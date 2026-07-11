import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/loader/content_loader.dart';
import 'package:ratel/content/spine/content_course_spine.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'dart:io';

/// S133 (EN answer-leak fix) + S134 (EN "Explain this" gloss parity): the EN
/// course's 12 authored roleplays (2 per band A1–C2) load through the
/// fail-closed loader and project structurally sound — every graded turn has
/// exactly one correct reply and every branch resolves.
///
/// THE LEAK GUARD: a you-turn's line is a PROMPT, never the leaked answer. S132's
/// QA found the oldest roleplay (scenario_en_a1_meet) had reused the lesson
/// sentence "Nice to meet you." as its you-line — byte-identical to the correct
/// choice and rendered directly above the choices by roleplay_player_screen
/// (_speakerLine). S133 repointed it to the honest prompt "How do you reply?".
///
/// THE EXPLANATION GUARD (S134): every roleplay choice must carry a non-empty
/// "Explain this" explanation gloss (content_kind: explanation, keyed by the
/// choice label_ref). Ground truth found scenario_en_a1_meet — the same
/// earliest-authored roleplay — was the ONLY one missing them (3 of 69 choices);
/// the other 11 roleplays already carried all 66. S134 authored the 3 and this
/// whole-surface test locks the invariant so no future roleplay can ship without
/// them. It also guards gotcha-22: the choice carries BOTH an explanation and an
/// instruction gloss on the same content_id, so the label must never render as
/// its explanation. [R-D10 · R-B3]
void main() {
  const ContentLoader loader = ContentLoader();
  String raw() =>
      File('assets/content/en/course.batch.json').readAsStringSync();
  CourseSpine spine() => buildCourseSpine(loader.loadString(raw()));

  test('EN projects 12 roleplays, 2 per band A1–C2', () {
    final List<CourseScenario> rps = spine().roleplays;
    expect(rps.length, 12);
    final Map<String, int> byBand = <String, int>{};
    for (final CourseScenario s in rps) {
      byBand[s.cefr] = (byBand[s.cefr] ?? 0) + 1;
    }
    expect(byBand, <String, int>{
      'A1': 2,
      'A2': 2,
      'B1': 2,
      'B2': 2,
      'C1': 2,
      'C2': 2,
    });
  });

  test('every roleplay is structurally sound and graded turns resolve', () {
    int decisions = 0;
    for (final CourseScenario s in spine().roleplays) {
      expect(s.title, isNotEmpty, reason: s.id);
      expect(s.goal, isNotNull, reason: s.id);
      expect(s.goal, isNotEmpty, reason: s.id);
      expect(s.scenes.length, greaterThanOrEqualTo(3), reason: s.id);
      for (final CourseScene sc in s.scenes) {
        expect(sc.line, isNotEmpty, reason: '${s.id} ${sc.sceneId}');
        expect(sc.speaker, isNotEmpty, reason: '${s.id} ${sc.sceneId}');
        if (!sc.isDecision) continue;
        decisions++;
        expect(sc.speaker, 'you', reason: '${s.id} ${sc.sceneId}');
        expect(sc.choices.length, 3, reason: '${s.id} ${sc.sceneId}');
        expect(
            sc.choices.where((CourseChoice c) => c.isCorrect == true).length,
            1,
            reason: '${s.id} exactly one correct reply per turn');
        for (final CourseChoice c in sc.choices) {
          expect(c.label, isNotEmpty, reason: '${s.id} label');
          expect(c.isCorrect, isNotNull, reason: '${s.id} graded');
          expect(s.indexOf(c.nextSceneId!), greaterThanOrEqualTo(0),
              reason: '${s.id} branch resolves');
        }
      }
    }
    expect(decisions, 23, reason: 'all EN roleplay you-turns are covered');
  });

  test('NO ANSWER LEAK: no you-turn prompt equals any of its choices', () {
    for (final CourseScenario s in spine().roleplays) {
      for (final CourseScene sc in s.scenes) {
        if (!sc.isDecision) continue;
        for (final CourseChoice c in sc.choices) {
          expect(sc.line == c.label, isFalse,
              reason: '${s.id} ${sc.sceneId}: you-prompt "${sc.line}" '
                  'must not reveal choice "${c.label}"');
        }
      }
    }
  });

  test('EXPLANATION PARITY: every roleplay choice carries a non-empty '
      '"Explain this" gloss, and the label never renders as its explanation',
      () {
    int choices = 0;
    for (final CourseScenario s in spine().roleplays) {
      for (final CourseScene sc in s.scenes) {
        if (!sc.isDecision) continue;
        for (final CourseChoice c in sc.choices) {
          choices++;
          expect(c.explain, isNotNull,
              reason: '${s.id} ${sc.sceneId} "${c.label}" needs an '
                  'explanation gloss');
          expect(c.explain, isNotEmpty,
              reason: '${s.id} ${sc.sceneId} "${c.label}" explanation is empty');
          // gotcha 22: explanation + instruction share the label_ref content_id;
          // the label must stay the choice text, never the explanation.
          expect(c.label == c.explain, isFalse,
              reason: '${s.id} ${sc.sceneId}: label leaked its explanation');
        }
      }
    }
    expect(choices, 69, reason: 'all EN roleplay choices covered');
  });

  test('the fixed a1_meet roleplay prompts honestly, answer + explanations intact',
      () {
    final CourseScenario meet = spine()
        .roleplays
        .firstWhere((CourseScenario s) => s.id == 'scenario_en_a1_meet');
    final CourseScene turn =
        meet.scenes.firstWhere((CourseScene s) => s.isDecision);
    // S133 fix: was the leaked answer "Nice to meet you.", now an honest prompt.
    expect(turn.line, 'How do you reply?');
    final CourseChoice correct =
        turn.choices.firstWhere((CourseChoice c) => c.isCorrect == true);
    // the correct answer still lives in the choices, just no longer leaked above.
    expect(correct.label, 'Nice to meet you.');
    // S134: the 3 authored explanations project onto the right choices.
    final Map<String, String?> explByLabel = <String, String?>{
      for (final CourseChoice c in turn.choices) c.label: c.explain,
    };
    expect(explByLabel['Nice to meet you.'],
        "'Nice to meet you' is exactly what you say when someone introduces themselves.");
    expect(explByLabel['Good night.'],
        "'Good night' is for leaving at the end of the day — Ben has just introduced himself.");
    expect(explByLabel['Goodbye.'],
        "'Goodbye' ends a conversation — but you're only just meeting Ben.");
  });
}
