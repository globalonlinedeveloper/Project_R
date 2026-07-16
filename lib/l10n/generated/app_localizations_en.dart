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
  String homeSectionN(int n) {
    return 'SECTION $n';
  }

  @override
  String homeSectionLevel(int n, String band) {
    return 'SECTION $n · LEVEL $band';
  }

  @override
  String homeLevelBand(String band) {
    return 'Level $band';
  }

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
  String get libraryAiTutorSub => 'Talk · Chat · Roleplay — live with Ratel';

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
  String get lessonExplainThis => '💡 Explain this';

  @override
  String get lessonMatchPairs => 'Match the pairs';

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
  String get onboardingLanguageSubtitle => 'Learn English from 10 languages';

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
  String get langNameEnglish => 'English';

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
      'Everything else — audio, review, leagues, roleplay and on-device pronunciation — stays free for everyone.';

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
  String get paywallRegionsTier1 => 'US, EU, Japan, Australia';

  @override
  String get paywallRegionsMid => 'Latin America, SE Asia, E. Europe';

  @override
  String get paywallRegionsLowPpp => 'India, Pakistan, Nigeria, Bangladesh';

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
  String get notifBodyLevel4 => 'Advanced (C1) — your English is strong.';

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
  String get progressYourLevel => 'YOUR LEVEL';

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
  String get adventuresHeaderSub => 'Explore a world · talk your way through';

  @override
  String get adventuresHeroTitle => 'Pick a place and dive in';

  @override
  String get adventuresHeroSub =>
      'Every scene is a real conversation — no wrong answers, and it\'s always free.';

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
  String get adventurePlayerFallbackTitle => 'Adventure';

  @override
  String get adventureTheEnd => '🏁 The End';

  @override
  String get adventureStartOver => 'Start over';

  @override
  String get adventureDone => 'Done';

  @override
  String get adventureCompleteKicker => 'ADVENTURE COMPLETE';

  @override
  String adventureCompleteTitle(String title) {
    return '$title ✓';
  }

  @override
  String get adventureCompleteBody =>
      'Nicely done! +15 XP · +5 💎 earned — explore the next scene whenever you like.';

  @override
  String adventureDistrictProgress(int done, int total) {
    return '$done/$total explored';
  }

  @override
  String get adventureDistrictDone => '✓ Done';

  @override
  String get adventureDistrictCafe => 'Café & Food';

  @override
  String get adventureDistrictMarket => 'Market Square';

  @override
  String get adventureDistrictMove => 'On the Move';

  @override
  String get adventureDistrictFriends => 'Making Friends';

  @override
  String get adventuresEmpty => 'No adventures in this course yet.';

  @override
  String get authWelcomeTitle => 'Welcome to Ratel';

  @override
  String get authWelcomeSubtitle =>
      'Lessons, stories, podcasts and more —\npick how you want to start.';

  @override
  String get authCreateFreeAccount => 'Create free account';

  @override
  String get authAlreadyHaveAccount => 'I already have an account';

  @override
  String get authSettingUp => 'Setting things up…';

  @override
  String get authContinueAsGuest => 'Continue as guest';

  @override
  String get authGuestNote =>
      'Guest progress lives on this device — create a free account any time in Settings to keep it everywhere.';

  @override
  String get authEnterYourEmail => 'Enter your email';

  @override
  String get authEnterValidEmail => 'Enter a valid email';

  @override
  String get authEnterYourPassword => 'Enter your password';

  @override
  String get authCouldNotSignIn => 'Could not sign you in. Please try again.';

  @override
  String get authSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get authSocialComingSoon =>
      'Social sign-in (Google / Apple) is coming soon.';

  @override
  String get authResetTitle => 'Reset your password';

  @override
  String get authWelcomeBack => 'Welcome back!';

  @override
  String get authResetSubtitle =>
      'Enter your email and we\'ll send a reset link.';

  @override
  String get authPickUpWhereYouLeft => 'Pick up where you left off';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authPasswordHint => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authSendResetLink => 'Send reset link';

  @override
  String get authLogIn => 'Log in';

  @override
  String get authBackToLogIn => 'Back to log in';

  @override
  String get authNewToRatel => 'New to Ratel? ';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authCheckYourInbox => 'Check your inbox';

  @override
  String authResetSent(String email) {
    return 'We sent a password-reset link to $email. Open it to choose a new password.';
  }

  @override
  String get authCreatePassword => 'Create a password';

  @override
  String get authAtLeast8Chars => 'At least 8 characters';

  @override
  String get authCreateYourAccount => 'Create your account';

  @override
  String get authSignupSubtitle =>
      'Free forever · learn English from 10 languages';

  @override
  String get authPassword8Hint => 'Password (8+ characters)';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authAlreadyAccountLead => 'Already have an account? ';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authConfirmEmail => 'Confirm your email';

  @override
  String authConfirmSent(String email) {
    return 'We sent a confirmation link to $email. Tap it to activate your account, then come back to log in.';
  }

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authContinueApple => 'Continue with Apple';

  @override
  String get authOr => 'or';

  @override
  String get authUnavailableNote =>
      'Accounts aren’t available in this build yet — you can keep learning as a guest. Sign-in turns on when the backend is configured.';

  @override
  String get liveMute => 'Mute';

  @override
  String get liveUnmute => 'Unmute';

  @override
  String commonDurSeconds(int s) {
    return '${s}s';
  }

  @override
  String commonDurMinutes(int m) {
    return '${m}m';
  }

  @override
  String commonDurHours(int h) {
    return '${h}h';
  }

  @override
  String commonDurHoursMinutes(int h, int m) {
    return '${h}h ${m}m';
  }

  @override
  String practiceGradeInterval(String label, int days) {
    return '$label · ${days}d';
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

  @override
  String get leaguesSoloCaption => 'this week · solo group';

  @override
  String leaguesXpToRank(int xp, int rank) {
    return '$xp XP to rank $rank';
  }

  @override
  String get leaguesLeading => 'leading your group';

  @override
  String get leaguesSoloNote =>
      'You\'re the only learner in your group this week. Real rivals join as Ratel grows — no bots, no fake leaderboards. Keep earning XP to be ready to climb when the week resets.';

  @override
  String questsGoalLine(int today, int goal) {
    return '$today / $goal XP · goal reached';
  }

  @override
  String questsGoalRemaining(int today, int goal, int remaining) {
    return '$today / $goal XP · $remaining XP to go';
  }

  @override
  String get worldLabelLight => 'Daylight';

  @override
  String get worldVehicleLight => 'Scooter';

  @override
  String get worldLabelGalaxy => 'Space';

  @override
  String get worldVehicleGalaxy => 'Star pod';

  @override
  String get worldLabelSavanna => 'Savanna';

  @override
  String get worldVehicleSavanna => 'Safari jeep';

  @override
  String get worldLabelOcean => 'Ocean';

  @override
  String get worldVehicleOcean => 'Submarine';

  @override
  String get worldLabelForest => 'Forest';

  @override
  String get worldVehicleForest => 'Leaf glider';

  @override
  String get worldLabelCandy => 'Candy';

  @override
  String get worldVehicleCandy => 'Balloon';

  @override
  String get worldLabelNeon => 'Neon City';

  @override
  String get worldVehicleNeon => 'Hover-bike';

  @override
  String get worldLabelStorm => 'Rainstorm';

  @override
  String get worldVehicleStorm => 'Storm glider';

  @override
  String get worldLabelSnow => 'Winter';

  @override
  String get worldVehicleSnow => 'Snow sled';

  @override
  String get worldLabelSakura => 'Cherry Blossom';

  @override
  String get worldVehicleSakura => 'Petal kite';

  @override
  String get worldLabelAutumn => 'Autumn';

  @override
  String get worldVehicleAutumn => 'Leaf-cart';

  @override
  String get worldLabelAurora => 'Aurora';

  @override
  String get worldVehicleAurora => 'Aurora skiff';

  @override
  String get worldLabelVolcano => 'Volcano';

  @override
  String get worldVehicleVolcano => 'Magma board';

  @override
  String get worldLabelSunset => 'Sunset';

  @override
  String get worldVehicleSunset => 'Glider';

  @override
  String get worldLabelDesert => 'Desert';

  @override
  String get worldVehicleDesert => 'Dune buggy';

  @override
  String get worldLabelReef => 'Coral Reef';

  @override
  String get worldVehicleReef => 'Glass boat';

  @override
  String get worldLabelMeadow => 'Meadow';

  @override
  String get worldVehicleMeadow => 'Bicycle';

  @override
  String get worldLabelDawn => 'Dawn';

  @override
  String get worldVehicleDawn => 'Sky balloon';

  @override
  String get worldLabelBeach => 'Tropical Beach';

  @override
  String get worldVehicleBeach => 'Catamaran';

  @override
  String get worldLabelMars => 'Mars';

  @override
  String get worldVehicleMars => 'Rover';

  @override
  String get worldLabelJungle => 'Rainforest';

  @override
  String get worldVehicleJungle => 'Zipline';

  @override
  String get worldLabelCyberrain => 'Cyber Rain';

  @override
  String get worldVehicleCyberrain => 'Hover-bike';

  @override
  String get worldLabelAbyss => 'Deep Sea';

  @override
  String get worldVehicleAbyss => 'Bathysphere';

  @override
  String get worldLabelAlpine => 'Alpine';

  @override
  String get worldVehicleAlpine => 'Cable car';

  @override
  String get worldLabelLavender => 'Lavender';

  @override
  String get worldVehicleLavender => 'Vespa';

  @override
  String get worldLabelBamboo => 'Bamboo Grove';

  @override
  String get worldVehicleBamboo => 'Rickshaw';

  @override
  String get worldLabelLagoon => 'Lagoon Night';

  @override
  String get worldVehicleLagoon => 'Kayak';

  @override
  String get worldLabelThunder => 'Thunderhead';

  @override
  String get worldVehicleThunder => 'Storm chaser';

  @override
  String get worldLabelNebula => 'Nebula';

  @override
  String get worldVehicleNebula => 'Star cruiser';

  @override
  String get worldLabelSandstorm => 'Sandstorm';

  @override
  String get worldVehicleSandstorm => 'Caravan';

  @override
  String get worldLabelCherrynight => 'Cherry Night';

  @override
  String get worldVehicleCherrynight => 'Paper lantern';

  @override
  String get shopYourBadger => 'Your badger';

  @override
  String get shopDiamondsNote =>
      'A real-money 💎 top-up is coming. Diamonds are earned by finishing lessons and meeting your daily goal, and every power-up here spends them for real — nothing is faked.';

  @override
  String get shopProBannerSub => 'Live AI, no ads, offline · Try 7 days free';

  @override
  String get shopYourDiamonds => 'Your diamonds';

  @override
  String get shopEquipped => 'Equipped';

  @override
  String get shopEquip => 'Equip';

  @override
  String shopEquippedSnack(String name, String emoji) {
    return 'Equipped $name $emoji';
  }

  @override
  String get shopFree => 'Free';

  @override
  String get outfitClassic => 'Classic';

  @override
  String get outfitScholar => 'Scholar';

  @override
  String get outfitExplorer => 'Explorer';

  @override
  String get outfitAstronaut => 'Astronaut';

  @override
  String get outfitWizard => 'Wizard';

  @override
  String paywallAnnualLine(String annual, String perMonth) {
    return '$annual/yr  ·  $perMonth/mo  ·  7 days free';
  }

  @override
  String paywallMonthlyLine(String monthly) {
    return '$monthly/mo  ·  billed monthly';
  }

  @override
  String paywallSavePercent(int percent) {
    return 'SAVE $percent%';
  }

  @override
  String get paywallIncluded => 'What\'s included with Pro';

  @override
  String get paywallTerms => 'Terms';

  @override
  String get paywallPrivacy => 'Privacy';

  @override
  String get paywallNothingToRestore =>
      'Nothing to restore — billing isn\'t live in this build yet.';

  @override
  String get contentUnavailableTitle => 'Content unavailable';

  @override
  String contentUnavailableBody(String noun) {
    return 'This $noun is not available right now. If you are offline, check your connection and try again.';
  }

  @override
  String get contentNounStory => 'story';

  @override
  String get contentNounPodcast => 'podcast';

  @override
  String get contentNounVideo => 'video';

  @override
  String get contentNounAdventure => 'adventure';

  @override
  String get contentNounRoleplay => 'roleplay';

  @override
  String get commonGoBack => 'Go back';

  @override
  String get placementTitle => 'Placement test';

  @override
  String placementQuestionN(int n) {
    return 'Question $n';
  }

  @override
  String get placementResultTitle => 'Your starting point';

  @override
  String placementResultBody(int count, String level) {
    return 'Based on $count questions, we placed you at $level. You can always adjust later.';
  }

  @override
  String get lessonTypedNote => 'Type your answer in the target language.';

  @override
  String lessonHintMinWords(int count) {
    return 'at least $count words';
  }

  @override
  String lessonHintUseWords(String words) {
    return 'use: $words';
  }

  @override
  String get lessonHintEndPunct => 'end with . ! or ?';

  @override
  String get lessonPlayAudio => 'Play audio';

  @override
  String get lessonPlaySlowly => 'Play slowly';

  @override
  String get lessonAudioUnavailable => 'Audio unavailable — read the prompt.';

  @override
  String get lessonPlaybackSpeed => 'Playback speed';

  @override
  String get authAccountsUnavailable =>
      'Accounts are not available in this build yet — keep learning as a guest.';

  @override
  String get liveNotEnabledShort => 'live AI is not enabled in this build.';

  @override
  String get liveMicUnavailable =>
      'microphone unavailable — allow mic access to talk with the tutor.';

  @override
  String get liveUnavailable => 'live AI is unavailable right now.';

  @override
  String get liveNeedsPro => 'Live AI is part of RATEL PRO.';

  @override
  String get liveMinutesUsed => 'You\'ve used this month\'s live minutes.';

  @override
  String get commonNetworkError => 'Could not reach the server. Try again.';

  @override
  String get friendsHandleTaken => 'That @handle is already taken.';

  @override
  String get friendsHandleFormat =>
      'Use 2–20 letters, numbers or _ for your handle.';

  @override
  String get friendsSignInForHandle => 'Sign in to claim your @handle.';

  @override
  String get friendsSetOwnHandleFirst =>
      'Set your own @handle first (Edit profile).';

  @override
  String get paywallCheckoutUnavailable =>
      'Checkout opens at launch — store billing isn\'t live in this build yet.';

  @override
  String get settingsManageUnavailable =>
      'Manage or cancel in your device\'s Subscriptions settings — the in-app shortcut opens at launch.';

  @override
  String get friendsAdd => 'Add';

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
  String coursesSwitchedTo(String language) {
    return 'Switched to $language';
  }

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
