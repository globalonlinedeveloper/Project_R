/// Content seam wiring (queue #H — content-driven spine; INF-3 selectable
/// course). Loads the SELECTED bundled authored course batch through the
/// fail-closed content layer and injects its [CourseSpine] projection behind
/// [courseSpineProvider]. On ANY failure it falls back to the EN default,
/// then to no override (the honest empty-path default — never a fabricated
/// curriculum, never a broken boot). This is the ONLY app-root file that
/// imports the build_runner content models, so — like the models — it is
/// CI-authoritative.
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/content/repository/content_repository.dart';
import 'package:ratel/content/repository/remote_content_repository.dart';
import 'package:ratel/content/repository/remote_fetch.dart' as remote;
import 'package:ratel/content/spine/content_course_spine.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// SharedPreferences key holding the learner's selected course code (INF-3).
const String kCoursePrefKey = 'ratel.course.code';

/// English is the sole target course (S142 — the ES pilot was removed;
/// single-target app). All 10 live courses share the English item base.
const String kDefaultCourseCode = 'en';

/// C-lane go-live gate (plan §B, O-1 = R2/CDN): when ON and [kRemoteContentBase]
/// is set, the app fetches the published course catalog + versioned batch from
/// the content CDN FIRST, falling back to the bundled asset on ANY failure.
/// Default OFF -> byte-identical bundled behaviour (twin of kEnableAiRelay).
const bool kEnableRemoteContent = bool.fromEnvironment('RATEL_REMOTE_CONTENT');

/// Content CDN base URL (e.g. https://pub-....r2.dev/content), set at build
/// time via --dart-define=RATEL_CONTENT_URL=... . Empty = remote disabled.
const String kRemoteContentBase = String.fromEnvironment('RATEL_CONTENT_URL');

/// The published catalog file under the content base.
const String kRemoteManifestPath = 'manifest.json';

/// Course codes served by the remote catalog, captured by the LAST
/// [initContentOverrides] that successfully read the manifest (null until
/// then). Lets the course picker grow remotely without an app release.
List<String>? remoteCourseCodes;

/// Bundled course asset for a course code. A new language = content ROWS +
/// this one asset; no code changes (plan §4, data-driven).
String courseAssetFor(String code) => 'assets/content/$code/course.batch.json';

/// Course codes that actually ship a course batch in this build — derived
/// from the asset manifest, so the picker grows by itself when a new
/// language's `course.batch.json` lands (never a hardcoded list).
Future<List<String>> availableCourseCodes() async {
  final Set<String> codes = <String>{...?remoteCourseCodes};
  try {
    final AssetManifest manifest =
        await AssetManifest.loadFromAssetBundle(rootBundle);
    final RegExp pattern =
        RegExp(r'^assets/content/([^/]+)/course\.batch\.json$');
    codes.addAll(<String>[
      for (final String asset in manifest.listAssets())
        if (pattern.firstMatch(asset) != null)
          pattern.firstMatch(asset)!.group(1)!,
    ]);
  } catch (_) {/* bundled scan best-effort */}
  final List<String> out = codes.toList()..sort();
  return out.isEmpty ? const <String>[kDefaultCourseCode] : out;
}

/// [R-B3 · R-A3] injects the projected Course→Section→Unit→Lesson path at app
/// root for the SELECTED course. Fail-closed ladder: requested course →
/// EN default → honest empty path (never blocks boot).
Future<List<Override>> initContentOverrides({
  String course = kDefaultCourseCode,
  bool? remoteEnabled,
  String? remoteBase,
  remote.RemoteTextFetch? remoteFetch,
}) async {
  // C-lane (O-1 = R2/CDN): remote-first when the gate is on — catalog, then
  // the VERSIONED course file, validated by the SAME fail-closed loader. ANY
  // failure (offline, 404, bad JSON, course missing remotely, empty spine)
  // falls through to the bundled ladder below, so boot can never get worse
  // than today's behaviour.
  final bool useRemote = remoteEnabled ?? kEnableRemoteContent;
  final String base = remoteBase ?? kRemoteContentBase;
  if (useRemote && base.isNotEmpty) {
    try {
      final remote.RemoteTextFetch fetch = remoteFetch ?? remote.fetchRemoteText;
      final String? manifest = await fetch(
          RemoteContentRepository.joinUrl(base, kRemoteManifestPath));
      if (manifest != null) {
        final Map<String, RemoteManifestEntry> entries =
            RemoteContentRepository.parseManifest(manifest);
        if (entries.isNotEmpty) {
          remoteCourseCodes = entries.keys.toList()..sort();
        }
        final RemoteManifestEntry? entry = entries[course];
        if (entry != null) {
          final batch = await RemoteContentRepository(baseUrl: base, fetch: fetch)
              .loadBatch(entry.path);
          final CourseSpine spine = buildCourseSpine(batch);
          if (!spine.isEmpty) {
            return <Override>[courseSpineProvider.overrideWithValue(spine)];
          }
        }
      }
    } catch (_) {/* fall through to the bundled ladder */}
  }
  try {
    final batch = await const BundledContentRepository()
        .loadBatch(courseAssetFor(course));
    final CourseSpine spine = buildCourseSpine(batch);
    if (spine.isEmpty) return const <Override>[];
    return <Override>[courseSpineProvider.overrideWithValue(spine)];
  } catch (_) {
    if (course != kDefaultCourseCode) {
      return initContentOverrides(
          remoteEnabled: useRemote, remoteBase: base, remoteFetch: remoteFetch);
    }
    return const <Override>[]; // honest empty path beats a fabricated one
  }
}
