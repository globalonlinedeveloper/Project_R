import 'dart:convert';

import '../loader/content_loader.dart';
import 'content_repository.dart';
import 'remote_fetch.dart' as remote;

/// One course entry from the published `manifest.json` catalog:
/// `{"courses":[{"code":"en","batch_id":"...","path":"en/course.<id>.json"}]}`.
class RemoteManifestEntry {
  const RemoteManifestEntry(
      {required this.code, required this.batchId, required this.path});

  /// Course code the picker/loader keys on (e.g. 'en').
  final String code;

  /// The published batch id (provenance/debugging; the versioned [path] is
  /// what actually cache-busts).
  final String batchId;

  /// Path of the VERSIONED course file relative to the content base URL.
  final String path;
}

/// Stage-3 [ContentRepository]: fetches a published course batch from the
/// R2/CDN content base (O-1, plan §B/C) and validates it through the SAME
/// fail-closed [ContentLoader] the bundled path uses — remote content can
/// never be less validated than bundled. [ref] is the manifest-relative path.
/// Fail-closed: ANY fetch/parse problem throws, and the caller's ladder
/// (bundled asset → ES → empty) takes over.
class RemoteContentRepository implements ContentRepository {
  RemoteContentRepository({
    required this.baseUrl,
    remote.RemoteTextFetch? fetch,
    ContentLoader? loader,
  })  : _fetch = fetch ?? remote.fetchRemoteText,
        _loader = loader ?? const ContentLoader();

  /// The published content base (e.g. `https://pub-….r2.dev/content`).
  final String baseUrl;

  final remote.RemoteTextFetch _fetch;
  final ContentLoader _loader;

  @override
  Future<ContentBatch> loadBatch(String ref) async {
    final String? source = await _fetch(joinUrl(baseUrl, ref));
    if (source == null) {
      throw StateError('remote content unavailable: $ref');
    }
    return _loader.loadString(source); // fail-closed validation, as bundled
  }

  /// Pure: join base + relative path without doubling slashes.
  static Uri joinUrl(String base, String ref) {
    final String b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final String r = ref.startsWith('/') ? ref.substring(1) : ref;
    return Uri.parse('$b/$r');
  }

  /// Pure, tolerant manifest parse: garbage entries are SKIPPED, never fatal;
  /// an unusable manifest yields an empty map (callers fall back to bundled).
  static Map<String, RemoteManifestEntry> parseManifest(String json) {
    final Map<String, RemoteManifestEntry> out = <String, RemoteManifestEntry>{};
    try {
      final Object? decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) return out;
      final Object? courses = decoded['courses'];
      if (courses is! List) return out;
      for (final Object? c in courses) {
        if (c is! Map) continue;
        final Object? code = c['code'];
        final Object? path = c['path'];
        if (code is! String || code.isEmpty || path is! String || path.isEmpty) {
          continue;
        }
        out[code] = RemoteManifestEntry(
          code: code,
          batchId: c['batch_id']?.toString() ?? '',
          path: path,
        );
      }
    } catch (_) {/* unusable manifest -> empty */}
    return out;
  }
}
