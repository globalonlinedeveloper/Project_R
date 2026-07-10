import 'package:ratel/features/learning_path/course_spine.dart';

/// L-3 (S113): the CLIENT half of the live-roleplay scenario contract — a
/// compact, structured payload for the `live-token` edge function (v2), which
/// builds the actual system prompt SERVER-side (the template and every clamp
/// live there; plan `RATEL_LIVE_AI_PLAN.md` §B/§E). The payload carries only
/// authored scenario data the learner already sees on the pre-generated 🎭
/// surface (title / CEFR level / goal / world + the opening NPC script lines)
/// plus the course language code. NO prompt text is composed client-side.
/// [R-H6 · R-D11]
Map<String, Object?> liveRoleplayPayload({
  CourseScenario? scenario,
  required String courseCode,
  int maxLines = 6,
}) {
  final Map<String, Object?> body = <String, Object?>{
    if (courseCode.trim().isNotEmpty) 'lang': courseCode.trim(),
  };
  final CourseScenario? s = scenario;
  if (s == null) return body;
  final List<Map<String, String>> lines = <Map<String, String>>[];
  for (final CourseScene scene in s.scenes) {
    // "you" decision scenes carry meta prompts ("How do you reply?"), not
    // script — the live tutor improvises those turns with the learner.
    if (scene.isDecision) continue;
    if (scene.line.trim().isEmpty) continue;
    lines.add(<String, String>{'speaker': scene.speaker, 'line': scene.line});
    if (lines.length >= maxLines) break;
  }
  body['scenario'] = <String, Object?>{
    'title': s.title,
    'cefr': s.cefr,
    if (s.goal != null && s.goal!.trim().isNotEmpty) 'goal': s.goal,
    if (s.world != null && s.world!.trim().isNotEmpty) 'world': s.world,
    if (lines.isNotEmpty) 'lines': lines,
  };
  return body;
}
