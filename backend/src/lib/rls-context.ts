import type { Prisma, PrismaClient } from "@prisma/client";

/**
 * RLS context helpers.
 *
 * Every database operation MUST run inside one of these. Each opens a
 * transaction and sets Postgres session-local config (`app.current_user_id`,
 * `app.role`) via set_config(..., true) so that RLS policies defined in the
 * SQL migrations can enforce row-level isolation. `is_local = true` scopes the
 * setting to the surrounding transaction.
 *
 * See: patterns_library/database/rls-migration.md and the rls-patterns skill.
 */

type TxCallback<T> = (client: Prisma.TransactionClient) => Promise<T>;

async function withContext<T>(
  prisma: PrismaClient,
  settings: Record<string, string>,
  callback: TxCallback<T>,
): Promise<T> {
  return prisma.$transaction(async (tx) => {
    for (const [key, value] of Object.entries(settings)) {
      // set_config is parameterized to avoid SQL injection via the value.
      await tx.$executeRaw`SELECT set_config(${key}, ${value}, true)`;
    }
    return callback(tx);
  });
}

/** User-scoped operations (profile, user-owned data). */
export function withUserContext<T>(
  prisma: PrismaClient,
  userId: string,
  callback: TxCallback<T>,
): Promise<T> {
  return withContext(
    prisma,
    { "app.current_user_id": userId, "app.role": "user" },
    callback,
  );
}

/** Admin-scoped operations (privileged tables). `userId` is the acting admin. */
export function withAdminContext<T>(
  prisma: PrismaClient,
  userId: string,
  callback: TxCallback<T>,
): Promise<T> {
  return withContext(
    prisma,
    { "app.current_user_id": userId, "app.role": "admin" },
    callback,
  );
}

/** System operations (webhooks, background jobs). `source` is for audit/logging. */
export function withSystemContext<T>(
  prisma: PrismaClient,
  source: string,
  callback: TxCallback<T>,
): Promise<T> {
  return withContext(
    prisma,
    { "app.current_user_id": `system:${source}`, "app.role": "system" },
    callback,
  );
}
