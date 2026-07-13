// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get navHome => '首页';

  @override
  String get navLibrary => '资料库';

  @override
  String get navLeagues => '联赛';

  @override
  String get navQuests => '任务';

  @override
  String get navProfile => '个人资料';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSectionLearning => '学习';

  @override
  String get settingsSectionSubscription => '订阅';

  @override
  String get settingsSectionAccessibility => '无障碍';

  @override
  String get settingsSectionNotifications => '通知';

  @override
  String get settingsSectionAppearanceAccount => '外观与账户';

  @override
  String get settingsAppLanguage => '应用语言';

  @override
  String get settingsAppLanguageSystem => '跟随系统';

  @override
  String get homeCourseLoadingTitle => '你的课程正在准备中';

  @override
  String get homeCourseLoadingBody => '课程内容加载后,课程将显示在这里。';

  @override
  String get homeGuideChip => '指南';

  @override
  String get homeStartNode => '开始';

  @override
  String get homeUnitGuideHeader => '单元指南';

  @override
  String get commonDone => '完成';

  @override
  String homeUnitKicker(String unit) {
    return '单元 · $unit';
  }

  @override
  String homeLessonMeta(int num, int count, String exercises) {
    return '第 $num 课,共 $count 课 · $exercises。';
  }

  @override
  String homeQuickExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个快速练习',
    );
    return '$_temp0';
  }

  @override
  String get homeEnergyChip => '−1 ⚡ 能量';

  @override
  String get homeXpChip => '+20 XP';

  @override
  String get homeStartLesson => '开始课程';

  @override
  String get homeTutorChip => '导师';

  @override
  String get libraryAiTutor => 'AI 导师';

  @override
  String get libraryAiTutorSub => '对话、聊天与角色扮演 — 写作反馈';

  @override
  String get libraryRoleplay => '角色扮演';

  @override
  String get libraryRoleplaySub => '练习回答 — 有评分,永久免费';

  @override
  String get librarySectionPractice => '练习';

  @override
  String get libraryPracticeHub => '练习中心';

  @override
  String get libraryPracticeHubSub => '错题、薄弱词汇与训练 · 免费';

  @override
  String get librarySectionReadListen => '读与听';

  @override
  String get libraryGradedStories => '分级故事';

  @override
  String get libraryPodcasts => '播客';

  @override
  String get libraryWatch => '观看';

  @override
  String get librarySearchHint => '搜索课程、单词、故事…';

  @override
  String get libraryFeaturedStory => '精选 · 故事';

  @override
  String commonLevel(String cefr) {
    return '$cefr 级';
  }

  @override
  String get libraryReadNow => '立即阅读';

  @override
  String get libraryNewExplore => '新 · 探索';

  @override
  String get libraryAdventures => '冒险';

  @override
  String get libraryStartExploring => '开始探索 →';

  @override
  String get libraryKindStory => '故事';

  @override
  String get libraryKindPodcast => '播客';

  @override
  String get libraryKindVideo => '视频';

  @override
  String get libraryAllStories => '全部故事';

  @override
  String get libraryAllPodcasts => '全部播客';

  @override
  String get libraryAllVideos => '全部视频';

  @override
  String get lessonTypeWhatYouHear => '输入你听到的内容';

  @override
  String get lessonTapWhatYouHear => '点选你听到的内容';

  @override
  String get lessonTranslateSentence => '翻译这个句子';

  @override
  String get lessonExplainThis => '💡 Explain this';

  @override
  String get lessonMatchPairs => 'Match the pairs';

  @override
  String get lessonTypeAnswerHint => '输入你的答案…';

  @override
  String get lessonWriteAnswerHint => '写下你的答案…';

  @override
  String get lessonContinue => '继续';

  @override
  String get lessonSkip => '跳过';

  @override
  String get lessonCheck => '检查';

  @override
  String get lessonNicelyDone => '✓ 做得好!';

  @override
  String get lessonNotQuite => '✕ 不太对';

  @override
  String lessonAnswerReveal(String answer) {
    return '答案:$answer';
  }

  @override
  String get lessonCompleteKicker => '课程完成';

  @override
  String get lessonCompleteTitle => '课程完成!';

  @override
  String lessonCompleteSummary(int correct, int graded, String level) {
    return '共 $graded 题,答对 $correct 题 · 现在是 $level';
  }

  @override
  String get lessonStatTotalXp => '总 XP';

  @override
  String get lessonStatAccuracy => '准确率';

  @override
  String get lessonStatTime => '用时';

  @override
  String get onboardingWelcomeTitle => '你好,我是 Ratel!';

  @override
  String get onboardingWelcomeBody => '无所畏惧地学语言——小步快跑、有趣、免费。准备好了吗?';

  @override
  String get onboardingHaveAccount => '我已有账户';

  @override
  String get onboardingTryWithoutAccount => '先不注册,试一试 →';

  @override
  String get onboardingGetStarted => '开始';

  @override
  String get onboardingStartLearning => '开始学习';

  @override
  String get onboardingLanguageTitle => '你想学什么?';

  @override
  String get onboardingLanguageSubtitle => '用 10 种语言学习英语';

  @override
  String get onboardingReasonTitle => '你为什么学习?';

  @override
  String get onboardingGoalTitle => '选择每日目标';

  @override
  String get onboardingPlacementTitle => '找到你的起点';

  @override
  String onboardingPlacementBody(String language) {
    return '刚接触$language,还是已经会一些?';
  }

  @override
  String get onboardingBrandNew => '我是零基础';

  @override
  String get onboardingBrandNewSub => '从最开始学起';

  @override
  String get onboardingPlacementTest => '参加定级测试';

  @override
  String get onboardingPlacementTestSub => '约 3 分钟 · 直达你的水平';

  @override
  String onboardingXpPerDay(int xp) {
    return '$xp XP / 天';
  }

  @override
  String get reasonTravel => '旅行';

  @override
  String get reasonCulture => '文化';

  @override
  String get reasonCareer => '职业';

  @override
  String get reasonFamilyFriends => '家人和朋友';

  @override
  String get reasonBrainTraining => '大脑训练';

  @override
  String get reasonJustForFun => '纯属娱乐';

  @override
  String get goalCasual => '轻松';

  @override
  String get goalRegular => '常规';

  @override
  String get goalSerious => '认真';

  @override
  String get goalIntense => '高强度';

  @override
  String get langNameEnglish => '英语';

  @override
  String get langNameSpanish => '西班牙语';

  @override
  String get langNameFrench => '法语';

  @override
  String get langNameJapanese => '日语';

  @override
  String get langNameTamil => '泰米尔语';

  @override
  String get langNameGerman => '德语';

  @override
  String get langNameKorean => '韩语';

  @override
  String get settingsDailyGoal => '每日目标';

  @override
  String settingsGoalRow(String label, int xp) {
    return '$label · 每天 $xp XP';
  }

  @override
  String get profileAchievements => '成就';

  @override
  String get profileFriends => '好友';

  @override
  String get profileShop => '商店';

  @override
  String get profileNotifications => '通知';

  @override
  String get profileSeeOnboarding => '查看新手引导 ↗';

  @override
  String get profileNotSignedIn => '未登录';

  @override
  String get profileCreateAccount => '创建免费账户';

  @override
  String get profileSaveProgress => '在所有设备上保存你的进度';

  @override
  String profileTodaysGoal(int today, int goal) {
    return '今日目标 · $today/$goal XP';
  }

  @override
  String get profileViewProgress => '查看进度 →';

  @override
  String get profileUnlocked => '已解锁';

  @override
  String questsResetsIn(int h, int m) {
    return '$h 小时 $m 分钟后重置';
  }

  @override
  String get questsDailyRefresh => '每日刷新';

  @override
  String get questsFreshMix => '全新 5 题混合练习';

  @override
  String get questsServedFromQueue => '来自你真实的复习队列 — 获得真实 XP。';

  @override
  String get questsGoalReached => '已达成每日目标!🎉';

  @override
  String questsReachGoal(int goal) {
    return '今天获得 $goal XP';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return '每日任务 · $done/$total';
  }

  @override
  String get questsInfoNote =>
      '任务追踪你真实的每日进度。奖励宝箱、好友任务和每周排行榜需要后端经济系统 — 由所有者决定(§6)。不展示虚假奖励。';

  @override
  String get questsStartRefresh => '开始每日刷新';

  @override
  String get questsStart => '开始';

  @override
  String get questsPractisedToday => '今天已练习 — 连胜安全';

  @override
  String get questsEarnAnyXp => '今天获得任意 XP';

  @override
  String questsXpToday(int current, int target) {
    return '今天 $current/$target XP';
  }

  @override
  String get leaguesYourGroup => '你的小组';

  @override
  String leaguesThisWeek(int size) {
    return '本周 · $size 名学习者';
  }

  @override
  String get leaguesTiers => '联赛等级';

  @override
  String leaguesTopClimb(int top, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天',
    );
    return '每周前 $top 名晋级 · $_temp0后结束';
  }

  @override
  String get leaguesDemotionZone => '降级区';

  @override
  String get leaguesPromotionZone => '晋级区';

  @override
  String get leaguesSafeZone => '安全区';

  @override
  String get leaguesYou => '你';

  @override
  String leaguesPromoteRelegate(int top, int bottom) {
    return '周末时前 $top 名晋级 · 后 $bottom 名降级。';
  }

  @override
  String get leaguesYouAreHere => '你在这里';

  @override
  String get leaguesViewAllTiers => '🏆 查看全部 10 个等级 ›';

  @override
  String get notifMarkAllRead => '全部标为已读';

  @override
  String get notifEmptyTitle => '暂无通知';

  @override
  String get notifEmptyBody => '完成课程、保持连胜、提升等级 — 你的里程碑会在真正达成的那一刻出现在这里。';

  @override
  String get notifPushNote =>
      '这些是应用内里程碑,在你达成时立即显示。推送通知和提醒由所有者决定,尚未启用 — 这里没有任何虚假内容。';

  @override
  String get shopPowerUps => '强化道具';

  @override
  String get shopStreakFreeze => '连胜冻结';

  @override
  String get shopStreakFreezeDesc => '漏学一天也能保住连胜。错过每日目标时自动消耗。';

  @override
  String shopOwned(int have, int max) {
    return '已拥有 $have/$max';
  }

  @override
  String get shopMaxedOut => '已达上限';

  @override
  String shopBuyFor(int cost) {
    return '花 $cost 💎 购买';
  }

  @override
  String get shopFreezeAdded => '已添加连胜冻结 💪';

  @override
  String shopFreezeAtCap(int max) {
    return '你已持有最多的冻结($max)。';
  }

  @override
  String shopNotEnoughEarnCost(int cost) {
    return '💎 不足 — 完成课程赚取 $cost。';
  }

  @override
  String get shopNotEnoughEarnMore => '💎 不足 — 完成课程赚取更多。';

  @override
  String get shopEnergyRefill => '能量补充';

  @override
  String get shopEnergyRefillDesc => '立即把能量补满。能量仅作展示 — 课程永不受阻。';

  @override
  String get shopAlreadyFull => '已满';

  @override
  String get shopEnergyRefilled => '能量已补满 ⚡';

  @override
  String get shopEnergyAlreadyFull => '你的能量已经满了。';

  @override
  String get shopStreakRepair => '连胜修复';

  @override
  String get shopStreakRepairDesc => '丢了连胜?恢复到之前的长度,继续前进。';

  @override
  String get shopStreakLapsed => '连胜已中断';

  @override
  String shopStreakDays(int days) {
    return '🔥 $days 天连胜';
  }

  @override
  String shopRepairFor(int cost) {
    return '花 $cost 💎 修复';
  }

  @override
  String get shopStreakRestored => '连胜已恢复 🔥';

  @override
  String get shopStreakSafe => '你的连胜安然无恙 — 现在无需修复。';

  @override
  String get shopDoubleXp => '双倍 XP';

  @override
  String get shopDoubleXpDesc => '15 分钟内每节课获得 2× XP。';

  @override
  String shopActiveLeft(int minutes) {
    return '生效中 · 剩余 $minutes 分钟';
  }

  @override
  String get shopInactive => '未激活';

  @override
  String get shopActive => '生效中';

  @override
  String get shopDoubleXpActive => '双倍 XP 已激活 ✨';

  @override
  String get shopBoostRunning => '你的加成正在生效 — XP 翻倍中。';

  @override
  String get shopBadgerOutfits => '獾的服装';

  @override
  String get paywallTitle => 'RATEL PRO';

  @override
  String get paywallStartTrial => '开始 7 天免费试用';

  @override
  String paywallGoPro(String price) {
    return '升级 Pro — $price/月';
  }

  @override
  String get paywallRestore => '恢复购买';

  @override
  String get paywallHero => '实时 AI 辅导、无广告、离线课程。';

  @override
  String get paywallAnnual => '按年';

  @override
  String get paywallMonthly => '按月';

  @override
  String get paywallTrialHow => '7 天免费试用如何运作';

  @override
  String get paywallTrialToday => '今天';

  @override
  String get paywallTrialTodayDesc => '解锁全部 Pro 权益。不收费。';

  @override
  String get paywallTrialDay5 => '第 5 天';

  @override
  String get paywallTrialDay5Desc => '试用结束前我们会提醒你。';

  @override
  String get paywallTrialDay7 => '第 7 天';

  @override
  String paywallTrialDay7Desc(String price) {
    return '若未取消,将开始按 $price/年收费。';
  }

  @override
  String get paywallFeatureLiveAi => '实时 AI:语音、导师聊天与写作反馈';

  @override
  String get paywallFeatureNoAds => '任何地方都无广告';

  @override
  String get paywallFeatureOffline => '离线课程与音频';

  @override
  String get paywallFeaturePronunciation => 'AI 发音指导建议';

  @override
  String get paywallEverythingFree => '其余一切 — 音频、复习、联赛、角色扮演和设备端发音 — 对所有人永久免费。';

  @override
  String get paywallYouArePro => '你已是 RATEL PRO';

  @override
  String get paywallThanks => '感谢支持 Ratel。可随时在 设置 → 管理订阅 中管理或取消。';

  @override
  String get paywallManage => '管理订阅';

  @override
  String paywallFinePrint(String regions) {
    return '可随时在设置中取消。所示价格适用于 $regions;你的本地价格由应用商店决定。';
  }

  @override
  String get questTitlePowerSession => '高能时段';

  @override
  String get questDescPowerSession => '赚取每日目标的两倍';

  @override
  String get questTitleOnFire => '火力全开';

  @override
  String get questDescOnFire => '赚取每日目标的三倍';

  @override
  String get questTitleStreakKeeper => '连胜守护';

  @override
  String get questDescStreakKeeper => '今天练习，保持连胜';

  @override
  String get notifTitleLessons1 => '完成第一课';

  @override
  String get notifBodyLessons1 => '你完成了第一节课 — 好的开始！';

  @override
  String get notifTitleLessons5 => '完成 5 节课';

  @override
  String get notifBodyLessons5 => '你已完成 5 节课。保持势头。';

  @override
  String get notifTitleLessons10 => '完成 10 节课';

  @override
  String get notifBodyLessons10 => '十节课了 — 你正在养成真正的习惯。';

  @override
  String get notifTitleLessons25 => '完成 25 节课';

  @override
  String get notifBodyLessons25 => '完成二十五节课。令人钦佩的坚持！';

  @override
  String get notifTitleLessons50 => '完成 50 节课';

  @override
  String get notifBodyLessons50 => '五十节课 — 你已走上正轨。';

  @override
  String get notifTitleStreak3 => '连胜 3 天！';

  @override
  String get notifBodyStreak3 => '连续三天。贵在坚持。';

  @override
  String get notifTitleStreak7 => '连胜 7 天！';

  @override
  String get notifBodyStreak7 => '整整一周每天练习。出色！';

  @override
  String get notifTitleStreak14 => '连胜 14 天！';

  @override
  String get notifBodyStreak14 => '连续两周 — 势不可挡。';

  @override
  String get notifTitleStreak30 => '连胜 30 天！';

  @override
  String get notifBodyStreak30 => '整整一个月每天练习。难以置信。';

  @override
  String get notifTitleXp100 => '获得 100 XP';

  @override
  String get notifBodyXp100 => '你的第一个一百 XP — 势头正起。';

  @override
  String get notifTitleXp500 => '获得 500 XP';

  @override
  String get notifBodyXp500 => '五百 XP。你在认真投入。';

  @override
  String get notifTitleXp1000 => '获得 1,000 XP';

  @override
  String get notifBodyXp1000 => '达成一千 XP 里程碑！';

  @override
  String get notifTitleXp2500 => '获得 2,500 XP';

  @override
  String get notifBodyXp2500 => '两千五百 XP — 进步显著。';

  @override
  String get notifTitleLevel1 => '达到 A2 级';

  @override
  String get notifBodyLevel1 => '你的能力从 A1 升到 A2。继续前进！';

  @override
  String get notifTitleLevel2 => '达到 B1 级';

  @override
  String get notifBodyLevel2 => '你已是中级学习者（B1）。';

  @override
  String get notifTitleLevel3 => '达到 B2 级';

  @override
  String get notifBodyLevel3 => '达到中高级（B2）。出色。';

  @override
  String get notifTitleLevel4 => '达到 C1 级';

  @override
  String get notifBodyLevel4 => '高级（C1）— 你的英语很扎实。';

  @override
  String get notifTitleLevel5 => '达到 C2 级';

  @override
  String get notifBodyLevel5 => '精通（C2）— 到达顶峰！';

  @override
  String get achTitleFirstSteps => '最初的脚步';

  @override
  String get achTitleScholar => '学者';

  @override
  String get achTitleWildfire => '燎原之火';

  @override
  String get achTitlePointMaker => '得分手';

  @override
  String get achTitleCollector => '收藏家';

  @override
  String get achTitleRisingStar => '新星';

  @override
  String get leagueTierBronze => '青铜';

  @override
  String get leagueTierSilver => '白银';

  @override
  String get leagueTierGold => '黄金';

  @override
  String get leagueTierSapphire => '蓝宝石';

  @override
  String get leagueTierRuby => '红宝石';

  @override
  String get leagueTierEmerald => '翡翠';

  @override
  String get leagueTierAmethyst => '紫水晶';

  @override
  String get leagueTierPearl => '珍珠';

  @override
  String get leagueTierObsidian => '黑曜石';

  @override
  String get leagueTierDiamond => '钻石';

  @override
  String get cefrNameBeginner => '入门';

  @override
  String get cefrNameElementary => '初级';

  @override
  String get cefrNameIntermediate => '中级';

  @override
  String get cefrNameUpperIntermediate => '中高级';

  @override
  String get cefrNameAdvanced => '高级';

  @override
  String get cefrNameProficient => '精通';

  @override
  String leaguesTierLeague(String tier) {
    return '$tier联赛';
  }

  @override
  String leaguesYoureIn(String tier) {
    return '你在$tier · 每周前 7 名晋级';
  }

  @override
  String get leaguesZonePromotion => '⬆ 晋级区';

  @override
  String get leaguesZoneDemotion => '⬇ 降级区';

  @override
  String profileAchievementsSummary(int unlocked, int total) {
    return '已解锁 $unlocked/$total · 真实进度';
  }

  @override
  String get profileRealStateNote => '等级、XP、课程、连胜和收藏的单词都是真实的引擎状态 — 新账户从零开始。';

  @override
  String get practiceTitle => '练习';

  @override
  String practiceReviewWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '复习 $count 个单词',
    );
    return '$_temp0';
  }

  @override
  String get practiceYourWords => '你的单词';

  @override
  String practiceSavedWordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已收藏 $count 个单词',
    );
    return '$_temp0';
  }

  @override
  String practiceDueForReview(int count) {
    return '$count 个待间隔复习';
  }

  @override
  String get practiceAllUpToDate => '所有复习都已完成';

  @override
  String practiceCaughtUp(String tail) {
    return '全部完成 — 目前没有待复习$tail。';
  }

  @override
  String practiceNextTail(String when) {
    return ' · 下次 $when';
  }

  @override
  String get practiceZeroDue => '0 待复习';

  @override
  String get practiceDueNow => '现在到期';

  @override
  String practiceDueWhen(String when) {
    return '到期：$when';
  }

  @override
  String get practiceChipDue => '到期';

  @override
  String get practiceChipScheduled => '已安排';

  @override
  String get practiceScheduleNote =>
      '复习由真实的 FSRS-6 间隔重复引擎安排。到期日期在本次会话内有效；跨重启保存是上线步骤 — 这里没有任何虚构。';

  @override
  String get practiceNoSavedWords => '还没有收藏的单词';

  @override
  String get practiceSaveWordHint =>
      '在练习课程时收藏一个单词，它会以闪卡形式出现在这里。之后由真实的 FSRS 间隔重复引擎安排复习 — 没有任何预填内容。';

  @override
  String get practiceStartLesson => '开始一节课';

  @override
  String practiceWordOf(int n, int total) {
    return '第 $n/$total 个单词';
  }

  @override
  String get practiceShowAnswer => '显示答案';

  @override
  String get practiceRecallHint => '回想词义，然后评价你记得如何。';

  @override
  String get practiceGradeAgain => '重来';

  @override
  String get practiceGradeHard => '困难';

  @override
  String get practiceGradeGood => '良好';

  @override
  String get practiceGradeEasy => '简单';

  @override
  String get practiceFsrsGradeNote => 'FSRS-6 根据你的评分安排下次复习';

  @override
  String get practiceReviewComplete => '复习完成';

  @override
  String practiceReviewedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '你复习了 $count 个单词。FSRS 已重新安排它们。',
    );
    return '$_temp0';
  }

  @override
  String get practiceDone => '完成';

  @override
  String get practiceRelTomorrow => '明天';

  @override
  String practiceRelInDays(int days) {
    return '$days 天后';
  }

  @override
  String practiceRelInHours(int hours) {
    return '$hours 小时后';
  }

  @override
  String practiceRelInMinutes(int minutes) {
    return '$minutes 分钟后';
  }

  @override
  String get practiceRelSoon => '很快';

  @override
  String get progressTitle => '进度';

  @override
  String get progressShareMilestone => '分享里程碑';

  @override
  String get progressLast7Days => '最近 7 天';

  @override
  String get progressAccuracyRetention => '准确率与记忆保持';

  @override
  String get progressHonestyNote =>
      '这里的一切都是真实记录的状态 — 等级、能力、收藏的单词、XP、课程、连胜、7 天历史、准确率和学习时间都从零开始，随学习增长。记忆保持是本次会话的预测回忆（跨会话调度器属于上线工作）；没有任何虚构。';

  @override
  String progressShareText(
    String level,
    String levelName,
    int streak,
    int xp,
    int lessons,
  ) {
    return '🦡 RATEL · 等级 $level（$levelName）\n🔥 连胜 $streak 天 · ⚡ $xp XP · 📘 $lessons 节课\n在 learnwithratel.com 学习中';
  }

  @override
  String get progressShareCopied => '里程碑已复制到剪贴板 — 随处分享！';

  @override
  String progressAbilityLine(String theta) {
    return '能力 θ $theta · 真实估计';
  }

  @override
  String get progressStatSavedWords => '收藏单词';

  @override
  String get progressStatLessons => '课程';

  @override
  String get progressStatDayStreak => '连胜天数';

  @override
  String get progressStatTotalXp => '总 XP';

  @override
  String get progressStatTodaysXp => '今日 XP';

  @override
  String get progressStatCefrLevel => 'CEFR 等级';

  @override
  String get progressAccuracy => '准确率';

  @override
  String get progressStudyTime => '学习时间';

  @override
  String get progressRetention => '记忆保持';

  @override
  String get progressNoData => '暂无数据';

  @override
  String get progressAccuracyEmpty => '完成计分练习后开始统计';

  @override
  String progressAccuracyDetail(int correct, int total) {
    return '$total 题中 $correct 题正确';
  }

  @override
  String get progressTimeEmpty => '课程时间会累计在这里';

  @override
  String get progressTimeDetail => '来自你的所有课程';

  @override
  String get progressRetentionEmpty => '复习后可查看预测回忆';

  @override
  String progressRetentionDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '预测 1 天回忆 · 本次会话 $count 项',
    );
    return '$_temp0';
  }

  @override
  String progressWeekTotal(int xp) {
    return '$xp XP · 最近 7 天';
  }

  @override
  String get progressNoXpYet => '尚未记录 XP';

  @override
  String get progressChartEmptyNote => '完成一节课即可开始 7 天历史 — 未活跃的日子保持为零，没有任何虚构。';

  @override
  String get commonDowMon => '一';

  @override
  String get commonDowTue => '二';

  @override
  String get commonDowWed => '三';

  @override
  String get commonDowThu => '四';

  @override
  String get commonDowFri => '五';

  @override
  String get commonDowSat => '六';

  @override
  String get commonDowSun => '日';

  @override
  String get searchTitle => '搜索';

  @override
  String get searchHint => '搜索课程、单词、故事…';

  @override
  String get searchRecent => '最近';

  @override
  String get searchClear => '清除';

  @override
  String get searchJumpTo => '前往';

  @override
  String get searchTagPage => '页面';

  @override
  String get searchTagWord => '单词';

  @override
  String get searchSubtitleSavedWord => '收藏的单词';

  @override
  String searchLessonSubtitle(String unit) {
    return '$unit · 课程';
  }

  @override
  String searchNoMatches(String query) {
    return '没有与“$query”匹配的结果';
  }

  @override
  String get searchEmptyNote =>
      '在你的课程、收藏单词和页面的标题、标签与课程内容中搜索。服务器内容索引和热门趋势是 R-L12 的后续跟进 — 这里没有任何虚假内容。';

  @override
  String get searchNoMatchNote =>
      '搜索你已发布的课程、收藏的单词和应用页面（标题 + 标签）。故事/播客和全文搜索是 R-L12 的后续跟进 — 绝不造假。';

  @override
  String get searchFooterNote =>
      '上线时支持标题 + 标签。全文、故事/播客和多课程范围是 R-L12 的后续跟进 — 绝不造假。';

  @override
  String get searchDestPracticeHub => '练习中心';

  @override
  String get searchDestPracticeHubSub => '错题、薄弱单词与训练';

  @override
  String get searchDestAiTutor => 'AI 导师';

  @override
  String get searchDestAiTutorSub => '对话、聊天与角色扮演';

  @override
  String get searchDestAdventures => '冒险';

  @override
  String get searchDestAdventuresSub => '真实对话 — 免费';

  @override
  String get searchDestLeagues => '联赛';

  @override
  String get searchDestLeaguesSub => '你的每周联赛';

  @override
  String get searchDestQuests => '任务';

  @override
  String get searchDestQuestsSub => '每日目标与任务';

  @override
  String get searchDestProgress => '进度';

  @override
  String get searchDestProgressSub => '你的统计与连胜';

  @override
  String get searchDestProfile => '个人资料';

  @override
  String get searchDestProfileSub => '你的个人资料';

  @override
  String get searchDestSettings => '设置';

  @override
  String get searchDestSettingsSub => '账户与偏好';

  @override
  String get searchDestShop => '商店';

  @override
  String get searchDestShopSub => '使用你的钻石';

  @override
  String get searchDestNotifications => '通知';

  @override
  String get searchDestNotificationsSub => '你的里程碑收件箱';

  @override
  String get themesTitle => '主题';

  @override
  String get themesSubtitle => '改变整个应用的风格 — 点按即可实时预览';

  @override
  String themesVehicle(String vehicle) {
    return '载具 · $vehicle';
  }

  @override
  String get tutorHeader => '练习真实对话';

  @override
  String get tutorHeaderSub => '选择场景并与 Ratel 聊天 — 没有错误答案，只有练习。';

  @override
  String get tutorTalkTitle => '与 Ratel 通话';

  @override
  String get tutorTalkSub => '实时语音和视频口语练习';

  @override
  String get tutorChatTitle => '与 Ratel 聊天';

  @override
  String get tutorChatSub => 'AI 聊天 · 写作反馈';

  @override
  String get tutorRoleplayTitle => '角色扮演场景';

  @override
  String get tutorRoleplayGuided => '有引导的角色扮演对话';

  @override
  String tutorScenesCount(int count) {
    return '$count 个场景';
  }

  @override
  String get tutorUnlockPro => '解锁 RATEL PRO';

  @override
  String get tutorRelayNote =>
      '实时 AI 辅导运行在有内容审核、成本受控的中继上，是 RATEL PRO 功能。回复绝不模拟 — 只有 PRO 和中继都激活后模式才会启动。';

  @override
  String get tutorStatusReadyPro => 'PRO 已激活且实时导师已连接 — 选择一个模式开始。';

  @override
  String get tutorStatusReadyFree => '实时导师已连接。实时辅导是 RATEL PRO 功能。';

  @override
  String get tutorStatusOffline => '此版本尚未连接经审核的实时导师 — 实时辅导将在后续步骤开启。下方内容均非模拟。';

  @override
  String get tutorAnnounceNeedsPro => 'RATEL PRO 解锁实时 AI 辅导。';

  @override
  String get tutorAnnounceNeedsRelay => '启用经审核的中继后，AI 辅导即可连接。';

  @override
  String get tutorAnnounceStarting => '正在开始你的会话…';

  @override
  String get adventuresTitle => '冒险';

  @override
  String get adventuresFreeChip => '免费';

  @override
  String get adventuresHeaderSub => '探索世界 · 用对话闯关';

  @override
  String get adventuresHeroTitle => '选个地方，开始吧';

  @override
  String get adventuresHeroSub => '每个场景都是真实对话 — 没有错误答案，而且永远免费。';

  @override
  String get adventuresFallbackWorld => '冒险';

  @override
  String adventureSheetKicker(String cefr) {
    return '🗺️ 冒险 · $cefr';
  }

  @override
  String adventureScenesCount(int count) {
    return '$count 个场景';
  }

  @override
  String adventureChoicePoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个决策点',
    );
    return '$_temp0';
  }

  @override
  String get adventureOpeningScene => '开场场景';

  @override
  String get adventureStart => '开始冒险';

  @override
  String get adventurePlayerFallbackTitle => '冒险';

  @override
  String get adventureTheEnd => '🏁 完';

  @override
  String get adventureStartOver => '重新开始';

  @override
  String get adventureDone => '完成';

  @override
  String get adventureCompleteKicker => '冒险完成';

  @override
  String adventureCompleteTitle(String title) {
    return '$title ✓';
  }

  @override
  String get adventureCompleteBody => '做得好！获得 +15 XP · +5 💎 — 随时探索下一个场景。';

  @override
  String adventureDistrictProgress(int done, int total) {
    return '已探索 $done/$total';
  }

  @override
  String get adventureDistrictDone => '✓ 完成';

  @override
  String get adventuresEmpty => '这个课程还没有冒险内容。';

  @override
  String get authWelcomeTitle => '欢迎来到 Ratel';

  @override
  String get authWelcomeSubtitle => '课程、故事、播客等 —\n选择你的开始方式。';

  @override
  String get authCreateFreeAccount => '创建免费账户';

  @override
  String get authAlreadyHaveAccount => '我已有账户';

  @override
  String get authSettingUp => '正在准备…';

  @override
  String get authContinueAsGuest => '以访客身份继续';

  @override
  String get authGuestNote => '访客进度保存在本设备 — 随时可在设置中创建免费账户，让进度随身携带。';

  @override
  String get authEnterYourEmail => '请输入邮箱';

  @override
  String get authEnterValidEmail => '请输入有效邮箱';

  @override
  String get authEnterYourPassword => '请输入密码';

  @override
  String get authCouldNotSignIn => '无法登录。请重试。';

  @override
  String get authSomethingWentWrong => '出了点问题。请重试。';

  @override
  String get authSocialComingSoon => 'Google / Apple 登录即将推出。';

  @override
  String get authResetTitle => '重置密码';

  @override
  String get authWelcomeBack => '欢迎回来！';

  @override
  String get authResetSubtitle => '输入邮箱，我们会发送重置链接。';

  @override
  String get authPickUpWhereYouLeft => '从上次的地方继续';

  @override
  String get authEmailHint => '邮箱';

  @override
  String get authPasswordHint => '密码';

  @override
  String get authForgotPassword => '忘记密码？';

  @override
  String get authSendResetLink => '发送重置链接';

  @override
  String get authLogIn => '登录';

  @override
  String get authBackToLogIn => '返回登录';

  @override
  String get authNewToRatel => '第一次用 Ratel？';

  @override
  String get authSignUp => '注册';

  @override
  String get authCheckYourInbox => '查看你的收件箱';

  @override
  String authResetSent(String email) {
    return '我们已向 $email 发送密码重置链接。打开它来设置新密码。';
  }

  @override
  String get authCreatePassword => '创建密码';

  @override
  String get authAtLeast8Chars => '至少 8 个字符';

  @override
  String get authCreateYourAccount => '创建你的账户';

  @override
  String get authSignupSubtitle => '永久免费 · 用 10 种语言学习英语';

  @override
  String get authPassword8Hint => '密码（8 个字符以上）';

  @override
  String get authCreateAccount => '创建账户';

  @override
  String get authAlreadyAccountLead => '已有账户？';

  @override
  String get authSignIn => '登录';

  @override
  String get authConfirmEmail => '确认你的邮箱';

  @override
  String authConfirmSent(String email) {
    return '我们已向 $email 发送确认链接。点按以激活账户，然后回来登录。';
  }

  @override
  String get authContinueGoogle => '使用 Google 继续';

  @override
  String get authContinueApple => '使用 Apple 继续';

  @override
  String get authOr => '或';

  @override
  String get authUnavailableNote => '此版本暂不支持账户 — 你可以继续以访客身份学习。后端配置好后登录即会开启。';

  @override
  String get liveMute => '静音';

  @override
  String get liveUnmute => '取消静音';

  @override
  String commonDurSeconds(int s) {
    return '$s 秒';
  }

  @override
  String commonDurMinutes(int m) {
    return '$m 分钟';
  }

  @override
  String commonDurHours(int h) {
    return '$h 小时';
  }

  @override
  String commonDurHoursMinutes(int h, int m) {
    return '$h 小时 $m 分钟';
  }

  @override
  String practiceGradeInterval(String label, int days) {
    return '$label · $days 天';
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
