import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/home/galaxy_path.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

// INC-HOME1 — the Space/Galaxy skin must surface the gold 🏆 checkpoint node,
// matching Classic's `PathNodeData.resolveState` (a COMPLETED end-of-unit
// checkpoint → gold trophy; the current checkpoint stays actionable ▶; a locked
// checkpoint is just 🔒). The class doc contract is "only the SKIN changes;
// states + positions identical to Classic", so the trophy must not disappear in
// Space.
//
// Authored spine: three 2-lesson units, so the last lesson of EACH unit
// (inUnit == lessonCount-1 == 1) is a checkpoint at global indices 1, 3, 5.
//   idx0 unit A l0  · idx1 unit A l1 = checkpoint
//   idx2 unit B l0  · idx3 unit B l1 = checkpoint
//   idx4 unit C l0  · idx5 unit C l1 = checkpoint
// With lessonsCompleted == 3 (active == global index 3):
//   idx1  (3 > 1)  → DONE checkpoint      → 🏆 gold  (assert #1)
//   idx3  (== 3)   → ACTIVE on checkpoint → ▶ normal (assert #2, over-gild guard)
//   idx5  (5 > 3)  → LOCKED checkpoint    → 🔒 normal (assert #3)
const CourseSpine _spine = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(section: 'SECTION 1 · LEVEL A1', title: 'Unit A', lessons: <CourseLesson>[
    CourseLesson(id: 'a0', title: 'A0', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'ax0', exerciseType: 'mcq', prompt: 'hi', accepted: <String>['hola']),
    ]),
    CourseLesson(id: 'a1', title: 'A1', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'ax1', exerciseType: 'mcq', prompt: 'bye', accepted: <String>['adios']),
    ]),
  ]),
  CourseUnit(section: 'SECTION 1 · LEVEL A1', title: 'Unit B', lessons: <CourseLesson>[
    CourseLesson(id: 'b0', title: 'B0', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'bx0', exerciseType: 'mcq', prompt: 'yes', accepted: <String>['si']),
    ]),
    CourseLesson(id: 'b1', title: 'B1', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'bx1', exerciseType: 'mcq', prompt: 'no', accepted: <String>['no']),
    ]),
  ]),
  CourseUnit(section: 'SECTION 1 · LEVEL A1', title: 'Unit C', lessons: <CourseLesson>[
    CourseLesson(id: 'c0', title: 'C0', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'cx0', exerciseType: 'mcq', prompt: 'food', accepted: <String>['comida']),
    ]),
    CourseLesson(id: 'c1', title: 'C1', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'cx1', exerciseType: 'mcq', prompt: 'water', accepted: <String>['agua']),
    ]),
  ]),
]);

ProviderContainer _container() => ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spine),
      // reduceMotion:true keeps the pod ticker off, so pumpAndSettle terminates.
      settingsStoreProvider.overrideWithValue(InMemorySettingsStore(
          const AppSettings(worldTheme: WorldTheme.space, reduceMotion: true))),
    ]);

/// Pumps the Space-skin home with `lessonsCompleted` advanced strictly PAST the
/// first unit's checkpoint (index 1) by recording [completed] real lessons on
/// the SAME container the widget reads — guaranteeing a genuinely completed
/// checkpoint (guards against a vacuous fixture that never completes one).
Future<ProviderContainer> _pumpAt(WidgetTester tester, int completed) async {
  final ProviderContainer c = _container();
  addTearDown(c.dispose);
  // Drive real progress through the learner controller (unconditionally bumps
  // lessonsCompleted); active index := lessonsCompleted.
  final LearnerController learner = c.read(learnerControllerProvider.notifier);
  for (int i = 0; i < completed; i++) {
    learner.recordLessonComplete(xp: 20);
  }
  expect(c.read(learnerControllerProvider).lessonsCompleted, completed,
      reason: 'fixture must actually complete $completed lessons');
  tester.view.physicalSize = const Size(460, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: const RatelApp()));
  await tester.pumpAndSettle();
  return c;
}

GalaxyPlanet _planetWithGlyph(WidgetTester tester, String glyph) {
  final Iterable<GalaxyPlanet> hits = tester
      .widgetList<GalaxyPlanet>(find.byType(GalaxyPlanet))
      .where((GalaxyPlanet p) => p.glyph == glyph);
  expect(hits.length, greaterThanOrEqualTo(1),
      reason: 'expected a GalaxyPlanet with glyph "$glyph"');
  return hits.first;
}

void main() {
  testWidgets(
      'Space skin: a COMPLETED checkpoint node renders 🏆 on a gold (amber) planet',
      (WidgetTester tester) async {
    await _pumpAt(tester, 3); // active == index 3; index 1 is a done checkpoint

    // #1 — the completed checkpoint (unit A, global index 1) is the gold trophy.
    final GalaxyPlanet trophy = _planetWithGlyph(tester, '🏆');
    expect(trophy.color, RatelColors.amber,
        reason: 'completed checkpoint body must be Classic gold (RatelColors.amber)');
    // It is a lit (done) node.
    expect(trophy.lit, isTrue);

    // No ordinary teal ✓ should also be masquerading as this checkpoint: with
    // this spine only the two NON-checkpoint done nodes (idx0, idx2) show ✓.
    final Iterable<GalaxyPlanet> checks = tester
        .widgetList<GalaxyPlanet>(find.byType(GalaxyPlanet))
        .where((GalaxyPlanet p) => p.glyph == '✓');
    expect(checks.length, 2,
        reason: 'exactly the two done NON-checkpoint nodes keep the ✓ glyph');
    // ...and neither of those ✓ nodes is gold (only the trophy golds).
    expect(checks.every((GalaxyPlanet p) => p.color != RatelColors.amber || p.glyph == '🏆'),
        isTrue);
  });

  testWidgets(
      'Space skin: the ACTIVE node on a checkpoint lesson stays ▶ (no over-gilding)',
      (WidgetTester tester) async {
    final ProviderContainer c = await _pumpAt(tester, 3);
    // active index 3 == unit B last lesson == a checkpoint lesson.
    expect(c.read(learnerControllerProvider).lessonsCompleted, 3);

    final GalaxyPlanet active = _planetWithGlyph(tester, '▶');
    // Classic never golds the active node, even on a checkpoint lesson.
    expect(active.color, isNot(RatelColors.amber),
        reason: 'the current checkpoint stays actionable — never gold');
    expect(active.size, 64, reason: 'active planet is the 64px node');
    // And it is emphatically not wearing the trophy.
    expect(active.glyph, isNot('🏆'));
  });

  testWidgets(
      'Space skin: a LOCKED checkpoint stays 🔒 (not 🏆, not gold)',
      (WidgetTester tester) async {
    await _pumpAt(tester, 3); // index 5 (unit C checkpoint) is locked (5 > 3)

    final GalaxyPlanet locked = _planetWithGlyph(tester, '🔒');
    expect(locked.color, isNot(RatelColors.amber),
        reason: 'a locked checkpoint is just locked — no gold reward yet');
    expect(locked.lit, isFalse, reason: 'locked planets render dim');
    // The locked checkpoint must not have been promoted to a trophy.
    final Iterable<GalaxyPlanet> lockedTrophies = tester
        .widgetList<GalaxyPlanet>(find.byType(GalaxyPlanet))
        .where((GalaxyPlanet p) => p.glyph == '🏆' && p.lit == false);
    expect(lockedTrophies, isEmpty,
        reason: 'no locked/dim node may show the trophy glyph');
  });
}
