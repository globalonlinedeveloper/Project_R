import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/services/data_access/data_access.dart'
    show LeaguesStore, leaguesStoreProvider, kLeagueMembershipKey;
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/leagues/leagues.dart';

/// Bridges the REAL learner weekly XP + the durable [LeaguesStore] seam to the
/// pure [LeaguesEngine] (design spec §4.3 [R-I6]). Honesty (charter "don't fake
/// depth"): a guest — or any learner before the cross-user backend answers — is
/// an honest cohort of ONE carrying their real weekly XP, never a fabricated
/// leaderboard. On a real `auth.uid()` session the controller CONSUMES the store:
/// it persists the learner's own weekly standing (own-row RLS) and reads the
/// cross-user cohort via the server-side `read_league_cohort` SECURITY DEFINER,
/// so the leaderboard becomes the learner's REAL cohort (each member's real
/// weekly XP) and their PERSISTED tier. With no session (or the in-memory
/// default) the store's load/readCohort are no-ops, so flag-off behaviour is
/// byte-identical to the pre-go-live solo build.
const LeaguesEngine _engine = LeaguesEngine();

/// The honest SOLO baseline: just you, carrying your REAL weekly XP. Used until
/// (and unless) a signed-in cross-user cohort read replaces it.
final leagueCohortProvider = Provider<List<LeagueMember>>((ref) {
  final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
  return <LeagueMember>[
    LeagueMember(
      id: 'you',
      displayName: 'You',
      avatarEmoji: '🦡',
      weeklyXp: snap.xpWeekEarned,
      isYou: true,
    ),
  ];
});

/// The async overlay: the learner's persisted tier + their REAL cross-user cohort
/// when signed in. Null fields mean "not loaded" -> fall back to the solo baseline.
class LeagueSync {
  const LeagueSync({this.cohort, this.tier, this.loaded = false});

  /// The real cohort members from the cross-user read; null until a signed-in
  /// read completes (guest / in-memory default leave it null -> solo baseline).
  final List<LeagueMember>? cohort;

  /// The learner's persisted tier (set by the weekly close); null -> entry tier.
  final LeagueTier? tier;

  /// True once a signed-in sync has settled (diagnostic; the screen reads cohort).
  final bool loaded;
}

/// Persists the learner's own weekly standing and loads their REAL cohort via the
/// [LeaguesStore] seam. A guest (or the in-memory default) is a pure no-op overlay
/// (state stays the empty [LeagueSync]), so the solo baseline shows unchanged.
class LeaguesSyncController extends Notifier<LeagueSync> {
  bool _disposed = false;

  @override
  LeagueSync build() {
    ref.onDispose(() => _disposed = true);
    // Sync ONCE on build, mirroring FriendsController._rehydrate: read (never
    // watch) the learner snapshot so the in-flight async sync isn't torn down by
    // an unrelated learner-state rebuild. The solo baseline (leagueCohortProvider)
    // independently watches the learner, so the learner's OWN weekly XP still
    // shows live; the durable cross-user cohort refreshes on each leagues open.
    _sync();
    return const LeagueSync();
  }

