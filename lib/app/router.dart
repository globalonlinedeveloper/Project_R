import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/adventures/adventures_screen.dart';
import 'package:ratel/features/auth/login_screen.dart';
import 'package:ratel/features/auth/signup_screen.dart';
import 'package:ratel/features/common/coming_soon_screen.dart';
import 'package:ratel/features/home/home_screen.dart';
import 'package:ratel/features/leagues/leagues_screen.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';
import 'package:ratel/features/library/library_screen.dart';
import 'package:ratel/features/onboarding/onboarding_screen.dart';
import 'package:ratel/features/onboarding/placement_quiz_screen.dart';
import 'package:ratel/features/practice/practice_hub_screen.dart';
import 'package:ratel/features/profile/profile_screen.dart';
import 'package:ratel/features/progress/progress_screen.dart';
import 'package:ratel/features/quests/quests_screen.dart';
import 'package:ratel/features/settings/settings_screen.dart';
import 'package:ratel/features/shop/shop_screen.dart';
import 'package:ratel/features/tutor/ai_tutor_screen.dart';

/// A not-yet-built destination rendered as an honest [ComingSoonScreen].
/// Settings / Progress / Onboarding / daily-quiz / Shop are REAL screens;
/// Notifications / Friends remain §6 owner-decisions (no engine). Adding or
/// ▶swapping a route is a one-line edit to this list.
typedef ComingSoonRoute = ({
  String path,
  String title,
  String emoji,
  String blurb,
});

const List<ComingSoonRoute> kComingSoonRoutes = <ComingSoonRoute>[
  (
    path: '/notifications',
    title: 'Notifications',
    emoji: '🔔',
    blurb: 'There is no notification engine yet — an owner decision (local '
        'reminders vs push vs an in-app inbox).'
  ),
  (
    path: '/friends',
    title: 'Friends',
    emoji: '👥',
    blurb: 'Friends & social (followers, friend activity, "passed you") have '
        'no engine yet — an owner decision.'
  ),
  (
    path: '/search',
    title: 'Search',
    emoji: '🔍',
    blurb: 'Library search is coming next — it will query the real content '
        'catalogue (lessons, saved words, stories).'
  ),
];

/// The app router — a [StatefulShellRoute] with one branch per bottom-nav tab
/// (Home / Library / Leagues / Quests / Profile, design spec §3). Each branch
/// keeps its own navigation state in an IndexedStack so tab switches preserve
/// scroll position. Sub-screens are TOP-LEVEL routes pushed over the shell
/// (full-screen, own back arrow). Provided per-scope (below) for test isolation.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) =>
            RatelShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/home',
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeScreen()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/library',
                builder: (BuildContext context, GoRouterState state) =>
                    const LibraryScreen()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/leagues',
                builder: (BuildContext context, GoRouterState state) =>
                    const LeaguesScreen()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/quests',
                builder: (BuildContext context, GoRouterState state) =>
                    const QuestsScreen()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/profile',
                builder: (BuildContext context, GoRouterState state) =>
                    const ProfileScreen()),
          ]),
        ],
      ),

      // Sub-screens (pushed full-screen over the shell). Honest stubs until the
      // real screen lands — see [kComingSoonRoutes].
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
      GoRoute(
        path: '/shop',
        builder: (BuildContext context, GoRouterState state) =>
            const ShopScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      GoRoute(
        path: '/placement',
        builder: (BuildContext context, GoRouterState state) =>
            const PlacementQuizScreen(),
      ),
      GoRoute(
        path: '/progress',
        builder: (BuildContext context, GoRouterState state) =>
            const ProgressScreen(),
      ),
      GoRoute(
        path: '/tutor',
        builder: (BuildContext context, GoRouterState state) =>
            const AiTutorScreen(),
      ),
      GoRoute(
        path: '/adventures',
        builder: (BuildContext context, GoRouterState state) =>
            const AdventuresScreen(),
      ),
      GoRoute(
        path: '/daily-quiz',
        builder: (BuildContext context, GoRouterState state) =>
            LessonRunnerScreen(lessonId: state.uri.queryParameters['lesson']),
      ),
      GoRoute(
        path: '/practice',
        builder: (BuildContext context, GoRouterState state) =>
            const PracticeHubScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) => LoginScreen(
          onAuthenticated: () => context.go('/home'),
          onSignUpInstead: () => context.pushReplacement('/signup'),
        ),
      ),
      GoRoute(
        path: '/signup',
        builder: (BuildContext context, GoRouterState state) => SignupScreen(
          onAuthenticated: () => context.go('/home'),
          onSignInInstead: () => context.pushReplacement('/login'),
        ),
      ),
      for (final ComingSoonRoute r in kComingSoonRoutes)
        GoRoute(
          path: r.path,
          builder: (BuildContext context, GoRouterState state) =>
              ComingSoonScreen(title: r.title, emoji: r.emoji, blurb: r.blurb),
        ),
    ],
  );
}

/// One [GoRouter] per provider scope (test isolation).
final routerProvider = Provider<GoRouter>((ref) => buildRouter());

/// The persistent shell: the tab content + the 5-tab [RatelBottomNav]. Tapping
/// the active tab re-roots its branch (Duolingo-style).
class RatelShell extends StatelessWidget {
  const RatelShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: RatelBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
