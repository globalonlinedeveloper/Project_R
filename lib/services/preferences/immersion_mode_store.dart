import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persistence seam for the device-local IMMERSION-MODE flag (INC-14). When on,
/// the app-shell chrome follows the CURRENT course's target language — a real
/// override on top of [UiLocaleController]. The stored value is a bare bool;
/// `false` (or absent) means immersion is off. Synchronous [load] keeps the
/// controller construction test-friendly (mirrors `UiLocaleStore`).
///
/// Persisted DEVICE-LOCALLY, exactly like the UI-locale override: the synced
/// `user_settings` row is fixed-column (S111/S126 — an unknown column 400s the
/// whole upsert), so a cross-device synced immersion flag is a separate
/// owner-gated migration, never smuggled in here.
abstract class ImmersionModeStore {
  bool load();
  Future<void> save(bool enabled);
}

/// Default — in-memory (tests + keyless boots). A `PrefsImmersionModeStore`
/// override in `main` gives real on-device persistence.
class InMemoryImmersionModeStore implements ImmersionModeStore {
  InMemoryImmersionModeStore([this._enabled = false]);

  bool _enabled;

  /// The most recently saved value (handy for tests).
  bool get current => _enabled;

  @override
  bool load() => _enabled;

  @override
  Future<void> save(bool enabled) async {
    _enabled = enabled;
  }
}

/// The immersion-mode persistence seam. Defaults to in-memory; `main` overrides
/// it with a `PrefsImmersionModeStore` for real on-device persistence.
final Provider<ImmersionModeStore> immersionModeStoreProvider =
    Provider<ImmersionModeStore>((ref) => InMemoryImmersionModeStore());
