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

  @override
  String get shopPowerUps => 'パワーアップ';

  @override
  String get shopStreakFreeze => 'ストリークフリーズ';

  @override
  String get shopStreakFreezeDesc => '1日休んでも連続記録を守ります。毎日の目標を逃すと自動で消費されます。';

  @override
  String shopOwned(int have, int max) {
    return '所持 $have/$max';
  }

  @override
  String get shopMaxedOut => '上限到達';

  @override
  String shopBuyFor(int cost) {
    return '$cost 💎 で購入';
  }

  @override
  String get shopFreezeAdded => 'ストリークフリーズを追加 💪';

  @override
  String shopFreezeAtCap(int max) {
    return 'すでに最大数のフリーズを所持しています($max)。';
  }

  @override
  String shopNotEnoughEarnCost(int cost) {
    return '💎 が足りません — レッスンを終えて $cost 獲得しよう。';
  }

  @override
  String get shopNotEnoughEarnMore => '💎 が足りません — レッスンを終えてもっと獲得しよう。';

  @override
  String get shopEnergyRefill => 'エネルギー回復';

  @override
  String get shopEnergyRefillDesc =>
      'エネルギーを一気に満タンへ。エネルギーは表示のみ — レッスンは決してブロックされません。';

  @override
  String get shopAlreadyFull => 'すでに満タン';

  @override
  String get shopEnergyRefilled => 'エネルギー回復 ⚡';

  @override
  String get shopEnergyAlreadyFull => 'エネルギーはすでに満タンです。';

  @override
  String get shopStreakRepair => 'ストリーク修復';

  @override
  String get shopStreakRepairDesc => '連続記録を失った?以前の長さに戻して続けよう。';

  @override
  String get shopStreakLapsed => 'ストリーク途切れ';

  @override
  String shopStreakDays(int days) {
    return '🔥 $days日連続';
  }

  @override
  String shopRepairFor(int cost) {
    return '$cost 💎 で修復';
  }

  @override
  String get shopStreakRestored => 'ストリーク復活 🔥';

  @override
  String get shopStreakSafe => '連続記録は無事です — 今は修復不要。';

  @override
  String get shopDoubleXp => 'ダブルXP';

  @override
  String get shopDoubleXpDesc => '15分間、全レッスンで2×XPを獲得。';

  @override
  String shopActiveLeft(int minutes) {
    return '有効 · 残り$minutes分';
  }

  @override
  String get shopInactive => '無効';

  @override
  String get shopActive => '有効';

  @override
  String get shopDoubleXpActive => 'ダブルXP発動 ✨';

  @override
  String get shopBoostRunning => 'ブースト作動中 — XPが2倍です。';

  @override
  String get shopBadgerOutfits => 'アナグマの衣装';

  @override
  String get paywallTitle => 'RATEL PRO';

  @override
  String get paywallStartTrial => '7日間無料トライアルを開始';

  @override
  String paywallGoPro(String price) {
    return 'Proにする — $price/月';
  }

  @override
  String get paywallRestore => '購入を復元';

  @override
  String get paywallHero => 'ライブAIチュータリング、広告なし、オフラインレッスン。';

  @override
  String get paywallAnnual => '年額';

  @override
  String get paywallMonthly => '月額';

  @override
  String get paywallTrialHow => '7日間無料トライアルの仕組み';

  @override
  String get paywallTrialToday => '今日';

  @override
  String get paywallTrialTodayDesc => 'Proのフルアクセスが解放。請求なし。';

  @override
  String get paywallTrialDay5 => '5日目';

  @override
  String get paywallTrialDay5Desc => '終了前にお知らせします。';

  @override
  String get paywallTrialDay7 => '7日目';

  @override
  String paywallTrialDay7Desc(String price) {
    return 'キャンセルしない限り $price/年が始まります。';
  }

  @override
  String get paywallFeatureLiveAi => 'ライブAI:音声・チューターチャット・作文フィードバック';

  @override
  String get paywallFeatureNoAds => '広告は一切なし';

  @override
  String get paywallFeatureOffline => 'オフラインのレッスンと音声';

  @override
  String get paywallFeaturePronunciation => 'AI発音コーチングのヒント';

  @override
  String get paywallEverythingFree =>
      'それ以外のすべて — 52言語・音声・復習・リーグ・ロールプレイ・端末上の発音 — は誰でもずっと無料。';

  @override
  String get paywallYouArePro => 'RATEL PRO をご利用中';

  @override
  String get paywallThanks =>
      'Ratelを支えてくれてありがとう。設定 → サブスクリプション管理 からいつでも管理・解約できます。';

  @override
  String get paywallManage => 'サブスクリプション管理';

  @override
  String paywallFinePrint(String regions) {
    return '設定からいつでもキャンセルできます。表示価格は $regions のもの。実際の価格はアプリストアが決定します。';
  }

  @override
  String get questTitlePowerSession => 'パワーセッション';

  @override
  String get questDescPowerSession => '毎日の目標の2倍を獲得しよう';

  @override
  String get questTitleOnFire => '絶好調';

  @override
  String get questDescOnFire => '毎日の目標の3倍を獲得しよう';

  @override
  String get questTitleStreakKeeper => '連続記録キーパー';

  @override
  String get questDescStreakKeeper => '連続記録を守るために今日練習しよう';

  @override
  String get notifTitleLessons1 => '初レッスン完了';

  @override
  String get notifBodyLessons1 => '最初のレッスンを終えました — 素晴らしいスタート!';

  @override
  String get notifTitleLessons5 => 'レッスン5回達成';

  @override
  String get notifBodyLessons5 => '5回のレッスンを完了しました。この調子で続けましょう。';

  @override
  String get notifTitleLessons10 => 'レッスン10回達成';

  @override
  String get notifBodyLessons10 => '10回のレッスン — 本物の習慣ができつつあります。';

  @override
  String get notifTitleLessons25 => 'レッスン25回達成';

  @override
  String get notifBodyLessons25 => '25回のレッスンを完了。見事な継続力!';

  @override
  String get notifTitleLessons50 => 'レッスン50回達成';

  @override
  String get notifBodyLessons50 => '50回のレッスン — 着実に前進しています。';

  @override
  String get notifTitleStreak3 => '3日連続!';

  @override
  String get notifBodyStreak3 => '3日連続です。継続がすべて。';

  @override
  String get notifTitleStreak7 => '7日連続!';

  @override
  String get notifBodyStreak7 => '毎日練習を丸1週間。お見事!';

  @override
  String get notifTitleStreak14 => '14日連続!';

  @override
  String get notifBodyStreak14 => '2週間連続 — 止まりませんね。';

  @override
  String get notifTitleStreak30 => '30日連続!';

  @override
  String get notifBodyStreak30 => '毎日練習を丸1か月。信じられないほどです。';

  @override
  String get notifTitleXp100 => '100 XP獲得';

  @override
  String get notifBodyXp100 => '最初の100 XP — 勢いが出てきました。';

  @override
  String get notifTitleXp500 => '500 XP獲得';

  @override
  String get notifBodyXp500 => '500 XP。努力が形になっています。';

  @override
  String get notifTitleXp1000 => '1,000 XP獲得';

  @override
  String get notifBodyXp1000 => '1,000 XPの節目に到達!';

  @override
  String get notifTitleXp2500 => '2,500 XP獲得';

  @override
  String get notifBodyXp2500 => '2,500 XP — 大きな進歩です。';

  @override
  String get notifTitleLevel1 => 'レベルA2に到達';

  @override
  String get notifBodyLevel1 => '実力がA1からA2に伸びました。前へ!';

  @override
  String get notifTitleLevel2 => 'レベルB1に到達';

  @override
  String get notifBodyLevel2 => '中級学習者(B1)になりました。';

  @override
  String get notifTitleLevel3 => 'レベルB2に到達';

  @override
  String get notifBodyLevel3 => '中上級(B2)に到達。見事。';

  @override
  String get notifTitleLevel4 => 'レベルC1に到達';

  @override
  String get notifBodyLevel4 => '上級(C1) — スペイン語が確かな力に。';

  @override
  String get notifTitleLevel5 => 'レベルC2に到達';

  @override
  String get notifBodyLevel5 => '熟達(C2) — スケールの頂点!';

  @override
  String get achTitleFirstSteps => 'はじめの一歩';

  @override
  String get achTitleScholar => '学者';

  @override
  String get achTitleWildfire => '野火';

  @override
  String get achTitlePointMaker => 'ポイントメーカー';

  @override
  String get achTitleCollector => 'コレクター';

  @override
  String get achTitleRisingStar => '期待の星';

  @override
  String get leagueTierBronze => 'ブロンズ';

  @override
  String get leagueTierSilver => 'シルバー';

  @override
  String get leagueTierGold => 'ゴールド';

  @override
  String get leagueTierSapphire => 'サファイア';

  @override
  String get leagueTierRuby => 'ルビー';

  @override
  String get leagueTierEmerald => 'エメラルド';

  @override
  String get leagueTierAmethyst => 'アメジスト';

  @override
  String get leagueTierPearl => 'パール';

  @override
  String get leagueTierObsidian => 'オブシディアン';

  @override
  String get leagueTierDiamond => 'ダイヤモンド';

  @override
  String get cefrNameBeginner => '入門';

  @override
  String get cefrNameElementary => '初級';

  @override
  String get cefrNameIntermediate => '中級';

  @override
  String get cefrNameUpperIntermediate => '中上級';

  @override
  String get cefrNameAdvanced => '上級';

  @override
  String get cefrNameProficient => '熟達';

  @override
  String leaguesTierLeague(String tier) {
    return '$tierリーグ';
  }

  @override
  String leaguesYoureIn(String tier) {
    return 'あなたは$tier · 毎週上位7名が昇格';
  }

  @override
  String get leaguesZonePromotion => '⬆ 昇格圏';

  @override
  String get leaguesZoneDemotion => '⬇ 降格圏';

  @override
  String profileAchievementsSummary(int unlocked, int total) {
    return '$total個中$unlocked個解除 · 実際の進捗';
  }

  @override
  String get profileRealStateNote =>
      'レベル・XP・レッスン・連続記録・保存した単語は実際のエンジン状態です — 新しいアカウントではゼロから始まります。';

  @override
  String get practiceTitle => '練習';

  @override
  String practiceReviewWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count語を復習',
    );
    return '$_temp0';
  }

  @override
  String get practiceYourWords => 'あなたの単語';

  @override
  String practiceSavedWordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '保存した単語 $count語',
    );
    return '$_temp0';
  }

  @override
  String practiceDueForReview(int count) {
    return '$count語が間隔復習の期限';
  }

  @override
  String get practiceAllUpToDate => 'すべての復習が最新';

  @override
  String practiceCaughtUp(String tail) {
    return 'すべて完了 — 今は復習するものがありません$tail。';
  }

  @override
  String practiceNextTail(String when) {
    return ' · 次は$when';
  }

  @override
  String get practiceZeroDue => '期限 0';

  @override
  String get practiceDueNow => '今が期限';

  @override
  String practiceDueWhen(String when) {
    return '期限: $when';
  }

  @override
  String get practiceChipDue => '期限';

  @override
  String get practiceChipScheduled => '予定済み';

  @override
  String get practiceScheduleNote =>
      '復習は本物のFSRS-6間隔反復エンジンが予定します。期限はこのセッション内で保持され、再起動をまたぐ保存はリリース時の作業です — ここに作り物はありません。';

  @override
  String get practiceNoSavedWords => '保存した単語はまだありません';

  @override
  String get practiceSaveWordHint =>
      'レッスン中に単語を保存すると、ここにフラッシュカードとして届きます。復習は本物のFSRS間隔反復エンジンが予定します — 事前入力はありません。';

  @override
  String get practiceStartLesson => 'レッスンを始める';

  @override
  String practiceWordOf(int n, int total) {
    return '単語 $n/$total';
  }

  @override
  String get practiceShowAnswer => '答えを見る';

  @override
  String get practiceRecallHint => '意味を思い出してから、どれだけ覚えていたか評価しましょう。';

  @override
  String get practiceGradeAgain => 'もう一度';

  @override
  String get practiceGradeHard => '難しい';

  @override
  String get practiceGradeGood => '良い';

  @override
  String get practiceGradeEasy => '簡単';

  @override
  String get practiceFsrsGradeNote => 'FSRS-6があなたの評価から次の復習を予定します';

  @override
  String get practiceReviewComplete => '復習完了';

  @override
  String practiceReviewedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count語を復習しました。FSRSが再予定しました。',
    );
    return '$_temp0';
  }

  @override
  String get practiceDone => '完了';

  @override
  String get practiceRelTomorrow => '明日';

  @override
  String practiceRelInDays(int days) {
    return '$days日後';
  }

  @override
  String practiceRelInHours(int hours) {
    return '$hours時間後';
  }

  @override
  String practiceRelInMinutes(int minutes) {
    return '$minutes分後';
  }

  @override
  String get practiceRelSoon => 'まもなく';

  @override
  String get progressTitle => '進捗';

  @override
  String get progressShareMilestone => 'マイルストーンを共有';

  @override
  String get progressLast7Days => '過去7日間';

  @override
  String get progressAccuracyRetention => '正答率と記憶保持';

  @override
  String get progressHonestyNote =>
      'ここにあるものはすべて実際に記録された状態です — レベル・能力・保存した単語・XP・レッスン・連続記録・7日間の履歴・正答率・学習時間はゼロから始まり、学ぶほど増えます。記憶保持はこのセッションの予測想起です(セッションをまたぐスケジューラはリリース時の作業)。作り物はありません。';

  @override
  String progressShareText(
    String level,
    String levelName,
    int streak,
    int xp,
    int lessons,
  ) {
    return '🦡 RATEL · レベル$level($levelName)\n🔥 $streak日連続 · ⚡ $xp XP · 📘 レッスン$lessons回\nlearnwithratel.comで学習中';
  }

  @override
  String get progressShareCopied => 'マイルストーンをクリップボードにコピーしました — どこでも共有できます!';

  @override
  String progressAbilityLine(String theta) {
    return '能力 θ $theta · 実際の推定';
  }

  @override
  String get progressStatSavedWords => '保存した単語';

  @override
  String get progressStatLessons => 'レッスン';

  @override
  String get progressStatDayStreak => '連続日数';

  @override
  String get progressStatTotalXp => '合計XP';

  @override
  String get progressStatTodaysXp => '今日のXP';

  @override
  String get progressStatCefrLevel => 'CEFRレベル';

  @override
  String get progressAccuracy => '正答率';

  @override
  String get progressStudyTime => '学習時間';

  @override
  String get progressRetention => '記憶保持';

  @override
  String get progressNoData => 'まだデータなし';

  @override
  String get progressAccuracyEmpty => '採点ありの問題に答えると始まります';

  @override
  String progressAccuracyDetail(int correct, int total) {
    return '$total問中$correct問正解';
  }

  @override
  String get progressTimeEmpty => 'レッスンの時間がここに積み上がります';

  @override
  String get progressTimeDetail => 'すべてのレッスンの合計';

  @override
  String get progressRetentionEmpty => '復習すると予測想起が表示されます';

  @override
  String progressRetentionDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '1日後の予測想起 · このセッションで$count項目',
    );
    return '$_temp0';
  }

  @override
  String progressWeekTotal(int xp) {
    return '$xp XP · 過去7日間';
  }

  @override
  String get progressNoXpYet => 'まだXPの記録がありません';

  @override
  String get progressChartEmptyNote =>
      'レッスンを終えると7日間の履歴が始まります — 活動のない日はゼロのまま、作り物はありません。';

  @override
  String get commonDowMon => '月';

  @override
  String get commonDowTue => '火';

  @override
  String get commonDowWed => '水';

  @override
  String get commonDowThu => '木';

  @override
  String get commonDowFri => '金';

  @override
  String get commonDowSat => '土';

  @override
  String get commonDowSun => '日';

  @override
  String get searchTitle => '検索';

  @override
  String get searchHint => 'レッスン・単語・ストーリーを検索…';

  @override
  String get searchRecent => '最近';

  @override
  String get searchClear => 'クリア';

  @override
  String get searchJumpTo => 'ジャンプ';

  @override
  String get searchTagPage => 'ページ';

  @override
  String get searchTagWord => '単語';

  @override
  String get searchSubtitleSavedWord => '保存した単語';

  @override
  String searchLessonSubtitle(String unit) {
    return '$unit · レッスン';
  }

  @override
  String searchNoMatches(String query) {
    return '「$query」に一致する結果はありません';
  }

  @override
  String get searchEmptyNote =>
      'コース・保存した単語・ページのタイトル、タグ、レッスン内容を検索します。サーバー側の内容インデックスと人気検索はR-L12の今後の対応 — ここに偽物はありません。';

  @override
  String get searchNoMatchNote =>
      '公開済みのレッスン、保存した単語、アプリのページ(タイトル+タグ)を検索します。ストーリー/ポッドキャストと全文検索はR-L12の今後の対応 — 決して偽装しません。';

  @override
  String get searchFooterNote =>
      'リリース時はタイトル+タグ。全文、ストーリー/ポッドキャスト、複数コース対応はR-L12の今後の対応 — 決して偽装しません。';

  @override
  String get searchDestPracticeHub => '練習ハブ';

  @override
  String get searchDestPracticeHubSub => '間違い・弱点単語・ドリル';

  @override
  String get searchDestAiTutor => 'AIチューター';

  @override
  String get searchDestAiTutorSub => '会話・チャット・ロールプレイ';

  @override
  String get searchDestAdventures => 'アドベンチャー';

  @override
  String get searchDestAdventuresSub => 'リアルな会話 — 無料';

  @override
  String get searchDestLeagues => 'リーグ';

  @override
  String get searchDestLeaguesSub => 'あなたの週間リーグ';

  @override
  String get searchDestQuests => 'クエスト';

  @override
  String get searchDestQuestsSub => '毎日の目標とクエスト';

  @override
  String get searchDestProgress => '進捗';

  @override
  String get searchDestProgressSub => '統計と連続記録';

  @override
  String get searchDestProfile => 'プロフィール';

  @override
  String get searchDestProfileSub => 'あなたのプロフィール';

  @override
  String get searchDestSettings => '設定';

  @override
  String get searchDestSettingsSub => 'アカウントと設定';

  @override
  String get searchDestShop => 'ショップ';

  @override
  String get searchDestShopSub => 'ダイヤモンドを使う';

  @override
  String get searchDestNotifications => '通知';

  @override
  String get searchDestNotificationsSub => 'マイルストーンの受信箱';

  @override
  String get themesTitle => 'テーマ';

  @override
  String get themesSubtitle => 'アプリ全体の見た目を変えます — タップでライブプレビュー';

  @override
  String themesVehicle(String vehicle) {
    return '乗り物 · $vehicle';
  }

  @override
  String get tutorHeader => 'リアルな会話を練習しよう';

  @override
  String get tutorHeaderSub => 'シーンを選んでRatelとチャット — 間違いはなし、ただ練習あるのみ。';

  @override
  String get tutorTalkTitle => 'Ratelと話す';

  @override
  String get tutorTalkSub => '音声・ビデオのライブスピーキング練習';

  @override
  String get tutorChatTitle => 'Ratelとチャット';

  @override
  String get tutorChatSub => 'AIチャット · ライティング添削';

  @override
  String get tutorRoleplayTitle => 'ロールプレイシーン';

  @override
  String get tutorRoleplayGuided => 'ガイド付きロールプレイ会話';

  @override
  String tutorScenesCount(int count) {
    return '$countシーン';
  }

  @override
  String get tutorUnlockPro => 'RATEL PROを解除';

  @override
  String get tutorRelayNote =>
      'ライブAIチュータリングはモデレーション付き・コスト管理されたリレー上で動作するRATEL PRO機能です。返答は決してシミュレーションではありません — PROとリレーの両方が有効なときだけモードが始まります。';

  @override
  String get tutorStatusReadyPro => 'PRO有効・ライブチューター接続済み — モードを選んで始めましょう。';

  @override
  String get tutorStatusReadyFree => 'ライブチューターは接続済み。ライブチュータリングはRATEL PRO機能です。';

  @override
  String get tutorStatusOffline =>
      'このビルドではモデレーション付きライブチューターは未接続です — ライブチュータリングは後の段階で有効になります。以下に偽物はありません。';

  @override
  String get tutorAnnounceNeedsPro => 'RATEL PROでライブAIチュータリングが解除されます。';

  @override
  String get tutorAnnounceNeedsRelay => 'モデレーション付きリレーが有効になるとAIチュータリングがつながります。';

  @override
  String get tutorAnnounceStarting => 'セッションを開始しています…';

  @override
  String get adventuresTitle => 'アドベンチャー';

  @override
  String get adventuresFreeChip => '無料';

  @override
  String get adventuresIntro => '道を選ぼう — 選択のたびに物語が分岐します。間違いはなく、いつでも無料。';

  @override
  String get adventuresFallbackWorld => 'アドベンチャー';

  @override
  String adventureSheetKicker(String cefr) {
    return '🗺️ アドベンチャー · $cefr';
  }

  @override
  String adventureScenesCount(int count) {
    return '$countシーン';
  }

  @override
  String adventureChoicePoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '分岐ポイント$count個',
    );
    return '$_temp0';
  }

  @override
  String get adventureOpeningScene => 'オープニングシーン';

  @override
  String get adventureStart => 'アドベンチャーを始める';

  @override
  String get adventurePlayerFallbackTitle => 'アドベンチャー';

  @override
  String get adventureTheEnd => '🏁 おわり';

  @override
  String get adventureStartOver => '最初からやり直す';

  @override
  String get adventureDone => '完了';

  @override
  String get adventureCompleteKicker => 'アドベンチャー完了';

  @override
  String adventureCompleteTitle(String title) {
    return '$title ✓';
  }

  @override
  String get adventureCompleteBody =>
      'よくできました！+15 XP · +5 💎 を獲得 — 次のシーンはいつでも探索できます。';

  @override
  String adventureDistrictProgress(int done, int total) {
    return '$done/$total 探索済み';
  }

  @override
  String get adventureDistrictDone => '✓ 完了';

  @override
  String get adventuresEmpty => 'このコースにはまだアドベンチャーがありません。';

  @override
  String get authWelcomeTitle => 'Ratelへようこそ';

  @override
  String get authWelcomeSubtitle => 'レッスン、ストーリー、ポッドキャストなど —\n始め方を選びましょう。';

  @override
  String get authCreateFreeAccount => '無料アカウントを作成';

  @override
  String get authAlreadyHaveAccount => 'アカウントを持っています';

  @override
  String get authSettingUp => '準備しています…';

  @override
  String get authContinueAsGuest => 'ゲストとして続ける';

  @override
  String get authGuestNote =>
      'ゲストの進捗はこの端末に保存されます — どこでも使うには、設定からいつでも無料アカウントを作成できます。';

  @override
  String get authEnterYourEmail => 'メールアドレスを入力';

  @override
  String get authEnterValidEmail => '有効なメールアドレスを入力';

  @override
  String get authEnterYourPassword => 'パスワードを入力';

  @override
  String get authCouldNotSignIn => 'サインインできませんでした。もう一度お試しください。';

  @override
  String get authSomethingWentWrong => '問題が発生しました。もう一度お試しください。';

  @override
  String get authSocialComingSoon => 'Google / Appleでのサインインは近日対応。';

  @override
  String get authResetTitle => 'パスワードをリセット';

  @override
  String get authWelcomeBack => 'おかえりなさい!';

  @override
  String get authResetSubtitle => 'メールアドレスを入力すると、リセットリンクを送ります。';

  @override
  String get authPickUpWhereYouLeft => '前回の続きから';

  @override
  String get authEmailHint => 'メール';

  @override
  String get authPasswordHint => 'パスワード';

  @override
  String get authForgotPassword => 'パスワードをお忘れですか?';

  @override
  String get authSendResetLink => 'リセットリンクを送信';

  @override
  String get authLogIn => 'ログイン';

  @override
  String get authBackToLogIn => 'ログインに戻る';

  @override
  String get authNewToRatel => 'Ratelは初めてですか? ';

  @override
  String get authSignUp => '登録';

  @override
  String get authCheckYourInbox => '受信箱を確認';

  @override
  String authResetSent(String email) {
    return '$email にパスワードリセットのリンクを送りました。開いて新しいパスワードを設定してください。';
  }

  @override
  String get authCreatePassword => 'パスワードを作成';

  @override
  String get authAtLeast8Chars => '8文字以上';

  @override
  String get authCreateYourAccount => 'アカウントを作成';

  @override
  String get authSignupSubtitle => 'ずっと無料 · 52言語を学べる';

  @override
  String get authPassword8Hint => 'パスワード(8文字以上)';

  @override
  String get authCreateAccount => 'アカウント作成';

  @override
  String get authAlreadyAccountLead => 'アカウントをお持ちですか? ';

  @override
  String get authSignIn => 'サインイン';

  @override
  String get authConfirmEmail => 'メールを確認';

  @override
  String authConfirmSent(String email) {
    return '$email に確認リンクを送りました。タップしてアカウントを有効化し、戻ってログインしてください。';
  }

  @override
  String get authContinueGoogle => 'Googleで続ける';

  @override
  String get authContinueApple => 'Appleで続ける';

  @override
  String get authOr => 'または';

  @override
  String get authUnavailableNote =>
      'このビルドではまだアカウントを利用できません — ゲストとして学習を続けられます。バックエンド設定後にサインインが有効になります。';

  @override
  String get liveMute => 'ミュート';

  @override
  String get liveUnmute => 'ミュート解除';

  @override
  String commonDurSeconds(int s) {
    return '$s秒';
  }

  @override
  String commonDurMinutes(int m) {
    return '$m分';
  }

  @override
  String commonDurHours(int h) {
    return '$h時間';
  }

  @override
  String commonDurHoursMinutes(int h, int m) {
    return '$h時間$m分';
  }

  @override
  String practiceGradeInterval(String label, int days) {
    return '$label · $days日';
  }
}
