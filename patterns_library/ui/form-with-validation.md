# Form with Validation Pattern (Flutter)

## What It Does

Creates a validated Flutter form using `Form` + `TextFormField` validators, with
submission routed through a Riverpod provider that calls the backend and exposes
loading/error state. Styling comes from the theme; no hardcoded values.

## When to Use

- Data entry / settings / profile editing
- Sign-in / sign-up forms (once auth lands)
- Any screen that collects + submits user input

## Code Pattern

```dart
// app/lib/features/{feature}/{feature}_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';

// 1. Submit controller as an AsyncNotifier (idle → loading → data/error)
class {Feature}Controller extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit({required String name, required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final dio = ref.read(apiClientProvider);
      await dio.post<void>('/api/{resource}', data: {'name': name, 'email': email});
    });
  }
}

final {feature}ControllerProvider =
    AutoDisposeAsyncNotifierProvider<{Feature}Controller, void>(
  {Feature}Controller.new,
);

// 2. The form widget
class {Feature}Form extends ConsumerStatefulWidget {
  const {Feature}Form({super.key});

  @override
  ConsumerState<{Feature}Form> createState() => _{Feature}FormState();
}

class _{Feature}FormState extends ConsumerState<{Feature}Form> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read({feature}ControllerProvider.notifier)
        .submit(name: _name.text.trim(), email: _email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    // Surface submit errors via a listener (snackbar), keep build pure.
    ref.listen({feature}ControllerProvider, (_, AsyncValue<void> next) {
      if (next case AsyncError(:final Object error)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $error')));
      }
    });
    final bool submitting = ref.watch({feature}ControllerProvider).isLoading;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (String? v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (String? v) =>
                (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: submitting ? null : _onSubmit,
            child: submitting
                ? const SizedBox(
                    height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

## Customization Guide

1. Replace `{Feature}`, `{feature}`, `{resource}` and the fields/endpoint.
2. Add fields by adding a controller + `TextFormField` with a `validator`.
3. For complex validation, extract validators into `core/validation/` and reuse.
4. Use `InputDecorationTheme` in `AppTheme` to style all fields once.

## Checklist

- [ ] Every field has a `validator`; submit is gated on `validate()`
- [ ] Controllers disposed in `dispose()`
- [ ] Submit disabled + spinner shown while `isLoading`
- [ ] Errors surfaced via `ref.listen` (not in `build`)
- [ ] No hardcoded colors/spacing (theme + `design_tokens`)
- [ ] Widget test covers invalid + valid submit paths

## Validation

```bash
cd app && flutter analyze && flutter test
```

## Related Patterns

- [Riverpod Async Provider](./riverpod-async-provider.md)
- [Zod Validation API](../api/zod-validation-api.md) - server-side validation (must mirror client)
- [Async Data Screen](./authenticated-page.md)

---

**Last Updated**: 2026-06
**Validated By**: System Architect
