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
}
