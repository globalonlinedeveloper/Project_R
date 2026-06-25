import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/models/enums.dart';
import 'package:ratel/features/placement/placement_controller.dart';
import 'package:ratel/services/data_access/data_access.dart';

void main() {
  StateNotifierProvider<PlacementController, PlacementState> fresh(
          {CefrLevel? band}) =>
      StateNotifierProvider<PlacementController, PlacementState>((ref) =>
          band == null
              ? PlacementController()
              : PlacementController.forBand(band));

  test('starts with no graded items and empty per-skill θ', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final p = fresh();
    expect(c.read(p).answered, 0);
    expect(c.read(p).thetaPerSkill, isEmpty);
  });

  test('a correct answer raises a skill θ above a wrong one', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final right = fresh();
    final wrong = fresh();
    c.read(right.notifier).answer(skill: 'g', itemDifficulty: 0.0, correct: true);
    c.read(wrong.notifier).answer(skill: 'g', itemDifficulty: 0.0, correct: false);
    expect(c.read(right).answered, 1);
    expect(
      c.read(right).thetaPerSkill['g']! > c.read(wrong).thetaPerSkill['g']!,
      isTrue,
    );
  });

  test('courseRow carries the per-skill θ in the store shape', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final p = fresh();
    c.read(p.notifier).answer(skill: 'vocab', itemDifficulty: 0.0, correct: true);
    final row = c.read(p.notifier).courseRow('es');
    expect(row['target_locale'], 'es');
    expect(
      (row['theta_per_skill']! as Map<String, Object?>).containsKey('vocab'),
      isTrue,
    );
  });

  test('persistPlacement saves a courses payload through the store seam', () async {
    final store = InMemoryLearnerStateStore();
    await persistPlacement(store, 'u1', <String, Object?>{
      'target_locale': 'es',
      'theta_per_skill': <String, Object?>{'vocab': 0.3},
    });
    final loaded = await store.load('u1');
    expect(loaded['courses'], isA<List<Object?>>());
    expect((loaded['courses']! as List<Object?>).length, 1);
  });
}
