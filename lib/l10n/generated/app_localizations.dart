import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
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
    Locale('bn'),
    Locale('de'),
    Locale('en'),
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

  /// No description provided for @homeSectionN.
  ///
  /// In en, this message translates to:
  /// **'SECTION {n}'**
  String homeSectionN(int n);

  /// No description provided for @homeSectionLevel.
  ///
  /// In en, this message translates to:
  /// **'SECTION {n} · LEVEL {band}'**
  String homeSectionLevel(int n, String band);

  /// No description provided for @homeLevelBand.
  ///
  /// In en, this message translates to:
  /// **'Level {band}'**
  String homeLevelBand(String band);

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
  /// **'Talk · Chat · Roleplay — live with Ratel'**
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

  /// No description provided for @lessonExplainThis.
  ///
  /// In en, this message translates to:
  /// **'💡 Explain this'**
  String get lessonExplainThis;

  /// No description provided for @lessonMatchPairs.
  ///
  /// In en, this message translates to:
  /// **'Match the pairs'**
  String get lessonMatchPairs;

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
  /// **'Learn English from 10 languages'**
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

  /// No description provided for @langNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langNameEnglish;

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
  /// **'Everything else — audio, review, leagues, roleplay and on-device pronunciation — stays free for everyone.'**
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

  /// No description provided for @paywallRegionsTier1.
  ///
  /// In en, this message translates to:
  /// **'US, EU, Japan, Australia'**
  String get paywallRegionsTier1;

  /// No description provided for @paywallRegionsMid.
  ///
  /// In en, this message translates to:
  /// **'Latin America, SE Asia, E. Europe'**
  String get paywallRegionsMid;

  /// No description provided for @paywallRegionsLowPpp.
  ///
  /// In en, this message translates to:
  /// **'India, Pakistan, Nigeria, Bangladesh'**
  String get paywallRegionsLowPpp;

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
  /// **'Advanced (C1) — your English is strong.'**
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

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTitle;

  /// No description provided for @practiceReviewWords.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Review 1 word} other{Review {count} words}}'**
  String practiceReviewWords(int count);

  /// No description provided for @practiceYourWords.
  ///
  /// In en, this message translates to:
  /// **'Your words'**
  String get practiceYourWords;

  /// No description provided for @practiceSavedWordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} saved word} other{{count} saved words}}'**
  String practiceSavedWordsCount(int count);

  /// No description provided for @practiceDueForReview.
  ///
  /// In en, this message translates to:
  /// **'{count} due for spaced review'**
  String practiceDueForReview(int count);

  /// No description provided for @practiceAllUpToDate.
  ///
  /// In en, this message translates to:
  /// **'All reviews up to date'**
  String get practiceAllUpToDate;

  /// No description provided for @practiceCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up — nothing due right now{tail}.'**
  String practiceCaughtUp(String tail);

  /// No description provided for @practiceNextTail.
  ///
  /// In en, this message translates to:
  /// **' · next {when}'**
  String practiceNextTail(String when);

  /// No description provided for @practiceZeroDue.
  ///
  /// In en, this message translates to:
  /// **'0 due'**
  String get practiceZeroDue;

  /// No description provided for @practiceDueNow.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get practiceDueNow;

  /// No description provided for @practiceDueWhen.
  ///
  /// In en, this message translates to:
  /// **'Due {when}'**
  String practiceDueWhen(String when);

  /// No description provided for @practiceChipDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get practiceChipDue;

  /// No description provided for @practiceChipScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get practiceChipScheduled;

  /// No description provided for @practiceScheduleNote.
  ///
  /// In en, this message translates to:
  /// **'Reviews are scheduled by the real FSRS-6 spaced-repetition engine. Due dates persist for this session; saving them across restarts is a go-live step — nothing here is invented.'**
  String get practiceScheduleNote;

  /// No description provided for @practiceNoSavedWords.
  ///
  /// In en, this message translates to:
  /// **'No saved words yet'**
  String get practiceNoSavedWords;

  /// No description provided for @practiceSaveWordHint.
  ///
  /// In en, this message translates to:
  /// **'Save a word while you practice a lesson and it lands here as a flashcard. Reviews are then scheduled by the real FSRS spaced-repetition engine — nothing is pre-filled.'**
  String get practiceSaveWordHint;

  /// No description provided for @practiceStartLesson.
  ///
  /// In en, this message translates to:
  /// **'Start a lesson'**
  String get practiceStartLesson;

  /// No description provided for @practiceWordOf.
  ///
  /// In en, this message translates to:
  /// **'Word {n} of {total}'**
  String practiceWordOf(int n, int total);

  /// No description provided for @practiceShowAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get practiceShowAnswer;

  /// No description provided for @practiceRecallHint.
  ///
  /// In en, this message translates to:
  /// **'Recall the meaning, then grade how well you remembered.'**
  String get practiceRecallHint;

  /// No description provided for @practiceGradeAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get practiceGradeAgain;

  /// No description provided for @practiceGradeHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get practiceGradeHard;

  /// No description provided for @practiceGradeGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get practiceGradeGood;

  /// No description provided for @practiceGradeEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get practiceGradeEasy;

  /// No description provided for @practiceFsrsGradeNote.
  ///
  /// In en, this message translates to:
  /// **'FSRS-6 schedules the next review from your grade'**
  String get practiceFsrsGradeNote;

  /// No description provided for @practiceReviewComplete.
  ///
  /// In en, this message translates to:
  /// **'Review complete'**
  String get practiceReviewComplete;

  /// No description provided for @practiceReviewedSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{You reviewed 1 word. They are rescheduled by FSRS.} other{You reviewed {count} words. They are rescheduled by FSRS.}}'**
  String practiceReviewedSummary(int count);

  /// No description provided for @practiceDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get practiceDone;

  /// No description provided for @practiceRelTomorrow.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get practiceRelTomorrow;

  /// No description provided for @practiceRelInDays.
  ///
  /// In en, this message translates to:
  /// **'in {days} days'**
  String practiceRelInDays(int days);

  /// No description provided for @practiceRelInHours.
  ///
  /// In en, this message translates to:
  /// **'in {hours}h'**
  String practiceRelInHours(int hours);

  /// No description provided for @practiceRelInMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {minutes}m'**
  String practiceRelInMinutes(int minutes);

  /// No description provided for @practiceRelSoon.
  ///
  /// In en, this message translates to:
  /// **'soon'**
  String get practiceRelSoon;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressYourLevel.
  ///
  /// In en, this message translates to:
  /// **'YOUR LEVEL'**
  String get progressYourLevel;

  /// No description provided for @progressShareMilestone.
  ///
  /// In en, this message translates to:
  /// **'Share milestone'**
  String get progressShareMilestone;

  /// No description provided for @progressLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get progressLast7Days;

  /// No description provided for @progressAccuracyRetention.
  ///
  /// In en, this message translates to:
  /// **'Accuracy & retention'**
  String get progressAccuracyRetention;

  /// No description provided for @progressHonestyNote.
  ///
  /// In en, this message translates to:
  /// **'Everything here is real recorded state — level, ability, saved words, XP, lessons, streak, your 7-day history, accuracy and study time all start at zero and grow as you learn. Retention is this session\'s predicted recall (the durable cross-session scheduler is go-live wiring); nothing is invented.'**
  String get progressHonestyNote;

  /// No description provided for @progressShareText.
  ///
  /// In en, this message translates to:
  /// **'🦡 RATEL · Level {level} ({levelName})\n🔥 {streak}-day streak · ⚡ {xp} XP · 📘 {lessons} lessons\nLearning at learnwithratel.com'**
  String progressShareText(
    String level,
    String levelName,
    int streak,
    int xp,
    int lessons,
  );

  /// No description provided for @progressShareCopied.
  ///
  /// In en, this message translates to:
  /// **'Milestone copied to clipboard — share it anywhere!'**
  String get progressShareCopied;

  /// No description provided for @progressAbilityLine.
  ///
  /// In en, this message translates to:
  /// **'Ability θ {theta} · real estimate'**
  String progressAbilityLine(String theta);

  /// No description provided for @progressStatSavedWords.
  ///
  /// In en, this message translates to:
  /// **'Saved words'**
  String get progressStatSavedWords;

  /// No description provided for @progressStatLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get progressStatLessons;

  /// No description provided for @progressStatDayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get progressStatDayStreak;

  /// No description provided for @progressStatTotalXp.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get progressStatTotalXp;

  /// No description provided for @progressStatTodaysXp.
  ///
  /// In en, this message translates to:
  /// **'Today\'s XP'**
  String get progressStatTodaysXp;

  /// No description provided for @progressStatCefrLevel.
  ///
  /// In en, this message translates to:
  /// **'CEFR level'**
  String get progressStatCefrLevel;

  /// No description provided for @progressAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get progressAccuracy;

  /// No description provided for @progressStudyTime.
  ///
  /// In en, this message translates to:
  /// **'Study time'**
  String get progressStudyTime;

  /// No description provided for @progressRetention.
  ///
  /// In en, this message translates to:
  /// **'Retention'**
  String get progressRetention;

  /// No description provided for @progressNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get progressNoData;

  /// No description provided for @progressAccuracyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Answer graded exercises to start'**
  String get progressAccuracyEmpty;

  /// No description provided for @progressAccuracyDetail.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct'**
  String progressAccuracyDetail(int correct, int total);

  /// No description provided for @progressTimeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Time in lessons adds up here'**
  String get progressTimeEmpty;

  /// No description provided for @progressTimeDetail.
  ///
  /// In en, this message translates to:
  /// **'across all your lessons'**
  String get progressTimeDetail;

  /// No description provided for @progressRetentionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Review items to see predicted recall'**
  String get progressRetentionEmpty;

  /// No description provided for @progressRetentionDetail.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{predicted 1-day recall · 1 item this session} other{predicted 1-day recall · {count} items this session}}'**
  String progressRetentionDetail(int count);

  /// No description provided for @progressWeekTotal.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP · last 7 days'**
  String progressWeekTotal(int xp);

  /// No description provided for @progressNoXpYet.
  ///
  /// In en, this message translates to:
  /// **'No XP recorded yet'**
  String get progressNoXpYet;

  /// No description provided for @progressChartEmptyNote.
  ///
  /// In en, this message translates to:
  /// **'Finish a lesson to start your 7-day history — inactive days stay at zero, nothing is invented.'**
  String get progressChartEmptyNote;

  /// No description provided for @commonDowMon.
  ///
  /// In en, this message translates to:
  /// **'Mo'**
  String get commonDowMon;

  /// No description provided for @commonDowTue.
  ///
  /// In en, this message translates to:
  /// **'Tu'**
  String get commonDowTue;

  /// No description provided for @commonDowWed.
  ///
  /// In en, this message translates to:
  /// **'We'**
  String get commonDowWed;

  /// No description provided for @commonDowThu.
  ///
  /// In en, this message translates to:
  /// **'Th'**
  String get commonDowThu;

  /// No description provided for @commonDowFri.
  ///
  /// In en, this message translates to:
  /// **'Fr'**
  String get commonDowFri;

  /// No description provided for @commonDowSat.
  ///
  /// In en, this message translates to:
  /// **'Sa'**
  String get commonDowSat;

  /// No description provided for @commonDowSun.
  ///
  /// In en, this message translates to:
  /// **'Su'**
  String get commonDowSun;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search lessons, words, stories…'**
  String get searchHint;

  /// No description provided for @searchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get searchRecent;

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClear;

  /// No description provided for @searchJumpTo.
  ///
  /// In en, this message translates to:
  /// **'Jump to'**
  String get searchJumpTo;

  /// No description provided for @searchTagPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get searchTagPage;

  /// No description provided for @searchTagWord.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get searchTagWord;

  /// No description provided for @searchSubtitleSavedWord.
  ///
  /// In en, this message translates to:
  /// **'Saved word'**
  String get searchSubtitleSavedWord;

  /// No description provided for @searchLessonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{unit} · Lesson'**
  String searchLessonSubtitle(String unit);

  /// No description provided for @searchNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches for “{query}”'**
  String searchNoMatches(String query);

  /// No description provided for @searchEmptyNote.
  ///
  /// In en, this message translates to:
  /// **'Searching titles, tags and lesson content across your course, saved words and pages. A server content index and trending are the remaining R-L12 fast-follow — nothing here is faked.'**
  String get searchEmptyNote;

  /// No description provided for @searchNoMatchNote.
  ///
  /// In en, this message translates to:
  /// **'Searches your published course lessons, saved words and app pages (titles + tags). Stories/podcasts and full-text are the R-L12 fast-follow — never faked.'**
  String get searchNoMatchNote;

  /// No description provided for @searchFooterNote.
  ///
  /// In en, this message translates to:
  /// **'Titles + tags at launch. Full-text, stories/podcasts and multi-course scope are the R-L12 fast-follow — never faked.'**
  String get searchFooterNote;

  /// No description provided for @searchDestPracticeHub.
  ///
  /// In en, this message translates to:
  /// **'Practice hub'**
  String get searchDestPracticeHub;

  /// No description provided for @searchDestPracticeHubSub.
  ///
  /// In en, this message translates to:
  /// **'Mistakes, weak words & drills'**
  String get searchDestPracticeHubSub;

  /// No description provided for @searchDestAiTutor.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor'**
  String get searchDestAiTutor;

  /// No description provided for @searchDestAiTutorSub.
  ///
  /// In en, this message translates to:
  /// **'Talk, chat & roleplay'**
  String get searchDestAiTutorSub;

  /// No description provided for @searchDestAdventures.
  ///
  /// In en, this message translates to:
  /// **'Adventures'**
  String get searchDestAdventures;

  /// No description provided for @searchDestAdventuresSub.
  ///
  /// In en, this message translates to:
  /// **'Real conversations — free'**
  String get searchDestAdventuresSub;

  /// No description provided for @searchDestLeagues.
  ///
  /// In en, this message translates to:
  /// **'Leagues'**
  String get searchDestLeagues;

  /// No description provided for @searchDestLeaguesSub.
  ///
  /// In en, this message translates to:
  /// **'Your weekly league'**
  String get searchDestLeaguesSub;

  /// No description provided for @searchDestQuests.
  ///
  /// In en, this message translates to:
  /// **'Quests'**
  String get searchDestQuests;

  /// No description provided for @searchDestQuestsSub.
  ///
  /// In en, this message translates to:
  /// **'Daily goals & quests'**
  String get searchDestQuestsSub;

  /// No description provided for @searchDestProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get searchDestProgress;

  /// No description provided for @searchDestProgressSub.
  ///
  /// In en, this message translates to:
  /// **'Your stats & streak'**
  String get searchDestProgressSub;

  /// No description provided for @searchDestProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get searchDestProfile;

  /// No description provided for @searchDestProfileSub.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get searchDestProfileSub;

  /// No description provided for @searchDestSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get searchDestSettings;

  /// No description provided for @searchDestSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Account & preferences'**
  String get searchDestSettingsSub;

  /// No description provided for @searchDestShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get searchDestShop;

  /// No description provided for @searchDestShopSub.
  ///
  /// In en, this message translates to:
  /// **'Spend your diamonds'**
  String get searchDestShopSub;

  /// No description provided for @searchDestNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get searchDestNotifications;

  /// No description provided for @searchDestNotificationsSub.
  ///
  /// In en, this message translates to:
  /// **'Your milestone inbox'**
  String get searchDestNotificationsSub;

  /// No description provided for @themesTitle.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themesTitle;

  /// No description provided for @themesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restyles the whole app — tap to preview live'**
  String get themesSubtitle;

  /// No description provided for @themesVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle · {vehicle}'**
  String themesVehicle(String vehicle);

  /// No description provided for @tutorHeader.
  ///
  /// In en, this message translates to:
  /// **'Practice a real conversation'**
  String get tutorHeader;

  /// No description provided for @tutorHeaderSub.
  ///
  /// In en, this message translates to:
  /// **'Pick a scene and chat with Ratel — no wrong answers, just practice.'**
  String get tutorHeaderSub;

  /// No description provided for @tutorTalkTitle.
  ///
  /// In en, this message translates to:
  /// **'Talk to Ratel'**
  String get tutorTalkTitle;

  /// No description provided for @tutorTalkSub.
  ///
  /// In en, this message translates to:
  /// **'Live voice & video speaking practice'**
  String get tutorTalkSub;

  /// No description provided for @tutorChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat with Ratel'**
  String get tutorChatTitle;

  /// No description provided for @tutorChatSub.
  ///
  /// In en, this message translates to:
  /// **'AI chat · writing feedback'**
  String get tutorChatSub;

  /// No description provided for @tutorRoleplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Roleplay scenes'**
  String get tutorRoleplayTitle;

  /// No description provided for @tutorRoleplayGuided.
  ///
  /// In en, this message translates to:
  /// **'Guided roleplay conversations'**
  String get tutorRoleplayGuided;

  /// No description provided for @tutorScenesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} scenes'**
  String tutorScenesCount(int count);

  /// No description provided for @tutorUnlockPro.
  ///
  /// In en, this message translates to:
  /// **'Unlock RATEL PRO'**
  String get tutorUnlockPro;

  /// No description provided for @tutorRelayNote.
  ///
  /// In en, this message translates to:
  /// **'Live AI tutoring runs on a moderated, cost-guarded relay and is a RATEL PRO feature. Replies are never simulated — a mode starts only once PRO and the relay are both active.'**
  String get tutorRelayNote;

  /// No description provided for @tutorStatusReadyPro.
  ///
  /// In en, this message translates to:
  /// **'PRO active and the live tutor is connected — pick a mode to begin.'**
  String get tutorStatusReadyPro;

  /// No description provided for @tutorStatusReadyFree.
  ///
  /// In en, this message translates to:
  /// **'The live tutor is connected. Live tutoring is a RATEL PRO feature.'**
  String get tutorStatusReadyFree;

  /// No description provided for @tutorStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'The moderated live tutor is not connected in this build yet — live tutoring turns on in a later step. Nothing below is simulated.'**
  String get tutorStatusOffline;

  /// No description provided for @tutorAnnounceNeedsPro.
  ///
  /// In en, this message translates to:
  /// **'RATEL PRO unlocks live AI tutoring.'**
  String get tutorAnnounceNeedsPro;

  /// No description provided for @tutorAnnounceNeedsRelay.
  ///
  /// In en, this message translates to:
  /// **'AI tutoring connects once the moderated relay is enabled.'**
  String get tutorAnnounceNeedsRelay;

  /// No description provided for @tutorAnnounceStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting your session…'**
  String get tutorAnnounceStarting;

  /// No description provided for @adventuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Adventures'**
  String get adventuresTitle;

  /// No description provided for @adventuresFreeChip.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get adventuresFreeChip;

  /// No description provided for @adventuresHeaderSub.
  ///
  /// In en, this message translates to:
  /// **'Explore a world · talk your way through'**
  String get adventuresHeaderSub;

  /// No description provided for @adventuresHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a place and dive in'**
  String get adventuresHeroTitle;

  /// No description provided for @adventuresHeroSub.
  ///
  /// In en, this message translates to:
  /// **'Every scene is a real conversation — no wrong answers, and it\'s always free.'**
  String get adventuresHeroSub;

  /// No description provided for @adventuresFallbackWorld.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get adventuresFallbackWorld;

  /// No description provided for @adventureSheetKicker.
  ///
  /// In en, this message translates to:
  /// **'🗺️ ADVENTURE · {cefr}'**
  String adventureSheetKicker(String cefr);

  /// No description provided for @adventureScenesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} scenes'**
  String adventureScenesCount(int count);

  /// No description provided for @adventureChoicePoints.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} choice point} other{{count} choice points}}'**
  String adventureChoicePoints(int count);

  /// No description provided for @adventureOpeningScene.
  ///
  /// In en, this message translates to:
  /// **'OPENING SCENE'**
  String get adventureOpeningScene;

  /// No description provided for @adventureStart.
  ///
  /// In en, this message translates to:
  /// **'Start adventure'**
  String get adventureStart;

  /// No description provided for @adventurePlayerFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get adventurePlayerFallbackTitle;

  /// No description provided for @adventureTheEnd.
  ///
  /// In en, this message translates to:
  /// **'🏁 The End'**
  String get adventureTheEnd;

  /// No description provided for @adventureStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get adventureStartOver;

  /// No description provided for @adventureDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get adventureDone;

  /// No description provided for @adventureCompleteKicker.
  ///
  /// In en, this message translates to:
  /// **'ADVENTURE COMPLETE'**
  String get adventureCompleteKicker;

  /// No description provided for @adventureCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'{title} ✓'**
  String adventureCompleteTitle(String title);

  /// No description provided for @adventureCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Nicely done! +15 XP · +5 💎 earned — explore the next scene whenever you like.'**
  String get adventureCompleteBody;

  /// No description provided for @adventureDistrictProgress.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} explored'**
  String adventureDistrictProgress(int done, int total);

  /// No description provided for @adventureDistrictDone.
  ///
  /// In en, this message translates to:
  /// **'✓ Done'**
  String get adventureDistrictDone;

  /// No description provided for @adventuresEmpty.
  ///
  /// In en, this message translates to:
  /// **'No adventures in this course yet.'**
  String get adventuresEmpty;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Ratel'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lessons, stories, podcasts and more —\npick how you want to start.'**
  String get authWelcomeSubtitle;

  /// No description provided for @authCreateFreeAccount.
  ///
  /// In en, this message translates to:
  /// **'Create free account'**
  String get authCreateFreeAccount;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authSettingUp.
  ///
  /// In en, this message translates to:
  /// **'Setting things up…'**
  String get authSettingUp;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get authContinueAsGuest;

  /// No description provided for @authGuestNote.
  ///
  /// In en, this message translates to:
  /// **'Guest progress lives on this device — create a free account any time in Settings to keep it everywhere.'**
  String get authGuestNote;

  /// No description provided for @authEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEnterYourEmail;

  /// No description provided for @authEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authEnterValidEmail;

  /// No description provided for @authEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authEnterYourPassword;

  /// No description provided for @authCouldNotSignIn.
  ///
  /// In en, this message translates to:
  /// **'Could not sign you in. Please try again.'**
  String get authCouldNotSignIn;

  /// No description provided for @authSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authSomethingWentWrong;

  /// No description provided for @authSocialComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Social sign-in (Google / Apple) is coming soon.'**
  String get authSocialComingSoon;

  /// No description provided for @authResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get authResetTitle;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get authWelcomeBack;

  /// No description provided for @authResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send a reset link.'**
  String get authResetSubtitle;

  /// No description provided for @authPickUpWhereYouLeft.
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off'**
  String get authPickUpWhereYouLeft;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authSendResetLink;

  /// No description provided for @authLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogIn;

  /// No description provided for @authBackToLogIn.
  ///
  /// In en, this message translates to:
  /// **'Back to log in'**
  String get authBackToLogIn;

  /// No description provided for @authNewToRatel.
  ///
  /// In en, this message translates to:
  /// **'New to Ratel? '**
  String get authNewToRatel;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// No description provided for @authCheckYourInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get authCheckYourInbox;

  /// No description provided for @authResetSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a password-reset link to {email}. Open it to choose a new password.'**
  String authResetSent(String email);

  /// No description provided for @authCreatePassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get authCreatePassword;

  /// No description provided for @authAtLeast8Chars.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authAtLeast8Chars;

  /// No description provided for @authCreateYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authCreateYourAccount;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free forever · learn English from 10 languages'**
  String get authSignupSubtitle;

  /// No description provided for @authPassword8Hint.
  ///
  /// In en, this message translates to:
  /// **'Password (8+ characters)'**
  String get authPassword8Hint;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authAlreadyAccountLead.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authAlreadyAccountLead;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authConfirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get authConfirmEmail;

  /// No description provided for @authConfirmSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a confirmation link to {email}. Tap it to activate your account, then come back to log in.'**
  String authConfirmSent(String email);

  /// No description provided for @authContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueGoogle;

  /// No description provided for @authContinueApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueApple;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authUnavailableNote.
  ///
  /// In en, this message translates to:
  /// **'Accounts aren’t available in this build yet — you can keep learning as a guest. Sign-in turns on when the backend is configured.'**
  String get authUnavailableNote;

  /// No description provided for @liveMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get liveMute;

  /// No description provided for @liveUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get liveUnmute;

  /// No description provided for @commonDurSeconds.
  ///
  /// In en, this message translates to:
  /// **'{s}s'**
  String commonDurSeconds(int s);

  /// No description provided for @commonDurMinutes.
  ///
  /// In en, this message translates to:
  /// **'{m}m'**
  String commonDurMinutes(int m);

  /// No description provided for @commonDurHours.
  ///
  /// In en, this message translates to:
  /// **'{h}h'**
  String commonDurHours(int h);

  /// No description provided for @commonDurHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String commonDurHoursMinutes(int h, int m);

  /// No description provided for @practiceGradeInterval.
  ///
  /// In en, this message translates to:
  /// **'{label} · {days}d'**
  String practiceGradeInterval(String label, int days);

  /// No description provided for @settingsGoalPerDay.
  ///
  /// In en, this message translates to:
  /// **'{goal} XP per day'**
  String settingsGoalPerDay(int goal);

  /// No description provided for @settingsGoalReachedSub.
  ///
  /// In en, this message translates to:
  /// **'{goal} XP per day · ✓ reached today'**
  String settingsGoalReachedSub(int goal);

  /// No description provided for @settingsSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get settingsSoundEffects;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get settingsHaptics;

  /// No description provided for @settingsProActive.
  ///
  /// In en, this message translates to:
  /// **'RATEL PRO active'**
  String get settingsProActive;

  /// No description provided for @settingsFreePlan.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get settingsFreePlan;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReduceMotion;

  /// No description provided for @settingsReduceMotionSub.
  ///
  /// In en, this message translates to:
  /// **'Master switch — turns off every animation'**
  String get settingsReduceMotionSub;

  /// No description provided for @settingsHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get settingsHighContrast;

  /// No description provided for @settingsNotifPush.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get settingsNotifPush;

  /// No description provided for @settingsNotifStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak reminders'**
  String get settingsNotifStreak;

  /// No description provided for @settingsNotifLeague.
  ///
  /// In en, this message translates to:
  /// **'League updates'**
  String get settingsNotifLeague;

  /// No description provided for @settingsNotifFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend activity'**
  String get settingsNotifFriend;

  /// No description provided for @settingsNotifFootnote.
  ///
  /// In en, this message translates to:
  /// **'Your choices are saved now — delivery switches on when push notifications ship.'**
  String get settingsNotifFootnote;

  /// No description provided for @settingsCourse.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get settingsCourse;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsWorld.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get settingsWorld;

  /// No description provided for @settingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get settingsEditProfile;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get settingsPrivacy;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get settingsHelp;

  /// No description provided for @settingsLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogOut;

  /// No description provided for @settingsGuestSub.
  ///
  /// In en, this message translates to:
  /// **'You are learning as a guest — sign up to save progress'**
  String get settingsGuestSub;

  /// No description provided for @settingsCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String settingsCouldNotOpen(String url);

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'Match device'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @mediaReadAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get mediaReadAloud;

  /// No description provided for @mediaTranscript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get mediaTranscript;

  /// No description provided for @mediaCheckUnderstanding.
  ///
  /// In en, this message translates to:
  /// **'Check understanding'**
  String get mediaCheckUnderstanding;

  /// No description provided for @mediaChecksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} comprehension check} other{{count} comprehension checks}}'**
  String mediaChecksCount(int count);

  /// No description provided for @mediaLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get mediaLoading;

  /// No description provided for @mediaPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get mediaPause;

  /// No description provided for @storiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get storiesTitle;

  /// No description provided for @storiesSub.
  ///
  /// In en, this message translates to:
  /// **'Read & listen — graded stories with browser read-aloud.'**
  String get storiesSub;

  /// No description provided for @storiesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No stories in this course yet.'**
  String get storiesEmpty;

  /// No description provided for @storyFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get storyFallbackTitle;

  /// No description provided for @podcastsSub.
  ///
  /// In en, this message translates to:
  /// **'Listen -- graded podcasts with real audio and a transcript.'**
  String get podcastsSub;

  /// No description provided for @podcastsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No podcasts in this course yet.'**
  String get podcastsEmpty;

  /// No description provided for @podcastFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Podcast'**
  String get podcastFallbackTitle;

  /// No description provided for @podcastPlayEpisode.
  ///
  /// In en, this message translates to:
  /// **'Play episode'**
  String get podcastPlayEpisode;

  /// No description provided for @watchSub.
  ///
  /// In en, this message translates to:
  /// **'Watch -- short clips with a transcript and comprehension checks.'**
  String get watchSub;

  /// No description provided for @watchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No watch lessons in this course yet.'**
  String get watchEmpty;

  /// No description provided for @watchWebOnly.
  ///
  /// In en, this message translates to:
  /// **'Video plays in the web app'**
  String get watchWebOnly;

  /// No description provided for @libraryAdventuresSub.
  ///
  /// In en, this message translates to:
  /// **'Walk a living world and talk your way through real scenes.'**
  String get libraryAdventuresSub;

  /// No description provided for @roleplaySub.
  ///
  /// In en, this message translates to:
  /// **'Practice real conversations -- pick the right reply, get instant feedback.'**
  String get roleplaySub;

  /// No description provided for @roleplayEmpty.
  ///
  /// In en, this message translates to:
  /// **'No roleplays in this course yet.'**
  String get roleplayEmpty;

  /// No description provided for @roleplayCatEveryday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get roleplayCatEveryday;

  /// No description provided for @roleplayCatTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get roleplayCatTravel;

  /// No description provided for @roleplayCatWorkStudy.
  ///
  /// In en, this message translates to:
  /// **'Work & Study'**
  String get roleplayCatWorkStudy;

  /// No description provided for @roleplayCatSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get roleplayCatSocial;

  /// No description provided for @roleplayCatHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get roleplayCatHealth;

  /// No description provided for @roleplaySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search scenes…'**
  String get roleplaySearchHint;

  /// No description provided for @roleplayYourReply.
  ///
  /// In en, this message translates to:
  /// **'Your reply:'**
  String get roleplayYourReply;

  /// No description provided for @roleplaySceneComplete.
  ///
  /// In en, this message translates to:
  /// **'🎉 Scene complete!'**
  String get roleplaySceneComplete;

  /// No description provided for @roleplayBack.
  ///
  /// In en, this message translates to:
  /// **'Back to roleplays'**
  String get roleplayBack;

  /// No description provided for @liveRoleplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Roleplay'**
  String get liveRoleplayTitle;

  /// No description provided for @liveRoleplayCardSub.
  ///
  /// In en, this message translates to:
  /// **'Talk it out with Ratel — real voice'**
  String get liveRoleplayCardSub;

  /// No description provided for @liveIntro.
  ///
  /// In en, this message translates to:
  /// **'Talk it out with Ratel — live voice roleplay. Pick a scene, or just have a conversation.'**
  String get liveIntro;

  /// No description provided for @liveFreeConversation.
  ///
  /// In en, this message translates to:
  /// **'Free conversation'**
  String get liveFreeConversation;

  /// No description provided for @liveFreeConversationSub.
  ///
  /// In en, this message translates to:
  /// **'No script — just talk'**
  String get liveFreeConversationSub;

  /// No description provided for @liveRoleplayScene.
  ///
  /// In en, this message translates to:
  /// **'Roleplay a scene'**
  String get liveRoleplayScene;

  /// No description provided for @liveReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get liveReconnecting;

  /// No description provided for @liveConnectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection lost — the live session dropped.'**
  String get liveConnectionLost;

  /// No description provided for @liveReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get liveReconnect;

  /// No description provided for @liveConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get liveConnecting;

  /// No description provided for @liveStartTalking.
  ///
  /// In en, this message translates to:
  /// **'Start talking'**
  String get liveStartTalking;

  /// No description provided for @liveSceneEndedNote.
  ///
  /// In en, this message translates to:
  /// **'Scene ended. Start again whenever you like — your live minutes are budgeted, never silent.'**
  String get liveSceneEndedNote;

  /// No description provided for @liveStartAgain.
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get liveStartAgain;

  /// No description provided for @liveProGate.
  ///
  /// In en, this message translates to:
  /// **'Live voice roleplay is a RATEL PRO feature — real conversation, live feedback, cost-guarded minutes.'**
  String get liveProGate;

  /// No description provided for @liveUnlockPro.
  ///
  /// In en, this message translates to:
  /// **'Unlock RATEL PRO'**
  String get liveUnlockPro;

  /// No description provided for @liveNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Live voice is not enabled in this build yet — it turns on in a later step. Nothing here is simulated.'**
  String get liveNotEnabled;

  /// No description provided for @livePhaseIdle.
  ///
  /// In en, this message translates to:
  /// **'Ready when you are — it’s a real live call.'**
  String get livePhaseIdle;

  /// No description provided for @livePhaseListening.
  ///
  /// In en, this message translates to:
  /// **'Listening — your turn.'**
  String get livePhaseListening;

  /// No description provided for @livePhaseSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Ratel is speaking — jump in any time.'**
  String get livePhaseSpeaking;

  /// No description provided for @livePhaseClosed.
  ///
  /// In en, this message translates to:
  /// **'Scene ended.'**
  String get livePhaseClosed;

  /// No description provided for @liveEndScene.
  ///
  /// In en, this message translates to:
  /// **'End scene'**
  String get liveEndScene;

  /// No description provided for @liveYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get liveYou;

  /// No description provided for @liveTutorName.
  ///
  /// In en, this message translates to:
  /// **'Ratel'**
  String get liveTutorName;

  /// No description provided for @liveTutorRole.
  ///
  /// In en, this message translates to:
  /// **'Ratel · Tutor'**
  String get liveTutorRole;

  /// No description provided for @liveHd.
  ///
  /// In en, this message translates to:
  /// **'HD'**
  String get liveHd;

  /// No description provided for @liveSpeakingIndicator.
  ///
  /// In en, this message translates to:
  /// **'speaking…'**
  String get liveSpeakingIndicator;

  /// No description provided for @liveIdleIndicator.
  ///
  /// In en, this message translates to:
  /// **'ready'**
  String get liveIdleIndicator;

  /// No description provided for @liveGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! I’m Ratel, your tutor. Ready to practice?'**
  String get liveGreeting;

  /// No description provided for @liveQuickReplyReady.
  ///
  /// In en, this message translates to:
  /// **'Yes, let’s go!'**
  String get liveQuickReplyReady;

  /// No description provided for @liveQuickReplyNervous.
  ///
  /// In en, this message translates to:
  /// **'A little nervous'**
  String get liveQuickReplyNervous;

  /// No description provided for @liveVideoOn.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get liveVideoOn;

  /// No description provided for @liveVideoOff.
  ///
  /// In en, this message translates to:
  /// **'Camera off'**
  String get liveVideoOff;

  /// No description provided for @liveCaptionsOn.
  ///
  /// In en, this message translates to:
  /// **'Captions'**
  String get liveCaptionsOn;

  /// No description provided for @liveCaptionsOff.
  ///
  /// In en, this message translates to:
  /// **'Captions off'**
  String get liveCaptionsOff;

  /// No description provided for @liveEndCall.
  ///
  /// In en, this message translates to:
  /// **'End call'**
  String get liveEndCall;

  /// No description provided for @liveCameraGated.
  ///
  /// In en, this message translates to:
  /// **'Live camera isn’t part of this build — nothing is faked. When it turns on, your self-view goes here.'**
  String get liveCameraGated;

  /// No description provided for @liveCaptionsGated.
  ///
  /// In en, this message translates to:
  /// **'Live captions appear here once the real voice engine is on — no transcript is invented.'**
  String get liveCaptionsGated;

  /// No description provided for @liveConnectPrompt.
  ///
  /// In en, this message translates to:
  /// **'This is the call screen. The live voice engine isn’t connected in this build, so nothing you say is answered yet — no reply is ever simulated.'**
  String get liveConnectPrompt;

  /// No description provided for @liveGreetingNote.
  ///
  /// In en, this message translates to:
  /// **'This is Ratel’s scripted opener — the greeting, not a live reply.'**
  String get liveGreetingNote;

  /// No description provided for @liveStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start the live session — try again.'**
  String get liveStartFailed;

  /// No description provided for @friendsHandleInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a handle like @mia (2–20 letters, numbers, _).'**
  String get friendsHandleInvalid;

  /// No description provided for @friendsAlreadyConnected.
  ///
  /// In en, this message translates to:
  /// **'You already have a connection with @{handle}.'**
  String friendsAlreadyConnected(String handle);

  /// No description provided for @friendsRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get friendsRequests;

  /// No description provided for @friendsYourFriends.
  ///
  /// In en, this message translates to:
  /// **'Your friends'**
  String get friendsYourFriends;

  /// No description provided for @friendsPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get friendsPending;

  /// No description provided for @friendsActivity.
  ///
  /// In en, this message translates to:
  /// **'Friend activity'**
  String get friendsActivity;

  /// No description provided for @friendsFootnote.
  ///
  /// In en, this message translates to:
  /// **'Your social graph is real and private to you. Friend requests are delivered, and \"passed you\" appears, once the durable cross-user graph goes live — the same go-live step as every other durable counter. Nothing here is faked.'**
  String get friendsFootnote;

  /// No description provided for @friendsAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add a friend by @handle…'**
  String get friendsAddHint;

  /// No description provided for @friendsAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get friendsAccept;

  /// No description provided for @friendsXpThisWeek.
  ///
  /// In en, this message translates to:
  /// **'@{handle} · {xp} XP this week'**
  String friendsXpThisWeek(String handle, String xp);

  /// No description provided for @friendsPassedYou.
  ///
  /// In en, this message translates to:
  /// **'Passed you'**
  String get friendsPassedYou;

  /// No description provided for @friendsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get friendsRemove;

  /// No description provided for @friendsBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get friendsBlock;

  /// No description provided for @friendsReportBlock.
  ///
  /// In en, this message translates to:
  /// **'Report & block'**
  String get friendsReportBlock;

  /// No description provided for @friendsRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get friendsRequestSent;

  /// No description provided for @friendsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get friendsEmptyTitle;

  /// No description provided for @friendsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add someone by their @handle to start sharing progress.'**
  String get friendsEmptyBody;

  /// No description provided for @profileLearner.
  ///
  /// In en, this message translates to:
  /// **'Learner'**
  String get profileLearner;

  /// No description provided for @profileGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuest;

  /// No description provided for @editProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get editProfileSaved;

  /// No description provided for @editProfileHandleSet.
  ///
  /// In en, this message translates to:
  /// **'Saved — your @handle is set.'**
  String get editProfileHandleSet;

  /// No description provided for @editProfileSignInForHandle.
  ///
  /// In en, this message translates to:
  /// **'Name saved. Sign in to claim your @handle.'**
  String get editProfileSignInForHandle;

  /// No description provided for @editProfileHandleFailed.
  ///
  /// In en, this message translates to:
  /// **'That @handle could not be set.'**
  String get editProfileHandleFailed;

  /// No description provided for @editProfileDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get editProfileDisplayName;

  /// No description provided for @editProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'How should we greet you?'**
  String get editProfileNameHint;

  /// No description provided for @editProfileNameNote.
  ///
  /// In en, this message translates to:
  /// **'Shown on your profile. Saved on this device — it syncs to your account when you sign in.'**
  String get editProfileNameNote;

  /// No description provided for @editProfileHandle.
  ///
  /// In en, this message translates to:
  /// **'Your @handle'**
  String get editProfileHandle;

  /// No description provided for @editProfileHandleNote.
  ///
  /// In en, this message translates to:
  /// **'Other learners add you by your @handle (2–20 letters, numbers or _). Claiming it needs you to be signed in.'**
  String get editProfileHandleNote;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @feedIsNowYourFriend.
  ///
  /// In en, this message translates to:
  /// **'is now your friend'**
  String get feedIsNowYourFriend;

  /// No description provided for @feedReachedLevel.
  ///
  /// In en, this message translates to:
  /// **'reached {level}'**
  String feedReachedLevel(String level);

  /// No description provided for @feedDayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String feedDayStreak(int count);

  /// No description provided for @feedPassedYou.
  ///
  /// In en, this message translates to:
  /// **'passed you in your league'**
  String get feedPassedYou;

  /// No description provided for @leaguesSoloCaption.
  ///
  /// In en, this message translates to:
  /// **'this week · solo group'**
  String get leaguesSoloCaption;

  /// No description provided for @leaguesXpToRank.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to rank {rank}'**
  String leaguesXpToRank(int xp, int rank);

  /// No description provided for @leaguesLeading.
  ///
  /// In en, this message translates to:
  /// **'leading your group'**
  String get leaguesLeading;

  /// No description provided for @leaguesSoloNote.
  ///
  /// In en, this message translates to:
  /// **'You\'re the only learner in your group this week. Real rivals join as Ratel grows — no bots, no fake leaderboards. Keep earning XP to be ready to climb when the week resets.'**
  String get leaguesSoloNote;

  /// No description provided for @questsGoalLine.
  ///
  /// In en, this message translates to:
  /// **'{today} / {goal} XP · goal reached'**
  String questsGoalLine(int today, int goal);

  /// No description provided for @questsGoalRemaining.
  ///
  /// In en, this message translates to:
  /// **'{today} / {goal} XP · {remaining} XP to go'**
  String questsGoalRemaining(int today, int goal, int remaining);

  /// No description provided for @worldLabelLight.
  ///
  /// In en, this message translates to:
  /// **'Daylight'**
  String get worldLabelLight;

  /// No description provided for @worldVehicleLight.
  ///
  /// In en, this message translates to:
  /// **'Scooter'**
  String get worldVehicleLight;

  /// No description provided for @worldLabelGalaxy.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get worldLabelGalaxy;

  /// No description provided for @worldVehicleGalaxy.
  ///
  /// In en, this message translates to:
  /// **'Star pod'**
  String get worldVehicleGalaxy;

  /// No description provided for @worldLabelSavanna.
  ///
  /// In en, this message translates to:
  /// **'Savanna'**
  String get worldLabelSavanna;

  /// No description provided for @worldVehicleSavanna.
  ///
  /// In en, this message translates to:
  /// **'Safari jeep'**
  String get worldVehicleSavanna;

  /// No description provided for @worldLabelOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get worldLabelOcean;

  /// No description provided for @worldVehicleOcean.
  ///
  /// In en, this message translates to:
  /// **'Submarine'**
  String get worldVehicleOcean;

  /// No description provided for @worldLabelForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get worldLabelForest;

  /// No description provided for @worldVehicleForest.
  ///
  /// In en, this message translates to:
  /// **'Leaf glider'**
  String get worldVehicleForest;

  /// No description provided for @worldLabelCandy.
  ///
  /// In en, this message translates to:
  /// **'Candy'**
  String get worldLabelCandy;

  /// No description provided for @worldVehicleCandy.
  ///
  /// In en, this message translates to:
  /// **'Balloon'**
  String get worldVehicleCandy;

  /// No description provided for @worldLabelNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon City'**
  String get worldLabelNeon;

  /// No description provided for @worldVehicleNeon.
  ///
  /// In en, this message translates to:
  /// **'Hover-bike'**
  String get worldVehicleNeon;

  /// No description provided for @worldLabelStorm.
  ///
  /// In en, this message translates to:
  /// **'Rainstorm'**
  String get worldLabelStorm;

  /// No description provided for @worldVehicleStorm.
  ///
  /// In en, this message translates to:
  /// **'Storm glider'**
  String get worldVehicleStorm;

  /// No description provided for @worldLabelSnow.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get worldLabelSnow;

  /// No description provided for @worldVehicleSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow sled'**
  String get worldVehicleSnow;

  /// No description provided for @worldLabelSakura.
  ///
  /// In en, this message translates to:
  /// **'Cherry Blossom'**
  String get worldLabelSakura;

  /// No description provided for @worldVehicleSakura.
  ///
  /// In en, this message translates to:
  /// **'Petal kite'**
  String get worldVehicleSakura;

  /// No description provided for @worldLabelAutumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get worldLabelAutumn;

  /// No description provided for @worldVehicleAutumn.
  ///
  /// In en, this message translates to:
  /// **'Leaf-cart'**
  String get worldVehicleAutumn;

  /// No description provided for @worldLabelAurora.
  ///
  /// In en, this message translates to:
  /// **'Aurora'**
  String get worldLabelAurora;

  /// No description provided for @worldVehicleAurora.
  ///
  /// In en, this message translates to:
  /// **'Aurora skiff'**
  String get worldVehicleAurora;

  /// No description provided for @worldLabelVolcano.
  ///
  /// In en, this message translates to:
  /// **'Volcano'**
  String get worldLabelVolcano;

  /// No description provided for @worldVehicleVolcano.
  ///
  /// In en, this message translates to:
  /// **'Magma board'**
  String get worldVehicleVolcano;

  /// No description provided for @worldLabelSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get worldLabelSunset;

  /// No description provided for @worldVehicleSunset.
  ///
  /// In en, this message translates to:
  /// **'Glider'**
  String get worldVehicleSunset;

  /// No description provided for @worldLabelDesert.
  ///
  /// In en, this message translates to:
  /// **'Desert'**
  String get worldLabelDesert;

  /// No description provided for @worldVehicleDesert.
  ///
  /// In en, this message translates to:
  /// **'Dune buggy'**
  String get worldVehicleDesert;

  /// No description provided for @worldLabelReef.
  ///
  /// In en, this message translates to:
  /// **'Coral Reef'**
  String get worldLabelReef;

  /// No description provided for @worldVehicleReef.
  ///
  /// In en, this message translates to:
  /// **'Glass boat'**
  String get worldVehicleReef;

  /// No description provided for @worldLabelMeadow.
  ///
  /// In en, this message translates to:
  /// **'Meadow'**
  String get worldLabelMeadow;

  /// No description provided for @worldVehicleMeadow.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get worldVehicleMeadow;

  /// No description provided for @worldLabelDawn.
  ///
  /// In en, this message translates to:
  /// **'Dawn'**
  String get worldLabelDawn;

  /// No description provided for @worldVehicleDawn.
  ///
  /// In en, this message translates to:
  /// **'Sky balloon'**
  String get worldVehicleDawn;

  /// No description provided for @worldLabelBeach.
  ///
  /// In en, this message translates to:
  /// **'Tropical Beach'**
  String get worldLabelBeach;

  /// No description provided for @worldVehicleBeach.
  ///
  /// In en, this message translates to:
  /// **'Catamaran'**
  String get worldVehicleBeach;

  /// No description provided for @worldLabelMars.
  ///
  /// In en, this message translates to:
  /// **'Mars'**
  String get worldLabelMars;

  /// No description provided for @worldVehicleMars.
  ///
  /// In en, this message translates to:
  /// **'Rover'**
  String get worldVehicleMars;

  /// No description provided for @worldLabelJungle.
  ///
  /// In en, this message translates to:
  /// **'Rainforest'**
  String get worldLabelJungle;

  /// No description provided for @worldVehicleJungle.
  ///
  /// In en, this message translates to:
  /// **'Zipline'**
  String get worldVehicleJungle;

  /// No description provided for @worldLabelCyberrain.
  ///
  /// In en, this message translates to:
  /// **'Cyber Rain'**
  String get worldLabelCyberrain;

  /// No description provided for @worldVehicleCyberrain.
  ///
  /// In en, this message translates to:
  /// **'Hover-bike'**
  String get worldVehicleCyberrain;

  /// No description provided for @worldLabelAbyss.
  ///
  /// In en, this message translates to:
  /// **'Deep Sea'**
  String get worldLabelAbyss;

  /// No description provided for @worldVehicleAbyss.
  ///
  /// In en, this message translates to:
  /// **'Bathysphere'**
  String get worldVehicleAbyss;

  /// No description provided for @worldLabelAlpine.
  ///
  /// In en, this message translates to:
  /// **'Alpine'**
  String get worldLabelAlpine;

  /// No description provided for @worldVehicleAlpine.
  ///
  /// In en, this message translates to:
  /// **'Cable car'**
  String get worldVehicleAlpine;

  /// No description provided for @worldLabelLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get worldLabelLavender;

  /// No description provided for @worldVehicleLavender.
  ///
  /// In en, this message translates to:
  /// **'Vespa'**
  String get worldVehicleLavender;

  /// No description provided for @worldLabelBamboo.
  ///
  /// In en, this message translates to:
  /// **'Bamboo Grove'**
  String get worldLabelBamboo;

  /// No description provided for @worldVehicleBamboo.
  ///
  /// In en, this message translates to:
  /// **'Rickshaw'**
  String get worldVehicleBamboo;

  /// No description provided for @worldLabelLagoon.
  ///
  /// In en, this message translates to:
  /// **'Lagoon Night'**
  String get worldLabelLagoon;

  /// No description provided for @worldVehicleLagoon.
  ///
  /// In en, this message translates to:
  /// **'Kayak'**
  String get worldVehicleLagoon;

  /// No description provided for @worldLabelThunder.
  ///
  /// In en, this message translates to:
  /// **'Thunderhead'**
  String get worldLabelThunder;

  /// No description provided for @worldVehicleThunder.
  ///
  /// In en, this message translates to:
  /// **'Storm chaser'**
  String get worldVehicleThunder;

  /// No description provided for @worldLabelNebula.
  ///
  /// In en, this message translates to:
  /// **'Nebula'**
  String get worldLabelNebula;

  /// No description provided for @worldVehicleNebula.
  ///
  /// In en, this message translates to:
  /// **'Star cruiser'**
  String get worldVehicleNebula;

  /// No description provided for @worldLabelSandstorm.
  ///
  /// In en, this message translates to:
  /// **'Sandstorm'**
  String get worldLabelSandstorm;

  /// No description provided for @worldVehicleSandstorm.
  ///
  /// In en, this message translates to:
  /// **'Caravan'**
  String get worldVehicleSandstorm;

  /// No description provided for @worldLabelCherrynight.
  ///
  /// In en, this message translates to:
  /// **'Cherry Night'**
  String get worldLabelCherrynight;

  /// No description provided for @worldVehicleCherrynight.
  ///
  /// In en, this message translates to:
  /// **'Paper lantern'**
  String get worldVehicleCherrynight;

  /// No description provided for @shopYourBadger.
  ///
  /// In en, this message translates to:
  /// **'Your badger'**
  String get shopYourBadger;

  /// No description provided for @shopDiamondsNote.
  ///
  /// In en, this message translates to:
  /// **'A real-money 💎 top-up is coming. Diamonds are earned by finishing lessons and meeting your daily goal, and every power-up here spends them for real — nothing is faked.'**
  String get shopDiamondsNote;

  /// No description provided for @shopProBannerSub.
  ///
  /// In en, this message translates to:
  /// **'Live AI, no ads, offline · Try 7 days free'**
  String get shopProBannerSub;

  /// No description provided for @shopYourDiamonds.
  ///
  /// In en, this message translates to:
  /// **'Your diamonds'**
  String get shopYourDiamonds;

  /// No description provided for @shopEquipped.
  ///
  /// In en, this message translates to:
  /// **'Equipped'**
  String get shopEquipped;

  /// No description provided for @shopEquip.
  ///
  /// In en, this message translates to:
  /// **'Equip'**
  String get shopEquip;

  /// No description provided for @shopEquippedSnack.
  ///
  /// In en, this message translates to:
  /// **'Equipped {name} {emoji}'**
  String shopEquippedSnack(String name, String emoji);

  /// No description provided for @shopFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get shopFree;

  /// No description provided for @outfitClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get outfitClassic;

  /// No description provided for @outfitScholar.
  ///
  /// In en, this message translates to:
  /// **'Scholar'**
  String get outfitScholar;

  /// No description provided for @outfitExplorer.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get outfitExplorer;

  /// No description provided for @outfitAstronaut.
  ///
  /// In en, this message translates to:
  /// **'Astronaut'**
  String get outfitAstronaut;

  /// No description provided for @outfitWizard.
  ///
  /// In en, this message translates to:
  /// **'Wizard'**
  String get outfitWizard;

  /// No description provided for @paywallAnnualLine.
  ///
  /// In en, this message translates to:
  /// **'{annual}/yr  ·  {perMonth}/mo  ·  7 days free'**
  String paywallAnnualLine(String annual, String perMonth);

  /// No description provided for @paywallMonthlyLine.
  ///
  /// In en, this message translates to:
  /// **'{monthly}/mo  ·  billed monthly'**
  String paywallMonthlyLine(String monthly);

  /// No description provided for @paywallSavePercent.
  ///
  /// In en, this message translates to:
  /// **'SAVE {percent}%'**
  String paywallSavePercent(int percent);

  /// No description provided for @paywallIncluded.
  ///
  /// In en, this message translates to:
  /// **'What\'s included with Pro'**
  String get paywallIncluded;

  /// No description provided for @paywallTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get paywallTerms;

  /// No description provided for @paywallPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get paywallPrivacy;

  /// No description provided for @paywallNothingToRestore.
  ///
  /// In en, this message translates to:
  /// **'Nothing to restore — billing isn\'t live in this build yet.'**
  String get paywallNothingToRestore;

  /// No description provided for @contentUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Content unavailable'**
  String get contentUnavailableTitle;

  /// No description provided for @contentUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This {noun} is not available right now. If you are offline, check your connection and try again.'**
  String contentUnavailableBody(String noun);

  /// No description provided for @contentNounStory.
  ///
  /// In en, this message translates to:
  /// **'story'**
  String get contentNounStory;

  /// No description provided for @contentNounPodcast.
  ///
  /// In en, this message translates to:
  /// **'podcast'**
  String get contentNounPodcast;

  /// No description provided for @contentNounVideo.
  ///
  /// In en, this message translates to:
  /// **'video'**
  String get contentNounVideo;

  /// No description provided for @contentNounAdventure.
  ///
  /// In en, this message translates to:
  /// **'adventure'**
  String get contentNounAdventure;

  /// No description provided for @contentNounRoleplay.
  ///
  /// In en, this message translates to:
  /// **'roleplay'**
  String get contentNounRoleplay;

  /// No description provided for @commonGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get commonGoBack;

  /// No description provided for @placementTitle.
  ///
  /// In en, this message translates to:
  /// **'Placement test'**
  String get placementTitle;

  /// No description provided for @placementQuestionN.
  ///
  /// In en, this message translates to:
  /// **'Question {n}'**
  String placementQuestionN(int n);

  /// No description provided for @placementResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your starting point'**
  String get placementResultTitle;

  /// No description provided for @placementResultBody.
  ///
  /// In en, this message translates to:
  /// **'Based on {count} questions, we placed you at {level}. You can always adjust later.'**
  String placementResultBody(int count, String level);

  /// No description provided for @lessonTypedNote.
  ///
  /// In en, this message translates to:
  /// **'Type your answer in the target language.'**
  String get lessonTypedNote;

  /// No description provided for @lessonHintMinWords.
  ///
  /// In en, this message translates to:
  /// **'at least {count} words'**
  String lessonHintMinWords(int count);

  /// No description provided for @lessonHintUseWords.
  ///
  /// In en, this message translates to:
  /// **'use: {words}'**
  String lessonHintUseWords(String words);

  /// No description provided for @lessonHintEndPunct.
  ///
  /// In en, this message translates to:
  /// **'end with . ! or ?'**
  String get lessonHintEndPunct;

  /// No description provided for @lessonPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Play audio'**
  String get lessonPlayAudio;

  /// No description provided for @lessonPlaySlowly.
  ///
  /// In en, this message translates to:
  /// **'Play slowly'**
  String get lessonPlaySlowly;

  /// No description provided for @lessonAudioUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Audio unavailable — read the prompt.'**
  String get lessonAudioUnavailable;

  /// No description provided for @lessonPlaybackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get lessonPlaybackSpeed;

  /// No description provided for @authAccountsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Accounts are not available in this build yet — keep learning as a guest.'**
  String get authAccountsUnavailable;

  /// No description provided for @liveNotEnabledShort.
  ///
  /// In en, this message translates to:
  /// **'live AI is not enabled in this build.'**
  String get liveNotEnabledShort;

  /// No description provided for @liveMicUnavailable.
  ///
  /// In en, this message translates to:
  /// **'microphone unavailable — allow mic access to talk with the tutor.'**
  String get liveMicUnavailable;

  /// No description provided for @liveUnavailable.
  ///
  /// In en, this message translates to:
  /// **'live AI is unavailable right now.'**
  String get liveUnavailable;

  /// No description provided for @liveNeedsPro.
  ///
  /// In en, this message translates to:
  /// **'Live AI is part of RATEL PRO.'**
  String get liveNeedsPro;

  /// No description provided for @liveMinutesUsed.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used this month\'s live minutes.'**
  String get liveMinutesUsed;

  /// No description provided for @commonNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Try again.'**
  String get commonNetworkError;

  /// No description provided for @friendsHandleTaken.
  ///
  /// In en, this message translates to:
  /// **'That @handle is already taken.'**
  String get friendsHandleTaken;

  /// No description provided for @friendsHandleFormat.
  ///
  /// In en, this message translates to:
  /// **'Use 2–20 letters, numbers or _ for your handle.'**
  String get friendsHandleFormat;

  /// No description provided for @friendsSignInForHandle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to claim your @handle.'**
  String get friendsSignInForHandle;

  /// No description provided for @friendsSetOwnHandleFirst.
  ///
  /// In en, this message translates to:
  /// **'Set your own @handle first (Edit profile).'**
  String get friendsSetOwnHandleFirst;

  /// No description provided for @paywallCheckoutUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Checkout opens at launch — store billing isn\'t live in this build yet.'**
  String get paywallCheckoutUnavailable;

  /// No description provided for @settingsManageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Manage or cancel in your device\'s Subscriptions settings — the in-app shortcut opens at launch.'**
  String get settingsManageUnavailable;

  /// No description provided for @friendsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get friendsAdd;

  /// No description provided for @practiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always free · never costs energy'**
  String get practiceSubtitle;

  /// No description provided for @practiceSkillStrength.
  ///
  /// In en, this message translates to:
  /// **'Skill strength'**
  String get practiceSkillStrength;

  /// No description provided for @practiceSkillVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get practiceSkillVocabulary;

  /// No description provided for @practiceSkillListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get practiceSkillListening;

  /// No description provided for @practiceSkillGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get practiceSkillGrammar;

  /// No description provided for @practiceSkillSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get practiceSkillSpeaking;

  /// No description provided for @practiceSkillNoData.
  ///
  /// In en, this message translates to:
  /// **'Per-skill strength builds as you practice — no score is shown until the engine has your real signal. Nothing here is invented.'**
  String get practiceSkillNoData;

  /// No description provided for @practiceStatWordsLearned.
  ///
  /// In en, this message translates to:
  /// **'Words learned'**
  String get practiceStatWordsLearned;

  /// No description provided for @practiceStatThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week XP'**
  String get practiceStatThisWeek;

  /// No description provided for @practiceStatAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get practiceStatAccuracy;

  /// No description provided for @practiceStatEmptyValue.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get practiceStatEmptyValue;

  /// No description provided for @practiceDrillMistakesTitle.
  ///
  /// In en, this message translates to:
  /// **'Mistakes review'**
  String get practiceDrillMistakesTitle;

  /// No description provided for @practiceDrillMistakesSub.
  ///
  /// In en, this message translates to:
  /// **'Redo the questions you got wrong'**
  String get practiceDrillMistakesSub;

  /// No description provided for @practiceDrillWeakTitle.
  ///
  /// In en, this message translates to:
  /// **'Weak words'**
  String get practiceDrillWeakTitle;

  /// No description provided for @practiceDrillWeakSub.
  ///
  /// In en, this message translates to:
  /// **'Strengthen fading memories'**
  String get practiceDrillWeakSub;

  /// No description provided for @practiceDrillListeningTitle.
  ///
  /// In en, this message translates to:
  /// **'Listening drill'**
  String get practiceDrillListeningTitle;

  /// No description provided for @practiceDrillListeningSub.
  ///
  /// In en, this message translates to:
  /// **'Train your ear'**
  String get practiceDrillListeningSub;

  /// No description provided for @practiceDrillSpeakingTitle.
  ///
  /// In en, this message translates to:
  /// **'Speaking drill'**
  String get practiceDrillSpeakingTitle;

  /// No description provided for @practiceDrillSpeakingSub.
  ///
  /// In en, this message translates to:
  /// **'Shadow native audio'**
  String get practiceDrillSpeakingSub;

  /// No description provided for @practiceDrillRoleplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Roleplay drill'**
  String get practiceDrillRoleplayTitle;

  /// No description provided for @practiceDrillRoleplaySub.
  ///
  /// In en, this message translates to:
  /// **'Scripted conversations · always free'**
  String get practiceDrillRoleplaySub;

  /// No description provided for @practiceDrillMyWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Words'**
  String get practiceDrillMyWordsTitle;

  /// No description provided for @practiceDrillMyWordsSub.
  ///
  /// In en, this message translates to:
  /// **'Saved words · search, relearn & listen'**
  String get practiceDrillMyWordsSub;

  /// No description provided for @practiceDrillWritingTitle.
  ///
  /// In en, this message translates to:
  /// **'Guided writing'**
  String get practiceDrillWritingTitle;

  /// No description provided for @practiceDrillWritingSub.
  ///
  /// In en, this message translates to:
  /// **'Build sentences · rule-checked, free'**
  String get practiceDrillWritingSub;

  /// No description provided for @practiceSmartReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart review'**
  String get practiceSmartReviewTitle;

  /// No description provided for @practiceSmartReviewSub.
  ///
  /// In en, this message translates to:
  /// **'Adaptive mix of everything you\'re forgetting'**
  String get practiceSmartReviewSub;

  /// No description provided for @practiceDrillEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to review yet'**
  String get practiceDrillEmptyTitle;

  /// No description provided for @practiceDrillEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'This drill draws on your real practice history. As you complete lessons and reviews, {drill} fills up here — nothing is pre-filled or faked.'**
  String practiceDrillEmptyBody(Object drill);

  /// No description provided for @practiceDrillComingNote.
  ///
  /// In en, this message translates to:
  /// **'The dedicated {drill} exercise plugs in at go-live. Until then this stays an honest empty state — it never shows a made-up exercise.'**
  String practiceDrillComingNote(Object drill);

  /// No description provided for @practiceSmartReviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your adaptive queue is empty — complete a lesson or save a word and the Smart review mix will draw from your real due items.'**
  String get practiceSmartReviewEmpty;

  /// No description provided for @practiceBackToHub.
  ///
  /// In en, this message translates to:
  /// **'Back to Practice'**
  String get practiceBackToHub;
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
    'bn',
    'de',
    'en',
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
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
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
