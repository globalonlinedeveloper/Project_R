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

  @override
  String get questTitlePowerSession => 'Мощная сессия';

  @override
  String get questDescPowerSession => 'Заработайте вдвое больше дневной цели';

  @override
  String get questTitleOnFire => 'В ударе';

  @override
  String get questDescOnFire => 'Заработайте втрое больше дневной цели';

  @override
  String get questTitleStreakKeeper => 'Хранитель серии';

  @override
  String get questDescStreakKeeper =>
      'Позанимайтесь сегодня, чтобы сохранить серию';

  @override
  String get notifTitleLessons1 => 'Первый урок пройден';

  @override
  String get notifBodyLessons1 =>
      'Вы закончили свой первый урок — отличное начало!';

  @override
  String get notifTitleLessons5 => '5 уроков пройдено';

  @override
  String get notifBodyLessons5 => 'Вы прошли 5 уроков. Не сбавляйте темп.';

  @override
  String get notifTitleLessons10 => '10 уроков пройдено';

  @override
  String get notifBodyLessons10 =>
      'Десять уроков — вы формируете настоящую привычку.';

  @override
  String get notifTitleLessons25 => '25 уроков пройдено';

  @override
  String get notifBodyLessons25 =>
      'Двадцать пять уроков. Впечатляющее упорство!';

  @override
  String get notifTitleLessons50 => '50 уроков пройдено';

  @override
  String get notifBodyLessons50 => 'Пятьдесят уроков — вы на верном пути.';

  @override
  String get notifTitleStreak3 => 'Серия 3 дня!';

  @override
  String get notifBodyStreak3 => 'Три дня подряд. Постоянство — это всё.';

  @override
  String get notifTitleStreak7 => 'Серия 7 дней!';

  @override
  String get notifBodyStreak7 =>
      'Целая неделя ежедневных занятий. Превосходно!';

  @override
  String get notifTitleStreak14 => 'Серия 14 дней!';

  @override
  String get notifBodyStreak14 => 'Две недели подряд — вас не остановить.';

  @override
  String get notifTitleStreak30 => 'Серия 30 дней!';

  @override
  String get notifBodyStreak30 => 'Целый месяц ежедневных занятий. Невероятно.';

  @override
  String get notifTitleXp100 => 'Заработано 100 XP';

  @override
  String get notifBodyXp100 => 'Ваши первые сто XP — темп нарастает.';

  @override
  String get notifTitleXp500 => 'Заработано 500 XP';

  @override
  String get notifBodyXp500 => 'Пятьсот XP. Вы отлично работаете.';

  @override
  String get notifTitleXp1000 => 'Заработано 1 000 XP';

  @override
  String get notifBodyXp1000 => 'Рубеж в тысячу XP взят!';

  @override
  String get notifTitleXp2500 => 'Заработано 2 500 XP';

  @override
  String get notifBodyXp2500 =>
      'Две с половиной тысячи XP — серьёзный прогресс.';

  @override
  String get notifTitleLevel1 => 'Достигнут уровень A2';

  @override
  String get notifBodyLevel1 => 'Ваш уровень вырос с A1 до A2. Вперёд!';

  @override
  String get notifTitleLevel2 => 'Достигнут уровень B1';

  @override
  String get notifBodyLevel2 => 'Теперь вы учащийся среднего уровня (B1).';

  @override
  String get notifTitleLevel3 => 'Достигнут уровень B2';

  @override
  String get notifBodyLevel3 =>
      'Достигнут уровень выше среднего (B2). Блестяще.';

  @override
  String get notifTitleLevel4 => 'Достигнут уровень C1';

  @override
  String get notifBodyLevel4 => 'Продвинутый (C1) — ваш испанский силён.';

  @override
  String get notifTitleLevel5 => 'Достигнут уровень C2';

  @override
  String get notifBodyLevel5 => 'Свободное владение (C2) — вершина шкалы!';

  @override
  String get achTitleFirstSteps => 'Первые шаги';

  @override
  String get achTitleScholar => 'Учёный';

  @override
  String get achTitleWildfire => 'Пожар';

  @override
  String get achTitlePointMaker => 'Мастер очков';

  @override
  String get achTitleCollector => 'Коллекционер';

  @override
  String get achTitleRisingStar => 'Восходящая звезда';

  @override
  String get leagueTierBronze => 'Бронза';

  @override
  String get leagueTierSilver => 'Серебро';

  @override
  String get leagueTierGold => 'Золото';

  @override
  String get leagueTierSapphire => 'Сапфир';

  @override
  String get leagueTierRuby => 'Рубин';

  @override
  String get leagueTierEmerald => 'Изумруд';

  @override
  String get leagueTierAmethyst => 'Аметист';

  @override
  String get leagueTierPearl => 'Жемчуг';

  @override
  String get leagueTierObsidian => 'Обсидиан';

  @override
  String get leagueTierDiamond => 'Алмаз';

  @override
  String get cefrNameBeginner => 'Начинающий';

  @override
  String get cefrNameElementary => 'Элементарный';

  @override
  String get cefrNameIntermediate => 'Средний';

  @override
  String get cefrNameUpperIntermediate => 'Выше среднего';

  @override
  String get cefrNameAdvanced => 'Продвинутый';

  @override
  String get cefrNameProficient => 'Свободный';

  @override
  String leaguesTierLeague(String tier) {
    return 'Лига $tier';
  }

  @override
  String leaguesYoureIn(String tier) {
    return 'Вы в лиге $tier · топ-7 поднимаются каждую неделю';
  }

  @override
  String get leaguesZonePromotion => '⬆ ЗОНА ПОВЫШЕНИЯ';

  @override
  String get leaguesZoneDemotion => '⬇ ЗОНА ВЫЛЕТА';

  @override
  String profileAchievementsSummary(int unlocked, int total) {
    return 'Открыто $unlocked из $total · реальный прогресс';
  }

  @override
  String get profileRealStateNote =>
      'Уровень, XP, уроки, серия и сохранённые слова — реальное состояние движка; на новом аккаунте они начинаются с нуля.';

  @override
  String get practiceTitle => 'Практика';

  @override
  String practiceReviewWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Повторить $count слова',
      many: 'Повторить $count слов',
      few: 'Повторить $count слова',
      one: 'Повторить $count слово',
    );
    return '$_temp0';
  }

  @override
  String get practiceYourWords => 'Ваши слова';

  @override
  String practiceSavedWordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сохранённого слова',
      many: '$count сохранённых слов',
      few: '$count сохранённых слова',
      one: '$count сохранённое слово',
    );
    return '$_temp0';
  }

  @override
  String practiceDueForReview(int count) {
    return '$count к интервальному повторению';
  }

  @override
  String get practiceAllUpToDate => 'Все повторения выполнены';

  @override
  String practiceCaughtUp(String tail) {
    return 'Всё выполнено — сейчас ничего не ожидает$tail.';
  }

  @override
  String practiceNextTail(String when) {
    return ' · следующее $when';
  }

  @override
  String get practiceZeroDue => '0 к повторению';

  @override
  String get practiceDueNow => 'Пора повторить';

  @override
  String practiceDueWhen(String when) {
    return 'Повторение $when';
  }

  @override
  String get practiceChipDue => 'Пора';

  @override
  String get practiceChipScheduled => 'Запланировано';

  @override
  String get practiceScheduleNote =>
      'Повторения планирует настоящий движок интервальных повторений FSRS-6. Даты действуют в этой сессии; сохранение между перезапусками — шаг перед запуском. Здесь ничего не выдумано.';

  @override
  String get practiceNoSavedWords => 'Пока нет сохранённых слов';

  @override
  String get practiceSaveWordHint =>
      'Сохраните слово во время урока, и оно появится здесь как карточка. Затем настоящий движок FSRS запланирует повторения — ничего не заполнено заранее.';

  @override
  String get practiceStartLesson => 'Начать урок';

  @override
  String practiceWordOf(int n, int total) {
    return 'Слово $n из $total';
  }

  @override
  String get practiceShowAnswer => 'Показать ответ';

  @override
  String get practiceRecallHint =>
      'Вспомните значение, затем оцените, насколько хорошо вспомнили.';

  @override
  String get practiceGradeAgain => 'Снова';

  @override
  String get practiceGradeHard => 'Трудно';

  @override
  String get practiceGradeGood => 'Хорошо';

  @override
  String get practiceGradeEasy => 'Легко';

  @override
  String get practiceFsrsGradeNote =>
      'FSRS-6 планирует следующее повторение по вашей оценке';

  @override
  String get practiceReviewComplete => 'Повторение завершено';

  @override
  String practiceReviewedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Вы повторили $count слова. FSRS перепланировал их.',
      many: 'Вы повторили $count слов. FSRS перепланировал их.',
      few: 'Вы повторили $count слова. FSRS перепланировал их.',
      one: 'Вы повторили $count слово. FSRS перепланировал его.',
    );
    return '$_temp0';
  }

  @override
  String get practiceDone => 'Готово';

  @override
  String get practiceRelTomorrow => 'завтра';

  @override
  String practiceRelInDays(int days) {
    return 'через $days дн.';
  }

  @override
  String practiceRelInHours(int hours) {
    return 'через $hours ч';
  }

  @override
  String practiceRelInMinutes(int minutes) {
    return 'через $minutes мин';
  }

  @override
  String get practiceRelSoon => 'скоро';

  @override
  String get progressTitle => 'Прогресс';

  @override
  String get progressShareMilestone => 'Поделиться вехой';

  @override
  String get progressLast7Days => 'Последние 7 дней';

  @override
  String get progressAccuracyRetention => 'Точность и удержание';

  @override
  String get progressHonestyNote =>
      'Всё здесь — реальное записанное состояние: уровень, способность, сохранённые слова, XP, уроки, серия, история за 7 дней, точность и время занятий начинаются с нуля и растут по мере обучения. Удержание — прогноз воспоминания этой сессии (межсессионный планировщик — работа к запуску); ничего не выдумано.';

  @override
  String progressShareText(
    String level,
    String levelName,
    int streak,
    int xp,
    int lessons,
  ) {
    return '🦡 RATEL · Уровень $level ($levelName)\n🔥 Серия $streak дн. · ⚡ $xp XP · 📘 $lessons уроков\nУчусь на learnwithratel.com';
  }

  @override
  String get progressShareCopied =>
      'Веха скопирована в буфер обмена — делитесь где угодно!';

  @override
  String progressAbilityLine(String theta) {
    return 'Способность θ $theta · реальная оценка';
  }

  @override
  String get progressStatSavedWords => 'Сохранённые слова';

  @override
  String get progressStatLessons => 'Уроки';

  @override
  String get progressStatDayStreak => 'Дней серии';

  @override
  String get progressStatTotalXp => 'Всего XP';

  @override
  String get progressStatTodaysXp => 'XP сегодня';

  @override
  String get progressStatCefrLevel => 'Уровень CEFR';

  @override
  String get progressAccuracy => 'Точность';

  @override
  String get progressStudyTime => 'Время занятий';

  @override
  String get progressRetention => 'Удержание';

  @override
  String get progressNoData => 'Пока нет данных';

  @override
  String get progressAccuracyEmpty =>
      'Отвечайте на оцениваемые задания, чтобы начать';

  @override
  String progressAccuracyDetail(int correct, int total) {
    return '$correct из $total верно';
  }

  @override
  String get progressTimeEmpty => 'Время уроков суммируется здесь';

  @override
  String get progressTimeDetail => 'по всем вашим урокам';

  @override
  String get progressRetentionEmpty =>
      'Повторяйте, чтобы увидеть прогноз воспоминания';

  @override
  String progressRetentionDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'прогноз воспоминания на 1 день · $count элемента за сессию',
      many: 'прогноз воспоминания на 1 день · $count элементов за сессию',
      few: 'прогноз воспоминания на 1 день · $count элемента за сессию',
      one: 'прогноз воспоминания на 1 день · $count элемент за сессию',
    );
    return '$_temp0';
  }

  @override
  String progressWeekTotal(int xp) {
    return '$xp XP · последние 7 дней';
  }

  @override
  String get progressNoXpYet => 'XP ещё не записан';

  @override
  String get progressChartEmptyNote =>
      'Закончите урок, чтобы начать историю за 7 дней — неактивные дни остаются на нуле, ничего не выдумано.';

  @override
  String get commonDowMon => 'Пн';

  @override
  String get commonDowTue => 'Вт';

  @override
  String get commonDowWed => 'Ср';

  @override
  String get commonDowThu => 'Чт';

  @override
  String get commonDowFri => 'Пт';

  @override
  String get commonDowSat => 'Сб';

  @override
  String get commonDowSun => 'Вс';

  @override
  String get searchTitle => 'Поиск';

  @override
  String get searchHint => 'Ищите уроки, слова, истории…';

  @override
  String get searchRecent => 'Недавние';

  @override
  String get searchClear => 'Очистить';

  @override
  String get searchJumpTo => 'Перейти к';

  @override
  String get searchTagPage => 'Страница';

  @override
  String get searchTagWord => 'Слово';

  @override
  String get searchSubtitleSavedWord => 'Сохранённое слово';

  @override
  String searchLessonSubtitle(String unit) {
    return '$unit · Урок';
  }

  @override
  String searchNoMatches(String query) {
    return 'Нет результатов по запросу «$query»';
  }

  @override
  String get searchEmptyNote =>
      'Поиск по названиям, тегам и содержимому уроков вашего курса, сохранённым словам и страницам. Серверный индекс контента и тренды — следующий шаг R-L12; здесь ничего не подделано.';

  @override
  String get searchNoMatchNote =>
      'Ищет по опубликованным урокам курса, сохранённым словам и страницам приложения (названия + теги). Истории/подкасты и полнотекстовый поиск — следующий шаг R-L12; никогда не подделывается.';

  @override
  String get searchFooterNote =>
      'На старте — названия + теги. Полный текст, истории/подкасты и мультикурс — следующий шаг R-L12; никогда не подделывается.';

  @override
  String get searchDestPracticeHub => 'Центр практики';

  @override
  String get searchDestPracticeHubSub => 'Ошибки, слабые слова и тренировки';

  @override
  String get searchDestAiTutor => 'ИИ-репетитор';

  @override
  String get searchDestAiTutorSub => 'Говорите, переписывайтесь, играйте роли';

  @override
  String get searchDestAdventures => 'Приключения';

  @override
  String get searchDestAdventuresSub => 'Настоящие диалоги — бесплатно';

  @override
  String get searchDestLeagues => 'Лиги';

  @override
  String get searchDestLeaguesSub => 'Ваша недельная лига';

  @override
  String get searchDestQuests => 'Задания';

  @override
  String get searchDestQuestsSub => 'Дневные цели и задания';

  @override
  String get searchDestProgress => 'Прогресс';

  @override
  String get searchDestProgressSub => 'Ваша статистика и серия';

  @override
  String get searchDestProfile => 'Профиль';

  @override
  String get searchDestProfileSub => 'Ваш профиль';

  @override
  String get searchDestSettings => 'Настройки';

  @override
  String get searchDestSettingsSub => 'Аккаунт и предпочтения';

  @override
  String get searchDestShop => 'Магазин';

  @override
  String get searchDestShopSub => 'Потратьте свои алмазы';

  @override
  String get searchDestNotifications => 'Уведомления';

  @override
  String get searchDestNotificationsSub => 'Ваш ящик достижений';

  @override
  String get themesTitle => 'Темы';

  @override
  String get themesSubtitle =>
      'Меняет стиль всего приложения — коснитесь для живого предпросмотра';

  @override
  String themesVehicle(String vehicle) {
    return 'Транспорт · $vehicle';
  }

  @override
  String get tutorHeader => 'Практикуйте настоящий разговор';

  @override
  String get tutorHeaderSub =>
      'Выберите сцену и общайтесь с Ratel — неправильных ответов нет, только практика.';

  @override
  String get tutorTalkTitle => 'Говорить с Ratel';

  @override
  String get tutorTalkSub => 'Живая разговорная практика с голосом и видео';

  @override
  String get tutorChatTitle => 'Чат с Ratel';

  @override
  String get tutorChatSub => 'ИИ-чат · разбор письма';

  @override
  String get tutorRoleplayTitle => 'Ролевые сцены';

  @override
  String get tutorRoleplayGuided => 'Ролевые диалоги с подсказками';

  @override
  String tutorScenesCount(int count) {
    return '$count сцен';
  }

  @override
  String get tutorUnlockPro => 'Открыть RATEL PRO';

  @override
  String get tutorRelayNote =>
      'Живое ИИ-обучение работает через модерируемый реле-сервис с контролем затрат и является функцией RATEL PRO. Ответы никогда не имитируются — режим запускается только когда активны PRO и реле.';

  @override
  String get tutorStatusReadyPro =>
      'PRO активен, живой репетитор подключён — выберите режим, чтобы начать.';

  @override
  String get tutorStatusReadyFree =>
      'Живой репетитор подключён. Живое обучение — функция RATEL PRO.';

  @override
  String get tutorStatusOffline =>
      'Модерируемый живой репетитор в этой сборке ещё не подключён — живое обучение включится на следующем шаге. Ничего ниже не имитируется.';

  @override
  String get tutorAnnounceNeedsPro => 'RATEL PRO открывает живое ИИ-обучение.';

  @override
  String get tutorAnnounceNeedsRelay =>
      'ИИ-обучение подключится после включения модерируемого реле.';

  @override
  String get tutorAnnounceStarting => 'Начинаем вашу сессию…';

  @override
  String get adventuresTitle => 'Приключения';

  @override
  String get adventuresFreeChip => 'БЕСПЛАТНО';

  @override
  String get adventuresIntro =>
      'Выбирайте свой путь — каждый выбор ветвит историю. Неправильных ответов нет, всегда бесплатно.';

  @override
  String get adventuresFallbackWorld => 'Приключение';

  @override
  String adventureSheetKicker(String cefr) {
    return '🗺️ ПРИКЛЮЧЕНИЕ · $cefr';
  }

  @override
  String adventureScenesCount(int count) {
    return '$count сцен';
  }

  @override
  String adventureChoicePoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count точки выбора',
      many: '$count точек выбора',
      few: '$count точки выбора',
      one: '$count точка выбора',
    );
    return '$_temp0';
  }

  @override
  String get adventureOpeningScene => 'ПЕРВАЯ СЦЕНА';

  @override
  String get adventureStart => 'Начать приключение';

  @override
  String get adventurePlayerFallbackTitle => 'Приключение';

  @override
  String get adventureTheEnd => '🏁 Конец';

  @override
  String get adventureStartOver => 'Начать заново';

  @override
  String get adventureDone => 'Готово';

  @override
  String get adventureCompleteKicker => 'ПРИКЛЮЧЕНИЕ ПРОЙДЕНО';

  @override
  String adventureCompleteTitle(String title) {
    return '$title ✓';
  }

  @override
  String get adventureCompleteBody =>
      'Отлично! Получено +15 XP · +5 💎 — исследуйте следующую сцену, когда захотите.';

  @override
  String get adventuresEmpty => 'В этом курсе пока нет приключений.';

  @override
  String get authWelcomeTitle => 'Добро пожаловать в Ratel';

  @override
  String get authWelcomeSubtitle =>
      'Уроки, истории, подкасты и не только —\nвыберите, как начать.';

  @override
  String get authCreateFreeAccount => 'Создать бесплатный аккаунт';

  @override
  String get authAlreadyHaveAccount => 'У меня уже есть аккаунт';

  @override
  String get authSettingUp => 'Готовим всё…';

  @override
  String get authContinueAsGuest => 'Продолжить как гость';

  @override
  String get authGuestNote =>
      'Гостевой прогресс хранится на этом устройстве — создайте бесплатный аккаунт в настройках в любой момент, чтобы он был с вами везде.';

  @override
  String get authEnterYourEmail => 'Введите свою почту';

  @override
  String get authEnterValidEmail => 'Введите корректную почту';

  @override
  String get authEnterYourPassword => 'Введите пароль';

  @override
  String get authCouldNotSignIn => 'Не удалось войти. Попробуйте ещё раз.';

  @override
  String get authSomethingWentWrong =>
      'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get authSocialComingSoon =>
      'Вход через Google / Apple скоро появится.';

  @override
  String get authResetTitle => 'Сбросьте пароль';

  @override
  String get authWelcomeBack => 'С возвращением!';

  @override
  String get authResetSubtitle =>
      'Введите почту — мы отправим ссылку для сброса.';

  @override
  String get authPickUpWhereYouLeft =>
      'Продолжите с того места, где остановились';

  @override
  String get authEmailHint => 'Почта';

  @override
  String get authPasswordHint => 'Пароль';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authSendResetLink => 'Отправить ссылку';

  @override
  String get authLogIn => 'Войти';

  @override
  String get authBackToLogIn => 'Назад ко входу';

  @override
  String get authNewToRatel => 'Впервые в Ratel? ';

  @override
  String get authSignUp => 'Регистрация';

  @override
  String get authCheckYourInbox => 'Проверьте почту';

  @override
  String authResetSent(String email) {
    return 'Мы отправили ссылку для сброса пароля на $email. Откройте её, чтобы выбрать новый пароль.';
  }

  @override
  String get authCreatePassword => 'Придумайте пароль';

  @override
  String get authAtLeast8Chars => 'Не менее 8 символов';

  @override
  String get authCreateYourAccount => 'Создайте аккаунт';

  @override
  String get authSignupSubtitle => 'Бесплатно навсегда · учите 52 языка';

  @override
  String get authPassword8Hint => 'Пароль (8+ символов)';

  @override
  String get authCreateAccount => 'Создать аккаунт';

  @override
  String get authAlreadyAccountLead => 'Уже есть аккаунт? ';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authConfirmEmail => 'Подтвердите почту';

  @override
  String authConfirmSent(String email) {
    return 'Мы отправили ссылку подтверждения на $email. Нажмите её, чтобы активировать аккаунт, и возвращайтесь ко входу.';
  }

  @override
  String get authContinueGoogle => 'Продолжить с Google';

  @override
  String get authContinueApple => 'Продолжить с Apple';

  @override
  String get authOr => 'или';

  @override
  String get authUnavailableNote =>
      'Аккаунты в этой сборке пока недоступны — можно продолжать учиться как гость. Вход включится после настройки бэкенда.';

  @override
  String get liveMute => 'Выкл. звук';

  @override
  String get liveUnmute => 'Вкл. звук';

  @override
  String commonDurSeconds(int s) {
    return '$s с';
  }

  @override
  String commonDurMinutes(int m) {
    return '$m мин';
  }

  @override
  String commonDurHours(int h) {
    return '$h ч';
  }

  @override
  String commonDurHoursMinutes(int h, int m) {
    return '$h ч $m мин';
  }

  @override
  String practiceGradeInterval(String label, int days) {
    return '$label · $days дн.';
  }
}
