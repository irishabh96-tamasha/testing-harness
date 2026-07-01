import { Router, type Request, type Response } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { withSystemContext } from "../lib/rls-context";

export const profileRouter = Router();

const PROFILE_ID = "me";

/** GET /api/profile — the (singleton) profile, created empty if missing. */
profileRouter.get("/api/profile", async (_req: Request, res: Response) => {
  try {
    const profile = await withSystemContext(prisma, "profile:get", (db) =>
      db.profile.upsert({
        where: { id: PROFILE_ID },
        update: {},
        create: { id: PROFILE_ID },
      }),
    );
    res.json(profile);
  } catch {
    res.status(500).json({ error: "Failed to load profile" });
  }
});

const ProfileBody = z.object({
  name: z.string().max(120).optional(),
  avatarUrl: z.string().max(2000).optional(),
  businessName: z.string().max(120).optional(),
  businessDetails: z.string().max(500).optional(),
  businessMobile: z.string().max(40).optional(),
});

/** PUT /api/profile — update the profile. */
profileRouter.put("/api/profile", async (req: Request, res: Response) => {
  const parsed = ProfileBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: "Invalid profile body" });
    return;
  }
  try {
    const profile = await withSystemContext(prisma, "profile:put", (db) =>
      db.profile.upsert({
        where: { id: PROFILE_ID },
        update: parsed.data,
        create: { id: PROFILE_ID, ...parsed.data },
      }),
    );
    res.json(profile);
  } catch {
    res.status(500).json({ error: "Failed to save profile" });
  }
});
