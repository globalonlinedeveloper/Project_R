import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../core/design_system/tokens/ratel_motion.dart';
import '../features/adventures/adventures_screen.dart';
import '../features/adventures/scene_screen.dart';
import '../features/auth/welcome_screen.dart';
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

/// First-run gate. Behind [authEnabled] (R-L1) a guest-first Welcome screen is
/// shown once before onboarding; with the flag off this is a no-op and the
/// original onboarding-first behaviour on `main` is unchanged.
String? _redirect(BuildContext context, GoRouterState state) {
  final loc = state.matchedLocation;
  if (authEnabled && !welcomeSeen.value) {
    return loc == '/welcome' ? null : '/welcome';
  }
  final atOnboarding = loc == '/onboarding';
  if (!onboardingComplete.value && !atOnboarding) return '/onboarding';
  if (onboardingComplete.value && atOnboarding) return '/learn';
  return null;
}

/// Tab-shell IA (R-L10): Learn / Practice / Adventures / Profile.
final GoRouter ratelRouter = GoRouter(
  initialLocation: '/learn',
  refreshListenable: Listenable.merge([onboardingComplete, welcomeSeen]),
  redirect: _redirect,
  routes: [
    GoRoute(
      path: '/welcome',
      pageBuilder: (c, s) => _fadePage(WelcomeScreen(
        onContinueAsGuest: () {
          welcomeSeen.value = true;
          c.go('/onboarding');
        },
        // onSignIn is wired when the Login flow lands (queue #4); until then the
        // Welcome screen is guest-only by design.
      )),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (c, s) => _fadePage(const OnboardingFlow()),
    ),
    GoRoute(
      path: '/lesson',
      pageBuilder: (c, s) => _fadePage(
          LessonScreen(isReview: s.uri.queryParameters['review'] == '1')),
    ),
    GoRoute(
      path: '/scene/:id',
      pageBuilder: (c, s) =>
          _fadePage(SceneScreen(sceneId: s.pathParameters['id']!)),
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
