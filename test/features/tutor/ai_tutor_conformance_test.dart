import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/tutor/ai_tutor_screen.dart';

/// UXA S115 inc2 — AI Tutor design-spec §4.8 conformance:
///  F-1 Talk stays dark; Chat & Roleplay are white cards (ink text).
///  F-2 Roleplay subtitle shows the REAL authored scene count (honest fallback).
///  F-3 mascot carries its subtitle.
///  F-6 status card keys off the live-voice gate the cards actually use.
/// Plus a layout gauntlet at 460 & 800 px (session-craft §11).

CourseSpine _spineWithRoleplays(int n) => CourseSpine(
      courseCode: 'en',
      units: const <CourseUnit>[],
      roleplays: <CourseScenario>[
        for (int i = 0; i < n; i++)
          CourseScenario(
            id: 'r$i',
            kind: 'roleplay',
            title: 'Scene $i',
            cefr: 'A1',
            scenes: const <CourseScene>[
              CourseScene(sceneId: 's0', speaker: 'ratel', line: 'Hola'),
            ],
          ),
      ],
    );

Future<void> _pump(WidgetTester tester, double width,
    {List<Override> overrides = const <Override>[]}) async {
  tester.view.physicalSize = Size(width, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: AiTutorScreen())));
  await tester.pump();
}

void main() {
  group('AI Tutor §4.8 conformance', () {
    testWidgets('F-3: mascot carries its subtitle', (WidgetTester tester) async {
      await _pump(tester, 460);
      expect(find.text('Practice a real conversation'), findsOneWidget);
      expect(find.textContaining('no wrong answers'), findsOneWidget);
    });

    testWidgets(
        'F-1: Talk is dark (onColor text); Chat & Roleplay are white (ink text)',
        (WidgetTester tester) async {
      await _pump(tester, 460);
      final Text talk = tester.widget<Text>(find.text('Talk to Ratel'));
      final Text chat = tester.widget<Text>(find.text('Chat with Ratel'));
      final Text roleplay = tester.widget<Text>(find.text('Roleplay scenes'));
      expect(talk.style?.color, RatelColors.onColor,
          reason: 'Talk stays the dark-teal feature card');
      expect(chat.style?.color, isNot(RatelColors.onColor),
          reason: 'Chat is a white card with ink text');
      expect(roleplay.style?.color, isNot(RatelColors.onColor),
          reason: 'Roleplay is a white card with ink text');
    });

    testWidgets('F-2: Roleplay shows the REAL authored scene count',
        (WidgetTester tester) async {
      await _pump(tester, 460, overrides: <Override>[
        courseSpineProvider.overrideWithValue(_spineWithRoleplays(3)),
      ]);
      expect(find.text('3 scenes'), findsOneWidget);
    });

    testWidgets('F-2: honest fallback when no scenes are authored',
        (WidgetTester tester) async {
      await _pump(tester, 460); // default CourseSpine.empty => 0 roleplays
      expect(find.text('Guided roleplay conversations'), findsOneWidget);
    });

    testWidgets('F-6: status keys off the live gate (honest not-connected)',
        (WidgetTester tester) async {
      await _pump(tester, 460);
      expect(find.textContaining('not connected'), findsOneWidget);
    });

    for (final double w in <double>[460, 800]) {
      testWidgets('layout gauntlet @ ${w.toInt()}px — no overflow',
          (WidgetTester tester) async {
        await _pump(tester, w, overrides: <Override>[
          courseSpineProvider.overrideWithValue(_spineWithRoleplays(12)),
        ]);
        expect(tester.takeException(), isNull);
        expect(find.byKey(const ValueKey<String>('screen-tutor')),
            findsOneWidget);
      });
    }
  });
}
