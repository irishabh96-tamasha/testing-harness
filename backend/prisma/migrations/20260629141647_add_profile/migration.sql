-- CreateTable
CREATE TABLE "profiles" (
    "id" TEXT NOT NULL DEFAULT 'me',
    "name" TEXT NOT NULL DEFAULT '',
    "avatarUrl" TEXT NOT NULL DEFAULT '',
    "businessName" TEXT NOT NULL DEFAULT '',
    "businessDetails" TEXT NOT NULL DEFAULT '',
    "businessMobile" TEXT NOT NULL DEFAULT '',
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "profiles_pkey" PRIMARY KEY ("id")
);
