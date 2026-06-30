import request from "supertest";
import { createApp } from "../app";

describe("GET /api/feed", () => {
  it("returns a typed array of deities", async () => {
    const res = await request(createApp()).get("/api/feed");
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.length).toBeGreaterThan(0);
    expect(res.body[0]).toEqual(
      expect.objectContaining({
        id: expect.any(String),
        name: expect.any(String),
        imageUrl: expect.any(String),
      }),
    );
  });
});
