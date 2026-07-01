import request from "supertest";
import { createApp } from "../app";

describe("wallpapers", () => {
  it("GET /api/wallpapers returns wallpapers with collection + counts", async () => {
    const res = await request(createApp()).get("/api/wallpapers");
    expect(res.status).toBe(200);
    expect(res.body.length).toBeGreaterThan(0);
    expect(res.body[0]).toEqual(
      expect.objectContaining({
        id: expect.any(String),
        imageUrl: expect.any(String),
        collection: expect.any(String),
        likes: expect.any(Number),
        shares: expect.any(Number),
        setCount: expect.any(Number),
      }),
    );
  });

  it("filters by deity", async () => {
    const res = await request(createApp()).get("/api/wallpapers?deity=ram");
    expect(res.status).toBe(200);
    expect(res.body.every((w: { deityId: string }) => w.deityId === "ram"))
      .toBe(true);
  });

  it("likes, sets and shares a wallpaper; 404s for unknown id", async () => {
    const app = createApp();
    const list = await request(app).get("/api/wallpapers");
    const id = list.body[0].id as string;
    const before = list.body[0] as { likes: number; setCount: number };

    const liked = await request(app)
      .post(`/api/wallpapers/${id}/like`)
      .send({ liked: true });
    expect(liked.status).toBe(200);
    expect(liked.body.likes).toBe(before.likes + 1);

    const set = await request(app).post(`/api/wallpapers/${id}/set`);
    expect(set.status).toBe(200);
    expect(set.body.setCount).toBe(before.setCount + 1);

    const shared = await request(app).post(`/api/wallpapers/${id}/share`);
    expect(shared.status).toBe(200);

    const missing = await request(app).post("/api/wallpapers/nope/set");
    expect(missing.status).toBe(404);

    // restore the like so the seed-independent suite stays balanced
    await request(app).post(`/api/wallpapers/${id}/like`).send({ liked: false });
  });
});

describe("ringtones", () => {
  it("GET /api/ringtones returns ringtones with audio + counts", async () => {
    const res = await request(createApp()).get("/api/ringtones");
    expect(res.status).toBe(200);
    expect(res.body.length).toBeGreaterThan(0);
    expect(res.body[0]).toEqual(
      expect.objectContaining({
        id: expect.any(String),
        title: expect.any(String),
        audioUrl: expect.any(String),
        plays: expect.any(Number),
        downloads: expect.any(Number),
        likes: expect.any(Number),
        shares: expect.any(Number),
        setCount: expect.any(Number),
      }),
    );
  });

  it("sets a ringtone (increments setCount); 404s for unknown id", async () => {
    const app = createApp();
    const list = await request(app).get("/api/ringtones");
    const id = list.body[0].id as string;
    const before = list.body[0].setCount as number;

    const set = await request(app).post(`/api/ringtones/${id}/set`);
    expect(set.status).toBe(200);
    expect(set.body.setCount).toBe(before + 1);

    const missing = await request(app).post("/api/ringtones/nope/set");
    expect(missing.status).toBe(404);
  });
});

describe("home feed", () => {
  it("GET /api/home/feed returns typed mixed items", async () => {
    const res = await request(createApp()).get("/api/home/feed");
    expect(res.status).toBe(200);
    expect(res.body.length).toBeGreaterThan(0);
    const types = new Set(res.body.map((x: { type: string }) => x.type));
    expect(types.has("status")).toBe(true);
    expect(types.has("wallpaper")).toBe(true);
    expect(types.has("ringtone")).toBe(true);
  });

  it("GET /api/home/banners returns banner image paths", async () => {
    const res = await request(createApp()).get("/api/home/banners");
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.length).toBeGreaterThan(0);
    for (const p of res.body) {
      expect(typeof p).toBe("string");
      expect(p.startsWith("/media/banners/")).toBe(true);
    }
  });
});
