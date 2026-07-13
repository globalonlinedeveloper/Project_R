import 'package:flutter/widgets.dart';

import 'package:ratel/l10n/generated/app_localizations.dart';
import 'package:ratel/services/auth/auth_service.dart' show AuthFailureCode;
import 'package:ratel/services/live_session/live_session.dart'
    show LiveUnavailableCode;
import 'package:ratel/services/social/friends_service.dart'
    show FriendMessageCode;

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
      'English' => context.l10n.langNameEnglish,
      'Spanish' => context.l10n.langNameSpanish,
      'French' => context.l10n.langNameFrench,
      'Japanese' => context.l10n.langNameJapanese,
      'Tamil' => context.l10n.langNameTamil,
      'German' => context.l10n.langNameGerman,
      'Korean' => context.l10n.langNameKorean,
      _ => englishName,
    };

/// Flag emoji for the active COURSE (the target language being taught),
/// mirroring the Home top-bar. Locale-independent (emoji) so it lives in
/// code; unknown course codes fall back to the badger.
String ratelCourseFlagEmoji(String courseCode) => switch (courseCode) {
  'en' => '\u{1F1EC}\u{1F1E7}',
  'ja' => '\u{1F1EF}\u{1F1F5}',
  'ta' => '\u{1F1EE}\u{1F1F3}',
  _ => '\u{1F9A1}',
};

/// Localized display name for the active COURSE (target language). Course code
/// in, localized language name out; unknown codes pass the upper-cased code
/// through so future courses degrade honestly.
String ratelCourseLanguageName(BuildContext context, String courseCode) =>
    switch (courseCode) {
      'en' => context.l10n.langNameEnglish,
      'es' => context.l10n.langNameSpanish,
      'fr' => context.l10n.langNameFrench,
      'ja' => context.l10n.langNameJapanese,
      'de' => context.l10n.langNameGerman,
      'ko' => context.l10n.langNameKorean,
      _ => courseCode.toUpperCase(),
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
  'hi': 'हिन्दी',
  'zh': '中文',
  'bn': 'বাংলা',
  'pt': 'Português',
  'ru': 'Русский',
  'ja': '日本語',
  'de': 'Deutsch',
  'fr': 'Français',
  'ko': '한국어',
};

/// Flag country + English display metadata for the settings app-language
/// picker (Option A). The endonym (kUiLanguageEndonyms) stays the PRIMARY
/// label; this adds an SVG country flag + an English-name·country subtitle.
/// `country` = ISO-3166 alpha-2 for the flag (rendered as SVG via
/// country_flags — NOT emoji flags, which render broken on Flutter web /
/// Chrome-Windows). Owner-specified country mapping.
const Map<String, ({String country, String english, String countryName})>
kUiLanguageFlag =
    <String, ({String country, String english, String countryName})>{
      'en': (country: 'GB', english: 'English', countryName: 'United Kingdom'),
      'de': (country: 'DE', english: 'German', countryName: 'Germany'),
      'fr': (country: 'FR', english: 'French', countryName: 'France'),
      'hi': (country: 'IN', english: 'Hindi', countryName: 'India'),
      'bn': (country: 'BD', english: 'Bengali', countryName: 'Bangladesh'),
      'ja': (country: 'JP', english: 'Japanese', countryName: 'Japan'),
      'ko': (country: 'KR', english: 'Korean', countryName: 'South Korea'),
      'zh': (country: 'CN', english: 'Chinese', countryName: 'China'),
      'pt': (country: 'PT', english: 'Portuguese', countryName: 'Portugal'),
      'ru': (country: 'RU', english: 'Russian', countryName: 'Russia'),
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
  BuildContext context,
  String id,
  String fallback,
) => switch (id) {
  'power_session' => context.l10n.questDescPowerSession,
  'on_fire' => context.l10n.questDescOnFire,
  'streak_keeper' => context.l10n.questDescStreakKeeper,
  _ => fallback,
};

