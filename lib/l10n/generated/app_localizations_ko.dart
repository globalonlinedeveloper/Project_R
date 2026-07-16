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
  String homeSectionN(int n) {
    return '섹션 $n';
  }

  @override
  String homeSectionLevel(int n, String band) {
    return '섹션 $n · 레벨 $band';
  }

  @override
  String homeLevelBand(String band) {
    return '레벨 $band';
  }

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
  String get lessonExplainThis => '💡 설명 보기';

  @override
  String get lessonMatchPairs => '짝을 맞추세요';

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
  String get onboardingLanguageSubtitle => '10개 언어로 영어를 배우세요';

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
  String get langNameEnglish => '영어';

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
      '나머지 전부 — 오디오, 복습, 리그, 롤플레이, 기기 내 발음 — 는 모두에게 무료예요.';

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
  String get paywallRegionsTier1 => '미국, EU, 일본, 호주';

  @override
  String get paywallRegionsMid => '라틴 아메리카, 동남아시아, 동유럽';

  @override
  String get paywallRegionsLowPpp => '인도, 파키스탄, 나이지리아, 방글라데시';

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
  String get notifBodyLevel4 => '고급(C1) — 영어 실력이 탄탄해요.';

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
  String get progressYourLevel => 'YOUR LEVEL';

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

  @override
  String get searchTitle => '검색';

  @override
  String get searchHint => '레슨, 단어, 이야기 검색…';

  @override
  String get searchRecent => '최근';

  @override
  String get searchClear => '지우기';

  @override
  String get searchJumpTo => '바로 가기';

  @override
  String get searchTagPage => '페이지';

  @override
  String get searchTagWord => '단어';

  @override
  String get searchSubtitleSavedWord => '저장한 단어';

  @override
  String searchLessonSubtitle(String unit) {
    return '$unit · 레슨';
  }

  @override
  String searchNoMatches(String query) {
    return '“$query”에 대한 결과가 없어요';
  }

  @override
  String get searchEmptyNote =>
      '코스, 저장한 단어, 페이지의 제목·태그·레슨 내용을 검색해요. 서버 콘텐츠 색인과 인기 검색은 R-L12 후속 작업이에요 — 여기에 가짜는 없어요.';

  @override
  String get searchNoMatchNote =>
      '게시된 레슨, 저장한 단어, 앱 페이지(제목 + 태그)를 검색해요. 이야기/팟캐스트와 전문 검색은 R-L12 후속 작업이에요 — 절대 꾸며내지 않아요.';

  @override
  String get searchFooterNote =>
      '출시 시점엔 제목 + 태그. 전문, 이야기/팟캐스트, 다중 코스는 R-L12 후속 작업이에요 — 절대 꾸며내지 않아요.';

  @override
  String get searchDestPracticeHub => '연습 허브';

  @override
  String get searchDestPracticeHubSub => '실수, 약한 단어, 드릴';

  @override
  String get searchDestAiTutor => 'AI 튜터';

  @override
  String get searchDestAiTutorSub => '말하기, 채팅, 롤플레이';

  @override
  String get searchDestAdventures => '어드벤처';

  @override
  String get searchDestAdventuresSub => '실제 대화 — 무료';

  @override
  String get searchDestLeagues => '리그';

  @override
  String get searchDestLeaguesSub => '나의 주간 리그';

  @override
  String get searchDestQuests => '퀘스트';

  @override
  String get searchDestQuestsSub => '일일 목표와 퀘스트';

  @override
  String get searchDestProgress => '진행 상황';

  @override
  String get searchDestProgressSub => '나의 통계와 스트릭';

  @override
  String get searchDestProfile => '프로필';

  @override
  String get searchDestProfileSub => '나의 프로필';

  @override
  String get searchDestSettings => '설정';

  @override
  String get searchDestSettingsSub => '계정과 환경설정';

  @override
  String get searchDestShop => '상점';

  @override
  String get searchDestShopSub => '다이아몬드 사용하기';

  @override
  String get searchDestNotifications => '알림';

  @override
  String get searchDestNotificationsSub => '나의 이정표 수신함';

  @override
  String get themesTitle => '테마';

  @override
  String get themesSubtitle => '앱 전체 스타일을 바꿔요 — 탭하면 실시간 미리보기';

  @override
  String themesVehicle(String vehicle) {
    return '탈것 · $vehicle';
  }

  @override
  String get tutorHeader => '실제 대화를 연습하세요';

  @override
  String get tutorHeaderSub => '장면을 골라 Ratel과 채팅하세요 — 틀린 답은 없고, 연습만 있어요.';

  @override
  String get tutorTalkTitle => 'Ratel과 통화하기';

  @override
  String get tutorTalkSub => '실시간 음성·영상 말하기 연습';

  @override
  String get tutorChatTitle => 'Ratel과 채팅하기';

  @override
  String get tutorChatSub => 'AI 채팅 · 글쓰기 피드백';

  @override
  String get tutorRoleplayTitle => '롤플레이 장면';

  @override
  String get tutorRoleplayGuided => '가이드형 롤플레이 대화';

  @override
  String tutorScenesCount(int count) {
    return '장면 $count개';
  }

  @override
  String get tutorUnlockPro => 'RATEL PRO 잠금 해제';

  @override
  String get tutorRelayNote =>
      '실시간 AI 튜터링은 검열되고 비용이 관리되는 릴레이에서 동작하는 RATEL PRO 기능이에요. 답변은 절대 시뮬레이션이 아니에요 — PRO와 릴레이가 모두 활성일 때만 모드가 시작돼요.';

  @override
  String get tutorStatusReadyPro => 'PRO 활성 상태이고 실시간 튜터가 연결됐어요 — 모드를 골라 시작하세요.';

  @override
  String get tutorStatusReadyFree => '실시간 튜터가 연결됐어요. 실시간 튜터링은 RATEL PRO 기능이에요.';

  @override
  String get tutorStatusOffline =>
      '이 빌드에서는 검열형 실시간 튜터가 아직 연결되지 않았어요 — 실시간 튜터링은 이후 단계에서 켜져요. 아래 어떤 것도 시뮬레이션이 아니에요.';

  @override
  String get tutorAnnounceNeedsPro => 'RATEL PRO가 실시간 AI 튜터링을 잠금 해제해요.';

  @override
  String get tutorAnnounceNeedsRelay => '검열형 릴레이가 활성화되면 AI 튜터링이 연결돼요.';

  @override
  String get tutorAnnounceStarting => '세션을 시작하는 중…';

  @override
  String get adventuresTitle => '어드벤처';

  @override
  String get adventuresFreeChip => '무료';

  @override
  String get adventuresHeaderSub => '세계를 탐험 · 대화로 헤쳐 나가요';

  @override
  String get adventuresHeroTitle => '장소를 골라 뛰어들어 보세요';

  @override
  String get adventuresHeroSub => '모든 장면은 진짜 대화예요 — 오답도 없고, 언제나 무료입니다.';

  @override
  String get adventuresFallbackWorld => '어드벤처';

  @override
  String adventureSheetKicker(String cefr) {
    return '🗺️ 어드벤처 · $cefr';
  }

  @override
  String adventureScenesCount(int count) {
    return '장면 $count개';
  }

  @override
  String adventureChoicePoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '선택 지점 $count개',
    );
    return '$_temp0';
  }

  @override
  String get adventureOpeningScene => '오프닝 장면';

  @override
  String get adventureStart => '어드벤처 시작';

  @override
  String get adventurePlayerFallbackTitle => '어드벤처';

  @override
  String get adventureTheEnd => '🏁 끝';

  @override
  String get adventureStartOver => '다시 시작';

  @override
  String get adventureDone => '완료';

  @override
  String get adventureCompleteKicker => '어드벤처 완료';

  @override
  String adventureCompleteTitle(String title) {
    return '$title ✓';
  }

  @override
  String get adventureCompleteBody =>
      '잘했어요! +15 XP · +5 💎 획득 — 다음 장면은 언제든 탐험해 보세요.';

  @override
  String adventureDistrictProgress(int done, int total) {
    return '$done/$total 탐험 완료';
  }

  @override
  String get adventureDistrictDone => '✓ 완료';

  @override
  String get adventureDistrictCafe => 'Café & Food';

  @override
  String get adventureDistrictMarket => 'Market Square';

  @override
  String get adventureDistrictMove => 'On the Move';

  @override
  String get adventureDistrictFriends => 'Making Friends';

  @override
  String get adventuresEmpty => '이 코스에는 아직 어드벤처가 없어요.';

  @override
  String get authWelcomeTitle => 'Ratel에 오신 것을 환영해요';

  @override
  String get authWelcomeSubtitle => '레슨, 이야기, 팟캐스트 등 —\n시작 방법을 골라보세요.';

  @override
  String get authCreateFreeAccount => '무료 계정 만들기';

  @override
  String get authAlreadyHaveAccount => '계정이 이미 있어요';

  @override
  String get authSettingUp => '준비하는 중…';

  @override
  String get authContinueAsGuest => '게스트로 계속하기';

  @override
  String get authGuestNote =>
      '게스트 진행 상황은 이 기기에 저장돼요 — 어디서나 이어가려면 설정에서 언제든 무료 계정을 만드세요.';

  @override
  String get authEnterYourEmail => '이메일을 입력하세요';

  @override
  String get authEnterValidEmail => '올바른 이메일을 입력하세요';

  @override
  String get authEnterYourPassword => '비밀번호를 입력하세요';

  @override
  String get authCouldNotSignIn => '로그인하지 못했어요. 다시 시도하세요.';

  @override
  String get authSomethingWentWrong => '문제가 발생했어요. 다시 시도하세요.';

  @override
  String get authSocialComingSoon => 'Google / Apple 로그인은 곧 제공돼요.';

  @override
  String get authResetTitle => '비밀번호 재설정';

  @override
  String get authWelcomeBack => '다시 만나서 반가워요!';

  @override
  String get authResetSubtitle => '이메일을 입력하면 재설정 링크를 보내드려요.';

  @override
  String get authPickUpWhereYouLeft => '멈춘 곳에서 이어가기';

  @override
  String get authEmailHint => '이메일';

  @override
  String get authPasswordHint => '비밀번호';

  @override
  String get authForgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get authSendResetLink => '재설정 링크 보내기';

  @override
  String get authLogIn => '로그인';

  @override
  String get authBackToLogIn => '로그인으로 돌아가기';

  @override
  String get authNewToRatel => 'Ratel이 처음인가요? ';

  @override
  String get authSignUp => '가입하기';

  @override
  String get authCheckYourInbox => '받은편지함을 확인하세요';

  @override
  String authResetSent(String email) {
    return '$email로 비밀번호 재설정 링크를 보냈어요. 열어서 새 비밀번호를 정하세요.';
  }

  @override
  String get authCreatePassword => '비밀번호를 만드세요';

  @override
  String get authAtLeast8Chars => '8자 이상';

  @override
  String get authCreateYourAccount => '계정을 만드세요';

  @override
  String get authSignupSubtitle => '영원히 무료 · 10개 언어로 영어 학습';

  @override
  String get authPassword8Hint => '비밀번호(8자 이상)';

  @override
  String get authCreateAccount => '계정 만들기';

  @override
  String get authAlreadyAccountLead => '계정이 이미 있나요? ';

  @override
  String get authSignIn => '로그인';

  @override
  String get authConfirmEmail => '이메일을 확인하세요';

  @override
  String authConfirmSent(String email) {
    return '$email로 확인 링크를 보냈어요. 눌러서 계정을 활성화한 뒤 돌아와 로그인하세요.';
  }

  @override
  String get authContinueGoogle => 'Google로 계속하기';

  @override
  String get authContinueApple => 'Apple로 계속하기';

  @override
  String get authOr => '또는';

  @override
  String get authUnavailableNote =>
      '이 빌드에서는 아직 계정을 쓸 수 없어요 — 게스트로 계속 배울 수 있어요. 백엔드가 구성되면 로그인이 켜져요.';

  @override
  String get liveMute => '음소거';

  @override
  String get liveUnmute => '음소거 해제';

  @override
  String commonDurSeconds(int s) {
    return '$s초';
  }

  @override
  String commonDurMinutes(int m) {
    return '$m분';
  }

  @override
  String commonDurHours(int h) {
    return '$h시간';
  }

  @override
  String commonDurHoursMinutes(int h, int m) {
    return '$h시간 $m분';
  }

  @override
  String practiceGradeInterval(String label, int days) {
    return '$label · $days일';
  }

  @override
  String settingsGoalPerDay(int goal) {
    return '하루 $goal XP';
  }

  @override
  String settingsGoalReachedSub(int goal) {
    return '하루 $goal XP · ✓ 오늘 달성';
  }

  @override
  String get settingsSoundEffects => '효과음';

  @override
  String get settingsHaptics => '진동';

  @override
  String get settingsProActive => 'RATEL PRO 활성';

  @override
  String get settingsFreePlan => '무료 플랜';

  @override
  String get settingsReduceMotion => '모션 줄이기';

  @override
  String get settingsReduceMotionSub => '마스터 스위치 — 모든 애니메이션을 꺼요';

  @override
  String get settingsHighContrast => '고대비';

  @override
  String get settingsNotifPush => '푸시 알림';

  @override
  String get settingsNotifStreak => '스트릭 리마인더';

  @override
  String get settingsNotifLeague => '리그 업데이트';

  @override
  String get settingsNotifFriend => '친구 활동';

  @override
  String get settingsNotifFootnote => '선택은 지금 저장돼요 — 푸시 알림이 출시되면 전송이 켜져요.';

  @override
  String get settingsCourse => '코스';

  @override
  String get settingsTheme => '테마';

  @override
  String get settingsWorld => '월드';

  @override
  String get settingsEditProfile => '프로필 편집';

  @override
  String get settingsPrivacy => '개인정보 및 데이터';

  @override
  String get settingsHelp => '도움말 및 지원';

  @override
  String get settingsLogOut => '로그아웃';

  @override
  String get settingsGuestSub => '게스트로 학습 중이에요 — 진행 상황을 저장하려면 가입하세요';

  @override
  String settingsCouldNotOpen(String url) {
    return '$url을(를) 열 수 없어요';
  }

  @override
  String get settingsThemeSystem => '기기에 맞춤';

  @override
  String get settingsThemeLight => '라이트';

  @override
  String get settingsThemeDark => '다크';

  @override
  String get mediaReadAloud => '소리 내어 읽기';

  @override
  String get mediaTranscript => '스크립트';

  @override
  String get mediaCheckUnderstanding => '이해도 확인';

  @override
  String mediaChecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '이해도 확인 $count개',
      one: '이해도 확인 $count개',
    );
    return '$_temp0';
  }

  @override
  String get mediaLoading => '불러오는 중…';

  @override
  String get mediaPause => '일시정지';

  @override
  String get storiesTitle => '스토리';

  @override
  String get storiesSub => '읽고 듣기 — 브라우저 소리 내어 읽기가 있는 단계별 스토리.';

  @override
  String get storiesEmpty => '이 코스에는 아직 스토리가 없어요.';

  @override
  String get storyFallbackTitle => '스토리';

  @override
  String get podcastsSub => '듣기 — 실제 오디오와 스크립트가 있는 단계별 팟캐스트.';

  @override
  String get podcastsEmpty => '이 코스에는 아직 팟캐스트가 없어요.';

  @override
  String get podcastFallbackTitle => '팟캐스트';

  @override
  String get podcastPlayEpisode => '에피소드 재생';

  @override
  String get watchSub => '시청 — 스크립트와 이해도 확인이 있는 짧은 클립.';

  @override
  String get watchEmpty => '이 코스에는 아직 시청 레슨이 없어요.';

  @override
  String get watchWebOnly => '동영상은 웹 앱에서 재생돼요';

  @override
  String get libraryAdventuresSub => '살아 있는 세계를 거닐며 실제 장면을 대화로 헤쳐 나가요.';

  @override
  String get roleplaySub => '실제 대화 연습 — 알맞은 답을 골라 즉시 피드백을 받아요.';

  @override
  String get roleplayEmpty => '이 코스에는 아직 롤플레이가 없어요.';

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
  String get roleplayYourReply => '내 답변:';

  @override
  String get roleplaySceneComplete => '🎉 장면 완료!';

  @override
  String get roleplayBack => '롤플레이로 돌아가기';

  @override
  String get liveRoleplayTitle => '실시간 롤플레이';

  @override
  String get liveRoleplayCardSub => 'Ratel과 대화로 풀어봐요 — 실제 음성';

  @override
  String get liveIntro =>
      'Ratel과 대화로 풀어봐요 — 실시간 음성 롤플레이. 장면을 고르거나, 그냥 대화해 보세요.';

  @override
  String get liveFreeConversation => '자유 대화';

  @override
  String get liveFreeConversationSub => '대본 없이 — 그냥 이야기해요';

  @override
  String get liveRoleplayScene => '장면 롤플레이';

  @override
  String get liveReconnecting => '재연결 중…';

  @override
  String get liveConnectionLost => '연결이 끊겼어요 — 실시간 세션이 종료됐어요.';

  @override
  String get liveReconnect => '재연결';

  @override
  String get liveConnecting => '연결 중…';

  @override
  String get liveStartTalking => '말하기 시작';

  @override
  String get liveSceneEndedNote =>
      '장면이 끝났어요. 언제든 다시 시작하세요 — 실시간 시간은 관리되며, 절대 조용히 흐르지 않아요.';

  @override
  String get liveStartAgain => '다시 시작';

  @override
  String get liveProGate =>
      '실시간 음성 롤플레이는 RATEL PRO 기능이에요 — 실제 대화, 실시간 피드백, 비용이 관리되는 시간.';

  @override
  String get liveUnlockPro => 'RATEL PRO 잠금 해제';

  @override
  String get liveNotEnabled =>
      '실시간 음성은 이 빌드에서 아직 활성화되지 않았어요 — 이후 단계에서 켜져요. 여기 어떤 것도 시뮬레이션이 아니에요.';

  @override
  String get livePhaseIdle => '준비되면 시작하세요 — 진짜 실시간 통화예요.';

  @override
  String get livePhaseListening => '듣는 중 — 당신 차례예요.';

  @override
  String get livePhaseSpeaking => 'Ratel이 말하는 중 — 언제든 끼어드세요.';

  @override
  String get livePhaseClosed => '장면이 끝났어요.';

  @override
  String get liveEndScene => '장면 종료';

  @override
  String get liveYou => '나';

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
  String get liveStartFailed => '실시간 세션을 시작할 수 없어요 — 다시 시도하세요.';

  @override
  String get friendsHandleInvalid => '@mia 같은 핸들을 입력하세요 (2–20자, 글자·숫자·_).';

  @override
  String friendsAlreadyConnected(String handle) {
    return '이미 @$handle님과 연결되어 있어요.';
  }

  @override
  String get friendsRequests => '요청';

  @override
  String get friendsYourFriends => '내 친구';

  @override
  String get friendsPending => '대기 중';

  @override
  String get friendsActivity => '친구 활동';

  @override
  String get friendsFootnote =>
      '당신의 소셜 그래프는 실제이며 당신만 볼 수 있어요. 친구 요청 전송과 \"나를 앞질렀어요\" 표시는 지속형 사용자 간 그래프가 활성화되면 이루어져요 — 다른 모든 지속형 카운터와 동일한 출시 단계예요. 여기 가짜는 없어요.';

  @override
  String get friendsAddHint => '@핸들로 친구 추가…';

  @override
  String get friendsAccept => '수락';

  @override
  String friendsXpThisWeek(String handle, String xp) {
    return '@$handle · 이번 주 $xp XP';
  }

  @override
  String get friendsPassedYou => '나를 앞질렀어요';

  @override
  String get friendsRemove => '삭제';

  @override
  String get friendsBlock => '차단';

  @override
  String get friendsReportBlock => '신고 및 차단';

  @override
  String get friendsRequestSent => '요청을 보냈어요';

  @override
  String get friendsEmptyTitle => '아직 친구가 없어요';

  @override
  String get friendsEmptyBody => '@핸들로 누군가를 추가해 진행 상황을 공유해 보세요.';

  @override
  String get profileLearner => '학습자';

  @override
  String get profileGuest => '게스트';

  @override
  String get editProfileSaved => '프로필을 저장했어요';

  @override
  String get editProfileHandleSet => '저장됨 — @핸들이 설정됐어요.';

  @override
  String get editProfileSignInForHandle => '이름을 저장했어요. @핸들을 등록하려면 로그인하세요.';

  @override
  String get editProfileHandleFailed => '그 @핸들을 설정할 수 없어요.';

  @override
  String get editProfileDisplayName => '표시 이름';

  @override
  String get editProfileNameHint => '어떻게 불러드릴까요?';

  @override
  String get editProfileNameNote => '프로필에 표시돼요. 이 기기에 저장되며 — 로그인하면 계정에 동기화돼요.';

  @override
  String get editProfileHandle => '내 @핸들';

  @override
  String get editProfileHandleNote =>
      '다른 학습자가 @핸들로 당신을 추가해요 (2–20자, 글자·숫자 또는 _). 등록하려면 로그인이 필요해요.';

  @override
  String get commonSave => '저장';

  @override
  String get commonCancel => '취소';

  @override
  String get feedIsNowYourFriend => '님이 이제 친구예요';

  @override
  String feedReachedLevel(String level) {
    return '$level 도달';
  }

  @override
  String feedDayStreak(int count) {
    return '$count일 스트릭';
  }

  @override
  String get feedPassedYou => '리그에서 나를 앞질렀어요';

  @override
  String get leaguesSoloCaption => '이번 주 · 솔로 그룹';

  @override
  String leaguesXpToRank(int xp, int rank) {
    return '$rank위까지 $xp XP';
  }

  @override
  String get leaguesLeading => '그룹 선두';

  @override
  String get leaguesSoloNote =>
      '이번 주에는 당신이 그룹의 유일한 학습자예요. Ratel이 성장하면 진짜 경쟁자가 합류해요 — 봇도, 가짜 리더보드도 없어요. 주가 초기화될 때 오를 수 있도록 계속 XP를 모으세요.';

  @override
  String questsGoalLine(int today, int goal) {
    return '$today / $goal XP · 목표 달성';
  }

  @override
  String questsGoalRemaining(int today, int goal, int remaining) {
    return '$today / $goal XP · $remaining XP 남음';
  }

  @override
  String get worldLabelLight => '한낮';

  @override
  String get worldVehicleLight => '스쿠터';

  @override
  String get worldLabelGalaxy => '우주';

  @override
  String get worldVehicleGalaxy => '별 포드';

  @override
  String get worldLabelSavanna => '사바나';

  @override
  String get worldVehicleSavanna => '사파리 지프';

  @override
  String get worldLabelOcean => '바다';

  @override
  String get worldVehicleOcean => '잠수함';

  @override
  String get worldLabelForest => '숲';

  @override
  String get worldVehicleForest => '잎사귀 글라이더';

  @override
  String get worldLabelCandy => '사탕';

  @override
  String get worldVehicleCandy => '풍선';

  @override
  String get worldLabelNeon => '네온 시티';

  @override
  String get worldVehicleNeon => '호버바이크';

  @override
  String get worldLabelStorm => '폭풍우';

  @override
  String get worldVehicleStorm => '폭풍 글라이더';

  @override
  String get worldLabelSnow => '겨울';

  @override
  String get worldVehicleSnow => '눈썰매';

  @override
  String get worldLabelSakura => '벚꽃';

  @override
  String get worldVehicleSakura => '꽃잎 연';

  @override
  String get worldLabelAutumn => '가을';

  @override
  String get worldVehicleAutumn => '낙엽 수레';

  @override
  String get worldLabelAurora => '오로라';

  @override
  String get worldVehicleAurora => '오로라 나룻배';

  @override
  String get worldLabelVolcano => '화산';

  @override
  String get worldVehicleVolcano => '마그마 보드';

  @override
  String get worldLabelSunset => '노을';

  @override
  String get worldVehicleSunset => '글라이더';

  @override
  String get worldLabelDesert => '사막';

  @override
  String get worldVehicleDesert => '사막 버기';

  @override
  String get worldLabelReef => '산호초';

  @override
  String get worldVehicleReef => '유리 보트';

  @override
  String get worldLabelMeadow => '초원';

  @override
  String get worldVehicleMeadow => '자전거';

  @override
  String get worldLabelDawn => '새벽';

  @override
  String get worldVehicleDawn => '하늘 풍선';

  @override
  String get worldLabelBeach => '열대 해변';

  @override
  String get worldVehicleBeach => '쌍동선';

  @override
  String get worldLabelMars => '화성';

  @override
  String get worldVehicleMars => '탐사차';

  @override
  String get worldLabelJungle => '열대우림';

  @override
  String get worldVehicleJungle => '짚라인';

  @override
  String get worldLabelCyberrain => '사이버 레인';

  @override
  String get worldVehicleCyberrain => '호버바이크';

  @override
  String get worldLabelAbyss => '심해';

  @override
  String get worldVehicleAbyss => '심해정';

  @override
  String get worldLabelAlpine => '알프스';

  @override
  String get worldVehicleAlpine => '케이블카';

  @override
  String get worldLabelLavender => '라벤더';

  @override
  String get worldVehicleLavender => '베스파';

  @override
  String get worldLabelBamboo => '대나무 숲';

  @override
  String get worldVehicleBamboo => '인력거';

  @override
  String get worldLabelLagoon => '석호의 밤';

  @override
  String get worldVehicleLagoon => '카약';

  @override
  String get worldLabelThunder => '천둥 구름';

  @override
  String get worldVehicleThunder => '폭풍 추격자';

  @override
  String get worldLabelNebula => '성운';

  @override
  String get worldVehicleNebula => '별 크루저';

  @override
  String get worldLabelSandstorm => '모래폭풍';

  @override
  String get worldVehicleSandstorm => '카라반';

  @override
  String get worldLabelCherrynight => '벚꽃의 밤';

  @override
  String get worldVehicleCherrynight => '종이 등불';

  @override
  String get shopYourBadger => '내 오소리';

  @override
  String get shopDiamondsNote =>
      '실제 결제로 💎를 충전하는 기능이 곧 나와요. 다이아몬드는 레슨을 끝내고 일일 목표를 달성하면 얻으며, 여기 모든 파워업은 실제로 다이아몬드를 사용해요 — 가짜는 없어요.';

  @override
  String get shopProBannerSub => '실시간 AI, 광고 없음, 오프라인 · 7일 무료 체험';

  @override
  String get shopYourDiamonds => '내 다이아몬드';

  @override
  String get shopEquipped => '착용 중';

  @override
  String get shopEquip => '착용';

  @override
  String shopEquippedSnack(String name, String emoji) {
    return '$name $emoji 착용 완료';
  }

  @override
  String get shopFree => '무료';

  @override
  String get outfitClassic => '클래식';

  @override
  String get outfitScholar => '학자';

  @override
  String get outfitExplorer => '탐험가';

  @override
  String get outfitAstronaut => '우주비행사';

  @override
  String get outfitWizard => '마법사';

  @override
  String paywallAnnualLine(String annual, String perMonth) {
    return '연 $annual  ·  월 $perMonth  ·  7일 무료';
  }

  @override
  String paywallMonthlyLine(String monthly) {
    return '월 $monthly  ·  매월 청구';
  }

  @override
  String paywallSavePercent(int percent) {
    return '$percent% 할인';
  }

  @override
  String get paywallIncluded => 'Pro에 포함된 항목';

  @override
  String get paywallTerms => '약관';

  @override
  String get paywallPrivacy => '개인정보';

  @override
  String get paywallNothingToRestore =>
      '복원할 항목이 없어요 — 이 빌드에서는 결제가 아직 활성화되지 않았어요.';

  @override
  String get contentUnavailableTitle => '콘텐츠를 사용할 수 없어요';

  @override
  String contentUnavailableBody(String noun) {
    return '이 $noun은(는) 지금 사용할 수 없어요. 오프라인 상태라면 연결을 확인하고 다시 시도하세요.';
  }

  @override
  String get contentNounStory => '스토리';

  @override
  String get contentNounPodcast => '팟캐스트';

  @override
  String get contentNounVideo => '동영상';

  @override
  String get contentNounAdventure => '어드벤처';

  @override
  String get contentNounRoleplay => '롤플레이';

  @override
  String get commonGoBack => '돌아가기';

  @override
  String get placementTitle => '레벨 테스트';

  @override
  String placementQuestionN(int n) {
    return '질문 $n';
  }

  @override
  String get placementResultTitle => '나의 시작 지점';

  @override
  String placementResultBody(int count, String level) {
    return '$count개의 질문을 바탕으로 $level에 배치했어요. 나중에 언제든 조정할 수 있어요.';
  }

  @override
  String get lessonTypedNote => '목표 언어로 답을 입력하세요.';

  @override
  String lessonHintMinWords(int count) {
    return '최소 $count단어';
  }

  @override
  String lessonHintUseWords(String words) {
    return '사용: $words';
  }

  @override
  String get lessonHintEndPunct => '. ! 또는 ?로 끝내기';

  @override
  String get lessonPlayAudio => '오디오 재생';

  @override
  String get lessonPlaySlowly => '천천히 재생';

  @override
  String get lessonAudioUnavailable => '오디오를 사용할 수 없어요 — 문제를 읽으세요.';

  @override
  String get lessonPlaybackSpeed => '재생 속도';

  @override
  String get authAccountsUnavailable =>
      '이 빌드에서는 계정 기능을 아직 이용할 수 없어요 — 게스트로 계속 학습하세요.';

  @override
  String get liveNotEnabledShort => '이 빌드에서는 실시간 AI가 활성화되지 않았어요.';

  @override
  String get liveMicUnavailable => '마이크를 사용할 수 없어요 — 튜터와 대화하려면 마이크 접근을 허용하세요.';

  @override
  String get liveUnavailable => '지금은 실시간 AI를 이용할 수 없어요.';

  @override
  String get liveNeedsPro => '실시간 AI는 RATEL PRO 기능이에요.';

  @override
  String get liveMinutesUsed => '이번 달 실시간 이용 시간을 모두 사용했어요.';

  @override
  String get commonNetworkError => '서버에 연결할 수 없어요. 다시 시도하세요.';

  @override
  String get friendsHandleTaken => '그 @핸들은 이미 사용 중이에요.';

  @override
  String get friendsHandleFormat => '핸들은 2–20자의 글자·숫자·_만 사용하세요.';

  @override
  String get friendsSignInForHandle => '@핸들을 등록하려면 로그인하세요.';

  @override
  String get friendsSetOwnHandleFirst => '먼저 내 @핸들을 설정하세요 (프로필 편집).';

  @override
  String get paywallCheckoutUnavailable =>
      '결제는 출시 시 열려요 — 이 빌드에서는 스토어 결제가 아직 활성화되지 않았어요.';

  @override
  String get settingsManageUnavailable =>
      '기기의 구독 설정에서 관리하거나 해지하세요 — 앱 내 바로가기는 출시 시 열려요.';

  @override
  String get friendsAdd => '추가';

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
}
