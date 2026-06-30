# Frontend Patterns

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-v2.10.0-blue)

> Frontend patterns for Flutter (Dart): Riverpod state, go_router navigation, Dio networking, and a Figma-token-driven theme.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** © 2026 J. Scott Graham ([@cheddarfox](https://github.com/cheddarfox)) / [ByBren, LLC](https://github.com/bybren-llc)
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The skill system architecture and MOB harness methodology are the intellectual property of J. Scott Graham and ByBren, LLC.

## Quick Start

This skill activates automatically when you:
- Build new screens or widgets
- Wire state / data loading / mutations (Riverpod)
- Add navigation routes (go_router)
- Call the backend API (Dio)
- Apply theming and design tokens

## What This Skill Does

Ensures consistent Flutter development: Riverpod for state, go_router for
navigation, Dio for the API, and `Theme.of(context)` fed by the Figma-generated
`design_tokens` package for all styling. Includes accessibility and widget
conventions. For implementing a Figma design, pair with the `figma-devmode` skill.

## Trigger Keywords

| Primary | Secondary |
|---------|-----------|
| widget | screen |
| Riverpod | state |
| go_router | navigation |
| Dio | theme / tokens |

## Related Skills

- [figma-devmode](../figma-devmode/) - Figma frame → widget
- [testing-patterns](../testing-patterns/) - widget / golden / integration tests
- [api-patterns](../api-patterns/) - backend API the app calls

## Maintenance

| Field | Value |
|-------|-------|
| Last Updated | 2026-06 |
| Harness Version | v2.10.0 |

---

*Full implementation details in [SKILL.md](SKILL.md)*
