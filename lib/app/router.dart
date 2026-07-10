import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/app/auth_gate.dart';
import 'package:ratel/app/navigation_focus.dart';
import 'package:ratel/services/billing/billing.dart';
import 'package:ratel/features/adventures/adventures_screen.dart';
import 'package:ratel/features/adventures/adventure_player_screen.dart';
import 'package:ratel/features/roleplay/roleplay_screen.dart';
import 'package:ratel/features/roleplay/live_roleplay_screen.dart';
import 'package:ratel/features/roleplay/roleplay_player_screen.dart';
import 'package:ratel/features/auth/login_screen.dart';
import 'package:ratel/features/auth/signup_screen.dart';
import 'package:ratel/features/auth/welcome_screen.dart';
import 'package:ratel/features/common/coming_soon_screen.dart';
import 'package:ratel/features/friends/friends_screen.dart';
import 'package:ratel/features/home/home_screen.dart';
import 'package:ratel/features/leagues/leagues_screen.dart';
import 'package:ratel/features/library/library_search_screen.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';
import 'package:ratel/features/library/library_screen.dart';
import 'package:ratel/features/stories/stories_screen.dart';
import 'package:ratel/features/stories/story_reader_screen.dart';
import 'package:ratel/features/podcasts/podcasts_screen.dart';
import 'package:ratel/features/podcasts/podcast_player_screen.dart';
import 'package:ratel/features/watch/watch_screen.dart';
import 'package:ratel/features/watch/watch_player_screen.dart';
import 'package:ratel/features/onboarding/onboarding_screen.dart';
import 'package:ratel/features/onboarding/placement_quiz_screen.dart';
import 'package:ratel/features/practice/practice_hub_screen.dart';
import 'package:ratel/features/profile/edit_profile_screen.dart';
import 'package:ratel/features/profile/profile_screen.dart';
import 'package:ratel/features/progress/progress_screen.dart';
import 'package:ratel/features/quests/quests_screen.dart';
import 'package:ratel/features/settings/settings_screen.dart';
import 'package:ratel/features/notifications/notifications_screen.dart';
import 'package:ratel/features/paywall/paywall_screen.dart';
import 'package:ratel/features/shop/shop_screen.dart';
import 'package:ratel/features/tutor/ai_tutor_screen.dart';
import 'package:ratel/features/themes/themes_screen.dart';

/// A not-yet-built destination rendered as an honest [ComingSoonScreen]. The
/// list is now EMPTY — every navigable destination resolves to a real screen
/// (Friends, the last stub, became a real screen in S64 / R-I9 + R-L8). The
/// typedef + const are kept as the seam for any future honest stub (and are
/// asserted-empty by the route tests); adding one is a one-line edit here.
typedef ComingSoonRoute = ({
  String path,
  String title,
  String emoji,
  String blurb,
});

const List<ComingSoonRoute> kComingSoonRoutes = <ComingSoonRoute>[];

