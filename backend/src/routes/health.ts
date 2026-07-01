import { Router, type Request, type Response } from "express";

export const healthRouter = Router();

/** GET /health — liveness probe. No DB access. */
healthRouter.get("/health", (_req: Request, res: Response) => {
  res.json({ status: "ok", service: "mobile-app-backend" });
});
