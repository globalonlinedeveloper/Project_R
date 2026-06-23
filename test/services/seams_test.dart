import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

void main() {
  test('identity defaults to anonymous (no auth.uid yet)', () {
    const id = AnonymousIdentity();
    expect(id.uid, isNull);
    expect(id.isAuthenticated, isFalse);
  });

  test('analytics no-op sink accepts events without error', () {
    const a = NoopAnalytics();
    expect(() => a.logEvent('lesson_complete', props: {'xp': 10}),
        returnsNormally);
  });

  test('entitlements default to free tier', () {
    expect(const FreeTierEntitlements().isPro, isFalse);
  });

  test('in-memory learner store round-trips and isolates per user', () async {
    final store = InMemoryLearnerStateStore();
    await store.save('u1', {'streak': 3});
    expect(await store.load('u1'), {'streak': 3});
    expect(await store.load('u2'), isEmpty);
  });

  test('ai relay is unconfigured and fails closed before Stage 3', () async {
    const relay = UnconfiguredAiRelay();
    expect(relay.isAvailable, isFalse);
    expect(() => relay.complete('hi'), throwsStateError);
  });
}
