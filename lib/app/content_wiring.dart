/// Content seam wiring (queue #H — content-driven spine). Loads the bundled
/// authored course batch through the fail-closed content layer and injects its
/// [CourseSpine] projection behind [courseSpineProvider]. On ANY failure it
/// returns no override, so the app boots with the honest empty-path default
/// (never a fabricated curriculum). This is the ONLY app-root file that imports
/// the build_runner content models, so — like the models — it is CI-authoritative.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/content/repository/content_repository.dart';
import 'package:ratel/content/spine/content_course_spine.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// [R-B3] injects the projected Course→Section→Unit→Lesson path at app root.
/// Bundled authored course batch (ES beachhead). Other locales add rows only.
const String kSeedEsCourseAsset = 'assets/content/es/course.batch.json';

/// Best-effort `main`-side wiring: load + project the bundled course batch, or
/// fall back to the honest empty default on any error (never blocks boot).
Future<List<Override>> initContentOverrides() async {
  try {
    final batch =
        await const BundledContentRepository().loadBatch(kSeedEsCourseAsset);
    final CourseSpine spine = buildCourseSpine(batch);
    if (spine.isEmpty) return const <Override>[];
    return <Override>[courseSpineProvider.overrideWithValue(spine)];
  } catch (_) {
    return const <Override>[]; // honest empty path beats a fabricated one
  }
}
