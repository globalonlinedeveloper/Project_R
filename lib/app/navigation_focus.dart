import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom-nav branch indices — MUST match the [StatefulShellBranch] order in
/// `buildRouter` (Home / Library / Leagues / Quests / Profile, design spec §3).
/// A named constant keeps focus-refresh consumers off a brittle magic number.
abstract final class RatelTab {
  static const int home = 0;
  static const int library = 1;
  static const int leagues = 2;
  static const int quests = 3;
  static const int profile = 4;
}

/// The active bottom-nav branch, PUBLISHED by `RatelShell` on every tab change.
/// A tab watches/listens this to react to REGAINING focus — e.g. the Leagues tab
/// re-polls its live cross-user cohort when re-entered (focus-refresh, S77,
/// complementing the S76 pull-to-refresh). The shell owns the write; tabs are
/// read-only consumers. Not autoDispose — it lives for the app session.
class ActiveTabController extends Notifier<int> {
  @override
  int build() => RatelTab.home;

  /// Set the active branch index. A no-op when unchanged, so the shell's
  /// per-build post-frame publish never spuriously notifies listeners.
  void setActive(int index) {
    if (state != index) state = index;
  }
}

final activeTabIndexProvider =
    NotifierProvider<ActiveTabController, int>(ActiveTabController.new);
