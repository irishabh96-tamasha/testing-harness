-- CreateTable
CREATE TABLE "users" (
    "user_id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "deities" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "imageUrl" TEXT NOT NULL,
    "sort" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "deities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "statuses" (
    "id" TEXT NOT NULL,
    "deityId" TEXT NOT NULL,
    "imageUrl" TEXT NOT NULL,
    "authorName" TEXT NOT NULL,
    "authorSubtitle" TEXT NOT NULL,
    "tagline" TEXT NOT NULL,
    "authorAvatarUrl" TEXT NOT NULL,
    "likes" INTEGER NOT NULL DEFAULT 0,
    "views" INTEGER NOT NULL DEFAULT 0,
    "sort" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "statuses_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "statuses_deityId_sort_idx" ON "statuses"("deityId", "sort");

-- AddForeignKey
ALTER TABLE "statuses" ADD CONSTRAINT "statuses_deityId_fkey" FOREIGN KEY ("deityId") REFERENCES "deities"("id") ON DELETE CASCADE ON UPDATE CASCADE;
