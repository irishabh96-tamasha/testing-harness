# mobile-app (Flutter client)

Flutter app using Riverpod (state), go_router (navigation), Dio (API), and the
local `design_tokens` package (Figma-generated theme).

## First-time setup

This directory was scaffolded by hand (source only). The native platform
folders (`android/`, `ios/`, etc.) are NOT yet present. With the Flutter SDK
installed:

```bash
cd app
flutter create . --platforms=android,ios   # generates android/ ios/ without overwriting lib/
flutter pub get
```

`flutter create .` is safe over existing `lib/` and `pubspec.yaml` — it only
fills in missing platform/tooling files.

## Daily commands

```bash
flutter run                      # run on device/emulator
flutter analyze                  # lint / static analysis
dart format .                    # format
flutter test                     # widget + unit tests
flutter test integration_test    # integration tests
```

## Structure

```
lib/
├── main.dart                 # app entry (ProviderScope + MaterialApp.router)
├── core/
│   ├── network/api_client.dart   # Dio client provider (API_BASE_URL dart-define)
│   └── router/app_router.dart    # go_router config
├── design_system/
│   └── app_theme.dart            # design_tokens → ThemeData
└── features/
    └── home/home_screen.dart     # sample screen (replace with Figma-built screens)
```

Styling comes from `Theme.of(context)`, fed by `../packages/design_tokens`.
Build new screens from Figma frames via the Dev Mode MCP pipeline (Step 3+).
