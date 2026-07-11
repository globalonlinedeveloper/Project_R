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
}
