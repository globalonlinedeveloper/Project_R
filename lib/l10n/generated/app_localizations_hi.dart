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
  String get lessonExplainThis => '💡 Explain this';

  @override
  String get lessonMatchPairs => 'Match the pairs';

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
  String get onboardingLanguageSubtitle => '10 भाषाओं से अंग्रेज़ी सीखें';

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
  String get langNameEnglish => 'अंग्रेज़ी';

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
      'बाकी सब — ऑडियो, रिवीज़न, लीग, रोलप्ले और ऑन-डिवाइस उच्चारण — सबके लिए मुफ़्त रहता है।';

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
  String get notifBodyLevel4 => 'उन्नत (C1) — आपकी अंग्रेज़ी मज़बूत है।';

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

  @override
  String get searchTitle => 'खोज';

  @override
  String get searchHint => 'पाठ, शब्द, कहानियाँ खोजें…';

  @override
  String get searchRecent => 'हाल की';

  @override
  String get searchClear => 'साफ़ करें';

  @override
  String get searchJumpTo => 'यहाँ जाएँ';

  @override
  String get searchTagPage => 'पेज';

  @override
  String get searchTagWord => 'शब्द';

  @override
  String get searchSubtitleSavedWord => 'सहेजा शब्द';

  @override
  String searchLessonSubtitle(String unit) {
    return '$unit · पाठ';
  }

  @override
  String searchNoMatches(String query) {
    return '“$query” के लिए कोई परिणाम नहीं';
  }

  @override
  String get searchEmptyNote =>
      'आपके कोर्स, सहेजे शब्दों और पेजों के शीर्षक, टैग और पाठ सामग्री में खोज। सर्वर कंटेंट इंडेक्स और ट्रेंडिंग R-L12 का अगला चरण हैं — यहाँ कुछ भी नकली नहीं।';

  @override
  String get searchNoMatchNote =>
      'आपके प्रकाशित पाठों, सहेजे शब्दों और ऐप पेजों (शीर्षक + टैग) में खोज। कहानियाँ/पॉडकास्ट और पूर्ण-पाठ R-L12 का अगला चरण हैं — कभी नकली नहीं।';

  @override
  String get searchFooterNote =>
      'लॉन्च पर शीर्षक + टैग। पूर्ण-पाठ, कहानियाँ/पॉडकास्ट और बहु-कोर्स R-L12 का अगला चरण हैं — कभी नकली नहीं।';

  @override
  String get searchDestPracticeHub => 'अभ्यास केंद्र';

  @override
  String get searchDestPracticeHubSub => 'गलतियाँ, कमज़ोर शब्द और ड्रिल';

  @override
  String get searchDestAiTutor => 'AI ट्यूटर';

  @override
  String get searchDestAiTutorSub => 'बोलें, चैट करें और रोलप्ले करें';

  @override
  String get searchDestAdventures => 'एडवेंचर';

  @override
  String get searchDestAdventuresSub => 'असली बातचीत — मुफ़्त';

  @override
  String get searchDestLeagues => 'लीग';

  @override
  String get searchDestLeaguesSub => 'आपकी साप्ताहिक लीग';

  @override
  String get searchDestQuests => 'क्वेस्ट';

  @override
  String get searchDestQuestsSub => 'दैनिक लक्ष्य और क्वेस्ट';

  @override
  String get searchDestProgress => 'प्रगति';

  @override
  String get searchDestProgressSub => 'आपके आँकड़े और स्ट्रीक';

  @override
  String get searchDestProfile => 'प्रोफ़ाइल';

  @override
  String get searchDestProfileSub => 'आपकी प्रोफ़ाइल';

  @override
  String get searchDestSettings => 'सेटिंग्स';

  @override
  String get searchDestSettingsSub => 'खाता और प्राथमिकताएँ';

  @override
  String get searchDestShop => 'दुकान';

  @override
  String get searchDestShopSub => 'अपने हीरे खर्च करें';

  @override
  String get searchDestNotifications => 'सूचनाएँ';

  @override
  String get searchDestNotificationsSub => 'आपकी उपलब्धियों का इनबॉक्स';

  @override
  String get themesTitle => 'थीम';

  @override
  String get themesSubtitle =>
      'पूरे ऐप का रूप बदलता है — लाइव पूर्वावलोकन के लिए टैप करें';

  @override
  String themesVehicle(String vehicle) {
    return 'वाहन · $vehicle';
  }

  @override
  String get tutorHeader => 'असली बातचीत का अभ्यास करें';

  @override
  String get tutorHeaderSub =>
      'एक दृश्य चुनें और Ratel से चैट करें — कोई गलत जवाब नहीं, बस अभ्यास।';

  @override
  String get tutorTalkTitle => 'Ratel से बात करें';

  @override
  String get tutorTalkSub => 'लाइव आवाज़ और वीडियो बोलने का अभ्यास';

  @override
  String get tutorChatTitle => 'Ratel से चैट करें';

  @override
  String get tutorChatSub => 'AI चैट · लेखन प्रतिक्रिया';

  @override
  String get tutorRoleplayTitle => 'रोलप्ले दृश्य';

  @override
  String get tutorRoleplayGuided => 'मार्गदर्शित रोलप्ले बातचीत';

  @override
  String tutorScenesCount(int count) {
    return '$count दृश्य';
  }

  @override
  String get tutorUnlockPro => 'RATEL PRO अनलॉक करें';

  @override
  String get tutorRelayNote =>
      'लाइव AI ट्यूटरिंग एक मॉडरेटेड, लागत-नियंत्रित रिले पर चलती है और RATEL PRO सुविधा है। जवाब कभी नकली नहीं होते — कोई मोड तभी शुरू होता है जब PRO और रिले दोनों सक्रिय हों।';

  @override
  String get tutorStatusReadyPro =>
      'PRO सक्रिय है और लाइव ट्यूटर जुड़ा है — शुरू करने के लिए मोड चुनें।';

  @override
  String get tutorStatusReadyFree =>
      'लाइव ट्यूटर जुड़ा है। लाइव ट्यूटरिंग RATEL PRO सुविधा है।';

  @override
  String get tutorStatusOffline =>
      'इस बिल्ड में मॉडरेटेड लाइव ट्यूटर अभी जुड़ा नहीं है — लाइव ट्यूटरिंग बाद के चरण में चालू होगी। नीचे कुछ भी नकली नहीं है।';

  @override
  String get tutorAnnounceNeedsPro =>
      'RATEL PRO लाइव AI ट्यूटरिंग अनलॉक करता है।';

  @override
  String get tutorAnnounceNeedsRelay =>
      'मॉडरेटेड रिले सक्षम होते ही AI ट्यूटरिंग जुड़ जाएगी।';

  @override
  String get tutorAnnounceStarting => 'आपका सत्र शुरू हो रहा है…';

  @override
  String get adventuresTitle => 'एडवेंचर';

  @override
  String get adventuresFreeChip => 'मुफ़्त';

  @override
  String get adventuresHeaderSub =>
      'एक दुनिया एक्सप्लोर करें · बातचीत से आगे बढ़ें';

  @override
  String get adventuresHeroTitle => 'कोई जगह चुनें और शुरू करें';

  @override
  String get adventuresHeroSub =>
      'हर दृश्य एक असली बातचीत है — कोई गलत जवाब नहीं, और हमेशा मुफ़्त।';

  @override
  String get adventuresFallbackWorld => 'एडवेंचर';

  @override
  String adventureSheetKicker(String cefr) {
    return '🗺️ एडवेंचर · $cefr';
  }

  @override
  String adventureScenesCount(int count) {
    return '$count दृश्य';
  }

  @override
  String adventureChoicePoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count निर्णय बिंदु',
      one: '$count निर्णय बिंदु',
    );
    return '$_temp0';
  }

  @override
  String get adventureOpeningScene => 'प्रारंभिक दृश्य';

  @override
  String get adventureStart => 'एडवेंचर शुरू करें';

  @override
  String get adventurePlayerFallbackTitle => 'एडवेंचर';

  @override
  String get adventureTheEnd => '🏁 समाप्त';

  @override
  String get adventureStartOver => 'फिर से शुरू करें';

  @override
  String get adventureDone => 'हो गया';

  @override
  String get adventureCompleteKicker => 'एडवेंचर पूरा हुआ';

  @override
  String adventureCompleteTitle(String title) {
    return '$title ✓';
  }

  @override
  String get adventureCompleteBody =>
      'बहुत बढ़िया! +15 XP · +5 💎 मिले — अगला दृश्य जब चाहें एक्सप्लोर करें।';

  @override
  String adventureDistrictProgress(int done, int total) {
    return '$done/$total एक्सप्लोर किए';
  }

  @override
  String get adventureDistrictDone => '✓ पूर्ण';

  @override
  String get adventuresEmpty => 'इस कोर्स में अभी कोई एडवेंचर नहीं।';

  @override
  String get authWelcomeTitle => 'Ratel में आपका स्वागत है';

  @override
  String get authWelcomeSubtitle =>
      'पाठ, कहानियाँ, पॉडकास्ट और भी बहुत कुछ —\nचुनें कि आप कैसे शुरू करना चाहते हैं।';

  @override
  String get authCreateFreeAccount => 'मुफ़्त खाता बनाएँ';

  @override
  String get authAlreadyHaveAccount => 'मेरा खाता पहले से है';

  @override
  String get authSettingUp => 'तैयारी हो रही है…';

  @override
  String get authContinueAsGuest => 'अतिथि के रूप में जारी रखें';

  @override
  String get authGuestNote =>
      'अतिथि प्रगति इसी डिवाइस पर रहती है — इसे हर जगह रखने के लिए सेटिंग्स में कभी भी मुफ़्त खाता बनाएँ।';

  @override
  String get authEnterYourEmail => 'अपना ईमेल लिखें';

  @override
  String get authEnterValidEmail => 'मान्य ईमेल लिखें';

  @override
  String get authEnterYourPassword => 'अपना पासवर्ड लिखें';

  @override
  String get authCouldNotSignIn => 'साइन इन नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get authSomethingWentWrong => 'कुछ गड़बड़ हुई। फिर से कोशिश करें।';

  @override
  String get authSocialComingSoon => 'Google / Apple से साइन-इन जल्द आ रहा है।';

  @override
  String get authResetTitle => 'पासवर्ड रीसेट करें';

  @override
  String get authWelcomeBack => 'वापसी पर स्वागत है!';

  @override
  String get authResetSubtitle => 'अपना ईमेल लिखें, हम रीसेट लिंक भेजेंगे।';

  @override
  String get authPickUpWhereYouLeft => 'जहाँ छोड़ा था वहीं से शुरू करें';

  @override
  String get authEmailHint => 'ईमेल';

  @override
  String get authPasswordHint => 'पासवर्ड';

  @override
  String get authForgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get authSendResetLink => 'रीसेट लिंक भेजें';

  @override
  String get authLogIn => 'लॉग इन';

  @override
  String get authBackToLogIn => 'लॉग इन पर वापस';

  @override
  String get authNewToRatel => 'Ratel पर नए हैं? ';

  @override
  String get authSignUp => 'साइन अप करें';

  @override
  String get authCheckYourInbox => 'अपना इनबॉक्स देखें';

  @override
  String authResetSent(String email) {
    return 'हमने $email पर पासवर्ड-रीसेट लिंक भेजा है। नया पासवर्ड चुनने के लिए उसे खोलें।';
  }

  @override
  String get authCreatePassword => 'पासवर्ड बनाएँ';

  @override
  String get authAtLeast8Chars => 'कम से कम 8 अक्षर';

  @override
  String get authCreateYourAccount => 'अपना खाता बनाएँ';

  @override
  String get authSignupSubtitle =>
      'हमेशा मुफ़्त · 10 भाषाओं से अंग्रेज़ी सीखें';

  @override
  String get authPassword8Hint => 'पासवर्ड (8+ अक्षर)';

  @override
  String get authCreateAccount => 'खाता बनाएँ';

  @override
  String get authAlreadyAccountLead => 'पहले से खाता है? ';

  @override
  String get authSignIn => 'साइन इन करें';

  @override
  String get authConfirmEmail => 'अपना ईमेल पक्का करें';

  @override
  String authConfirmSent(String email) {
    return 'हमने $email पर पुष्टि लिंक भेजा है। खाता सक्रिय करने के लिए उसे टैप करें, फिर लॉग इन करने लौटें।';
  }

  @override
  String get authContinueGoogle => 'Google से जारी रखें';

  @override
  String get authContinueApple => 'Apple से जारी रखें';

  @override
  String get authOr => 'या';

  @override
  String get authUnavailableNote =>
      'इस बिल्ड में खाते अभी उपलब्ध नहीं हैं — आप अतिथि के रूप में सीखते रह सकते हैं। बैकएंड कॉन्फ़िगर होते ही साइन-इन चालू होगा।';

  @override
  String get liveMute => 'म्यूट';

  @override
  String get liveUnmute => 'अनम्यूट';

  @override
  String commonDurSeconds(int s) {
    return '$s से.';
  }

  @override
  String commonDurMinutes(int m) {
    return '$m मि.';
  }

  @override
  String commonDurHours(int h) {
    return '$h घं.';
  }

  @override
  String commonDurHoursMinutes(int h, int m) {
    return '$h घं. $m मि.';
  }

  @override
  String practiceGradeInterval(String label, int days) {
    return '$label · $days दिन';
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
