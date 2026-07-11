import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persistence seam for the device-local app-shell UI-language override
/// (L-2 · R-C13). The stored value is a bare BCP-47 language code (`'es'`);
/// `null` means "follow the device locale". Synchronous [load] keeps
/// controller construction test-friendly (mirrors `EarnedStampsStore`).
abstract class UiLocaleStore {
  String? load();
  Future<void> save(String? languageCode);
}

/// Default — in-memory (tests + keyless boots). A `PrefsUiLocaleStore`
/// override in `main` gives real on-device persistence.
class InMemoryUiLocaleStore implements UiLocaleStore {
  InMemoryUiLocaleStore([this._code]);

  String? _code;

  /// The most recently saved value (handy for tests).
  String? get current => _code;

  @override
  String? load() => _code;

  @override
  Future<void> save(String? languageCode) async {
    _code = languageCode;
  }
}

/// The UI-locale persistence seam. Defaults to in-memory; `main` overrides it
/// with a `PrefsUiLocaleStore` for real on-device persistence.
final Provider<UiLocaleStore> uiLocaleStoreProvider =
    Provider<UiLocaleStore>((ref) => InMemoryUiLocaleStore());
