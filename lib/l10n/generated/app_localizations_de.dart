// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get navHome => 'Start';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navLeagues => 'Ligen';

  @override
  String get navQuests => 'Quests';

  @override
  String get navProfile => 'Profil';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionLearning => 'Lernen';

  @override
  String get settingsSectionSubscription => 'Abo';

  @override
  String get settingsSectionAccessibility => 'Barrierefreiheit';

  @override
  String get settingsSectionNotifications => 'Benachrichtigungen';

  @override
  String get settingsSectionAppearanceAccount => 'Aussehen & Konto';

  @override
  String get settingsAppLanguage => 'App-Sprache';

  @override
  String get settingsAppLanguageSystem => 'Systemstandard';

  @override
  String get homeCourseLoadingTitle => 'Dein Kurs wird vorbereitet';

  @override
  String get homeCourseLoadingBody =>
      'Lektionen erscheinen hier, sobald die Kursinhalte geladen sind.';

  @override
  String get homeGuideChip => 'Guide';

  @override
  String get homeStartNode => 'START';

  @override
  String get homeUnitGuideHeader => 'EINHEITEN-GUIDE';

  @override
  String get commonDone => 'Fertig';

  @override
  String homeUnitKicker(String unit) {
    return 'EINHEIT · $unit';
  }

  @override
  String homeLessonMeta(int num, int count, String exercises) {
    return 'Lektion $num von $count · $exercises.';
  }

  @override
  String homeQuickExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count schnelle Übungen',
      one: '$count schnelle Übung',
    );
    return '$_temp0';
  }

  @override
  String get homeEnergyChip => '−1 ⚡ Energie';

  @override
  String get homeXpChip => '+20 XP';

  @override
  String get homeStartLesson => 'Lektion starten';

  @override
  String get homeTutorChip => 'Tutor';

  @override
  String get libraryAiTutor => 'KI-Tutor';

  @override
  String get libraryAiTutorSub =>
      'Sprechen, chatten & Rollenspiel — Schreib-Feedback';

  @override
  String get libraryRoleplay => 'Rollenspiel';

  @override
  String get libraryRoleplaySub => 'Antworten üben — bewertet, immer kostenlos';

  @override
  String get librarySectionPractice => 'Üben';

  @override
  String get libraryPracticeHub => 'Übungszentrum';

  @override
  String get libraryPracticeHubSub =>
      'Fehler, schwache Wörter & Drills · KOSTENLOS';

  @override
  String get librarySectionReadListen => 'Lesen & Hören';

  @override
  String get libraryGradedStories => 'Abgestufte Geschichten';

  @override
  String get libraryPodcasts => 'Podcasts';

  @override
  String get libraryWatch => 'Ansehen';

  @override
  String get librarySearchHint => 'Lektionen, Wörter, Geschichten suchen…';

  @override
  String get libraryFeaturedStory => 'EMPFOHLEN · GESCHICHTE';

  @override
  String commonLevel(String cefr) {
    return 'Niveau $cefr';
  }

  @override
  String get libraryReadNow => 'Jetzt lesen';

  @override
  String get libraryNewExplore => 'NEU · ENTDECKEN';

  @override
  String get libraryAdventures => 'Abenteuer';

  @override
  String get libraryStartExploring => 'Jetzt entdecken →';

  @override
  String get libraryKindStory => 'Geschichte';

  @override
  String get libraryKindPodcast => 'Podcast';

  @override
  String get libraryKindVideo => 'Video';

  @override
  String get libraryAllStories => 'Alle Geschichten';

  @override
  String get libraryAllPodcasts => 'Alle Podcasts';

  @override
  String get libraryAllVideos => 'Alle Videos';

  @override
  String get lessonTypeWhatYouHear => 'Tippe, was du hörst';

  @override
  String get lessonTapWhatYouHear => 'Wähle, was du hörst';

  @override
  String get lessonTranslateSentence => 'Übersetze diesen Satz';

  @override
  String get lessonTypeAnswerHint => 'Deine Antwort…';

  @override
  String get lessonWriteAnswerHint => 'Schreibe deine Antwort…';

  @override
  String get lessonContinue => 'Weiter';

  @override
  String get lessonSkip => 'Überspringen';

  @override
  String get lessonCheck => 'Prüfen';

  @override
  String get lessonNicelyDone => '✓ Gut gemacht!';

  @override
  String get lessonNotQuite => '✕ Nicht ganz';

  @override
  String lessonAnswerReveal(String answer) {
    return 'Antwort: $answer';
  }

  @override
  String get lessonCompleteKicker => 'LEKTION ABGESCHLOSSEN';

  @override
  String get lessonCompleteTitle => 'Lektion geschafft!';

  @override
  String lessonCompleteSummary(int correct, int graded, String level) {
    return '$correct von $graded richtig · jetzt $level';
  }

  @override
  String get lessonStatTotalXp => 'GESAMT-XP';

  @override
  String get lessonStatAccuracy => 'GENAUIGKEIT';

  @override
  String get lessonStatTime => 'ZEIT';

  @override
  String get onboardingWelcomeTitle => 'Hi, ich bin Ratel!';

  @override
  String get onboardingWelcomeBody =>
      'Lerne eine Sprache ohne Angst — in kleinen Häppchen, mit Spaß und kostenlos. Bereit loszulegen?';

  @override
  String get onboardingHaveAccount => 'Ich habe schon ein Konto';

  @override
  String get onboardingTryWithoutAccount => 'Ohne Konto ausprobieren →';

  @override
  String get onboardingGetStarted => 'Los geht\'s';

  @override
  String get onboardingStartLearning => 'Mit dem Lernen anfangen';

  @override
  String get onboardingLanguageTitle => 'Was möchtest du lernen?';

  @override
  String get onboardingLanguageSubtitle => '52 Sprachen verfügbar';

  @override
  String get onboardingReasonTitle => 'Warum lernst du?';

  @override
  String get onboardingGoalTitle => 'Wähle ein Tagesziel';

  @override
  String get onboardingPlacementTitle => 'Finde deinen Startpunkt';

  @override
  String onboardingPlacementBody(String language) {
    return 'Neu in $language oder kannst du schon etwas?';
  }

  @override
  String get onboardingBrandNew => 'Ich fange ganz neu an';

  @override
  String get onboardingBrandNewSub => 'Ganz von vorn beginnen';

  @override
  String get onboardingPlacementTest => 'Einstufungstest machen';

  @override
  String get onboardingPlacementTestSub => '~3 Min · spring zu deinem Niveau';

  @override
  String onboardingXpPerDay(int xp) {
    return '$xp XP / Tag';
  }

  @override
  String get reasonTravel => 'Reisen';

  @override
  String get reasonCulture => 'Kultur';

  @override
  String get reasonCareer => 'Karriere';

  @override
  String get reasonFamilyFriends => 'Familie & Freunde';

  @override
  String get reasonBrainTraining => 'Gehirntraining';

  @override
  String get reasonJustForFun => 'Nur zum Spaß';

  @override
  String get goalCasual => 'Locker';

  @override
  String get goalRegular => 'Regelmäßig';

  @override
  String get goalSerious => 'Ernsthaft';

  @override
  String get goalIntense => 'Intensiv';

  @override
  String get langNameSpanish => 'Spanisch';

  @override
  String get langNameFrench => 'Französisch';

  @override
  String get langNameJapanese => 'Japanisch';

  @override
  String get langNameTamil => 'Tamil';

  @override
  String get langNameGerman => 'Deutsch';

  @override
  String get langNameKorean => 'Koreanisch';

  @override
  String get settingsDailyGoal => 'Tagesziel';

  @override
  String settingsGoalRow(String label, int xp) {
    return '$label · $xp XP/Tag';
  }

  @override
  String get profileAchievements => 'Erfolge';

  @override
  String get profileFriends => 'Freunde';

  @override
  String get profileShop => 'Shop';

  @override
  String get profileNotifications => 'Benachrichtigungen';

  @override
  String get profileSeeOnboarding => 'Onboarding ansehen ↗';

  @override
  String get profileNotSignedIn => 'Nicht angemeldet';

  @override
  String get profileCreateAccount => 'Kostenloses Konto erstellen';

  @override
  String get profileSaveProgress =>
      'Sichere deinen Fortschritt auf allen Geräten';

  @override
  String profileTodaysGoal(int today, int goal) {
    return 'Tagesziel · $today/$goal XP';
  }

  @override
  String get profileViewProgress => 'Fortschritt ansehen →';

  @override
  String get profileUnlocked => 'Freigeschaltet';

  @override
  String questsResetsIn(int h, int m) {
    return 'Zurücksetzung in ${h}h ${m}min';
  }

  @override
  String get questsDailyRefresh => 'Tägliche Auffrischung';

  @override
  String get questsFreshMix => 'Ein frischer 5-Fragen-Mix';

  @override
  String get questsServedFromQueue =>
      'Aus deiner echten Wiederholungs-Warteschlange — bringt echtes XP.';

  @override
  String get questsGoalReached => 'Tagesziel erreicht! 🎉';

  @override
  String questsReachGoal(int goal) {
    return 'Erreiche heute $goal XP';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return 'Tägliche Quests · $done/$total';
  }

  @override
  String get questsInfoNote =>
      'Quests verfolgen deinen echten Tagesfortschritt. Belohnungstruhen, Freundes-Quests und eine Wochen-Rangliste brauchen eine Backend-Ökonomie — Entscheidung des Eigentümers (§6). Keine falschen Belohnungen.';

  @override
  String get questsStartRefresh => 'Tägliche Auffrischung starten';

  @override
  String get questsStart => 'Start';

  @override
  String get questsPractisedToday => 'Heute geübt — Serie sicher';

  @override
  String get questsEarnAnyXp => 'Verdiene heute beliebiges XP';

  @override
  String questsXpToday(int current, int target) {
    return '$current/$target XP heute';
  }

  @override
  String get leaguesYourGroup => 'DEINE GRUPPE';

  @override
  String leaguesThisWeek(int size) {
    return 'DIESE WOCHE · $size LERNENDE';
  }

  @override
  String get leaguesTiers => 'Liga-Stufen';

  @override
  String leaguesTopClimb(int top, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tagen',
      one: '$days Tag',
    );
    return 'Die Top $top steigen jede Woche auf · endet in $_temp0';
  }

  @override
  String get leaguesDemotionZone => 'Abstiegszone';

  @override
  String get leaguesPromotionZone => 'Aufstiegszone';

  @override
  String get leaguesSafeZone => 'Sichere Zone';

  @override
  String get leaguesYou => 'Du';

  @override
  String leaguesPromoteRelegate(int top, int bottom) {
    return 'Die Top $top steigen auf · die letzten $bottom steigen ab, wenn die Woche endet.';
  }

  @override
  String get leaguesYouAreHere => 'Du bist hier';

  @override
  String get leaguesViewAllTiers => '🏆 Alle 10 Stufen ansehen ›';

  @override
  String get notifMarkAllRead => 'Alle als gelesen markieren';

  @override
  String get notifEmptyTitle => 'Noch keine Benachrichtigungen';

  @override
  String get notifEmptyBody =>
      'Schließe Lektionen ab, baue eine Serie auf und steige auf — deine Meilensteine erscheinen hier, sobald du sie wirklich erreichst.';

  @override
  String get notifPushNote =>
      'Das sind In-App-Meilensteine, angezeigt in dem Moment, in dem du sie erreichst. Push-Benachrichtigungen und Erinnerungen sind Eigentümer-Entscheidung und noch nicht aktiviert — nichts hier ist gefälscht.';
}