String ratelNotificationTitle(
  BuildContext context,
  String id,
  String fallback,
) => switch (id) {
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
  BuildContext context,
  String id,
  String fallback,
) => switch (id) {
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
  BuildContext context,
  String id,
  String fallback,
) => switch (id) {
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
  BuildContext context,
  String route,
  String fallback,
) => switch (route) {
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
  BuildContext context,
  String route,
  String fallback,
) => switch (route) {
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

/// Badger-outfit display names (economy/outfits.dart catalogue) localize by id
/// at the render site; unknown ids pass through.
String ratelOutfitName(BuildContext context, String id) => switch (id) {
  'classic' => context.l10n.outfitClassic,
  'scholar' => context.l10n.outfitScholar,
  'explorer' => context.l10n.outfitExplorer,
  'astronaut' => context.l10n.outfitAstronaut,
  'wizard' => context.l10n.outfitWizard,
  _ => id,
};

/// Theme-world display names + vehicles (core/theme/world_registry.dart) localize
/// by world id at the render site; unknown ids pass the id through.
String ratelWorldLabel(BuildContext context, String id) => switch (id) {
  'light' => context.l10n.worldLabelLight,
  'galaxy' => context.l10n.worldLabelGalaxy,
  'savanna' => context.l10n.worldLabelSavanna,
  'ocean' => context.l10n.worldLabelOcean,
  'forest' => context.l10n.worldLabelForest,
  'candy' => context.l10n.worldLabelCandy,
  'neon' => context.l10n.worldLabelNeon,
  'storm' => context.l10n.worldLabelStorm,
  'snow' => context.l10n.worldLabelSnow,
  'sakura' => context.l10n.worldLabelSakura,
  'autumn' => context.l10n.worldLabelAutumn,
  'aurora' => context.l10n.worldLabelAurora,
  'volcano' => context.l10n.worldLabelVolcano,
  'sunset' => context.l10n.worldLabelSunset,
  'desert' => context.l10n.worldLabelDesert,
  'reef' => context.l10n.worldLabelReef,
  'meadow' => context.l10n.worldLabelMeadow,
  'dawn' => context.l10n.worldLabelDawn,
  'beach' => context.l10n.worldLabelBeach,
  'mars' => context.l10n.worldLabelMars,
  'jungle' => context.l10n.worldLabelJungle,
  'cyberrain' => context.l10n.worldLabelCyberrain,
  'abyss' => context.l10n.worldLabelAbyss,
  'alpine' => context.l10n.worldLabelAlpine,
  'lavender' => context.l10n.worldLabelLavender,
  'bamboo' => context.l10n.worldLabelBamboo,
  'lagoon' => context.l10n.worldLabelLagoon,
  'thunder' => context.l10n.worldLabelThunder,
  'nebula' => context.l10n.worldLabelNebula,
  'sandstorm' => context.l10n.worldLabelSandstorm,
  'cherrynight' => context.l10n.worldLabelCherrynight,
  _ => id,
};

String ratelWorldVehicle(BuildContext context, String id) => switch (id) {
  'light' => context.l10n.worldVehicleLight,
  'galaxy' => context.l10n.worldVehicleGalaxy,
  'savanna' => context.l10n.worldVehicleSavanna,
  'ocean' => context.l10n.worldVehicleOcean,
  'forest' => context.l10n.worldVehicleForest,
  'candy' => context.l10n.worldVehicleCandy,
  'neon' => context.l10n.worldVehicleNeon,
  'storm' => context.l10n.worldVehicleStorm,
  'snow' => context.l10n.worldVehicleSnow,
  'sakura' => context.l10n.worldVehicleSakura,
  'autumn' => context.l10n.worldVehicleAutumn,
  'aurora' => context.l10n.worldVehicleAurora,
  'volcano' => context.l10n.worldVehicleVolcano,
  'sunset' => context.l10n.worldVehicleSunset,
  'desert' => context.l10n.worldVehicleDesert,
  'reef' => context.l10n.worldVehicleReef,
  'meadow' => context.l10n.worldVehicleMeadow,
  'dawn' => context.l10n.worldVehicleDawn,
  'beach' => context.l10n.worldVehicleBeach,
  'mars' => context.l10n.worldVehicleMars,
  'jungle' => context.l10n.worldVehicleJungle,
  'cyberrain' => context.l10n.worldVehicleCyberrain,
  'abyss' => context.l10n.worldVehicleAbyss,
  'alpine' => context.l10n.worldVehicleAlpine,
  'lavender' => context.l10n.worldVehicleLavender,
  'bamboo' => context.l10n.worldVehicleBamboo,
  'lagoon' => context.l10n.worldVehicleLagoon,
  'thunder' => context.l10n.worldVehicleThunder,
  'nebula' => context.l10n.worldVehicleNebula,
  'sandstorm' => context.l10n.worldVehicleSandstorm,
  'cherrynight' => context.l10n.worldVehicleCherrynight,
  _ => id,
};

/// Content-player nouns (content_unavailable_card) localize by id at the render
/// site; unknown nouns pass through.
String ratelContentNoun(BuildContext context, String noun) => switch (noun) {
  'story' => context.l10n.contentNounStory,
  'podcast' => context.l10n.contentNounPodcast,
  'video' => context.l10n.contentNounVideo,
  'adventure' => context.l10n.contentNounAdventure,
  'roleplay' => context.l10n.contentNounRoleplay,
  _ => noun,
};

/// Service-error render maps (i18n I4): a service emits a stable,
/// backend-agnostic [code] and the render site maps it → a localized ARB
/// string here — the same split as the notification / quest catalogues. A null
/// code means a dynamic backend / server message that renders verbatim, so
/// these are only invoked when the code is non-null.
String ratelAuthError(BuildContext context, AuthFailureCode code) =>
    switch (code) {
      AuthFailureCode.accountsUnavailable =>
        context.l10n.authAccountsUnavailable,
    };

String ratelLiveError(BuildContext context, LiveUnavailableCode code) =>
    switch (code) {
      LiveUnavailableCode.notEnabled => context.l10n.liveNotEnabledShort,
      LiveUnavailableCode.startFailed => context.l10n.liveStartFailed,
      LiveUnavailableCode.micUnavailable => context.l10n.liveMicUnavailable,
      LiveUnavailableCode.unavailable => context.l10n.liveUnavailable,
      LiveUnavailableCode.needsPro => context.l10n.liveNeedsPro,
      LiveUnavailableCode.minutesUsed => context.l10n.liveMinutesUsed,
    };

String ratelFriendMessage(BuildContext context, FriendMessageCode code) =>
    switch (code) {
      FriendMessageCode.signInForHandle => context.l10n.friendsSignInForHandle,
      FriendMessageCode.handleTaken => context.l10n.friendsHandleTaken,
      FriendMessageCode.handleFormat => context.l10n.friendsHandleFormat,
      FriendMessageCode.networkError => context.l10n.commonNetworkError,
      FriendMessageCode.setOwnHandleFirst =>
        context.l10n.friendsSetOwnHandleFirst,
    };

/// Localized market list for a Pro price band (R-J2 fine print). The band's
/// enum name is the stable id; the English catalogue value is byte-mirrored by
/// the ARB, localized here so the region names translate INSIDE the localized
/// `paywallFinePrint` sentence instead of showing English in every locale.
String ratelProRegions(BuildContext context, String bandName) =>
    switch (bandName) {
      'tier1' => context.l10n.paywallRegionsTier1,
      'mid' => context.l10n.paywallRegionsMid,
      'lowPpp' => context.l10n.paywallRegionsLowPpp,
      _ => context.l10n.paywallRegionsTier1,
    };
