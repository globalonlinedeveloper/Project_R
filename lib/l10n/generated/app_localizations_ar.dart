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

  @override
  String get onboardingWelcomeTitle => 'مرحبًا، أنا راتل!';

  @override
  String get onboardingWelcomeBody =>
      'تعلّم لغة بلا خوف — دروس قصيرة وممتعة ومجانية. جاهز للانطلاق؟';

  @override
  String get onboardingHaveAccount => 'لديّ حساب بالفعل';

  @override
  String get onboardingTryWithoutAccount => '← جرّب بدون حساب';

  @override
  String get onboardingGetStarted => 'ابدأ';

  @override
  String get onboardingStartLearning => 'ابدأ التعلّم';

  @override
  String get onboardingLanguageTitle => 'ماذا تريد أن تتعلّم؟';

  @override
  String get onboardingLanguageSubtitle => '52 لغة متاحة';

  @override
  String get onboardingReasonTitle => 'لماذا تتعلّم؟';

  @override
  String get onboardingGoalTitle => 'اختر هدفًا يوميًا';

  @override
  String get onboardingPlacementTitle => 'حدّد نقطة انطلاقك';

  @override
  String onboardingPlacementBody(String language) {
    return 'جديد على $language، أم تعرف بعض الأساسيات؟';
  }

  @override
  String get onboardingBrandNew => 'أنا مبتدئ تمامًا';

  @override
  String get onboardingBrandNewSub => 'ابدأ من البداية';

  @override
  String get onboardingPlacementTest => 'خُض اختبار تحديد المستوى';

  @override
  String get onboardingPlacementTestSub => '~3 دقائق · انتقل إلى مستواك';

  @override
  String onboardingXpPerDay(int xp) {
    return '$xp XP / يوم';
  }

  @override
  String get reasonTravel => 'السفر';

  @override
  String get reasonCulture => 'الثقافة';

  @override
  String get reasonCareer => 'العمل';

  @override
  String get reasonFamilyFriends => 'العائلة والأصدقاء';

  @override
  String get reasonBrainTraining => 'تدريب الدماغ';

  @override
  String get reasonJustForFun => 'للمتعة فقط';

  @override
  String get goalCasual => 'مسترخٍ';

  @override
  String get goalRegular => 'منتظم';

  @override
  String get goalSerious => 'جادّ';

  @override
  String get goalIntense => 'مكثّف';

  @override
  String get langNameSpanish => 'الإسبانية';

  @override
  String get langNameFrench => 'الفرنسية';

  @override
  String get langNameJapanese => 'اليابانية';

  @override
  String get langNameTamil => 'التاميلية';

  @override
  String get langNameGerman => 'الألمانية';

  @override
  String get langNameKorean => 'الكورية';

  @override
  String get settingsDailyGoal => 'الهدف اليومي';

  @override
  String settingsGoalRow(String label, int xp) {
    return '$label · $xp XP/يوم';
  }

  @override
  String get profileAchievements => 'الإنجازات';

  @override
  String get profileFriends => 'الأصدقاء';

  @override
  String get profileShop => 'المتجر';

  @override
  String get profileNotifications => 'الإشعارات';

  @override
  String get profileSeeOnboarding => 'عرض جولة البداية ↗';

  @override
  String get profileNotSignedIn => 'غير مسجّل الدخول';

  @override
  String get profileCreateAccount => 'أنشئ حسابًا مجانيًا';

  @override
  String get profileSaveProgress => 'احفظ تقدّمك على جميع أجهزتك';

  @override
  String profileTodaysGoal(int today, int goal) {
    return 'هدف اليوم · $today/$goal XP';
  }

  @override
  String get profileViewProgress => 'عرض التقدّم ←';

  @override
  String get profileUnlocked => 'مفتوح';
}
