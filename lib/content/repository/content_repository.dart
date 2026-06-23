import 'package:flutter/services.dart' show rootBundle;
import '../loader/content_loader.dart';

/// Data-access seam for CONTENT (R-M3). Features read content batches ONLY
/// through this interface — never a concrete loader — so Stage 3 can plug a
/// Supabase-backed implementation in behind the SAME contract without touching
/// feature code. This mirrors the learner-state DAL in `lib/services/data_access/`
/// (validation finding P1-5).
abstract interface class ContentRepository {
  /// Load and validate one content batch identified by [ref]. The bundled impl
  /// treats [ref] as an asset path; a Stage-3 impl may treat it as a batch id /
  /// remote key. Implementations MUST be fail-closed (validate before return).
  Future<ContentBatch> loadBatch(String ref);
}

/// Stage 1–2 implementation: loads bundled JSON from the asset bundle through
/// the fail-closed [ContentLoader]. Web-safe (`rootBundle`), local-only, NO DB.
/// The hard-coded asset path lives at the call site (`kSeedEnAsset`), not in the
/// interface — so the interface stays storage-agnostic.
class BundledContentRepository implements ContentRepository {
  const BundledContentRepository([this._loader = const ContentLoader()]);

  final ContentLoader _loader;

  @override
  Future<ContentBatch> loadBatch(String ref) async {
    final source = await rootBundle.loadString(ref);
    return _loader.loadString(source);
  }
}
