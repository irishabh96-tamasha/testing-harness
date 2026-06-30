import request from "supertest";
import { createApp } from "../app";

describe("profile", () => {
  it("GET returns a profile object", async () => {
    const res = await request(createApp()).get("/api/profile");
    expect(res.status).toBe(200);
    expect(res.body).toEqual(
      expect.objectContaining({
        id: expect.any(String),
        name: expect.any(String),
        businessName: expect.any(String),
      }),
    );
  });

  it("PUT persists changes", async () => {
    const app = createApp();
    const put = await request(app)
      .put("/api/profile")
      .send({ name: "Test User", businessName: "Test Co" });
    expect(put.status).toBe(200);
    expect(put.body.name).toBe("Test User");

    const get = await request(app).get("/api/profile");
    expect(get.body.name).toBe("Test User");
    expect(get.body.businessName).toBe("Test Co");

    // restore to empty so the screen demo starts clean
    await request(app)
      .put("/api/profile")
      .send({ name: "", businessName: "", businessDetails: "", businessMobile: "" });
  });

  it("rejects an invalid body", async () => {
    const res = await request(createApp())
      .put("/api/profile")
      .send({ name: 123 });
    expect(res.status).toBe(400);
  });
});
