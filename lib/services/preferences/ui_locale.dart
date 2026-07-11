import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui_locale_store.dart';

/// The learner's explicit app-shell (chrome) language override — `null`
/// follows the device locale (L-2 · the R-C13 ARB layer).
///
/// Persisted DEVICE-LOCALLY through [UiLocaleStore] (the `xpHistory`
/// precedent): the synced `user_settings` row is fixed-column (S111/S126 —
/// an unknown column 400s the whole upsert), so a cross-device synced locale
/// is a separate owner-gated migration, never smuggled in here.
class UiLocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final String? code = ref.watch(uiLocaleStoreProvider).load();
    return code == null ? null : Locale(code);
  }

  /// Sets (or clears, with `null`) the override and persists it.
  Future<void> setLocale(Locale? locale) async {
    state = locale;
    await ref.read(uiLocaleStoreProvider).save(locale?.languageCode);
  }
}

/// The learner's app-shell locale override; `null` = follow the device.
final NotifierProvider<UiLocaleController, Locale?>
    uiLocaleControllerProvider =
    NotifierProvider<UiLocaleController, Locale?>(UiLocaleController.new);
