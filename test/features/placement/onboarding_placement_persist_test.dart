import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/models/enums.dart';
import 'package:ratel/features/onboarding/onboarding_flow.dart';
import 'package:ratel/features/placement/placement_controller.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/identity/supabase_identity.dart';

/// Onboarding placement wiring (#9): the extracted [persistOnboardingPlacement]
/// is the seam the onboarding flow calls on completion. Tested directly so the
/// wiring is verified without driving the asset-backed first-win UI.
void main() {
  test('persists a courses payload (target_locale + per-skill θ) for an authed uid',
      () async {
    final store = InMemoryLearnerStateStore();
    final placement = PlacementController.forBand(CefrLevel.a1)
      ..answer(skill: 'vocab', itemDifficulty: 0.0, correct: true);

    await persistOnboardingPlacement(
      SupabaseIdentity(currentUserId: () => 'uid-1'),
      store,
      placement,
      'en',
    );

    final loaded = await store.load('uid-1');
    final courses = loaded['courses']! as List<Object?>;
    expect(courses.length, 1);
    final row = courses.first! as Map<String, Object?>;
    expect(row['target_locale'], 'en');
    expect(
      (row['theta_per_skill']! as Map<String, Object?>).containsKey('vocab'),
      isTrue,
    );
  });

  test('is a no-op for a guest (uid null) — placement stays local', () async {
    final store = InMemoryLearnerStateStore();
    final placement = PlacementController.forBand(CefrLevel.a1);

    await persistOnboardingPlacement(
      const AnonymousIdentity(),
      store,
      placement,
      'en',
    );

    expect(await store.load('uid-1'), isEmpty);
  });
}
