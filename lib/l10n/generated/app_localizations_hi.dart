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
}
