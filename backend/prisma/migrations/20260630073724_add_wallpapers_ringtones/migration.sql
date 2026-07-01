-- CreateTable
CREATE TABLE "wallpapers" (
    "id" TEXT NOT NULL,
    "deityId" TEXT NOT NULL,
    "imageUrl" TEXT NOT NULL,
    "collection" TEXT NOT NULL DEFAULT 'new',
    "sort" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "wallpapers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ringtones" (
    "id" TEXT NOT NULL,
    "deityId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "imageUrl" TEXT NOT NULL,
    "audioUrl" TEXT NOT NULL,
    "plays" INTEGER NOT NULL DEFAULT 0,
    "downloads" INTEGER NOT NULL DEFAULT 0,
    "sort" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "ringtones_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "wallpapers_deityId_collection_sort_idx" ON "wallpapers"("deityId", "collection", "sort");

-- CreateIndex
CREATE INDEX "ringtones_deityId_sort_idx" ON "ringtones"("deityId", "sort");
