import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/home/home_screen.dart';
import 'package:ratel/features/leagues/leagues_screen.dart';
import 'package:ratel/features/library/library_screen.dart';
import 'package:ratel/features/profile/profile_screen.dart';
import 'package:ratel/features/quests/quests_screen.dart';

/// The app router — a [StatefulShellRoute] with one branch per bottom-nav tab
/// (Home / Library / Leagues / Quests / Profile, design spec §3). Each branch
/// keeps its own navigation state in an IndexedStack so tab switches preserve
/// scroll position. Provided per-scope (below) so each app instance / test gets
/// a fresh router.
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
