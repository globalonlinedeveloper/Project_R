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

  @override
  String questsResetsIn(int h, int m) {
    return 'Resets in ${h}h ${m}m';
  }

  @override
  String get questsDailyRefresh => 'Daily refresh';

  @override
  String get questsFreshMix => 'A fresh 5-question mix';

  @override
  String get questsServedFromQueue =>
      'Served from your real review queue — earns real XP.';

  @override
  String get questsGoalReached => 'Daily goal reached! 🎉';

  @override
  String questsReachGoal(int goal) {
    return 'Reach $goal XP today';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return 'Daily quests · $done/$total';
  }

  @override
  String get questsInfoNote =>
      'Quests track your real daily progress. Reward chests, friend quests and a weekly leaderboard need a backend economy — an owner decision (§6). No fake rewards are shown.';

  @override
  String get questsStartRefresh => 'Start the daily refresh';

  @override
  String get questsStart => 'Start';

  @override
  String get questsPractisedToday => 'Practised today — streak safe';

  @override
  String get questsEarnAnyXp => 'Earn any XP today';

  @override
  String questsXpToday(int current, int target) {
    return '$current/$target XP today';
  }

  @override
  String get leaguesYourGroup => 'YOUR GROUP';

  @override
  String leaguesThisWeek(int size) {
    return 'THIS WEEK · $size LEARNERS';
  }

  @override
  String get leaguesTiers => 'League tiers';

  @override
  String leaguesTopClimb(int top, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return 'Top $top climb each week · ends in $_temp0';
  }

  @override
  String get leaguesDemotionZone => 'Demotion zone';

  @override
  String get leaguesPromotionZone => 'Promotion zone';

  @override
  String get leaguesSafeZone => 'Safe zone';

  @override
  String get leaguesYou => 'You';

  @override
  String leaguesPromoteRelegate(int top, int bottom) {
    return 'Top $top promote · bottom $bottom relegate when the week ends.';
  }

  @override
  String get leaguesYouAreHere => 'You\'re here';

  @override
  String get leaguesViewAllTiers => '🏆 View all 10 tiers ›';

  @override
  String get notifMarkAllRead => 'Mark all read';

  @override
  String get notifEmptyTitle => 'No notifications yet';

  @override
  String get notifEmptyBody =>
      'Finish lessons, build a streak and level up — your milestones will appear here the moment you genuinely earn them.';

  @override
  String get notifPushNote =>
      'These are in-app milestones, surfaced the moment you earn them. Push notifications and reminders are an owner decision and not enabled yet — nothing here is faked.';

  @override
  String get shopPowerUps => 'Power-ups';

  @override
  String get shopStreakFreeze => 'Streak Freeze';

  @override
  String get shopStreakFreezeDesc =>
      'Protects your streak for one missed day. Spent automatically when you miss your daily goal.';

  @override
  String shopOwned(int have, int max) {
    return 'Owned $have/$max';
  }

  @override
  String get shopMaxedOut => 'Maxed out';

  @override
  String shopBuyFor(int cost) {
    return 'Buy for $cost 💎';
  }

  @override
  String get shopFreezeAdded => 'Streak freeze added 💪';

  @override
  String shopFreezeAtCap(int max) {
    return 'You already hold the most freezes ($max).';
  }

  @override
  String shopNotEnoughEarnCost(int cost) {
    return 'Not enough 💎 — earn $cost by finishing lessons.';
  }

  @override
  String get shopNotEnoughEarnMore =>
      'Not enough 💎 — earn more by finishing lessons.';

  @override
  String get shopEnergyRefill => 'Energy Refill';

  @override
  String get shopEnergyRefillDesc =>
      'Top your energy straight back up to full. Energy is display-only — lessons never block.';

  @override
  String get shopAlreadyFull => 'Already full';

  @override
  String get shopEnergyRefilled => 'Energy refilled ⚡';

  @override
  String get shopEnergyAlreadyFull => 'Your energy is already full.';

  @override
  String get shopStreakRepair => 'Streak Repair';

  @override
  String get shopStreakRepairDesc =>
      'Lost your streak? Restore it to its previous length and keep the run going.';

  @override
  String get shopStreakLapsed => 'Streak lapsed';

  @override
  String shopStreakDays(int days) {
    return '🔥 $days-day streak';
  }

  @override
  String shopRepairFor(int cost) {
    return 'Repair for $cost 💎';
  }

  @override
  String get shopStreakRestored => 'Streak restored 🔥';

  @override
  String get shopStreakSafe =>
      'Your streak is safe — nothing to repair right now.';

  @override
  String get shopDoubleXp => 'Double XP';

  @override
  String get shopDoubleXpDesc => 'Earn 2× XP from every lesson for 15 minutes.';

  @override
  String shopActiveLeft(int minutes) {
    return 'Active · ${minutes}m left';
  }

  @override
  String get shopInactive => 'Inactive';

  @override
  String get shopActive => 'Active';

  @override
  String get shopDoubleXpActive => 'Double XP active ✨';

  @override
  String get shopBoostRunning => 'Your boost is running — XP is doubled.';

  @override
  String get shopBadgerOutfits => 'Badger outfits';

  @override
  String get paywallTitle => 'RATEL PRO';

  @override
  String get paywallStartTrial => 'Start 7-day free trial';

  @override
  String paywallGoPro(String price) {
    return 'Go Pro — $price/mo';
  }

  @override
  String get paywallRestore => 'Restore purchases';

  @override
  String get paywallHero => 'Live AI tutoring, ad-free, and offline lessons.';

  @override
  String get paywallAnnual => 'Annual';

  @override
  String get paywallMonthly => 'Monthly';

  @override
  String get paywallTrialHow => 'How the 7-day free trial works';

  @override
  String get paywallTrialToday => 'Today';

  @override
  String get paywallTrialTodayDesc => 'Full Pro access unlocks. No charge.';

  @override
  String get paywallTrialDay5 => 'Day 5';

  @override
  String get paywallTrialDay5Desc => 'We remind you before the trial ends.';

  @override
  String get paywallTrialDay7 => 'Day 7';

  @override
  String paywallTrialDay7Desc(String price) {
    return '$price/yr begins unless you cancel.';
  }

  @override
  String get paywallFeatureLiveAi =>
      'Live AI: voice, tutor chat & writing feedback';

  @override
  String get paywallFeatureNoAds => 'No ads, anywhere';

  @override
  String get paywallFeatureOffline => 'Offline lessons & audio';

  @override
  String get paywallFeaturePronunciation => 'AI pronunciation coaching tips';

  @override
  String get paywallEverythingFree =>
      'Everything else — all 52 languages, audio, review, leagues, roleplay and on-device pronunciation — stays free for everyone.';

  @override
  String get paywallYouArePro => 'You are on RATEL PRO';

  @override
  String get paywallThanks =>
      'Thanks for supporting Ratel. Manage or cancel anytime from Settings → Manage subscription.';

  @override
  String get paywallManage => 'Manage subscription';

  @override
  String paywallFinePrint(String regions) {
    return 'Cancel anytime in Settings. Prices shown for $regions; your local price is set by your app store.';
  }
}
