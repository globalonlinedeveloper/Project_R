import 'package:flutter/services.dart' show rootBundle;
import '../loader/content_loader.dart';

/// Loads bundled content batches through the fail-closed [ContentLoader].
/// Web-safe (rootBundle), local-only, NO DB (Stage 2 still loads bundled JSON).
class ContentRepository {
  const ContentRepository(this._loader);

  final ContentLoader _loader;

  Future<ContentBatch> loadAsset(String assetPath) async {
    final source = await rootBundle.loadString(assetPath);
    return _loader.loadString(source);
  }
}