  Future<void> _sync() async {
    final String? uid = ref.read(identityProvider).uid;
    if (uid == null) return; // guest -> honest solo baseline, nothing persisted

    final LeaguesStore store = ref.read(leaguesStoreProvider);
    final DateTime now = ref.read(clockProvider)();
    final String week = _weekKey(LeagueWeek.startOf(now));
    final LearnerSnapshot snap = ref.read(learnerControllerProvider);
    final String name =
        _displayName(ref.read(appSettingsControllerProvider).displayName);

    // Recover the persisted tier (set by the weekly close) for this week; a brand
    // -new member defaults to the entry tier.
    final Map<String, Object?> existing = await store.load(uid);
    if (_disposed) return;
    final LeagueTier tier = _tierFor(existing[kLeagueMembershipKey], week);

    // Persist OWN standing for this week (own-row RLS). weekly_xp is the learner's
    // REAL current weekly XP, client-asserted exactly like every other counter.
    await store.save(uid, <String, Object?>{
      kLeagueMembershipKey: <Map<String, Object?>>[
        <String, Object?>{
          'week_start': week,
          'tier': tier.name,
          'weekly_xp': snap.xpWeekEarned,
          'display_name': name,
          'avatar_emoji': '🦡',
        },
      ],
    });
    if (_disposed) return;

    // Cross-user leaderboard read (server-side SECURITY DEFINER). Empty -> no
    // cross-user backend (in-memory default) -> keep the honest solo baseline.
    final List<Map<String, Object?>> rows = await store.readCohort(uid);
    if (_disposed) return;
    if (rows.isEmpty) {
      state = LeagueSync(tier: tier, loaded: true);
      return;
    }
    state = LeagueSync(
      cohort: rows.map(_memberFrom).toList(growable: false),
      tier: tier,
      loaded: true,
    );
  }

  static String _displayName(String raw) {
    final String t = raw.trim();
    return t.isEmpty ? 'Badger' : t;
  }

  static String _weekKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static LeagueTier _tierByName(String? n) {
    for (final LeagueTier t in LeagueTier.values) {
      if (t.name == n) return t;
    }
    return LeagueTier.bronze; // forward-compat: unknown -> entry tier
  }

  static LeagueTier _tierFor(Object? membership, String week) {
    if (membership is List) {
      for (final Object? e in membership) {
        if (e is Map && e['week_start'] == week) {
          return _tierByName(e['tier'] as String?);
        }
      }
    }
    return LeagueTier.bronze;
  }

  static LeagueMember _memberFrom(Map<String, Object?> r) => LeagueMember(
        id: (r['member_id'] ?? '').toString(),
        displayName: (r['display_name'] as String?) ?? 'Learner',
        avatarEmoji: (r['avatar_emoji'] as String?) ?? '🦡',
        weeklyXp: (r['weekly_xp'] as num?)?.toInt() ?? 0,
        isYou: r['is_you'] == true,
      );
}

final leaguesSyncProvider = NotifierProvider<LeaguesSyncController, LeagueSync>(
    LeaguesSyncController.new);

/// The ranked standings: the REAL cross-user cohort when signed in, else the
/// honest solo baseline. A real engine ranking either way.
final leagueStandingsProvider = Provider<List<LeagueStanding>>((ref) {
  final LeagueSync sync = ref.watch(leaguesSyncProvider);
  final List<LeagueMember> cohort =
      sync.cohort ?? ref.watch(leagueCohortProvider);
  return _engine.rank(cohort);
});

/// Immutable view-model for the Leagues screen: the learner's tier, their own
/// standing, the whole cohort, the weekly rules and the days left this week.
class LeagueStatus {
  const LeagueStatus({
    required this.tier,
    required this.you,
    required this.standings,
    required this.rules,
    required this.daysRemaining,
  });

  final LeagueTier tier;
  final LeagueStanding you;
  final List<LeagueStanding> standings;
  final LeagueRules rules;
  final int daysRemaining;

  int get cohortSize => standings.length;
  bool get isSolo => cohortSize <= 1;

  /// Weekly XP still needed to overtake the rank above (0 when you are first).
  int get xpToRankAbove => _engine.xpToRankAbove(standings, you.rank);
}

final leagueStatusProvider = Provider<LeagueStatus>((ref) {
  final List<LeagueStanding> standings = ref.watch(leagueStandingsProvider);
  final LeagueSync sync = ref.watch(leaguesSyncProvider);
  final DateTime now = ref.watch(clockProvider)();
  final LeagueStanding you = standings.firstWhere(
    (LeagueStanding s) => s.member.isYou,
    orElse: () => standings.first,
  );
  return LeagueStatus(
    tier: sync.tier ?? LeagueTier.bronze,
    you: you,
    standings: standings,
    rules: _engine.rules,
    daysRemaining: LeagueWeek.daysRemaining(now),
  );
});
