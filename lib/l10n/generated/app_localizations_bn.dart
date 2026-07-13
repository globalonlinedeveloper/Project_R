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
  String get lessonExplainThis => '💡 Explain this';

  @override
  String get lessonMatchPairs => 'Match the pairs';

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
  String get onboardingLanguageSubtitle => '১০টি ভাষা থেকে ইংরেজি শিখুন';

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
  String get langNameEnglish => 'ইংরেজি';

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
      'বাকি সব — অডিও, রিভিউ, লিগ, রোলপ্লে ও ডিভাইসে উচ্চারণ — সবার জন্য ফ্রি থাকে।';

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

  @override
  String get questTitlePowerSession => 'পাওয়ার সেশন';

  @override
  String get questDescPowerSession => 'আপনার দৈনিক লক্ষ্যের দ্বিগুণ অর্জন করুন';

  @override
  String get questTitleOnFire => 'আগুনে গতি';

  @override
  String get questDescOnFire => 'আপনার দৈনিক লক্ষ্যের তিনগুণ অর্জন করুন';

  @override
  String get questTitleStreakKeeper => 'স্ট্রিক রক্ষক';

  @override
  String get questDescStreakKeeper => 'স্ট্রিক ধরে রাখতে আজ অনুশীলন করুন';

  @override
  String get notifTitleLessons1 => 'প্রথম পাঠ সম্পূর্ণ';

  @override
  String get notifBodyLessons1 =>
      'আপনি আপনার প্রথম পাঠ শেষ করেছেন — দুর্দান্ত শুরু!';

  @override
  String get notifTitleLessons5 => '5টি পাঠ সম্পন্ন';

  @override
  String get notifBodyLessons5 =>
      'আপনি 5টি পাঠ সম্পন্ন করেছেন। গতি বজায় রাখুন।';

  @override
  String get notifTitleLessons10 => '10টি পাঠ সম্পন্ন';

  @override
  String get notifBodyLessons10 => 'দশটি পাঠ — আপনি সত্যিকারের অভ্যাস গড়ছেন।';

  @override
  String get notifTitleLessons25 => '25টি পাঠ সম্পন্ন';

  @override
  String get notifBodyLessons25 => 'পঁচিশটি পাঠ সম্পন্ন। প্রশংসনীয় নিষ্ঠা!';

  @override
  String get notifTitleLessons50 => '50টি পাঠ সম্পন্ন';

  @override
  String get notifBodyLessons50 => 'পঞ্চাশটি পাঠ — আপনি সঠিক পথে এগোচ্ছেন।';

  @override
  String get notifTitleStreak3 => '3 দিনের স্ট্রিক!';

  @override
  String get notifBodyStreak3 => 'টানা তিন দিন। ধারাবাহিকতাই সব।';

  @override
  String get notifTitleStreak7 => '7 দিনের স্ট্রিক!';

  @override
  String get notifBodyStreak7 => 'প্রতিদিন অনুশীলনের পুরো এক সপ্তাহ। অসাধারণ!';

  @override
  String get notifTitleStreak14 => '14 দিনের স্ট্রিক!';

  @override
  String get notifBodyStreak14 => 'টানা দুই সপ্তাহ — আপনি অপ্রতিরোধ্য।';

  @override
  String get notifTitleStreak30 => '30 দিনের স্ট্রিক!';

  @override
  String get notifBodyStreak30 => 'প্রতিদিন অনুশীলনের পুরো এক মাস। অবিশ্বাস্য।';

  @override
  String get notifTitleXp100 => '100 XP অর্জিত';

  @override
  String get notifBodyXp100 => 'আপনার প্রথম একশো XP — গতি বাড়ছে।';

  @override
  String get notifTitleXp500 => '500 XP অর্জিত';

  @override
  String get notifBodyXp500 => 'পাঁচশো XP। আপনি পরিশ্রম করছেন।';

  @override
  String get notifTitleXp1000 => '1,000 XP অর্জিত';

  @override
  String get notifBodyXp1000 => 'এক হাজার XP মাইলফলক অর্জিত!';

  @override
  String get notifTitleXp2500 => '2,500 XP অর্জিত';

  @override
  String get notifBodyXp2500 => 'আড়াই হাজার XP — গুরুতর অগ্রগতি।';

  @override
  String get notifTitleLevel1 => 'স্তর A2-এ পৌঁছেছেন';

  @override
  String get notifBodyLevel1 => 'আপনার দক্ষতা A1 থেকে A2 হয়েছে। এগিয়ে চলুন!';

  @override
  String get notifTitleLevel2 => 'স্তর B1-এ পৌঁছেছেন';

  @override
  String get notifBodyLevel2 => 'আপনি এখন মধ্যম স্তরের শিক্ষার্থী (B1)।';

  @override
  String get notifTitleLevel3 => 'স্তর B2-এ পৌঁছেছেন';

  @override
  String get notifBodyLevel3 => 'উচ্চ-মধ্যম (B2) অর্জিত। চমৎকার।';

  @override
  String get notifTitleLevel4 => 'স্তর C1-এ পৌঁছেছেন';

  @override
  String get notifBodyLevel4 => 'উন্নত (C1) — আপনার ইংরেজি শক্তিশালী।';

  @override
  String get notifTitleLevel5 => 'স্তর C2-এ পৌঁছেছেন';

  @override
  String get notifBodyLevel5 => 'দক্ষতা (C2) — স্কেলের শীর্ষ!';

  @override
  String get achTitleFirstSteps => 'প্রথম পদক্ষেপ';

  @override
  String get achTitleScholar => 'পণ্ডিত';

  @override
  String get achTitleWildfire => 'দাবানল';

  @override
  String get achTitlePointMaker => 'পয়েন্ট মেকার';

  @override
  String get achTitleCollector => 'সংগ্রাহক';

  @override
  String get achTitleRisingStar => 'উদীয়মান তারকা';

  @override
  String get leagueTierBronze => 'ব্রোঞ্জ';

  @override
  String get leagueTierSilver => 'রুপা';

  @override
  String get leagueTierGold => 'সোনা';

  @override
  String get leagueTierSapphire => 'নীলকান্তমণি';

  @override
  String get leagueTierRuby => 'চুনি';

  @override
  String get leagueTierEmerald => 'পান্না';

  @override
  String get leagueTierAmethyst => 'অ্যামেথিস্ট';

  @override
  String get leagueTierPearl => 'মুক্তা';

  @override
  String get leagueTierObsidian => 'অবসিডিয়ান';

  @override
  String get leagueTierDiamond => 'হীরা';

  @override
  String get cefrNameBeginner => 'শিক্ষানবিস';

  @override
  String get cefrNameElementary => 'প্রাথমিক';

  @override
  String get cefrNameIntermediate => 'মধ্যম';

  @override
  String get cefrNameUpperIntermediate => 'উচ্চ-মধ্যম';

  @override
  String get cefrNameAdvanced => 'উন্নত';

  @override
  String get cefrNameProficient => 'দক্ষ';

  @override
  String leaguesTierLeague(String tier) {
    return '$tier লিগ';
  }

  @override
  String leaguesYoureIn(String tier) {
    return 'আপনি $tier-এ আছেন · শীর্ষ 7 প্রতি সপ্তাহে উপরে ওঠে';
  }

  @override
  String get leaguesZonePromotion => '⬆ পদোন্নতি অঞ্চল';

  @override
  String get leaguesZoneDemotion => '⬇ অবনমন অঞ্চল';

  @override
  String profileAchievementsSummary(int unlocked, int total) {
    return '$totalটির মধ্যে $unlockedটি আনলক · প্রকৃত অগ্রগতি';
  }

  @override
  String get profileRealStateNote =>
      'স্তর, XP, পাঠ, স্ট্রিক ও সংরক্ষিত শব্দ প্রকৃত ইঞ্জিন অবস্থা — নতুন অ্যাকাউন্টে শূন্য থেকে শুরু হয়।';

  @override
  String get practiceTitle => 'অনুশীলন';

  @override
  String practiceReviewWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি শব্দ রিভিউ করুন',
      one: '1টি শব্দ রিভিউ করুন',
    );
    return '$_temp0';
  }

  @override
  String get practiceYourWords => 'আপনার শব্দ';

  @override
  String practiceSavedWordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সংরক্ষিত শব্দ',
      one: '$countটি সংরক্ষিত শব্দ',
    );
    return '$_temp0';
  }

  @override
  String practiceDueForReview(int count) {
    return '$countটি স্পেসড রিভিউয়ের জন্য বাকি';
  }

  @override
  String get practiceAllUpToDate => 'সব রিভিউ হালনাগাদ';

  @override
  String practiceCaughtUp(String tail) {
    return 'সব সম্পন্ন — এখন কিছু বাকি নেই$tail।';
  }

  @override
  String practiceNextTail(String when) {
    return ' · পরেরটি $when';
  }

  @override
  String get practiceZeroDue => '0 বাকি';

  @override
  String get practiceDueNow => 'এখন বাকি';

  @override
  String practiceDueWhen(String when) {
    return 'বাকি $when';
  }

  @override
  String get practiceChipDue => 'বাকি';

  @override
  String get practiceChipScheduled => 'নির্ধারিত';

  @override
  String get practiceScheduleNote =>
      'রিভিউ নির্ধারণ করে প্রকৃত FSRS-6 স্পেসড-রিপিটিশন ইঞ্জিন। তারিখগুলো এই সেশনে থাকে; রিস্টার্টের পরেও রাখা গো-লাইভ ধাপ — এখানে কিছুই বানানো নয়।';

  @override
  String get practiceNoSavedWords => 'এখনো কোনো সংরক্ষিত শব্দ নেই';

  @override
  String get practiceSaveWordHint =>
      'পাঠ অনুশীলনের সময় একটি শব্দ সংরক্ষণ করুন, সেটি এখানে ফ্ল্যাশকার্ড হয়ে আসবে। এরপর প্রকৃত FSRS ইঞ্জিন রিভিউ নির্ধারণ করবে — কিছুই আগে থেকে ভরা নয়।';

  @override
  String get practiceStartLesson => 'একটি পাঠ শুরু করুন';

  @override
  String practiceWordOf(int n, int total) {
    return 'শব্দ $n/$total';
  }

  @override
  String get practiceShowAnswer => 'উত্তর দেখান';

  @override
  String get practiceRecallHint =>
      'অর্থ মনে করুন, তারপর কতটা মনে ছিল তা মূল্যায়ন করুন।';

  @override
  String get practiceGradeAgain => 'আবার';

  @override
  String get practiceGradeHard => 'কঠিন';

  @override
  String get practiceGradeGood => 'ভালো';

  @override
  String get practiceGradeEasy => 'সহজ';

  @override
  String get practiceFsrsGradeNote =>
      'আপনার মূল্যায়ন থেকে FSRS-6 পরের রিভিউ নির্ধারণ করে';

  @override
  String get practiceReviewComplete => 'রিভিউ সম্পূর্ণ';

  @override
  String practiceReviewedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আপনি $countটি শব্দ রিভিউ করেছেন। FSRS সেগুলো পুনঃনির্ধারণ করেছে।',
      one: 'আপনি 1টি শব্দ রিভিউ করেছেন। FSRS সেটি পুনঃনির্ধারণ করেছে।',
    );
    return '$_temp0';
  }

  @override
  String get practiceDone => 'সম্পন্ন';

  @override
  String get practiceRelTomorrow => 'আগামীকাল';

  @override
  String practiceRelInDays(int days) {
    return '$days দিনে';
  }

  @override
  String practiceRelInHours(int hours) {
    return '$hours ঘণ্টায়';
  }

  @override
  String practiceRelInMinutes(int minutes) {
    return '$minutes মিনিটে';
  }

  @override
  String get practiceRelSoon => 'শীঘ্রই';

  @override
  String get progressTitle => 'অগ্রগতি';

  @override
  String get progressShareMilestone => 'মাইলফলক শেয়ার করুন';

  @override
  String get progressLast7Days => 'শেষ 7 দিন';

  @override
  String get progressAccuracyRetention => 'নির্ভুলতা ও ধারণ';

  @override
  String get progressHonestyNote =>
      'এখানে সবকিছু প্রকৃত রেকর্ড করা অবস্থা — স্তর, দক্ষতা, সংরক্ষিত শব্দ, XP, পাঠ, স্ট্রিক, 7-দিনের ইতিহাস, নির্ভুলতা ও পড়ার সময় শূন্য থেকে শুরু হয়ে শেখার সাথে বাড়ে। ধারণ হলো এই সেশনের পূর্বাভাসিত স্মরণ (সেশন-পারাপার শিডিউলার গো-লাইভ কাজ); কিছুই বানানো নয়।';

  @override
  String progressShareText(
    String level,
    String levelName,
    int streak,
    int xp,
    int lessons,
  ) {
    return '🦡 RATEL · স্তর $level ($levelName)\n🔥 $streak দিনের স্ট্রিক · ⚡ $xp XP · 📘 $lessonsটি পাঠ\nlearnwithratel.com-এ শিখছি';
  }

  @override
  String get progressShareCopied =>
      'মাইলফলক ক্লিপবোর্ডে কপি হয়েছে — যেকোনো জায়গায় শেয়ার করুন!';

  @override
  String progressAbilityLine(String theta) {
    return 'দক্ষতা θ $theta · প্রকৃত অনুমান';
  }

  @override
  String get progressStatSavedWords => 'সংরক্ষিত শব্দ';

  @override
  String get progressStatLessons => 'পাঠ';

  @override
  String get progressStatDayStreak => 'দিনের স্ট্রিক';

  @override
  String get progressStatTotalXp => 'মোট XP';

  @override
  String get progressStatTodaysXp => 'আজকের XP';

  @override
  String get progressStatCefrLevel => 'CEFR স্তর';

  @override
  String get progressAccuracy => 'নির্ভুলতা';

  @override
  String get progressStudyTime => 'পড়ার সময়';

  @override
  String get progressRetention => 'ধারণ';

  @override
  String get progressNoData => 'এখনো ডেটা নেই';

  @override
  String get progressAccuracyEmpty =>
      'শুরু করতে নম্বরযুক্ত অনুশীলনের উত্তর দিন';

  @override
  String progressAccuracyDetail(int correct, int total) {
    return '$totalটির মধ্যে $correctটি সঠিক';
  }

  @override
  String get progressTimeEmpty => 'পাঠের সময় এখানে জমা হয়';

  @override
  String get progressTimeDetail => 'আপনার সব পাঠ জুড়ে';

  @override
  String get progressRetentionEmpty => 'পূর্বাভাসিত স্মরণ দেখতে রিভিউ করুন';

  @override
  String progressRetentionDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '1-দিনের পূর্বাভাসিত স্মরণ · এই সেশনে $countটি আইটেম',
      one: '1-দিনের পূর্বাভাসিত স্মরণ · এই সেশনে 1টি আইটেম',
    );
    return '$_temp0';
  }

  @override
  String progressWeekTotal(int xp) {
    return '$xp XP · শেষ 7 দিন';
  }

  @override
  String get progressNoXpYet => 'এখনো XP রেকর্ড হয়নি';

  @override
  String get progressChartEmptyNote =>
      '7-দিনের ইতিহাস শুরু করতে একটি পাঠ শেষ করুন — নিষ্ক্রিয় দিন শূন্যে থাকে, কিছুই বানানো নয়।';

  @override
  String get commonDowMon => 'সো';

  @override
  String get commonDowTue => 'ম';

  @override
  String get commonDowWed => 'বু';

  @override
  String get commonDowThu => 'বৃ';

  @override
  String get commonDowFri => 'শু';

  @override
  String get commonDowSat => 'শ';

  @override
  String get commonDowSun => 'র';

  @override
  String get searchTitle => 'খুঁজুন';

  @override
  String get searchHint => 'পাঠ, শব্দ, গল্প খুঁজুন…';

  @override
  String get searchRecent => 'সাম্প্রতিক';

  @override
  String get searchClear => 'মুছুন';

  @override
  String get searchJumpTo => 'যান';

  @override
  String get searchTagPage => 'পেজ';

  @override
  String get searchTagWord => 'শব্দ';

  @override
  String get searchSubtitleSavedWord => 'সংরক্ষিত শব্দ';

  @override
  String searchLessonSubtitle(String unit) {
    return '$unit · পাঠ';
  }

  @override
  String searchNoMatches(String query) {
    return '“$query”-এর জন্য কোনো ফলাফল নেই';
  }

  @override
  String get searchEmptyNote =>
      'আপনার কোর্স, সংরক্ষিত শব্দ ও পেজের শিরোনাম, ট্যাগ ও পাঠের বিষয়বস্তুতে খোঁজা হয়। সার্ভার কন্টেন্ট ইনডেক্স ও ট্রেন্ডিং R-L12-এর পরবর্তী ধাপ — এখানে কিছুই নকল নয়।';

  @override
  String get searchNoMatchNote =>
      'আপনার প্রকাশিত পাঠ, সংরক্ষিত শব্দ ও অ্যাপ পেজে (শিরোনাম + ট্যাগ) খোঁজা হয়। গল্প/পডকাস্ট ও পূর্ণ-পাঠ্য R-L12-এর পরবর্তী ধাপ — কখনো নকল নয়।';

  @override
  String get searchFooterNote =>
      'লঞ্চে শিরোনাম + ট্যাগ। পূর্ণ-পাঠ্য, গল্প/পডকাস্ট ও বহু-কোর্স R-L12-এর পরবর্তী ধাপ — কখনো নকল নয়।';

  @override
  String get searchDestPracticeHub => 'অনুশীলন কেন্দ্র';

  @override
  String get searchDestPracticeHubSub => 'ভুল, দুর্বল শব্দ ও ড্রিল';

  @override
  String get searchDestAiTutor => 'AI টিউটর';

  @override
  String get searchDestAiTutorSub => 'কথা বলুন, চ্যাট ও রোলপ্লে করুন';

  @override
  String get searchDestAdventures => 'অ্যাডভেঞ্চার';

  @override
  String get searchDestAdventuresSub => 'বাস্তব কথোপকথন — বিনামূল্যে';

  @override
  String get searchDestLeagues => 'লিগ';

  @override
  String get searchDestLeaguesSub => 'আপনার সাপ্তাহিক লিগ';

  @override
  String get searchDestQuests => 'কোয়েস্ট';

  @override
  String get searchDestQuestsSub => 'দৈনিক লক্ষ্য ও কোয়েস্ট';

  @override
  String get searchDestProgress => 'অগ্রগতি';

  @override
  String get searchDestProgressSub => 'আপনার পরিসংখ্যান ও স্ট্রিক';

  @override
  String get searchDestProfile => 'প্রোফাইল';

  @override
  String get searchDestProfileSub => 'আপনার প্রোফাইল';

  @override
  String get searchDestSettings => 'সেটিংস';

  @override
  String get searchDestSettingsSub => 'অ্যাকাউন্ট ও পছন্দ';

  @override
  String get searchDestShop => 'দোকান';

  @override
  String get searchDestShopSub => 'আপনার হীরা খরচ করুন';

  @override
  String get searchDestNotifications => 'বিজ্ঞপ্তি';

  @override
  String get searchDestNotificationsSub => 'আপনার মাইলফলক ইনবক্স';

  @override
  String get themesTitle => 'থিম';

  @override
  String get themesSubtitle =>
      'পুরো অ্যাপের রূপ বদলায় — লাইভ প্রিভিউতে ট্যাপ করুন';

  @override
  String themesVehicle(String vehicle) {
    return 'বাহন · $vehicle';
  }

  @override
  String get tutorHeader => 'বাস্তব কথোপকথনের অনুশীলন করুন';

  @override
  String get tutorHeaderSub =>
      'একটি দৃশ্য বেছে নিয়ে Ratel-এর সাথে চ্যাট করুন — ভুল উত্তর নেই, শুধু অনুশীলন।';

  @override
  String get tutorTalkTitle => 'Ratel-এর সাথে কথা বলুন';

  @override
  String get tutorTalkSub => 'লাইভ ভয়েস ও ভিডিও কথা বলার অনুশীলন';

  @override
  String get tutorChatTitle => 'Ratel-এর সাথে চ্যাট করুন';

  @override
  String get tutorChatSub => 'AI চ্যাট · লেখার মতামত';

  @override
  String get tutorRoleplayTitle => 'রোলপ্লে দৃশ্য';

  @override
  String get tutorRoleplayGuided => 'নির্দেশিত রোলপ্লে কথোপকথন';

  @override
  String tutorScenesCount(int count) {
    return '$countটি দৃশ্য';
  }

  @override
  String get tutorUnlockPro => 'RATEL PRO আনলক করুন';

  @override
  String get tutorRelayNote =>
      'লাইভ AI টিউটরিং একটি মডারেটেড, ব্যয়-নিয়ন্ত্রিত রিলেতে চলে এবং এটি RATEL PRO সুবিধা। উত্তর কখনো নকল হয় না — PRO ও রিলে দুটোই সক্রিয় হলে তবেই কোনো মোড শুরু হয়।';

  @override
  String get tutorStatusReadyPro =>
      'PRO সক্রিয় এবং লাইভ টিউটর সংযুক্ত — শুরু করতে একটি মোড বেছে নিন।';

  @override
  String get tutorStatusReadyFree =>
      'লাইভ টিউটর সংযুক্ত। লাইভ টিউটরিং RATEL PRO সুবিধা।';

  @override
  String get tutorStatusOffline =>
      'এই বিল্ডে মডারেটেড লাইভ টিউটর এখনো সংযুক্ত নয় — লাইভ টিউটরিং পরের ধাপে চালু হবে। নিচের কিছুই নকল নয়।';

  @override
  String get tutorAnnounceNeedsPro => 'RATEL PRO লাইভ AI টিউটরিং আনলক করে।';

  @override
  String get tutorAnnounceNeedsRelay =>
      'মডারেটেড রিলে চালু হলেই AI টিউটরিং সংযুক্ত হবে।';

  @override
  String get tutorAnnounceStarting => 'আপনার সেশন শুরু হচ্ছে…';

  @override
  String get adventuresTitle => 'অ্যাডভেঞ্চার';

  @override
  String get adventuresFreeChip => 'ফ্রি';

  @override
  String get adventuresHeaderSub =>
      'একটি জগৎ এক্সপ্লোর করুন · কথা বলে এগিয়ে যান';

  @override
  String get adventuresHeroTitle => 'একটি জায়গা বেছে নিয়ে শুরু করুন';

  @override
  String get adventuresHeroSub =>
      'প্রতিটি দৃশ্য একটি সত্যিকারের কথোপকথন — ভুল উত্তর নেই, আর সবসময় বিনামূল্যে।';

  @override
  String get adventuresFallbackWorld => 'অ্যাডভেঞ্চার';

  @override
  String adventureSheetKicker(String cefr) {
    return '🗺️ অ্যাডভেঞ্চার · $cefr';
  }

  @override
  String adventureScenesCount(int count) {
    return '$countটি দৃশ্য';
  }

  @override
  String adventureChoicePoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সিদ্ধান্ত বিন্দু',
      one: '$countটি সিদ্ধান্ত বিন্দু',
    );
    return '$_temp0';
  }

  @override
  String get adventureOpeningScene => 'শুরুর দৃশ্য';

  @override
  String get adventureStart => 'অ্যাডভেঞ্চার শুরু করুন';

  @override
  String get adventurePlayerFallbackTitle => 'অ্যাডভেঞ্চার';

  @override
  String get adventureTheEnd => '🏁 সমাপ্ত';

  @override
  String get adventureStartOver => 'আবার শুরু করুন';

  @override
  String get adventureDone => 'সম্পন্ন';

  @override
  String get adventureCompleteKicker => 'অ্যাডভেঞ্চার সম্পূর্ণ';

  @override
  String adventureCompleteTitle(String title) {
    return '$title ✓';
  }

  @override
  String get adventureCompleteBody =>
      'দারুণ! +15 XP · +5 💎 অর্জিত — যখন খুশি পরের দৃশ্যটি এক্সপ্লোর করুন।';

  @override
  String adventureDistrictProgress(int done, int total) {
    return '$done/$total এক্সপ্লোর করা';
  }

  @override
  String get adventureDistrictDone => '✓ সম্পন্ন';

  @override
  String get adventuresEmpty => 'এই কোর্সে এখনো কোনো অ্যাডভেঞ্চার নেই।';

  @override
  String get authWelcomeTitle => 'Ratel-এ স্বাগতম';

  @override
  String get authWelcomeSubtitle =>
      'পাঠ, গল্প, পডকাস্ট আরও অনেক কিছু —\nকীভাবে শুরু করবেন বেছে নিন।';

  @override
  String get authCreateFreeAccount => 'ফ্রি অ্যাকাউন্ট খুলুন';

  @override
  String get authAlreadyHaveAccount => 'আমার অ্যাকাউন্ট আছে';

  @override
  String get authSettingUp => 'প্রস্তুত হচ্ছে…';

  @override
  String get authContinueAsGuest => 'অতিথি হিসেবে চালিয়ে যান';

  @override
  String get authGuestNote =>
      'অতিথির অগ্রগতি এই ডিভাইসে থাকে — সবখানে রাখতে সেটিংসে গিয়ে যেকোনো সময় ফ্রি অ্যাকাউন্ট খুলুন।';

  @override
  String get authEnterYourEmail => 'আপনার ইমেইল লিখুন';

  @override
  String get authEnterValidEmail => 'সঠিক ইমেইল লিখুন';

  @override
  String get authEnterYourPassword => 'আপনার পাসওয়ার্ড লিখুন';

  @override
  String get authCouldNotSignIn => 'সাইন ইন করা গেল না। আবার চেষ্টা করুন।';

  @override
  String get authSomethingWentWrong => 'কিছু ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get authSocialComingSoon =>
      'Google / Apple দিয়ে সাইন-ইন শীঘ্রই আসছে।';

  @override
  String get authResetTitle => 'পাসওয়ার্ড রিসেট করুন';

  @override
  String get authWelcomeBack => 'আবার স্বাগতম!';

  @override
  String get authResetSubtitle => 'ইমেইল লিখুন, আমরা রিসেট লিঙ্ক পাঠাব।';

  @override
  String get authPickUpWhereYouLeft => 'যেখানে ছেড়েছিলেন সেখান থেকে শুরু করুন';

  @override
  String get authEmailHint => 'ইমেইল';

  @override
  String get authPasswordHint => 'পাসওয়ার্ড';

  @override
  String get authForgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get authSendResetLink => 'রিসেট লিঙ্ক পাঠান';

  @override
  String get authLogIn => 'লগ ইন';

  @override
  String get authBackToLogIn => 'লগ ইনে ফিরুন';

  @override
  String get authNewToRatel => 'Ratel-এ নতুন? ';

  @override
  String get authSignUp => 'সাইন আপ করুন';

  @override
  String get authCheckYourInbox => 'আপনার ইনবক্স দেখুন';

  @override
  String authResetSent(String email) {
    return 'আমরা $email-এ পাসওয়ার্ড-রিসেট লিঙ্ক পাঠিয়েছি। নতুন পাসওয়ার্ড বাছতে সেটি খুলুন।';
  }

  @override
  String get authCreatePassword => 'পাসওয়ার্ড তৈরি করুন';

  @override
  String get authAtLeast8Chars => 'কমপক্ষে 8টি অক্ষর';

  @override
  String get authCreateYourAccount => 'আপনার অ্যাকাউন্ট তৈরি করুন';

  @override
  String get authSignupSubtitle => 'চিরকাল ফ্রি · ১০টি ভাষা থেকে ইংরেজি শিখুন';

  @override
  String get authPassword8Hint => 'পাসওয়ার্ড (8+ অক্ষর)';

  @override
  String get authCreateAccount => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get authAlreadyAccountLead => 'আগে থেকে অ্যাকাউন্ট আছে? ';

  @override
  String get authSignIn => 'সাইন ইন করুন';

  @override
  String get authConfirmEmail => 'আপনার ইমেইল নিশ্চিত করুন';

  @override
  String authConfirmSent(String email) {
    return 'আমরা $email-এ নিশ্চিতকরণ লিঙ্ক পাঠিয়েছি। অ্যাকাউন্ট চালু করতে সেটি ট্যাপ করুন, তারপর লগ ইন করতে ফিরুন।';
  }

  @override
  String get authContinueGoogle => 'Google দিয়ে চালিয়ে যান';

  @override
  String get authContinueApple => 'Apple দিয়ে চালিয়ে যান';

  @override
  String get authOr => 'অথবা';

  @override
  String get authUnavailableNote =>
      'এই বিল্ডে অ্যাকাউন্ট এখনো চালু হয়নি — অতিথি হিসেবে শেখা চালিয়ে যেতে পারেন। ব্যাকএন্ড কনফিগার হলে সাইন-ইন চালু হবে।';

  @override
  String get liveMute => 'মিউট';

  @override
  String get liveUnmute => 'আনমিউট';

  @override
  String commonDurSeconds(int s) {
    return '$s সে.';
  }

  @override
  String commonDurMinutes(int m) {
    return '$m মি.';
  }

  @override
  String commonDurHours(int h) {
    return '$h ঘ.';
  }

  @override
  String commonDurHoursMinutes(int h, int m) {
    return '$h ঘ. $m মি.';
  }

  @override
  String practiceGradeInterval(String label, int days) {
    return '$label · $days দিন';
  }

  @override
  String settingsGoalPerDay(int goal) {
    return '$goal XP per day';
  }

  @override
  String settingsGoalReachedSub(int goal) {
    return '$goal XP per day · ✓ reached today';
  }

  @override
  String get settingsSoundEffects => 'Sound effects';

  @override
  String get settingsHaptics => 'Haptics';

  @override
  String get settingsProActive => 'RATEL PRO active';

  @override
  String get settingsFreePlan => 'Free plan';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceMotionSub =>
      'Master switch — turns off every animation';

  @override
  String get settingsHighContrast => 'High contrast';

  @override
  String get settingsNotifPush => 'Push notifications';

  @override
  String get settingsNotifStreak => 'Streak reminders';

  @override
  String get settingsNotifLeague => 'League updates';

  @override
  String get settingsNotifFriend => 'Friend activity';

  @override
  String get settingsNotifFootnote =>
      'Your choices are saved now — delivery switches on when push notifications ship.';

  @override
  String get settingsCourse => 'Course';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsWorld => 'World';

  @override
  String get settingsEditProfile => 'Edit profile';

  @override
  String get settingsPrivacy => 'Privacy & data';

  @override
  String get settingsHelp => 'Help & support';

  @override
  String get settingsLogOut => 'Log out';

  @override
  String get settingsGuestSub =>
      'You are learning as a guest — sign up to save progress';

  @override
  String settingsCouldNotOpen(String url) {
    return 'Could not open $url';
  }

  @override
  String get settingsThemeSystem => 'Match device';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get mediaReadAloud => 'Read aloud';

  @override
  String get mediaTranscript => 'Transcript';

  @override
  String get mediaCheckUnderstanding => 'Check understanding';

  @override
  String mediaChecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comprehension checks',
      one: '$count comprehension check',
    );
    return '$_temp0';
  }

  @override
  String get mediaLoading => 'Loading…';

  @override
  String get mediaPause => 'Pause';

  @override
  String get storiesTitle => 'Stories';

  @override
  String get storiesSub =>
      'Read & listen — graded stories with browser read-aloud.';

  @override
  String get storiesEmpty => 'No stories in this course yet.';

  @override
  String get storyFallbackTitle => 'Story';

  @override
  String get podcastsSub =>
      'Listen -- graded podcasts with real audio and a transcript.';

  @override
  String get podcastsEmpty => 'No podcasts in this course yet.';

  @override
  String get podcastFallbackTitle => 'Podcast';

  @override
  String get podcastPlayEpisode => 'Play episode';

  @override
  String get watchSub =>
      'Watch -- short clips with a transcript and comprehension checks.';

  @override
  String get watchEmpty => 'No watch lessons in this course yet.';

  @override
  String get watchWebOnly => 'Video plays in the web app';

  @override
  String get libraryAdventuresSub =>
      'Walk a living world and talk your way through real scenes.';

  @override
  String get roleplaySub =>
      'Practice real conversations -- pick the right reply, get instant feedback.';

  @override
  String get roleplayEmpty => 'No roleplays in this course yet.';

  @override
  String get roleplayYourReply => 'Your reply:';

  @override
  String get roleplaySceneComplete => '🎉 Scene complete!';

  @override
  String get roleplayBack => 'Back to roleplays';

  @override
  String get liveRoleplayTitle => 'Live Roleplay';

  @override
  String get liveRoleplayCardSub => 'Talk it out with Ratel — real voice';

  @override
  String get liveIntro =>
      'Talk it out with Ratel — live voice roleplay. Pick a scene, or just have a conversation.';

  @override
  String get liveFreeConversation => 'Free conversation';

  @override
  String get liveFreeConversationSub => 'No script — just talk';

  @override
  String get liveRoleplayScene => 'Roleplay a scene';

  @override
  String get liveReconnecting => 'Reconnecting…';

  @override
  String get liveConnectionLost =>
      'Connection lost — the live session dropped.';

  @override
  String get liveReconnect => 'Reconnect';

  @override
  String get liveConnecting => 'Connecting…';

  @override
  String get liveStartTalking => 'Start talking';

  @override
  String get liveSceneEndedNote =>
      'Scene ended. Start again whenever you like — your live minutes are budgeted, never silent.';

  @override
  String get liveStartAgain => 'Start again';

  @override
  String get liveProGate =>
      'Live voice roleplay is a RATEL PRO feature — real conversation, live feedback, cost-guarded minutes.';

  @override
  String get liveUnlockPro => 'Unlock RATEL PRO';

  @override
  String get liveNotEnabled =>
      'Live voice is not enabled in this build yet — it turns on in a later step. Nothing here is simulated.';

  @override
  String get livePhaseIdle => 'Ready when you are — it’s a real live call.';

  @override
  String get livePhaseListening => 'Listening — your turn.';

  @override
  String get livePhaseSpeaking => 'Ratel is speaking — jump in any time.';

  @override
  String get livePhaseClosed => 'Scene ended.';

  @override
  String get liveEndScene => 'End scene';

  @override
  String get liveYou => 'You';

  @override
  String get liveStartFailed => 'Could not start the live session — try again.';

  @override
  String get friendsHandleInvalid =>
      'Enter a handle like @mia (2–20 letters, numbers, _).';

  @override
  String friendsAlreadyConnected(String handle) {
    return 'You already have a connection with @$handle.';
  }

  @override
  String get friendsRequests => 'Requests';

  @override
  String get friendsYourFriends => 'Your friends';

  @override
  String get friendsPending => 'Pending';

  @override
  String get friendsActivity => 'Friend activity';

  @override
  String get friendsFootnote =>
      'Your social graph is real and private to you. Friend requests are delivered, and \"passed you\" appears, once the durable cross-user graph goes live — the same go-live step as every other durable counter. Nothing here is faked.';

  @override
  String get friendsAddHint => 'Add a friend by @handle…';

  @override
  String get friendsAccept => 'Accept';

  @override
  String friendsXpThisWeek(String handle, String xp) {
    return '@$handle · $xp XP this week';
  }

  @override
  String get friendsPassedYou => 'Passed you';

  @override
  String get friendsRemove => 'Remove';

  @override
  String get friendsBlock => 'Block';

  @override
  String get friendsReportBlock => 'Report & block';

  @override
  String get friendsRequestSent => 'Request sent';

  @override
  String get friendsEmptyTitle => 'No friends yet';

  @override
  String get friendsEmptyBody =>
      'Add someone by their @handle to start sharing progress.';

  @override
  String get profileLearner => 'Learner';

  @override
  String get profileGuest => 'Guest';

  @override
  String get editProfileSaved => 'Profile saved';

  @override
  String get editProfileHandleSet => 'Saved — your @handle is set.';

  @override
  String get editProfileSignInForHandle =>
      'Name saved. Sign in to claim your @handle.';

  @override
  String get editProfileHandleFailed => 'That @handle could not be set.';

  @override
  String get editProfileDisplayName => 'Display name';

  @override
  String get editProfileNameHint => 'How should we greet you?';

  @override
  String get editProfileNameNote =>
      'Shown on your profile. Saved on this device — it syncs to your account when you sign in.';

  @override
  String get editProfileHandle => 'Your @handle';

  @override
  String get editProfileHandleNote =>
      'Other learners add you by your @handle (2–20 letters, numbers or _). Claiming it needs you to be signed in.';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get feedIsNowYourFriend => 'is now your friend';

  @override
  String feedReachedLevel(String level) {
    return 'reached $level';
  }

  @override
  String feedDayStreak(int count) {
    return '$count-day streak';
  }

  @override
  String get feedPassedYou => 'passed you in your league';
}
