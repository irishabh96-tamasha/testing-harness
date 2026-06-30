import express, { type Express } from "express";
import path from "node:path";
import { healthRouter } from "./routes/health";
import { feedRouter } from "./routes/feed";
import { statusRouter } from "./routes/status";
import { profileRouter } from "./routes/profile";
import { horoscopeRouter } from "./routes/horoscope";
import { booksRouter } from "./routes/books";
import { mediaRouter } from "./routes/media";

/** Build the Express app. Kept separate from index.ts so tests can import it. */
export function createApp(): Express {
  const app = express();
  app.use(express.json());

  // Dev-only permissive CORS so the Flutter web build (different port) can call
  // the API. NOT enabled in production — lock origins down before shipping web.
  if (process.env.NODE_ENV !== "production") {
    app.use((req, res, next) => {
      res.header("Access-Control-Allow-Origin", "*");
      res.header("Access-Control-Allow-Headers", "*");
      res.header("Access-Control-Allow-Methods", "*");
      if (req.method === "OPTIONS") {
        res.sendStatus(204);
        return;
      }
      next();
    });
  }

  // Static devotional media (deity faces, wallpapers, ringtone covers),
  // extracted from Figma and served from backend/public/media.
  app.use("/media", express.static(path.join(process.cwd(), "public", "media")));

  // Routes
  app.use(healthRouter);
  app.use(feedRouter);
  app.use(statusRouter);
  app.use(profileRouter);
  app.use(horoscopeRouter);
  app.use(booksRouter);
  app.use(mediaRouter);

  return app;
}
