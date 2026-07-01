# Data List Pattern (Flutter + Riverpod)

> Filename kept as `data-table.md` for index stability; on mobile the tabular
> analog is a scrollable list/grid with item cards.

## What It Does

Renders a collection from the backend as a scrollable list with pull-to-refresh,
empty/loading/error states, and tappable item cards that navigate to a detail
route. Pagination is incremental (infinite scroll), not page-numbered.

## When to Use

- List screens (feed, history, search results, admin lists)
- Any collection of items the user scrolls and taps into
- Large collections needing incremental loading

## Code Pattern

```dart
// app/lib/features/{feature}/{feature}_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/network/api_client.dart';

final {resource}ListProvider =
    FutureProvider.autoDispose<List<{Resource}>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final res = await dio.get<List<dynamic>>('/api/{resource}');
  return (res.data ?? <dynamic>[])
      .map((e) => {Resource}.fromJson(e as Map<String, dynamic>))
      .toList();
});

class {Feature}List extends ConsumerWidget {
  const {Feature}List({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<{Resource}>> items = ref.watch({resource}ListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('{Title}')),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate({resource}ListProvider),
            child: const Text('Retry'),
          ),
        ),
        data: (List<{Resource}> data) {
          if (data.isEmpty) {
            return Center(
              child: Text('Nothing here yet',
                  style: Theme.of(context).textTheme.bodyMedium),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh({resource}ListProvider.future),
            child: ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (BuildContext context, int i) {
                final {Resource} item = data[i];
                return ListTile(
                  title: Text(item.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.goNamed('{resource}-detail',
                      pathParameters: <String, String>{'id': item.id}),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

## Customization Guide

1. Replace `{Feature}`, `{Resource}`, `{resource}`, `{Title}`, endpoint, route name.
2. Swap `ListTile` for a custom item card built from a Figma frame
   (see the `figma-devmode` skill) — keep styling in the theme.
3. For infinite scroll, watch a `StateNotifier`/`AsyncNotifier` that appends
   pages on scroll-near-end instead of a one-shot `FutureProvider`.
4. Add the detail route to `app/lib/core/router/app_router.dart`.

## Checklist

- [ ] Empty, loading, and error states all handled
- [ ] Pull-to-refresh wired (`RefreshIndicator`)
- [ ] Item tap navigates via `go_router` (named route)
- [ ] No hardcoded colors/spacing (theme + `design_tokens`)
- [ ] Widget test covers empty + populated list

## Validation

```bash
cd app && flutter analyze && flutter test
```

## Related Patterns

- [Async Data Screen](./authenticated-page.md)
- [Riverpod Async Provider](./riverpod-async-provider.md)

---

**Last Updated**: 2026-06
**Validated By**: System Architect
