// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get navHome => 'Главная';

  @override
  String get navLibrary => 'Библиотека';

  @override
  String get navLeagues => 'Лиги';

  @override
  String get navQuests => 'Задания';

  @override
  String get navProfile => 'Профиль';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSectionLearning => 'Обучение';

  @override
  String get settingsSectionSubscription => 'Подписка';

  @override
  String get settingsSectionAccessibility => 'Специальные возможности';

  @override
  String get settingsSectionNotifications => 'Уведомления';

  @override
  String get settingsSectionAppearanceAccount => 'Внешний вид и аккаунт';

  @override
  String get settingsAppLanguage => 'Язык приложения';

  @override
  String get settingsAppLanguageSystem => 'Как в системе';

  @override
  String get homeCourseLoadingTitle => 'Ваш курс готовится';

  @override
  String get homeCourseLoadingBody =>
      'Уроки появятся здесь, когда загрузится содержимое курса.';

  @override
  String get homeGuideChip => 'Гид';

  @override
  String get homeStartNode => 'НАЧАТЬ';

  @override
  String get homeUnitGuideHeader => 'ГИД ПО РАЗДЕЛУ';

  @override
  String get commonDone => 'Готово';

  @override
  String homeUnitKicker(String unit) {
    return 'РАЗДЕЛ · $unit';
  }

  @override
  String homeLessonMeta(int num, int count, String exercises) {
    return 'Урок $num из $count · $exercises.';
  }

  @override
  String homeQuickExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count быстрого упражнения',
      many: '$count быстрых упражнений',
      few: '$count быстрых упражнения',
      one: '$count быстрое упражнение',
    );
    return '$_temp0';
  }

  @override
  String get homeEnergyChip => '−1 ⚡ энергия';

  @override
  String get homeXpChip => '+20 XP';

  @override
  String get homeStartLesson => 'Начать урок';

  @override
  String get homeTutorChip => 'Наставник';

  @override
  String get libraryAiTutor => 'ИИ-наставник';

  @override
  String get libraryAiTutorSub =>
      'Говорите, общайтесь, разыгрывайте сценки — разбор письма';

  @override
  String get libraryRoleplay => 'Ролевая игра';

  @override
  String get libraryRoleplaySub =>
      'Отрабатывайте ответы — с оценкой, всегда бесплатно';

  @override
  String get librarySectionPractice => 'Практика';

  @override
  String get libraryPracticeHub => 'Центр практики';

  @override
  String get libraryPracticeHubSub =>
      'Ошибки, слабые слова и упражнения · БЕСПЛАТНО';

  @override
  String get librarySectionReadListen => 'Читать и слушать';

  @override
  String get libraryGradedStories => 'Адаптированные истории';

  @override
  String get libraryPodcasts => 'Подкасты';

  @override
  String get libraryWatch => 'Смотреть';

  @override
  String get librarySearchHint => 'Ищите уроки, слова, истории…';

  @override
  String get libraryFeaturedStory => 'ИЗБРАННОЕ · ИСТОРИЯ';

  @override
  String commonLevel(String cefr) {
    return 'Уровень $cefr';
  }

  @override
  String get libraryReadNow => 'Читать сейчас';

  @override
  String get libraryNewExplore => 'НОВОЕ · ИССЛЕДУЙ';

  @override
  String get libraryAdventures => 'Приключения';

  @override
  String get libraryStartExploring => 'Начать исследовать →';

  @override
  String get libraryKindStory => 'История';

  @override
  String get libraryKindPodcast => 'Подкаст';

  @override
  String get libraryKindVideo => 'Видео';

  @override
  String get libraryAllStories => 'Все истории';

  @override
  String get libraryAllPodcasts => 'Все подкасты';

  @override
  String get libraryAllVideos => 'Все видео';

  @override
  String get lessonTypeWhatYouHear => 'Напишите то, что слышите';

  @override
  String get lessonTapWhatYouHear => 'Соберите то, что слышите';

  @override
  String get lessonTranslateSentence => 'Переведите это предложение';

  @override
  String get lessonTypeAnswerHint => 'Введите свой ответ…';

  @override
  String get lessonWriteAnswerHint => 'Напишите свой ответ…';

  @override
  String get lessonContinue => 'Продолжить';

  @override
  String get lessonSkip => 'Пропустить';

  @override
  String get lessonCheck => 'Проверить';

  @override
  String get lessonNicelyDone => '✓ Отлично!';

  @override
  String get lessonNotQuite => '✕ Не совсем';

  @override
  String lessonAnswerReveal(String answer) {
    return 'Ответ: $answer';
  }

  @override
  String get lessonCompleteKicker => 'УРОК ПРОЙДЕН';

  @override
  String get lessonCompleteTitle => 'Урок пройден!';

  @override
  String lessonCompleteSummary(int correct, int graded, String level) {
    return '$correct из $graded верно · теперь $level';
  }

  @override
  String get lessonStatTotalXp => 'ВСЕГО XP';

  @override
  String get lessonStatAccuracy => 'ТОЧНОСТЬ';

  @override
  String get lessonStatTime => 'ВРЕМЯ';

  @override
  String get onboardingWelcomeTitle => 'Привет, я Рател!';

  @override
  String get onboardingWelcomeBody =>
      'Учите язык без страха — короткие уроки, весело и бесплатно. Готовы копнуть глубже?';

  @override
  String get onboardingHaveAccount => 'У меня уже есть аккаунт';

  @override
  String get onboardingTryWithoutAccount => 'Попробовать без аккаунта →';

  @override
  String get onboardingGetStarted => 'Начать';

  @override
  String get onboardingStartLearning => 'Начать обучение';

  @override
  String get onboardingLanguageTitle => 'Что вы хотите изучать?';

  @override
  String get onboardingLanguageSubtitle => 'Доступно 52 языка';

  @override
  String get onboardingReasonTitle => 'Зачем вы учитесь?';

  @override
  String get onboardingGoalTitle => 'Выберите дневную цель';

  @override
  String get onboardingPlacementTitle => 'Найдите свою отправную точку';

  @override
  String onboardingPlacementBody(String language) {
    return 'Вы новичок в языке ($language) или уже что-то знаете?';
  }

  @override
  String get onboardingBrandNew => 'Я совсем новичок';

  @override
  String get onboardingBrandNewSub => 'Начать с самого начала';

  @override
  String get onboardingPlacementTest => 'Пройти тест на уровень';

  @override
  String get onboardingPlacementTestSub => '~3 мин · сразу к своему уровню';

  @override
  String onboardingXpPerDay(int xp) {
    return '$xp XP / день';
  }

  @override
  String get reasonTravel => 'Путешествия';

  @override
  String get reasonCulture => 'Культура';

  @override
  String get reasonCareer => 'Карьера';

  @override
  String get reasonFamilyFriends => 'Семья и друзья';

  @override
  String get reasonBrainTraining => 'Тренировка мозга';

  @override
  String get reasonJustForFun => 'Просто для удовольствия';

  @override
  String get goalCasual => 'Лёгкий';

  @override
  String get goalRegular => 'Обычный';

  @override
  String get goalSerious => 'Серьёзный';

  @override
  String get goalIntense => 'Интенсивный';

  @override
  String get langNameSpanish => 'Испанский';

  @override
  String get langNameFrench => 'Французский';

  @override
  String get langNameJapanese => 'Японский';

  @override
  String get langNameTamil => 'Тамильский';

  @override
  String get langNameGerman => 'Немецкий';

  @override
  String get langNameKorean => 'Корейский';

  @override
  String get settingsDailyGoal => 'Дневная цель';

  @override
  String settingsGoalRow(String label, int xp) {
    return '$label · $xp XP/день';
  }

  @override
  String get profileAchievements => 'Достижения';

  @override
  String get profileFriends => 'Друзья';

  @override
  String get profileShop => 'Магазин';

  @override
  String get profileNotifications => 'Уведомления';

  @override
  String get profileSeeOnboarding => 'Посмотреть онбординг ↗';

  @override
  String get profileNotSignedIn => 'Вы не вошли';

  @override
  String get profileCreateAccount => 'Создать бесплатный аккаунт';

  @override
  String get profileSaveProgress => 'Сохраняйте прогресс на всех устройствах';

  @override
  String profileTodaysGoal(int today, int goal) {
    return 'Цель на сегодня · $today/$goal XP';
  }

  @override
  String get profileViewProgress => 'Смотреть прогресс →';

  @override
  String get profileUnlocked => 'Открыто';

  @override
  String questsResetsIn(int h, int m) {
    return 'Сброс через $hч $mмин';
  }

  @override
  String get questsDailyRefresh => 'Ежедневное обновление';

  @override
  String get questsFreshMix => 'Свежая подборка из 5 вопросов';

  @override
  String get questsServedFromQueue =>
      'Из вашей реальной очереди повторения — даёт настоящий XP.';

  @override
  String get questsGoalReached => 'Дневная цель достигнута! 🎉';

  @override
  String questsReachGoal(int goal) {
    return 'Наберите $goal XP сегодня';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return 'Ежедневные задания · $done/$total';
  }

  @override
  String get questsInfoNote =>
      'Задания отслеживают ваш реальный ежедневный прогресс. Сундуки наград, задания с друзьями и недельный рейтинг требуют серверной экономики — решение владельца (§6). Фальшивые награды не показываются.';

  @override
  String get questsStartRefresh => 'Начать ежедневное обновление';

  @override
  String get questsStart => 'Начать';

  @override
  String get questsPractisedToday =>
      'Сегодня занимались — серия в безопасности';

  @override
  String get questsEarnAnyXp => 'Получите любой XP сегодня';

  @override
  String questsXpToday(int current, int target) {
    return '$current/$target XP сегодня';
  }

  @override
  String get leaguesYourGroup => 'ВАША ГРУППА';

  @override
  String leaguesThisWeek(int size) {
    return 'ЭТА НЕДЕЛЯ · УЧАЩИХСЯ: $size';
  }

  @override
  String get leaguesTiers => 'Лиги';

  @override
  String leaguesTopClimb(int top, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня',
      many: '$days дней',
      few: '$days дня',
      one: '$days день',
    );
    return 'Топ-$top поднимаются каждую неделю · конец через $_temp0';
  }

  @override
  String get leaguesDemotionZone => 'Зона вылета';

  @override
  String get leaguesPromotionZone => 'Зона повышения';

  @override
  String get leaguesSafeZone => 'Безопасная зона';

  @override
  String get leaguesYou => 'Вы';

  @override
  String leaguesPromoteRelegate(int top, int bottom) {
    return 'Топ-$top поднимаются · последние $bottom выбывают в конце недели.';
  }

  @override
  String get leaguesYouAreHere => 'Вы здесь';

  @override
  String get leaguesViewAllTiers => '🏆 Все 10 лиг ›';

  @override
  String get notifMarkAllRead => 'Отметить всё прочитанным';

  @override
  String get notifEmptyTitle => 'Пока нет уведомлений';

  @override
  String get notifEmptyBody =>
      'Проходите уроки, копите серию и повышайте уровень — ваши достижения появятся здесь, как только вы их действительно заработаете.';

  @override
  String get notifPushNote =>
      'Это внутренние вехи приложения, они появляются в момент достижения. Пуш-уведомления и напоминания — решение владельца, пока не включены. Здесь ничего не подделано.';

  @override
  String get shopPowerUps => 'Усиления';

  @override
  String get shopStreakFreeze => 'Заморозка серии';

  @override
  String get shopStreakFreezeDesc =>
      'Сохраняет серию за один пропущенный день. Тратится автоматически, если вы не выполнили дневную цель.';

  @override
  String shopOwned(int have, int max) {
    return 'В наличии $have/$max';
  }

  @override
  String get shopMaxedOut => 'Максимум';

  @override
  String shopBuyFor(int cost) {
    return 'Купить за $cost 💎';
  }

  @override
  String get shopFreezeAdded => 'Заморозка серии добавлена 💪';

  @override
  String shopFreezeAtCap(int max) {
    return 'У вас уже максимум заморозок ($max).';
  }

  @override
  String shopNotEnoughEarnCost(int cost) {
    return 'Недостаточно 💎 — заработайте $cost, проходя уроки.';
  }

  @override
  String get shopNotEnoughEarnMore =>
      'Недостаточно 💎 — заработайте больше, проходя уроки.';

  @override
  String get shopEnergyRefill => 'Восполнение энергии';

  @override
  String get shopEnergyRefillDesc =>
      'Мгновенно восполните энергию до максимума. Энергия только для отображения — уроки никогда не блокируются.';

  @override
  String get shopAlreadyFull => 'Уже полная';

  @override
  String get shopEnergyRefilled => 'Энергия восполнена ⚡';

  @override
  String get shopEnergyAlreadyFull => 'Ваша энергия уже полная.';

  @override
  String get shopStreakRepair => 'Починка серии';

  @override
  String get shopStreakRepairDesc =>
      'Потеряли серию? Верните её прежнюю длину и продолжайте.';

  @override
  String get shopStreakLapsed => 'Серия прервана';

  @override
  String shopStreakDays(int days) {
    return '🔥 Серия $days дн.';
  }

  @override
  String shopRepairFor(int cost) {
    return 'Починить за $cost 💎';
  }

  @override
  String get shopStreakRestored => 'Серия восстановлена 🔥';

  @override
  String get shopStreakSafe => 'Ваша серия в порядке — чинить нечего.';

  @override
  String get shopDoubleXp => 'Двойной XP';

  @override
  String get shopDoubleXpDesc =>
      'Получайте 2× XP за каждый урок в течение 15 минут.';

  @override
  String shopActiveLeft(int minutes) {
    return 'Активно · осталось $minutes мин';
  }

  @override
  String get shopInactive => 'Неактивно';

  @override
  String get shopActive => 'Активно';

  @override
  String get shopDoubleXpActive => 'Двойной XP активирован ✨';

  @override
  String get shopBoostRunning => 'Буст работает — XP удваивается.';

  @override
  String get shopBadgerOutfits => 'Наряды барсука';

  @override
  String get paywallTitle => 'RATEL PRO';

  @override
  String get paywallStartTrial => 'Начать бесплатный 7-дневный период';

  @override
  String paywallGoPro(String price) {
    return 'Перейти на Pro — $price/мес';
  }

  @override
  String get paywallRestore => 'Восстановить покупки';

  @override
  String get paywallHero => 'Живой ИИ-репетитор, без рекламы и офлайн-уроки.';

  @override
  String get paywallAnnual => 'Годовая';

  @override
  String get paywallMonthly => 'Месячная';

  @override
  String get paywallTrialHow => 'Как работает бесплатный 7-дневный период';

  @override
  String get paywallTrialToday => 'Сегодня';

  @override
  String get paywallTrialTodayDesc =>
      'Открывается полный доступ Pro. Без списаний.';

  @override
  String get paywallTrialDay5 => 'День 5';

  @override
  String get paywallTrialDay5Desc => 'Напомним до окончания пробного периода.';

  @override
  String get paywallTrialDay7 => 'День 7';

  @override
  String paywallTrialDay7Desc(String price) {
    return 'Начнётся тариф $price/год, если не отмените.';
  }

  @override
  String get paywallFeatureLiveAi =>
      'Живой ИИ: голос, чат с репетитором и разбор письма';

  @override
  String get paywallFeatureNoAds => 'Никакой рекламы, нигде';

  @override
  String get paywallFeatureOffline => 'Офлайн-уроки и аудио';

  @override
  String get paywallFeaturePronunciation => 'Советы ИИ по произношению';

  @override
  String get paywallEverythingFree =>
      'Всё остальное — все 52 языка, аудио, повторение, лиги, ролевые сценки и произношение на устройстве — остаётся бесплатным для всех.';

  @override
  String get paywallYouArePro => 'У вас RATEL PRO';

  @override
  String get paywallThanks =>
      'Спасибо за поддержку Ratel. Управляйте подпиской или отменяйте её в Настройки → Управление подпиской.';

  @override
  String get paywallManage => 'Управление подпиской';

  @override
  String paywallFinePrint(String regions) {
    return 'Отмена в любой момент в настройках. Цены указаны для $regions; вашу локальную цену определяет магазин приложений.';
  }
}
