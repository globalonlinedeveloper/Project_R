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

  @override
  String questsResetsIn(int h, int m) {
    return '$hঘণ্টা $mমিনিটে রিসেট';
  }

  @override
  String get questsDailyRefresh => 'দৈনিক রিফ্রেশ';

  @override
  String get questsFreshMix => '৫টি প্রশ্নের নতুন মিশ্রণ';

  @override
  String get questsServedFromQueue =>
      'আপনার আসল রিভিউ সারি থেকে — আসল XP দেয়।';

  @override
  String get questsGoalReached => 'দৈনিক লক্ষ্য অর্জিত! 🎉';

  @override
  String questsReachGoal(int goal) {
    return 'আজ $goal XP অর্জন করুন';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return 'দৈনিক কোয়েস্ট · $done/$total';
  }

  @override
  String get questsInfoNote =>
      'কোয়েস্ট আপনার আসল দৈনিক অগ্রগতি অনুসরণ করে। রিওয়ার্ড চেস্ট, বন্ধু কোয়েস্ট ও সাপ্তাহিক লিডারবোর্ডের জন্য ব্যাকএন্ড ইকোনমি দরকার — মালিকের সিদ্ধান্ত (§6)। কোনো নকল পুরস্কার দেখানো হয় না।';

  @override
  String get questsStartRefresh => 'দৈনিক রিফ্রেশ শুরু করুন';

  @override
  String get questsStart => 'শুরু';

  @override
  String get questsPractisedToday => 'আজ অনুশীলন হয়েছে — স্ট্রিক নিরাপদ';

  @override
  String get questsEarnAnyXp => 'আজ যেকোনো XP অর্জন করুন';

  @override
  String questsXpToday(int current, int target) {
    return 'আজ $current/$target XP';
  }

  @override
  String get leaguesYourGroup => 'আপনার দল';

  @override
  String leaguesThisWeek(int size) {
    return 'এই সপ্তাহ · $size জন শিক্ষার্থী';
  }

  @override
  String get leaguesTiers => 'লিগ স্তর';

  @override
  String leaguesTopClimb(int top, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days দিনে',
      one: '$days দিনে',
    );
    return 'প্রতি সপ্তাহে সেরা $top জন ওপরে ওঠে · শেষ হবে $_temp0';
  }

  @override
  String get leaguesDemotionZone => 'অবনমন অঞ্চল';

  @override
  String get leaguesPromotionZone => 'পদোন্নতি অঞ্চল';

  @override
  String get leaguesSafeZone => 'নিরাপদ অঞ্চল';

  @override
  String get leaguesYou => 'আপনি';

  @override
  String leaguesPromoteRelegate(int top, int bottom) {
    return 'সপ্তাহ শেষে সেরা $top ওপরে · শেষের $bottom নিচে নামে।';
  }

  @override
  String get leaguesYouAreHere => 'আপনি এখানে';

  @override
  String get leaguesViewAllTiers => '🏆 সব ১০টি স্তর দেখুন ›';

  @override
  String get notifMarkAllRead => 'সব পঠিত হিসেবে চিহ্নিত করুন';

  @override
  String get notifEmptyTitle => 'এখনো কোনো বিজ্ঞপ্তি নেই';

  @override
  String get notifEmptyBody =>
      'পাঠ শেষ করুন, স্ট্রিক গড়ুন ও স্তর বাড়ান — সত্যিই অর্জনের মুহূর্তে আপনার মাইলফলক এখানে দেখা যাবে।';

  @override
  String get notifPushNote =>
      'এগুলো অ্যাপের ভেতরের মাইলফলক, অর্জনের মুহূর্তেই দেখানো হয়। পুশ বিজ্ঞপ্তি ও রিমাইন্ডার মালিকের সিদ্ধান্ত, এখনো চালু হয়নি — এখানে কিছুই নকল নয়।';

  @override
  String get shopPowerUps => 'পাওয়ার-আপ';

  @override
  String get shopStreakFreeze => 'স্ট্রিক ফ্রিজ';

  @override
  String get shopStreakFreezeDesc =>
      'একটি বাদ পড়া দিনে আপনার স্ট্রিক রক্ষা করে। দৈনিক লক্ষ্য মিস করলে স্বয়ংক্রিয়ভাবে খরচ হয়।';

  @override
  String shopOwned(int have, int max) {
    return 'আছে $have/$max';
  }

  @override
  String get shopMaxedOut => 'সর্বোচ্চ';

  @override
  String shopBuyFor(int cost) {
    return '$cost 💎 দিয়ে কিনুন';
  }

  @override
  String get shopFreezeAdded => 'স্ট্রিক ফ্রিজ যোগ হয়েছে 💪';

  @override
  String shopFreezeAtCap(int max) {
    return 'আপনার কাছে ইতিমধ্যে সর্বোচ্চ ফ্রিজ আছে ($max)।';
  }

  @override
  String shopNotEnoughEarnCost(int cost) {
    return 'যথেষ্ট 💎 নেই — পাঠ শেষ করে $cost অর্জন করুন।';
  }

  @override
  String get shopNotEnoughEarnMore =>
      'যথেষ্ট 💎 নেই — পাঠ শেষ করে আরও অর্জন করুন।';

  @override
  String get shopEnergyRefill => 'এনার্জি রিফিল';

  @override
  String get shopEnergyRefillDesc =>
      'শক্তি সরাসরি পূর্ণ করুন। শক্তি শুধু প্রদর্শনের জন্য — পাঠ কখনো আটকায় না।';

  @override
  String get shopAlreadyFull => 'আগে থেকেই পূর্ণ';

  @override
  String get shopEnergyRefilled => 'শক্তি পূরণ হয়েছে ⚡';

  @override
  String get shopEnergyAlreadyFull => 'আপনার শক্তি আগে থেকেই পূর্ণ।';

  @override
  String get shopStreakRepair => 'স্ট্রিক মেরামত';

  @override
  String get shopStreakRepairDesc =>
      'স্ট্রিক হারিয়েছেন? আগের দৈর্ঘ্যে ফিরিয়ে এনে চালিয়ে যান।';

  @override
  String get shopStreakLapsed => 'স্ট্রিক ভেঙেছে';

  @override
  String shopStreakDays(int days) {
    return '🔥 $days-দিনের স্ট্রিক';
  }

  @override
  String shopRepairFor(int cost) {
    return '$cost 💎 দিয়ে মেরামত';
  }

  @override
  String get shopStreakRestored => 'স্ট্রিক পুনরুদ্ধার 🔥';

  @override
  String get shopStreakSafe => 'আপনার স্ট্রিক নিরাপদ — এখন মেরামতের কিছু নেই।';

  @override
  String get shopDoubleXp => 'ডাবল XP';

  @override
  String get shopDoubleXpDesc => '১৫ মিনিট ধরে প্রতিটি পাঠে 2× XP অর্জন করুন।';

  @override
  String shopActiveLeft(int minutes) {
    return 'সক্রিয় · $minutesমি বাকি';
  }

  @override
  String get shopInactive => 'নিষ্ক্রিয়';

  @override
  String get shopActive => 'সক্রিয়';

  @override
  String get shopDoubleXpActive => 'ডাবল XP সক্রিয় ✨';

  @override
  String get shopBoostRunning => 'আপনার বুস্ট চলছে — XP দ্বিগুণ হচ্ছে।';

  @override
  String get shopBadgerOutfits => 'ব্যাজারের পোশাক';

  @override
  String get paywallTitle => 'RATEL PRO';

  @override
  String get paywallStartTrial => '৭ দিনের ফ্রি ট্রায়াল শুরু করুন';

  @override
  String paywallGoPro(String price) {
    return 'Pro নিন — $price/মাস';
  }

  @override
  String get paywallRestore => 'কেনাকাটা পুনরুদ্ধার';

  @override
  String get paywallHero => 'লাইভ AI টিউটরিং, বিজ্ঞাপনমুক্ত, অফলাইন পাঠ।';

  @override
  String get paywallAnnual => 'বার্ষিক';

  @override
  String get paywallMonthly => 'মাসিক';

  @override
  String get paywallTrialHow => '৭ দিনের ফ্রি ট্রায়াল কীভাবে কাজ করে';

  @override
  String get paywallTrialToday => 'আজ';

  @override
  String get paywallTrialTodayDesc =>
      'সম্পূর্ণ Pro অ্যাক্সেস খুলে যায়। কোনো চার্জ নেই।';

  @override
  String get paywallTrialDay5 => 'দিন ৫';

  @override
  String get paywallTrialDay5Desc => 'ট্রায়াল শেষের আগে আমরা মনে করিয়ে দিই।';

  @override
  String get paywallTrialDay7 => 'দিন ৭';

  @override
  String paywallTrialDay7Desc(String price) {
    return 'বাতিল না করলে $price/বছর শুরু হয়।';
  }

  @override
  String get paywallFeatureLiveAi =>
      'লাইভ AI: ভয়েস, টিউটর চ্যাট ও লেখার ফিডব্যাক';

  @override
  String get paywallFeatureNoAds => 'কোথাও বিজ্ঞাপন নেই';

  @override
  String get paywallFeatureOffline => 'অফলাইন পাঠ ও অডিও';

  @override
  String get paywallFeaturePronunciation => 'AI উচ্চারণ কোচিং টিপস';

  @override
  String get paywallEverythingFree =>
      'বাকি সব — ৫২টি ভাষা, অডিও, রিভিউ, লিগ, রোলপ্লে ও ডিভাইসে উচ্চারণ — সবার জন্য ফ্রি থাকে।';

  @override
  String get paywallYouArePro => 'আপনি RATEL PRO-তে আছেন';

  @override
  String get paywallThanks =>
      'Ratel-কে সমর্থনের জন্য ধন্যবাদ। সেটিংস → সাবস্ক্রিপশন পরিচালনা থেকে যেকোনো সময় পরিচালনা বা বাতিল করুন।';

  @override
  String get paywallManage => 'সাবস্ক্রিপশন পরিচালনা';

  @override
  String paywallFinePrint(String regions) {
    return 'সেটিংসে যেকোনো সময় বাতিল করুন। দেখানো দাম $regions-এর জন্য; আপনার স্থানীয় দাম ঠিক করে আপনার অ্যাপ স্টোর।';
  }
}
