import { PrismaClient } from "@prisma/client";

/**
 * Singleton PrismaClient.
 *
 * Do NOT import this directly into route/service code to run queries — that is
 * blocked by ESLint. Route code must go through the RLS context helpers in
 * ./rls-context, which set the per-request Postgres session context that RLS
 * policies depend on.
 */
const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma =
  globalForPrisma.prisma ?? new PrismaClient({ log: ["warn", "error"] });

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}
