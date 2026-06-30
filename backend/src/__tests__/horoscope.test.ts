import request from "supertest";
import { createApp } from "../app";

describe("GET /api/horoscope", () => {
  it("returns the 12 zodiac signs", async () => {
    const res = await request(createApp()).get("/api/horoscope");
    expect(res.status).toBe(200);
    expect(res.body.length).toBe(12);
    expect(res.body[0]).toEqual(
      expect.objectContaining({
        id: expect.any(String),
        name: expect.any(String),
        reading: expect.any(String),
      }),
    );
  });
});
