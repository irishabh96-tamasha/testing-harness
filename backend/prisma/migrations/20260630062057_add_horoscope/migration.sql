-- CreateTable
CREATE TABLE "horoscopes" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "reading" TEXT NOT NULL,
    "sort" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "horoscopes_pkey" PRIMARY KEY ("id")
);
