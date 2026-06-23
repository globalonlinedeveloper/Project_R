import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/features/adventures/adventure_model.dart';
import 'package:ratel/features/adventures/scene_player.dart';

void main() {
  group('ScenePlayer (R-L4a scripted rails)', () {
    test('empty scene is immediately complete', () {
      final p = ScenePlayer(const Scene(id: 'x', title: 'x', steps: []));
      expect(p.state.isComplete, isTrue);
      expect(p.state.progress, 1.0);
    });

    test('choose -> replying (with reply), advance -> next step', () {
      final scene = findScene('cafe_order')!;
      final p = ScenePlayer(scene);
      expect(p.state.phase, ScenePhase.choosing);
      expect(p.currentStep.line, 'Hi! What can I get you?');

      p.choose(0); // the best choice
      expect(p.state.phase, ScenePhase.replying);
      expect(p.state.lastWasBest, isTrue);
      expect(p.currentStep.reply, 'Coming right up!');

      p.advance();
      expect(p.state.phase, ScenePhase.choosing);
      expect(p.state.stepIndex, 1);
    });

    test('a non-best choice still advances (on rails), flagged not-best', () {
      final p = ScenePlayer(findScene('cafe_order')!);
      p.choose(1); // not the best
      expect(p.state.lastWasBest, isFalse);
      p.advance();
      expect(p.state.stepIndex, 1); // still advanced
    });

    test('walking every step completes the scene', () {
      final scene = findScene('cafe_order')!;
      final p = ScenePlayer(scene);
      for (var i = 0; i < scene.steps.length; i++) {
        p.choose(0);
        p.advance();
      }
      expect(p.state.isComplete, isTrue);
      expect(p.state.progress, 1.0);
    });

    test('out-of-phase calls are no-ops', () {
      final p = ScenePlayer(findScene('market_fruit')!);
      p.advance(); // no-op while choosing
      expect(p.state.stepIndex, 0);
      p.choose(0);
      p.choose(0); // second choose ignored while replying
      expect(p.state.phase, ScenePhase.replying);
    });

    test('catalog has two placeholder districts with scenes', () {
      expect(adventuresCatalog.length, 2);
      expect(adventuresCatalog.every((a) => a.scenes.isNotEmpty), isTrue);
    });
  });
}
