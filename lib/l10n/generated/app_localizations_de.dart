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

  @override
  String get shopPowerUps => 'Power-ups';

  @override
  String get shopStreakFreeze => 'Serien-Schutz';

  @override
  String get shopStreakFreezeDesc =>
      'Schützt deine Serie an einem verpassten Tag. Wird automatisch verbraucht, wenn du dein Tagesziel verfehlst.';

  @override
  String shopOwned(int have, int max) {
    return 'Im Besitz: $have/$max';
  }

  @override
  String get shopMaxedOut => 'Maximum erreicht';

  @override
  String shopBuyFor(int cost) {
    return 'Für $cost 💎 kaufen';
  }

  @override
  String get shopFreezeAdded => 'Serien-Schutz hinzugefügt 💪';

  @override
  String shopFreezeAtCap(int max) {
    return 'Du hast bereits die maximale Anzahl ($max).';
  }

  @override
  String shopNotEnoughEarnCost(int cost) {
    return 'Nicht genug 💎 — verdiene $cost durch Lektionen.';
  }

  @override
  String get shopNotEnoughEarnMore =>
      'Nicht genug 💎 — verdiene mehr durch Lektionen.';

  @override
  String get shopEnergyRefill => 'Energie-Auffüllung';

  @override
  String get shopEnergyRefillDesc =>
      'Fülle deine Energie sofort wieder auf. Energie ist nur Anzeige — Lektionen blockieren nie.';

  @override
  String get shopAlreadyFull => 'Schon voll';

  @override
  String get shopEnergyRefilled => 'Energie aufgefüllt ⚡';

  @override
  String get shopEnergyAlreadyFull => 'Deine Energie ist schon voll.';

  @override
  String get shopStreakRepair => 'Serien-Reparatur';

  @override
  String get shopStreakRepairDesc =>
      'Serie verloren? Stelle die alte Länge wieder her und mach weiter.';

  @override
  String get shopStreakLapsed => 'Serie gerissen';

  @override
  String shopStreakDays(int days) {
    return '🔥 $days-Tage-Serie';
  }

  @override
  String shopRepairFor(int cost) {
    return 'Für $cost 💎 reparieren';
  }

  @override
  String get shopStreakRestored => 'Serie wiederhergestellt 🔥';

  @override
  String get shopStreakSafe => 'Deine Serie ist sicher — nichts zu reparieren.';

  @override
  String get shopDoubleXp => 'Doppeltes XP';

  @override
  String get shopDoubleXpDesc => '15 Minuten lang 2× XP aus jeder Lektion.';

  @override
  String shopActiveLeft(int minutes) {
    return 'Aktiv · noch $minutes Min';
  }

  @override
  String get shopInactive => 'Inaktiv';

  @override
  String get shopActive => 'Aktiv';

  @override
  String get shopDoubleXpActive => 'Doppeltes XP aktiv ✨';

  @override
  String get shopBoostRunning => 'Dein Boost läuft — XP wird verdoppelt.';

  @override
  String get shopBadgerOutfits => 'Dachs-Outfits';

  @override
  String get paywallTitle => 'RATEL PRO';

  @override
  String get paywallStartTrial => '7 Tage gratis testen';

  @override
  String paywallGoPro(String price) {
    return 'Pro werden — $price/Monat';
  }

  @override
  String get paywallRestore => 'Käufe wiederherstellen';

  @override
  String get paywallHero =>
      'Live-KI-Tutoring, werbefrei und Offline-Lektionen.';

  @override
  String get paywallAnnual => 'Jährlich';

  @override
  String get paywallMonthly => 'Monatlich';

  @override
  String get paywallTrialHow => 'So funktioniert die 7-Tage-Testphase';

  @override
  String get paywallTrialToday => 'Heute';

  @override
  String get paywallTrialTodayDesc =>
      'Voller Pro-Zugang wird freigeschaltet. Keine Kosten.';

  @override
  String get paywallTrialDay5 => 'Tag 5';

  @override
  String get paywallTrialDay5Desc =>
      'Wir erinnern dich vor Ablauf der Testphase.';

  @override
  String get paywallTrialDay7 => 'Tag 7';

  @override
  String paywallTrialDay7Desc(String price) {
    return '$price/Jahr beginnt, sofern du nicht kündigst.';
  }

  @override
  String get paywallFeatureLiveAi =>
      'Live-KI: Stimme, Tutor-Chat & Schreib-Feedback';

  @override
  String get paywallFeatureNoAds => 'Keine Werbung, nirgends';

  @override
  String get paywallFeatureOffline => 'Offline-Lektionen & Audio';

  @override
  String get paywallFeaturePronunciation => 'KI-Tipps zur Aussprache';

  @override
  String get paywallEverythingFree =>
      'Alles andere — alle 52 Sprachen, Audio, Wiederholung, Ligen, Rollenspiel und Aussprache auf dem Gerät — bleibt für alle kostenlos.';

  @override
  String get paywallYouArePro => 'Du hast RATEL PRO';

  @override
  String get paywallThanks =>
      'Danke, dass du Ratel unterstützt. Verwalte oder kündige jederzeit unter Einstellungen → Abo verwalten.';

  @override
  String get paywallManage => 'Abo verwalten';

  @override
  String paywallFinePrint(String regions) {
    return 'Jederzeit in den Einstellungen kündbar. Preise gelten für $regions; deinen lokalen Preis legt dein App-Store fest.';
  }

  @override
  String get questTitlePowerSession => 'Power-Session';

  @override
  String get questDescPowerSession => 'Verdiene das Doppelte deines Tagesziels';

  @override
  String get questTitleOnFire => 'In Fahrt';

  @override
  String get questDescOnFire => 'Verdiene das Dreifache deines Tagesziels';

  @override
  String get questTitleStreakKeeper => 'Serienhüter';

  @override
  String get questDescStreakKeeper => 'Übe heute, um deine Serie zu halten';

  @override
  String get notifTitleLessons1 => 'Erste Lektion abgeschlossen';

  @override
  String get notifBodyLessons1 =>
      'Du hast deine erste Lektion beendet — großartiger Start!';

  @override
  String get notifTitleLessons5 => '5 Lektionen geschafft';

  @override
  String get notifBodyLessons5 =>
      'Du hast 5 Lektionen abgeschlossen. Bleib dran.';

  @override
  String get notifTitleLessons10 => '10 Lektionen geschafft';

  @override
  String get notifBodyLessons10 =>
      'Zehn Lektionen — du baust eine echte Gewohnheit auf.';

  @override
  String get notifTitleLessons25 => '25 Lektionen geschafft';

  @override
  String get notifBodyLessons25 =>
      'Fünfundzwanzig Lektionen abgeschlossen. Beeindruckender Einsatz!';

  @override
  String get notifTitleLessons50 => '50 Lektionen geschafft';

  @override
  String get notifBodyLessons50 =>
      'Fünfzig Lektionen — du bist auf einem guten Weg.';

  @override
  String get notifTitleStreak3 => '3-Tage-Serie!';

  @override
  String get notifBodyStreak3 => 'Drei Tage in Folge. Beständigkeit ist alles.';

  @override
  String get notifTitleStreak7 => '7-Tage-Serie!';

  @override
  String get notifBodyStreak7 =>
      'Eine ganze Woche tägliches Üben. Hervorragend!';

  @override
  String get notifTitleStreak14 => '14-Tage-Serie!';

  @override
  String get notifBodyStreak14 =>
      'Zwei Wochen am Stück — du bist nicht zu stoppen.';

  @override
  String get notifTitleStreak30 => '30-Tage-Serie!';

  @override
  String get notifBodyStreak30 =>
      'Ein ganzer Monat tägliches Üben. Unglaublich.';

  @override
  String get notifTitleXp100 => '100 XP verdient';

  @override
  String get notifBodyXp100 => 'Deine ersten hundert XP — der Schwung wächst.';

  @override
  String get notifTitleXp500 => '500 XP verdient';

  @override
  String get notifBodyXp500 =>
      'Fünfhundert XP. Du legst dich richtig ins Zeug.';

  @override
  String get notifTitleXp1000 => '1.000 XP verdient';

  @override
  String get notifBodyXp1000 => 'Meilenstein von tausend XP erreicht!';

  @override
  String get notifTitleXp2500 => '2.500 XP verdient';

  @override
  String get notifBodyXp2500 =>
      'Zweitausendfünfhundert XP — ernsthafter Fortschritt.';

  @override
  String get notifTitleLevel1 => 'Niveau A2 erreicht';

  @override
  String get notifBodyLevel1 => 'Dein Können wuchs von A1 auf A2. Weiter so!';

  @override
  String get notifTitleLevel2 => 'Niveau B1 erreicht';

  @override
  String get notifBodyLevel2 => 'Du bist jetzt auf mittlerem Niveau (B1).';

  @override
  String get notifTitleLevel3 => 'Niveau B2 erreicht';

  @override
  String get notifBodyLevel3 => 'Obere Mittelstufe (B2) erreicht. Brillant.';

  @override
  String get notifTitleLevel4 => 'Niveau C1 erreicht';

  @override
  String get notifBodyLevel4 =>
      'Fortgeschritten (C1) — dein Spanisch ist stark.';

  @override
  String get notifTitleLevel5 => 'Niveau C2 erreicht';

  @override
  String get notifBodyLevel5 => 'Meisterschaft (C2) — die Spitze der Skala!';

  @override
  String get achTitleFirstSteps => 'Erste Schritte';

  @override
  String get achTitleScholar => 'Gelehrter';

  @override
  String get achTitleWildfire => 'Lauffeuer';

  @override
  String get achTitlePointMaker => 'Punktemacher';

  @override
  String get achTitleCollector => 'Sammler';

  @override
  String get achTitleRisingStar => 'Aufsteigender Stern';

  @override
  String get leagueTierBronze => 'Bronze';

  @override
  String get leagueTierSilver => 'Silber';

  @override
  String get leagueTierGold => 'Gold';

  @override
  String get leagueTierSapphire => 'Saphir';

  @override
  String get leagueTierRuby => 'Rubin';

  @override
  String get leagueTierEmerald => 'Smaragd';

  @override
  String get leagueTierAmethyst => 'Amethyst';

  @override
  String get leagueTierPearl => 'Perle';

  @override
  String get leagueTierObsidian => 'Obsidian';

  @override
  String get leagueTierDiamond => 'Diamant';

  @override
  String get cefrNameBeginner => 'Anfänger';

  @override
  String get cefrNameElementary => 'Grundstufe';

  @override
  String get cefrNameIntermediate => 'Mittelstufe';

  @override
  String get cefrNameUpperIntermediate => 'Obere Mittelstufe';

  @override
  String get cefrNameAdvanced => 'Fortgeschritten';

  @override
  String get cefrNameProficient => 'Exzellent';

  @override
  String leaguesTierLeague(String tier) {
    return '$tier-Liga';
  }

  @override
  String leaguesYoureIn(String tier) {
    return 'Du bist in $tier · die Top 7 steigen jede Woche auf';
  }

  @override
  String get leaguesZonePromotion => '⬆ AUFSTIEGSZONE';

  @override
  String get leaguesZoneDemotion => '⬇ ABSTIEGSZONE';

  @override
  String profileAchievementsSummary(int unlocked, int total) {
    return '$unlocked von $total freigeschaltet · echter Fortschritt';
  }

  @override
  String get profileRealStateNote =>
      'Niveau, XP, Lektionen, Serie und gespeicherte Wörter sind echter Engine-Zustand — sie starten bei null auf einem neuen Konto.';
}
