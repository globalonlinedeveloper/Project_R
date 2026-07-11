import 'package:flutter/widgets.dart';

import 'package:ratel/l10n/generated/app_localizations.dart';

export 'package:ratel/l10n/generated/app_localizations.dart';

/// App-shell (chrome) localization — the R-C13 ARB layer (L-2).
///
/// [l10n] is the null-safe lookup every screen uses: it falls back to English
/// whenever no `AppLocalizations` delegate is installed above `this` context,
/// so bare-`MaterialApp` test harnesses (and any host that skips the
/// delegates) keep rendering byte-identical English chrome instead of
/// crashing. `RatelApp` installs the real delegates + the learner's locale.
extension RatelL10nX on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      lookupAppLocalizations(const Locale('en'));
}

/// Endonyms for the app-shell UI languages (picker display strings — these
/// are locale-INDEPENDENT by design, so they live in code, not ARB).
/// Order = shipped-course order (en · es, then the S123 reach order).
const Map<String, String> kUiLanguageEndonyms = <String, String>{
  'en': 'English',
  'es': 'Español',
  'hi': 'हिन्दी',
  'zh': '中文',
  'ar': 'العربية',
  'bn': 'বাংলা',
  'pt': 'Português',
  'ru': 'Русский',
  'ja': '日本語',
  'de': 'Deutsch',
  'fr': 'Français',
  'ko': '한국어',
};
