# CLAUDE.md

## AI Assistant Context for SAFe Multi-Agent Development

**Repository**: mobile-app
**Methodology**: SAFe (Scaled Agile Framework) Agentic Workflow
**Philosophy**: "Round Table" - Equal voice, mutual respect, shared responsibility

---

## Quick Start

This is a **SAFe multi-agent development project** with 11 specialized AI agents working collaboratively. You are part of a team where your input has equal weight with human contributors.

**Core Principles**:
- Search for existing patterns before creating new ones ("Search First, Reuse Always")
- Attach evidence to Linear tickets for all work
- You have "stop-the-line" authority for architectural/security concerns
- Follow SAFe methodology: Epic → Feature → Story → Enabler

**Key Resources**:
- [AGENTS.md](AGENTS.md) - All 11 agent roles, invocation patterns, capabilities
- [CONTRIBUTING.md](CONTRIBUTING.md) - Git workflow, commit standards, PR process
- [docs/onboarding/](docs/onboarding/) - Setup guides and daily workflows
- [docs/guides/ROUND-TABLE-PHILOSOPHY.md](docs/guides/ROUND-TABLE-PHILOSOPHY.md) - Collaboration principles
- [patterns_library/](patterns_library/) - Reusable code patterns (18+ patterns, 7 categories)

---

## Development Commands

This is a monorepo: `app/` is the Flutter client, `backend/` is the Express API.

```bash
# Development server
cd app && flutter run                          # App: run on device/emulator
npm --prefix backend run dev                   # Backend: start API (watch mode)

# Build and production
cd app && flutter build apk                    # App: Android build (use `ios` for iOS)
npm --prefix backend run build                 # Backend: compile TypeScript
npm --prefix backend start                     # Backend: start production server

# Code quality
cd app && flutter analyze                      # App: static analysis (lint)
npm --prefix backend run lint                  # Backend: ESLint
cd app && dart format .                         # App: auto-format
npm --prefix backend run lint:fix              # Backend: auto-fix lint
cd app && dart analyze                          # App: type/analysis check
npm --prefix backend run typecheck             # Backend: tsc --noEmit

# Testing
cd app && flutter test                          # App: widget/unit tests
npm --prefix backend test                       # Backend: unit tests (Jest)
cd app && flutter test integration_test         # App: integration tests
npm --prefix backend run test:integration       # Backend: API integration tests

# Database
npm --prefix backend run prisma:migrate         # Run migrations (Prisma)

# CI/CD validation (REQUIRED before PR)
npm run ci:validate                             # Run all quality checks (both lanes)
```

**Important**: Always run `npm run ci:validate` before creating a pull request.

---

## Architecture Overview

### Technology Stack

- **Frontend**: Flutter (Dart), Riverpod state management
- **Backend**: Express (Node.js / TypeScript)
- **Database**: PostgreSQL
- **ORM**: Prisma
- **Authentication**: TBD (backend-issued JWT planned)
- **Payments**: None (out of scope for now)
- **Analytics**: None (out of scope for now)
- **UI Components**: Flutter Material / Cupertino + project design-system package (Figma-token driven)
- **Design source**: Figma (Dev Mode MCP → design tokens → Dart theme → widgets)

### Repository Structure

```
mobile-app/
├── CLAUDE.md                    # This file - AI assistant context
├── AGENTS.md                    # Agent team quick reference
├── CONTRIBUTING.md              # Git workflow and commit standards
├── app/                         # Flutter client (lib/{features,core,design_system})
├── backend/                     # Express API (src/, prisma/)
├── packages/design_tokens/      # Figma → tokens → Dart theme
├── docs/                        # Documentation (onboarding, database, security, sop, workflow)
├── specs/                       # SAFe specifications (Epic/Feature/Story)
├── patterns_library/            # Reusable code patterns (7 categories)
├── .claude/                     # Claude Code harness (hooks, commands, skills, agents)
├── agent_providers/             # Agent configurations
└── scripts/                     # Utility scripts
```

---

## SAFe Workflow

All work follows the SAFe hierarchy and specs-driven development:

1. BSA creates spec in `specs/MOB-XXX-feature-spec.md`
2. System Architect validates architectural approach
3. Implementation agents execute with pattern discovery
4. QAS validates against acceptance criteria
5. Evidence attached to Linear ticket before POPM review

