// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get navHome => 'होम';

  @override
  String get navLibrary => 'लाइब्रेरी';

  @override
  String get navLeagues => 'लीग';

  @override
  String get navQuests => 'क्वेस्ट';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsSectionLearning => 'सीखना';

  @override
  String get settingsSectionSubscription => 'सदस्यता';

  @override
  String get settingsSectionAccessibility => 'सुलभता';

  @override
  String get settingsSectionNotifications => 'सूचनाएँ';

  @override
  String get settingsSectionAppearanceAccount => 'रूप और खाता';

  @override
  String get settingsAppLanguage => 'ऐप की भाषा';

  @override
  String get settingsAppLanguageSystem => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get homeCourseLoadingTitle => 'आपका कोर्स तैयार हो रहा है';

  @override
  String get homeCourseLoadingBody =>
      'कोर्स सामग्री लोड होते ही पाठ यहाँ दिखेंगे।';

  @override
  String get homeGuideChip => 'गाइड';

  @override
  String get homeStartNode => 'शुरू करें';

  @override
  String get homeUnitGuideHeader => 'इकाई गाइड';

  @override
  String get commonDone => 'हो गया';

  @override
  String homeUnitKicker(String unit) {
    return 'इकाई · $unit';
  }

  @override
  String homeLessonMeta(int num, int count, String exercises) {
    return 'पाठ $num / $count · $exercises।';
  }

  @override
  String homeQuickExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count त्वरित अभ्यास',
      one: '$count त्वरित अभ्यास',
    );
    return '$_temp0';
  }

  @override
  String get homeEnergyChip => '−1 ⚡ ऊर्जा';

  @override
  String get homeXpChip => '+20 XP';

  @override
  String get homeStartLesson => 'पाठ शुरू करें';

  @override
  String get homeTutorChip => 'ट्यूटर';

  @override
  String get libraryAiTutor => 'AI ट्यूटर';

  @override
  String get libraryAiTutorSub => 'बात करें, चैट और रोलप्ले — लेखन प्रतिक्रिया';

  @override
  String get libraryRoleplay => 'रोलप्ले';

  @override
  String get libraryRoleplaySub => 'जवाबों का अभ्यास — ग्रेडेड, हमेशा मुफ़्त';

  @override
  String get librarySectionPractice => 'अभ्यास';

  @override
  String get libraryPracticeHub => 'अभ्यास केंद्र';

  @override
  String get libraryPracticeHubSub => 'गलतियाँ, कमज़ोर शब्द और ड्रिल · मुफ़्त';

  @override
  String get librarySectionReadListen => 'पढ़ें और सुनें';

  @override
  String get libraryGradedStories => 'स्तरीय कहानियाँ';

  @override
  String get libraryPodcasts => 'पॉडकास्ट';

  @override
  String get libraryWatch => 'देखें';

  @override
  String get librarySearchHint => 'पाठ, शब्द, कहानियाँ खोजें…';

  @override
  String get libraryFeaturedStory => 'विशेष · कहानी';

  @override
  String commonLevel(String cefr) {
    return 'स्तर $cefr';
  }

  @override
  String get libraryReadNow => 'अभी पढ़ें';

  @override
  String get libraryNewExplore => 'नया · एक्सप्लोर';

  @override
  String get libraryAdventures => 'एडवेंचर';

  @override
  String get libraryStartExploring => 'एक्सप्लोर करना शुरू करें →';

  @override
  String get libraryKindStory => 'कहानी';

  @override
  String get libraryKindPodcast => 'पॉडकास्ट';

  @override
  String get libraryKindVideo => 'वीडियो';

  @override
  String get libraryAllStories => 'सभी कहानियाँ';

  @override
  String get libraryAllPodcasts => 'सभी पॉडकास्ट';

  @override
  String get libraryAllVideos => 'सभी वीडियो';

  @override
  String get lessonTypeWhatYouHear => 'जो सुनें वह लिखें';

  @override
  String get lessonTapWhatYouHear => 'जो सुनें उसे चुनें';

  @override
  String get lessonTranslateSentence => 'इस वाक्य का अनुवाद करें';

  @override
  String get lessonTypeAnswerHint => 'अपना उत्तर लिखें…';

  @override
  String get lessonWriteAnswerHint => 'अपना उत्तर लिखें…';

  @override
  String get lessonContinue => 'आगे बढ़ें';

  @override
  String get lessonSkip => 'छोड़ें';

  @override
  String get lessonCheck => 'जाँचें';

  @override
  String get lessonNicelyDone => '✓ बहुत बढ़िया!';

  @override
  String get lessonNotQuite => '✕ बिल्कुल नहीं';

  @override
  String lessonAnswerReveal(String answer) {
    return 'उत्तर: $answer';
  }

  @override
  String get lessonCompleteKicker => 'पाठ पूर्ण';

  @override
  String get lessonCompleteTitle => 'पाठ पूरा हुआ!';

  @override
  String lessonCompleteSummary(int correct, int graded, String level) {
    return '$graded में से $correct सही · अब $level';
  }

  @override
  String get lessonStatTotalXp => 'कुल XP';

  @override
  String get lessonStatAccuracy => 'सटीकता';

  @override
  String get lessonStatTime => 'समय';

  @override
  String get onboardingWelcomeTitle => 'नमस्ते, मैं रेटल हूँ!';

  @override
  String get onboardingWelcomeBody =>
      'बिना डरे भाषा सीखें — छोटे-छोटे पाठ, मज़ेदार और मुफ़्त। शुरू करें?';

  @override
  String get onboardingHaveAccount => 'मेरा खाता पहले से है';

  @override
  String get onboardingTryWithoutAccount => 'बिना खाते के आज़माएँ →';

  @override
  String get onboardingGetStarted => 'शुरू करें';

  @override
  String get onboardingStartLearning => 'सीखना शुरू करें';

  @override
  String get onboardingLanguageTitle => 'आप क्या सीखना चाहते हैं?';

  @override
  String get onboardingLanguageSubtitle => '52 भाषाएँ उपलब्ध';

  @override
  String get onboardingReasonTitle => 'आप क्यों सीख रहे हैं?';

  @override
  String get onboardingGoalTitle => 'दैनिक लक्ष्य चुनें';

  @override
  String get onboardingPlacementTitle => 'अपनी शुरुआत का स्तर खोजें';

  @override
  String onboardingPlacementBody(String language) {
    return '$language में नए हैं, या कुछ पहले से जानते हैं?';
  }

  @override
  String get onboardingBrandNew => 'मैं बिल्कुल नया हूँ';

  @override
  String get onboardingBrandNewSub => 'एकदम शुरुआत से शुरू करें';

  @override
  String get onboardingPlacementTest => 'प्लेसमेंट टेस्ट दें';

  @override
  String get onboardingPlacementTestSub => '~3 मिनट · अपने स्तर तक पहुँचें';

  @override
  String onboardingXpPerDay(int xp) {
    return '$xp XP / दिन';
  }

  @override
  String get reasonTravel => 'यात्रा';

  @override
  String get reasonCulture => 'संस्कृति';

  @override
  String get reasonCareer => 'करियर';

  @override
  String get reasonFamilyFriends => 'परिवार और दोस्त';

  @override
  String get reasonBrainTraining => 'दिमाग़ी कसरत';

  @override
  String get reasonJustForFun => 'बस मज़े के लिए';

  @override
  String get goalCasual => 'आराम से';

  @override
  String get goalRegular => 'नियमित';

  @override
  String get goalSerious => 'गंभीर';

  @override
  String get goalIntense => 'गहन';

  @override
  String get langNameSpanish => 'स्पेनिश';

  @override
  String get langNameFrench => 'फ़्रेंच';

  @override
  String get langNameJapanese => 'जापानी';

  @override
  String get langNameTamil => 'तमिल';

  @override
  String get langNameGerman => 'जर्मन';

  @override
  String get langNameKorean => 'कोरियाई';

  @override
  String get settingsDailyGoal => 'दैनिक लक्ष्य';

  @override
  String settingsGoalRow(String label, int xp) {
    return '$label · $xp XP/दिन';
  }

  @override
  String get profileAchievements => 'उपलब्धियाँ';

  @override
  String get profileFriends => 'दोस्त';

  @override
  String get profileShop => 'दुकान';

  @override
  String get profileNotifications => 'सूचनाएँ';

  @override
  String get profileSeeOnboarding => 'ऑनबोर्डिंग फ़्लो देखें ↗';

  @override
  String get profileNotSignedIn => 'साइन इन नहीं';

  @override
  String get profileCreateAccount => 'मुफ़्त खाता बनाएँ';

  @override
  String get profileSaveProgress => 'अपनी प्रगति सभी डिवाइस पर सहेजें';

  @override
  String profileTodaysGoal(int today, int goal) {
    return 'आज का लक्ष्य · $today/$goal XP';
  }

  @override
  String get profileViewProgress => 'प्रगति देखें →';

  @override
  String get profileUnlocked => 'अनलॉक';

  @override
  String questsResetsIn(int h, int m) {
    return '$hघं $mमि में रीसेट';
  }

  @override
  String get questsDailyRefresh => 'दैनिक रिफ़्रेश';

  @override
  String get questsFreshMix => '5 सवालों का ताज़ा मिश्रण';

  @override
  String get questsServedFromQueue =>
      'आपकी असली रिवीज़न कतार से — असली XP मिलता है।';

  @override
  String get questsGoalReached => 'दैनिक लक्ष्य पूरा! 🎉';

  @override
  String questsReachGoal(int goal) {
    return 'आज $goal XP पाएँ';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return 'दैनिक क्वेस्ट · $done/$total';
  }

  @override
  String get questsInfoNote =>
      'क्वेस्ट आपकी असली दैनिक प्रगति दिखाते हैं। रिवॉर्ड चेस्ट, फ्रेंड क्वेस्ट और साप्ताहिक लीडरबोर्ड के लिए बैकएंड इकॉनमी चाहिए — मालिक का निर्णय (§6)। कोई नकली इनाम नहीं दिखाया जाता।';

  @override
  String get questsStartRefresh => 'दैनिक रिफ़्रेश शुरू करें';

  @override
  String get questsStart => 'शुरू';

  @override
  String get questsPractisedToday => 'आज अभ्यास हुआ — स्ट्रीक सुरक्षित';

  @override
  String get questsEarnAnyXp => 'आज कोई भी XP कमाएँ';

  @override
  String questsXpToday(int current, int target) {
    return 'आज $current/$target XP';
  }

  @override
  String get leaguesYourGroup => 'आपका समूह';

  @override
  String leaguesThisWeek(int size) {
    return 'इस सप्ताह · $size शिक्षार्थी';
  }

  @override
  String get leaguesTiers => 'लीग स्तर';

  @override
  String leaguesTopClimb(int top, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिन',
      one: '$days दिन',
    );
    return 'हर हफ़्ते शीर्ष $top ऊपर जाते हैं · समाप्ति $_temp0 में';
  }

  @override
  String get leaguesDemotionZone => 'अवनति क्षेत्र';

  @override
  String get leaguesPromotionZone => 'पदोन्नति क्षेत्र';

  @override
  String get leaguesSafeZone => 'सुरक्षित क्षेत्र';

  @override
  String get leaguesYou => 'आप';

  @override
  String leaguesPromoteRelegate(int top, int bottom) {
    return 'सप्ताह के अंत में शीर्ष $top ऊपर · नीचे के $bottom नीचे जाते हैं।';
  }

  @override
  String get leaguesYouAreHere => 'आप यहाँ हैं';

  @override
  String get leaguesViewAllTiers => '🏆 सभी 10 स्तर देखें ›';

  @override
  String get notifMarkAllRead => 'सभी को पढ़ा हुआ चिह्नित करें';

  @override
  String get notifEmptyTitle => 'अभी कोई सूचना नहीं';

  @override
  String get notifEmptyBody =>
      'पाठ पूरे करें, स्ट्रीक बनाएँ और स्तर बढ़ाएँ — आपकी उपलब्धियाँ सच में हासिल होते ही यहाँ दिखेंगी।';

  @override
  String get notifPushNote =>
      'ये ऐप के अंदर की उपलब्धियाँ हैं, कमाते ही दिखाई देती हैं। पुश सूचनाएँ और रिमाइंडर मालिक का निर्णय हैं और अभी चालू नहीं — यहाँ कुछ भी नकली नहीं है।';

  @override
  String get shopPowerUps => 'पावर-अप';

  @override
  String get shopStreakFreeze => 'स्ट्रीक फ़्रीज़';

  @override
  String get shopStreakFreezeDesc =>
      'एक छूटे दिन पर आपकी स्ट्रीक बचाता है। दैनिक लक्ष्य चूकने पर अपने आप खर्च होता है।';

  @override
  String shopOwned(int have, int max) {
    return 'पास में: $have/$max';
  }

  @override
  String get shopMaxedOut => 'अधिकतम';

  @override
  String shopBuyFor(int cost) {
    return '$cost 💎 में खरीदें';
  }

  @override
  String get shopFreezeAdded => 'स्ट्रीक फ़्रीज़ जुड़ा 💪';

  @override
  String shopFreezeAtCap(int max) {
    return 'आपके पास पहले से अधिकतम फ़्रीज़ हैं ($max)।';
  }

  @override
  String shopNotEnoughEarnCost(int cost) {
    return 'पर्याप्त 💎 नहीं — पाठ पूरे करके $cost कमाएँ।';
  }

  @override
  String get shopNotEnoughEarnMore =>
      'पर्याप्त 💎 नहीं — पाठ पूरे करके और कमाएँ।';

  @override
  String get shopEnergyRefill => 'ऊर्जा रिफ़िल';

  @override
  String get shopEnergyRefillDesc =>
      'अपनी ऊर्जा तुरंत पूरी करें। ऊर्जा केवल दिखावटी है — पाठ कभी नहीं रुकते।';

  @override
  String get shopAlreadyFull => 'पहले से भरी';

  @override
  String get shopEnergyRefilled => 'ऊर्जा भर गई ⚡';

  @override
  String get shopEnergyAlreadyFull => 'आपकी ऊर्जा पहले से पूरी है।';

  @override
  String get shopStreakRepair => 'स्ट्रीक मरम्मत';

  @override
  String get shopStreakRepairDesc =>
      'स्ट्रीक खो गई? उसे पिछली लंबाई पर लौटाएँ और सिलसिला जारी रखें।';

  @override
  String get shopStreakLapsed => 'स्ट्रीक टूटी';

  @override
  String shopStreakDays(int days) {
    return '🔥 $days-दिन की स्ट्रीक';
  }

  @override
  String shopRepairFor(int cost) {
    return '$cost 💎 में मरम्मत';
  }

  @override
  String get shopStreakRestored => 'स्ट्रीक बहाल 🔥';

  @override
  String get shopStreakSafe =>
      'आपकी स्ट्रीक सुरक्षित है — अभी मरम्मत की ज़रूरत नहीं।';

  @override
  String get shopDoubleXp => 'डबल XP';

  @override
  String get shopDoubleXpDesc => '15 मिनट तक हर पाठ से 2× XP कमाएँ।';

  @override
  String shopActiveLeft(int minutes) {
    return 'सक्रिय · $minutesमि बचे';
  }

  @override
  String get shopInactive => 'निष्क्रिय';

  @override
  String get shopActive => 'सक्रिय';

  @override
  String get shopDoubleXpActive => 'डबल XP सक्रिय ✨';

  @override
  String get shopBoostRunning => 'आपका बूस्ट चल रहा है — XP दोगुना हो रहा है।';

  @override
  String get shopBadgerOutfits => 'बैजर पोशाकें';

  @override
  String get paywallTitle => 'RATEL PRO';

  @override
  String get paywallStartTrial => '7-दिन की मुफ़्त ट्रायल शुरू करें';

  @override
  String paywallGoPro(String price) {
    return 'Pro बनें — $price/माह';
  }

  @override
  String get paywallRestore => 'खरीदारी बहाल करें';

  @override
  String get paywallHero => 'लाइव AI ट्यूटरिंग, विज्ञापन-मुक्त और ऑफ़लाइन पाठ।';

  @override
  String get paywallAnnual => 'वार्षिक';

  @override
  String get paywallMonthly => 'मासिक';

  @override
  String get paywallTrialHow => '7-दिन की मुफ़्त ट्रायल कैसे काम करती है';

  @override
  String get paywallTrialToday => 'आज';

  @override
  String get paywallTrialTodayDesc =>
      'पूरा Pro एक्सेस खुलता है। कोई शुल्क नहीं।';

  @override
  String get paywallTrialDay5 => 'दिन 5';

  @override
  String get paywallTrialDay5Desc =>
      'ट्रायल खत्म होने से पहले हम याद दिलाते हैं।';

  @override
  String get paywallTrialDay7 => 'दिन 7';

  @override
  String paywallTrialDay7Desc(String price) {
    return 'रद्द न करने पर $price/वर्ष शुरू होता है।';
  }

  @override
  String get paywallFeatureLiveAi =>
      'लाइव AI: आवाज़, ट्यूटर चैट और लेखन प्रतिक्रिया';

  @override
  String get paywallFeatureNoAds => 'कहीं भी विज्ञापन नहीं';

  @override
  String get paywallFeatureOffline => 'ऑफ़लाइन पाठ और ऑडियो';

  @override
  String get paywallFeaturePronunciation => 'AI उच्चारण कोचिंग सुझाव';

  @override
  String get paywallEverythingFree =>
      'बाकी सब — सभी 52 भाषाएँ, ऑडियो, रिवीज़न, लीग, रोलप्ले और ऑन-डिवाइस उच्चारण — सबके लिए मुफ़्त रहता है।';

  @override
  String get paywallYouArePro => 'आप RATEL PRO पर हैं';

  @override
  String get paywallThanks =>
      'Ratel को समर्थन देने के लिए धन्यवाद। सेटिंग्स → सदस्यता प्रबंधन से कभी भी प्रबंधित या रद्द करें।';

  @override
  String get paywallManage => 'सदस्यता प्रबंधित करें';

  @override
  String paywallFinePrint(String regions) {
    return 'सेटिंग्स में कभी भी रद्द करें। दिखाए गए दाम $regions के लिए हैं; आपका स्थानीय दाम आपका ऐप स्टोर तय करता है।';
  }

  @override
  String get questTitlePowerSession => 'पावर सेशन';

  @override
  String get questDescPowerSession => 'अपने दैनिक लक्ष्य का दोगुना कमाएँ';

  @override
  String get questTitleOnFire => 'जोश में';

  @override
  String get questDescOnFire => 'अपने दैनिक लक्ष्य का तिगुना कमाएँ';

  @override
  String get questTitleStreakKeeper => 'स्ट्रीक रक्षक';

  @override
  String get questDescStreakKeeper => 'स्ट्रीक बनाए रखने के लिए आज अभ्यास करें';

  @override
  String get notifTitleLessons1 => 'पहला पाठ पूरा';

  @override
  String get notifBodyLessons1 =>
      'आपने अपना पहला पाठ पूरा किया — शानदार शुरुआत!';

  @override
  String get notifTitleLessons5 => '5 पाठ पूरे';

  @override
  String get notifBodyLessons5 => 'आपने 5 पाठ पूरे कर लिए हैं। गति बनाए रखें।';

  @override
  String get notifTitleLessons10 => '10 पाठ पूरे';

  @override
  String get notifBodyLessons10 => 'दस पाठ — आप एक सच्ची आदत बना रहे हैं।';

  @override
  String get notifTitleLessons25 => '25 पाठ पूरे';

  @override
  String get notifBodyLessons25 => 'पच्चीस पाठ पूरे। प्रभावशाली समर्पण!';

  @override
  String get notifTitleLessons50 => '50 पाठ पूरे';

  @override
  String get notifBodyLessons50 => 'पचास पाठ — आप सही राह पर हैं।';

  @override
  String get notifTitleStreak3 => '3 दिन की स्ट्रीक!';

  @override
  String get notifBodyStreak3 => 'लगातार तीन दिन। निरंतरता ही सब कुछ है।';

  @override
  String get notifTitleStreak7 => '7 दिन की स्ट्रीक!';

  @override
  String get notifBodyStreak7 => 'रोज़ अभ्यास का पूरा एक हफ़्ता। शानदार!';

  @override
  String get notifTitleStreak14 => '14 दिन की स्ट्रीक!';

  @override
  String get notifBodyStreak14 => 'लगातार दो हफ़्ते — आप अजेय हैं।';

  @override
  String get notifTitleStreak30 => '30 दिन की स्ट्रीक!';

  @override
  String get notifBodyStreak30 => 'रोज़ अभ्यास का पूरा एक महीना। अविश्वसनीय।';

  @override
  String get notifTitleXp100 => '100 XP अर्जित';

  @override
  String get notifBodyXp100 => 'आपके पहले सौ XP — गति बढ़ रही है।';

  @override
  String get notifTitleXp500 => '500 XP अर्जित';

  @override
  String get notifBodyXp500 => 'पाँच सौ XP। आप मेहनत कर रहे हैं।';

  @override
  String get notifTitleXp1000 => '1,000 XP अर्जित';

  @override
  String get notifBodyXp1000 => 'एक हज़ार XP का पड़ाव पूरा!';

  @override
  String get notifTitleXp2500 => '2,500 XP अर्जित';

  @override
  String get notifBodyXp2500 => 'ढाई हज़ार XP — गंभीर प्रगति।';

  @override
  String get notifTitleLevel1 => 'स्तर A2 पर पहुँचे';

  @override
  String get notifBodyLevel1 => 'आपकी क्षमता A1 से A2 हो गई। आगे बढ़ें!';

  @override
  String get notifTitleLevel2 => 'स्तर B1 पर पहुँचे';

  @override
  String get notifBodyLevel2 => 'अब आप मध्यम स्तर के शिक्षार्थी हैं (B1)।';

  @override
  String get notifTitleLevel3 => 'स्तर B2 पर पहुँचे';

  @override
  String get notifBodyLevel3 => 'उच्च-मध्यम (B2) पर पहुँचे। शानदार।';

  @override
  String get notifTitleLevel4 => 'स्तर C1 पर पहुँचे';

  @override
  String get notifBodyLevel4 => 'उन्नत (C1) — आपकी स्पैनिश मज़बूत है।';

  @override
  String get notifTitleLevel5 => 'स्तर C2 पर पहुँचे';

  @override
  String get notifBodyLevel5 => 'प्रवीणता (C2) — पैमाने का शिखर!';

  @override
  String get achTitleFirstSteps => 'पहले क़दम';

  @override
  String get achTitleScholar => 'विद्वान';

  @override
  String get achTitleWildfire => 'दावानल';

  @override
  String get achTitlePointMaker => 'पॉइंट मेकर';

  @override
  String get achTitleCollector => 'संग्राहक';

  @override
  String get achTitleRisingStar => 'उभरता सितारा';

  @override
  String get leagueTierBronze => 'कांस्य';

  @override
  String get leagueTierSilver => 'रजत';

  @override
  String get leagueTierGold => 'स्वर्ण';

  @override
  String get leagueTierSapphire => 'नीलम';

  @override
  String get leagueTierRuby => 'माणिक';

  @override
  String get leagueTierEmerald => 'पन्ना';

  @override
  String get leagueTierAmethyst => 'एमेथिस्ट';

  @override
  String get leagueTierPearl => 'मोती';

  @override
  String get leagueTierObsidian => 'ऑब्सिडियन';

  @override
  String get leagueTierDiamond => 'हीरा';

  @override
  String get cefrNameBeginner => 'शुरुआती';

  @override
  String get cefrNameElementary => 'प्रारंभिक';

  @override
  String get cefrNameIntermediate => 'मध्यम';

  @override
  String get cefrNameUpperIntermediate => 'उच्च-मध्यम';

  @override
  String get cefrNameAdvanced => 'उन्नत';

  @override
  String get cefrNameProficient => 'प्रवीण';

  @override
  String leaguesTierLeague(String tier) {
    return '$tier लीग';
  }

  @override
  String leaguesYoureIn(String tier) {
    return 'आप $tier में हैं · शीर्ष 7 हर हफ़्ते ऊपर जाते हैं';
  }

  @override
  String get leaguesZonePromotion => '⬆ पदोन्नति क्षेत्र';

  @override
  String get leaguesZoneDemotion => '⬇ अवनति क्षेत्र';

  @override
  String profileAchievementsSummary(int unlocked, int total) {
    return '$total में से $unlocked अनलॉक · वास्तविक प्रगति';
  }

  @override
  String get profileRealStateNote =>
      'स्तर, XP, पाठ, स्ट्रीक और सहेजे गए शब्द असली इंजन स्थिति हैं — नए खाते में ये शून्य से शुरू होते हैं।';

  @override
  String get practiceTitle => 'अभ्यास';

  @override
  String practiceReviewWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count शब्द दोहराएँ',
      one: '1 शब्द दोहराएँ',
    );
    return '$_temp0';
  }

  @override
  String get practiceYourWords => 'आपके शब्द';

  @override
  String practiceSavedWordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सहेजे गए शब्द',
      one: '$count सहेजा गया शब्द',
    );
    return '$_temp0';
  }

  @override
  String practiceDueForReview(int count) {
    return '$count स्पेस्ड दोहराव के लिए बाकी';
  }

  @override
  String get practiceAllUpToDate => 'सभी दोहराव अप-टू-डेट';

  @override
  String practiceCaughtUp(String tail) {
    return 'सब पूरा — अभी कुछ बाकी नहीं$tail।';
  }

  @override
  String practiceNextTail(String when) {
    return ' · अगला $when';
  }

  @override
  String get practiceZeroDue => '0 बाकी';

  @override
  String get practiceDueNow => 'अभी बाकी';

  @override
  String practiceDueWhen(String when) {
    return 'बाकी $when';
  }

  @override
  String get practiceChipDue => 'बाकी';

  @override
  String get practiceChipScheduled => 'निर्धारित';

  @override
  String get practiceScheduleNote =>
      'दोहराव असली FSRS-6 स्पेस्ड-रिपीटिशन इंजन तय करता है। तिथियाँ इस सत्र तक रहती हैं; इन्हें रीस्टार्ट के बाद सहेजना गो-लाइव का चरण है — यहाँ कुछ भी गढ़ा हुआ नहीं है।';

  @override
  String get practiceNoSavedWords => 'अभी कोई सहेजा शब्द नहीं';

  @override
  String get practiceSaveWordHint =>
      'पाठ का अभ्यास करते हुए कोई शब्द सहेजें और वह यहाँ फ़्लैशकार्ड बनकर आएगा। फिर असली FSRS स्पेस्ड-रिपीटिशन इंजन दोहराव तय करेगा — कुछ भी पहले से भरा नहीं है।';

  @override
  String get practiceStartLesson => 'पाठ शुरू करें';

  @override
  String practiceWordOf(int n, int total) {
    return 'शब्द $n / $total';
  }

  @override
  String get practiceShowAnswer => 'उत्तर दिखाएँ';

  @override
  String get practiceRecallHint =>
      'अर्थ याद करें, फिर आँकें कि कितना अच्छा याद रहा।';

  @override
  String get practiceGradeAgain => 'फिर से';

  @override
  String get practiceGradeHard => 'कठिन';

  @override
  String get practiceGradeGood => 'अच्छा';

  @override
  String get practiceGradeEasy => 'आसान';

  @override
  String get practiceFsrsGradeNote =>
      'आपकी रेटिंग से FSRS-6 अगला दोहराव तय करता है';

  @override
  String get practiceReviewComplete => 'दोहराव पूरा';

  @override
  String practiceReviewedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आपने $count शब्द दोहराए। FSRS ने उन्हें फिर निर्धारित किया।',
      one: 'आपने 1 शब्द दोहराया। FSRS ने उसे फिर निर्धारित किया।',
    );
    return '$_temp0';
  }

  @override
  String get practiceDone => 'हो गया';

  @override
  String get practiceRelTomorrow => 'कल';

  @override
  String practiceRelInDays(int days) {
    return '$days दिन में';
  }

  @override
  String practiceRelInHours(int hours) {
    return '$hours घं. में';
  }

  @override
  String practiceRelInMinutes(int minutes) {
    return '$minutes मि. में';
  }

  @override
  String get practiceRelSoon => 'जल्द';

  @override
  String get progressTitle => 'प्रगति';

  @override
  String get progressShareMilestone => 'उपलब्धि साझा करें';

  @override
  String get progressLast7Days => 'पिछले 7 दिन';

  @override
  String get progressAccuracyRetention => 'सटीकता और स्मरण';

  @override
  String get progressHonestyNote =>
      'यहाँ सब कुछ वास्तविक दर्ज स्थिति है — स्तर, क्षमता, सहेजे शब्द, XP, पाठ, स्ट्रीक, 7-दिन का इतिहास, सटीकता और अध्ययन समय शून्य से शुरू होकर सीखने के साथ बढ़ते हैं। स्मरण इस सत्र का अनुमानित रिकॉल है (सत्रों के बीच का शेड्यूलर गो-लाइव कार्य है); कुछ भी गढ़ा नहीं गया।';

  @override
  String progressShareText(
    String level,
    String levelName,
    int streak,
    int xp,
    int lessons,
  ) {
    return '🦡 RATEL · स्तर $level ($levelName)\n🔥 $streak दिन की स्ट्रीक · ⚡ $xp XP · 📘 $lessons पाठ\nlearnwithratel.com पर सीख रहे हैं';
  }

  @override
  String get progressShareCopied =>
      'उपलब्धि क्लिपबोर्ड पर कॉपी हुई — कहीं भी साझा करें!';

  @override
  String progressAbilityLine(String theta) {
    return 'क्षमता θ $theta · वास्तविक अनुमान';
  }

  @override
  String get progressStatSavedWords => 'सहेजे शब्द';

  @override
  String get progressStatLessons => 'पाठ';

  @override
  String get progressStatDayStreak => 'दिन की स्ट्रीक';

  @override
  String get progressStatTotalXp => 'कुल XP';

  @override
  String get progressStatTodaysXp => 'आज का XP';

  @override
  String get progressStatCefrLevel => 'CEFR स्तर';

  @override
  String get progressAccuracy => 'सटीकता';

  @override
  String get progressStudyTime => 'अध्ययन समय';

  @override
  String get progressRetention => 'स्मरण';

  @override
  String get progressNoData => 'अभी डेटा नहीं';

  @override
  String get progressAccuracyEmpty => 'शुरू करने के लिए आँके गए अभ्यास हल करें';

  @override
  String progressAccuracyDetail(int correct, int total) {
    return '$total में से $correct सही';
  }

  @override
  String get progressTimeEmpty => 'पाठों का समय यहाँ जुड़ता है';

  @override
  String get progressTimeDetail => 'आपके सभी पाठों में';

  @override
  String get progressRetentionEmpty => 'अनुमानित रिकॉल देखने के लिए दोहराएँ';

  @override
  String progressRetentionDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '1-दिन का अनुमानित रिकॉल · इस सत्र में $count आइटम',
      one: '1-दिन का अनुमानित रिकॉल · इस सत्र में 1 आइटम',
    );
    return '$_temp0';
  }

  @override
  String progressWeekTotal(int xp) {
    return '$xp XP · पिछले 7 दिन';
  }

  @override
  String get progressNoXpYet => 'अभी कोई XP दर्ज नहीं';

  @override
  String get progressChartEmptyNote =>
      '7-दिन का इतिहास शुरू करने के लिए एक पाठ पूरा करें — निष्क्रिय दिन शून्य रहते हैं, कुछ भी गढ़ा नहीं जाता।';

  @override
  String get commonDowMon => 'सो';

  @override
  String get commonDowTue => 'मं';

  @override
  String get commonDowWed => 'बु';

  @override
  String get commonDowThu => 'गु';

  @override
  String get commonDowFri => 'शु';

  @override
  String get commonDowSat => 'श';

  @override
  String get commonDowSun => 'र';
}
