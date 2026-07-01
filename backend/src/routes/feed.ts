import { Router, type Request, type Response } from "express";
import { prisma } from "../lib/prisma";
import { withSystemContext } from "../lib/rls-context";

export const feedRouter = Router();

/** GET /api/feed — deities from the DB (ordered). */
feedRouter.get("/api/feed", async (_req: Request, res: Response) => {
  try {
    const deities = await withSystemContext(prisma, "feed", (db) =>
      db.deity.findMany({ orderBy: { sort: "asc" } }),
    );
    res.json(
      deities.map((d) => ({ id: d.id, name: d.name, imageUrl: d.imageUrl })),
    );
  } catch {
    res.status(500).json({ error: "Failed to load feed" });
  }
});
