import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../core/design_system/tokens/ratel_motion.dart';
import '../features/adventures/adventures_screen.dart';
import '../features/home/home_screen.dart';
import '../features/practice/practice_screen.dart';
import '../features/profile/profile_screen.dart';
import 'shell.dart';

/// Defined page transition (R-L17: primary navigation never hard-cuts), timed
/// from motion tokens (R-L16) so the build's token-lint stays satisfied.
CustomTransitionPage<void> _fadePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: RatelMotion.pageTransition,
    reverseTransitionDuration: RatelMotion.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// Tab-shell IA (R-L10): Learn / Practice / Adventures / Profile, each an
/// independently-stateful branch.
final GoRouter ratelRouter = GoRouter(
  initialLocation: '/learn',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RatelShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/learn', pageBuilder: (c, s) => _fadePage(const HomeScreen())),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/practice',
              pageBuilder: (c, s) => _fadePage(const PracticeScreen())),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/adventures',
              pageBuilder: (c, s) => _fadePage(const AdventuresScreen())),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/profile',
              pageBuilder: (c, s) => _fadePage(const ProfileScreen())),
        ]),
      ],
    ),
  ],
);
