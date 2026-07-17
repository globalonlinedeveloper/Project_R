import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/content/models/enums.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/learning/learning.dart';

import 'auth/fake_identity.dart';

/// A [LearnerStateStore] test double: returns a seeded snapshot on [load] and
/// records every [save] so a test can assert the write-through payload.
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

List<Override> _wired(RecordingStore store, {Identity? identity}) => <Override>[
      if (identity != null) identityProvider.overrideWithValue(identity),
      learnerStateStoreProvider.overrideWithValue(store),
      persistDebounceProvider.overrideWithValue(Duration.zero),
    ];

void main() {
  group('LearnerController durable persistence', () {
    test('rehydrates xp / lessons / streak / θ from the user_course row',
        () async {
      final RecordingStore store = RecordingStore(<String, Object?>{
        'courses': <Object?>[
          <String, Object?>{
            'target_locale': 'en',
            'xp_total': 140,
            'lessons_completed': 7,
            'streak_days': 3,
            'theta_per_skill': <String, Object?>{'__global__': 1.25, 's1': 0.5},
          },
        ],
        'items': <Object?>[],
      });
      final ProviderContainer c =
          ProviderContainer(overrides: _wired(store, identity: FakeIdentity()));
      addTearDown(c.dispose);

      // First synchronous read is the honest cold-start (A1 / zero).
      expect(c.read(learnerControllerProvider).xpTotal, 0);
      await _settle();

      final LearnerSnapshot snap = c.read(learnerControllerProvider);
      expect(snap.xpTotal, 140);
      expect(snap.lessonsCompleted, 7);
      expect(snap.streakDays, 3);
      expect(snap.theta, closeTo(1.25, 1e-6));
    });

    test('writes through a mutation to the store (debounced)', () async {
      final RecordingStore store = RecordingStore();
      final ProviderContainer c =
          ProviderContainer(overrides: _wired(store, identity: FakeIdentity()));
      addTearDown(c.dispose);

      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await _settle();

      expect(store.lastUserId, 'uid-test');
      expect(store.saves, isNotEmpty);
      // INC-15: a mutation upserts BOTH rows — the current course's per-course
      // row (xp/lessons/θ) AND the canonical __global__ row (streak/diamonds).
      final List<Object?> courses =
          store.saves.last['courses']! as List<Object?>;
      final Map<Object?, Object?> courseRow = courses.firstWhere((Object? r) =>
          (r as Map)['target_locale'] == 'en') as Map<Object?, Object?>;
      // Per-course fields live on the course row; global fields do NOT.
      expect(courseRow['xp_total'], 20);
      expect(courseRow['lessons_completed'], 1);
      expect(courseRow.containsKey('streak_days'), isFalse);
      final Map<Object?, Object?> theta =
          courseRow['theta_per_skill']! as Map<Object?, Object?>;
      expect(theta.containsKey('__global__'), isTrue);
      // The __global__ row carries the account-level fields (streak/diamonds),
      // not xp/lessons.
      final Map<Object?, Object?> globalRow = courses.firstWhere((Object? r) =>
          (r as Map)['target_locale'] == '__global__') as Map<Object?, Object?>;
      expect(globalRow.containsKey('streak_days'), isTrue);
      expect(globalRow.containsKey('diamonds'), isTrue);
      expect(globalRow.containsKey('xp_total'), isFalse);
    });

    test('guest (uid == null) never persists, in-memory behaviour identical',
        () async {
      final RecordingStore store = RecordingStore();
      // No identity override → default AnonymousIdentity (uid == null).
      final ProviderContainer c = ProviderContainer(overrides: _wired(store));
      addTearDown(c.dispose);

      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await _settle();

      expect(store.saves, isEmpty); // fail-closed: no write for a guest
      expect(c.read(learnerControllerProvider).xpTotal, 20); // in-memory intact
      expect(c.read(learnerControllerProvider).level, CefrLevel.a1);
    });
  });

  group('SavedWordsController durable persistence', () {
    test('rehydrates FSRS cards from user_item_state, ignoring lesson rows',
        () async {
      final RecordingStore store = RecordingStore(<String, Object?>{
        'courses': <Object?>[],
        'items': <Object?>[
          <String, Object?>{
            'item_id': 'sw:en:hola',
            'state': 'review',
            'stability': 10.0,
            'difficulty': 5.0,
            'reps': 3,
            'lapses': 1,
            'due': '2026-07-01T00:00:00Z',
            'last_review': '2026-06-20T00:00:00Z',
          },
          <String, Object?>{'item_id': 'it_lesson_1', 'state': 'new'},
        ],
      });
      final ProviderContainer c =
          ProviderContainer(overrides: _wired(store, identity: FakeIdentity()));
      addTearDown(c.dispose);

      expect(c.read(savedWordsControllerProvider).count, 0);
      await _settle();

      final SavedWordsState s = c.read(savedWordsControllerProvider);
      expect(s.count, 1); // the lesson item row is ignored
      final SavedWordCard card = s.cards.single;
      expect(card.key.normalizedLemma, 'hola');
      expect(card.fsrs.state, FsrsState.review);
      expect(card.fsrs.reps, 3);
      expect(card.fsrs.stability, 10.0);
    });

    test('writes a saved word through as a namespaced user_item_state row',
        () async {
      final RecordingStore store = RecordingStore();
      final ProviderContainer c =
          ProviderContainer(overrides: _wired(store, identity: FakeIdentity()));
      addTearDown(c.dispose);

      final SavedWordDisposition d =
          c.read(savedWordsControllerProvider.notifier).save('Hola');
      expect(d, SavedWordDisposition.admitted);
      await _settle();

      expect(store.saves, isNotEmpty);
      final List<Object?> items = store.saves.last['items']! as List<Object?>;
      final Map<Object?, Object?> row = items.single as Map<Object?, Object?>;
      expect(row['item_id'], 'sw:en:hola');
      expect(row['state'], 'new');
      expect(row['reps'], 0);
    });

    test('guest (uid == null) never persists saved words', () async {
      final RecordingStore store = RecordingStore();
      final ProviderContainer c = ProviderContainer(overrides: _wired(store));
      addTearDown(c.dispose);

      c.read(savedWordsControllerProvider.notifier).save('Hola');
      await _settle();

      expect(store.saves, isEmpty);
      expect(c.read(savedWordsControllerProvider).count, 1); // in-memory intact
    });
  });
}
