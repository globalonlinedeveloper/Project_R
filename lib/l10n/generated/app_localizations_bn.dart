// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get navHome => 'হোম';

  @override
  String get navLibrary => 'লাইব্রেরি';

  @override
  String get navLeagues => 'লিগ';

  @override
  String get navQuests => 'কোয়েস্ট';

  @override
  String get navProfile => 'প্রোফাইল';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsSectionLearning => 'শেখা';

  @override
  String get settingsSectionSubscription => 'সাবস্ক্রিপশন';

  @override
  String get settingsSectionAccessibility => 'অ্যাক্সেসিবিলিটি';

  @override
  String get settingsSectionNotifications => 'বিজ্ঞপ্তি';

  @override
  String get settingsSectionAppearanceAccount => 'চেহারা ও অ্যাকাউন্ট';

  @override
  String get settingsAppLanguage => 'অ্যাপের ভাষা';

  @override
  String get settingsAppLanguageSystem => 'সিস্টেম ডিফল্ট';

  @override
  String get homeCourseLoadingTitle => 'আপনার কোর্স প্রস্তুত হচ্ছে';

  @override
  String get homeCourseLoadingBody =>
      'কোর্সের বিষয়বস্তু লোড হলে পাঠগুলো এখানে দেখা যাবে।';

  @override
  String get homeGuideChip => 'গাইড';

  @override
  String get homeStartNode => 'শুরু';

  @override
  String get homeUnitGuideHeader => 'ইউনিট গাইড';

  @override
  String get commonDone => 'সম্পন্ন';

  @override
  String homeUnitKicker(String unit) {
    return 'ইউনিট · $unit';
  }

  @override
  String homeLessonMeta(int num, int count, String exercises) {
    return 'পাঠ $num / $count · $exercises।';
  }

  @override
  String homeQuickExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দ্রুত অনুশীলন',
      one: '$count দ্রুত অনুশীলন',
    );
    return '$_temp0';
  }

  @override
  String get homeEnergyChip => '−1 ⚡ শক্তি';

  @override
  String get homeXpChip => '+20 XP';

  @override
  String get homeStartLesson => 'পাঠ শুরু করুন';

  @override
  String get homeTutorChip => 'টিউটর';

  @override
  String get libraryAiTutor => 'AI টিউটর';

  @override
  String get libraryAiTutorSub => 'কথা বলুন, চ্যাট ও রোলপ্লে — লেখার ফিডব্যাক';

  @override
  String get libraryRoleplay => 'রোলপ্লে';

  @override
  String get libraryRoleplaySub => 'উত্তরের অনুশীলন — গ্রেডেড, সবসময় ফ্রি';

  @override
  String get librarySectionPractice => 'অনুশীলন';

  @override
  String get libraryPracticeHub => 'অনুশীলন কেন্দ্র';

  @override
  String get libraryPracticeHubSub => 'ভুল, দুর্বল শব্দ ও ড্রিল · ফ্রি';

  @override
  String get librarySectionReadListen => 'পড়ুন ও শুনুন';

  @override
  String get libraryGradedStories => 'স্তরভিত্তিক গল্প';

  @override
  String get libraryPodcasts => 'পডকাস্ট';

  @override
  String get libraryWatch => 'দেখুন';

  @override
  String get librarySearchHint => 'পাঠ, শব্দ, গল্প খুঁজুন…';

  @override
  String get libraryFeaturedStory => 'বিশেষ · গল্প';

  @override
  String commonLevel(String cefr) {
    return 'স্তর $cefr';
  }

  @override
  String get libraryReadNow => 'এখনই পড়ুন';

  @override
  String get libraryNewExplore => 'নতুন · ঘুরে দেখুন';

  @override
  String get libraryAdventures => 'অ্যাডভেঞ্চার';

  @override
  String get libraryStartExploring => 'ঘুরে দেখা শুরু করুন →';

  @override
  String get libraryKindStory => 'গল্প';

  @override
  String get libraryKindPodcast => 'পডকাস্ট';

  @override
  String get libraryKindVideo => 'ভিডিও';

  @override
  String get libraryAllStories => 'সব গল্প';

  @override
  String get libraryAllPodcasts => 'সব পডকাস্ট';

  @override
  String get libraryAllVideos => 'সব ভিডিও';

  @override
  String get lessonTypeWhatYouHear => 'যা শুনছেন তা লিখুন';

  @override
  String get lessonTapWhatYouHear => 'যা শুনছেন তা বাছুন';

  @override
  String get lessonTranslateSentence => 'এই বাক্যটি অনুবাদ করুন';

  @override
  String get lessonTypeAnswerHint => 'আপনার উত্তর লিখুন…';

  @override
  String get lessonWriteAnswerHint => 'আপনার উত্তর লিখুন…';

  @override
  String get lessonContinue => 'চালিয়ে যান';

  @override
  String get lessonSkip => 'এড়িয়ে যান';

  @override
  String get lessonCheck => 'যাচাই করুন';

  @override
  String get lessonNicelyDone => '✓ দারুণ!';

  @override
  String get lessonNotQuite => '✕ ঠিক হয়নি';

  @override
  String lessonAnswerReveal(String answer) {
    return 'উত্তর: $answer';
  }

  @override
  String get lessonCompleteKicker => 'পাঠ সম্পূর্ণ';

  @override
  String get lessonCompleteTitle => 'পাঠ সম্পূর্ণ!';

  @override
  String lessonCompleteSummary(int correct, int graded, String level) {
    return '$gradedটির মধ্যে $correctটি সঠিক · এখন $level';
  }

  @override
  String get lessonStatTotalXp => 'মোট XP';

  @override
  String get lessonStatAccuracy => 'নির্ভুলতা';

  @override
  String get lessonStatTime => 'সময়';

  @override
  String get onboardingWelcomeTitle => 'হ্যালো, আমি রেটেল!';

  @override
  String get onboardingWelcomeBody =>
      'নির্ভয়ে ভাষা শিখুন — ছোট ছোট পাঠ, মজার আর ফ্রি। শুরু করবেন?';

  @override
  String get onboardingHaveAccount => 'আমার আগে থেকেই অ্যাকাউন্ট আছে';

  @override
  String get onboardingTryWithoutAccount => 'অ্যাকাউন্ট ছাড়াই দেখুন →';

  @override
  String get onboardingGetStarted => 'শুরু করুন';

  @override
  String get onboardingStartLearning => 'শেখা শুরু করুন';

  @override
  String get onboardingLanguageTitle => 'আপনি কী শিখতে চান?';

  @override
  String get onboardingLanguageSubtitle => '৫২টি ভাষা উপলব্ধ';

  @override
  String get onboardingReasonTitle => 'আপনি কেন শিখছেন?';

  @override
  String get onboardingGoalTitle => 'দৈনিক লক্ষ্য বেছে নিন';

  @override
  String get onboardingPlacementTitle => 'আপনার শুরুর জায়গা খুঁজুন';

  @override
  String onboardingPlacementBody(String language) {
    return '$language-এ নতুন, নাকি কিছুটা জানেন?';
  }

  @override
  String get onboardingBrandNew => 'আমি একেবারে নতুন';

  @override
  String get onboardingBrandNewSub => 'একদম শুরু থেকে শুরু করুন';

  @override
  String get onboardingPlacementTest => 'প্লেসমেন্ট টেস্ট দিন';

  @override
  String get onboardingPlacementTestSub => '~৩ মিনিট · আপনার স্তরে চলে যান';

  @override
  String onboardingXpPerDay(int xp) {
    return '$xp XP / দিন';
  }

  @override
  String get reasonTravel => 'ভ্রমণ';

  @override
  String get reasonCulture => 'সংস্কৃতি';

  @override
  String get reasonCareer => 'কর্মজীবন';

  @override
  String get reasonFamilyFriends => 'পরিবার ও বন্ধুরা';

  @override
  String get reasonBrainTraining => 'মস্তিষ্কের ব্যায়াম';

  @override
  String get reasonJustForFun => 'শুধু মজার জন্য';

  @override
  String get goalCasual => 'হালকা';

  @override
  String get goalRegular => 'নিয়মিত';

  @override
  String get goalSerious => 'সিরিয়াস';

  @override
  String get goalIntense => 'তীব্র';

  @override
  String get langNameSpanish => 'স্প্যানিশ';

  @override
  String get langNameFrench => 'ফরাসি';

  @override
  String get langNameJapanese => 'জাপানি';

  @override
  String get langNameTamil => 'তামিল';

  @override
  String get langNameGerman => 'জার্মান';

  @override
  String get langNameKorean => 'কোরিয়ান';

  @override
  String get settingsDailyGoal => 'দৈনিক লক্ষ্য';

  @override
  String settingsGoalRow(String label, int xp) {
    return '$label · $xp XP/দিন';
  }

  @override
  String get profileAchievements => 'অর্জন';

  @override
  String get profileFriends => 'বন্ধুরা';

  @override
  String get profileShop => 'দোকান';

  @override
  String get profileNotifications => 'বিজ্ঞপ্তি';

  @override
  String get profileSeeOnboarding => 'অনবোর্ডিং ফ্লো দেখুন ↗';

  @override
  String get profileNotSignedIn => 'সাইন ইন করা নেই';

  @override
  String get profileCreateAccount => 'ফ্রি অ্যাকাউন্ট খুলুন';

  @override
  String get profileSaveProgress => 'সব ডিভাইসে আপনার অগ্রগতি সংরক্ষণ করুন';

  @override
  String profileTodaysGoal(int today, int goal) {
    return 'আজকের লক্ষ্য · $today/$goal XP';
  }

  @override
  String get profileViewProgress => 'অগ্রগতি দেখুন →';

  @override
  String get profileUnlocked => 'আনলকড';
}
