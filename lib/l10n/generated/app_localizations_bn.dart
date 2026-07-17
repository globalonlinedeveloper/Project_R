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
  String homeSectionN(int n) {
    return 'বিভাগ $n';
  }

  @override
  String homeSectionLevel(int n, String band) {
    return 'বিভাগ $n · স্তর $band';
  }

  @override
  String homeLevelBand(String band) {
    return 'স্তর $band';
  }

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
  String get lessonExplainThis => '💡 এটি ব্যাখ্যা করুন';

  @override
  String get lessonMatchPairs => 'জোড়া মেলান';

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
  String libraryEstMinutes(int n) {
    return '~$n min';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return 'দৈনিক কোয়েস্ট · $done/$total';
  }

  @override
  String get questsInfoNote =>
      'কোয়েস্ট আপনার আসল দৈনিক অগ্রগতি অনুসরণ করে। রিওয়ার্ড চেস্ট, বন্ধু কোয়েস্ট ও সাপ্তাহিক লিডারবোর্ডের জন্য ব্যাকএন্ড ইকোনমি দরকার — মালিকের সিদ্ধান্ত (§6)। কোনো নকল পুরস্কার দেখানো হয় না।';

  @override
  String get questsRewardPending => 'Rewards soon';

  @override
  String get questsFriendQuest => 'Friend quest';

  @override
  String get questsFriendQuestSoon => 'Friend quests need a social backend — coming soon. No fake partners are shown.';

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
  String get paywallRegionsTier1 =>
      'মার্কিন যুক্তরাষ্ট্র, ইইউ, জাপান, অস্ট্রেলিয়া';

  @override
  String get paywallRegionsMid =>
      'লাতিন আমেরিকা, দক্ষিণ-পূর্ব এশিয়া, পূর্ব ইউরোপ';

  @override
  String get paywallRegionsLowPpp => 'ভারত, পাকিস্তান, নাইজেরিয়া, বাংলাদেশ';

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
  String get progressYourLevel => 'YOUR LEVEL';

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
  String get adventureDistrictCafe => 'Café & Food';

  @override
  String get adventureDistrictMarket => 'Market Square';

  @override
  String get adventureDistrictMove => 'On the Move';

  @override
  String get adventureDistrictFriends => 'Making Friends';

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
    return 'প্রতিদিন $goal XP';
  }

  @override
  String settingsGoalReachedSub(int goal) {
    return 'প্রতিদিন $goal XP · ✓ আজ অর্জিত';
  }

  @override
  String get settingsSoundEffects => 'সাউন্ড ইফেক্ট';

  @override
  String get settingsHaptics => 'হ্যাপটিক্স';

  @override
  String get settingsProActive => 'RATEL PRO সক্রিয়';

  @override
  String get settingsFreePlan => 'ফ্রি প্ল্যান';

  @override
  String get settingsReduceMotion => 'গতি কমান';

  @override
  String get settingsReduceMotionSub =>
      'মাস্টার সুইচ — প্রতিটি অ্যানিমেশন বন্ধ করে';

  @override
  String get settingsHighContrast => 'উচ্চ কনট্রাস্ট';

  @override
  String get settingsNotifPush => 'পুশ বিজ্ঞপ্তি';

  @override
  String get settingsNotifStreak => 'স্ট্রিক রিমাইন্ডার';

  @override
  String get settingsNotifLeague => 'লিগ আপডেট';

  @override
  String get settingsNotifFriend => 'বন্ধুর কার্যকলাপ';

  @override
  String get settingsNotifFootnote =>
      'আপনার পছন্দ এখন সংরক্ষিত — পুশ বিজ্ঞপ্তি চালু হলে ডেলিভারি সক্রিয় হবে।';

  @override
  String get settingsCourse => 'কোর্স';

  @override
  String get settingsTheme => 'থিম';

  @override
  String get settingsWorld => 'জগৎ';

  @override
  String get settingsEditProfile => 'প্রোফাইল সম্পাদনা';

  @override
  String get settingsPrivacy => 'গোপনীয়তা ও ডেটা';

  @override
  String get settingsHelp => 'সহায়তা ও সাপোর্ট';

  @override
  String get settingsLogOut => 'লগ আউট';

  @override
  String get settingsGuestSub =>
      'আপনি অতিথি হিসেবে শিখছেন — অগ্রগতি রাখতে সাইন আপ করুন';

  @override
  String settingsCouldNotOpen(String url) {
    return '$url খোলা গেল না';
  }

  @override
  String get settingsThemeSystem => 'ডিভাইসের সাথে মেলান';

  @override
  String get settingsThemeLight => 'লাইট';

  @override
  String get settingsThemeDark => 'ডার্ক';

  @override
  String get mediaReadAloud => 'উচ্চস্বরে পড়ুন';

  @override
  String get mediaTranscript => 'ট্রান্সক্রিপ্ট';

  @override
  String get mediaCheckUnderstanding => 'বোঝা যাচাই করুন';

  @override
  String mediaChecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বোধগম্যতা যাচাই',
      one: '$countটি বোধগম্যতা যাচাই',
    );
    return '$_temp0';
  }

  @override
  String get mediaLoading => 'লোড হচ্ছে…';

  @override
  String get mediaPause => 'বিরতি';

  @override
  String get storiesTitle => 'গল্প';

  @override
  String get storiesSub =>
      'পড়ুন ও শুনুন — ব্রাউজার উচ্চস্বরে পড়াসহ স্তরভিত্তিক গল্প।';

  @override
  String get storiesEmpty => 'এই কোর্সে এখনো কোনো গল্প নেই।';

  @override
  String get storyFallbackTitle => 'গল্প';

  @override
  String get podcastsSub =>
      'শুনুন — আসল অডিও ও ট্রান্সক্রিপ্টসহ স্তরভিত্তিক পডকাস্ট।';

  @override
  String get podcastsEmpty => 'এই কোর্সে এখনো কোনো পডকাস্ট নেই।';

  @override
  String get podcastFallbackTitle => 'পডকাস্ট';

  @override
  String get podcastPlayEpisode => 'পর্ব চালান';

  @override
  String get watchSub =>
      'দেখুন — ট্রান্সক্রিপ্ট ও বোধগম্যতা যাচাইসহ ছোট ক্লিপ।';

  @override
  String get watchEmpty => 'এই কোর্সে এখনো কোনো ভিডিও পাঠ নেই।';

  @override
  String get watchWebOnly => 'ভিডিও ওয়েব অ্যাপে চলে';

  @override
  String get libraryAdventuresSub =>
      'একটি জীবন্ত জগতে ঘুরুন আর আসল দৃশ্যে কথা বলে এগিয়ে যান।';

  @override
  String get roleplaySub =>
      'বাস্তব কথোপকথনের অনুশীলন করুন — সঠিক উত্তর বাছুন, তাৎক্ষণিক ফিডব্যাক পান।';

  @override
  String get roleplayEmpty => 'এই কোর্সে এখনো কোনো রোলপ্লে নেই।';

  @override
  String get roleplayCatEveryday => 'Everyday';

  @override
  String get roleplayCatTravel => 'Travel';

  @override
  String get roleplayCatWorkStudy => 'Work & Study';

  @override
  String get roleplayCatSocial => 'Social';

  @override
  String get roleplayCatHealth => 'Health';

  @override
  String get roleplaySearchHint => 'Search scenes…';

  @override
  String get roleplayYourReply => 'আপনার উত্তর:';

  @override
  String get roleplaySceneComplete => '🎉 দৃশ্য সম্পূর্ণ!';

  @override
  String get roleplayBack => 'রোলপ্লেতে ফিরুন';

  @override
  String get liveRoleplayTitle => 'লাইভ রোলপ্লে';

  @override
  String get liveRoleplayCardSub =>
      'Ratel-এর সাথে কথা বলে সমাধান করুন — আসল ভয়েস';

  @override
  String get liveIntro =>
      'Ratel-এর সাথে কথা বলে সমাধান করুন — লাইভ ভয়েস রোলপ্লে। একটি দৃশ্য বাছুন, নয়তো শুধু কথোপকথন করুন।';

  @override
  String get liveFreeConversation => 'ফ্রি কথোপকথন';

  @override
  String get liveFreeConversationSub => 'কোনো স্ক্রিপ্ট নেই — শুধু কথা বলুন';

  @override
  String get liveRoleplayScene => 'একটি দৃশ্যে রোলপ্লে';

  @override
  String get liveReconnecting => 'পুনরায় সংযোগ হচ্ছে…';

  @override
  String get liveConnectionLost =>
      'সংযোগ হারিয়েছে — লাইভ সেশন বন্ধ হয়ে গেছে।';

  @override
  String get liveReconnect => 'পুনরায় সংযোগ';

  @override
  String get liveConnecting => 'সংযোগ হচ্ছে…';

  @override
  String get liveStartTalking => 'কথা বলা শুরু করুন';

  @override
  String get liveSceneEndedNote =>
      'দৃশ্য শেষ। যখন খুশি আবার শুরু করুন — আপনার লাইভ মিনিট বাজেট করা, কখনো নীরব নয়।';

  @override
  String get liveStartAgain => 'আবার শুরু করুন';

  @override
  String get liveProGate =>
      'লাইভ ভয়েস রোলপ্লে একটি RATEL PRO সুবিধা — আসল কথোপকথন, লাইভ ফিডব্যাক, ব্যয়-নিয়ন্ত্রিত মিনিট।';

  @override
  String get liveUnlockPro => 'RATEL PRO আনলক করুন';

  @override
  String get liveNotEnabled =>
      'এই বিল্ডে লাইভ ভয়েস এখনো চালু হয়নি — এটি পরের ধাপে চালু হবে। এখানে কিছুই নকল নয়।';

  @override
  String get livePhaseIdle => 'আপনি প্রস্তুত হলেই শুরু — এটি একটি আসল লাইভ কল।';

  @override
  String get livePhaseListening => 'শুনছি — আপনার পালা।';

  @override
  String get livePhaseSpeaking => 'Ratel কথা বলছে — যেকোনো সময় যোগ দিন।';

  @override
  String get livePhaseClosed => 'দৃশ্য শেষ।';

  @override
  String get liveEndScene => 'দৃশ্য শেষ করুন';

  @override
  String get liveYou => 'আপনি';

  @override
  String get liveTutorName => 'Ratel';

  @override
  String get liveTutorRole => 'Ratel · Tutor';

  @override
  String get liveHd => 'HD';

  @override
  String get liveSpeakingIndicator => 'speaking…';

  @override
  String get liveIdleIndicator => 'ready';

  @override
  String get liveGreeting => 'Hi! I’m Ratel, your tutor. Ready to practice?';

  @override
  String get liveQuickReplyReady => 'Yes, let’s go!';

  @override
  String get liveQuickReplyNervous => 'A little nervous';

  @override
  String get liveVideoOn => 'Camera';

  @override
  String get liveVideoOff => 'Camera off';

  @override
  String get liveCaptionsOn => 'Captions';

  @override
  String get liveCaptionsOff => 'Captions off';

  @override
  String get liveEndCall => 'End call';

  @override
  String get liveCameraGated =>
      'Live camera isn’t part of this build — nothing is faked. When it turns on, your self-view goes here.';

  @override
  String get liveCaptionsGated =>
      'Live captions appear here once the real voice engine is on — no transcript is invented.';

  @override
  String get liveConnectPrompt =>
      'This is the call screen. The live voice engine isn’t connected in this build, so nothing you say is answered yet — no reply is ever simulated.';

  @override
  String get liveGreetingNote =>
      'This is Ratel’s scripted opener — the greeting, not a live reply.';

  @override
  String get liveStartFailed => 'লাইভ সেশন শুরু করা গেল না — আবার চেষ্টা করুন।';

  @override
  String get friendsHandleInvalid =>
      '@mia-এর মতো একটি হ্যান্ডেল লিখুন (২–২০টি অক্ষর, সংখ্যা, _)।';

  @override
  String friendsAlreadyConnected(String handle) {
    return '@$handle-এর সাথে আপনার আগে থেকেই সংযোগ আছে।';
  }

  @override
  String get friendsRequests => 'অনুরোধ';

  @override
  String get friendsYourFriends => 'আপনার বন্ধুরা';

  @override
  String get friendsPending => 'অপেক্ষমাণ';

  @override
  String get friendsActivity => 'বন্ধুর কার্যকলাপ';

  @override
  String get friendsFootnote =>
      'আপনার সোশ্যাল গ্রাফ আসল এবং শুধু আপনার জন্য গোপন। স্থায়ী ক্রস-ইউজার গ্রাফ চালু হলেই বন্ধু অনুরোধ ডেলিভার হয় এবং \"আপনাকে পেরিয়ে গেছে\" দেখা যায় — অন্য প্রতিটি স্থায়ী কাউন্টারের মতো একই গো-লাইভ ধাপে। এখানে কিছুই নকল নয়।';

  @override
  String get friendsAddHint => '@handle দিয়ে একজন বন্ধু যোগ করুন…';

  @override
  String get friendsAccept => 'গ্রহণ করুন';

  @override
  String friendsXpThisWeek(String handle, String xp) {
    return '@$handle · এই সপ্তাহে $xp XP';
  }

  @override
  String get friendsPassedYou => 'আপনাকে পেরিয়ে গেছে';

  @override
  String get friendsRemove => 'সরান';

  @override
  String get friendsBlock => 'ব্লক করুন';

  @override
  String get friendsReportBlock => 'রিপোর্ট ও ব্লক করুন';

  @override
  String get friendsRequestSent => 'অনুরোধ পাঠানো হয়েছে';

  @override
  String get friendsEmptyTitle => 'এখনো কোনো বন্ধু নেই';

  @override
  String get friendsEmptyBody =>
      'অগ্রগতি শেয়ার শুরু করতে কাউকে তার @handle দিয়ে যোগ করুন।';

  @override
  String get profileLearner => 'শিক্ষার্থী';

  @override
  String get profileGuest => 'অতিথি';

  @override
  String get editProfileSaved => 'প্রোফাইল সংরক্ষিত';

  @override
  String get editProfileHandleSet => 'সংরক্ষিত — আপনার @handle সেট হয়েছে।';

  @override
  String get editProfileSignInForHandle =>
      'নাম সংরক্ষিত। আপনার @handle দাবি করতে সাইন ইন করুন।';

  @override
  String get editProfileHandleFailed => 'সেই @handle সেট করা গেল না।';

  @override
  String get editProfileDisplayName => 'প্রদর্শন নাম';

  @override
  String get editProfileNameHint => 'আপনাকে কীভাবে সম্বোধন করব?';

  @override
  String get editProfileNameNote =>
      'আপনার প্রোফাইলে দেখানো হয়। এই ডিভাইসে সংরক্ষিত — সাইন ইন করলে এটি আপনার অ্যাকাউন্টে সিঙ্ক হয়।';

  @override
  String get editProfileHandle => 'আপনার @handle';

  @override
  String get editProfileHandleNote =>
      'অন্য শিক্ষার্থীরা আপনার @handle দিয়ে আপনাকে যোগ করে (২–২০টি অক্ষর, সংখ্যা বা _)। এটি দাবি করতে আপনাকে সাইন ইন করতে হবে।';

  @override
  String get editProfileAvatar => 'Avatar';

  @override
  String get editProfileChangeAvatar => 'Change avatar';

  @override
  String get editProfileAvatarTitle => 'Choose your avatar';

  @override
  String get editProfileAvatarNote =>
      'Pick an emoji badger buddy. Saved on this device.';

  @override
  String get editProfileBio => 'Bio';

  @override
  String get editProfileBioHint => 'A short line about you';

  @override
  String get editProfileBioNote =>
      'A short note shown on your profile. Saved on this device.';

  @override
  String get commonSave => 'সংরক্ষণ';

  @override
  String get commonCancel => 'বাতিল';

  @override
  String get feedIsNowYourFriend => 'এখন আপনার বন্ধু';

  @override
  String feedReachedLevel(String level) {
    return '$level-এ পৌঁছেছে';
  }

  @override
  String feedDayStreak(int count) {
    return '$count-দিনের স্ট্রিক';
  }

  @override
  String get feedPassedYou => 'আপনার লিগে আপনাকে পেরিয়ে গেছে';

  @override
  String get leaguesSoloCaption => 'এই সপ্তাহ · একক দল';

  @override
  String leaguesXpToRank(int xp, int rank) {
    return 'র‍্যাঙ্ক $rank-এ যেতে $xp XP';
  }

  @override
  String get leaguesLeading => 'আপনার দলে এগিয়ে';

  @override
  String get leaguesSoloNote =>
      'এই সপ্তাহে আপনি আপনার দলের একমাত্র শিক্ষার্থী। Ratel বড় হলে আসল প্রতিদ্বন্দ্বীরা যোগ দেবে — কোনো বট নেই, কোনো নকল লিডারবোর্ড নেই। সপ্তাহ রিসেট হলে ওপরে ওঠার জন্য প্রস্তুত থাকতে XP অর্জন চালিয়ে যান।';

  @override
  String questsGoalLine(int today, int goal) {
    return '$today / $goal XP · লক্ষ্য অর্জিত';
  }

  @override
  String questsGoalRemaining(int today, int goal, int remaining) {
    return '$today / $goal XP · আরও $remaining XP বাকি';
  }

  @override
  String get worldLabelLight => 'দিবালোক';

  @override
  String get worldVehicleLight => 'স্কুটার';

  @override
  String get worldLabelGalaxy => 'মহাকাশ';

  @override
  String get worldVehicleGalaxy => 'তারা-যান';

  @override
  String get worldLabelSavanna => 'সাভানা';

  @override
  String get worldVehicleSavanna => 'সাফারি জিপ';

  @override
  String get worldLabelOcean => 'সাগর';

  @override
  String get worldVehicleOcean => 'সাবমেরিন';

  @override
  String get worldLabelForest => 'বন';

  @override
  String get worldVehicleForest => 'পাতা-গ্লাইডার';

  @override
  String get worldLabelCandy => 'ক্যান্ডি';

  @override
  String get worldVehicleCandy => 'বেলুন';

  @override
  String get worldLabelNeon => 'নিয়ন শহর';

  @override
  String get worldVehicleNeon => 'ভাসন্ত বাইক';

  @override
  String get worldLabelStorm => 'ঝড়বৃষ্টি';

  @override
  String get worldVehicleStorm => 'ঝড়-গ্লাইডার';

  @override
  String get worldLabelSnow => 'শীতকাল';

  @override
  String get worldVehicleSnow => 'তুষার-স্লেজ';

  @override
  String get worldLabelSakura => 'চেরি ফুল';

  @override
  String get worldVehicleSakura => 'পাপড়ি-ঘুড়ি';

  @override
  String get worldLabelAutumn => 'হেমন্ত';

  @override
  String get worldVehicleAutumn => 'পাতা-গাড়ি';

  @override
  String get worldLabelAurora => 'মেরুজ্যোতি';

  @override
  String get worldVehicleAurora => 'জ্যোতি-নৌকা';

  @override
  String get worldLabelVolcano => 'আগ্নেয়গিরি';

  @override
  String get worldVehicleVolcano => 'লাভা-বোর্ড';

  @override
  String get worldLabelSunset => 'সূর্যাস্ত';

  @override
  String get worldVehicleSunset => 'গ্লাইডার';

  @override
  String get worldLabelDesert => 'মরুভূমি';

  @override
  String get worldVehicleDesert => 'বালিয়াড়ি বাগি';

  @override
  String get worldLabelReef => 'প্রবাল প্রাচীর';

  @override
  String get worldVehicleReef => 'কাচ-নৌকা';

  @override
  String get worldLabelMeadow => 'তৃণভূমি';

  @override
  String get worldVehicleMeadow => 'সাইকেল';

  @override
  String get worldLabelDawn => 'ভোর';

  @override
  String get worldVehicleDawn => 'আকাশ-বেলুন';

  @override
  String get worldLabelBeach => 'গ্রীষ্মমণ্ডলীয় সৈকত';

  @override
  String get worldVehicleBeach => 'ক্যাটামারান';

  @override
  String get worldLabelMars => 'মঙ্গল';

  @override
  String get worldVehicleMars => 'রোভার';

  @override
  String get worldLabelJungle => 'বৃষ্টিবন';

  @override
  String get worldVehicleJungle => 'জিপলাইন';

  @override
  String get worldLabelCyberrain => 'সাইবার বৃষ্টি';

  @override
  String get worldVehicleCyberrain => 'ভাসন্ত বাইক';

  @override
  String get worldLabelAbyss => 'গভীর সাগর';

  @override
  String get worldVehicleAbyss => 'গভীরযান';

  @override
  String get worldLabelAlpine => 'পর্বতমালা';

  @override
  String get worldVehicleAlpine => 'কেবল কার';

  @override
  String get worldLabelLavender => 'ল্যাভেন্ডার';

  @override
  String get worldVehicleLavender => 'ভেসপা';

  @override
  String get worldLabelBamboo => 'বাঁশবন';

  @override
  String get worldVehicleBamboo => 'রিকশা';

  @override
  String get worldLabelLagoon => 'উপহ্রদের রাত';

  @override
  String get worldVehicleLagoon => 'কায়াক';

  @override
  String get worldLabelThunder => 'বজ্রমেঘ';

  @override
  String get worldVehicleThunder => 'ঝড়-শিকারি';

  @override
  String get worldLabelNebula => 'নীহারিকা';

  @override
  String get worldVehicleNebula => 'তারা-জাহাজ';

  @override
  String get worldLabelSandstorm => 'বালুঝড়';

  @override
  String get worldVehicleSandstorm => 'কাফেলা';

  @override
  String get worldLabelCherrynight => 'চেরি রাত';

  @override
  String get worldVehicleCherrynight => 'কাগজ-লণ্ঠন';

  @override
  String get shopYourBadger => 'আপনার ব্যাজার';

  @override
  String get shopDiamondsNote =>
      'আসল টাকায় 💎 টপ-আপ আসছে। পাঠ শেষ করে ও দৈনিক লক্ষ্য পূরণ করে হীরা অর্জিত হয়, আর এখানকার প্রতিটি পাওয়ার-আপ সেগুলো সত্যিই খরচ করে — কিছুই নকল নয়।';

  @override
  String get shopProBannerSub =>
      'লাইভ AI, বিজ্ঞাপনমুক্ত, অফলাইন · ৭ দিন ফ্রি দেখুন';

  @override
  String get shopYourDiamonds => 'আপনার হীরা';

  @override
  String get shopEquipped => 'পরিহিত';

  @override
  String get shopEquip => 'পরান';

  @override
  String shopEquippedSnack(String name, String emoji) {
    return '$name $emoji পরানো হয়েছে';
  }

  @override
  String get shopFree => 'ফ্রি';

  @override
  String get outfitClassic => 'ক্লাসিক';

  @override
  String get outfitScholar => 'পণ্ডিত';

  @override
  String get outfitExplorer => 'অভিযাত্রী';

  @override
  String get outfitAstronaut => 'মহাকাশচারী';

  @override
  String get outfitWizard => 'জাদুকর';

  @override
  String paywallAnnualLine(String annual, String perMonth) {
    return '$annual/বছর  ·  $perMonth/মাস  ·  ৭ দিন ফ্রি';
  }

  @override
  String paywallMonthlyLine(String monthly) {
    return '$monthly/মাস  ·  মাসিক বিল';
  }

  @override
  String paywallSavePercent(int percent) {
    return '$percent% সাশ্রয়';
  }

  @override
  String get paywallIncluded => 'Pro-তে যা যা আছে';

  @override
  String get paywallTerms => 'শর্তাবলি';

  @override
  String get paywallPrivacy => 'গোপনীয়তা';

  @override
  String get paywallNothingToRestore =>
      'পুনরুদ্ধারের কিছু নেই — এই বিল্ডে বিলিং এখনো চালু নয়।';

  @override
  String get contentUnavailableTitle => 'কন্টেন্ট অনুপলব্ধ';

  @override
  String contentUnavailableBody(String noun) {
    return 'এই $nounটি এখন উপলব্ধ নয়। আপনি অফলাইন থাকলে সংযোগ দেখে আবার চেষ্টা করুন।';
  }

  @override
  String get contentNounStory => 'গল্প';

  @override
  String get contentNounPodcast => 'পডকাস্ট';

  @override
  String get contentNounVideo => 'ভিডিও';

  @override
  String get contentNounAdventure => 'অ্যাডভেঞ্চার';

  @override
  String get contentNounRoleplay => 'রোলপ্লে';

  @override
  String get commonGoBack => 'ফিরে যান';

  @override
  String get placementTitle => 'প্লেসমেন্ট টেস্ট';

  @override
  String placementQuestionN(int n) {
    return 'প্রশ্ন $n';
  }

  @override
  String get placementResultTitle => 'আপনার শুরুর জায়গা';

  @override
  String placementResultBody(int count, String level) {
    return '$countটি প্রশ্নের ভিত্তিতে, আমরা আপনাকে $level-এ রেখেছি। আপনি সবসময় পরে বদলাতে পারেন।';
  }

  @override
  String get lessonTypedNote => 'লক্ষ্য ভাষায় আপনার উত্তর লিখুন।';

  @override
  String lessonHintMinWords(int count) {
    return 'কমপক্ষে $countটি শব্দ';
  }

  @override
  String lessonHintUseWords(String words) {
    return 'ব্যবহার করুন: $words';
  }

  @override
  String get lessonHintEndPunct => '. ! বা ? দিয়ে শেষ করুন';

  @override
  String get lessonPlayAudio => 'অডিও চালান';

  @override
  String get lessonPlaySlowly => 'ধীরে চালান';

  @override
  String get lessonAudioUnavailable => 'অডিও অনুপলব্ধ — প্রম্পট পড়ুন।';

  @override
  String get lessonPlaybackSpeed => 'প্লেব্যাক গতি';

  @override
  String get authAccountsUnavailable =>
      'এই বিল্ডে অ্যাকাউন্ট এখনো চালু হয়নি — গেস্ট হিসেবে শেখা চালিয়ে যান।';

  @override
  String get liveNotEnabledShort => 'এই বিল্ডে লাইভ AI চালু নেই।';

  @override
  String get liveMicUnavailable =>
      'মাইক্রোফোন পাওয়া যাচ্ছে না — টিউটরের সাথে কথা বলতে মাইক অ্যাক্সেস দিন।';

  @override
  String get liveUnavailable => 'এই মুহূর্তে লাইভ AI পাওয়া যাচ্ছে না।';

  @override
  String get liveNeedsPro => 'লাইভ AI শুধু RATEL PRO-তে পাওয়া যায়।';

  @override
  String get liveMinutesUsed => 'এই মাসের লাইভ মিনিট আপনি ব্যবহার করে ফেলেছেন।';

  @override
  String get commonNetworkError => 'সার্ভারে পৌঁছানো গেল না। আবার চেষ্টা করুন।';

  @override
  String get friendsHandleTaken => 'সেই @handle আগে থেকেই নেওয়া হয়ে গেছে।';

  @override
  String get friendsHandleFormat =>
      'আপনার হ্যান্ডেলের জন্য 2–20টি অক্ষর, সংখ্যা বা _ ব্যবহার করুন।';

  @override
  String get friendsSignInForHandle => 'আপনার @handle দাবি করতে সাইন ইন করুন।';

  @override
  String get friendsSetOwnHandleFirst =>
      'প্রথমে নিজের @handle সেট করুন (প্রোফাইল সম্পাদনা)।';

  @override
  String get paywallCheckoutUnavailable =>
      'চেকআউট চালু হবে লঞ্চে — এই বিল্ডে স্টোর বিলিং এখনো চালু নয়।';

  @override
  String get settingsManageUnavailable =>
      'আপনার ডিভাইসের Subscriptions সেটিংসে পরিচালনা বা বাতিল করুন — অ্যাপের ভেতরের শর্টকাট চালু হবে লঞ্চে।';

  @override
  String get friendsAdd => 'যোগ করুন';

  @override
  String get practiceSubtitle => 'Always free · never costs energy';

  @override
  String get practiceSkillStrength => 'Skill strength';

  @override
  String get practiceSkillVocabulary => 'Vocabulary';

  @override
  String get practiceSkillListening => 'Listening';

  @override
  String get practiceSkillGrammar => 'Grammar';

  @override
  String get practiceSkillSpeaking => 'Speaking';

  @override
  String get practiceSkillNoData =>
      'Per-skill strength builds as you practice — no score is shown until the engine has your real signal. Nothing here is invented.';

  @override
  String get practiceStatWordsLearned => 'Words learned';

  @override
  String get practiceStatThisWeek => 'This week XP';

  @override
  String get practiceStatAccuracy => 'Accuracy';

  @override
  String get practiceStatEmptyValue => '—';

  @override
  String get practiceDrillMistakesTitle => 'Mistakes review';

  @override
  String get practiceDrillMistakesSub => 'Redo the questions you got wrong';

  @override
  String get practiceDrillWeakTitle => 'Weak words';

  @override
  String get practiceDrillWeakSub => 'Strengthen fading memories';

  @override
  String get practiceDrillListeningTitle => 'Listening drill';

  @override
  String get practiceDrillListeningSub => 'Train your ear';

  @override
  String get practiceDrillSpeakingTitle => 'Speaking drill';

  @override
  String get practiceDrillSpeakingSub => 'Shadow native audio';

  @override
  String get practiceDrillRoleplayTitle => 'Roleplay drill';

  @override
  String get practiceDrillRoleplaySub => 'Scripted conversations · always free';

  @override
  String get practiceDrillMyWordsTitle => 'My Words';

  @override
  String get practiceDrillMyWordsSub =>
      'Saved words · search, relearn & listen';

  @override
  String get practiceDrillWritingTitle => 'Guided writing';

  @override
  String get practiceDrillWritingSub => 'Build sentences · rule-checked, free';

  @override
  String get practiceSmartReviewTitle => 'Smart review';

  @override
  String get practiceSmartReviewSub =>
      'Adaptive mix of everything you\'re forgetting';

  @override
  String get practiceDrillEmptyTitle => 'Nothing to review yet';

  @override
  String practiceDrillEmptyBody(Object drill) {
    return 'This drill draws on your real practice history. As you complete lessons and reviews, $drill fills up here — nothing is pre-filled or faked.';
  }

  @override
  String practiceDrillComingNote(Object drill) {
    return 'The dedicated $drill exercise plugs in at go-live. Until then this stays an honest empty state — it never shows a made-up exercise.';
  }

  @override
  String get practiceSmartReviewEmpty =>
      'Your adaptive queue is empty — complete a lesson or save a word and the Smart review mix will draw from your real due items.';

  @override
  String get practiceBackToHub => 'Back to Practice';

  @override
  String get streakTitle => 'Streak';

  @override
  String get streakDayLabel => 'DAY STREAK';

  @override
  String get streakFreezesLabel => 'Streak freezes';

  @override
  String get streakFreezesTileSub =>
      'A freeze covers one missed day so your run survives.';

  @override
  String get streakDeadlineTitle => 'Keep it going today';

  @override
  String get streakDeadlineBody =>
      'Meet your daily goal before midnight to extend your streak.';

  @override
  String get streakTodayDone => 'Today\'s goal is met — your streak is safe.';

  @override
  String get streakZeroTitle => 'Start your streak today';

  @override
  String get streakZeroBody =>
      'Finish a lesson to light the flame. Every consecutive day you meet your goal adds one.';

  @override
  String get streakSocietyTitle => 'Streak Society';

  @override
  String get streakSocietySub => 'Friend streaks · societies · perks';

  @override
  String get streakSocietyHonest =>
      'Streak Society is not built yet — there is no friends-streak backend, so nothing here is faked. It arrives with real social features, like Leagues.';

  @override
  String get streakHonestNote =>
      'Your day count and freezes are your real numbers. RATEL does not show a day-by-day calendar here because it does not yet keep a per-day activity log — nothing is invented.';

  @override
  String get energyTitle => 'Energy';

  @override
  String energyCountLabel(int current, int max) {
    return '$current of $max energy';
  }

  @override
  String get energyUnlimitedLabel => 'Unlimited energy';

  @override
  String get energyLessonCost => 'Each lesson costs 1 ⚡';

  @override
  String get energyNeverBlocksTitle => 'Energy never blocks learning';

  @override
  String get energyNeverBlocksBody =>
      'You can always keep learning, even at 0 ⚡. Energy is a gentle pace signal — it never locks a lesson, and practice is always free.';

  @override
  String get energyRegenNote =>
      'Energy refills on its own over time toward the cap. Exact refill timing isn\'t finalised, so RATEL doesn\'t show a countdown it can\'t guarantee.';

  @override
  String get energyProTitle => 'You have unlimited energy';

  @override
  String get energyProBody =>
      'RATEL PRO removes the counter entirely — it always reads ∞.';

  @override
  String get energyPracticeFree => 'Practice for free';

  @override
  String get energyGoProUnlimited => 'Go PRO · unlimited energy';

  @override
  String get energyHonestNote =>
      'This is your real current energy. RATEL doesn\'t show a refill price or timer here because those numbers aren\'t finalised — it won\'t commit to a figure it can\'t back.';

  @override
  String get coursesTitle => 'Courses';

  @override
  String get coursesLearningHeader => 'LEARNING';

  @override
  String get coursesActive => 'Active';

  @override
  String get coursesSwitch => 'Switch';

  @override
  String get coursesSharedProgress =>
      'Your streak & XP are shared across courses — switching never loses progress.';

  @override
  String get coursesAddHeader => 'ADD A COURSE';

  @override
  String get coursesAddHonest =>
      'More languages are on the way. RATEL only lists courses it actually ships, so there\'s no fake catalog or \"50+ courses\" count here yet.';

  @override
  String get coursesDisplayHeader => 'DISPLAY';

  @override
  String get coursesMenuLanguage => 'Menu language';

  @override
  String get coursesMenuLanguageSub =>
      'Set the app\'s interface language in Settings';

  @override
  String get coursesImmersionMode => 'Immersion mode';

  @override
  String get coursesImmersionSub =>
      'Learn with the app interface in the language you\'re studying.';

  @override
  String coursesImmersionUnsupported(String language) {
    return 'Immersion isn\'t available for $language yet — the app interface isn\'t translated into it.';
  }

  @override
  String coursesSwitchedTo(String language) {
    return 'Switched to $language';
  }

  @override
  String coursesXpTotal(int xp) {
    return '⚡ $xp XP';
  }

  @override
  String get coursesSearchHint => 'Search languages';

  @override
  String get chatTitle => 'Ratel · Tutor';

  @override
  String get chatSubtitle => 'Chat with Ratel';

  @override
  String get chatIntroBubble =>
      'Hi! I\'m Ratel. Ask me anything, or paste a sentence and I\'ll give you feedback.';

  @override
  String get chatQuickHowSay => 'How do you say…?';

  @override
  String get chatQuickCorrect => 'Correct my sentence';

  @override
  String get chatQuickTalk => 'Let\'s chat';

  @override
  String get chatComposerHint => 'Type your message…';

  @override
  String get chatOfflineTitle => 'The tutor chat isn\'t connected yet';

  @override
  String get chatOfflineBody =>
      'Live AI chat is a moderated RATEL PRO feature that turns on in a later step. Until then, no reply is ever simulated — the composer stays here so the layout is ready, but Ratel won\'t send a made-up answer.';

  @override
  String get chatSendBlocked =>
      'The AI tutor isn\'t connected yet — no reply is simulated. Live chat turns on in a later step.';

  @override
  String get homeStreakChipTip => 'View your streak';

  @override
  String get homeEnergyChipTip => 'View your energy';

  @override
  String get diamondsSheetTitle => 'DIAMONDS';

  @override
  String diamondsSheetCount(int count) {
    return '$count diamonds';
  }

  @override
  String get diamondsSheetBody =>
      'Spend on streak freezes, energy refills and outfits in the Shop.';

  @override
  String diamondsSheetEarn(int lesson, int goal) {
    return 'You earn diamonds by finishing lessons (+$lesson each) and meeting your daily goal (+$goal). Everything in the Shop spends real diamonds — nothing here is faked.';
  }

  @override
  String get diamondsOpenShop => 'Open Shop';

  @override
  String get diamondsClose => 'Close';
}
