// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navLibrary => 'المكتبة';

  @override
  String get navLeagues => 'الدوريات';

  @override
  String get navQuests => 'المهام';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSectionLearning => 'التعلّم';

  @override
  String get settingsSectionSubscription => 'الاشتراك';

  @override
  String get settingsSectionAccessibility => 'إمكانية الوصول';

  @override
  String get settingsSectionNotifications => 'الإشعارات';

  @override
  String get settingsSectionAppearanceAccount => 'المظهر والحساب';

  @override
  String get settingsAppLanguage => 'لغة التطبيق';

  @override
  String get settingsAppLanguageSystem => 'افتراضي النظام';

  @override
  String get homeCourseLoadingTitle => 'دورتك قيد التجهيز';

  @override
  String get homeCourseLoadingBody =>
      'ستظهر الدروس هنا بمجرد تحميل محتوى الدورة.';

  @override
  String get homeGuideChip => 'الدليل';

  @override
  String get homeStartNode => 'ابدأ';

  @override
  String get homeUnitGuideHeader => 'دليل الوحدة';

  @override
  String get commonDone => 'تم';

  @override
  String homeUnitKicker(String unit) {
    return 'الوحدة · $unit';
  }

  @override
  String homeLessonMeta(int num, int count, String exercises) {
    return 'الدرس $num من $count · $exercises.';
  }

  @override
  String homeQuickExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تمرين سريع',
      many: '$count تمرينًا سريعًا',
      few: '$count تمارين سريعة',
      two: 'تمرينان سريعان',
      one: 'تمرين سريع واحد',
      zero: 'لا تمارين سريعة',
    );
    return '$_temp0';
  }

  @override
  String get homeEnergyChip => '−1 ⚡ طاقة';

  @override
  String get homeXpChip => '+20 XP';

  @override
  String get homeStartLesson => 'ابدأ الدرس';

  @override
  String get homeTutorChip => 'المعلّم';

  @override
  String get libraryAiTutor => 'معلّم الذكاء الاصطناعي';

  @override
  String get libraryAiTutorSub =>
      'تحدّث ودردش ومثّل الأدوار — ملاحظات على الكتابة';

  @override
  String get libraryRoleplay => 'تمثيل الأدوار';

  @override
  String get libraryRoleplaySub => 'تدرّب على الردود — مقيّمة ومجانية دائمًا';

  @override
  String get librarySectionPractice => 'التدريب';

  @override
  String get libraryPracticeHub => 'مركز التدريب';

  @override
  String get libraryPracticeHubSub =>
      'الأخطاء والكلمات الضعيفة والتدريبات · مجانًا';

  @override
  String get librarySectionReadListen => 'اقرأ واستمع';

  @override
  String get libraryGradedStories => 'قصص متدرّجة';

  @override
  String get libraryPodcasts => 'بودكاست';

  @override
  String get libraryWatch => 'شاهد';

  @override
  String get librarySearchHint => 'ابحث عن دروس وكلمات وقصص…';

  @override
  String get libraryFeaturedStory => 'مميّز · قصة';

  @override
  String commonLevel(String cefr) {
    return 'المستوى $cefr';
  }

  @override
  String get libraryReadNow => 'اقرأ الآن';

  @override
  String get libraryNewExplore => 'جديد · استكشف';

  @override
  String get libraryAdventures => 'المغامرات';

  @override
  String get libraryStartExploring => '← ابدأ الاستكشاف';

  @override
  String get libraryKindStory => 'قصة';

  @override
  String get libraryKindPodcast => 'بودكاست';

  @override
  String get libraryKindVideo => 'فيديو';

  @override
  String get libraryAllStories => 'كل القصص';

  @override
  String get libraryAllPodcasts => 'كل البودكاست';

  @override
  String get libraryAllVideos => 'كل الفيديوهات';

  @override
  String get lessonTypeWhatYouHear => 'اكتب ما تسمعه';

  @override
  String get lessonTapWhatYouHear => 'انقر ما تسمعه';

  @override
  String get lessonTranslateSentence => 'ترجم هذه الجملة';

  @override
  String get lessonTypeAnswerHint => 'اكتب إجابتك…';

  @override
  String get lessonWriteAnswerHint => 'اكتب إجابتك…';

  @override
  String get lessonContinue => 'متابعة';

  @override
  String get lessonSkip => 'تخطٍّ';

  @override
  String get lessonCheck => 'تحقّق';

  @override
  String get lessonNicelyDone => '✓ أحسنت!';

  @override
  String get lessonNotQuite => '✕ ليس تمامًا';

  @override
  String lessonAnswerReveal(String answer) {
    return 'الإجابة: $answer';
  }

  @override
  String get lessonCompleteKicker => 'اكتمل الدرس';

  @override
  String get lessonCompleteTitle => 'اكتمل الدرس!';

  @override
  String lessonCompleteSummary(int correct, int graded, String level) {
    return '$correct من $graded صحيحة · الآن $level';
  }

  @override
  String get lessonStatTotalXp => 'مجموع XP';

  @override
  String get lessonStatAccuracy => 'الدقة';

  @override
  String get lessonStatTime => 'الوقت';
}
