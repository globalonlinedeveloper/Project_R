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
import 'package:ratel/features/settings/settings_screen.dart';

/// A not-yet-built destination rendered as an honest [ComingSoonScreen].
/// Settings / Progress / Onboarding / daily-quiz are REAL screens landing in
/// later increments; Shop / Notifications / Friends are §6 owner-decisions (no
/// engine). Adding/▶swapping a route is a one-line edit to this list.
typedef ComingSoonRoute = ({
  String path,
  String title,
  String emoji,
  String blurb,
});

const List<ComingSoonRoute> kComingSoonRoutes = <ComingSoonRoute>[
  (
    path: '/progress',
    title: 'Progress',
    emoji: '📊',
    blurb: 'The progress dashboard is coming next, built entirely from your '
        'real learner stats — nothing here is invented.'
  ),
  (
    path: '/onboarding',
    title: 'Onboarding',
    emoji: '🦡',
    blurb: 'The onboarding flow (Welcome → Language → Reason → Goal → '
        'Placement) is coming next, wired to the real placement engine.'
  ),
  (
    path: '/daily-quiz',
    title: 'Daily refresh',
    emoji: '🎯',
    blurb: 'The lesson / quiz runner is coming next — it will serve a real '
        '5-item mix from your review queue and score it through the '
        'CAT / IRT / FSRS engines.'
  ),
  (
    path: '/shop',
    title: 'Shop',
    emoji: '💎',
    blurb: 'The diamond economy and consumables have no backend engine yet — '
        'an owner decision (build a wallet/ledger, or leave it out of v1). '
        'Nothing here is faked.'
  ),
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
    path: '/tutor',
    title: 'AI Tutor',
    emoji: '🦡',
    blurb: 'The AI Tutor (Talk / Chat / Roleplay) is coming next, wired to the '
        'cost-guarded, moderated ai_relay engine behind a PRO gate.'
  ),
  (
    path: '/adventures',
    title: 'Adventures',
    emoji: '🗺️',
    blurb: 'Adventures (free roleplay scenes) are coming next, wired to the '
        'moderated ai_relay engine — every scene a real conversation.'
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
