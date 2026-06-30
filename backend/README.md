# mobile-app backend

Express + TypeScript + Prisma API.

## Setup

```bash
npm install
cp .env.example .env        # then edit DATABASE_URL
npm run prisma:generate
npm run prisma:migrate      # requires a running Postgres
```

## Scripts

| Command | Purpose |
| --- | --- |
| `npm run dev` | Start API in watch mode |
| `npm run build` | Compile TypeScript to `dist/` |
| `npm start` | Run compiled server |
| `npm run lint` / `lint:fix` | ESLint (enforces RLS-only DB access) |
| `npm run typecheck` | `tsc --noEmit` |
| `npm test` | Unit tests (Jest) |
| `npm run test:integration` | Integration tests |
| `npm run prisma:migrate` | Create + apply a migration |

## Database access rule

All DB access goes through `src/lib/rls-context.ts`
(`withUserContext` / `withAdminContext` / `withSystemContext`). Direct
`prisma.*` calls are blocked by ESLint. RLS policies are defined in SQL
migrations — see `patterns_library/database/rls-migration.md`.
