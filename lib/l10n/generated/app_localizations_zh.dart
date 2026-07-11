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
  String get onboardingLanguageSubtitle => '提供 52 种语言';

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
  String get paywallEverythingFree =>
      '其余一切 — 全部 52 种语言、音频、复习、联赛、角色扮演和设备端发音 — 对所有人永久免费。';

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
}
