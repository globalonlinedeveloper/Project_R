// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get navHome => 'ホーム';

  @override
  String get navLibrary => 'ライブラリ';

  @override
  String get navLeagues => 'リーグ';

  @override
  String get navQuests => 'クエスト';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSectionLearning => '学習';

  @override
  String get settingsSectionSubscription => 'サブスクリプション';

  @override
  String get settingsSectionAccessibility => 'アクセシビリティ';

  @override
  String get settingsSectionNotifications => '通知';

  @override
  String get settingsSectionAppearanceAccount => '外観とアカウント';

  @override
  String get settingsAppLanguage => 'アプリの言語';

  @override
  String get settingsAppLanguageSystem => 'システムのデフォルト';

  @override
  String get homeCourseLoadingTitle => 'コースを準備しています';

  @override
  String get homeCourseLoadingBody => 'コースのコンテンツが読み込まれると、ここにレッスンが表示されます。';

  @override
  String get homeGuideChip => 'ガイド';

  @override
  String get homeStartNode => 'スタート';

  @override
  String get homeUnitGuideHeader => 'ユニットガイド';

  @override
  String get commonDone => '完了';

  @override
  String homeUnitKicker(String unit) {
    return 'ユニット · $unit';
  }

  @override
  String homeLessonMeta(int num, int count, String exercises) {
    return 'レッスン $num / $count · $exercises。';
  }

  @override
  String homeQuickExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'クイック練習 $count問',
    );
    return '$_temp0';
  }

  @override
  String get homeEnergyChip => '−1 ⚡ エネルギー';

  @override
  String get homeXpChip => '+20 XP';

  @override
  String get homeStartLesson => 'レッスンを始める';

  @override
  String get homeTutorChip => 'チューター';

  @override
  String get libraryAiTutor => 'AIチューター';

  @override
  String get libraryAiTutorSub => '話す・チャット・ロールプレイ — 作文フィードバック';

  @override
  String get libraryRoleplay => 'ロールプレイ';

  @override
  String get libraryRoleplaySub => '返答の練習 — 採点つき、いつでも無料';

  @override
  String get librarySectionPractice => '練習';

  @override
  String get libraryPracticeHub => '練習ハブ';

  @override
  String get libraryPracticeHubSub => 'ミス・苦手な単語・ドリル · 無料';

  @override
  String get librarySectionReadListen => '読む・聞く';

  @override
  String get libraryGradedStories => 'レベル別ストーリー';

  @override
  String get libraryPodcasts => 'ポッドキャスト';

  @override
  String get libraryWatch => '動画';

  @override
  String get librarySearchHint => 'レッスン・単語・ストーリーを検索…';

  @override
  String get libraryFeaturedStory => '注目 · ストーリー';

  @override
  String commonLevel(String cefr) {
    return 'レベル $cefr';
  }

  @override
  String get libraryReadNow => '今すぐ読む';

  @override
  String get libraryNewExplore => '新着 · 探検';

  @override
  String get libraryAdventures => 'アドベンチャー';

  @override
  String get libraryStartExploring => '探検を始める →';

  @override
  String get libraryKindStory => 'ストーリー';

  @override
  String get libraryKindPodcast => 'ポッドキャスト';

  @override
  String get libraryKindVideo => '動画';

  @override
  String get libraryAllStories => 'すべてのストーリー';

  @override
  String get libraryAllPodcasts => 'すべてのポッドキャスト';

  @override
  String get libraryAllVideos => 'すべての動画';

  @override
  String get lessonTypeWhatYouHear => '聞こえたとおりに入力';

  @override
  String get lessonTapWhatYouHear => '聞こえたとおりにタップ';

  @override
  String get lessonTranslateSentence => 'この文を翻訳しましょう';

  @override
  String get lessonTypeAnswerHint => '答えを入力…';

  @override
  String get lessonWriteAnswerHint => '答えを書きましょう…';

  @override
  String get lessonContinue => '続ける';

  @override
  String get lessonSkip => 'スキップ';

  @override
  String get lessonCheck => 'チェック';

  @override
  String get lessonNicelyDone => '✓ よくできました!';

  @override
  String get lessonNotQuite => '✕ おしい!';

  @override
  String lessonAnswerReveal(String answer) {
    return '答え: $answer';
  }

  @override
  String get lessonCompleteKicker => 'レッスン完了';

  @override
  String get lessonCompleteTitle => 'レッスン完了!';

  @override
  String lessonCompleteSummary(int correct, int graded, String level) {
    return '$graded問中$correct問正解 · 現在 $level';
  }

  @override
  String get lessonStatTotalXp => '合計XP';

  @override
  String get lessonStatAccuracy => '正答率';

  @override
  String get lessonStatTime => '時間';

  @override
  String get onboardingWelcomeTitle => 'こんにちは、ラテルです!';

  @override
  String get onboardingWelcomeBody => '恐れず言語を学ぼう — 少しずつ、楽しく、無料で。始める準備はいい?';

  @override
  String get onboardingHaveAccount => 'アカウントを持っています';

  @override
  String get onboardingTryWithoutAccount => 'アカウントなしで試す →';

  @override
  String get onboardingGetStarted => 'はじめる';

  @override
  String get onboardingStartLearning => '学習を始める';

  @override
  String get onboardingLanguageTitle => '何を学びたい?';

  @override
  String get onboardingLanguageSubtitle => '52言語に対応';

  @override
  String get onboardingReasonTitle => '学ぶ理由は?';

  @override
  String get onboardingGoalTitle => '毎日の目標を選ぼう';

  @override
  String get onboardingPlacementTitle => 'スタート地点を見つけよう';

  @override
  String onboardingPlacementBody(String language) {
    return '$languageは初めて?それとも少し知ってる?';
  }

  @override
  String get onboardingBrandNew => 'まったくの初心者です';

  @override
  String get onboardingBrandNewSub => 'いちばん最初から始める';

  @override
  String get onboardingPlacementTest => 'レベル診断テストを受ける';

  @override
  String get onboardingPlacementTestSub => '約3分 · 自分のレベルから開始';

  @override
  String onboardingXpPerDay(int xp) {
    return '$xp XP / 日';
  }

  @override
  String get reasonTravel => '旅行';

  @override
  String get reasonCulture => '文化';

  @override
  String get reasonCareer => 'キャリア';

  @override
  String get reasonFamilyFriends => '家族と友だち';

  @override
  String get reasonBrainTraining => '脳トレ';

  @override
  String get reasonJustForFun => '楽しみのため';

  @override
  String get goalCasual => 'カジュアル';

  @override
  String get goalRegular => 'レギュラー';

  @override
  String get goalSerious => '本気';

  @override
  String get goalIntense => 'ガチ';

  @override
  String get langNameSpanish => 'スペイン語';

  @override
  String get langNameFrench => 'フランス語';

  @override
  String get langNameJapanese => '日本語';

  @override
  String get langNameTamil => 'タミル語';

  @override
  String get langNameGerman => 'ドイツ語';

  @override
  String get langNameKorean => '韓国語';

  @override
  String get settingsDailyGoal => '毎日の目標';

  @override
  String settingsGoalRow(String label, int xp) {
    return '$label · 1日 $xp XP';
  }

  @override
  String get profileAchievements => '実績';

  @override
  String get profileFriends => 'フレンド';

  @override
  String get profileShop => 'ショップ';

  @override
  String get profileNotifications => '通知';

  @override
  String get profileSeeOnboarding => 'オンボーディングを見る ↗';

  @override
  String get profileNotSignedIn => '未ログイン';

  @override
  String get profileCreateAccount => '無料アカウントを作成';

  @override
  String get profileSaveProgress => '進捗をすべての端末で保存';

  @override
  String profileTodaysGoal(int today, int goal) {
    return '今日の目標 · $today/$goal XP';
  }

  @override
  String get profileViewProgress => '進捗を見る →';

  @override
  String get profileUnlocked => '解除済み';
}
