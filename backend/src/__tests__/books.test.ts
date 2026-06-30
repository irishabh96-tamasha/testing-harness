import request from "supertest";
import { createApp } from "../app";

describe("books", () => {
  it("GET /api/books returns the library", async () => {
    const res = await request(createApp()).get("/api/books");
    expect(res.status).toBe(200);
    expect(res.body.length).toBeGreaterThan(0);
    expect(res.body[0]).toEqual(
      expect.objectContaining({
        id: expect.any(String),
        title: expect.any(String),
        author: expect.any(String),
        category: expect.any(String),
      }),
    );
  });

  it("GET /api/books?category= filters", async () => {
    const res = await request(createApp()).get("/api/books?category=Chalisa");
    expect(res.status).toBe(200);
    expect(res.body.every((b: { category: string }) => b.category === "Chalisa"))
      .toBe(true);
  });

  it("GET /api/books/:id returns a book with chapters", async () => {
    const res = await request(createApp()).get("/api/books/ramayan");
    expect(res.status).toBe(200);
    expect(res.body.id).toBe("ramayan");
    expect(Array.isArray(res.body.chapters)).toBe(true);
    expect(res.body.chapters.length).toBeGreaterThan(0);
    expect(res.body.chapters[0]).toEqual(
      expect.objectContaining({
        id: expect.any(String),
        section: expect.any(String),
        title: expect.any(String),
        body: expect.any(String),
        audioUrl: expect.any(String),
      }),
    );
  });

  it("GET /api/books/:id 404s for unknown id", async () => {
    const res = await request(createApp()).get("/api/books/nope");
    expect(res.status).toBe(404);
  });
});
