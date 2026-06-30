import { Router, type Request, type Response } from "express";
import type { Book, Chapter } from "@prisma/client";
import { prisma } from "../lib/prisma";
import { withSystemContext } from "../lib/rls-context";

export const booksRouter = Router();

function serializeBook(b: Book) {
  return {
    id: b.id,
    title: b.title,
    author: b.author,
    coverUrl: b.coverUrl,
    category: b.category,
  };
}

function serializeChapter(c: Chapter) {
  return {
    id: c.id,
    section: c.section,
    title: c.title,
    body: c.body,
    audioUrl: c.audioUrl,
  };
}

/** GET /api/books?category=<name> — the library (optionally filtered). */
booksRouter.get("/api/books", async (req: Request, res: Response) => {
  try {
    const category =
      typeof req.query.category === "string" ? req.query.category : undefined;
    const list = await withSystemContext(prisma, "books:list", (db) =>
      db.book.findMany({
        where: category ? { category } : undefined,
        orderBy: { sort: "asc" },
      }),
    );
    res.json(list.map(serializeBook));
  } catch {
    res.status(500).json({ error: "Failed to load books" });
  }
});

/** GET /api/books/:id — a book with its ordered chapters. */
booksRouter.get("/api/books/:id", async (req: Request, res: Response) => {
  try {
    const book = await withSystemContext(prisma, "books:detail", (db) =>
      db.book.findUnique({
        where: { id: req.params.id },
        include: {
          chapters: { orderBy: [{ sectionSort: "asc" }, { sort: "asc" }] },
        },
      }),
    );
    if (!book) {
      res.status(404).json({ error: "Book not found" });
      return;
    }
    res.json({
      ...serializeBook(book),
      chapters: book.chapters.map(serializeChapter),
    });
  } catch {
    res.status(500).json({ error: "Failed to load book" });
  }
});