/// The app router — a [StatefulShellRoute] with one branch per bottom-nav tab
/// (Home / Library / Leagues / Quests / Profile, design spec §3). Each branch
/// keeps its own navigation state in an IndexedStack so tab switches preserve
/// scroll position. Sub-screens are TOP-LEVEL routes pushed over the shell
/// (full-screen, own back arrow). Provided per-scope (below) for test isolation.
GoRouter buildRouter({
  bool Function()? welcomeGateNeeded,
  VoidCallback? onSessionEntered,
}) {
  return GoRouter(
    initialLocation: '/home',
    // AUTH-1 (S112): first-launch Welcome gate. While the gate is needed,
    // every location except the gate + the account-entry screens redirects to
    // /welcome; both hooks default null/off so pre-gate tests (and keyless
    // builds) stay byte-identical.
    redirect: (BuildContext context, GoRouterState state) {
      if (!(welcomeGateNeeded?.call() ?? false)) return null;
      final String loc = state.matchedLocation;
      const Set<String> open = <String>{'/welcome', '/login', '/signup'};
      return open.contains(loc) ? null : '/welcome';
    },
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
        path: '/themes',
        builder: (BuildContext context, GoRouterState state) =>
            const ThemesScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (BuildContext context, GoRouterState state) =>
            const EditProfileScreen(),
      ),
      GoRoute(
        path: '/shop',
        builder: (BuildContext context, GoRouterState state) =>
            const ShopScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (BuildContext context, GoRouterState state) =>
            const NotificationsScreen(),
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
        path: '/search',
        builder: (BuildContext context, GoRouterState state) =>
            const LibrarySearchScreen(),
      ),
      GoRoute(
        path: '/stories',
        builder: (BuildContext context, GoRouterState state) =>
            const StoriesScreen(),
      ),
      GoRoute(
        path: '/story',
        builder: (BuildContext context, GoRouterState state) =>
            StoryReaderScreen(passageId: state.uri.queryParameters['passage']),
      ),
      GoRoute(
        path: '/podcasts',
        builder: (BuildContext context, GoRouterState state) =>
            const PodcastsScreen(),
      ),
      GoRoute(
        path: '/podcast',
        builder: (BuildContext context, GoRouterState state) =>
            PodcastPlayerScreen(passageId: state.uri.queryParameters['passage']),
      ),
      GoRoute(
        path: '/watch',
        builder: (BuildContext context, GoRouterState state) =>
            const WatchScreen(),
      ),
      GoRoute(
        path: '/watch-play',
        builder: (BuildContext context, GoRouterState state) =>
            WatchPlayerScreen(passageId: state.uri.queryParameters['passage']),
      ),
      GoRoute(
        path: '/roleplay',
        builder: (BuildContext context, GoRouterState state) =>
            const RoleplayScreen(),
      ),
      GoRoute(
        path: '/roleplay-play',
        builder: (BuildContext context, GoRouterState state) =>
            RoleplayPlayerScreen(
                scenarioId: state.uri.queryParameters['scenario']),
      ),
      GoRoute(
        path: '/roleplay-live',
        builder: (BuildContext context, GoRouterState state) =>
            LiveRoleplayScreen(
                scenarioId: state.uri.queryParameters['scenario'],
                freeForm: state.uri.queryParameters['mode'] == 'free'),
      ),
      GoRoute(
        path: '/adventure',
        builder: (BuildContext context, GoRouterState state) =>
            AdventurePlayerScreen(
                scenarioId: state.uri.queryParameters['scenario']),
      ),
      GoRoute(
        path: '/friends',
        builder: (BuildContext context, GoRouterState state) =>
            const FriendsScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (BuildContext context, GoRouterState state) => PaywallScreen(
            source: state.uri.queryParameters['source'] ?? 'direct'),
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
        path: '/welcome',
        builder: (BuildContext context, GoRouterState state) => WelcomeScreen(
          onRegister: () => context.push('/signup'),
          onLogin: () => context.push('/login'),
          onEntered: () => context.go('/home'),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) => LoginScreen(
          onAuthenticated: () {
            onSessionEntered?.call();
            context.go('/home');
          },
          onSignUpInstead: () => context.pushReplacement('/signup'),
        ),
      ),
      GoRoute(
        path: '/signup',
        builder: (BuildContext context, GoRouterState state) => SignupScreen(
          onAuthenticated: () {
            onSessionEntered?.call();
            context.go('/home');
          },
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
final routerProvider = Provider<GoRouter>((ref) => buildRouter(
      welcomeGateNeeded: () => ref.read(welcomeGateNeededProvider),
      onSessionEntered: () {
        // A session was established from the gate: drop it now and persist
        // the choice (best-effort) so later signed-out boots skip the gate
        // too (Settings keeps its sign-in entry).
        ref.read(welcomeGateNeededProvider.notifier).state = false;
        ref.read(authChoicePersisterProvider)(kAuthChoiceAccount).ignore();
        // L-5b (S114): pull the fresh pro flag so PRO surfaces unlock
        // immediately after login (no reboot needed). Best-effort.
        ref.read(proStatusRefresherProvider)().ignore();
      },
    ));

/// The persistent shell: the tab content + the 5-tab [RatelBottomNav]. Tapping
/// the active tab re-roots its branch (Duolingo-style).
class RatelShell extends ConsumerWidget {
  const RatelShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Publish the active bottom-nav branch so a tab can react to REGAINING focus
    // (Leagues re-polls its live cohort — focus-refresh, complementing the S76
    // pull-to-refresh). Post-frame: never mutate a provider during build; the
    // setActive guard makes a redundant publish a no-op.
    final int activeIndex = navigationShell.currentIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeTabIndexProvider.notifier).setActive(activeIndex);
    });
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
