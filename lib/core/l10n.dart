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
/// Engine-generated strings (quest / notification / achievement catalogues,
/// league tier labels, CEFR level names) localize through these RENDER-time
/// maps — the engines stay UI-free and keep emitting their stable English
/// catalogue (ids + English text = the identifiers, pinned by service tests);
/// only the render site swaps in the learner's locale. Unknown ids/labels
/// pass through untouched, so future catalogue growth degrades honestly.
String ratelQuestTitle(BuildContext context, String id, String fallback) =>
    switch (id) {
      'power_session' => context.l10n.questTitlePowerSession,
      'on_fire' => context.l10n.questTitleOnFire,
      'streak_keeper' => context.l10n.questTitleStreakKeeper,
      _ => fallback,
    };

String ratelQuestDescription(
        BuildContext context, String id, String fallback) =>
    switch (id) {
      'power_session' => context.l10n.questDescPowerSession,
      'on_fire' => context.l10n.questDescOnFire,
      'streak_keeper' => context.l10n.questDescStreakKeeper,
      _ => fallback,
    };

String ratelNotificationTitle(
        BuildContext context, String id, String fallback) =>
    switch (id) {
      'lessons:1' => context.l10n.notifTitleLessons1,
      'lessons:5' => context.l10n.notifTitleLessons5,
      'lessons:10' => context.l10n.notifTitleLessons10,
      'lessons:25' => context.l10n.notifTitleLessons25,
      'lessons:50' => context.l10n.notifTitleLessons50,
      'streak:3' => context.l10n.notifTitleStreak3,
      'streak:7' => context.l10n.notifTitleStreak7,
      'streak:14' => context.l10n.notifTitleStreak14,
      'streak:30' => context.l10n.notifTitleStreak30,
      'xp:100' => context.l10n.notifTitleXp100,
      'xp:500' => context.l10n.notifTitleXp500,
      'xp:1000' => context.l10n.notifTitleXp1000,
      'xp:2500' => context.l10n.notifTitleXp2500,
      'level:1' => context.l10n.notifTitleLevel1,
      'level:2' => context.l10n.notifTitleLevel2,
      'level:3' => context.l10n.notifTitleLevel3,
      'level:4' => context.l10n.notifTitleLevel4,
      'level:5' => context.l10n.notifTitleLevel5,
      _ => fallback,
    };

String ratelNotificationBody(
        BuildContext context, String id, String fallback) =>
    switch (id) {
      'lessons:1' => context.l10n.notifBodyLessons1,
      'lessons:5' => context.l10n.notifBodyLessons5,
      'lessons:10' => context.l10n.notifBodyLessons10,
      'lessons:25' => context.l10n.notifBodyLessons25,
      'lessons:50' => context.l10n.notifBodyLessons50,
      'streak:3' => context.l10n.notifBodyStreak3,
      'streak:7' => context.l10n.notifBodyStreak7,
      'streak:14' => context.l10n.notifBodyStreak14,
      'streak:30' => context.l10n.notifBodyStreak30,
      'xp:100' => context.l10n.notifBodyXp100,
      'xp:500' => context.l10n.notifBodyXp500,
      'xp:1000' => context.l10n.notifBodyXp1000,
      'xp:2500' => context.l10n.notifBodyXp2500,
      'level:1' => context.l10n.notifBodyLevel1,
      'level:2' => context.l10n.notifBodyLevel2,
      'level:3' => context.l10n.notifBodyLevel3,
      'level:4' => context.l10n.notifBodyLevel4,
      'level:5' => context.l10n.notifBodyLevel5,
      _ => fallback,
    };

String ratelAchievementTitle(
        BuildContext context, String id, String fallback) =>
    switch (id) {
      'first_steps' => context.l10n.achTitleFirstSteps,
      'scholar' => context.l10n.achTitleScholar,
      'wildfire' => context.l10n.achTitleWildfire,
      'point_maker' => context.l10n.achTitlePointMaker,
      'collector' => context.l10n.achTitleCollector,
      'rising_star' => context.l10n.achTitleRisingStar,
      _ => fallback,
    };

String ratelLeagueTierName(BuildContext context, String englishLabel) =>
    switch (englishLabel) {
      'Bronze' => context.l10n.leagueTierBronze,
      'Silver' => context.l10n.leagueTierSilver,
      'Gold' => context.l10n.leagueTierGold,
      'Sapphire' => context.l10n.leagueTierSapphire,
      'Ruby' => context.l10n.leagueTierRuby,
      'Emerald' => context.l10n.leagueTierEmerald,
      'Amethyst' => context.l10n.leagueTierAmethyst,
      'Pearl' => context.l10n.leagueTierPearl,
      'Obsidian' => context.l10n.leagueTierObsidian,
      'Diamond' => context.l10n.leagueTierDiamond,
      _ => englishLabel,
    };

String ratelCefrLevelDisplayName(BuildContext context, String englishName) =>
    switch (englishName) {
      'Beginner' => context.l10n.cefrNameBeginner,
      'Elementary' => context.l10n.cefrNameElementary,
      'Intermediate' => context.l10n.cefrNameIntermediate,
      'Upper intermediate' => context.l10n.cefrNameUpperIntermediate,
      'Advanced' => context.l10n.cefrNameAdvanced,
      'Proficient' => context.l10n.cefrNameProficient,
      _ => englishName,
    };
/// Search render maps (R-L12): destination catalogue entries localize by
/// ROUTE (the stable identifier), result-type tags by their English value.
/// Authored content (lesson/word titles, unit names) passes through — only
/// chrome localizes. Matching still runs over the engine's English catalogue;
/// a localized matching index is part of the R-L12 server-index fast-follow.
String ratelSearchDestinationTitle(
        BuildContext context, String route, String fallback) =>
    switch (route) {
      '/practice' => context.l10n.searchDestPracticeHub,
      '/tutor' => context.l10n.searchDestAiTutor,
      '/adventures' => context.l10n.searchDestAdventures,
      '/leagues' => context.l10n.searchDestLeagues,
      '/quests' => context.l10n.searchDestQuests,
      '/progress' => context.l10n.searchDestProgress,
      '/profile' => context.l10n.searchDestProfile,
      '/settings' => context.l10n.searchDestSettings,
      '/shop' => context.l10n.searchDestShop,
      '/notifications' => context.l10n.searchDestNotifications,
      _ => fallback,
    };

String ratelSearchDestinationSubtitle(
        BuildContext context, String route, String fallback) =>
    switch (route) {
      '/practice' => context.l10n.searchDestPracticeHubSub,
      '/tutor' => context.l10n.searchDestAiTutorSub,
      '/adventures' => context.l10n.searchDestAdventuresSub,
      '/leagues' => context.l10n.searchDestLeaguesSub,
      '/quests' => context.l10n.searchDestQuestsSub,
      '/progress' => context.l10n.searchDestProgressSub,
      '/profile' => context.l10n.searchDestProfileSub,
      '/settings' => context.l10n.searchDestSettingsSub,
      '/shop' => context.l10n.searchDestShopSub,
      '/notifications' => context.l10n.searchDestNotificationsSub,
      _ => fallback,
    };

String ratelSearchTag(BuildContext context, String tag) => switch (tag) {
      'Page' => context.l10n.searchTagPage,
      'Word' => context.l10n.searchTagWord,
      _ => tag, // CEFR codes (A1…C2) are locale-independent.
    };
