import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/identity/identity.dart';

import 'auth/fake_identity.dart';

/// INC-15 — per-course learner state.
///
/// PER-COURSE fields (xp / lessons / θ) are keyed on [currentCourseCodeProvider]
/// (the live course code the app is mounted on) → each course hydrates and
/// persists its OWN `user_course` row. GLOBAL fields (streak / diamonds /
/// freezes) live in ONE canonical `target_locale='__global__'` row, shared
/// across courses, with a first-run FALLBACK that reads them off the legacy
/// `'en'` row so existing users never lose them. Guest / flag-off stays
/// byte-identical (no uid → no load / no save → in-memory defaults).
class RecordingStore implements LearnerStateStore {
  RecordingStore([this.seed = const <String, Object?>{}]);

  final Map<String, Object?> seed;
  final List<Map<String, Object?>> saves = <Map<String, Object?>>[];
  String? lastUserId;

  @override
  Future<Map<String, Object?>> load(String userId) async => seed;

  @override
  Future<void> save(String userId, Map<String, Object?> state) async {
    lastUserId = userId;
    saves.add(state);
  }
}

/// Let the fire-and-forget hydrate / debounced drain (debounce = zero) settle.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

/// A fixed "today" so the streak math is deterministic (no dependence on the
/// host clock). Seeds use [_lastActive] as `streak_last_active` → gap 0 → the
/// run reads as alive and the seeded streak is displayed verbatim.
final DateTime _fixedToday = DateTime(2026, 7, 17);
const String _lastActive = '2026-07-17';

/// Wire the learner onto [store] for a signed-in user, mounted on [course]
/// (defaults to `'en'` — the pre-INC-15 spine). The clock is pinned so streak
/// display is deterministic.
List<Override> _wired(
  RecordingStore store, {
  String? course,
  Identity? identity,
}) =>
    <Override>[
      if (identity != null) identityProvider.overrideWithValue(identity),
      if (course != null)
        currentCourseCodeProvider.overrideWithValue(course),
      learnerStateStoreProvider.overrideWithValue(store),
      persistDebounceProvider.overrideWithValue(Duration.zero),
      clockProvider.overrideWithValue(() => _fixedToday),
    ];

/// A two-course seed: Spanish xp=100, German xp=40, plus a `__global__` row
/// carrying the shared streak/diamonds. Used to prove per-course isolation and
/// global continuity.
Map<String, Object?> _twoCourseSeed() => <String, Object?>{
      'courses': <Object?>[
        <String, Object?>{
          'target_locale': 'es',
          'xp_total': 100,
          'lessons_completed': 5,
          'theta_per_skill': <String, Object?>{'__global__': 0.75},
        },
        <String, Object?>{
          'target_locale': 'de',
          'xp_total': 40,
          'lessons_completed': 2,
          'theta_per_skill': <String, Object?>{'__global__': -0.5},
        },
        <String, Object?>{
          'target_locale': '__global__',
          'streak_days': 9,
          'streak_last_active': _lastActive, // gap 0 → run alive
          'diamonds': 33,
          'streak_freezes': 1,
        },
      ],
      'items': <Object?>[],
    };

