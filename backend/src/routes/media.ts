import { Router, type Request, type Response } from "express";
import { z } from "zod";
import type { Wallpaper, Ringtone } from "@prisma/client";
import { prisma } from "../lib/prisma";
import { withSystemContext } from "../lib/rls-context";

export const mediaRouter = Router();

function deityFilter(req: Request): { deityId: string } | undefined {
  const deity = typeof req.query.deity === "string" ? req.query.deity : "all";
  return deity === "all" ? undefined : { deityId: deity };
}

export function serializeWallpaper(w: Wallpaper) {
  return {
    id: w.id,
    deityId: w.deityId,
    imageUrl: w.imageUrl,
    collection: w.collection,
    likes: w.likes,
    shares: w.shares,
    setCount: w.setCount,
  };
}

export function serializeRingtone(r: Ringtone) {
  return {
    id: r.id,
    deityId: r.deityId,
    title: r.title,
    imageUrl: r.imageUrl,
    audioUrl: r.audioUrl,
    plays: r.plays,
    downloads: r.downloads,
    likes: r.likes,
    shares: r.shares,
    setCount: r.setCount,
  };
}

/** GET /api/wallpapers?deity= — wallpapers (optionally filtered by deity). */
mediaRouter.get("/api/wallpapers", async (req: Request, res: Response) => {
  try {
    const list = await withSystemContext(prisma, "wallpapers", (db) =>
      db.wallpaper.findMany({
        where: deityFilter(req),
        orderBy: [{ collection: "asc" }, { sort: "asc" }],
      }),
    );
    res.json(list.map(serializeWallpaper));
  } catch {
    res.status(500).json({ error: "Failed to load wallpapers" });
  }
});

/** GET /api/ringtones?deity= — ringtones (optionally filtered by deity). */
mediaRouter.get("/api/ringtones", async (req: Request, res: Response) => {
  try {
    const list = await withSystemContext(prisma, "ringtones", (db) =>
      db.ringtone.findMany({
        where: deityFilter(req),
        orderBy: [{ deityId: "asc" }, { sort: "asc" }],
      }),
    );
    res.json(list.map(serializeRingtone));
  } catch {
    res.status(500).json({ error: "Failed to load ringtones" });
  }
});

const LikeBody = z.object({ liked: z.boolean() });

/** POST /api/wallpapers/:id/like { liked } — persist a like / unlike. */
mediaRouter.post(
  "/api/wallpapers/:id/like",
  async (req: Request, res: Response) => {
    const parsed = LikeBody.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ error: "Body must be { liked: boolean }" });
      return;
    }
    try {
      const updated = await withSystemContext(prisma, "wallpaper:like", (db) =>
        db.wallpaper.update({
          where: { id: req.params.id },
          data: { likes: { increment: parsed.data.liked ? 1 : -1 } },
        }),
      );
      res.json(serializeWallpaper(updated));
    } catch {
      res.status(404).json({ error: "Wallpaper not found" });
    }
  },
);

/** POST /api/wallpapers/:id/set — count a "set as wallpaper" action. */
mediaRouter.post(
  "/api/wallpapers/:id/set",
  async (req: Request, res: Response) => {
    try {
      const updated = await withSystemContext(prisma, "wallpaper:set", (db) =>
        db.wallpaper.update({
          where: { id: req.params.id },
          data: { setCount: { increment: 1 } },
        }),
      );
      res.json(serializeWallpaper(updated));
    } catch {
      res.status(404).json({ error: "Wallpaper not found" });
    }
  },
);

/** POST /api/wallpapers/:id/share — count a share action. */
mediaRouter.post(
  "/api/wallpapers/:id/share",
  async (req: Request, res: Response) => {
    try {
      const updated = await withSystemContext(prisma, "wallpaper:share", (db) =>
        db.wallpaper.update({
          where: { id: req.params.id },
          data: { shares: { increment: 1 } },
        }),
      );
      res.json(serializeWallpaper(updated));
    } catch {
      res.status(404).json({ error: "Wallpaper not found" });
    }
  },
);

/** POST /api/ringtones/:id/like { liked } — persist a like / unlike. */
mediaRouter.post(
  "/api/ringtones/:id/like",
  async (req: Request, res: Response) => {
    const parsed = LikeBody.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ error: "Body must be { liked: boolean }" });
      return;
    }
    try {
      const updated = await withSystemContext(prisma, "ringtone:like", (db) =>
        db.ringtone.update({
          where: { id: req.params.id },
          data: { likes: { increment: parsed.data.liked ? 1 : -1 } },
        }),
      );
      res.json(serializeRingtone(updated));
    } catch {
      res.status(404).json({ error: "Ringtone not found" });
    }
  },
);

/** POST /api/ringtones/:id/set — count a "set as ringtone" action. */
mediaRouter.post(
  "/api/ringtones/:id/set",
  async (req: Request, res: Response) => {
    try {
      const updated = await withSystemContext(prisma, "ringtone:set", (db) =>
        db.ringtone.update({
          where: { id: req.params.id },
          data: { setCount: { increment: 1 }, downloads: { increment: 1 } },
        }),
      );
      res.json(serializeRingtone(updated));
    } catch {
      res.status(404).json({ error: "Ringtone not found" });
    }
  },
);

/** POST /api/ringtones/:id/share — count a share action. */
mediaRouter.post(
  "/api/ringtones/:id/share",
  async (req: Request, res: Response) => {
    try {
      const updated = await withSystemContext(prisma, "ringtone:share", (db) =>
        db.ringtone.update({
          where: { id: req.params.id },
          data: { shares: { increment: 1 } },
        }),
      );
      res.json(serializeRingtone(updated));
    } catch {
      res.status(404).json({ error: "Ringtone not found" });
    }
  },
);

/** POST /api/ringtones/:id/play — count a playback. */
mediaRouter.post(
  "/api/ringtones/:id/play",
  async (req: Request, res: Response) => {
    try {
      const updated = await withSystemContext(prisma, "ringtone:play", (db) =>
        db.ringtone.update({
          where: { id: req.params.id },
          data: { plays: { increment: 1 } },
        }),
      );
      res.json(serializeRingtone(updated));
    } catch {
      res.status(404).json({ error: "Ringtone not found" });
    }
  },
);
