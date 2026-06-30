import { Router, type Request, type Response } from "express";
import { z } from "zod";
import type { Status } from "@prisma/client";
import { prisma } from "../lib/prisma";
import { withSystemContext } from "../lib/rls-context";
import { serializeWallpaper, serializeRingtone } from "./media";

export const statusRouter = Router();

/** Public shape returned to the app. */
function serialize(s: Status) {
  return {
    id: s.id,
    deityId: s.deityId,
    imageUrl: s.imageUrl,
    authorName: s.authorName,
    authorSubtitle: s.authorSubtitle,
    tagline: s.tagline,
    authorAvatarUrl: s.authorAvatarUrl,
    likes: s.likes,
    views: s.views,
  };
}

/**
 * GET /api/home/feed — the Home "Trending" feed: a typed, interleaved mix of
 * status, wallpaper and ringtone cards (Figma Home 285:3464). Each item carries
 * a `type` discriminator the app switches on to pick a card widget.
 */
statusRouter.get("/api/home/feed", async (_req: Request, res: Response) => {
  try {
    const [statuses, wallpapers, ringtones] = await withSystemContext(
      prisma,
      "home:feed",
      (db) =>
        Promise.all([
          db.status.findMany({ orderBy: [{ deityId: "asc" }, { sort: "asc" }] }),
          db.wallpaper.findMany({
            where: { collection: "trending" },
            orderBy: { sort: "asc" },
          }),
          db.ringtone.findMany({ orderBy: { plays: "desc" } }),
        ]),
    );

    const statusItems = statuses.map((s) => ({
      type: "status" as const,
      ...serialize(s),
    }));
    const wallpaperItems = wallpapers.map((w) => ({
      type: "wallpaper" as const,
      ...serializeWallpaper(w),
    }));
    const ringtoneItems = ringtones.map((r) => ({
      type: "ringtone" as const,
      ...serializeRingtone(r),
    }));

    // Interleave for variety: status, wallpaper, ringtone, repeat. Leftovers of
    // any list are appended in order so nothing is dropped.
    const feed: Array<
      | (typeof statusItems)[number]
      | (typeof wallpaperItems)[number]
      | (typeof ringtoneItems)[number]
    > = [];
    const lanes = [statusItems, wallpaperItems, ringtoneItems];
    for (let i = 0; lanes.some((l) => i < l.length); i++) {
      for (const lane of lanes) if (i < lane.length) feed.push(lane[i]);
    }

    res.json(feed);
  } catch {
    res.status(500).json({ error: "Failed to load home feed" });
  }
});

/**
 * GET /api/home/banners — promo banner carousel images for the Home top slot
 * (Figma Home banners 285:3507). Served statically from /media/banners; the app
 * resolves these relative paths to absolute URLs. No DB content here, but the
 * list stays backend-driven so banners can change without an app release.
 */
const HOME_BANNERS = [
  "/media/banners/banner-1.jpg",
  "/media/banners/banner-2.jpg",
  "/media/banners/banner-3.jpg",
];

statusRouter.get("/api/home/banners", (_req: Request, res: Response) => {
  res.json(HOME_BANNERS);
});

/** GET /api/status?deity=<id> — that deity's statuses (ordered). */
statusRouter.get("/api/status", async (req: Request, res: Response) => {
  try {
    const deity =
      typeof req.query.deity === "string" ? req.query.deity : "all";
    const list = await withSystemContext(prisma, "status:list", (db) =>
      db.status.findMany({
        where: { deityId: deity },
        orderBy: { sort: "asc" },
      }),
    );
    res.json(list.map(serialize));
  } catch {
    res.status(500).json({ error: "Failed to load statuses" });
  }
});

const LikeBody = z.object({ liked: z.boolean() });

/** POST /api/status/:id/like { liked } — persist a like / unlike. */
statusRouter.post(
  "/api/status/:id/like",
  async (req: Request, res: Response) => {
    const parsed = LikeBody.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ error: "Body must be { liked: boolean }" });
      return;
    }
    try {
      const updated = await withSystemContext(prisma, "status:like", (db) =>
        db.status.update({
          where: { id: req.params.id },
          data: { likes: { increment: parsed.data.liked ? 1 : -1 } },
        }),
      );
      res.json(serialize(updated));
    } catch {
      res.status(404).json({ error: "Status not found" });
    }
  },
);

/** POST /api/status/:id/view — persist a view. */
statusRouter.post(
  "/api/status/:id/view",
  async (req: Request, res: Response) => {
    try {
      const updated = await withSystemContext(prisma, "status:view", (db) =>
        db.status.update({
          where: { id: req.params.id },
          data: { views: { increment: 1 } },
        }),
      );
      res.json(serialize(updated));
    } catch {
      res.status(404).json({ error: "Status not found" });
    }
  },
);
