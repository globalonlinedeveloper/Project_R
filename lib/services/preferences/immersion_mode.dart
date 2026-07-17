import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'immersion_mode_store.dart';

/// Whether IMMERSION MODE is on (INC-14): the app-shell chrome follows the
/// CURRENT course's target language instead of the device / menu-language
/// override. This is a device-local PREFERENCE flag — the actual locale flip is
/// driven through [UiLocaleController.setLocale] at the toggle site (immersion
/// on ⇒ `setLocale(Locale(courseCode))`, off ⇒ `setLocale(null)`), so the two
/// controls share `MaterialApp.locale` by design (INC-13 coherence).
///
/// Persisted DEVICE-LOCALLY through [ImmersionModeStore] (the `UiLocaleStore`
/// precedent): the synced `user_settings` row is fixed-column (S111/S126 — an
/// unknown column 400s the whole upsert), so a cross-device synced immersion
/// flag is a separate owner-gated migration, never smuggled in here.
class ImmersionModeController extends Notifier<bool> {
  @override
  bool build() => ref.watch(immersionModeStoreProvider).load();

  /// Sets the flag and persists it. The caller is responsible for the paired
  /// `UiLocaleController.setLocale` so the shared `MaterialApp.locale` stays in
  /// step — immersion is a manual toggle, not a reactive per-build enforcer.
  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await ref.read(immersionModeStoreProvider).save(enabled);
  }
}

/// The learner's immersion-mode flag; `false` = off (follow device / menu
/// language). Off by default.
final NotifierProvider<ImmersionModeController, bool> immersionModeProvider =
    NotifierProvider<ImmersionModeController, bool>(
        ImmersionModeController.new);
