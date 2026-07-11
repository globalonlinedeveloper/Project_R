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

  @override
  String questsResetsIn(int h, int m) {
    return 'يُعاد الضبط خلال $hس $mد';
  }

  @override
  String get questsDailyRefresh => 'التحديث اليومي';

  @override
  String get questsFreshMix => 'مزيج جديد من 5 أسئلة';

  @override
  String get questsServedFromQueue =>
      'يُقدَّم من قائمة مراجعتك الحقيقية — يمنح XP حقيقيًا.';

  @override
  String get questsGoalReached => 'تحقق الهدف اليومي! 🎉';

  @override
  String questsReachGoal(int goal) {
    return 'اجمع $goal XP اليوم';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return 'المهام اليومية · $done/$total';
  }

  @override
  String get questsInfoNote =>
      'تتتبّع المهام تقدّمك اليومي الحقيقي. صناديق المكافآت ومهام الأصدقاء ولوحة الصدارة الأسبوعية تحتاج اقتصاد خلفية — قرار المالك (§6). لا تُعرض مكافآت زائفة.';

  @override
  String get questsStartRefresh => 'ابدأ التحديث اليومي';

  @override
  String get questsStart => 'ابدأ';

  @override
  String get questsPractisedToday => 'تدرّبت اليوم — السلسلة بأمان';

  @override
  String get questsEarnAnyXp => 'اجمع أي XP اليوم';

  @override
  String questsXpToday(int current, int target) {
    return '$current/$target XP اليوم';
  }

  @override
  String get leaguesYourGroup => 'مجموعتك';

  @override
  String leaguesThisWeek(int size) {
    return 'هذا الأسبوع · $size متعلّمًا';
  }

  @override
  String get leaguesTiers => 'مستويات الدوري';

  @override
  String leaguesTopClimb(int top, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days يوم',
      many: '$days يومًا',
      few: '$days أيام',
      two: 'يومين',
      one: 'يوم واحد',
      zero: '$days يوم',
    );
    return 'يصعد أفضل $top كل أسبوع · ينتهي خلال $_temp0';
  }

  @override
  String get leaguesDemotionZone => 'منطقة الهبوط';

  @override
  String get leaguesPromotionZone => 'منطقة الصعود';

  @override
  String get leaguesSafeZone => 'منطقة آمنة';

  @override
  String get leaguesYou => 'أنت';

  @override
  String leaguesPromoteRelegate(int top, int bottom) {
    return 'يصعد أفضل $top · ويهبط آخر $bottom عند نهاية الأسبوع.';
  }

  @override
  String get leaguesYouAreHere => 'أنت هنا';

  @override
  String get leaguesViewAllTiers => '🏆 عرض المستويات العشرة ‹';

  @override
  String get notifMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get notifEmptyTitle => 'لا إشعارات بعد';

  @override
  String get notifEmptyBody =>
      'أنهِ الدروس وابنِ سلسلة وارفع مستواك — ستظهر إنجازاتك هنا لحظة تحقيقها فعلًا.';

  @override
  String get notifPushNote =>
      'هذه إنجازات داخل التطبيق تظهر لحظة تحقيقها. إشعارات الدفع والتذكيرات قرار المالك وغير مفعّلة بعد — لا شيء هنا مزيّف.';

  @override
  String get shopPowerUps => 'التعزيزات';

  @override
  String get shopStreakFreeze => 'تجميد السلسلة';

  @override
  String get shopStreakFreezeDesc =>
      'يحمي سلسلتك ليوم واحد فائت. يُستهلك تلقائيًا عند تفويت هدفك اليومي.';

  @override
  String shopOwned(int have, int max) {
    return 'تملك $have/$max';
  }

  @override
  String get shopMaxedOut => 'الحد الأقصى';

  @override
  String shopBuyFor(int cost) {
    return 'اشترِ بـ $cost 💎';
  }

  @override
  String get shopFreezeAdded => 'أُضيف تجميد السلسلة 💪';

  @override
  String shopFreezeAtCap(int max) {
    return 'لديك بالفعل أقصى عدد من التجميدات ($max).';
  }

  @override
  String shopNotEnoughEarnCost(int cost) {
    return '💎 غير كافية — اجمع $cost بإنهاء الدروس.';
  }

  @override
  String get shopNotEnoughEarnMore =>
      '💎 غير كافية — اجمع المزيد بإنهاء الدروس.';

  @override
  String get shopEnergyRefill => 'إعادة شحن الطاقة';

  @override
  String get shopEnergyRefillDesc =>
      'أعد طاقتك إلى الحد الأقصى فورًا. الطاقة للعرض فقط — الدروس لا تُحجب أبدًا.';

  @override
  String get shopAlreadyFull => 'ممتلئة بالفعل';

  @override
  String get shopEnergyRefilled => 'أُعيد شحن الطاقة ⚡';

  @override
  String get shopEnergyAlreadyFull => 'طاقتك ممتلئة بالفعل.';

  @override
  String get shopStreakRepair => 'إصلاح السلسلة';

  @override
  String get shopStreakRepairDesc =>
      'فقدت سلسلتك؟ أعدها إلى طولها السابق وواصل المسيرة.';

  @override
  String get shopStreakLapsed => 'انقطعت السلسلة';

  @override
  String shopStreakDays(int days) {
    return '🔥 سلسلة $days يومًا';
  }

  @override
  String shopRepairFor(int cost) {
    return 'أصلح بـ $cost 💎';
  }

  @override
  String get shopStreakRestored => 'استُعيدت السلسلة 🔥';

  @override
  String get shopStreakSafe => 'سلسلتك بأمان — لا شيء يحتاج إصلاحًا الآن.';

  @override
  String get shopDoubleXp => 'XP مضاعف';

  @override
  String get shopDoubleXpDesc => 'اكسب 2× XP من كل درس لمدة 15 دقيقة.';

  @override
  String shopActiveLeft(int minutes) {
    return 'نشط · تبقّى $minutes د';
  }

  @override
  String get shopInactive => 'غير نشط';

  @override
  String get shopActive => 'نشط';

  @override
  String get shopDoubleXpActive => 'تفعّل XP المضاعف ✨';

  @override
  String get shopBoostRunning => 'التعزيز يعمل — يتضاعف XP.';

  @override
  String get shopBadgerOutfits => 'أزياء الغرير';

  @override
  String get paywallTitle => 'RATEL PRO';

  @override
  String get paywallStartTrial => 'ابدأ تجربة مجانية لـ7 أيام';

  @override
  String paywallGoPro(String price) {
    return 'اشترك في Pro — $price/شهر';
  }

  @override
  String get paywallRestore => 'استعادة المشتريات';

  @override
  String get paywallHero =>
      'تدريس مباشر بالذكاء الاصطناعي، بلا إعلانات، ودروس دون اتصال.';

  @override
  String get paywallAnnual => 'سنوي';

  @override
  String get paywallMonthly => 'شهري';

  @override
  String get paywallTrialHow => 'كيف تعمل التجربة المجانية لـ7 أيام';

  @override
  String get paywallTrialToday => 'اليوم';

  @override
  String get paywallTrialTodayDesc => 'يُفتح وصول Pro الكامل. بلا رسوم.';

  @override
  String get paywallTrialDay5 => 'اليوم 5';

  @override
  String get paywallTrialDay5Desc => 'نذكّرك قبل انتهاء التجربة.';

  @override
  String get paywallTrialDay7 => 'اليوم 7';

  @override
  String paywallTrialDay7Desc(String price) {
    return 'يبدأ $price/سنة ما لم تلغِ.';
  }

  @override
  String get paywallFeatureLiveAi =>
      'ذكاء اصطناعي مباشر: صوت ودردشة معلّم وملاحظات كتابة';

  @override
  String get paywallFeatureNoAds => 'لا إعلانات، في أي مكان';

  @override
  String get paywallFeatureOffline => 'دروس وصوت دون اتصال';

  @override
  String get paywallFeaturePronunciation =>
      'نصائح تدريب على النطق بالذكاء الاصطناعي';

  @override
  String get paywallEverythingFree =>
      'كل ما عدا ذلك — الـ52 لغة والصوت والمراجعة والدوريات وتمثيل الأدوار والنطق على الجهاز — يبقى مجانيًا للجميع.';

  @override
  String get paywallYouArePro => 'أنت مشترك في RATEL PRO';

  @override
  String get paywallThanks =>
      'شكرًا لدعمك Ratel. أدر اشتراكك أو ألغِه متى شئت من الإعدادات ← إدارة الاشتراك.';

  @override
  String get paywallManage => 'إدارة الاشتراك';

  @override
  String paywallFinePrint(String regions) {
    return 'ألغِ في أي وقت من الإعدادات. الأسعار المعروضة لـ$regions؛ يحدد متجر تطبيقاتك سعرك المحلي.';
  }

  @override
  String get questTitlePowerSession => 'جلسة قوية';

  @override
  String get questDescPowerSession => 'اجمع ضعف هدفك اليومي';

  @override
  String get questTitleOnFire => 'متوهّج';

  @override
  String get questDescOnFire => 'اجمع ثلاثة أضعاف هدفك اليومي';

  @override
  String get questTitleStreakKeeper => 'حارس السلسلة';

  @override
  String get questDescStreakKeeper => 'تدرّب اليوم للحفاظ على سلسلتك';

  @override
  String get notifTitleLessons1 => 'اكتمل الدرس الأول';

  @override
  String get notifBodyLessons1 => 'أنهيت درسك الأول — بداية رائعة!';

  @override
  String get notifTitleLessons5 => 'أُنجزت 5 دروس';

  @override
  String get notifBodyLessons5 => 'أكملت 5 دروس. حافظ على الزخم.';

  @override
  String get notifTitleLessons10 => 'أُنجزت 10 دروس';

  @override
  String get notifBodyLessons10 => 'عشرة دروس — أنت تبني عادة حقيقية.';

  @override
  String get notifTitleLessons25 => 'أُنجز 25 درسًا';

  @override
  String get notifBodyLessons25 =>
      'اكتملت خمسة وعشرون درسًا. تفانٍ مثير للإعجاب!';

  @override
  String get notifTitleLessons50 => 'أُنجز 50 درسًا';

  @override
  String get notifBodyLessons50 => 'خمسون درسًا — أنت على الطريق الصحيح.';

  @override
  String get notifTitleStreak3 => 'سلسلة 3 أيام!';

  @override
  String get notifBodyStreak3 => 'ثلاثة أيام متتالية. الاستمرارية هي كل شيء.';

  @override
  String get notifTitleStreak7 => 'سلسلة 7 أيام!';

  @override
  String get notifBodyStreak7 => 'أسبوع كامل من التدريب اليومي. متميز!';

  @override
  String get notifTitleStreak14 => 'سلسلة 14 يومًا!';

  @override
  String get notifBodyStreak14 => 'أسبوعان متتاليان — لا يمكن إيقافك.';

  @override
  String get notifTitleStreak30 => 'سلسلة 30 يومًا!';

  @override
  String get notifBodyStreak30 => 'شهر كامل من التدريب اليومي. مذهل.';

  @override
  String get notifTitleXp100 => 'اكتسبت 100 XP';

  @override
  String get notifBodyXp100 => 'أول مئة XP لك — الزخم يتصاعد.';

  @override
  String get notifTitleXp500 => 'اكتسبت 500 XP';

  @override
  String get notifBodyXp500 => 'خمسمئة XP. أنت تبذل الجهد.';

  @override
  String get notifTitleXp1000 => 'اكتسبت 1,000 XP';

  @override
  String get notifBodyXp1000 => 'تم بلوغ إنجاز الألف XP!';

  @override
  String get notifTitleXp2500 => 'اكتسبت 2,500 XP';

  @override
  String get notifBodyXp2500 => 'ألفان وخمسمئة XP — تقدّم جادّ.';

  @override
  String get notifTitleLevel1 => 'بلغت المستوى A2';

  @override
  String get notifBodyLevel1 => 'نمت قدرتك من A1 إلى A2. إلى الأمام!';

  @override
  String get notifTitleLevel2 => 'بلغت المستوى B1';

  @override
  String get notifBodyLevel2 => 'أصبحت متعلمًا متوسطًا (B1).';

  @override
  String get notifTitleLevel3 => 'بلغت المستوى B2';

  @override
  String get notifBodyLevel3 => 'بلغت فوق المتوسط (B2). رائع.';

  @override
  String get notifTitleLevel4 => 'بلغت المستوى C1';

  @override
  String get notifBodyLevel4 => 'متقدم (C1) — إسبانيتك قوية.';

  @override
  String get notifTitleLevel5 => 'بلغت المستوى C2';

  @override
  String get notifBodyLevel5 => 'الإتقان (C2) — قمة السلّم!';

  @override
  String get achTitleFirstSteps => 'الخطوات الأولى';

  @override
  String get achTitleScholar => 'الباحث';

  @override
  String get achTitleWildfire => 'نار متأججة';

  @override
  String get achTitlePointMaker => 'صانع النقاط';

  @override
  String get achTitleCollector => 'الجامع';

  @override
  String get achTitleRisingStar => 'نجم صاعد';

  @override
  String get leagueTierBronze => 'البرونز';

  @override
  String get leagueTierSilver => 'الفضة';

  @override
  String get leagueTierGold => 'الذهب';

  @override
  String get leagueTierSapphire => 'الياقوت الأزرق';

  @override
  String get leagueTierRuby => 'الياقوت الأحمر';

  @override
  String get leagueTierEmerald => 'الزمرد';

  @override
  String get leagueTierAmethyst => 'الجمشت';

  @override
  String get leagueTierPearl => 'اللؤلؤ';

  @override
  String get leagueTierObsidian => 'السبج';

  @override
  String get leagueTierDiamond => 'الماس';

  @override
  String get cefrNameBeginner => 'مبتدئ';

  @override
  String get cefrNameElementary => 'أساسي';

  @override
  String get cefrNameIntermediate => 'متوسط';

  @override
  String get cefrNameUpperIntermediate => 'فوق المتوسط';

  @override
  String get cefrNameAdvanced => 'متقدم';

  @override
  String get cefrNameProficient => 'متقن';

  @override
  String leaguesTierLeague(String tier) {
    return 'دوري $tier';
  }

  @override
  String leaguesYoureIn(String tier) {
    return 'أنت في $tier · أفضل 7 يصعدون كل أسبوع';
  }

  @override
  String get leaguesZonePromotion => '⬆ منطقة الصعود';

  @override
  String get leaguesZoneDemotion => '⬇ منطقة الهبوط';

  @override
  String profileAchievementsSummary(int unlocked, int total) {
    return '$unlocked من $total مفتوحة · تقدّم حقيقي';
  }

  @override
  String get profileRealStateNote =>
      'المستوى وXP والدروس والسلسلة والكلمات المحفوظة حالة محرّك حقيقية — تبدأ من الصفر في الحساب الجديد.';

  @override
  String get practiceTitle => 'تدريب';

  @override
  String practiceReviewWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'راجع $count كلمة',
      many: 'راجع $count كلمة',
      few: 'راجع $count كلمات',
      two: 'راجع كلمتين',
      one: 'راجع كلمة واحدة',
      zero: 'لا كلمات للمراجعة',
    );
    return '$_temp0';
  }

  @override
  String get practiceYourWords => 'كلماتك';

  @override
  String practiceSavedWordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count كلمة محفوظة',
      many: '$count كلمة محفوظة',
      few: '$count كلمات محفوظة',
      two: 'كلمتان محفوظتان',
      one: 'كلمة محفوظة واحدة',
      zero: 'لا كلمات محفوظة',
    );
    return '$_temp0';
  }

  @override
  String practiceDueForReview(int count) {
    return '$count مستحقة للمراجعة المتباعدة';
  }

  @override
  String get practiceAllUpToDate => 'كل المراجعات محدّثة';

  @override
  String practiceCaughtUp(String tail) {
    return 'كل شيء منجز — لا شيء مستحق الآن$tail.';
  }

  @override
  String practiceNextTail(String when) {
    return ' · التالي $when';
  }

  @override
  String get practiceZeroDue => '0 مستحقة';

  @override
  String get practiceDueNow => 'مستحقة الآن';

  @override
  String practiceDueWhen(String when) {
    return 'مستحقة $when';
  }

  @override
  String get practiceChipDue => 'مستحقة';

  @override
  String get practiceChipScheduled => 'مجدولة';

  @override
  String get practiceScheduleNote =>
      'تُجدول المراجعات بواسطة محرّك التكرار المتباعد الحقيقي FSRS-6. تظل المواعيد لهذه الجلسة؛ وحفظها بين التشغيلات خطوة إطلاق — لا شيء هنا مُختلق.';

  @override
  String get practiceNoSavedWords => 'لا كلمات محفوظة بعد';

  @override
  String get practiceSaveWordHint =>
      'احفظ كلمة أثناء التدرب على درس وستظهر هنا كبطاقة. بعدها يجدول محرّك FSRS الحقيقي للتكرار المتباعد المراجعات — لا شيء مُعبأ مسبقًا.';

  @override
  String get practiceStartLesson => 'ابدأ درسًا';

  @override
  String practiceWordOf(int n, int total) {
    return 'الكلمة $n من $total';
  }

  @override
  String get practiceShowAnswer => 'أظهر الإجابة';

  @override
  String get practiceRecallHint => 'استرجع المعنى ثم قيّم مدى تذكرك.';

  @override
  String get practiceGradeAgain => 'من جديد';

  @override
  String get practiceGradeHard => 'صعب';

  @override
  String get practiceGradeGood => 'جيد';

  @override
  String get practiceGradeEasy => 'سهل';

  @override
  String get practiceFsrsGradeNote =>
      'يجدول FSRS-6 المراجعة التالية بحسب تقييمك';

  @override
  String get practiceReviewComplete => 'اكتملت المراجعة';

  @override
  String practiceReviewedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'راجعت $count كلمة. أعاد FSRS جدولتها.',
      many: 'راجعت $count كلمة. أعاد FSRS جدولتها.',
      few: 'راجعت $count كلمات. أعاد FSRS جدولتها.',
      two: 'راجعت كلمتين. أعاد FSRS جدولتهما.',
      one: 'راجعت كلمة واحدة. أعاد FSRS جدولتها.',
      zero: 'لم تراجع كلمات.',
    );
    return '$_temp0';
  }

  @override
  String get practiceDone => 'تم';

  @override
  String get practiceRelTomorrow => 'غدًا';

  @override
  String practiceRelInDays(int days) {
    return 'بعد $days أيام';
  }

  @override
  String practiceRelInHours(int hours) {
    return 'بعد $hours س';
  }

  @override
  String practiceRelInMinutes(int minutes) {
    return 'بعد $minutes د';
  }

  @override
  String get practiceRelSoon => 'قريبًا';

  @override
  String get progressTitle => 'التقدم';

  @override
  String get progressShareMilestone => 'شارك الإنجاز';

  @override
  String get progressLast7Days => 'آخر 7 أيام';

  @override
  String get progressAccuracyRetention => 'الدقة والاحتفاظ';

  @override
  String get progressHonestyNote =>
      'كل ما هنا حالة حقيقية مسجلة — المستوى والقدرة والكلمات المحفوظة وXP والدروس والسلسلة وسجل 7 أيام والدقة ووقت الدراسة تبدأ من الصفر وتنمو مع تعلمك. الاحتفاظ هو الاسترجاع المتوقع لهذه الجلسة (مجدول عابر للجلسات ضمن أعمال الإطلاق)؛ لا شيء مُختلق.';

  @override
  String progressShareText(
    String level,
    String levelName,
    int streak,
    int xp,
    int lessons,
  ) {
    return '🦡 RATEL · المستوى $level ($levelName)\n🔥 سلسلة $streak يومًا · ⚡ $xp XP · 📘 $lessons درسًا\nأتعلم على learnwithratel.com';
  }

  @override
  String get progressShareCopied =>
      'نُسخ الإنجاز إلى الحافظة — شاركه أينما شئت!';

  @override
  String progressAbilityLine(String theta) {
    return 'القدرة θ $theta · تقدير حقيقي';
  }

  @override
  String get progressStatSavedWords => 'كلمات محفوظة';

  @override
  String get progressStatLessons => 'دروس';

  @override
  String get progressStatDayStreak => 'أيام السلسلة';

  @override
  String get progressStatTotalXp => 'إجمالي XP';

  @override
  String get progressStatTodaysXp => 'XP اليوم';

  @override
  String get progressStatCefrLevel => 'مستوى CEFR';

  @override
  String get progressAccuracy => 'الدقة';

  @override
  String get progressStudyTime => 'وقت الدراسة';

  @override
  String get progressRetention => 'الاحتفاظ';

  @override
  String get progressNoData => 'لا بيانات بعد';

  @override
  String get progressAccuracyEmpty => 'أجب عن تمارين مقيّمة للبدء';

  @override
  String progressAccuracyDetail(int correct, int total) {
    return '$correct من $total صحيحة';
  }

  @override
  String get progressTimeEmpty => 'يتراكم وقت الدروس هنا';

  @override
  String get progressTimeDetail => 'عبر كل دروسك';

  @override
  String get progressRetentionEmpty => 'راجع عناصر لرؤية الاسترجاع المتوقع';

  @override
  String progressRetentionDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'استرجاع متوقع ليوم واحد · $count عنصر هذه الجلسة',
      many: 'استرجاع متوقع ليوم واحد · $count عنصرًا هذه الجلسة',
      few: 'استرجاع متوقع ليوم واحد · $count عناصر هذه الجلسة',
      two: 'استرجاع متوقع ليوم واحد · عنصران هذه الجلسة',
      one: 'استرجاع متوقع ليوم واحد · عنصر واحد هذه الجلسة',
      zero: 'استرجاع متوقع ليوم واحد · لا عناصر هذه الجلسة',
    );
    return '$_temp0';
  }

  @override
  String progressWeekTotal(int xp) {
    return '$xp XP · آخر 7 أيام';
  }

  @override
  String get progressNoXpYet => 'لا XP مسجلة بعد';

  @override
  String get progressChartEmptyNote =>
      'أكمل درسًا لبدء سجل 7 أيام — تبقى الأيام الخاملة صفرًا، لا شيء مُختلق.';

  @override
  String get commonDowMon => 'ن';

  @override
  String get commonDowTue => 'ث';

  @override
  String get commonDowWed => 'ر';

  @override
  String get commonDowThu => 'خ';

  @override
  String get commonDowFri => 'ج';

  @override
  String get commonDowSat => 'س';

  @override
  String get commonDowSun => 'ح';

  @override
  String get searchTitle => 'بحث';

  @override
  String get searchHint => 'ابحث في الدروس والكلمات والقصص…';

  @override
  String get searchRecent => 'الأخيرة';

  @override
  String get searchClear => 'مسح';

  @override
  String get searchJumpTo => 'انتقل إلى';

  @override
  String get searchTagPage => 'صفحة';

  @override
  String get searchTagWord => 'كلمة';

  @override
  String get searchSubtitleSavedWord => 'كلمة محفوظة';

  @override
  String searchLessonSubtitle(String unit) {
    return '$unit · درس';
  }

  @override
  String searchNoMatches(String query) {
    return 'لا نتائج لـ «$query»';
  }

  @override
  String get searchEmptyNote =>
      'يبحث في العناوين والوسوم ومحتوى الدروس عبر دورتك وكلماتك المحفوظة والصفحات. فهرس المحتوى على الخادم والرائج هما متابعة R-L12 — لا شيء هنا مزيف.';

  @override
  String get searchNoMatchNote =>
      'يبحث في دروس دورتك المنشورة وكلماتك المحفوظة وصفحات التطبيق (العناوين + الوسوم). القصص/البودكاست والنص الكامل متابعة R-L12 — لا تزييف أبدًا.';

  @override
  String get searchFooterNote =>
      'العناوين + الوسوم عند الإطلاق. النص الكامل والقصص/البودكاست وتعدد الدورات متابعة R-L12 — لا تزييف أبدًا.';

  @override
  String get searchDestPracticeHub => 'مركز التدريب';

  @override
  String get searchDestPracticeHubSub => 'الأخطاء والكلمات الضعيفة والتمارين';

  @override
  String get searchDestAiTutor => 'المعلّم الذكي';

  @override
  String get searchDestAiTutorSub => 'تحدّث ودردش ومثّل الأدوار';

  @override
  String get searchDestAdventures => 'المغامرات';

  @override
  String get searchDestAdventuresSub => 'محادثات حقيقية — مجانًا';

  @override
  String get searchDestLeagues => 'الدوريات';

  @override
  String get searchDestLeaguesSub => 'دوريك الأسبوعي';

  @override
  String get searchDestQuests => 'المهام';

  @override
  String get searchDestQuestsSub => 'أهداف ومهام يومية';

  @override
  String get searchDestProgress => 'التقدم';

  @override
  String get searchDestProgressSub => 'إحصاءاتك وسلسلتك';

  @override
  String get searchDestProfile => 'الملف الشخصي';

  @override
  String get searchDestProfileSub => 'ملفك الشخصي';

  @override
  String get searchDestSettings => 'الإعدادات';

  @override
  String get searchDestSettingsSub => 'الحساب والتفضيلات';

  @override
  String get searchDestShop => 'المتجر';

  @override
  String get searchDestShopSub => 'أنفق ماساتك';

  @override
  String get searchDestNotifications => 'الإشعارات';

  @override
  String get searchDestNotificationsSub => 'صندوق إنجازاتك';

  @override
  String get themesTitle => 'السمات';

  @override
  String get themesSubtitle => 'يغيّر مظهر التطبيق كله — انقر للمعاينة الحية';

  @override
  String themesVehicle(String vehicle) {
    return 'المركبة · $vehicle';
  }

  @override
  String get tutorHeader => 'تدرّب على محادثة حقيقية';

  @override
  String get tutorHeaderSub =>
      'اختر مشهدًا ودردش مع Ratel — لا إجابات خاطئة، مجرد تدريب.';

  @override
  String get tutorTalkTitle => 'تحدّث مع Ratel';

  @override
  String get tutorTalkSub => 'تدريب حي على التحدث بالصوت والفيديو';

  @override
  String get tutorChatTitle => 'دردش مع Ratel';

  @override
  String get tutorChatSub => 'دردشة ذكية · ملاحظات على الكتابة';

  @override
  String get tutorRoleplayTitle => 'مشاهد تمثيل الأدوار';

  @override
  String get tutorRoleplayGuided => 'محادثات تمثيل أدوار موجّهة';

  @override
  String tutorScenesCount(int count) {
    return '$count مشاهد';
  }

  @override
  String get tutorUnlockPro => 'افتح RATEL PRO';

  @override
  String get tutorRelayNote =>
      'يعمل التدريس الحي بالذكاء الاصطناعي عبر مرحّل خاضع للإشراف ومضبوط التكلفة، وهو ميزة RATEL PRO. الردود لا تُحاكى أبدًا — لا يبدأ وضع إلا حين يكون PRO والمرحّل نشطين.';

  @override
  String get tutorStatusReadyPro =>
      'PRO نشط والمعلّم الحي متصل — اختر وضعًا للبدء.';

  @override
  String get tutorStatusReadyFree =>
      'المعلّم الحي متصل. التدريس الحي ميزة RATEL PRO.';

  @override
  String get tutorStatusOffline =>
      'المعلّم الحي الخاضع للإشراف غير متصل في هذا الإصدار بعد — سيُفعّل التدريس الحي في خطوة لاحقة. لا شيء أدناه مُحاكى.';

  @override
  String get tutorAnnounceNeedsPro =>
      'يفتح RATEL PRO التدريس الحي بالذكاء الاصطناعي.';

  @override
  String get tutorAnnounceNeedsRelay =>
      'يتصل التدريس الذكي فور تفعيل المرحّل الخاضع للإشراف.';

  @override
  String get tutorAnnounceStarting => 'جارٍ بدء جلستك…';

  @override
  String get adventuresTitle => 'المغامرات';

  @override
  String get adventuresFreeChip => 'مجاني';

  @override
  String get adventuresIntro =>
      'اختر طريقك — كل اختيار يفرّع القصة. لا إجابات خاطئة، ومجاني دائمًا.';

  @override
  String get adventuresFallbackWorld => 'مغامرة';

  @override
  String adventureSheetKicker(String cefr) {
    return '🗺️ مغامرة · $cefr';
  }

  @override
  String adventureScenesCount(int count) {
    return '$count مشاهد';
  }

  @override
  String adventureChoicePoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نقطة قرار',
      many: '$count نقطة قرار',
      few: '$count نقاط قرار',
      two: 'نقطتا قرار',
      one: 'نقطة قرار واحدة',
      zero: 'بلا نقاط قرار',
    );
    return '$_temp0';
  }

  @override
  String get adventureOpeningScene => 'المشهد الافتتاحي';

  @override
  String get adventureStart => 'ابدأ المغامرة';

  @override
  String get adventurePlayerFallbackTitle => 'مغامرة';

  @override
  String get adventureTheEnd => '🏁 النهاية';

  @override
  String get adventureStartOver => 'ابدأ من جديد';

  @override
  String get adventureDone => 'تم';

  @override
  String get adventureCompleteKicker => 'اكتملت المغامرة';

  @override
  String adventureCompleteTitle(String title) {
    return '$title ✓';
  }

  @override
  String get adventureCompleteBody =>
      'أحسنت! حصلت على ‎+15 XP · ‎+5 💎 — استكشف المشهد التالي وقتما تشاء.';

  @override
  String get adventuresEmpty => 'لا مغامرات في هذه الدورة بعد.';

  @override
  String get authWelcomeTitle => 'مرحبًا بك في Ratel';

  @override
  String get authWelcomeSubtitle =>
      'دروس وقصص وبودكاست والمزيد —\nاختر كيف تريد أن تبدأ.';

  @override
  String get authCreateFreeAccount => 'أنشئ حسابًا مجانيًا';

  @override
  String get authAlreadyHaveAccount => 'لدي حساب بالفعل';

  @override
  String get authSettingUp => 'جارٍ التجهيز…';

  @override
  String get authContinueAsGuest => 'المتابعة كضيف';

  @override
  String get authGuestNote =>
      'تقدم الضيف يبقى على هذا الجهاز — أنشئ حسابًا مجانيًا في الإعدادات متى شئت ليبقى معك في كل مكان.';

  @override
  String get authEnterYourEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get authEnterValidEmail => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get authEnterYourPassword => 'أدخل كلمة المرور';

  @override
  String get authCouldNotSignIn => 'تعذّر تسجيل دخولك. حاول مرة أخرى.';

  @override
  String get authSomethingWentWrong => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get authSocialComingSoon =>
      'تسجيل الدخول عبر Google / Apple قادم قريبًا.';

  @override
  String get authResetTitle => 'أعد تعيين كلمة المرور';

  @override
  String get authWelcomeBack => 'مرحبًا بعودتك!';

  @override
  String get authResetSubtitle => 'أدخل بريدك وسنرسل رابط إعادة التعيين.';

  @override
  String get authPickUpWhereYouLeft => 'تابع من حيث توقفت';

  @override
  String get authEmailHint => 'البريد الإلكتروني';

  @override
  String get authPasswordHint => 'كلمة المرور';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authSendResetLink => 'أرسل رابط إعادة التعيين';

  @override
  String get authLogIn => 'تسجيل الدخول';

  @override
  String get authBackToLogIn => 'عودة إلى تسجيل الدخول';

  @override
  String get authNewToRatel => 'جديد على Ratel؟ ';

  @override
  String get authSignUp => 'سجّل الآن';

  @override
  String get authCheckYourInbox => 'تفقد بريدك الوارد';

  @override
  String authResetSent(String email) {
    return 'أرسلنا رابط إعادة تعيين كلمة المرور إلى $email. افتحه لاختيار كلمة مرور جديدة.';
  }

  @override
  String get authCreatePassword => 'أنشئ كلمة مرور';

  @override
  String get authAtLeast8Chars => '8 أحرف على الأقل';

  @override
  String get authCreateYourAccount => 'أنشئ حسابك';

  @override
  String get authSignupSubtitle => 'مجاني للأبد · تعلّم 52 لغة';

  @override
  String get authPassword8Hint => 'كلمة المرور (8 أحرف أو أكثر)';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authAlreadyAccountLead => 'لديك حساب بالفعل؟ ';

  @override
  String get authSignIn => 'سجّل الدخول';

  @override
  String get authConfirmEmail => 'أكّد بريدك الإلكتروني';

  @override
  String authConfirmSent(String email) {
    return 'أرسلنا رابط تأكيد إلى $email. انقر عليه لتفعيل حسابك ثم عد لتسجيل الدخول.';
  }

  @override
  String get authContinueGoogle => 'المتابعة عبر Google';

  @override
  String get authContinueApple => 'المتابعة عبر Apple';

  @override
  String get authOr => 'أو';

  @override
  String get authUnavailableNote =>
      'الحسابات غير متاحة في هذا الإصدار بعد — يمكنك مواصلة التعلم كضيف. سيُفعّل تسجيل الدخول عند تهيئة الخادم.';

  @override
  String get liveMute => 'كتم';

  @override
  String get liveUnmute => 'إلغاء الكتم';

  @override
  String commonDurSeconds(int s) {
    return '$s ث';
  }

  @override
  String commonDurMinutes(int m) {
    return '$m د';
  }

  @override
  String commonDurHours(int h) {
    return '$h س';
  }

  @override
  String commonDurHoursMinutes(int h, int m) {
    return '$h س $m د';
  }

  @override
  String practiceGradeInterval(String label, int days) {
    return '$label · $days ي';
  }
}
