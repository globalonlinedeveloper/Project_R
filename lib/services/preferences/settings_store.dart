import 'app_settings.dart';

/// Persistence seam for [AppSettings] (a11y + daily goal). The world/motion
/// Synchronous [load] keeps controller construction simple + test-friendly; the
/// real [PrefsSettingsStore] loads the underlying store once at boot.
abstract class SettingsStore {
  AppSettings load();
  Future<void> save(AppSettings settings);
}

/// Default store — in-memory, like the other Stage-2 controllers (R-O1). Used
/// in tests and on keyless/degraded boots; a [PrefsSettingsStore] override gives
/// real on-device persistence in `main`.
class InMemorySettingsStore implements SettingsStore {
  InMemorySettingsStore([AppSettings initial = const AppSettings()])
      : _settings = initial;

  AppSettings _settings;

  /// The most recently saved value (handy for tests).
  AppSettings get current => _settings;

  @override
  AppSettings load() => _settings;

  @override
  Future<void> save(AppSettings settings) async {
    _settings = settings;
  }
}