### Metacognitive Tags

Use in specs to highlight critical decisions:
- `#PATH_DECISION` - Architectural path chosen (document alternatives)
- `#PLAN_UNCERTAINTY` - Areas requiring validation
- `#EXPORT_CRITICAL` - Security/compliance requirements

### Pattern Discovery Protocol (MANDATORY)

**Before implementing ANY feature:**

1. Search `patterns_library/` for existing patterns
2. Search `specs/` for similar specifications
3. Search codebase for similar implementations
4. Consult documentation: [CONTRIBUTING.md](CONTRIBUTING.md), [docs/database/](docs/database/), [docs/security/](docs/security/)
5. Propose to System Architect before implementation

---

## Project-Specific Implementation Notes

*Customize this section for your technology stack.*

### Authentication

**Provider**: TBD (backend-issued JWT planned)

- Environment variables: See `.env.template`
- Routes (backend): `/api/auth/*` (public) / `/api/*` (protected)
- Patterns: `patterns_library/` + [docs/security/SECURITY_FIRST_ARCHITECTURE.md](docs/security/SECURITY_FIRST_ARCHITECTURE.md)

### Payments

**Provider**: None (out of scope for now)

- Re-enable `patterns_library/api/webhook-handler.md` and the `stripe-patterns` skill if/when payments are added.

### Analytics

**Provider**: None (out of scope for now)

- If added: privacy-first, no tracking without explicit consent (GDPR/CCPA); analytics failures must not crash the app.

### Design (Figma → Flutter)

**Source**: Figma Dev Mode MCP server (`figma-dev-mode` in `.mcp.json`, served locally at `http://127.0.0.1:3845/mcp` by the Figma desktop app).

- **Before building any UI from a design, use the `figma-devmode` skill.**
- Design variables flow: Figma → `packages/design_tokens` → `app/lib/design_system/app_theme.dart` → widgets via `Theme.of(context)`.
- **Never hardcode** colors/spacing/type in widgets — they belong in `design_tokens`. `get_code` output is a structural hint only (it emits web), not code to paste.
- Prereq: a Figma Dev Mode seat + the Dev Mode MCP server enabled in Figma.

### Database

**System**: PostgreSQL | **ORM**: Prisma

**Guidelines**:
- Always use ORM (type safety) with RLS context helpers (`withUserContext`, `withAdminContext`, `withSystemContext`)
- Always create proper migrations (never `db push` in production)
- Never use direct SQL or bypass RLS policies

**Schema Docs**: [docs/database/DATA_DICTIONARY.md](docs/database/DATA_DICTIONARY.md) (single source of truth)

**Migration Workflow**:
```bash
npx prisma migrate dev --name <feature>   # Create + apply migration locally (run in backend/)
npx prisma migrate deploy                  # Apply against a test/staging DB to verify
git add backend/prisma/migrations/ && git commit -m "feat(db): add feature migration"
npx prisma migrate deploy                  # Deploy to production
```

---

## Code Quality

**Linter**: `flutter analyze` (app, `analysis_options.yaml`) + ESLint (backend, `eslint.config.mjs`)

```bash
cd app && flutter analyze            # App: lint
npm --prefix backend run lint        # Backend: lint
cd app && dart format .              # App: auto-format
npm --prefix backend run lint:fix    # Backend: auto-fix
```

Always lint before committing. Consult `app/analysis_options.yaml` and `backend/eslint.config.mjs` for project-specific rules.

---

## CI/CD Pipeline

**MANDATORY**: Read [CONTRIBUTING.md](CONTRIBUTING.md) before any development.

### PR Workflow

1. Create feature branch: `MOB-{number}-{description}`
2. Implement with proper commits: `type(scope): description [MOB-XXX]`
3. Rebase: `git rebase origin/main`
4. Validate: `npm run ci:validate` (must pass)
5. Push: `git push --force-with-lease`
6. Create PR using `.github/pull_request_template.md`
7. Merge using "Rebase and merge" only

### Branch Protection

- All PRs must be up-to-date with `main`
- All CI checks must pass
- CODEOWNERS reviewers required
- No direct pushes to `main`

**Detailed Guides**: [docs/ci-cd/CI-CD-Pipeline-Guide.md](docs/ci-cd/CI-CD-Pipeline-Guide.md) | [docs/workflow/](docs/workflow/)
