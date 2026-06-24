import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/adventures/scene_screen.dart';

// Additive scene coverage (R-L4a). adventures_screen_test already plays the
// 'cafe_order' happy path; this hits the branches it does not: scene-not-found,
// best vs non-best feedback, the mid-scene close (X), and a full playthrough of
// the *second* scene ('market_fruit').
Widget _scene(String id, {VoidCallback? onClose}) {
  return ProviderScope(
    child: MaterialApp(
      theme: RatelTheme.light(),
      home: Builder(
        builder: (c) => MediaQuery(
          data: MediaQuery.of(c).copyWith(disableAnimations: true),
          child: SceneScreen(sceneId: id, onClose: onClose),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('an unknown scene id shows a graceful not-found message',
      (tester) async {
    await tester.pumpWidget(_scene('no_such_scene'));
    await tester.pump();
    expect(find.text('Scene not found'), findsOneWidget);
  });

  testWidgets('the best choice shows the affirming feedback (R-L4a)',
      (tester) async {
    await tester.pumpWidget(_scene('market_fruit'));
    await tester.pump();
    expect(find.text('Fresh apples today!'), findsOneWidget);

    await tester.tap(find.text('How much are they?')); // bestIndex 0
    await tester.pump();
    expect(find.text('Great — that fits the moment.'), findsOneWidget);
    expect(find.text('One dollar each.'), findsOneWidget); // NPC reply
  });

  testWidgets('a non-best choice still advances with a gentle reply',
      (tester) async {
    await tester.pumpWidget(_scene('market_fruit'));
    await tester.pump();

    await tester.tap(find.text('I am a tree.')); // non-best choice
    await tester.pump();
    expect(find.text('That works — here is a natural reply.'), findsOneWidget);
  });

  testWidgets('the close (X) button invokes onClose mid-scene', (tester) async {
    var closed = false;
    await tester.pumpWidget(_scene('market_fruit', onClose: () => closed = true));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(closed, isTrue);
  });

  testWidgets('playing market_fruit to the end reaches completion + Done',
      (tester) async {
    var closed = false;
    await tester.pumpWidget(_scene('market_fruit', onClose: () => closed = true));
    await tester.pump();

    // Step 1
    await tester.tap(find.text('How much are they?'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();

    // Step 2
    expect(find.text('How many would you like?'), findsOneWidget);
    await tester.tap(find.text('Three, please.'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();

    // Complete
    expect(find.text('Scene complete!'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pump();
    expect(closed, isTrue);
  });
}
