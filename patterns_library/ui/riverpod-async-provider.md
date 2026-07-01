# Riverpod Async Provider Pattern (Flutter)

## What It Does

Defines a unit of app state backed by an async source (the backend API) with
`AsyncNotifier`: exposes `AsyncValue` (loading/data/error) to widgets and
provides mutation methods that optimistically update and re-sync. This is the
default state-management building block for the app.

## When to Use

- Any state that comes from / writes to the backend (lists, detail, settings)
- Anywhere you'd otherwise reach for `setState` + manual loading flags
- As the controller behind screens (see Async Data Screen / Data List patterns)

## Code Pattern

```dart
// app/lib/features/{feature}/{feature}_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';

class {Feature}Controller extends AutoDisposeAsyncNotifier<List<{Resource}>> {
  @override
  Future<List<{Resource}>> build() async {
    // Initial load. Errors here surface as AsyncError to the UI automatically.
    final dio = ref.watch(apiClientProvider);
    final res = await dio.get<List<dynamic>>('/api/{resource}');
    return (res.data ?? <dynamic>[])
        .map((e) => {Resource}.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> add({Resource} item) async {
    final dio = ref.read(apiClientProvider);
    // Wrap mutations so failures become AsyncError instead of throwing.
    state = await AsyncValue.guard(() async {
      await dio.post<void>('/api/{resource}', data: item.toJson());
      final current = state.valueOrNull ?? <{Resource}>[];
      return <{Resource}>[...current, item];
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final {feature}ControllerProvider = AutoDisposeAsyncNotifierProvider<
    {Feature}Controller, List<{Resource}>>({Feature}Controller.new);
```

### Optional: codegen variant (`riverpod_generator`)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '{feature}_controller.g.dart';

@riverpod
class {Feature}Controller extends _${Feature}Controller {
  @override
  Future<List<{Resource}>> build() async { /* ...as above... */ }
}
// Run: dart run build_runner watch -d
```

## Customization Guide

1. Replace `{Feature}`, `{feature}`, `{Resource}`, `{resource}`, endpoints.
2. Pick the param shape: use `.family` when the controller is keyed (e.g. by id).
3. Drop `autoDispose` only if the state must persist across screen pops.
4. Keep widgets dumb: they `ref.watch` the provider and call notifier methods.

## Checklist

- [ ] Async work wrapped in `AsyncValue.guard` (no raw throws into state)
- [ ] Widgets read `AsyncValue` and handle all three states
- [ ] `autoDispose` unless persistence is required
- [ ] `.family` used for keyed/parameterized state
- [ ] Unit test the controller with a mocked Dio / overridden `apiClientProvider`

## Validation

```bash
cd app && flutter analyze && flutter test
```

## Related Patterns

- [Async Data Screen](./authenticated-page.md) - consuming a provider in a screen
- [Form with Validation](./form-with-validation.md) - mutation controllers
- [Data List](./data-table.md) - list state

---

**Last Updated**: 2026-06
**Validated By**: System Architect
