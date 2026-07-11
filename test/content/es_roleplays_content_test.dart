import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/loader/content_loader.dart';
import 'package:ratel/content/spine/content_course_spine.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// S132 (ES-roleplays lane): the ES course's 12 authored roleplays — all
/// banded A1–A2 by owner ruling (strict alignment with the course's real
/// skill inventory; no invented higher-band content) — load through the
/// fail-closed loader and project structurally sound: every graded turn has
/// exactly one correct reply, every branch resolves, every choice carries an
/// authored "Explain this". [R-D10 · R-B3]
void main() {
  const ContentLoader loader = ContentLoader();
  String raw() =>
      File('assets/content/es/course.batch.json').readAsStringSync();
  CourseSpine spine() => buildCourseSpine(loader.loadString(raw()));

  test('ES projects 12 roleplays, 6 A1 + 6 A2, honestly no higher bands', () {
    final List<CourseScenario> rps = spine().roleplays;
    expect(rps.length, 12);
    final Map<String, int> byBand = <String, int>{};
    for (final CourseScenario s in rps) {
      byBand[s.cefr] = (byBand[s.cefr] ?? 0) + 1;
    }
    expect(byBand, <String, int>{'A1': 6, 'A2': 6});
  });

  test('every roleplay is structurally sound: 5 scenes, graded turns resolve',
      () {
    for (final CourseScenario s in spine().roleplays) {
      expect(s.title, isNotEmpty, reason: s.id);
      expect(s.goal, isNotNull, reason: s.id);
      expect(s.goal, isNotEmpty, reason: s.id);
      expect(s.scenes.length, 5, reason: s.id);
      // NPC / you / NPC / you / NPC — graded decisions at sc2 + sc4.
      for (int i = 0; i < 5; i++) {
        final CourseScene sc = s.scenes[i];
        expect(sc.line, isNotEmpty, reason: '${s.id} ${sc.sceneId}');
        expect(sc.speaker, isNotEmpty, reason: '${s.id} ${sc.sceneId}');
        final bool shouldDecide = i == 1 || i == 3;
        expect(sc.isDecision, shouldDecide, reason: '${s.id} ${sc.sceneId}');
        if (!shouldDecide) continue;
        expect(sc.speaker, 'you', reason: s.id);
        expect(sc.choices.length, 3, reason: s.id);
        expect(
            sc.choices.where((CourseChoice c) => c.isCorrect == true).length,
            1,
            reason: '${s.id} exactly one correct reply per turn');
        for (final CourseChoice c in sc.choices) {
          expect(c.label, isNotEmpty, reason: '${s.id} label');
          expect(c.isCorrect, isNotNull,
              reason: '${s.id} roleplay choices are graded');
          expect(c.explain, isNotNull, reason: '${s.id} explain authored');
          expect(c.explain, isNotEmpty, reason: '${s.id} explain authored');
          expect(s.indexOf(c.nextSceneId!), greaterThanOrEqualTo(0),
              reason: '${s.id} branch resolves');
          // The honest-prompt rule: a you-turn's line is a prompt, never a
          // leaked answer (the EN catalogue leaks the correct reply there —
          // logged QA finding; the ES catalogue does not).
          expect(sc.line == c.label, isFalse,
              reason: '${s.id} prompt must not leak a choice');
        }
      }
    }
  });

  test('skill honesty: every roleplay ties only to the real ES skills', () {
    final Map<String, Object?> doc =
        jsonDecode(raw()) as Map<String, Object?>;
    final Map<String, Object?> tables = doc['tables']! as Map<String, Object?>;
    final Set<String> real = <String>{
      for (final Object? g in tables['grammar_point']! as List<Object?>)
        ((g! as Map<String, Object?>)['grammar_id']!) as String,
    };
    int seen = 0;
    for (final Object? row in tables['scenario']! as List<Object?>) {
      final Map<String, Object?> r = row! as Map<String, Object?>;
      if (r['kind'] != 'roleplay') continue;
      seen++;
      expect(<String>{'A1', 'A2'}.contains(r['cefr_level']), isTrue,
          reason: 'owner ruling: A1–A2 only (${r['scenario_id']})');
      final List<Object?> skills = r['skill_ids']! as List<Object?>;
      expect(skills, isNotEmpty, reason: '${r['scenario_id']}');
      for (final Object? sk in skills) {
        expect(real.contains(sk), isTrue,
            reason: '${r['scenario_id']} must reference a real ES skill: $sk');
      }
    }
    expect(seen, 12);
  });

  test('the bakery roleplay carries its authored Spanish', () {
    final CourseScenario pan = spine()
        .roleplays
        .firstWhere((CourseScenario s) => s.id == 'scenario_es_rp_pan1');
    expect(pan.title, 'Buy bread at the bakery');
    expect(pan.cefr, 'A1');
    expect(pan.scenes.first.line, '¡Hola! ¿Qué le pongo?');
    final CourseScene turn = pan.scenes[1];
    final CourseChoice correct =
        turn.choices.firstWhere((CourseChoice c) => c.isCorrect == true);
    expect(correct.label, 'Dos panes, por favor.');
    expect(correct.explain,
        'Number + noun + por favor — a complete, polite order.');
  });
}
