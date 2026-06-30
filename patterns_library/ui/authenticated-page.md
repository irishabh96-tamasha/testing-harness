# Async Data Screen Pattern (Flutter + Riverpod)

> Filename kept as `authenticated-page.md` for index stability; this is the
> Flutter screen pattern (the Next.js "authenticated page" analog).

## What It Does

Creates a Flutter screen that loads data from the backend API through a Riverpod
provider and renders explicit loading / error / data states. Auth (when added)
is carried by the Dio client; the screen itself just consumes the provider.

## When to Use

- Any screen that fetches user/server data on open
- Dashboards, detail screens, profile screens
- Screens behind auth (token attached by the Dio interceptor, not the widget)

## Code Pattern

```dart
// app/lib/features/{feature}/{feature}_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';

// 1. Model (or use a generated/freezed model)
class {Resource} {
  const {Resource}({required this.id, required this.name});
  factory {Resource}.fromJson(Map<String, dynamic> json) =>
      {Resource}(id: json['id'] as String, name: json['name'] as String);
  final String id;
  final String name;
}

// 2. Provider: fetch via the shared Dio client (auth handled there)
final {resource}Provider =
    FutureProvider.autoDispose<List<{Resource}>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final res = await dio.get<List<dynamic>>('/api/{resource}');
  return (res.data ?? <dynamic>[])
      .map((e) => {Resource}.fromJson(e as Map<String, dynamic>))
      .toList();
});

// 3. Screen: render the three states explicitly
class {Feature}Screen extends ConsumerWidget {
  const {Feature}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<{Resource}>> items = ref.watch({resource}Provider);
    return Scaffold(
      appBar: AppBar(title: const Text('{Title}')),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => _ErrorView(
          message: 'Could not load {resource}.',
          onRetry: () => ref.invalidate({resource}Provider),
        ),
        data: (List<{Resource}> data) => RefreshIndicator(
          onRefresh: () => ref.refresh({resource}Provider.future),
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, int i) => ListTile(title: Text(data[i].name)),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
```

## Customization Guide

1. Replace `{Feature}`, `{Resource}`, `{resource}`, `{Title}` and the endpoint.
2. Swap the hand-written model/provider for generated ones if using
   `riverpod_generator` / `freezed` (see `riverpod-async-provider.md`).
3. Register the screen's route in `app/lib/core/router/app_router.dart`.
4. Pull all styling from `Theme.of(context)` — never hardcode colors/spacing.

## Checklist

- [ ] All three states handled (loading, error with retry, data)
- [ ] Provider is `autoDispose` unless the data must outlive the screen
- [ ] No direct color/spacing literals (use theme + `design_tokens`)
- [ ] Route added to `app_router.dart`
- [ ] Widget test covers the data + error states

## Validation

```bash
cd app && flutter analyze && flutter test
```

## Related Patterns

- [Riverpod Async Provider](./riverpod-async-provider.md) - state + mutations
- [Data List](./data-table.md) - collection rendering
- [Form with Validation](./form-with-validation.md) - data entry
- [User Context API](../api/user-context-api.md) - the backend endpoint

---

**Last Updated**: 2026-06
**Validated By**: System Architect