void main() {
  group('INC-15 per-course learner state', () {
    test('per-course isolation: the current course hydrates its OWN xp', () async {
      // Same store, two containers mounted on different courses.
      final RecordingStore esStore = RecordingStore(_twoCourseSeed());
      final ProviderContainer es = ProviderContainer(
          overrides: _wired(esStore, course: 'es', identity: FakeIdentity()));
      addTearDown(es.dispose);

      final RecordingStore deStore = RecordingStore(_twoCourseSeed());
      final ProviderContainer de = ProviderContainer(
          overrides: _wired(deStore, course: 'de', identity: FakeIdentity()));
      addTearDown(de.dispose);

      // First synchronous read is the honest cold-start (zero) for both.
      expect(es.read(learnerControllerProvider).xpTotal, 0);
      expect(de.read(learnerControllerProvider).xpTotal, 0);
      await _settle();

      // Distinct per-course XP + lessons, from each course's own row.
      expect(es.read(learnerControllerProvider).xpTotal, 100);
      expect(es.read(learnerControllerProvider).lessonsCompleted, 5);
      expect(de.read(learnerControllerProvider).xpTotal, 40);
      expect(de.read(learnerControllerProvider).lessonsCompleted, 2);
    });

    test('global streak continuity: the __global__ streak is the same '
        'regardless of the current course', () async {
      final RecordingStore esStore = RecordingStore(_twoCourseSeed());
      final ProviderContainer es = ProviderContainer(
          overrides: _wired(esStore, course: 'es', identity: FakeIdentity()));
      addTearDown(es.dispose);

      final RecordingStore deStore = RecordingStore(_twoCourseSeed());
      final ProviderContainer de = ProviderContainer(
          overrides: _wired(deStore, course: 'de', identity: FakeIdentity()));
      addTearDown(de.dispose);

      // Force each provider to build (which kicks off the async hydrate)
      // BEFORE settling — the NotifierProvider is lazy.
      es.read(learnerControllerProvider);
      de.read(learnerControllerProvider);
      await _settle();

      // Streak + diamonds come from the shared __global__ row — identical
      // across a course switch (es vs de).
      expect(es.read(learnerControllerProvider).streakDays, 9);
      expect(de.read(learnerControllerProvider).streakDays, 9);
      expect(es.read(learnerControllerProvider).diamonds, 33);
      expect(de.read(learnerControllerProvider).diamonds, 33);
      expect(es.read(learnerControllerProvider).streakFreezes, 1);
      expect(de.read(learnerControllerProvider).streakFreezes, 1);
    });

    test('migration fallback: with NO __global__ row, global fields come off '
        'the legacy en row and persist writes a __global__ row', () async {
      // A pre-INC-15 user: a single legacy 'en' row carrying EVERYTHING, no
      // __global__ row yet.
      final RecordingStore store = RecordingStore(<String, Object?>{
        'courses': <Object?>[
          <String, Object?>{
            'target_locale': 'en',
            'xp_total': 200,
            'lessons_completed': 10,
            'streak_days': 12,
            'streak_last_active': _lastActive, // gap 0 → run alive
            'diamonds': 77,
            'streak_freezes': 2,
            'theta_per_skill': <String, Object?>{'__global__': 1.1},
          },
        ],
        'items': <Object?>[],
      });
      // Mounted on the legacy course 'en' (the default spine).
      final ProviderContainer c = ProviderContainer(
          overrides: _wired(store, course: 'en', identity: FakeIdentity()));
      addTearDown(c.dispose);

      c.read(learnerControllerProvider); // build → kick off hydrate
      await _settle();

      // No loss: streak/diamonds/freezes migrated off the legacy 'en' row,
      // per-course xp/lessons/θ also come from that same 'en' row.
      final LearnerSnapshot snap = c.read(learnerControllerProvider);
      expect(snap.streakDays, 12);
      expect(snap.diamonds, 77);
      expect(snap.streakFreezes, 2);
      expect(snap.xpTotal, 200);
      expect(snap.lessonsCompleted, 10);
      expect(snap.theta, closeTo(1.1, 1e-6));

      // Force a persist (any mutation) and assert the __global__ row is
      // written FORWARD off the legacy 'en' row — the app-side migration.
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await _settle();
      expect(store.saves, isNotEmpty);
      final List<Object?> courses =
          store.saves.last['courses']! as List<Object?>;
      final Iterable<Object?> globals = courses.where(
          (Object? r) => (r as Map)['target_locale'] == '__global__');
      expect(globals, isNotEmpty, reason: 'persist must write a __global__ row');
      final Map<Object?, Object?> g = globals.first as Map<Object?, Object?>;
      expect(g.containsKey('streak_days'), isTrue);
      expect(g.containsKey('diamonds'), isTrue);
    });

    test('persist writes BOTH rows: current-course (per-course fields) AND '
        '__global__ (global fields)', () async {
      final RecordingStore store = RecordingStore();
      final ProviderContainer c = ProviderContainer(
          overrides: _wired(store, course: 'es', identity: FakeIdentity()));
      addTearDown(c.dispose);

      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await _settle();

      expect(store.saves, isNotEmpty);
      final List<Object?> courses =
          store.saves.last['courses']! as List<Object?>;
      final List<Object?> locales = courses
          .map((Object? r) => (r as Map)['target_locale'])
          .toList();
      // The current course's row (es) carries per-course fields, no streak.
      expect(locales, contains('es'));
      final Map<Object?, Object?> courseRow = courses.firstWhere((Object? r) =>
          (r as Map)['target_locale'] == 'es') as Map<Object?, Object?>;
      expect(courseRow['xp_total'], 20);
      expect(courseRow['lessons_completed'], 1);
      expect(courseRow.containsKey('streak_days'), isFalse);
      expect(courseRow.containsKey('diamonds'), isFalse);
      // The __global__ row carries global fields, no xp/lessons.
      expect(locales, contains('__global__'));
      final Map<Object?, Object?> globalRow = courses.firstWhere((Object? r) =>
          (r as Map)['target_locale'] == '__global__') as Map<Object?, Object?>;
      expect(globalRow.containsKey('streak_days'), isTrue);
      expect(globalRow.containsKey('diamonds'), isTrue);
      // INC-STK-LONGEST: the monotonic longest streak rides the same
      // __global__ row (so the live upsert's column set includes it).
      expect(globalRow.containsKey('longest_streak'), isTrue);
      expect(globalRow['longest_streak'], 1);
      expect(globalRow.containsKey('xp_total'), isFalse);
      // A non-'en' current course does NOT touch the legacy 'en' row (honest
      // transition: pre-existing XP stays where it was, never fabricated here).
      expect(locales, isNot(contains('en')));
    });

    test('honesty: a fresh non-en course starts at zero xp, never inheriting '
        "another course's history", () async {
      // Seed has ES xp=100 + a __global__ row, but the learner is mounted on a
      // brand-new course 'fr' with no row of its own.
      final RecordingStore store = RecordingStore(_twoCourseSeed());
      final ProviderContainer c = ProviderContainer(
          overrides: _wired(store, course: 'fr', identity: FakeIdentity()));
      addTearDown(c.dispose);

      c.read(learnerControllerProvider); // build → kick off hydrate
      await _settle();

      final LearnerSnapshot snap = c.read(learnerControllerProvider);
      // No 'fr' row → per-course fields honestly cold-start at zero…
      expect(snap.xpTotal, 0);
      expect(snap.lessonsCompleted, 0);
      // …but the GLOBAL streak/diamonds are still shared from __global__.
      expect(snap.streakDays, 9);
      expect(snap.diamonds, 33);
    });

    test('guest (uid == null) — no load / no save, byte-identical to the '
        'pre-INC-15 single-course build', () async {
      // The guest path must be UNCHANGED by INC-15: with no uid there is no
      // load (the seed is ignored) and no save, and mounting on a non-en
      // course must not alter the in-memory result one bit. Prove it by
      // comparing the mounted-on-'es' guest to a reference guest on the DEFAULT
      // course (no currentCourseCodeProvider override) — same identical inputs.
      final RecordingStore store = RecordingStore(_twoCourseSeed());
      final ProviderContainer c =
          ProviderContainer(overrides: _wired(store, course: 'es'));
      addTearDown(c.dispose);

      final RecordingStore refStore = RecordingStore(_twoCourseSeed());
      final ProviderContainer ref = ProviderContainer(
          overrides: _wired(refStore)); // default course ('en'), no override
      addTearDown(ref.dispose);

      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      ref.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await _settle();

      // Fail-closed: no write for a guest, on EITHER container.
      expect(store.saves, isEmpty);
      expect(refStore.saves, isEmpty);

      // The seed is never applied (no uid → no hydrate): XP is the in-memory
      // 20, NOT the seed's 100, and the snapshot is byte-identical to the
      // default-course reference — INC-15's course code is inert for a guest.
      final LearnerSnapshot snap = c.read(learnerControllerProvider);
      expect(snap.xpTotal, 20);
      expect(snap, equals(ref.read(learnerControllerProvider)));
    });
  });
}
