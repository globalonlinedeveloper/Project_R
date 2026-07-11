import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persistence seam for the device-local notification earn-time stamps
/// (D-13 · R-L11 per-row timestamps). The map is `notification id -> the REAL
/// moment the learner was observed crossing that milestone's threshold`
/// (recorded against the injected clock AT the crossing, never invented after
/// the fact). Synchronous [load] keeps controller construction test-friendly;
/// the real `PrefsEarnedStampsStore` reads the platform store once at boot
/// (mirrors `XpHistoryStore`).
///
/// HONESTY (charter "don't fake depth"): a milestone earned BEFORE this
/// feature shipped — or hydrated from another device — has NO stamp; its inbox
/// row simply shows no time label. Nothing is backfilled or fabricated.
abstract class EarnedStampsStore {
  Map<String, DateTime> load();
  Future<void> save(Map<String, DateTime> stamps);
}

/// Default — in-memory (tests + keyless boots, R-O1). A
/// `PrefsEarnedStampsStore` override in `main` gives real on-device
/// persistence.
class InMemoryEarnedStampsStore implements EarnedStampsStore {
  InMemoryEarnedStampsStore([Map<String, DateTime>? initial])
      : _stamps = <String, DateTime>{...?initial};

  Map<String, DateTime> _stamps;

  /// The most recently saved value (handy for tests).
  Map<String, DateTime> get current => <String, DateTime>{..._stamps};

  @override
  Map<String, DateTime> load() => <String, DateTime>{..._stamps};

  @override
  Future<void> save(Map<String, DateTime> stamps) async {
    _stamps = <String, DateTime>{...stamps};
  }
}

/// The earn-stamps persistence seam. Defaults to in-memory; `main` overrides
/// it with a `PrefsEarnedStampsStore` for real on-device persistence.
final earnedStampsStoreProvider =
    Provider<EarnedStampsStore>((ref) => InMemoryEarnedStampsStore());
