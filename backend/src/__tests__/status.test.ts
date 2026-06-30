import request from "supertest";
import { createApp } from "../app";

describe("GET /api/status", () => {
  it("returns statuses for the requested deity", async () => {
    const res = await request(createApp()).get("/api/status?deity=hanuman");
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.length).toBeGreaterThan(0);
    expect(res.body[0]).toEqual(
      expect.objectContaining({
        id: expect.any(String),
        imageUrl: expect.any(String),
        authorName: expect.any(String),
        likes: expect.any(Number),
        views: expect.any(Number),
      }),
    );
  });

  it("defaults to 'all' when no deity is given", async () => {
    const res = await request(createApp()).get("/api/status");
    expect(res.status).toBe(200);
    expect(res.body[0].id.startsWith("all-")).toBe(true);
  });
});

describe("GET /api/home/feed", () => {
  it("returns all statuses across deities", async () => {
    const res = await request(createApp()).get("/api/home/feed");
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    // more than any single deity's list (statuses from all deities combined)
    expect(res.body.length).toBeGreaterThan(3);
    expect(res.body[0]).toEqual(
      expect.objectContaining({
        id: expect.any(String),
        deityId: expect.any(String),
        likes: expect.any(Number),
      }),
    );
  });
});

describe("POST /api/status/:id/like", () => {
  it("persists a like and an unlike", async () => {
    const app = createApp();
    const before = (await request(app).get("/api/status?deity=all")).body[0];

    const liked = await request(app)
      .post(`/api/status/${before.id}/like`)
      .send({ liked: true });
    expect(liked.status).toBe(200);
    expect(liked.body.likes).toBe(before.likes + 1);

    const unliked = await request(app)
      .post(`/api/status/${before.id}/like`)
      .send({ liked: false });
    expect(unliked.body.likes).toBe(before.likes);
  });

  it("rejects a bad body", async () => {
    const res = await request(createApp())
      .post("/api/status/all-1/like")
      .send({});
    expect(res.status).toBe(400);
  });
});

describe("POST /api/status/:id/view", () => {
  it("persists a view", async () => {
    const app = createApp();
    const before = (await request(app).get("/api/status?deity=all")).body[0];
    const res = await request(app).post(`/api/status/${before.id}/view`).send();
    expect(res.status).toBe(200);
    expect(res.body.views).toBe(before.views + 1);
  });

  it("404s for an unknown id", async () => {
    const res = await request(createApp())
      .post("/api/status/does-not-exist/view")
      .send();
    expect(res.status).toBe(404);
  });
});
