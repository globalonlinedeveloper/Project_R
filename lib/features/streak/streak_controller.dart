import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Account streak (R-L8). Pure + in-memory only (learner state stays stubs
/// until Stage 3 — R-O1). "Day" = the device-local calendar date (local
/// midnight boundary), so it never depends on a server clock.
class StreakState {
  const StreakState({
    this.current = 0,
    this.longest = 0,
    this.lastActiveEpochDay,
  });

  final int current;
  final int longest;

  /// Days since the Unix epoch for the last active LOCAL date (null = never).
  final int? lastActiveEpochDay;

  bool activeOn(int epochDay) => lastActiveEpochDay == epochDay;

  StreakState copyWith({int? current, int? longest, int? lastActiveEpochDay}) =>
      StreakState(
        current: current ?? this.current,
        longest: longest ?? this.longest,
        lastActiveEpochDay: lastActiveEpochDay ?? this.lastActiveEpochDay,
      );
}

/// Local-midnight day index for a [DateTime] (uses its local Y/M/D only).
int localEpochDay(DateTime now) =>
    DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

class StreakController extends StateNotifier<StreakState> {
  StreakController([StreakState? initial]) : super(initial ?? const StreakState());

  /// Record a learning activity for the local day of [now]. Same-day repeats
  /// are no-ops; a consecutive next day extends the streak; any gap resets it
  /// to 1. [longest] only ever grows.
  void recordActivity([DateTime? now]) {
    final today = localEpochDay(now ?? DateTime.now());
    final last = state.lastActiveEpochDay;
    if (last == today) return; // already counted today
    final next = (last != null && today - last == 1) ? state.current + 1 : 1;
    state = state.copyWith(
      current: next,
      longest: next > state.longest ? next : state.longest,
      lastActiveEpochDay: today,
    );
  }
}

final streakControllerProvider =
    StateNotifierProvider<StreakController, StreakState>(
        (ref) => StreakController());
