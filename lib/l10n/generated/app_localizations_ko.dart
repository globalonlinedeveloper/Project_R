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
}
