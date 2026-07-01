import { Router, type Request, type Response } from "express";
import { prisma } from "../lib/prisma";
import { withSystemContext } from "../lib/rls-context";

export const horoscopeRouter = Router();

/** GET /api/horoscope — the 12 zodiac signs with today's reading. */
horoscopeRouter.get("/api/horoscope", async (_req: Request, res: Response) => {
  try {
    const signs = await withSystemContext(prisma, "horoscope", (db) =>
      db.horoscope.findMany({ orderBy: { sort: "asc" } }),
    );
    res.json(signs);
  } catch {
    res.status(500).json({ error: "Failed to load horoscope" });
  }
});
