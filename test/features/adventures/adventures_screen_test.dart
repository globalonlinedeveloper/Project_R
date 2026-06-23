import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/adventures/adventures_screen.dart';
import 'package:ratel/features/adventures/scene_screen.dart';

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
  testWidgets('adventures map lists the placeholder districts (R-L4a)',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(theme: RatelTheme.light(), home: const AdventuresScreen()));
    await tester.pump();
    expect(find.byKey(const Key('adventures-screen')), findsOneWidget);
    expect(find.text('Café Corner'), findsOneWidget);
    expect(find.text('Market Street'), findsOneWidget);
  });

  testWidgets('a scene plays on rails to completion', (tester) async {
    var closed = false;
    await tester.pumpWidget(_scene('cafe_order', onClose: () => closed = true));
    await tester.pump();

    expect(find.text('Hi! What can I get you?'), findsOneWidget);

    // Step 1
    await tester.tap(find.text('A coffee, please.'));
    await tester.pump();
    expect(find.text('Coming right up!'), findsOneWidget); // NPC reply
    await tester.tap(find.text('Continue'));
    await tester.pump();

    // Step 2
    expect(find.text('Milk or sugar?'), findsOneWidget);
    await tester.tap(find.text('Just milk, thanks.'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();

    // Step 3
    expect(find.text('That will be three dollars.'), findsOneWidget);
    await tester.tap(find.text('Here you go.'));
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
