import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/content/models/models.dart' show ExerciseType;
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/adventures/adventures_screen.dart';
import 'package:ratel/features/adventures/scene_screen.dart';
import 'package:ratel/features/home/home_screen.dart';
import 'package:ratel/features/lesson/engine/exercise.dart';
import 'package:ratel/features/lesson/lesson_controller.dart';
import 'package:ratel/features/lesson/lesson_screen.dart';
import 'package:ratel/features/mascot/mascot_view.dart';

/// R-O1 exit gate, checks 4–6 (R-N1/R-N8): every core screen lays out on a
/// cheap-phone width without overflow, and the heaviest animations run + dispose
/// cleanly. (A full on-device frame-timing bench needs a profile build on an
/// emulator — tracked as the remaining CI-infra item in docs/STAGE2_EXIT.md.)
const _cheapPhone = Size(360, 690);

Widget _surface(Widget home, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: RatelTheme.light(),
        home: Builder(
          builder: (c) => MediaQuery(
            data: MediaQuery.of(c).copyWith(disableAnimations: true),
            child: home,
          ),
        ),
      ),
    );

void _cheap(WidgetTester t) {
  t.view.physicalSize = _cheapPhone;
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
}

final _ex = [
  Exercise(
    itemId: 'a',
    type: ExerciseType.mcq,
    prompt: 'I ___ bread.',
    options: const ['eat', 'run', 'book'],
    accepted: const ['eat'],
    whyCard: 'why',
  ),
];

void main() {
  group('R-O1 check 4/5 — core screens at 360px lay out without overflow', () {
    testWidgets('home (streak + energy + mascot path)', (t) async {
      _cheap(t);
      await t.pumpWidget(_surface(const HomeScreen()));
      await t.pump();
      expect(find.byKey(const Key('home-screen')), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('adventures map', (t) async {
      _cheap(t);
      await t.pumpWidget(_surface(const AdventuresScreen()));
      await t.pump();
      expect(find.byKey(const Key('adventures-screen')), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('lesson runner', (t) async {
      _cheap(t);
      await t.pumpWidget(_surface(
        LessonScreen(onClose: () {}),
        overrides: [lessonExercisesProvider.overrideWith((r) => _ex)],
      ));
      await t.pump();
      expect(find.text('Check'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('scene player', (t) async {
      _cheap(t);
      await t.pumpWidget(_surface(SceneScreen(sceneId: 'cafe_order', onClose: () {})));
      await t.pump();
      expect(t.takeException(), isNull);
    });
  });

  testWidgets(
      'R-O1 check 6 — animation stress: mascot loop + levelUp celebration, full motion, clean dispose (R-N8)',
      (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: MascotView(size: 120, mood: MascotMood.cheer)),
            Positioned.fill(
              child: IgnorePointer(
                child: RatelCelebration(level: CelebrationLevel.levelUp),
              ),
            ),
          ],
        ),
      ),
    ));
    await t.pump();
    for (var i = 0; i < 12; i++) {
      await t.pump(const Duration(milliseconds: 16)); // ~12 frames of motion
    }
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox()); // unmount -> controllers disposed
    expect(t.takeException(), isNull);
  });
}
