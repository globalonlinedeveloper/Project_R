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
  String homeSectionN(int n) {
    return 'БЛОК $n';
  }

  @override
  String homeSectionLevel(int n, String band) {
    return 'БЛОК $n · УРОВЕНЬ $band';
  }

  @override
  String homeLevelBand(String band) {
    return 'Уровень $band';
  }

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
  String get lessonExplainThis => '💡 Объяснить это';

  @override
  String get lessonMatchPairs => 'Найдите пары';

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
  String get onboardingLanguageSubtitle => 'Учите английский на 10 языках';

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
  String get langNameEnglish => 'Английский';

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
  String libraryEstMinutes(int n) {
    return '~$n min';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return 'Ежедневные задания · $done/$total';
  }

  @override
  String get questsInfoNote =>
      'Задания отслеживают ваш реальный ежедневный прогресс. Сундуки наград, задания с друзьями и недельный рейтинг требуют серверной экономики — решение владельца (§6). Фальшивые награды не показываются.';

  @override
  String get questsRewardPending => 'Rewards soon';

  @override
  String get questsFriendQuest => 'Friend quest';

  @override
  String get questsFriendQuestSoon => 'Friend quests need a social backend — coming soon. No fake partners are shown.';

  @override
  String questsFriendQuestOutearn(String handle, int gap) {
    return 'Out-earn @$handle · $gap XP to catch up this week';
  }

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
      'Всё остальное — аудио, повторение, лиги, ролевые сценки и произношение на устройстве — остаётся бесплатным для всех.';

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
  String get paywallRegionsTier1 => 'США, ЕС, Япония, Австралия';

  @override
  String get paywallRegionsMid =>
      'Латинская Америка, Юго-Восточная Азия, Восточная Европа';

  @override
  String get paywallRegionsLowPpp => 'Индия, Пакистан, Нигерия, Бангладеш';

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
  String get notifBodyLevel4 => 'Продвинутый (C1) — ваш английский силён.';

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
  String get progressYourLevel => 'YOUR LEVEL';

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
    int streak,
    int xp,
    int lessons,
  ) {
    return '🦡 RATEL\n🔥 Серия $streak дн. · ⚡ $xp XP · 📘 $lessons уроков\nУчусь на learnwithratel.com';
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
  String get adventuresHeaderSub => 'Исследуйте мир · говорите по-своему';

  @override
  String get adventuresHeroTitle => 'Выберите место и вперёд';

  @override
  String get adventuresHeroSub =>
      'Каждая сцена — настоящий разговор: без неправильных ответов и всегда бесплатно.';

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
  String adventureDistrictProgress(int done, int total) {
    return '$done/$total пройдено';
  }

  @override
  String get adventureDistrictDone => '✓ Готово';

  @override
  String get adventureDistrictCafe => 'Café & Food';

  @override
  String get adventureDistrictMarket => 'Market Square';

  @override
  String get adventureDistrictMove => 'On the Move';

  @override
  String get adventureDistrictFriends => 'Making Friends';

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
  String get authSignupSubtitle =>
      'Бесплатно навсегда · учите английский на 10 языках';

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

  @override
  String settingsGoalPerDay(int goal) {
    return '$goal XP в день';
  }

  @override
  String settingsGoalReachedSub(int goal) {
    return '$goal XP в день · ✓ достигнуто сегодня';
  }

  @override
  String get settingsSoundEffects => 'Звуковые эффекты';

  @override
  String get settingsHaptics => 'Вибрация';

  @override
  String get settingsProActive => 'RATEL PRO активен';

  @override
  String get settingsFreePlan => 'Бесплатный тариф';

  @override
  String get settingsReduceMotion => 'Уменьшить движение';

  @override
  String get settingsReduceMotionSub =>
      'Главный переключатель — отключает все анимации';

  @override
  String get settingsHighContrast => 'Высокая контрастность';

  @override
  String get settingsNotifPush => 'Пуш-уведомления';

  @override
  String get settingsNotifStreak => 'Напоминания о серии';

  @override
  String get settingsNotifLeague => 'Обновления лиги';

  @override
  String get settingsNotifFriend => 'Активность друзей';

  @override
  String get settingsNotifFootnote =>
      'Ваш выбор уже сохранён — доставка включится, когда появятся пуш-уведомления.';

  @override
  String get settingsCourse => 'Курс';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsWorld => 'Мир';

  @override
  String get settingsEditProfile => 'Редактировать профиль';

  @override
  String get settingsPrivacy => 'Конфиденциальность и данные';

  @override
  String get settingsHelp => 'Помощь и поддержка';

  @override
  String get settingsLogOut => 'Выйти';

  @override
  String get settingsGuestSub =>
      'Вы учитесь как гость — зарегистрируйтесь, чтобы сохранить прогресс';

  @override
  String settingsCouldNotOpen(String url) {
    return 'Не удалось открыть $url';
  }

  @override
  String get settingsThemeSystem => 'Как в системе';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get mediaReadAloud => 'Читать вслух';

  @override
  String get mediaTranscript => 'Расшифровка';

  @override
  String get mediaCheckUnderstanding => 'Проверить понимание';

  @override
  String mediaChecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count проверки понимания',
      many: '$count проверок понимания',
      few: '$count проверки понимания',
      one: '$count проверка понимания',
    );
    return '$_temp0';
  }

  @override
  String get mediaLoading => 'Загрузка…';

  @override
  String get mediaPause => 'Пауза';

  @override
  String get storiesTitle => 'Истории';

  @override
  String get storiesSub =>
      'Читайте и слушайте — адаптированные истории с чтением вслух в браузере.';

  @override
  String get storiesEmpty => 'В этом курсе пока нет историй.';

  @override
  String get storyFallbackTitle => 'История';

  @override
  String get podcastsSub =>
      'Слушайте — адаптированные подкасты с настоящим аудио и расшифровкой.';

  @override
  String get podcastsEmpty => 'В этом курсе пока нет подкастов.';

  @override
  String get podcastFallbackTitle => 'Подкаст';

  @override
  String get podcastPlayEpisode => 'Слушать эпизод';

  @override
  String get watchSub =>
      'Смотрите — короткие клипы с расшифровкой и проверкой понимания.';

  @override
  String get watchEmpty => 'В этом курсе пока нет уроков для просмотра.';

  @override
  String get watchWebOnly => 'Видео воспроизводится в веб-приложении';

  @override
  String get libraryAdventuresSub =>
      'Гуляйте по живому миру и говорите, проходя настоящие сцены.';

  @override
  String get roleplaySub =>
      'Отрабатывайте настоящие диалоги — выбирайте верный ответ и сразу получайте отклик.';

  @override
  String get roleplayEmpty => 'В этом курсе пока нет ролевых сцен.';

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
  String get roleplayYourReply => 'Ваш ответ:';

  @override
  String get roleplaySceneComplete => '🎉 Сцена пройдена!';

  @override
  String get roleplayBack => 'Назад к ролевым сценам';

  @override
  String get liveRoleplayTitle => 'Живая ролевая игра';

  @override
  String get liveRoleplayCardSub => 'Проговорите вслух с Ratel — живой голос';

  @override
  String get liveIntro =>
      'Проговорите вслух с Ratel — живая голосовая ролевая игра. Выберите сцену или просто побеседуйте.';

  @override
  String get liveFreeConversation => 'Свободная беседа';

  @override
  String get liveFreeConversationSub => 'Без сценария — просто говорите';

  @override
  String get liveRoleplayScene => 'Разыграть сцену';

  @override
  String get liveReconnecting => 'Переподключение…';

  @override
  String get liveConnectionLost => 'Связь потеряна — живая сессия прервалась.';

  @override
  String get liveReconnect => 'Переподключиться';

  @override
  String get liveConnecting => 'Подключение…';

  @override
  String get liveStartTalking => 'Начать говорить';

  @override
  String get liveSceneEndedNote =>
      'Сцена завершена. Начните заново, когда захотите — ваши живые минуты учтены и никогда не пропадают.';

  @override
  String get liveStartAgain => 'Начать заново';

  @override
  String get liveProGate =>
      'Живая голосовая ролевая игра — функция RATEL PRO: настоящий разговор, живой отклик, минуты под контролем затрат.';

  @override
  String get liveUnlockPro => 'Открыть RATEL PRO';

  @override
  String get liveNotEnabled =>
      'Живой голос в этой сборке ещё не включён — он заработает на следующем шаге. Здесь ничего не имитируется.';

  @override
  String get livePhaseIdle =>
      'Готовы, когда захотите — это настоящий живой звонок.';

  @override
  String get livePhaseListening => 'Слушаю — ваша очередь.';

  @override
  String get livePhaseSpeaking => 'Ratel говорит — вступайте в любой момент.';

  @override
  String get livePhaseClosed => 'Сцена завершена.';

  @override
  String get liveEndScene => 'Завершить сцену';

  @override
  String get liveYou => 'Вы';

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
  String get liveStartFailed =>
      'Не удалось начать живую сессию — попробуйте ещё раз.';

  @override
  String get friendsHandleInvalid =>
      'Введите имя вида @mia (2–20 букв, цифр, _).';

  @override
  String friendsAlreadyConnected(String handle) {
    return 'У вас уже есть связь с @$handle.';
  }

  @override
  String get friendsRequests => 'Заявки';

  @override
  String get friendsYourFriends => 'Ваши друзья';

  @override
  String get friendsPending => 'В ожидании';

  @override
  String get friendsActivity => 'Активность друзей';

  @override
  String get friendsFootnote =>
      'Ваш список друзей реален и виден только вам. Заявки в друзья будут доставляться, а «обошёл вас» появится, когда заработает устойчивый межпользовательский граф — это тот же этап запуска, что и у всех остальных устойчивых счётчиков. Здесь ничего не подделано.';

  @override
  String get friendsAddHint => 'Добавьте друга по @имени…';

  @override
  String get friendsAccept => 'Принять';

  @override
  String friendsXpThisWeek(String handle, String xp) {
    return '@$handle · $xp XP за эту неделю';
  }

  @override
  String get friendsPassedYou => 'Обошёл вас';

  @override
  String get friendsRemove => 'Удалить';

  @override
  String get friendsBlock => 'Заблокировать';

  @override
  String get friendsReportBlock => 'Пожаловаться и заблокировать';

  @override
  String get friendsRequestSent => 'Заявка отправлена';

  @override
  String get friendsEmptyTitle => 'Пока нет друзей';

  @override
  String get friendsEmptyBody =>
      'Добавьте кого-нибудь по @имени, чтобы начать делиться прогрессом.';

  @override
  String get profileLearner => 'Учащийся';

  @override
  String get profileGuest => 'Гость';

  @override
  String get editProfileSaved => 'Профиль сохранён';

  @override
  String get editProfileHandleSet => 'Сохранено — ваше @имя задано.';

  @override
  String get editProfileSignInForHandle =>
      'Имя сохранено. Войдите, чтобы закрепить своё @имя.';

  @override
  String get editProfileHandleFailed => 'Не удалось задать это @имя.';

  @override
  String get editProfileDisplayName => 'Отображаемое имя';

  @override
  String get editProfileNameHint => 'Как к вам обращаться?';

  @override
  String get editProfileNameNote =>
      'Показывается в вашем профиле. Сохраняется на этом устройстве — синхронизируется с аккаунтом, когда вы войдёте.';

  @override
  String get editProfileHandle => 'Ваше @имя';

  @override
  String get editProfileHandleNote =>
      'Другие учащиеся добавляют вас по @имени (2–20 букв, цифр или _). Чтобы закрепить его, нужно войти.';

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
  String get commonSave => 'Сохранить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get feedIsNowYourFriend => 'теперь ваш друг';

  @override
  String feedReachedLevel(String level) {
    return 'достиг $level';
  }

  @override
  String feedDayStreak(int count) {
    return 'серия $count дн.';
  }

  @override
  String get feedPassedYou => 'обошёл вас в вашей лиге';

  @override
  String get leaguesSoloCaption => 'эта неделя · группа из одного';

  @override
  String leaguesXpToRank(int xp, int rank) {
    return '$xp XP до места $rank';
  }

  @override
  String get leaguesLeading => 'лидируете в своей группе';

  @override
  String get leaguesSoloNote =>
      'На этой неделе вы единственный учащийся в своей группе. Настоящие соперники присоединятся по мере роста Ratel — без ботов и фальшивых рейтингов. Продолжайте копить XP, чтобы быть готовым подняться, когда неделя обновится.';

  @override
  String questsGoalLine(int today, int goal) {
    return '$today / $goal XP · цель достигнута';
  }

  @override
  String questsGoalRemaining(int today, int goal, int remaining) {
    return '$today / $goal XP · осталось $remaining XP';
  }

  @override
  String get worldLabelLight => 'Дневной свет';

  @override
  String get worldVehicleLight => 'Самокат';

  @override
  String get worldLabelGalaxy => 'Космос';

  @override
  String get worldVehicleGalaxy => 'Звёздная капсула';

  @override
  String get worldLabelSavanna => 'Саванна';

  @override
  String get worldVehicleSavanna => 'Джип для сафари';

  @override
  String get worldLabelOcean => 'Океан';

  @override
  String get worldVehicleOcean => 'Субмарина';

  @override
  String get worldLabelForest => 'Лес';

  @override
  String get worldVehicleForest => 'Планёр-листок';

  @override
  String get worldLabelCandy => 'Сладости';

  @override
  String get worldVehicleCandy => 'Воздушный шар';

  @override
  String get worldLabelNeon => 'Неоновый город';

  @override
  String get worldVehicleNeon => 'Ховербайк';

  @override
  String get worldLabelStorm => 'Ливень';

  @override
  String get worldVehicleStorm => 'Штормовой планёр';

  @override
  String get worldLabelSnow => 'Зима';

  @override
  String get worldVehicleSnow => 'Снежные санки';

  @override
  String get worldLabelSakura => 'Цветущая вишня';

  @override
  String get worldVehicleSakura => 'Воздушный змей из лепестков';

  @override
  String get worldLabelAutumn => 'Осень';

  @override
  String get worldVehicleAutumn => 'Тележка с листьями';

  @override
  String get worldLabelAurora => 'Сияние';

  @override
  String get worldVehicleAurora => 'Лодка полярного сияния';

  @override
  String get worldLabelVolcano => 'Вулкан';

  @override
  String get worldVehicleVolcano => 'Доска по магме';

  @override
  String get worldLabelSunset => 'Закат';

  @override
  String get worldVehicleSunset => 'Планёр';

  @override
  String get worldLabelDesert => 'Пустыня';

  @override
  String get worldVehicleDesert => 'Багги по дюнам';

  @override
  String get worldLabelReef => 'Коралловый риф';

  @override
  String get worldVehicleReef => 'Стеклянная лодка';

  @override
  String get worldLabelMeadow => 'Луг';

  @override
  String get worldVehicleMeadow => 'Велосипед';

  @override
  String get worldLabelDawn => 'Рассвет';

  @override
  String get worldVehicleDawn => 'Небесный шар';

  @override
  String get worldLabelBeach => 'Тропический пляж';

  @override
  String get worldVehicleBeach => 'Катамаран';

  @override
  String get worldLabelMars => 'Марс';

  @override
  String get worldVehicleMars => 'Марсоход';

  @override
  String get worldLabelJungle => 'Тропический лес';

  @override
  String get worldVehicleJungle => 'Зиплайн';

  @override
  String get worldLabelCyberrain => 'Кибердождь';

  @override
  String get worldVehicleCyberrain => 'Ховербайк';

  @override
  String get worldLabelAbyss => 'Глубоководье';

  @override
  String get worldVehicleAbyss => 'Батисфера';

  @override
  String get worldLabelAlpine => 'Альпы';

  @override
  String get worldVehicleAlpine => 'Канатная дорога';

  @override
  String get worldLabelLavender => 'Лаванда';

  @override
  String get worldVehicleLavender => 'Веспа';

  @override
  String get worldLabelBamboo => 'Бамбуковая роща';

  @override
  String get worldVehicleBamboo => 'Рикша';

  @override
  String get worldLabelLagoon => 'Ночная лагуна';

  @override
  String get worldVehicleLagoon => 'Каяк';

  @override
  String get worldLabelThunder => 'Грозовая туча';

  @override
  String get worldVehicleThunder => 'Охотник за грозой';

  @override
  String get worldLabelNebula => 'Туманность';

  @override
  String get worldVehicleNebula => 'Звёздный крейсер';

  @override
  String get worldLabelSandstorm => 'Песчаная буря';

  @override
  String get worldVehicleSandstorm => 'Караван';

  @override
  String get worldLabelCherrynight => 'Вишнёвая ночь';

  @override
  String get worldVehicleCherrynight => 'Бумажный фонарик';

  @override
  String get shopYourBadger => 'Ваш барсук';

  @override
  String get shopDiamondsNote =>
      'Скоро появится пополнение 💎 за реальные деньги. Алмазы зарабатываются за прохождение уроков и достижение дневной цели, и каждое усиление здесь тратит их по-настоящему — ничего не подделано.';

  @override
  String get shopProBannerSub =>
      'Живой ИИ, без рекламы, офлайн · 7 дней бесплатно';

  @override
  String get shopYourDiamonds => 'Ваши алмазы';

  @override
  String get shopEquipped => 'Надето';

  @override
  String get shopEquip => 'Надеть';

  @override
  String shopEquippedSnack(String name, String emoji) {
    return 'Надето: $name $emoji';
  }

  @override
  String get shopFree => 'Бесплатно';

  @override
  String get outfitClassic => 'Классический';

  @override
  String get outfitScholar => 'Учёный';

  @override
  String get outfitExplorer => 'Исследователь';

  @override
  String get outfitAstronaut => 'Космонавт';

  @override
  String get outfitWizard => 'Волшебник';

  @override
  String paywallAnnualLine(String annual, String perMonth) {
    return '$annual/год  ·  $perMonth/мес  ·  7 дней бесплатно';
  }

  @override
  String paywallMonthlyLine(String monthly) {
    return '$monthly/мес  ·  оплата помесячно';
  }

  @override
  String paywallSavePercent(int percent) {
    return 'ЭКОНОМИЯ $percent%';
  }

  @override
  String get paywallIncluded => 'Что входит в Pro';

  @override
  String get paywallTerms => 'Условия';

  @override
  String get paywallPrivacy => 'Конфиденциальность';

  @override
  String get paywallNothingToRestore =>
      'Восстанавливать нечего — оплата в этой сборке пока не подключена.';

  @override
  String get contentUnavailableTitle => 'Содержимое недоступно';

  @override
  String contentUnavailableBody(String noun) {
    return 'Этот $noun сейчас недоступен. Если вы офлайн, проверьте соединение и попробуйте ещё раз.';
  }

  @override
  String get contentNounStory => 'рассказ';

  @override
  String get contentNounPodcast => 'подкаст';

  @override
  String get contentNounVideo => 'видеоролик';

  @override
  String get contentNounAdventure => 'приключение';

  @override
  String get contentNounRoleplay => 'ролевой сюжет';

  @override
  String get commonGoBack => 'Назад';

  @override
  String get placementTitle => 'Тест на уровень';

  @override
  String placementQuestionN(int n) {
    return 'Вопрос $n';
  }

  @override
  String get placementResultTitle => 'Ваша отправная точка';

  @override
  String placementResultBody(int count, String level) {
    return 'На основе $count вопросов мы определили ваш уровень как $level. Вы всегда можете скорректировать его позже.';
  }

  @override
  String get lessonTypedNote => 'Введите ответ на изучаемом языке.';

  @override
  String lessonHintMinWords(int count) {
    return 'не менее $count слов';
  }

  @override
  String lessonHintUseWords(String words) {
    return 'используйте: $words';
  }

  @override
  String get lessonHintEndPunct => 'закончите на . ! или ?';

  @override
  String get lessonPlayAudio => 'Воспроизвести аудио';

  @override
  String get lessonPlaySlowly => 'Воспроизвести медленно';

  @override
  String get lessonAudioUnavailable => 'Аудио недоступно — прочитайте задание.';

  @override
  String get lessonPlaybackSpeed => 'Скорость воспроизведения';

  @override
  String get authAccountsUnavailable =>
      'Аккаунты пока не поддерживаются в этой сборке — продолжайте заниматься как гость.';

  @override
  String get liveNotEnabledShort => 'живой ИИ не включён в этой сборке.';

  @override
  String get liveMicUnavailable =>
      'микрофон недоступен — разрешите доступ к микрофону, чтобы говорить с репетитором.';

  @override
  String get liveUnavailable => 'живой ИИ сейчас недоступен.';

  @override
  String get liveNeedsPro => 'Живой ИИ доступен в RATEL PRO.';

  @override
  String get liveMinutesUsed => 'Лимит живых минут на этот месяц исчерпан.';

  @override
  String get commonNetworkError =>
      'Не удалось связаться с сервером. Попробуйте ещё раз.';

  @override
  String get friendsHandleTaken => 'Это @имя уже занято.';

  @override
  String get friendsHandleFormat =>
      'Используйте 2–20 букв, цифр или _ для своего @имени.';

  @override
  String get friendsSignInForHandle => 'Войдите, чтобы закрепить своё @имя.';

  @override
  String get friendsSetOwnHandleFirst =>
      'Сначала задайте своё @имя (Изменить профиль).';

  @override
  String get paywallCheckoutUnavailable =>
      'Оплата откроется при запуске — покупки в этой сборке пока не подключены.';

  @override
  String get settingsManageUnavailable =>
      'Управляйте подпиской или отмените её в настройках подписок вашего устройства — быстрый переход появится при запуске.';

  @override
  String get friendsAdd => 'Добавить';

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
  String get streakLongestLabel => 'Longest streak';

  @override
  String get streakLongestNone => 'No streak yet';

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
  String get coursesImmersionMode => 'Immersion mode';

  @override
  String get coursesImmersionSub =>
      'Learn with the app interface in the language you\'re studying.';

  @override
  String coursesImmersionUnsupported(String language) {
    return 'Immersion isn\'t available for $language yet — the app interface isn\'t translated into it.';
  }

  @override
  String coursesSwitchedTo(String language) {
    return 'Switched to $language';
  }

  @override
  String coursesXpTotal(int xp) {
    return '⚡ $xp XP';
  }

  @override
  String get coursesSearchHint => 'Search languages';

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
