import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navLeagues.
  ///
  /// In en, this message translates to:
  /// **'Leagues'**
  String get navLeagues;

  /// No description provided for @navQuests.
  ///
  /// In en, this message translates to:
  /// **'Quests'**
  String get navQuests;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get settingsSectionLearning;

  /// No description provided for @settingsSectionSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSectionSubscription;

  /// No description provided for @settingsSectionAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settingsSectionAccessibility;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsSectionAppearanceAccount.
  ///
  /// In en, this message translates to:
  /// **'Appearance & account'**
  String get settingsSectionAppearanceAccount;

  /// No description provided for @settingsAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsAppLanguage;

  /// No description provided for @settingsAppLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsAppLanguageSystem;

  /// No description provided for @homeCourseLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your course is getting ready'**
  String get homeCourseLoadingTitle;

  /// No description provided for @homeCourseLoadingBody.
  ///
  /// In en, this message translates to:
  /// **'Lessons will appear here once your course content loads.'**
  String get homeCourseLoadingBody;

  /// No description provided for @homeGuideChip.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get homeGuideChip;

  /// No description provided for @homeStartNode.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get homeStartNode;

  /// No description provided for @homeUnitGuideHeader.
  ///
  /// In en, this message translates to:
  /// **'UNIT GUIDE'**
  String get homeUnitGuideHeader;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @homeUnitKicker.
  ///
  /// In en, this message translates to:
  /// **'UNIT · {unit}'**
  String homeUnitKicker(String unit);

  /// No description provided for @homeLessonMeta.
  ///
  /// In en, this message translates to:
  /// **'Lesson {num} of {count} · {exercises}.'**
  String homeLessonMeta(int num, int count, String exercises);

  /// No description provided for @homeQuickExercises.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} quick exercise} other{{count} quick exercises}}'**
  String homeQuickExercises(int count);

  /// No description provided for @homeEnergyChip.
  ///
  /// In en, this message translates to:
  /// **'−1 ⚡ energy'**
  String get homeEnergyChip;

  /// No description provided for @homeXpChip.
  ///
  /// In en, this message translates to:
  /// **'+20 XP'**
  String get homeXpChip;

  /// No description provided for @homeStartLesson.
  ///
  /// In en, this message translates to:
  /// **'Start lesson'**
  String get homeStartLesson;

  /// No description provided for @homeTutorChip.
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get homeTutorChip;

  /// No description provided for @libraryAiTutor.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor'**
  String get libraryAiTutor;

  /// No description provided for @libraryAiTutorSub.
  ///
  /// In en, this message translates to:
  /// **'Talk, chat & roleplay — writing feedback'**
  String get libraryAiTutorSub;

  /// No description provided for @libraryRoleplay.
  ///
  /// In en, this message translates to:
  /// **'Roleplay'**
  String get libraryRoleplay;

  /// No description provided for @libraryRoleplaySub.
  ///
  /// In en, this message translates to:
  /// **'Practice replies — graded, always free'**
  String get libraryRoleplaySub;

  /// No description provided for @librarySectionPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get librarySectionPractice;

  /// No description provided for @libraryPracticeHub.
  ///
  /// In en, this message translates to:
  /// **'Practice hub'**
  String get libraryPracticeHub;

  /// No description provided for @libraryPracticeHubSub.
  ///
  /// In en, this message translates to:
  /// **'Mistakes, weak words & drills · FREE'**
  String get libraryPracticeHubSub;

  /// No description provided for @librarySectionReadListen.
  ///
  /// In en, this message translates to:
  /// **'Read & listen'**
  String get librarySectionReadListen;

  /// No description provided for @libraryGradedStories.
  ///
  /// In en, this message translates to:
  /// **'Graded stories'**
  String get libraryGradedStories;

  /// No description provided for @libraryPodcasts.
  ///
  /// In en, this message translates to:
  /// **'Podcasts'**
  String get libraryPodcasts;

  /// No description provided for @libraryWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get libraryWatch;

  /// No description provided for @librarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search lessons, words, stories…'**
  String get librarySearchHint;

  /// No description provided for @libraryFeaturedStory.
  ///
  /// In en, this message translates to:
  /// **'FEATURED · STORY'**
  String get libraryFeaturedStory;

  /// No description provided for @commonLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {cefr}'**
  String commonLevel(String cefr);

  /// No description provided for @libraryReadNow.
  ///
  /// In en, this message translates to:
  /// **'Read now'**
  String get libraryReadNow;

  /// No description provided for @libraryNewExplore.
  ///
  /// In en, this message translates to:
  /// **'NEW · EXPLORE'**
  String get libraryNewExplore;

  /// No description provided for @libraryAdventures.
  ///
  /// In en, this message translates to:
  /// **'Adventures'**
  String get libraryAdventures;

  /// No description provided for @libraryStartExploring.
  ///
  /// In en, this message translates to:
  /// **'Start exploring →'**
  String get libraryStartExploring;

  /// No description provided for @libraryKindStory.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get libraryKindStory;

  /// No description provided for @libraryKindPodcast.
  ///
  /// In en, this message translates to:
  /// **'Podcast'**
  String get libraryKindPodcast;

  /// No description provided for @libraryKindVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get libraryKindVideo;

  /// No description provided for @libraryAllStories.
  ///
  /// In en, this message translates to:
  /// **'All stories'**
  String get libraryAllStories;

  /// No description provided for @libraryAllPodcasts.
  ///
  /// In en, this message translates to:
  /// **'All podcasts'**
  String get libraryAllPodcasts;

  /// No description provided for @libraryAllVideos.
  ///
  /// In en, this message translates to:
  /// **'All videos'**
  String get libraryAllVideos;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
