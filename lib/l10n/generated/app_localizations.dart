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

  /// No description provided for @lessonTypeWhatYouHear.
  ///
  /// In en, this message translates to:
  /// **'Type what you hear'**
  String get lessonTypeWhatYouHear;

  /// No description provided for @lessonTapWhatYouHear.
  ///
  /// In en, this message translates to:
  /// **'Tap what you hear'**
  String get lessonTapWhatYouHear;

  /// No description provided for @lessonTranslateSentence.
  ///
  /// In en, this message translates to:
  /// **'Translate this sentence'**
  String get lessonTranslateSentence;

  /// No description provided for @lessonTypeAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Type your answer…'**
  String get lessonTypeAnswerHint;

  /// No description provided for @lessonWriteAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Write your answer…'**
  String get lessonWriteAnswerHint;

  /// No description provided for @lessonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get lessonContinue;

  /// No description provided for @lessonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get lessonSkip;

  /// No description provided for @lessonCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get lessonCheck;

  /// No description provided for @lessonNicelyDone.
  ///
  /// In en, this message translates to:
  /// **'✓ Nicely done!'**
  String get lessonNicelyDone;

  /// No description provided for @lessonNotQuite.
  ///
  /// In en, this message translates to:
  /// **'✕ Not quite'**
  String get lessonNotQuite;

  /// No description provided for @lessonAnswerReveal.
  ///
  /// In en, this message translates to:
  /// **'Answer: {answer}'**
  String lessonAnswerReveal(String answer);

  /// No description provided for @lessonCompleteKicker.
  ///
  /// In en, this message translates to:
  /// **'LESSON COMPLETE'**
  String get lessonCompleteKicker;

  /// No description provided for @lessonCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson complete!'**
  String get lessonCompleteTitle;

  /// No description provided for @lessonCompleteSummary.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {graded} correct · now {level}'**
  String lessonCompleteSummary(int correct, int graded, String level);

  /// No description provided for @lessonStatTotalXp.
  ///
  /// In en, this message translates to:
  /// **'TOTAL XP'**
  String get lessonStatTotalXp;

  /// No description provided for @lessonStatAccuracy.
  ///
  /// In en, this message translates to:
  /// **'ACCURACY'**
  String get lessonStatAccuracy;

  /// No description provided for @lessonStatTime.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get lessonStatTime;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m Ratel!'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Learn a language the fearless way — bite-sized, fun, and free. Ready to dig in?'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onboardingHaveAccount;

  /// No description provided for @onboardingTryWithoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Try without an account →'**
  String get onboardingTryWithoutAccount;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingStartLearning.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get onboardingStartLearning;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to learn?'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'52 languages available'**
  String get onboardingLanguageSubtitle;

  /// No description provided for @onboardingReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Why are you learning?'**
  String get onboardingReasonTitle;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a daily goal'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingPlacementTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your starting point'**
  String get onboardingPlacementTitle;

  /// No description provided for @onboardingPlacementBody.
  ///
  /// In en, this message translates to:
  /// **'New to {language}, or do you know some already?'**
  String onboardingPlacementBody(String language);

  /// No description provided for @onboardingBrandNew.
  ///
  /// In en, this message translates to:
  /// **'I\'m brand new'**
  String get onboardingBrandNew;

  /// No description provided for @onboardingBrandNewSub.
  ///
  /// In en, this message translates to:
  /// **'Start from the very beginning'**
  String get onboardingBrandNewSub;

  /// No description provided for @onboardingPlacementTest.
  ///
  /// In en, this message translates to:
  /// **'Take a placement test'**
  String get onboardingPlacementTest;

  /// No description provided for @onboardingPlacementTestSub.
  ///
  /// In en, this message translates to:
  /// **'~3 min · skip ahead to your level'**
  String get onboardingPlacementTestSub;

  /// No description provided for @onboardingXpPerDay.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP / day'**
  String onboardingXpPerDay(int xp);

  /// No description provided for @reasonTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get reasonTravel;

  /// No description provided for @reasonCulture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get reasonCulture;

  /// No description provided for @reasonCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get reasonCareer;

  /// No description provided for @reasonFamilyFriends.
  ///
  /// In en, this message translates to:
  /// **'Family & friends'**
  String get reasonFamilyFriends;

  /// No description provided for @reasonBrainTraining.
  ///
  /// In en, this message translates to:
  /// **'Brain training'**
  String get reasonBrainTraining;

  /// No description provided for @reasonJustForFun.
  ///
  /// In en, this message translates to:
  /// **'Just for fun'**
  String get reasonJustForFun;

  /// No description provided for @goalCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get goalCasual;

  /// No description provided for @goalRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get goalRegular;

  /// No description provided for @goalSerious.
  ///
  /// In en, this message translates to:
  /// **'Serious'**
  String get goalSerious;

  /// No description provided for @goalIntense.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get goalIntense;

  /// No description provided for @langNameSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get langNameSpanish;

  /// No description provided for @langNameFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get langNameFrench;

  /// No description provided for @langNameJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get langNameJapanese;

  /// No description provided for @langNameTamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get langNameTamil;

  /// No description provided for @langNameGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get langNameGerman;

  /// No description provided for @langNameKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get langNameKorean;

  /// No description provided for @settingsDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get settingsDailyGoal;

  /// No description provided for @settingsGoalRow.
  ///
  /// In en, this message translates to:
  /// **'{label} · {xp} XP/day'**
  String settingsGoalRow(String label, int xp);

  /// No description provided for @profileAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get profileAchievements;

  /// No description provided for @profileFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get profileFriends;

  /// No description provided for @profileShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get profileShop;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileSeeOnboarding.
  ///
  /// In en, this message translates to:
  /// **'See onboarding flow ↗'**
  String get profileSeeOnboarding;

  /// No description provided for @profileNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get profileNotSignedIn;

  /// No description provided for @profileCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a free account'**
  String get profileCreateAccount;

  /// No description provided for @profileSaveProgress.
  ///
  /// In en, this message translates to:
  /// **'Save your progress across devices'**
  String get profileSaveProgress;

  /// No description provided for @profileTodaysGoal.
  ///
  /// In en, this message translates to:
  /// **'Today\'s goal · {today}/{goal} XP'**
  String profileTodaysGoal(int today, int goal);

  /// No description provided for @profileViewProgress.
  ///
  /// In en, this message translates to:
  /// **'View progress →'**
  String get profileViewProgress;

  /// No description provided for @profileUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get profileUnlocked;

  /// No description provided for @questsResetsIn.
  ///
  /// In en, this message translates to:
  /// **'Resets in {h}h {m}m'**
  String questsResetsIn(int h, int m);

  /// No description provided for @questsDailyRefresh.
  ///
  /// In en, this message translates to:
  /// **'Daily refresh'**
  String get questsDailyRefresh;

  /// No description provided for @questsFreshMix.
  ///
  /// In en, this message translates to:
  /// **'A fresh 5-question mix'**
  String get questsFreshMix;

  /// No description provided for @questsServedFromQueue.
  ///
  /// In en, this message translates to:
  /// **'Served from your real review queue — earns real XP.'**
  String get questsServedFromQueue;

  /// No description provided for @questsGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Daily goal reached! 🎉'**
  String get questsGoalReached;

  /// No description provided for @questsReachGoal.
  ///
  /// In en, this message translates to:
  /// **'Reach {goal} XP today'**
  String questsReachGoal(int goal);

  /// No description provided for @questsDailyQuests.
  ///
  /// In en, this message translates to:
  /// **'Daily quests · {done}/{total}'**
  String questsDailyQuests(int done, int total);

  /// No description provided for @questsInfoNote.
  ///
  /// In en, this message translates to:
  /// **'Quests track your real daily progress. Reward chests, friend quests and a weekly leaderboard need a backend economy — an owner decision (§6). No fake rewards are shown.'**
  String get questsInfoNote;

  /// No description provided for @questsStartRefresh.
  ///
  /// In en, this message translates to:
  /// **'Start the daily refresh'**
  String get questsStartRefresh;

  /// No description provided for @questsStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get questsStart;

  /// No description provided for @questsPractisedToday.
  ///
  /// In en, this message translates to:
  /// **'Practised today — streak safe'**
  String get questsPractisedToday;

  /// No description provided for @questsEarnAnyXp.
  ///
  /// In en, this message translates to:
  /// **'Earn any XP today'**
  String get questsEarnAnyXp;

  /// No description provided for @questsXpToday.
  ///
  /// In en, this message translates to:
  /// **'{current}/{target} XP today'**
  String questsXpToday(int current, int target);

  /// No description provided for @leaguesYourGroup.
  ///
  /// In en, this message translates to:
  /// **'YOUR GROUP'**
  String get leaguesYourGroup;

  /// No description provided for @leaguesThisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK · {size} LEARNERS'**
  String leaguesThisWeek(int size);

  /// No description provided for @leaguesTiers.
  ///
  /// In en, this message translates to:
  /// **'League tiers'**
  String get leaguesTiers;

  /// No description provided for @leaguesTopClimb.
  ///
  /// In en, this message translates to:
  /// **'Top {top} climb each week · ends in {days, plural, one{{days} day} other{{days} days}}'**
  String leaguesTopClimb(int top, int days);

  /// No description provided for @leaguesDemotionZone.
  ///
  /// In en, this message translates to:
  /// **'Demotion zone'**
  String get leaguesDemotionZone;

  /// No description provided for @leaguesPromotionZone.
  ///
  /// In en, this message translates to:
  /// **'Promotion zone'**
  String get leaguesPromotionZone;

  /// No description provided for @leaguesSafeZone.
  ///
  /// In en, this message translates to:
  /// **'Safe zone'**
  String get leaguesSafeZone;

  /// No description provided for @leaguesYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get leaguesYou;

  /// No description provided for @leaguesPromoteRelegate.
  ///
  /// In en, this message translates to:
  /// **'Top {top} promote · bottom {bottom} relegate when the week ends.'**
  String leaguesPromoteRelegate(int top, int bottom);

  /// No description provided for @leaguesYouAreHere.
  ///
  /// In en, this message translates to:
  /// **'You\'re here'**
  String get leaguesYouAreHere;

  /// No description provided for @leaguesViewAllTiers.
  ///
  /// In en, this message translates to:
  /// **'🏆 View all 10 tiers ›'**
  String get leaguesViewAllTiers;

  /// No description provided for @notifMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notifMarkAllRead;

  /// No description provided for @notifEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notifEmptyTitle;

  /// No description provided for @notifEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Finish lessons, build a streak and level up — your milestones will appear here the moment you genuinely earn them.'**
  String get notifEmptyBody;

  /// No description provided for @notifPushNote.
  ///
  /// In en, this message translates to:
  /// **'These are in-app milestones, surfaced the moment you earn them. Push notifications and reminders are an owner decision and not enabled yet — nothing here is faked.'**
  String get notifPushNote;

  /// No description provided for @shopPowerUps.
  ///
  /// In en, this message translates to:
  /// **'Power-ups'**
  String get shopPowerUps;

  /// No description provided for @shopStreakFreeze.
  ///
  /// In en, this message translates to:
  /// **'Streak Freeze'**
  String get shopStreakFreeze;

  /// No description provided for @shopStreakFreezeDesc.
  ///
  /// In en, this message translates to:
  /// **'Protects your streak for one missed day. Spent automatically when you miss your daily goal.'**
  String get shopStreakFreezeDesc;

  /// No description provided for @shopOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned {have}/{max}'**
  String shopOwned(int have, int max);

  /// No description provided for @shopMaxedOut.
  ///
  /// In en, this message translates to:
  /// **'Maxed out'**
  String get shopMaxedOut;

  /// No description provided for @shopBuyFor.
  ///
  /// In en, this message translates to:
  /// **'Buy for {cost} 💎'**
  String shopBuyFor(int cost);

  /// No description provided for @shopFreezeAdded.
  ///
  /// In en, this message translates to:
  /// **'Streak freeze added 💪'**
  String get shopFreezeAdded;

  /// No description provided for @shopFreezeAtCap.
  ///
  /// In en, this message translates to:
  /// **'You already hold the most freezes ({max}).'**
  String shopFreezeAtCap(int max);

  /// No description provided for @shopNotEnoughEarnCost.
  ///
  /// In en, this message translates to:
  /// **'Not enough 💎 — earn {cost} by finishing lessons.'**
  String shopNotEnoughEarnCost(int cost);

  /// No description provided for @shopNotEnoughEarnMore.
  ///
  /// In en, this message translates to:
  /// **'Not enough 💎 — earn more by finishing lessons.'**
  String get shopNotEnoughEarnMore;

  /// No description provided for @shopEnergyRefill.
  ///
  /// In en, this message translates to:
  /// **'Energy Refill'**
  String get shopEnergyRefill;

  /// No description provided for @shopEnergyRefillDesc.
  ///
  /// In en, this message translates to:
  /// **'Top your energy straight back up to full. Energy is display-only — lessons never block.'**
  String get shopEnergyRefillDesc;

  /// No description provided for @shopAlreadyFull.
  ///
  /// In en, this message translates to:
  /// **'Already full'**
  String get shopAlreadyFull;

  /// No description provided for @shopEnergyRefilled.
  ///
  /// In en, this message translates to:
  /// **'Energy refilled ⚡'**
  String get shopEnergyRefilled;

  /// No description provided for @shopEnergyAlreadyFull.
  ///
  /// In en, this message translates to:
  /// **'Your energy is already full.'**
  String get shopEnergyAlreadyFull;

  /// No description provided for @shopStreakRepair.
  ///
  /// In en, this message translates to:
  /// **'Streak Repair'**
  String get shopStreakRepair;

  /// No description provided for @shopStreakRepairDesc.
  ///
  /// In en, this message translates to:
  /// **'Lost your streak? Restore it to its previous length and keep the run going.'**
  String get shopStreakRepairDesc;

  /// No description provided for @shopStreakLapsed.
  ///
  /// In en, this message translates to:
  /// **'Streak lapsed'**
  String get shopStreakLapsed;

  /// No description provided for @shopStreakDays.
  ///
  /// In en, this message translates to:
  /// **'🔥 {days}-day streak'**
  String shopStreakDays(int days);

  /// No description provided for @shopRepairFor.
  ///
  /// In en, this message translates to:
  /// **'Repair for {cost} 💎'**
  String shopRepairFor(int cost);

  /// No description provided for @shopStreakRestored.
  ///
  /// In en, this message translates to:
  /// **'Streak restored 🔥'**
  String get shopStreakRestored;

  /// No description provided for @shopStreakSafe.
  ///
  /// In en, this message translates to:
  /// **'Your streak is safe — nothing to repair right now.'**
  String get shopStreakSafe;

  /// No description provided for @shopDoubleXp.
  ///
  /// In en, this message translates to:
  /// **'Double XP'**
  String get shopDoubleXp;

  /// No description provided for @shopDoubleXpDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn 2× XP from every lesson for 15 minutes.'**
  String get shopDoubleXpDesc;

  /// No description provided for @shopActiveLeft.
  ///
  /// In en, this message translates to:
  /// **'Active · {minutes}m left'**
  String shopActiveLeft(int minutes);

  /// No description provided for @shopInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get shopInactive;

  /// No description provided for @shopActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get shopActive;

  /// No description provided for @shopDoubleXpActive.
  ///
  /// In en, this message translates to:
  /// **'Double XP active ✨'**
  String get shopDoubleXpActive;

  /// No description provided for @shopBoostRunning.
  ///
  /// In en, this message translates to:
  /// **'Your boost is running — XP is doubled.'**
  String get shopBoostRunning;

  /// No description provided for @shopBadgerOutfits.
  ///
  /// In en, this message translates to:
  /// **'Badger outfits'**
  String get shopBadgerOutfits;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'RATEL PRO'**
  String get paywallTitle;

  /// No description provided for @paywallStartTrial.
  ///
  /// In en, this message translates to:
  /// **'Start 7-day free trial'**
  String get paywallStartTrial;

  /// No description provided for @paywallGoPro.
  ///
  /// In en, this message translates to:
  /// **'Go Pro — {price}/mo'**
  String paywallGoPro(String price);

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestore;

  /// No description provided for @paywallHero.
  ///
  /// In en, this message translates to:
  /// **'Live AI tutoring, ad-free, and offline lessons.'**
  String get paywallHero;

  /// No description provided for @paywallAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get paywallAnnual;

  /// No description provided for @paywallMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallMonthly;

  /// No description provided for @paywallTrialHow.
  ///
  /// In en, this message translates to:
  /// **'How the 7-day free trial works'**
  String get paywallTrialHow;

  /// No description provided for @paywallTrialToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get paywallTrialToday;

  /// No description provided for @paywallTrialTodayDesc.
  ///
  /// In en, this message translates to:
  /// **'Full Pro access unlocks. No charge.'**
  String get paywallTrialTodayDesc;

  /// No description provided for @paywallTrialDay5.
  ///
  /// In en, this message translates to:
  /// **'Day 5'**
  String get paywallTrialDay5;

  /// No description provided for @paywallTrialDay5Desc.
  ///
  /// In en, this message translates to:
  /// **'We remind you before the trial ends.'**
  String get paywallTrialDay5Desc;

  /// No description provided for @paywallTrialDay7.
  ///
  /// In en, this message translates to:
  /// **'Day 7'**
  String get paywallTrialDay7;

  /// No description provided for @paywallTrialDay7Desc.
  ///
  /// In en, this message translates to:
  /// **'{price}/yr begins unless you cancel.'**
  String paywallTrialDay7Desc(String price);

  /// No description provided for @paywallFeatureLiveAi.
  ///
  /// In en, this message translates to:
  /// **'Live AI: voice, tutor chat & writing feedback'**
  String get paywallFeatureLiveAi;

  /// No description provided for @paywallFeatureNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads, anywhere'**
  String get paywallFeatureNoAds;

  /// No description provided for @paywallFeatureOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline lessons & audio'**
  String get paywallFeatureOffline;

  /// No description provided for @paywallFeaturePronunciation.
  ///
  /// In en, this message translates to:
  /// **'AI pronunciation coaching tips'**
  String get paywallFeaturePronunciation;

  /// No description provided for @paywallEverythingFree.
  ///
  /// In en, this message translates to:
  /// **'Everything else — all 52 languages, audio, review, leagues, roleplay and on-device pronunciation — stays free for everyone.'**
  String get paywallEverythingFree;

  /// No description provided for @paywallYouArePro.
  ///
  /// In en, this message translates to:
  /// **'You are on RATEL PRO'**
  String get paywallYouArePro;

  /// No description provided for @paywallThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for supporting Ratel. Manage or cancel anytime from Settings → Manage subscription.'**
  String get paywallThanks;

  /// No description provided for @paywallManage.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get paywallManage;

  /// No description provided for @paywallFinePrint.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime in Settings. Prices shown for {regions}; your local price is set by your app store.'**
  String paywallFinePrint(String regions);

  /// No description provided for @questTitlePowerSession.
  ///
  /// In en, this message translates to:
  /// **'Power session'**
  String get questTitlePowerSession;

  /// No description provided for @questDescPowerSession.
  ///
  /// In en, this message translates to:
  /// **'Earn double your daily goal'**
  String get questDescPowerSession;

  /// No description provided for @questTitleOnFire.
  ///
  /// In en, this message translates to:
  /// **'On fire'**
  String get questTitleOnFire;

  /// No description provided for @questDescOnFire.
  ///
  /// In en, this message translates to:
  /// **'Earn triple your daily goal'**
  String get questDescOnFire;

  /// No description provided for @questTitleStreakKeeper.
  ///
  /// In en, this message translates to:
  /// **'Streak keeper'**
  String get questTitleStreakKeeper;

  /// No description provided for @questDescStreakKeeper.
  ///
  /// In en, this message translates to:
  /// **'Practice today to keep your streak'**
  String get questDescStreakKeeper;

  /// No description provided for @notifTitleLessons1.
  ///
  /// In en, this message translates to:
  /// **'First lesson complete'**
  String get notifTitleLessons1;

  /// No description provided for @notifBodyLessons1.
  ///
  /// In en, this message translates to:
  /// **'You finished your first lesson — great start!'**
  String get notifBodyLessons1;

  /// No description provided for @notifTitleLessons5.
  ///
  /// In en, this message translates to:
  /// **'5 lessons done'**
  String get notifTitleLessons5;

  /// No description provided for @notifBodyLessons5.
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed 5 lessons. Keep the momentum going.'**
  String get notifBodyLessons5;

  /// No description provided for @notifTitleLessons10.
  ///
  /// In en, this message translates to:
  /// **'10 lessons done'**
  String get notifTitleLessons10;

  /// No description provided for @notifBodyLessons10.
  ///
  /// In en, this message translates to:
  /// **'Ten lessons in — you are building a real habit.'**
  String get notifBodyLessons10;

  /// No description provided for @notifTitleLessons25.
  ///
  /// In en, this message translates to:
  /// **'25 lessons done'**
  String get notifTitleLessons25;

  /// No description provided for @notifBodyLessons25.
  ///
  /// In en, this message translates to:
  /// **'Twenty-five lessons completed. Impressive dedication!'**
  String get notifBodyLessons25;

  /// No description provided for @notifTitleLessons50.
  ///
  /// In en, this message translates to:
  /// **'50 lessons done'**
  String get notifTitleLessons50;

  /// No description provided for @notifBodyLessons50.
  ///
  /// In en, this message translates to:
  /// **'Fifty lessons — you are well on your way.'**
  String get notifBodyLessons50;

  /// No description provided for @notifTitleStreak3.
  ///
  /// In en, this message translates to:
  /// **'3-day streak!'**
  String get notifTitleStreak3;

  /// No description provided for @notifBodyStreak3.
  ///
  /// In en, this message translates to:
  /// **'Three days in a row. Consistency is everything.'**
  String get notifBodyStreak3;

  /// No description provided for @notifTitleStreak7.
  ///
  /// In en, this message translates to:
  /// **'7-day streak!'**
  String get notifTitleStreak7;

  /// No description provided for @notifBodyStreak7.
  ///
  /// In en, this message translates to:
  /// **'A full week of daily practice. Outstanding!'**
  String get notifBodyStreak7;

  /// No description provided for @notifTitleStreak14.
  ///
  /// In en, this message translates to:
  /// **'14-day streak!'**
  String get notifTitleStreak14;

  /// No description provided for @notifBodyStreak14.
  ///
  /// In en, this message translates to:
  /// **'Two weeks straight — you are unstoppable.'**
  String get notifBodyStreak14;

  /// No description provided for @notifTitleStreak30.
  ///
  /// In en, this message translates to:
  /// **'30-day streak!'**
  String get notifTitleStreak30;

  /// No description provided for @notifBodyStreak30.
  ///
  /// In en, this message translates to:
  /// **'A whole month of daily practice. Incredible.'**
  String get notifBodyStreak30;

  /// No description provided for @notifTitleXp100.
  ///
  /// In en, this message translates to:
  /// **'100 XP earned'**
  String get notifTitleXp100;

  /// No description provided for @notifBodyXp100.
  ///
  /// In en, this message translates to:
  /// **'Your first hundred XP — momentum is building.'**
  String get notifBodyXp100;

  /// No description provided for @notifTitleXp500.
  ///
  /// In en, this message translates to:
  /// **'500 XP earned'**
  String get notifTitleXp500;

  /// No description provided for @notifBodyXp500.
  ///
  /// In en, this message translates to:
  /// **'Five hundred XP. You are putting in the work.'**
  String get notifBodyXp500;

  /// No description provided for @notifTitleXp1000.
  ///
  /// In en, this message translates to:
  /// **'1,000 XP earned'**
  String get notifTitleXp1000;

  /// No description provided for @notifBodyXp1000.
  ///
  /// In en, this message translates to:
  /// **'A thousand XP milestone reached!'**
  String get notifBodyXp1000;

  /// No description provided for @notifTitleXp2500.
  ///
  /// In en, this message translates to:
  /// **'2,500 XP earned'**
  String get notifTitleXp2500;

  /// No description provided for @notifBodyXp2500.
  ///
  /// In en, this message translates to:
  /// **'Twenty-five hundred XP — serious progress.'**
  String get notifBodyXp2500;

  /// No description provided for @notifTitleLevel1.
  ///
  /// In en, this message translates to:
  /// **'Reached level A2'**
  String get notifTitleLevel1;

  /// No description provided for @notifBodyLevel1.
  ///
  /// In en, this message translates to:
  /// **'Your ability grew from A1 to A2. Onward!'**
  String get notifBodyLevel1;

  /// No description provided for @notifTitleLevel2.
  ///
  /// In en, this message translates to:
  /// **'Reached level B1'**
  String get notifTitleLevel2;

  /// No description provided for @notifBodyLevel2.
  ///
  /// In en, this message translates to:
  /// **'You are now an intermediate learner (B1).'**
  String get notifBodyLevel2;

  /// No description provided for @notifTitleLevel3.
  ///
  /// In en, this message translates to:
  /// **'Reached level B2'**
  String get notifTitleLevel3;

  /// No description provided for @notifBodyLevel3.
  ///
  /// In en, this message translates to:
  /// **'Upper-intermediate (B2) reached. Brilliant.'**
  String get notifBodyLevel3;

  /// No description provided for @notifTitleLevel4.
  ///
  /// In en, this message translates to:
  /// **'Reached level C1'**
  String get notifTitleLevel4;

  /// No description provided for @notifBodyLevel4.
  ///
  /// In en, this message translates to:
  /// **'Advanced (C1) — your Spanish is strong.'**
  String get notifBodyLevel4;

  /// No description provided for @notifTitleLevel5.
  ///
  /// In en, this message translates to:
  /// **'Reached level C2'**
  String get notifTitleLevel5;

  /// No description provided for @notifBodyLevel5.
  ///
  /// In en, this message translates to:
  /// **'Proficiency (C2) — the top of the scale!'**
  String get notifBodyLevel5;

  /// No description provided for @achTitleFirstSteps.
  ///
  /// In en, this message translates to:
  /// **'First Steps'**
  String get achTitleFirstSteps;

  /// No description provided for @achTitleScholar.
  ///
  /// In en, this message translates to:
  /// **'Scholar'**
  String get achTitleScholar;

  /// No description provided for @achTitleWildfire.
  ///
  /// In en, this message translates to:
  /// **'Wildfire'**
  String get achTitleWildfire;

  /// No description provided for @achTitlePointMaker.
  ///
  /// In en, this message translates to:
  /// **'Point Maker'**
  String get achTitlePointMaker;

  /// No description provided for @achTitleCollector.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get achTitleCollector;

  /// No description provided for @achTitleRisingStar.
  ///
  /// In en, this message translates to:
  /// **'Rising Star'**
  String get achTitleRisingStar;

  /// No description provided for @leagueTierBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get leagueTierBronze;

  /// No description provided for @leagueTierSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get leagueTierSilver;

  /// No description provided for @leagueTierGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get leagueTierGold;

  /// No description provided for @leagueTierSapphire.
  ///
  /// In en, this message translates to:
  /// **'Sapphire'**
  String get leagueTierSapphire;

  /// No description provided for @leagueTierRuby.
  ///
  /// In en, this message translates to:
  /// **'Ruby'**
  String get leagueTierRuby;

  /// No description provided for @leagueTierEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get leagueTierEmerald;

  /// No description provided for @leagueTierAmethyst.
  ///
  /// In en, this message translates to:
  /// **'Amethyst'**
  String get leagueTierAmethyst;

  /// No description provided for @leagueTierPearl.
  ///
  /// In en, this message translates to:
  /// **'Pearl'**
  String get leagueTierPearl;

  /// No description provided for @leagueTierObsidian.
  ///
  /// In en, this message translates to:
  /// **'Obsidian'**
  String get leagueTierObsidian;

  /// No description provided for @leagueTierDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get leagueTierDiamond;

  /// No description provided for @cefrNameBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get cefrNameBeginner;

  /// No description provided for @cefrNameElementary.
  ///
  /// In en, this message translates to:
  /// **'Elementary'**
  String get cefrNameElementary;

  /// No description provided for @cefrNameIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get cefrNameIntermediate;

  /// No description provided for @cefrNameUpperIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Upper intermediate'**
  String get cefrNameUpperIntermediate;

  /// No description provided for @cefrNameAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get cefrNameAdvanced;

  /// No description provided for @cefrNameProficient.
  ///
  /// In en, this message translates to:
  /// **'Proficient'**
  String get cefrNameProficient;

  /// No description provided for @leaguesTierLeague.
  ///
  /// In en, this message translates to:
  /// **'{tier} League'**
  String leaguesTierLeague(String tier);

  /// No description provided for @leaguesYoureIn.
  ///
  /// In en, this message translates to:
  /// **'You\'re in {tier} · top 7 climb each week'**
  String leaguesYoureIn(String tier);

  /// No description provided for @leaguesZonePromotion.
  ///
  /// In en, this message translates to:
  /// **'⬆ PROMOTION ZONE'**
  String get leaguesZonePromotion;

  /// No description provided for @leaguesZoneDemotion.
  ///
  /// In en, this message translates to:
  /// **'⬇ DEMOTION ZONE'**
  String get leaguesZoneDemotion;

  /// No description provided for @profileAchievementsSummary.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} of {total} unlocked · real progress'**
  String profileAchievementsSummary(int unlocked, int total);

  /// No description provided for @profileRealStateNote.
  ///
  /// In en, this message translates to:
  /// **'Level, XP, lessons, streak and saved words are real engine state — they start at zero on a fresh account.'**
  String get profileRealStateNote;
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
