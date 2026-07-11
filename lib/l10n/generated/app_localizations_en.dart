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

  @override
  String get questTitlePowerSession => 'Power session';

  @override
  String get questDescPowerSession => 'Earn double your daily goal';

  @override
  String get questTitleOnFire => 'On fire';

  @override
  String get questDescOnFire => 'Earn triple your daily goal';

  @override
  String get questTitleStreakKeeper => 'Streak keeper';

  @override
  String get questDescStreakKeeper => 'Practice today to keep your streak';

  @override
  String get notifTitleLessons1 => 'First lesson complete';

  @override
  String get notifBodyLessons1 =>
      'You finished your first lesson — great start!';

  @override
  String get notifTitleLessons5 => '5 lessons done';

  @override
  String get notifBodyLessons5 =>
      'You\'ve completed 5 lessons. Keep the momentum going.';

  @override
  String get notifTitleLessons10 => '10 lessons done';

  @override
  String get notifBodyLessons10 =>
      'Ten lessons in — you are building a real habit.';

  @override
  String get notifTitleLessons25 => '25 lessons done';

  @override
  String get notifBodyLessons25 =>
      'Twenty-five lessons completed. Impressive dedication!';

  @override
  String get notifTitleLessons50 => '50 lessons done';

  @override
  String get notifBodyLessons50 => 'Fifty lessons — you are well on your way.';

  @override
  String get notifTitleStreak3 => '3-day streak!';

  @override
  String get notifBodyStreak3 =>
      'Three days in a row. Consistency is everything.';

  @override
  String get notifTitleStreak7 => '7-day streak!';

  @override
  String get notifBodyStreak7 => 'A full week of daily practice. Outstanding!';

  @override
  String get notifTitleStreak14 => '14-day streak!';

  @override
  String get notifBodyStreak14 => 'Two weeks straight — you are unstoppable.';

  @override
  String get notifTitleStreak30 => '30-day streak!';

  @override
  String get notifBodyStreak30 =>
      'A whole month of daily practice. Incredible.';

  @override
  String get notifTitleXp100 => '100 XP earned';

  @override
  String get notifBodyXp100 => 'Your first hundred XP — momentum is building.';

  @override
  String get notifTitleXp500 => '500 XP earned';

  @override
  String get notifBodyXp500 => 'Five hundred XP. You are putting in the work.';

  @override
  String get notifTitleXp1000 => '1,000 XP earned';

  @override
  String get notifBodyXp1000 => 'A thousand XP milestone reached!';

  @override
  String get notifTitleXp2500 => '2,500 XP earned';

  @override
  String get notifBodyXp2500 => 'Twenty-five hundred XP — serious progress.';

  @override
  String get notifTitleLevel1 => 'Reached level A2';

  @override
  String get notifBodyLevel1 => 'Your ability grew from A1 to A2. Onward!';

  @override
  String get notifTitleLevel2 => 'Reached level B1';

  @override
  String get notifBodyLevel2 => 'You are now an intermediate learner (B1).';

  @override
  String get notifTitleLevel3 => 'Reached level B2';

  @override
  String get notifBodyLevel3 => 'Upper-intermediate (B2) reached. Brilliant.';

  @override
  String get notifTitleLevel4 => 'Reached level C1';

  @override
  String get notifBodyLevel4 => 'Advanced (C1) — your Spanish is strong.';

  @override
  String get notifTitleLevel5 => 'Reached level C2';

  @override
  String get notifBodyLevel5 => 'Proficiency (C2) — the top of the scale!';

  @override
  String get achTitleFirstSteps => 'First Steps';

  @override
  String get achTitleScholar => 'Scholar';

  @override
  String get achTitleWildfire => 'Wildfire';

  @override
  String get achTitlePointMaker => 'Point Maker';

  @override
  String get achTitleCollector => 'Collector';

  @override
  String get achTitleRisingStar => 'Rising Star';

  @override
  String get leagueTierBronze => 'Bronze';

  @override
  String get leagueTierSilver => 'Silver';

  @override
  String get leagueTierGold => 'Gold';

  @override
  String get leagueTierSapphire => 'Sapphire';

  @override
  String get leagueTierRuby => 'Ruby';

  @override
  String get leagueTierEmerald => 'Emerald';

  @override
  String get leagueTierAmethyst => 'Amethyst';

  @override
  String get leagueTierPearl => 'Pearl';

  @override
  String get leagueTierObsidian => 'Obsidian';

  @override
  String get leagueTierDiamond => 'Diamond';

  @override
  String get cefrNameBeginner => 'Beginner';

  @override
  String get cefrNameElementary => 'Elementary';

  @override
  String get cefrNameIntermediate => 'Intermediate';

  @override
  String get cefrNameUpperIntermediate => 'Upper intermediate';

  @override
  String get cefrNameAdvanced => 'Advanced';

  @override
  String get cefrNameProficient => 'Proficient';

  @override
  String leaguesTierLeague(String tier) {
    return '$tier League';
  }

  @override
  String leaguesYoureIn(String tier) {
    return 'You\'re in $tier · top 7 climb each week';
  }

  @override
  String get leaguesZonePromotion => '⬆ PROMOTION ZONE';

  @override
  String get leaguesZoneDemotion => '⬇ DEMOTION ZONE';

  @override
  String profileAchievementsSummary(int unlocked, int total) {
    return '$unlocked of $total unlocked · real progress';
  }

  @override
  String get profileRealStateNote =>
      'Level, XP, lessons, streak and saved words are real engine state — they start at zero on a fresh account.';

  @override
  String get practiceTitle => 'Practice';

  @override
  String practiceReviewWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Review $count words',
      one: 'Review 1 word',
    );
    return '$_temp0';
  }

  @override
  String get practiceYourWords => 'Your words';

  @override
  String practiceSavedWordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved words',
      one: '$count saved word',
    );
    return '$_temp0';
  }

  @override
  String practiceDueForReview(int count) {
    return '$count due for spaced review';
  }

  @override
  String get practiceAllUpToDate => 'All reviews up to date';

  @override
  String practiceCaughtUp(String tail) {
    return 'All caught up — nothing due right now$tail.';
  }

  @override
  String practiceNextTail(String when) {
    return ' · next $when';
  }

  @override
  String get practiceZeroDue => '0 due';

  @override
  String get practiceDueNow => 'Due now';

  @override
  String practiceDueWhen(String when) {
    return 'Due $when';
  }

  @override
  String get practiceChipDue => 'Due';

  @override
  String get practiceChipScheduled => 'Scheduled';

  @override
  String get practiceScheduleNote =>
      'Reviews are scheduled by the real FSRS-6 spaced-repetition engine. Due dates persist for this session; saving them across restarts is a go-live step — nothing here is invented.';

  @override
  String get practiceNoSavedWords => 'No saved words yet';

  @override
  String get practiceSaveWordHint =>
      'Save a word while you practice a lesson and it lands here as a flashcard. Reviews are then scheduled by the real FSRS spaced-repetition engine — nothing is pre-filled.';

  @override
  String get practiceStartLesson => 'Start a lesson';

  @override
  String practiceWordOf(int n, int total) {
    return 'Word $n of $total';
  }

  @override
  String get practiceShowAnswer => 'Show answer';

  @override
  String get practiceRecallHint =>
      'Recall the meaning, then grade how well you remembered.';

  @override
  String get practiceGradeAgain => 'Again';

  @override
  String get practiceGradeHard => 'Hard';

  @override
  String get practiceGradeGood => 'Good';

  @override
  String get practiceGradeEasy => 'Easy';

  @override
  String get practiceFsrsGradeNote =>
      'FSRS-6 schedules the next review from your grade';

  @override
  String get practiceReviewComplete => 'Review complete';

  @override
  String practiceReviewedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You reviewed $count words. They are rescheduled by FSRS.',
      one: 'You reviewed 1 word. They are rescheduled by FSRS.',
    );
    return '$_temp0';
  }

  @override
  String get practiceDone => 'Done';

  @override
  String get practiceRelTomorrow => 'tomorrow';

  @override
  String practiceRelInDays(int days) {
    return 'in $days days';
  }

  @override
  String practiceRelInHours(int hours) {
    return 'in ${hours}h';
  }

  @override
  String practiceRelInMinutes(int minutes) {
    return 'in ${minutes}m';
  }

  @override
  String get practiceRelSoon => 'soon';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressShareMilestone => 'Share milestone';

  @override
  String get progressLast7Days => 'Last 7 days';

  @override
  String get progressAccuracyRetention => 'Accuracy & retention';

  @override
  String get progressHonestyNote =>
      'Everything here is real recorded state — level, ability, saved words, XP, lessons, streak, your 7-day history, accuracy and study time all start at zero and grow as you learn. Retention is this session\'s predicted recall (the durable cross-session scheduler is go-live wiring); nothing is invented.';

  @override
  String progressShareText(
    String level,
    String levelName,
    int streak,
    int xp,
    int lessons,
  ) {
    return '🦡 RATEL · Level $level ($levelName)\n🔥 $streak-day streak · ⚡ $xp XP · 📘 $lessons lessons\nLearning at learnwithratel.com';
  }

  @override
  String get progressShareCopied =>
      'Milestone copied to clipboard — share it anywhere!';

  @override
  String progressAbilityLine(String theta) {
    return 'Ability θ $theta · real estimate';
  }

  @override
  String get progressStatSavedWords => 'Saved words';

  @override
  String get progressStatLessons => 'Lessons';

  @override
  String get progressStatDayStreak => 'Day streak';

  @override
  String get progressStatTotalXp => 'Total XP';

  @override
  String get progressStatTodaysXp => 'Today\'s XP';

  @override
  String get progressStatCefrLevel => 'CEFR level';

  @override
  String get progressAccuracy => 'Accuracy';

  @override
  String get progressStudyTime => 'Study time';

  @override
  String get progressRetention => 'Retention';

  @override
  String get progressNoData => 'No data yet';

  @override
  String get progressAccuracyEmpty => 'Answer graded exercises to start';

  @override
  String progressAccuracyDetail(int correct, int total) {
    return '$correct of $total correct';
  }

  @override
  String get progressTimeEmpty => 'Time in lessons adds up here';

  @override
  String get progressTimeDetail => 'across all your lessons';

  @override
  String get progressRetentionEmpty => 'Review items to see predicted recall';

  @override
  String progressRetentionDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'predicted 1-day recall · $count items this session',
      one: 'predicted 1-day recall · 1 item this session',
    );
    return '$_temp0';
  }

  @override
  String progressWeekTotal(int xp) {
    return '$xp XP · last 7 days';
  }

  @override
  String get progressNoXpYet => 'No XP recorded yet';

  @override
  String get progressChartEmptyNote =>
      'Finish a lesson to start your 7-day history — inactive days stay at zero, nothing is invented.';

  @override
  String get commonDowMon => 'Mo';

  @override
  String get commonDowTue => 'Tu';

  @override
  String get commonDowWed => 'We';

  @override
  String get commonDowThu => 'Th';

  @override
  String get commonDowFri => 'Fr';

  @override
  String get commonDowSat => 'Sa';

  @override
  String get commonDowSun => 'Su';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search lessons, words, stories…';

  @override
  String get searchRecent => 'Recent';

  @override
  String get searchClear => 'Clear';

  @override
  String get searchJumpTo => 'Jump to';

  @override
  String get searchTagPage => 'Page';

  @override
  String get searchTagWord => 'Word';

  @override
  String get searchSubtitleSavedWord => 'Saved word';

  @override
  String searchLessonSubtitle(String unit) {
    return '$unit · Lesson';
  }

  @override
  String searchNoMatches(String query) {
    return 'No matches for “$query”';
  }

  @override
  String get searchEmptyNote =>
      'Searching titles, tags and lesson content across your course, saved words and pages. A server content index and trending are the remaining R-L12 fast-follow — nothing here is faked.';

  @override
  String get searchNoMatchNote =>
      'Searches your published course lessons, saved words and app pages (titles + tags). Stories/podcasts and full-text are the R-L12 fast-follow — never faked.';

  @override
  String get searchFooterNote =>
      'Titles + tags at launch. Full-text, stories/podcasts and multi-course scope are the R-L12 fast-follow — never faked.';

  @override
  String get searchDestPracticeHub => 'Practice hub';

  @override
  String get searchDestPracticeHubSub => 'Mistakes, weak words & drills';

  @override
  String get searchDestAiTutor => 'AI Tutor';

  @override
  String get searchDestAiTutorSub => 'Talk, chat & roleplay';

  @override
  String get searchDestAdventures => 'Adventures';

  @override
  String get searchDestAdventuresSub => 'Real conversations — free';

  @override
  String get searchDestLeagues => 'Leagues';

  @override
  String get searchDestLeaguesSub => 'Your weekly league';

  @override
  String get searchDestQuests => 'Quests';

  @override
  String get searchDestQuestsSub => 'Daily goals & quests';

  @override
  String get searchDestProgress => 'Progress';

  @override
  String get searchDestProgressSub => 'Your stats & streak';

  @override
  String get searchDestProfile => 'Profile';

  @override
  String get searchDestProfileSub => 'Your profile';

  @override
  String get searchDestSettings => 'Settings';

  @override
  String get searchDestSettingsSub => 'Account & preferences';

  @override
  String get searchDestShop => 'Shop';

  @override
  String get searchDestShopSub => 'Spend your diamonds';

  @override
  String get searchDestNotifications => 'Notifications';

  @override
  String get searchDestNotificationsSub => 'Your milestone inbox';

  @override
  String get themesTitle => 'Themes';

  @override
  String get themesSubtitle => 'Restyles the whole app — tap to preview live';

  @override
  String themesVehicle(String vehicle) {
    return 'Vehicle · $vehicle';
  }

  @override
  String get tutorHeader => 'Practice a real conversation';

  @override
  String get tutorHeaderSub =>
      'Pick a scene and chat with Ratel — no wrong answers, just practice.';

  @override
  String get tutorTalkTitle => 'Talk to Ratel';

  @override
  String get tutorTalkSub => 'Live voice & video speaking practice';

  @override
  String get tutorChatTitle => 'Chat with Ratel';

  @override
  String get tutorChatSub => 'AI chat · writing feedback';

  @override
  String get tutorRoleplayTitle => 'Roleplay scenes';

  @override
  String get tutorRoleplayGuided => 'Guided roleplay conversations';

  @override
  String tutorScenesCount(int count) {
    return '$count scenes';
  }

  @override
  String get tutorUnlockPro => 'Unlock RATEL PRO';

  @override
  String get tutorRelayNote =>
      'Live AI tutoring runs on a moderated, cost-guarded relay and is a RATEL PRO feature. Replies are never simulated — a mode starts only once PRO and the relay are both active.';

  @override
  String get tutorStatusReadyPro =>
      'PRO active and the live tutor is connected — pick a mode to begin.';

  @override
  String get tutorStatusReadyFree =>
      'The live tutor is connected. Live tutoring is a RATEL PRO feature.';

  @override
  String get tutorStatusOffline =>
      'The moderated live tutor is not connected in this build yet — live tutoring turns on in a later step. Nothing below is simulated.';

  @override
  String get tutorAnnounceNeedsPro => 'RATEL PRO unlocks live AI tutoring.';

  @override
  String get tutorAnnounceNeedsRelay =>
      'AI tutoring connects once the moderated relay is enabled.';

  @override
  String get tutorAnnounceStarting => 'Starting your session…';

  @override
  String get adventuresTitle => 'Adventures';

  @override
  String get adventuresFreeChip => 'FREE';

  @override
  String get adventuresIntro =>
      'Choose your path -- every choice branches the story. No wrong answers, always free.';

  @override
  String get adventuresFallbackWorld => 'Adventure';

  @override
  String adventureSheetKicker(String cefr) {
    return '🗺️ ADVENTURE · $cefr';
  }

  @override
  String adventureScenesCount(int count) {
    return '$count scenes';
  }

  @override
  String adventureChoicePoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count choice points',
      one: '$count choice point',
    );
    return '$_temp0';
  }

  @override
  String get adventureOpeningScene => 'OPENING SCENE';

  @override
  String get adventureStart => 'Start adventure';

  @override
  String get adventuresEmpty => 'No adventures in this course yet.';
}
