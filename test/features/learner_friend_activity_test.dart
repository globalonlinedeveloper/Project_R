// R-I9 / R-L8 / R-L11 — the LearnerController PRODUCES friend-activity on REAL
// milestones: a CEFR level rise (recordReview) → `leveledUp`; a streak milestone
// (recordLessonComplete) → `streak`. Emitted only on a real session; a guest
// produces nothing (honest, byte-identical flag-off).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/content/models/enums.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/learning/learning.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';
import 'package:ratel/services/social/friends_service.dart';

import 'auth/fake_identity.dart';

class _RecordingFriendsService implements FriendsService {
  final List<(String, String)> emitted = <(String, String)>[];
  final List<int> published = <int>[];
  @override
  Future<FriendDeliveryResult> emitActivity(String activityType,
      {String summary = '', List<String>? targets}) async {
    emitted.add((activityType, summary));
    return const FriendDeliveryResult(FriendDeliveryOutcome.delivered);
  }

  @override
  Future<FriendDeliveryResult> publishWeeklyXp(int weeklyXp) async {
    published.add(weeklyXp);
    return const FriendDeliveryResult(FriendDeliveryOutcome.delivered);
  }

  @override
  Future<FriendDeliveryResult> sendRequest(String t) async =>
      const FriendDeliveryResult(FriendDeliveryOutcome.unavailable);
  @override
  Future<FriendDeliveryResult> respond(String h, {required bool accept}) async =>
      const FriendDeliveryResult(FriendDeliveryOutcome.unavailable);
  @override
  Future<FriendDeliveryResult> setHandle(String h) async =>
      const FriendDeliveryResult(FriendDeliveryOutcome.unavailable);
  @override
  Future<FriendDeliveryResult> removeFriend(String o, {required bool block}) async =>
      const FriendDeliveryResult(FriendDeliveryOutcome.unavailable);
}

class _NoopStore implements LearnerStateStore {
  @override
  Future<Map<String, Object?>> load(String userId) async =>
      const <String, Object?>{};
  @override
  Future<void> save(String userId, Map<String, Object?> state) async {}
}

ProviderContainer _container(
  DateTime Function() clock,
  _RecordingFriendsService svc, {
  int goal = 20,
  Identity? identity,
}) =>
    ProviderContainer(overrides: <Override>[
      clockProvider.overrideWithValue(clock),
      settingsStoreProvider.overrideWithValue(
          InMemorySettingsStore(AppSettings(dailyGoal: goal))),
      friendsServiceProvider.overrideWithValue(svc),
      learnerStateStoreProvider.overrideWithValue(_NoopStore()),
      if (identity != null) identityProvider.overrideWithValue(identity),
      persistDebounceProvider.overrideWithValue(Duration.zero),
    ]);

ReviewLogEntry _correct(int n) => ReviewLogEntry(
      itemId: 'i$n',
      skill: 's1',
      grade: FsrsRating.easy,
      correct: true,
      elapsedMs: 0,
      thetaBefore: 0,
      irtBAtReview: 3.0, // a hard item answered correctly ⇒ strong upward θ
      source: 'lesson',
    );

void main() {
  test('a level rise (recordReview) emits a leveledUp activity (signed in)',
      () async {
    final svc = _RecordingFriendsService();
    final c =
        _container(() => DateTime(2026, 6, 29, 9), svc, identity: FakeIdentity());
    addTearDown(c.dispose);
    final n = c.read(learnerControllerProvider.notifier);
    expect(c.read(learnerControllerProvider).level, CefrLevel.a1);

    bool crossed = false;
    for (int i = 0; i < 400; i++) {
      n.recordReview(_correct(i));
      if (c.read(learnerControllerProvider).level != CefrLevel.a1) {
        crossed = true;
        break;
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(crossed, isTrue,
        reason: 'sustained correct answers should raise the CEFR level');
    expect(svc.emitted.where((e) => e.$1 == 'leveledUp'), isNotEmpty);
  });

  test('a streak milestone (recordLessonComplete) emits a streak activity',
      () async {
    final svc = _RecordingFriendsService();
    DateTime clock = DateTime(2026, 6, 29, 9);
    final c = _container(() => clock, svc, identity: FakeIdentity());
    addTearDown(c.dispose);
    final n = c.read(learnerControllerProvider.notifier);
    n.recordLessonComplete(xp: 20); // day 1 → streak 1 (not a milestone)
    clock = DateTime(2026, 6, 30, 9);
    n.recordLessonComplete(xp: 20); // day 2 → 2
    clock = DateTime(2026, 7, 1, 9);
    n.recordLessonComplete(xp: 20); // day 3 → 3 (milestone)
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(c.read(learnerControllerProvider).streakDays, 3);
    expect(svc.emitted, contains(('streak', '3-day streak')));
    expect(svc.emitted.where((e) => e.$1 == 'streak').length, 1);
  });

  test('a completed lesson publishes REAL weekly XP (signed in)', () async {
    final svc = _RecordingFriendsService();
    final c =
        _container(() => DateTime(2026, 6, 29, 9), svc, identity: FakeIdentity());
    addTearDown(c.dispose);
    final n = c.read(learnerControllerProvider.notifier);
    n.recordLessonComplete(xp: 20);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(svc.published, isNotEmpty);
    expect(svc.published.last,
        c.read(learnerControllerProvider).xpWeekEarned);
    expect(svc.published.last, greaterThan(0));
  });

  test('a GUEST produces no friend activity (honest, byte-identical flag-off)',
      () async {
    final svc = _RecordingFriendsService();
    DateTime clock = DateTime(2026, 6, 29, 9);
    final c = _container(() => clock, svc); // no identity ⇒ guest
    addTearDown(c.dispose);
    final n = c.read(learnerControllerProvider.notifier);
    for (int i = 0; i < 80; i++) {
      n.recordReview(_correct(i));
    }
    n.recordLessonComplete(xp: 20);
    clock = DateTime(2026, 6, 30, 9);
    n.recordLessonComplete(xp: 20);
    clock = DateTime(2026, 7, 1, 9);
    n.recordLessonComplete(xp: 20);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(svc.emitted, isEmpty);
    expect(svc.published, isEmpty);
  });
}
