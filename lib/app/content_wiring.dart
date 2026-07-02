/// Content seam wiring (queue #H — content-driven spine; INF-3 selectable
/// course). Loads the SELECTED bundled authored course batch through the
/// fail-closed content layer and injects its [CourseSpine] projection behind
/// [courseSpineProvider]. On ANY failure it falls back to the ES beachhead,
/// then to no override (the honest empty-path default — never a fabricated
/// curriculum, never a broken boot). This is the ONLY app-root file that
/// imports the build_runner content models, so — like the models — it is
/// CI-authoritative.
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/content/repository/content_repository.dart';
import 'package:ratel/content/spine/content_course_spine.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// SharedPreferences key holding the learner's selected course code (INF-3).
const String kCoursePrefKey = 'ratel.course.code';

/// The ES beachhead stays the default — existing learners see no change.
const String kDefaultCourseCode = 'es';

/// Bundled course asset for a course code. A new language = content ROWS +
/// this one asset; no code changes (plan §4, data-driven).
String courseAssetFor(String code) => 'assets/content/$code/course.batch.json';

/// Course codes that actually ship a course batch in this build — derived
/// from the asset manifest, so the picker grows by itself when a new
/// language's `course.batch.json` lands (never a hardcoded list).
Future<List<String>> availableCourseCodes() async {
  try {
    final AssetManifest manifest =
        await AssetManifest.loadFromAssetBundle(rootBundle);
    final RegExp pattern =
        RegExp(r'^assets/content/([^/]+)/course\.batch\.json$');
    final List<String> codes = <String>[
      for (final String asset in manifest.listAssets())
        if (pattern.firstMatch(asset) != null)
          pattern.firstMatch(asset)!.group(1)!,
    ]..sort();
    return codes.isEmpty ? const <String>[kDefaultCourseCode] : codes;
  } catch (_) {
    return const <String>[kDefaultCourseCode];
  }
}

/// [R-B3 · R-A3] injects the projected Course→Section→Unit→Lesson path at app
/// root for the SELECTED course. Fail-closed ladder: requested course →
/// ES beachhead → honest empty path (never blocks boot).
Future<List<Override>> initContentOverrides(
    {String course = kDefaultCourseCode}) async {
  try {
    final batch = await const BundledContentRepository()
        .loadBatch(courseAssetFor(course));
    final CourseSpine spine = buildCourseSpine(batch);
    if (spine.isEmpty) return const <Override>[];
    return <Override>[courseSpineProvider.overrideWithValue(spine)];
  } catch (_) {
    if (course != kDefaultCourseCode) return initContentOverrides();
    return const <Override>[]; // honest empty path beats a fabricated one
  }
}
