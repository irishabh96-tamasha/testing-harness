import request from "supertest";
import { createApp } from "../app";

describe("wallpapers", () => {
  it("GET /api/wallpapers returns wallpapers with a collection", async () => {
    const res = await request(createApp()).get("/api/wallpapers");
    expect(res.status).toBe(200);
    expect(res.body.length).toBeGreaterThan(0);
    expect(res.body[0]).toEqual(
      expect.objectContaining({
        id: expect.any(String),
        imageUrl: expect.any(String),
        collection: expect.any(String),
      }),
    );
  });

  it("filters by deity", async () => {
    const res = await request(createApp()).get("/api/wallpapers?deity=ram");
    expect(res.status).toBe(200);
    expect(res.body.every((w: { deityId: string }) => w.deityId === "ram"))
      .toBe(true);
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
      }),
    );
  });
});
