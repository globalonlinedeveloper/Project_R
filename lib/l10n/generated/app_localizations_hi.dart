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
}
