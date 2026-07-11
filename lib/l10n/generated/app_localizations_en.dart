// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navLeagues => 'Leagues';

  @override
  String get navQuests => 'Quests';

  @override
  String get navProfile => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionLearning => 'Learning';

  @override
  String get settingsSectionSubscription => 'Subscription';

  @override
  String get settingsSectionAccessibility => 'Accessibility';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsSectionAppearanceAccount => 'Appearance & account';

  @override
  String get settingsAppLanguage => 'App language';

  @override
  String get settingsAppLanguageSystem => 'System default';

  @override
  String get homeCourseLoadingTitle => 'Your course is getting ready';

  @override
  String get homeCourseLoadingBody =>
      'Lessons will appear here once your course content loads.';

  @override
  String get homeGuideChip => 'Guide';

  @override
  String get homeStartNode => 'START';

  @override
  String get homeUnitGuideHeader => 'UNIT GUIDE';

  @override
  String get commonDone => 'Done';

  @override
  String homeUnitKicker(String unit) {
    return 'UNIT · $unit';
  }

  @override
  String homeLessonMeta(int num, int count, String exercises) {
    return 'Lesson $num of $count · $exercises.';
  }

  @override
  String homeQuickExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quick exercises',
      one: '$count quick exercise',
    );
    return '$_temp0';
  }

  @override
  String get homeEnergyChip => '−1 ⚡ energy';

  @override
  String get homeXpChip => '+20 XP';

  @override
  String get homeStartLesson => 'Start lesson';

  @override
  String get homeTutorChip => 'Tutor';

  @override
  String get libraryAiTutor => 'AI Tutor';

  @override
  String get libraryAiTutorSub => 'Talk, chat & roleplay — writing feedback';

  @override
  String get libraryRoleplay => 'Roleplay';

  @override
  String get libraryRoleplaySub => 'Practice replies — graded, always free';

  @override
  String get librarySectionPractice => 'Practice';

  @override
  String get libraryPracticeHub => 'Practice hub';

  @override
  String get libraryPracticeHubSub => 'Mistakes, weak words & drills · FREE';

  @override
  String get librarySectionReadListen => 'Read & listen';

  @override
  String get libraryGradedStories => 'Graded stories';

  @override
  String get libraryPodcasts => 'Podcasts';

  @override
  String get libraryWatch => 'Watch';

  @override
  String get librarySearchHint => 'Search lessons, words, stories…';

  @override
  String get libraryFeaturedStory => 'FEATURED · STORY';

  @override
  String commonLevel(String cefr) {
    return 'Level $cefr';
  }

  @override
  String get libraryReadNow => 'Read now';

  @override
  String get libraryNewExplore => 'NEW · EXPLORE';

  @override
  String get libraryAdventures => 'Adventures';

  @override
  String get libraryStartExploring => 'Start exploring →';

  @override
  String get libraryKindStory => 'Story';

  @override
  String get libraryKindPodcast => 'Podcast';

  @override
  String get libraryKindVideo => 'Video';

  @override
  String get libraryAllStories => 'All stories';

  @override
  String get libraryAllPodcasts => 'All podcasts';

  @override
  String get libraryAllVideos => 'All videos';

  @override
  String get lessonTypeWhatYouHear => 'Type what you hear';

  @override
  String get lessonTapWhatYouHear => 'Tap what you hear';

  @override
  String get lessonTranslateSentence => 'Translate this sentence';

  @override
  String get lessonTypeAnswerHint => 'Type your answer…';

  @override
  String get lessonWriteAnswerHint => 'Write your answer…';

  @override
  String get lessonContinue => 'Continue';

  @override
  String get lessonSkip => 'Skip';

  @override
  String get lessonCheck => 'Check';

  @override
  String get lessonNicelyDone => '✓ Nicely done!';

  @override
  String get lessonNotQuite => '✕ Not quite';

  @override
  String lessonAnswerReveal(String answer) {
    return 'Answer: $answer';
  }

  @override
  String get lessonCompleteKicker => 'LESSON COMPLETE';

  @override
  String get lessonCompleteTitle => 'Lesson complete!';

  @override
  String lessonCompleteSummary(int correct, int graded, String level) {
    return '$correct of $graded correct · now $level';
  }

  @override
  String get lessonStatTotalXp => 'TOTAL XP';

  @override
  String get lessonStatAccuracy => 'ACCURACY';

  @override
  String get lessonStatTime => 'TIME';

  @override
  String get onboardingWelcomeTitle => 'Hi, I\'m Ratel!';

  @override
  String get onboardingWelcomeBody =>
      'Learn a language the fearless way — bite-sized, fun, and free. Ready to dig in?';

  @override
  String get onboardingHaveAccount => 'I already have an account';

  @override
  String get onboardingTryWithoutAccount => 'Try without an account →';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingStartLearning => 'Start learning';

  @override
  String get onboardingLanguageTitle => 'What do you want to learn?';

  @override
  String get onboardingLanguageSubtitle => '52 languages available';

  @override
  String get onboardingReasonTitle => 'Why are you learning?';

  @override
  String get onboardingGoalTitle => 'Pick a daily goal';

  @override
  String get onboardingPlacementTitle => 'Find your starting point';

  @override
  String onboardingPlacementBody(String language) {
    return 'New to $language, or do you know some already?';
  }

  @override
  String get onboardingBrandNew => 'I\'m brand new';

  @override
  String get onboardingBrandNewSub => 'Start from the very beginning';

  @override
  String get onboardingPlacementTest => 'Take a placement test';

  @override
  String get onboardingPlacementTestSub => '~3 min · skip ahead to your level';

  @override
  String onboardingXpPerDay(int xp) {
    return '$xp XP / day';
  }

  @override
  String get reasonTravel => 'Travel';

  @override
  String get reasonCulture => 'Culture';

  @override
  String get reasonCareer => 'Career';

  @override
  String get reasonFamilyFriends => 'Family & friends';

  @override
  String get reasonBrainTraining => 'Brain training';

  @override
  String get reasonJustForFun => 'Just for fun';

  @override
  String get goalCasual => 'Casual';

  @override
  String get goalRegular => 'Regular';

  @override
  String get goalSerious => 'Serious';

  @override
  String get goalIntense => 'Intense';

  @override
  String get langNameSpanish => 'Spanish';

  @override
  String get langNameFrench => 'French';

  @override
  String get langNameJapanese => 'Japanese';

  @override
  String get langNameTamil => 'Tamil';

  @override
  String get langNameGerman => 'German';

  @override
  String get langNameKorean => 'Korean';

  @override
  String get settingsDailyGoal => 'Daily goal';

  @override
  String settingsGoalRow(String label, int xp) {
    return '$label · $xp XP/day';
  }

  @override
  String get profileAchievements => 'Achievements';

  @override
  String get profileFriends => 'Friends';

  @override
  String get profileShop => 'Shop';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileSeeOnboarding => 'See onboarding flow ↗';

  @override
  String get profileNotSignedIn => 'Not signed in';

  @override
  String get profileCreateAccount => 'Create a free account';

  @override
  String get profileSaveProgress => 'Save your progress across devices';

  @override
  String profileTodaysGoal(int today, int goal) {
    return 'Today\'s goal · $today/$goal XP';
  }

  @override
  String get profileViewProgress => 'View progress →';

  @override
  String get profileUnlocked => 'Unlocked';
}
