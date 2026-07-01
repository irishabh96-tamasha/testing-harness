import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/shell/main_shell.dart';

/// Application router. The shell owns the bottom-nav tab switching; add
/// deep-linkable routes here as features need them.
final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) => const MainShell(),
    ),
  ],
);
