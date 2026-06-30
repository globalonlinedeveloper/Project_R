import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persistence seam for the device-local per-day XP history (D1). The map is
/// `YYYY-MM-DD` -> earned XP. Synchronous [load] keeps controller construction
/// test-friendly; the real `PrefsXpHistoryStore` reads the platform store once
/// at boot (mirrors `SettingsStore`).
abstract class XpHistoryStore {
  Map<String, int> load();
  Future<void> save(Map<String, int> history);
}

/// Default — in-memory (tests + keyless boots, R-O1). A `PrefsXpHistoryStore`
/// override in `main` gives real on-device persistence.
class InMemoryXpHistoryStore implements XpHistoryStore {
  InMemoryXpHistoryStore([Map<String, int>? initial])
      : _history = <String, int>{...?initial};

  Map<String, int> _history;

  /// The most recently saved value (handy for tests).
  Map<String, int> get current => <String, int>{..._history};

  @override
  Map<String, int> load() => <String, int>{..._history};

  @override
  Future<void> save(Map<String, int> history) async {
    _history = <String, int>{...history};
  }
}

/// The XP-history persistence seam. Defaults to in-memory; `main` overrides it
/// with a `PrefsXpHistoryStore` for real on-device persistence.
final xpHistoryStoreProvider =
    Provider<XpHistoryStore>((ref) => InMemoryXpHistoryStore());
