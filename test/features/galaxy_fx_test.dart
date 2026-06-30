import 'dart:ui' show PictureRecorder;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/features/home/galaxy_path.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// G3 evidence — tier-gated galaxy FX + pod auto-defense (R-WT7). When motion is
/// allowed the Galaxy-Home pod animates (a gentle bob + a periodic shield-pulse
/// "auto-defense" ring); under the reduce-motion HARD FLOOR (the OS setting OR
/// the in-app toggle, both folded into `MediaQuery.disableAnimations`) the pod
/// is STATIC — no animation, no ticker. The motion is decorative; it never
/// touches state or progress.
const CourseSpine _testSpine = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(section: 'SECTION 1 · LEVEL A1', title: 'Level A1', lessons: <CourseLesson>[
    CourseLesson(id: 'l_greet', title: 'Saludos', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'i1', exerciseType: 'mcq', prompt: 'hi', accepted: <String>['hola']),
    ]),
  ]),
]);

Widget _app({required bool reduceMotion}) => ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_testSpine),
        settingsStoreProvider.overrideWithValue(InMemorySettingsStore(
            AppSettings(
                worldTheme: WorldTheme.space, reduceMotion: reduceMotion))),
      ],
      child: const RatelApp(),
    );

void main() {
  test('PodShieldPainter paints + repaints on phase change (auto-defense FX)', () {
    final PictureRecorder rec = PictureRecorder();
    final Canvas canvas = Canvas(rec);
    const PodShieldPainter(0.25).paint(canvas, const Size(40, 40));
    const PodShieldPainter(0.25).paint(canvas, Size.zero); // empty = safe no-op
    expect(
        const PodShieldPainter(0.25)
            .shouldRepaint(const PodShieldPainter(0.25)),
        isFalse);
    expect(
        const PodShieldPainter(0.25)
            .shouldRepaint(const PodShieldPainter(0.5)),
        isTrue);
  });

  testWidgets('motion allowed → the pod animates (shield-pulse auto-defense present)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(reduceMotion: false));
    await tester.pump(); // first frame
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byKey(const ValueKey<String>('home-galaxy-pod')), findsOneWidget);
    // The animated branch adds the shield-pulse layer (R-WT7 "pod auto-defense").
    expect(find.byKey(const ValueKey<String>('home-galaxy-pod-shield')),
        findsOneWidget);
    await tester.pumpWidget(const SizedBox()); // unmount → dispose the ticker
  });

  testWidgets('reduce-motion HARD FLOOR → the pod is STATIC (no shield, settles)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(reduceMotion: true));
    await tester.pumpAndSettle(); // settles ⇒ proves there is no repeating ticker
    expect(find.byKey(const ValueKey<String>('home-galaxy-pod')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-galaxy-pod-shield')),
        findsNothing);
  });
}
