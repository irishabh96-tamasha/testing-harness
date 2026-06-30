---
name: frontend-patterns
description: Frontend patterns for Flutter (Dart) with Riverpod state, go_router navigation, Dio networking, and a Figma-token-driven theme. Use when building screens/widgets, wiring state, adding routes, or calling the backend API. Ensures consistent, idiomatic, accessible Flutter UI.
user-invocable: false
allowed-tools: Read, Grep, Glob
---

# Frontend Patterns Skill (Flutter)

## Purpose

Ensure consistent Flutter development: Riverpod for state, go_router for
navigation, Dio for the API, and `Theme.of(context)` fed by the Figma-generated
`design_tokens` package for all styling.

## When This Skill Applies

- Building or modifying any screen or widget
- Wiring state / data loading / mutations
- Adding navigation routes
- Calling the backend API from the app
- Theming and applying design tokens

> If the work implements a Figma design, ALSO use the `figma-devmode` skill.

## Project Layout

```text
app/lib/
├── main.dart                    # ProviderScope + MaterialApp.router
├── core/
│   ├── network/api_client.dart  # apiClientProvider (Dio)
│   └── router/app_router.dart   # GoRouter config (one route per screen)
├── design_system/
│   └── app_theme.dart           # design_tokens → ThemeData
└── features/<feature>/          # one folder per feature
    ├── <feature>_screen.dart
    └── <feature>_controller.dart
packages/design_tokens/          # colors/spacing/typography (Figma-generated)
```

## State Management (Riverpod)

- **Default to `AsyncNotifier`** (or `FutureProvider` for read-only) — see
  `patterns_library/ui/riverpod-async-provider.md`.
- Widgets are `ConsumerWidget` / `ConsumerStatefulWidget`; they `ref.watch`
  state and call notifier methods. Keep widgets dumb.
- Wrap async work in `AsyncValue.guard`; render all three states
  (loading / error+retry / data).
- Prefer `autoDispose`; use `.family` for keyed state.
- Surface one-off events (snackbars, navigation) via `ref.listen`, never in `build`.

```dart
class CounterController extends AutoDisposeAsyncNotifier<int> {
  @override
  Future<int> build() async => 0;
  Future<void> increment() async =>
      state = AsyncData((state.valueOrNull ?? 0) + 1);
}
final counterControllerProvider =
    AutoDisposeAsyncNotifierProvider<CounterController, int>(CounterController.new);
```

## Navigation (go_router)

- All routes declared in `core/router/app_router.dart`, one `GoRoute` per screen,
  each with a `name`. Navigate with `context.goNamed('home')` /
  `context.pushNamed(...)`, not by constructing widgets directly.

```dart
GoRoute(
  path: '/items/:id',
  name: 'item-detail',
  builder: (context, state) =>
      ItemDetailScreen(id: state.pathParameters['id']!),
),
```

## Networking (Dio)

- Use the shared `apiClientProvider` (`core/network/api_client.dart`). Base URL
  comes from `--dart-define=API_BASE_URL`.
- Don't construct `Dio()` inline in features. Auth/headers/retry belong in
  interceptors registered on the shared client.

## Theming & Design Tokens (NON-NEGOTIABLE)

- **Never hardcode** colors, spacing, radii, or text styles in a widget.
- Tokens live in `packages/design_tokens`; `app_theme.dart` maps them to
  `ThemeData`; widgets read `Theme.of(context)` (`colorScheme`, `textTheme`).
- Tokens are Figma-generated — change values in Figma, regenerate, don't hand-edit.

```dart
// ❌ DON'T
Container(color: const Color(0xFF3D5AFE), padding: const EdgeInsets.all(16));
Text('Hi', style: TextStyle(fontSize: 28));

// ✅ DO
Container(
  color: Theme.of(context).colorScheme.primary,
  padding: const EdgeInsets.all(AppSpacing.md),
);
Text('Hi', style: Theme.of(context).textTheme.headlineLarge);
```

## Widget Conventions

- `const` constructors wherever possible (lint enforces it).
- `super.key` on every widget; trailing commas (auto-formats cleanly).
- Compose small widgets; extract private `_Foo` widgets over giant `build`
  methods or helper methods returning `Widget`.
- Package imports only (`package:mobile_app/...`), not relative (`../..`).

## Accessibility

- [ ] Tap targets ≥ 48×48 dp
- [ ] `Semantics` / `semanticLabel` on icon-only buttons and images
- [ ] Text scales with the system (avoid fixed heights that clip large fonts)
- [ ] Color contrast ≥ 4.5:1 (verify token choices)
- [ ] Don't convey state by color alone

```dart
IconButton(
  icon: const Icon(Icons.close),
  tooltip: 'Close',            // also provides a semantic label
  onPressed: () => Navigator.of(context).pop(),
);
```

## Common Mistakes to Avoid

```dart
// ❌ Hardcoded style literals (use theme + design_tokens)
// ❌ Business logic / API calls inside build()
// ❌ setState for server data (use Riverpod AsyncNotifier)
// ❌ Constructing Dio() per feature (use apiClientProvider)
// ❌ Navigating by pushing widgets (use go_router named routes)
// ❌ Forgetting to dispose TextEditingController / controllers
```

## Authoritative References

- **UI patterns**: `patterns_library/ui/`
  - `authenticated-page.md` — async data screen
  - `data-table.md` — data list
  - `form-with-validation.md` — validated form
  - `riverpod-async-provider.md` — state + mutations
- **Theme**: `app/lib/design_system/app_theme.dart`
- **Tokens**: `packages/design_tokens/`
- **Figma → code**: the `figma-devmode` skill
- **Testing**: the `testing-patterns` skill (widget / golden / integration tests)
