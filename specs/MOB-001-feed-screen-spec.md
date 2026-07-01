# Spec: Feed Screen (pilot)

## Linear Issue Reference

- **Ticket**: [MOB-001]
- **URL**: https://linear.app/tamasha/issue/MOB-001

> **Pilot note**: First feature exercising the adapted Flutter + Express harness
> end-to-end (spec → pattern → Figma → implementation → validation). The "feed"
> is realized as the **deities selector** from the Tamasha Status design
> (Figma node `302:4384`). Real design tokens were pulled via
> `get_variable_defs` (orange brand ramp, grey scale, Inter type) and written to
> `packages/design_tokens`; the screen reads them through the theme. See
> #PLAN_UNCERTAINTY for what remains.

## High-Level Objective

### User Story

**As a** user
**I want to** see a scrollable feed of items when I open the app
**So that** I can browse the latest content at a glance

### Business Context

The feed is the app's primary landing surface. This pilot establishes the
canonical "list screen" path (provider → API → list with loading/empty/error +
pull-to-refresh) that later list features reuse.

## Acceptance Criteria

- [ ] Opening the Feed screen fetches items from `GET /api/feed`
- [ ] Loading shows a spinner; error shows a retry affordance; empty shows an empty state
- [ ] Items render in a scrollable list; pull-to-refresh re-fetches
- [ ] Tapping an item navigates to a detail route (placeholder target acceptable for pilot)
- [ ] No hardcoded colors/spacing/type — styling via `Theme.of(context)` / `design_tokens`
- [ ] `flutter analyze` clean, `flutter test` passing for the feed widget
- [ ] Backend `GET /api/feed` returns a typed JSON array; `npm run lint/typecheck/test` pass

## Pattern References

### Primary Patterns

- **Pattern Used**: `patterns_library/ui/data-table.md` (Data List)
- **Justification**: Canonical scrollable-collection screen with all states + refresh.

### Secondary Patterns

- **Pattern Used**: `patterns_library/ui/riverpod-async-provider.md`
- **Usage**: Feed state/fetch via an async provider.
- **Pattern Used**: `patterns_library/api/user-context-api.md`
- **Usage**: Shape for the backend read endpoint (RLS context when a real data model lands).

## Low-Level Implementation Tasks

### Backend Tasks

1. [ ] Add `GET /api/feed` route returning `FeedItem[]` (id, title, subtitle)
2. [ ] Register the router in `src/app.ts`
3. [ ] Unit test the endpoint (supertest)

### Frontend Tasks

1. [ ] `feed_models.dart` — `FeedItem` model + `fromJson`
2. [ ] `feed_controller.dart` — `feedProvider` fetching `/api/feed` via `apiClientProvider`
3. [ ] `feed_screen.dart` — list screen (loading/empty/error/data + refresh) per Data List pattern
4. [ ] Add `/feed` named route to `core/router/app_router.dart`; link from Home
5. [ ] Widget test covering data + error states (override `feedProvider`)
6. [ ] Replace placeholder item styling with Figma-frame tokens via `figma-devmode` (post-prereqs)

### Database Tasks

1. [ ] (Deferred) `feed_items` table + RLS migration when the feed is backed by real data
   — Data Engineer; the pilot endpoint returns a static list, touching no DB.

## Critical Handoff Notes

### #PATH_DECISION

Pilot endpoint returns an in-memory list (no Prisma) so the UI path is provable
without first designing a data model. Real persistence is a follow-up enabler.
This keeps the RLS rule intact (no DB access = no context needed) rather than
faking a DB call.

### #PLAN_UNCERTAINTY

- Tokens were pulled from Figma; **not yet compiler-verified** — the Flutter SDK
  isn't on PATH, so `flutter analyze`/`flutter test` haven't run. Code was
  authored against the patterns and self-reviewed only.
- `letterSpacing` from Figma ("-3") is ambiguous; approximated as small negative
  values in `design_tokens`. Confirm against the design once running.
- Deity images use placeholder URLs (picsum) — swap for real asset URLs.
- Auth is TBD (no user context on `/api/feed` yet).

### #EXPORT_CRITICAL

- NEVER hardcode colors/spacing/type in widgets — tokens only (`design_tokens`).
- When the feed becomes user-specific, the endpoint MUST move to
  `withUserContext` and add an RLS migration before shipping.

## Testing Strategy

### Unit Tests

- [ ] `GET /api/feed` returns 200 + array shape (backend, supertest)

### Integration Tests

- [ ] (Later) App → backend feed fetch against a running API

### End-to-End Tests

- [ ] (Later) Boot app → feed loads → pull-to-refresh → tap item

### Manual Testing

- [ ] Feed renders on device; compare item card to the Figma frame

## Definition of Done

- [ ] All acceptance criteria met
- [ ] All tests passing (`npm run ci:validate`)
- [ ] No hardcoded design values (token discipline upheld)
- [ ] PR created with evidence (screenshot vs Figma frame) attached
- [ ] Linear ticket updated with session ID and validation results

## Notes for Execution Agent

1. Read the Data List + Riverpod Async Provider patterns first.
2. Use the `figma-devmode` skill for the item card once the MCP tools are live.
3. Run `cd app && flutter analyze && flutter test` and the backend lane before handoff.
