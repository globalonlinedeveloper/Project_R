import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../core/design_system/tokens/ratel_motion.dart';
import '../features/adventures/adventures_screen.dart';
import '../features/home/home_screen.dart';
import '../features/lesson/lesson_screen.dart';
import '../features/onboarding/onboarding_flow.dart';
import '../features/practice/practice_screen.dart';
import '../features/profile/profile_screen.dart';
import 'app_flags.dart';
import 'shell.dart';

/// Defined page transition (R-L17), timed from motion tokens (R-L16).
CustomTransitionPage<void> _fadePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: RatelMotion.pageTransition,
    reverseTransitionDuration: RatelMotion.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// First-run gate: route to /onboarding until it completes.
String? _redirect(BuildContext context, GoRouterState state) {
  final atOnboarding = state.matchedLocation == '/onboarding';
  if (!onboardingComplete.value && !atOnboarding) return '/onboarding';
  if (onboardingComplete.value && atOnboarding) return '/learn';
  return null;
}

/// Tab-shell IA (R-L10): Learn / Practice / Adventures / Profile.
final GoRouter ratelRouter = GoRouter(
  initialLocation: '/learn',
  refreshListenable: onboardingComplete,
  redirect: _redirect,
  routes: [
    GoRoute(
      path: '/onboarding',
      pageBuilder: (c, s) => _fadePage(const OnboardingFlow()),
    ),
    GoRoute(
      path: '/lesson',
      pageBuilder: (c, s) => _fadePage(const LessonScreen()),
    ),
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
