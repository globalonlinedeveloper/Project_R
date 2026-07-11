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

/// Display-name lookups for CHROME entities whose stored identifier IS the
/// English label (onboarding option lists, goal presets). English in,
/// localized display out; unknown names pass through untouched — so authored
/// content and future entries degrade honestly.
String ratelLanguageDisplayName(BuildContext context, String englishName) =>
    switch (englishName) {
      'Spanish' => context.l10n.langNameSpanish,
      'French' => context.l10n.langNameFrench,
      'Japanese' => context.l10n.langNameJapanese,
      'Tamil' => context.l10n.langNameTamil,
      'German' => context.l10n.langNameGerman,
      'Korean' => context.l10n.langNameKorean,
      _ => englishName,
    };

String ratelReasonDisplayLabel(BuildContext context, String englishLabel) =>
    switch (englishLabel) {
      'Travel' => context.l10n.reasonTravel,
      'Culture' => context.l10n.reasonCulture,
      'Career' => context.l10n.reasonCareer,
      'Family & friends' => context.l10n.reasonFamilyFriends,
      'Brain training' => context.l10n.reasonBrainTraining,
      'Just for fun' => context.l10n.reasonJustForFun,
      _ => englishLabel,
    };

String ratelGoalDisplayLabel(BuildContext context, String englishLabel) =>
    switch (englishLabel) {
      'Casual' => context.l10n.goalCasual,
      'Regular' => context.l10n.goalRegular,
      'Serious' => context.l10n.goalSerious,
      'Intense' => context.l10n.goalIntense,
      _ => englishLabel,
    };

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
