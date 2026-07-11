// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get navHome => '홈';

  @override
  String get navLibrary => '라이브러리';

  @override
  String get navLeagues => '리그';

  @override
  String get navQuests => '퀘스트';

  @override
  String get navProfile => '프로필';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsSectionLearning => '학습';

  @override
  String get settingsSectionSubscription => '구독';

  @override
  String get settingsSectionAccessibility => '접근성';

  @override
  String get settingsSectionNotifications => '알림';

  @override
  String get settingsSectionAppearanceAccount => '모양 및 계정';

  @override
  String get settingsAppLanguage => '앱 언어';

  @override
  String get settingsAppLanguageSystem => '시스템 기본값';

  @override
  String get homeCourseLoadingTitle => '코스를 준비하고 있어요';

  @override
  String get homeCourseLoadingBody => '코스 콘텐츠가 로드되면 레슨이 여기에 표시됩니다.';

  @override
  String get homeGuideChip => '가이드';

  @override
  String get homeStartNode => '시작';

  @override
  String get homeUnitGuideHeader => '유닛 가이드';

  @override
  String get commonDone => '완료';

  @override
  String homeUnitKicker(String unit) {
    return '유닛 · $unit';
  }

  @override
  String homeLessonMeta(int num, int count, String exercises) {
    return '레슨 $num / $count · $exercises.';
  }

  @override
  String homeQuickExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '빠른 연습 $count개',
    );
    return '$_temp0';
  }

  @override
  String get homeEnergyChip => '−1 ⚡ 에너지';

  @override
  String get homeXpChip => '+20 XP';

  @override
  String get homeStartLesson => '레슨 시작';

  @override
  String get homeTutorChip => '튜터';

  @override
  String get libraryAiTutor => 'AI 튜터';

  @override
  String get libraryAiTutorSub => '말하기·채팅·롤플레이 — 작문 피드백';

  @override
  String get libraryRoleplay => '롤플레이';

  @override
  String get libraryRoleplaySub => '답변 연습 — 채점되며 항상 무료';

  @override
  String get librarySectionPractice => '연습';

  @override
  String get libraryPracticeHub => '연습 허브';

  @override
  String get libraryPracticeHubSub => '실수·약한 단어·드릴 · 무료';

  @override
  String get librarySectionReadListen => '읽고 듣기';

  @override
  String get libraryGradedStories => '단계별 스토리';

  @override
  String get libraryPodcasts => '팟캐스트';

  @override
  String get libraryWatch => '시청';

  @override
  String get librarySearchHint => '레슨, 단어, 스토리 검색…';

  @override
  String get libraryFeaturedStory => '추천 · 스토리';

  @override
  String commonLevel(String cefr) {
    return '레벨 $cefr';
  }

  @override
  String get libraryReadNow => '지금 읽기';

  @override
  String get libraryNewExplore => '신규 · 탐험';

  @override
  String get libraryAdventures => '어드벤처';

  @override
  String get libraryStartExploring => '탐험 시작하기 →';

  @override
  String get libraryKindStory => '스토리';

  @override
  String get libraryKindPodcast => '팟캐스트';

  @override
  String get libraryKindVideo => '동영상';

  @override
  String get libraryAllStories => '모든 스토리';

  @override
  String get libraryAllPodcasts => '모든 팟캐스트';

  @override
  String get libraryAllVideos => '모든 동영상';

  @override
  String get lessonTypeWhatYouHear => '들리는 대로 입력하세요';

  @override
  String get lessonTapWhatYouHear => '들리는 대로 선택하세요';

  @override
  String get lessonTranslateSentence => '이 문장을 번역하세요';

  @override
  String get lessonTypeAnswerHint => '답을 입력하세요…';

  @override
  String get lessonWriteAnswerHint => '답을 써 보세요…';

  @override
  String get lessonContinue => '계속';

  @override
  String get lessonSkip => '건너뛰기';

  @override
  String get lessonCheck => '확인';

  @override
  String get lessonNicelyDone => '✓ 잘했어요!';

  @override
  String get lessonNotQuite => '✕ 아쉬워요';

  @override
  String lessonAnswerReveal(String answer) {
    return '정답: $answer';
  }

  @override
  String get lessonCompleteKicker => '레슨 완료';

  @override
  String get lessonCompleteTitle => '레슨 완료!';

  @override
  String lessonCompleteSummary(int correct, int graded, String level) {
    return '$graded개 중 $correct개 정답 · 현재 $level';
  }

  @override
  String get lessonStatTotalXp => '총 XP';

  @override
  String get lessonStatAccuracy => '정확도';

  @override
  String get lessonStatTime => '시간';

  @override
  String get onboardingWelcomeTitle => '안녕, 나는 라텔이야!';

  @override
  String get onboardingWelcomeBody =>
      '두려움 없이 언어를 배워요 — 한 입 크기로, 재미있게, 무료로. 시작해 볼까요?';

  @override
  String get onboardingHaveAccount => '이미 계정이 있어요';

  @override
  String get onboardingTryWithoutAccount => '계정 없이 체험하기 →';

  @override
  String get onboardingGetStarted => '시작하기';

  @override
  String get onboardingStartLearning => '학습 시작하기';

  @override
  String get onboardingLanguageTitle => '무엇을 배우고 싶나요?';

  @override
  String get onboardingLanguageSubtitle => '52개 언어 지원';

  @override
  String get onboardingReasonTitle => '왜 배우나요?';

  @override
  String get onboardingGoalTitle => '일일 목표를 골라요';

  @override
  String get onboardingPlacementTitle => '시작 지점을 찾아요';

  @override
  String onboardingPlacementBody(String language) {
    return '$language가 처음인가요, 아니면 조금 아나요?';
  }

  @override
  String get onboardingBrandNew => '완전 처음이에요';

  @override
  String get onboardingBrandNewSub => '맨 처음부터 시작';

  @override
  String get onboardingPlacementTest => '레벨 테스트 보기';

  @override
  String get onboardingPlacementTestSub => '약 3분 · 내 레벨로 건너뛰기';

  @override
  String onboardingXpPerDay(int xp) {
    return '$xp XP / 일';
  }

  @override
  String get reasonTravel => '여행';

  @override
  String get reasonCulture => '문화';

  @override
  String get reasonCareer => '커리어';

  @override
  String get reasonFamilyFriends => '가족과 친구';

  @override
  String get reasonBrainTraining => '두뇌 훈련';

  @override
  String get reasonJustForFun => '그냥 재미로';

  @override
  String get goalCasual => '가볍게';

  @override
  String get goalRegular => '꾸준히';

  @override
  String get goalSerious => '진지하게';

  @override
  String get goalIntense => '빡세게';

  @override
  String get langNameSpanish => '스페인어';

  @override
  String get langNameFrench => '프랑스어';

  @override
  String get langNameJapanese => '일본어';

  @override
  String get langNameTamil => '타밀어';

  @override
  String get langNameGerman => '독일어';

  @override
  String get langNameKorean => '한국어';

  @override
  String get settingsDailyGoal => '일일 목표';

  @override
  String settingsGoalRow(String label, int xp) {
    return '$label · 하루 $xp XP';
  }

  @override
  String get profileAchievements => '업적';

  @override
  String get profileFriends => '친구';

  @override
  String get profileShop => '상점';

  @override
  String get profileNotifications => '알림';

  @override
  String get profileSeeOnboarding => '온보딩 보기 ↗';

  @override
  String get profileNotSignedIn => '로그인 안 됨';

  @override
  String get profileCreateAccount => '무료 계정 만들기';

  @override
  String get profileSaveProgress => '모든 기기에서 진행 상황 저장';

  @override
  String profileTodaysGoal(int today, int goal) {
    return '오늘의 목표 · $today/$goal XP';
  }

  @override
  String get profileViewProgress => '진행 상황 보기 →';

  @override
  String get profileUnlocked => '잠금 해제';

  @override
  String questsResetsIn(int h, int m) {
    return '$h시간 $m분 후 초기화';
  }

  @override
  String get questsDailyRefresh => '데일리 리프레시';

  @override
  String get questsFreshMix => '새로운 5문제 믹스';

  @override
  String get questsServedFromQueue => '실제 복습 대기열에서 출제 — 진짜 XP 획득.';

  @override
  String get questsGoalReached => '일일 목표 달성! 🎉';

  @override
  String questsReachGoal(int goal) {
    return '오늘 $goal XP 모으기';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return '일일 퀘스트 · $done/$total';
  }

  @override
  String get questsInfoNote =>
      '퀘스트는 실제 일일 진행 상황을 추적해요. 보상 상자, 친구 퀘스트, 주간 리더보드에는 백엔드 경제가 필요해요 — 소유자의 결정(§6). 가짜 보상은 표시하지 않아요.';

  @override
  String get questsStartRefresh => '데일리 리프레시 시작';

  @override
  String get questsStart => '시작';

  @override
  String get questsPractisedToday => '오늘 연습 완료 — 스트릭 안전';

  @override
  String get questsEarnAnyXp => '오늘 아무 XP나 획득';

  @override
  String questsXpToday(int current, int target) {
    return '오늘 $current/$target XP';
  }

  @override
  String get leaguesYourGroup => '내 그룹';

  @override
  String leaguesThisWeek(int size) {
    return '이번 주 · 학습자 $size명';
  }

  @override
  String get leaguesTiers => '리그 티어';

  @override
  String leaguesTopClimb(int top, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days일',
    );
    return '매주 상위 $top명 승급 · $_temp0 후 종료';
  }

  @override
  String get leaguesDemotionZone => '강등권';

  @override
  String get leaguesPromotionZone => '승급권';

  @override
  String get leaguesSafeZone => '안전권';

  @override
  String get leaguesYou => '나';

  @override
  String leaguesPromoteRelegate(int top, int bottom) {
    return '주가 끝나면 상위 $top명 승급 · 하위 $bottom명 강등.';
  }

  @override
  String get leaguesYouAreHere => '현재 위치';

  @override
  String get leaguesViewAllTiers => '🏆 전체 10개 티어 보기 ›';

  @override
  String get notifMarkAllRead => '모두 읽음으로 표시';

  @override
  String get notifEmptyTitle => '아직 알림이 없어요';

  @override
  String get notifEmptyBody =>
      '레슨을 끝내고, 스트릭을 쌓고, 레벨을 올리세요 — 진짜로 달성하는 순간 마일스톤이 여기에 표시돼요.';

  @override
  String get notifPushNote =>
      '이것은 앱 내 마일스톤으로, 달성하는 순간 표시돼요. 푸시 알림과 리마인더는 소유자의 결정이며 아직 활성화되지 않았어요 — 여기 가짜는 없어요.';

  @override
  String get shopPowerUps => '파워업';

  @override
  String get shopStreakFreeze => '스트릭 프리즈';

  @override
  String get shopStreakFreezeDesc => '하루 빠져도 스트릭을 지켜줘요. 일일 목표를 놓치면 자동으로 사용돼요.';

  @override
  String shopOwned(int have, int max) {
    return '보유 $have/$max';
  }

  @override
  String get shopMaxedOut => '최대 보유';

  @override
  String shopBuyFor(int cost) {
    return '$cost 💎로 구매';
  }

  @override
  String get shopFreezeAdded => '스트릭 프리즈 추가됨 💪';

  @override
  String shopFreezeAtCap(int max) {
    return '이미 최대 개수예요($max).';
  }

  @override
  String shopNotEnoughEarnCost(int cost) {
    return '💎 부족 — 레슨을 끝내고 $cost 모으세요.';
  }

  @override
  String get shopNotEnoughEarnMore => '💎 부족 — 레슨을 끝내고 더 모으세요.';

  @override
  String get shopEnergyRefill => '에너지 리필';

  @override
  String get shopEnergyRefillDesc =>
      '에너지를 바로 가득 채우세요. 에너지는 표시용일 뿐 — 레슨은 절대 막히지 않아요.';

  @override
  String get shopAlreadyFull => '이미 가득';

  @override
  String get shopEnergyRefilled => '에너지 충전 완료 ⚡';

  @override
  String get shopEnergyAlreadyFull => '에너지가 이미 가득해요.';

  @override
  String get shopStreakRepair => '스트릭 복구';

  @override
  String get shopStreakRepairDesc => '스트릭을 잃었나요? 이전 길이로 되돌리고 계속 이어가세요.';

  @override
  String get shopStreakLapsed => '스트릭 끊김';

  @override
  String shopStreakDays(int days) {
    return '🔥 $days일 스트릭';
  }

  @override
  String shopRepairFor(int cost) {
    return '$cost 💎로 복구';
  }

  @override
  String get shopStreakRestored => '스트릭 복구 완료 🔥';

  @override
  String get shopStreakSafe => '스트릭이 안전해요 — 지금은 복구할 게 없어요.';

  @override
  String get shopDoubleXp => '더블 XP';

  @override
  String get shopDoubleXpDesc => '15분 동안 모든 레슨에서 2× XP 획득.';

  @override
  String shopActiveLeft(int minutes) {
    return '활성 · $minutes분 남음';
  }

  @override
  String get shopInactive => '비활성';

  @override
  String get shopActive => '활성';

  @override
  String get shopDoubleXpActive => '더블 XP 활성화 ✨';

  @override
  String get shopBoostRunning => '부스트 작동 중 — XP가 2배예요.';

  @override
  String get shopBadgerOutfits => '오소리 의상';

  @override
  String get paywallTitle => 'RATEL PRO';

  @override
  String get paywallStartTrial => '7일 무료 체험 시작';

  @override
  String paywallGoPro(String price) {
    return 'Pro 시작 — $price/월';
  }

  @override
  String get paywallRestore => '구매 복원';

  @override
  String get paywallHero => '실시간 AI 튜터링, 광고 없음, 오프라인 레슨.';

  @override
  String get paywallAnnual => '연간';

  @override
  String get paywallMonthly => '월간';

  @override
  String get paywallTrialHow => '7일 무료 체험 안내';

  @override
  String get paywallTrialToday => '오늘';

  @override
  String get paywallTrialTodayDesc => 'Pro 전체 이용 해제. 요금 없음.';

  @override
  String get paywallTrialDay5 => '5일차';

  @override
  String get paywallTrialDay5Desc => '체험 종료 전에 알려드려요.';

  @override
  String get paywallTrialDay7 => '7일차';

  @override
  String paywallTrialDay7Desc(String price) {
    return '취소하지 않으면 $price/년이 시작돼요.';
  }

  @override
  String get paywallFeatureLiveAi => '실시간 AI: 음성, 튜터 채팅, 작문 피드백';

  @override
  String get paywallFeatureNoAds => '어디서든 광고 없음';

  @override
  String get paywallFeatureOffline => '오프라인 레슨과 오디오';

  @override
  String get paywallFeaturePronunciation => 'AI 발음 코칭 팁';

  @override
  String get paywallEverythingFree =>
      '나머지 전부 — 52개 언어, 오디오, 복습, 리그, 롤플레이, 기기 내 발음 — 는 모두에게 무료예요.';

  @override
  String get paywallYouArePro => 'RATEL PRO 이용 중';

  @override
  String get paywallThanks =>
      'Ratel을 응원해 주셔서 감사해요. 설정 → 구독 관리에서 언제든 관리하거나 취소할 수 있어요.';

  @override
  String get paywallManage => '구독 관리';

  @override
  String paywallFinePrint(String regions) {
    return '설정에서 언제든 취소할 수 있어요. 표시된 가격은 $regions 기준이며 실제 가격은 앱 스토어가 정해요.';
  }

  @override
  String get questTitlePowerSession => '파워 세션';

  @override
  String get questDescPowerSession => '일일 목표의 2배를 획득하세요';

  @override
  String get questTitleOnFire => '불타는 중';

  @override
  String get questDescOnFire => '일일 목표의 3배를 획득하세요';

  @override
  String get questTitleStreakKeeper => '스트릭 지킴이';

  @override
  String get questDescStreakKeeper => '스트릭을 지키려면 오늘 연습하세요';

  @override
  String get notifTitleLessons1 => '첫 레슨 완료';

  @override
  String get notifBodyLessons1 => '첫 레슨을 마쳤어요 — 멋진 시작!';

  @override
  String get notifTitleLessons5 => '레슨 5개 완료';

  @override
  String get notifBodyLessons5 => '레슨 5개를 완료했어요. 기세를 이어가세요.';

  @override
  String get notifTitleLessons10 => '레슨 10개 완료';

  @override
  String get notifBodyLessons10 => '레슨 10개 — 진짜 습관이 만들어지고 있어요.';

  @override
  String get notifTitleLessons25 => '레슨 25개 완료';

  @override
  String get notifBodyLessons25 => '레슨 25개 완료. 인상적인 노력이에요!';

  @override
  String get notifTitleLessons50 => '레슨 50개 완료';

  @override
  String get notifBodyLessons50 => '레슨 50개 — 순조롭게 나아가고 있어요.';

  @override
  String get notifTitleStreak3 => '3일 스트릭!';

  @override
  String get notifBodyStreak3 => '3일 연속. 꾸준함이 전부예요.';

  @override
  String get notifTitleStreak7 => '7일 스트릭!';

  @override
  String get notifBodyStreak7 => '매일 연습으로 꽉 채운 일주일. 훌륭해요!';

  @override
  String get notifTitleStreak14 => '14일 스트릭!';

  @override
  String get notifBodyStreak14 => '2주 연속 — 멈출 수 없네요.';

  @override
  String get notifTitleStreak30 => '30일 스트릭!';

  @override
  String get notifBodyStreak30 => '매일 연습으로 꽉 채운 한 달. 놀라워요.';

  @override
  String get notifTitleXp100 => '100 XP 획득';

  @override
  String get notifBodyXp100 => '첫 100 XP — 탄력이 붙고 있어요.';

  @override
  String get notifTitleXp500 => '500 XP 획득';

  @override
  String get notifBodyXp500 => '500 XP. 제대로 노력하고 있어요.';

  @override
  String get notifTitleXp1000 => '1,000 XP 획득';

  @override
  String get notifBodyXp1000 => '1,000 XP 이정표 달성!';

  @override
  String get notifTitleXp2500 => '2,500 XP 획득';

  @override
  String get notifBodyXp2500 => '2,500 XP — 진지한 발전이에요.';

  @override
  String get notifTitleLevel1 => '레벨 A2 도달';

  @override
  String get notifBodyLevel1 => '실력이 A1에서 A2로 성장했어요. 앞으로!';

  @override
  String get notifTitleLevel2 => '레벨 B1 도달';

  @override
  String get notifBodyLevel2 => '이제 중급 학습자예요 (B1).';

  @override
  String get notifTitleLevel3 => '레벨 B2 도달';

  @override
  String get notifBodyLevel3 => '중상급(B2) 도달. 훌륭해요.';

  @override
  String get notifTitleLevel4 => '레벨 C1 도달';

  @override
  String get notifBodyLevel4 => '고급(C1) — 스페인어 실력이 탄탄해요.';

  @override
  String get notifTitleLevel5 => '레벨 C2 도달';

  @override
  String get notifBodyLevel5 => '숙달(C2) — 척도의 정점!';

  @override
  String get achTitleFirstSteps => '첫걸음';

  @override
  String get achTitleScholar => '학자';

  @override
  String get achTitleWildfire => '들불';

  @override
  String get achTitlePointMaker => '포인트 메이커';

  @override
  String get achTitleCollector => '수집가';

  @override
  String get achTitleRisingStar => '떠오르는 별';

  @override
  String get leagueTierBronze => '브론즈';

  @override
  String get leagueTierSilver => '실버';

  @override
  String get leagueTierGold => '골드';

  @override
  String get leagueTierSapphire => '사파이어';

  @override
  String get leagueTierRuby => '루비';

  @override
  String get leagueTierEmerald => '에메랄드';

  @override
  String get leagueTierAmethyst => '자수정';

  @override
  String get leagueTierPearl => '진주';

  @override
  String get leagueTierObsidian => '흑요석';

  @override
  String get leagueTierDiamond => '다이아몬드';

  @override
  String get cefrNameBeginner => '입문';

  @override
  String get cefrNameElementary => '초급';

  @override
  String get cefrNameIntermediate => '중급';

  @override
  String get cefrNameUpperIntermediate => '중상급';

  @override
  String get cefrNameAdvanced => '고급';

  @override
  String get cefrNameProficient => '숙달';

  @override
  String leaguesTierLeague(String tier) {
    return '$tier 리그';
  }

  @override
  String leaguesYoureIn(String tier) {
    return '$tier 리그에 있어요 · 매주 상위 7명 승급';
  }

  @override
  String get leaguesZonePromotion => '⬆ 승급권';

  @override
  String get leaguesZoneDemotion => '⬇ 강등권';

  @override
  String profileAchievementsSummary(int unlocked, int total) {
    return '$total개 중 $unlocked개 잠금 해제 · 실제 진행률';
  }

  @override
  String get profileRealStateNote =>
      '레벨, XP, 레슨, 스트릭, 저장한 단어는 실제 엔진 상태예요 — 새 계정에서는 0부터 시작해요.';

  @override
  String get practiceTitle => '연습';

  @override
  String practiceReviewWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '단어 $count개 복습',
    );
    return '$_temp0';
  }

  @override
  String get practiceYourWords => '내 단어';

  @override
  String practiceSavedWordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '저장한 단어 $count개',
    );
    return '$_temp0';
  }

  @override
  String practiceDueForReview(int count) {
    return '$count개가 간격 복습 예정';
  }

  @override
  String get practiceAllUpToDate => '모든 복습 완료';

  @override
  String practiceCaughtUp(String tail) {
    return '모두 끝났어요 — 지금은 복습할 것이 없어요$tail.';
  }

  @override
  String practiceNextTail(String when) {
    return ' · 다음 $when';
  }

  @override
  String get practiceZeroDue => '0개 예정';

  @override
  String get practiceDueNow => '지금 복습';

  @override
  String practiceDueWhen(String when) {
    return '복습 $when';
  }

  @override
  String get practiceChipDue => '예정';

  @override
  String get practiceChipScheduled => '예약됨';

  @override
  String get practiceScheduleNote =>
      '복습은 실제 FSRS-6 간격 반복 엔진이 예약해요. 기한은 이번 세션 동안 유지되며, 재시작 간 저장은 출시 단계예요 — 여기에 꾸며낸 것은 없어요.';

  @override
  String get practiceNoSavedWords => '아직 저장한 단어가 없어요';

  @override
  String get practiceSaveWordHint =>
      '레슨을 연습하며 단어를 저장하면 여기 플래시카드로 나타나요. 이후 실제 FSRS 간격 반복 엔진이 복습을 예약해요 — 미리 채워진 것은 없어요.';

  @override
  String get practiceStartLesson => '레슨 시작하기';

  @override
  String practiceWordOf(int n, int total) {
    return '단어 $n/$total';
  }

  @override
  String get practiceShowAnswer => '정답 보기';

  @override
  String get practiceRecallHint => '뜻을 떠올린 뒤 얼마나 잘 기억했는지 평가하세요.';

  @override
  String get practiceGradeAgain => '다시';

  @override
  String get practiceGradeHard => '어려움';

  @override
  String get practiceGradeGood => '좋음';

  @override
  String get practiceGradeEasy => '쉬움';

  @override
  String get practiceFsrsGradeNote => 'FSRS-6가 평가에 따라 다음 복습을 예약해요';

  @override
  String get practiceReviewComplete => '복습 완료';

  @override
  String practiceReviewedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '단어 $count개를 복습했어요. FSRS가 다시 예약했어요.',
    );
    return '$_temp0';
  }

  @override
  String get practiceDone => '완료';

  @override
  String get practiceRelTomorrow => '내일';

  @override
  String practiceRelInDays(int days) {
    return '$days일 후';
  }

  @override
  String practiceRelInHours(int hours) {
    return '$hours시간 후';
  }

  @override
  String practiceRelInMinutes(int minutes) {
    return '$minutes분 후';
  }

  @override
  String get practiceRelSoon => '곧';

  @override
  String get progressTitle => '진행 상황';

  @override
  String get progressShareMilestone => '이정표 공유';

  @override
  String get progressLast7Days => '최근 7일';

  @override
  String get progressAccuracyRetention => '정확도와 기억 유지';

  @override
  String get progressHonestyNote =>
      '여기 있는 모든 것은 실제 기록된 상태예요 — 레벨, 능력, 저장한 단어, XP, 레슨, 스트릭, 7일 기록, 정확도, 학습 시간이 0에서 시작해 배울수록 늘어나요. 기억 유지는 이번 세션의 예측 회상이에요(세션 간 스케줄러는 출시 작업). 꾸며낸 것은 없어요.';

  @override
  String progressShareText(
    String level,
    String levelName,
    int streak,
    int xp,
    int lessons,
  ) {
    return '🦡 RATEL · 레벨 $level($levelName)\n🔥 $streak일 스트릭 · ⚡ $xp XP · 📘 레슨 $lessons개\nlearnwithratel.com에서 학습 중';
  }

  @override
  String get progressShareCopied => '이정표를 클립보드에 복사했어요 — 어디서든 공유하세요!';

  @override
  String progressAbilityLine(String theta) {
    return '능력 θ $theta · 실제 추정';
  }

  @override
  String get progressStatSavedWords => '저장한 단어';

  @override
  String get progressStatLessons => '레슨';

  @override
  String get progressStatDayStreak => '스트릭 일수';

  @override
  String get progressStatTotalXp => '총 XP';

  @override
  String get progressStatTodaysXp => '오늘 XP';

  @override
  String get progressStatCefrLevel => 'CEFR 레벨';

  @override
  String get progressAccuracy => '정확도';

  @override
  String get progressStudyTime => '학습 시간';

  @override
  String get progressRetention => '기억 유지';

  @override
  String get progressNoData => '아직 데이터 없음';

  @override
  String get progressAccuracyEmpty => '채점되는 문제에 답하면 시작돼요';

  @override
  String progressAccuracyDetail(int correct, int total) {
    return '$total개 중 $correct개 정답';
  }

  @override
  String get progressTimeEmpty => '레슨 시간이 여기에 쌓여요';

  @override
  String get progressTimeDetail => '모든 레슨 합계';

  @override
  String get progressRetentionEmpty => '복습하면 예측 회상이 표시돼요';

  @override
  String progressRetentionDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '1일 예측 회상 · 이번 세션 $count개 항목',
    );
    return '$_temp0';
  }

  @override
  String progressWeekTotal(int xp) {
    return '$xp XP · 최근 7일';
  }

  @override
  String get progressNoXpYet => '아직 기록된 XP가 없어요';

  @override
  String get progressChartEmptyNote =>
      '레슨을 마치면 7일 기록이 시작돼요 — 활동 없는 날은 0으로 유지되고, 꾸며낸 것은 없어요.';

  @override
  String get commonDowMon => '월';

  @override
  String get commonDowTue => '화';

  @override
  String get commonDowWed => '수';

  @override
  String get commonDowThu => '목';

  @override
  String get commonDowFri => '금';

  @override
  String get commonDowSat => '토';

  @override
  String get commonDowSun => '일';
}
