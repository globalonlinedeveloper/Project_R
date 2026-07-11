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

  @override
  String questsResetsIn(int h, int m) {
    return 'リセットまで $h時間 $m分';
  }

  @override
  String get questsDailyRefresh => 'デイリーリフレッシュ';

  @override
  String get questsFreshMix => '新しい5問ミックス';

  @override
  String get questsServedFromQueue => '実際の復習キューから出題 — 本物のXPを獲得。';

  @override
  String get questsGoalReached => '毎日の目標を達成!🎉';

  @override
  String questsReachGoal(int goal) {
    return '今日 $goal XP を獲得しよう';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return 'デイリークエスト · $done/$total';
  }

  @override
  String get questsInfoNote =>
      'クエストは実際の毎日の進捗を追跡します。宝箱・フレンドクエスト・週間リーダーボードにはバックエンド経済が必要 — オーナーの判断(§6)。偽の報酬は表示しません。';

  @override
  String get questsStartRefresh => 'デイリーリフレッシュを始める';

  @override
  String get questsStart => '開始';

  @override
  String get questsPractisedToday => '今日は練習済み — 連続記録は安全';

  @override
  String get questsEarnAnyXp => '今日XPを獲得しよう';

  @override
  String questsXpToday(int current, int target) {
    return '今日 $current/$target XP';
  }

  @override
  String get leaguesYourGroup => 'あなたのグループ';

  @override
  String leaguesThisWeek(int size) {
    return '今週 · $size人の学習者';
  }

  @override
  String get leaguesTiers => 'リーグティア';

  @override
  String leaguesTopClimb(int top, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days日',
    );
    return '毎週上位$top人が昇格 · 終了まで $_temp0';
  }

  @override
  String get leaguesDemotionZone => '降格圏';

  @override
  String get leaguesPromotionZone => '昇格圏';

  @override
  String get leaguesSafeZone => '安全圏';

  @override
  String get leaguesYou => 'あなた';

  @override
  String leaguesPromoteRelegate(int top, int bottom) {
    return '週末に上位$top人が昇格 · 下位$bottom人が降格。';
  }

  @override
  String get leaguesYouAreHere => '現在地';

  @override
  String get leaguesViewAllTiers => '🏆 全10ティアを見る ›';

  @override
  String get notifMarkAllRead => 'すべて既読にする';

  @override
  String get notifEmptyTitle => '通知はまだありません';

  @override
  String get notifEmptyBody =>
      'レッスンを終え、連続記録を作り、レベルアップしよう — 本当に達成した瞬間にマイルストーンがここに表示されます。';

  @override
  String get notifPushNote =>
      'これらはアプリ内のマイルストーンで、達成した瞬間に表示されます。プッシュ通知とリマインダーはオーナーの判断でまだ無効です — 偽物は一切ありません。';
}
