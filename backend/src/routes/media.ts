import { Router, type Request, type Response } from "express";
import type { Wallpaper, Ringtone } from "@prisma/client";
import { prisma } from "../lib/prisma";
import { withSystemContext } from "../lib/rls-context";

export const mediaRouter = Router();

function deityFilter(req: Request): { deityId: string } | undefined {
  const deity = typeof req.query.deity === "string" ? req.query.deity : "all";
  return deity === "all" ? undefined : { deityId: deity };
}

function serializeWallpaper(w: Wallpaper) {
  return {
    id: w.id,
    deityId: w.deityId,
    imageUrl: w.imageUrl,
    collection: w.collection,
  };
}

function serializeRingtone(r: Ringtone) {
  return {
    id: r.id,
    deityId: r.deityId,
    title: r.title,
    imageUrl: r.imageUrl,
    audioUrl: r.audioUrl,
    plays: r.plays,
    downloads: r.downloads,
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
