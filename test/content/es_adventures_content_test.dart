import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/loader/content_loader.dart';
import 'package:ratel/content/spine/content_course_spine.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// S131c (L-4): the ES course's 9 authored adventures — ported from the
/// owner design HTML's own Spanish adventure scenes (§4.12 mock data was the
/// owner's authored ES content) with short authored closers — load through
/// the fail-closed loader and project structurally sound: every branch
/// resolves, every scenario ends, all chrome refs resolve to real glosses.
/// [R-D10 · R-B3]
void main() {
  const ContentLoader loader = ContentLoader();
  CourseSpine spine() => buildCourseSpine(loader.loadString(
      File('assets/content/es/course.batch.json').readAsStringSync()));

  test('ES projects 9 adventures across the design district bands', () {
    final List<CourseScenario> adv = spine().adventures;
    expect(adv.length, 9);
    final Map<String, int> byBand = <String, int>{};
    for (final CourseScenario s in adv) {
      byBand[s.cefr] = (byBand[s.cefr] ?? 0) + 1;
    }
    expect(byBand, <String, int>{'A1': 2, 'A2': 2, 'B1': 3, 'B2': 2});
  });

  test('every adventure is structurally sound: branches resolve + endings',
      () {
    for (final CourseScenario s in spine().adventures) {
      expect(s.title, isNotEmpty, reason: s.id);
      expect(s.goal, isNotNull, reason: s.id);
      expect(s.goal, isNotEmpty, reason: s.id);
      expect(s.scenes.length, 4, reason: s.id); // 1 decision + 3 endings
      final CourseScene opening = s.scenes.first;
      expect(opening.choices.length, 3, reason: s.id);
      expect(opening.line, isNotEmpty, reason: s.id);
      for (final CourseChoice c in opening.choices) {
        expect(c.label, isNotEmpty, reason: '${s.id} label');
        expect(c.nextSceneId, isNotNull, reason: '${s.id} branch');
        expect(s.indexOf(c.nextSceneId!), greaterThanOrEqualTo(0),
            reason: '${s.id} branch ${c.nextSceneId} must resolve');
      }
      // Every closer is a real ENDING (no choices) with a real Spanish line.
      for (final CourseScene end in s.scenes.skip(1)) {
        expect(end.isDecision, isFalse, reason: s.id);
        expect(end.line, isNotEmpty, reason: s.id);
        expect(end.speaker, isNotEmpty, reason: s.id);
      }
    }
  });

  test('the design café scene ports with its authored Spanish', () {
    final CourseScenario cafe = spine().adventures.firstWhere(
        (CourseScenario s) => s.id == 'scenario_es_adv_cafe1');
    expect(cafe.title, 'Order a coffee');
    expect(cafe.cefr, 'A1');
    expect(cafe.goal, 'Ask for your drink');
    expect(cafe.scenes.first.line, '¡Hola! ¿Qué te pongo?');
    expect(cafe.scenes.first.choices.first.label,
        'Un café con leche, por favor');
  });

  test('roleplays remain honestly absent for ES (none authored yet)', () {
    expect(spine().roleplays, isEmpty);
  });
}
