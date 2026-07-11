import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/features/adventures/adventures_screen.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/tutor/ai_tutor_screen.dart';

/// Tall surface so the whole lazy ListView lays out (S37 fold gotcha).
Future<void> _pumpTall(WidgetTester tester, Widget child,
    {List<Override> overrides = const <Override>[]}) async {
  tester.view.physicalSize = const Size(440, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: MaterialApp(home: child)));
  await tester.pump();
}

CourseSpine _spineWithAdventure() => const CourseSpine(
      courseCode: 'en',
      units: <CourseUnit>[],
      adventures: <CourseScenario>[
        CourseScenario(
          id: 'adv1',
          kind: 'adventure',
          title: 'The market',
          cefr: 'A1',
          scenes: <CourseScene>[
            CourseScene(
                sceneId: 'a1', speaker: 'narrator', line: 'You reach a fork.'),
          ],
        ),
      ],
    );

void main() {
  testWidgets('Library → AI Tutor opens the REAL screen (route promoted)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AI Tutor'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('screen-tutor')), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
    expect(find.text('PRO'), findsWidgets);
    expect(find.textContaining('not connected'), findsOneWidget);
  });

  testWidgets('AI Tutor mode tap is HONEST (PRO gate, never a faked reply)',
      (WidgetTester tester) async {
    await _pumpTall(tester, const AiTutorScreen());
    await tester.tap(find.text('Talk to Ratel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('RATEL PRO unlocks live AI tutoring.'), findsOneWidget);
  });

  testWidgets('Library → Adventures opens the REAL screen (FREE, INF-8)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adventures'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('screen-adventures')),
        findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
    expect(find.text('FREE'), findsWidgets);
  });

  testWidgets('Adventures lists authored branching scenarios (no live AI)',
      (WidgetTester tester) async {
    await _pumpTall(tester, const AdventuresScreen(), overrides: <Override>[
      settingsStoreProvider.overrideWithValue(
          InMemorySettingsStore(const AppSettings(reduceMotion: true))),
      courseSpineProvider.overrideWithValue(_spineWithAdventure()),
    ]);
    expect(find.text('The market'), findsOneWidget);
    // S131b: the invented intro was replaced by the design 4.12 hero copy.
    expect(find.textContaining('no wrong answers'), findsOneWidget);
  });
}
