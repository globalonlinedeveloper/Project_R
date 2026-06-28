import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/common/coming_soon_screen.dart';
import 'package:ratel/features/home/home_screen.dart';
import 'package:ratel/features/leagues/leagues_screen.dart';
import 'package:ratel/features/library/library_screen.dart';
import 'package:ratel/features/profile/profile_screen.dart';
import 'package:ratel/features/quests/quests_screen.dart';

/// The app router — a [StatefulShellRoute] with one branch per bottom-nav tab
/// (Home / Library / Leagues / Quests / Profile, design spec §3). Each branch
/// keeps its own navigation state in an IndexedStack so tab switches preserve
/// scroll position. Sub-screens (Settings, Shop, …) are TOP-LEVEL routes pushed
/// over the shell (full-screen, own back arrow). Provided per-scope (below) so
/// each app instance / test gets a fresh router.
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
                  const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
              path: '/library',
              builder: (BuildContext context, GoRouterState state) =>
                  const LibraryScreen(),
            ),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
              path: '/leagues',
              builder: (BuildContext context, GoRouterState state) =>
                  const LeaguesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
              path: '/quests',
              builder: (BuildContext context, GoRouterState state) =>
                  const QuestsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
              path: '/profile',
              builder: (BuildContext context, GoRouterState state) =>
                  const ProfileScreen(),
            ),
          ]),
        ],
      ),

      // ── Sub-screens (pushed full-screen over the shell) ──────────────────
      // Real screens (Settings / Progress / Onboarding) land in later
      // increments — until then an honest "coming next" stub; the §6 no-engine
      // destinations (Shop / Notifications / Friends) state the owner decision.
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) =>
            const ComingSoonScreen(
          title: 'Settings',
          emoji: '⚙️',
          blurb: 'Settings are coming next — daily goal, sound, reduce motion '
              'and high contrast are already real under the hood.',
        ),
      ),
      GoRoute(
        path: '/progress',
        builder: (BuildContext context, GoRouterState state) =>
            const ComingSoonScreen(
          title: 'Progress',
          emoji: '📊',
          blurb: 'The progress dashboard is coming next, built entirely from '
              'your real learner stats — nothing here is invented.',
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) =>
            const ComingSoonScreen(
          title: 'Onboarding',
          emoji: '🦡',
          blurb: 'The onboarding flow (Welcome → Language → Reason → Goal → '
              'Placement) is coming next, wired to the real placement engine.',
        ),
      ),
      GoRoute(
        path: '/shop',
        builder: (BuildContext context, GoRouterState state) =>
            const ComingSoonScreen(
          title: 'Shop',
          emoji: '💎',
          blurb: 'The diamond economy and consumables have no backend engine '
              'yet — an owner decision (build a wallet/ledger, or leave it out '
              'of v1). Nothing here is faked.',
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (BuildContext context, GoRouterState state) =>
            const ComingSoonScreen(
          title: 'Notifications',
          emoji: '🔔',
          blurb: 'There is no notification engine yet — an owner decision '
              '(local reminders vs push vs an in-app inbox).',
        ),
      ),
      GoRoute(
        path: '/friends',
        builder: (BuildContext context, GoRouterState state) =>
            const ComingSoonScreen(
          title: 'Friends',
          emoji: '👥',
          blurb: 'Friends & social (followers, friend activity, "passed you") '
              'have no engine yet — an owner decision.',
        ),
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
