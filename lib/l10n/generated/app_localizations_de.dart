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
  String homeSectionN(int n) {
    return 'ABSCHNITT $n';
  }

  @override
  String homeSectionLevel(int n, String band) {
    return 'ABSCHNITT $n · NIVEAU $band';
  }

  @override
  String homeLevelBand(String band) {
    return 'Niveau $band';
  }

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
  String get lessonExplainThis => '💡 Erklär das';

  @override
  String get lessonMatchPairs => 'Ordne die Paare zu';

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
  String get onboardingLanguageSubtitle => 'Lerne Englisch aus 10 Sprachen';

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
  String get langNameEnglish => 'Englisch';

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
  String libraryEstMinutes(int n) {
    return '~$n min';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return 'Tägliche Quests · $done/$total';
  }

  @override
  String get questsInfoNote =>
      'Quests verfolgen deinen echten Tagesfortschritt. Belohnungstruhen, Freundes-Quests und eine Wochen-Rangliste brauchen eine Backend-Ökonomie — Entscheidung des Eigentümers (§6). Keine falschen Belohnungen.';

  @override
  String get questsRewardPending => 'Rewards soon';

  @override
  String get questsFriendQuest => 'Friend quest';

  @override
  String get questsFriendQuestSoon => 'Friend quests need a social backend — coming soon. No fake partners are shown.';

  @override
  String questsFriendQuestOutearn(String handle, int gap) {
    return 'Out-earn @$handle · $gap XP to catch up this week';
  }

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
      'Alles andere — Audio, Wiederholung, Ligen, Rollenspiel und Aussprache auf dem Gerät — bleibt für alle kostenlos.';

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
  String get paywallRegionsTier1 => 'USA, EU, Japan, Australien';

  @override
  String get paywallRegionsMid => 'Lateinamerika, Südostasien, Osteuropa';

  @override
  String get paywallRegionsLowPpp => 'Indien, Pakistan, Nigeria, Bangladesch';

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
      'Fortgeschritten (C1) — dein Englisch ist stark.';

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

  @override
  String get practiceTitle => 'Üben';

  @override
  String practiceReviewWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wörter wiederholen',
      one: '1 Wort wiederholen',
    );
    return '$_temp0';
  }

  @override
  String get practiceYourWords => 'Deine Wörter';

  @override
  String practiceSavedWordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gespeicherte Wörter',
      one: '$count gespeichertes Wort',
    );
    return '$_temp0';
  }

  @override
  String practiceDueForReview(int count) {
    return '$count fällig zur verteilten Wiederholung';
  }

  @override
  String get practiceAllUpToDate => 'Alle Wiederholungen aktuell';

  @override
  String practiceCaughtUp(String tail) {
    return 'Alles erledigt — gerade ist nichts fällig$tail.';
  }

  @override
  String practiceNextTail(String when) {
    return ' · nächste $when';
  }

  @override
  String get practiceZeroDue => '0 fällig';

  @override
  String get practiceDueNow => 'Jetzt fällig';

  @override
  String practiceDueWhen(String when) {
    return 'Fällig $when';
  }

  @override
  String get practiceChipDue => 'Fällig';

  @override
  String get practiceChipScheduled => 'Geplant';

  @override
  String get practiceScheduleNote =>
      'Wiederholungen plant die echte FSRS-6-Engine für verteilte Wiederholung. Termine gelten für diese Sitzung; das Speichern über Neustarts hinweg ist ein Go-live-Schritt — nichts hier ist erfunden.';

  @override
  String get practiceNoSavedWords => 'Noch keine gespeicherten Wörter';

  @override
  String get practiceSaveWordHint =>
      'Speichere ein Wort während einer Lektion und es landet hier als Karteikarte. Die Wiederholungen plant dann die echte FSRS-Engine — nichts ist vorausgefüllt.';

  @override
  String get practiceStartLesson => 'Eine Lektion starten';

  @override
  String practiceWordOf(int n, int total) {
    return 'Wort $n von $total';
  }

  @override
  String get practiceShowAnswer => 'Antwort zeigen';

  @override
  String get practiceRecallHint =>
      'Rufe die Bedeutung ab und bewerte dann, wie gut du dich erinnert hast.';

  @override
  String get practiceGradeAgain => 'Nochmal';

  @override
  String get practiceGradeHard => 'Schwer';

  @override
  String get practiceGradeGood => 'Gut';

  @override
  String get practiceGradeEasy => 'Leicht';

  @override
  String get practiceFsrsGradeNote =>
      'FSRS-6 plant die nächste Wiederholung nach deiner Bewertung';

  @override
  String get practiceReviewComplete => 'Wiederholung abgeschlossen';

  @override
  String practiceReviewedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Du hast $count Wörter wiederholt. FSRS hat sie neu eingeplant.',
      one: 'Du hast 1 Wort wiederholt. FSRS hat es neu eingeplant.',
    );
    return '$_temp0';
  }

  @override
  String get practiceDone => 'Fertig';

  @override
  String get practiceRelTomorrow => 'morgen';

  @override
  String practiceRelInDays(int days) {
    return 'in $days Tagen';
  }

  @override
  String practiceRelInHours(int hours) {
    return 'in $hours Std.';
  }

  @override
  String practiceRelInMinutes(int minutes) {
    return 'in $minutes Min.';
  }

  @override
  String get practiceRelSoon => 'bald';

  @override
  String get progressTitle => 'Fortschritt';

  @override
  String get progressYourLevel => 'YOUR LEVEL';

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
  String get progressShareMilestone => 'Meilenstein teilen';

  @override
  String get progressLast7Days => 'Letzte 7 Tage';

  @override
  String get progressAccuracyRetention => 'Genauigkeit & Behalten';

  @override
  String get progressHonestyNote =>
      'Alles hier ist echter aufgezeichneter Zustand — Niveau, Können, gespeicherte Wörter, XP, Lektionen, Serie, deine 7-Tage-Historie, Genauigkeit und Lernzeit starten bei null und wachsen beim Lernen. Behalten ist der vorhergesagte Abruf dieser Sitzung (der sitzungsübergreifende Planer ist Go-live-Arbeit); nichts ist erfunden.';

  @override
  String progressShareText(
    int streak,
    int xp,
    int lessons,
  ) {
    return '🦡 RATEL\n🔥 $streak-Tage-Serie · ⚡ $xp XP · 📘 $lessons Lektionen\nLernt auf learnwithratel.com';
  }

  @override
  String get progressShareCopied =>
      'Meilenstein in die Zwischenablage kopiert — teile ihn überall!';

  @override
  String progressAbilityLine(String theta) {
    return 'Können θ $theta · echte Schätzung';
  }

  @override
  String get progressStatSavedWords => 'Gespeicherte Wörter';

  @override
  String get progressStatLessons => 'Lektionen';

  @override
  String get progressStatDayStreak => 'Serientage';

  @override
  String get progressStatTotalXp => 'Gesamt-XP';

  @override
  String get progressStatTodaysXp => 'Heutiges XP';

  @override
  String get progressStatCefrLevel => 'CEFR-Niveau';

  @override
  String get progressAccuracy => 'Genauigkeit';

  @override
  String get progressStudyTime => 'Lernzeit';

  @override
  String get progressRetention => 'Behalten';

  @override
  String get progressNoData => 'Noch keine Daten';

  @override
  String get progressAccuracyEmpty =>
      'Beantworte bewertete Übungen, um zu starten';

  @override
  String progressAccuracyDetail(int correct, int total) {
    return '$correct von $total richtig';
  }

  @override
  String get progressTimeEmpty => 'Lektionszeit summiert sich hier';

  @override
  String get progressTimeDetail => 'über alle deine Lektionen';

  @override
  String get progressRetentionEmpty =>
      'Wiederhole Einträge, um den vorhergesagten Abruf zu sehen';

  @override
  String progressRetentionDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vorhergesagter 1-Tages-Abruf · $count Einträge in dieser Sitzung',
      one: 'vorhergesagter 1-Tages-Abruf · 1 Eintrag in dieser Sitzung',
    );
    return '$_temp0';
  }

  @override
  String progressWeekTotal(int xp) {
    return '$xp XP · letzte 7 Tage';
  }

  @override
  String get progressNoXpYet => 'Noch kein XP erfasst';

  @override
  String get progressChartEmptyNote =>
      'Beende eine Lektion, um deine 7-Tage-Historie zu starten — inaktive Tage bleiben bei null, nichts ist erfunden.';

  @override
  String get commonDowMon => 'Mo';

  @override
  String get commonDowTue => 'Di';

  @override
  String get commonDowWed => 'Mi';

  @override
  String get commonDowThu => 'Do';

  @override
  String get commonDowFri => 'Fr';

  @override
  String get commonDowSat => 'Sa';

  @override
  String get commonDowSun => 'So';

  @override
  String get searchTitle => 'Suche';

  @override
  String get searchHint => 'Lektionen, Wörter, Geschichten suchen…';

  @override
  String get searchRecent => 'Zuletzt';

  @override
  String get searchClear => 'Löschen';

  @override
  String get searchJumpTo => 'Springe zu';

  @override
  String get searchTagPage => 'Seite';

  @override
  String get searchTagWord => 'Wort';

  @override
  String get searchSubtitleSavedWord => 'Gespeichertes Wort';

  @override
  String searchLessonSubtitle(String unit) {
    return '$unit · Lektion';
  }

  @override
  String searchNoMatches(String query) {
    return 'Keine Treffer für „$query“';
  }

  @override
  String get searchEmptyNote =>
      'Durchsucht Titel, Tags und Lektionsinhalte deines Kurses, gespeicherte Wörter und Seiten. Server-Inhaltsindex und Trends sind der nächste R-L12-Schritt — nichts hier ist vorgetäuscht.';

  @override
  String get searchNoMatchNote =>
      'Durchsucht deine veröffentlichten Lektionen, gespeicherte Wörter und App-Seiten (Titel + Tags). Geschichten/Podcasts und Volltext sind der nächste R-L12-Schritt — nie vorgetäuscht.';

  @override
  String get searchFooterNote =>
      'Zum Start Titel + Tags. Volltext, Geschichten/Podcasts und Mehrkurs-Suche sind der nächste R-L12-Schritt — nie vorgetäuscht.';

  @override
  String get searchDestPracticeHub => 'Übungszentrum';

  @override
  String get searchDestPracticeHubSub => 'Fehler, schwache Wörter & Drills';

  @override
  String get searchDestAiTutor => 'KI-Tutor';

  @override
  String get searchDestAiTutorSub => 'Sprechen, chatten & Rollenspiel';

  @override
  String get searchDestAdventures => 'Abenteuer';

  @override
  String get searchDestAdventuresSub => 'Echte Gespräche — kostenlos';

  @override
  String get searchDestLeagues => 'Ligen';

  @override
  String get searchDestLeaguesSub => 'Deine Wochenliga';

  @override
  String get searchDestQuests => 'Quests';

  @override
  String get searchDestQuestsSub => 'Tagesziele & Quests';

  @override
  String get searchDestProgress => 'Fortschritt';

  @override
  String get searchDestProgressSub => 'Deine Statistiken & Serie';

  @override
  String get searchDestProfile => 'Profil';

  @override
  String get searchDestProfileSub => 'Dein Profil';

  @override
  String get searchDestSettings => 'Einstellungen';

  @override
  String get searchDestSettingsSub => 'Konto & Präferenzen';

  @override
  String get searchDestShop => 'Shop';

  @override
  String get searchDestShopSub => 'Gib deine Diamanten aus';

  @override
  String get searchDestNotifications => 'Benachrichtigungen';

  @override
  String get searchDestNotificationsSub => 'Dein Meilenstein-Posteingang';

  @override
  String get themesTitle => 'Themen';

  @override
  String get themesSubtitle =>
      'Gestaltet die ganze App um — tippe für Live-Vorschau';

  @override
  String themesVehicle(String vehicle) {
    return 'Fahrzeug · $vehicle';
  }

  @override
  String get tutorHeader => 'Übe ein echtes Gespräch';

  @override
  String get tutorHeaderSub =>
      'Wähle eine Szene und chatte mit Ratel — keine falschen Antworten, nur Übung.';

  @override
  String get tutorTalkTitle => 'Mit Ratel sprechen';

  @override
  String get tutorTalkSub => 'Live-Sprechtraining mit Stimme & Video';

  @override
  String get tutorChatTitle => 'Mit Ratel chatten';

  @override
  String get tutorChatSub => 'KI-Chat · Schreibfeedback';

  @override
  String get tutorRoleplayTitle => 'Rollenspiel-Szenen';

  @override
  String get tutorRoleplayGuided => 'Geführte Rollenspiel-Gespräche';

  @override
  String tutorScenesCount(int count) {
    return '$count Szenen';
  }

  @override
  String get tutorUnlockPro => 'RATEL PRO freischalten';

  @override
  String get tutorRelayNote =>
      'Live-KI-Tutoring läuft über ein moderiertes, kostenkontrolliertes Relay und ist eine RATEL-PRO-Funktion. Antworten werden nie simuliert — ein Modus startet erst, wenn PRO und Relay aktiv sind.';

  @override
  String get tutorStatusReadyPro =>
      'PRO aktiv und Live-Tutor verbunden — wähle einen Modus zum Start.';

  @override
  String get tutorStatusReadyFree =>
      'Der Live-Tutor ist verbunden. Live-Tutoring ist eine RATEL-PRO-Funktion.';

  @override
  String get tutorStatusOffline =>
      'Der moderierte Live-Tutor ist in diesem Build noch nicht verbunden — Live-Tutoring folgt in einem späteren Schritt. Nichts unten ist simuliert.';

  @override
  String get tutorAnnounceNeedsPro =>
      'RATEL PRO schaltet Live-KI-Tutoring frei.';

  @override
  String get tutorAnnounceNeedsRelay =>
      'KI-Tutoring verbindet sich, sobald das moderierte Relay aktiviert ist.';

  @override
  String get tutorAnnounceStarting => 'Deine Sitzung startet…';

  @override
  String get adventuresTitle => 'Abenteuer';

  @override
  String get adventuresFreeChip => 'GRATIS';

  @override
  String get adventuresHeaderSub => 'Erkunde eine Welt · sprich dich durch';

  @override
  String get adventuresHeroTitle => 'Such dir einen Ort aus und leg los';

  @override
  String get adventuresHeroSub =>
      'Jede Szene ist ein echtes Gespräch — keine falschen Antworten, und immer kostenlos.';

  @override
  String get adventuresFallbackWorld => 'Abenteuer';

  @override
  String adventureSheetKicker(String cefr) {
    return '🗺️ ABENTEUER · $cefr';
  }

  @override
  String adventureScenesCount(int count) {
    return '$count Szenen';
  }

  @override
  String adventureChoicePoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Entscheidungspunkte',
      one: '$count Entscheidungspunkt',
    );
    return '$_temp0';
  }

  @override
  String get adventureOpeningScene => 'ERSTE SZENE';

  @override
  String get adventureStart => 'Abenteuer starten';

  @override
  String get adventurePlayerFallbackTitle => 'Abenteuer';

  @override
  String get adventureTheEnd => '🏁 Ende';

  @override
  String get adventureStartOver => 'Neu starten';

  @override
  String get adventureDone => 'Fertig';

  @override
  String get adventureCompleteKicker => 'ABENTEUER ABGESCHLOSSEN';

  @override
  String adventureCompleteTitle(String title) {
    return '$title ✓';
  }

  @override
  String get adventureCompleteBody =>
      'Gut gemacht! +15 XP · +5 💎 verdient — erkunde die nächste Szene, wann immer du willst.';

  @override
  String adventureDistrictProgress(int done, int total) {
    return '$done/$total erkundet';
  }

  @override
  String get adventureDistrictDone => '✓ Fertig';

  @override
  String get adventuresEmpty => 'In diesem Kurs gibt es noch keine Abenteuer.';

  @override
  String get authWelcomeTitle => 'Willkommen bei Ratel';

  @override
  String get authWelcomeSubtitle =>
      'Lektionen, Geschichten, Podcasts und mehr —\nwähle, wie du starten willst.';

  @override
  String get authCreateFreeAccount => 'Kostenloses Konto erstellen';

  @override
  String get authAlreadyHaveAccount => 'Ich habe schon ein Konto';

  @override
  String get authSettingUp => 'Wird eingerichtet…';

  @override
  String get authContinueAsGuest => 'Als Gast fortfahren';

  @override
  String get authGuestNote =>
      'Gast-Fortschritt bleibt auf diesem Gerät — erstelle jederzeit in den Einstellungen ein kostenloses Konto, um ihn überall zu behalten.';

  @override
  String get authEnterYourEmail => 'Gib deine E-Mail ein';

  @override
  String get authEnterValidEmail => 'Gib eine gültige E-Mail ein';

  @override
  String get authEnterYourPassword => 'Gib dein Passwort ein';

  @override
  String get authCouldNotSignIn =>
      'Anmeldung fehlgeschlagen. Bitte versuch es erneut.';

  @override
  String get authSomethingWentWrong =>
      'Etwas ist schiefgelaufen. Bitte versuch es erneut.';

  @override
  String get authSocialComingSoon => 'Anmeldung mit Google / Apple kommt bald.';

  @override
  String get authResetTitle => 'Passwort zurücksetzen';

  @override
  String get authWelcomeBack => 'Willkommen zurück!';

  @override
  String get authResetSubtitle =>
      'Gib deine E-Mail ein und wir senden einen Reset-Link.';

  @override
  String get authPickUpWhereYouLeft => 'Mach da weiter, wo du aufgehört hast';

  @override
  String get authEmailHint => 'E-Mail';

  @override
  String get authPasswordHint => 'Passwort';

  @override
  String get authForgotPassword => 'Passwort vergessen?';

  @override
  String get authSendResetLink => 'Reset-Link senden';

  @override
  String get authLogIn => 'Anmelden';

  @override
  String get authBackToLogIn => 'Zurück zur Anmeldung';

  @override
  String get authNewToRatel => 'Neu bei Ratel? ';

  @override
  String get authSignUp => 'Registrieren';

  @override
  String get authCheckYourInbox => 'Sieh in dein Postfach';

  @override
  String authResetSent(String email) {
    return 'Wir haben einen Passwort-Reset-Link an $email gesendet. Öffne ihn, um ein neues Passwort zu wählen.';
  }

  @override
  String get authCreatePassword => 'Erstelle ein Passwort';

  @override
  String get authAtLeast8Chars => 'Mindestens 8 Zeichen';

  @override
  String get authCreateYourAccount => 'Erstelle dein Konto';

  @override
  String get authSignupSubtitle =>
      'Für immer kostenlos · lerne Englisch aus 10 Sprachen';

  @override
  String get authPassword8Hint => 'Passwort (8+ Zeichen)';

  @override
  String get authCreateAccount => 'Konto erstellen';

  @override
  String get authAlreadyAccountLead => 'Schon ein Konto? ';

  @override
  String get authSignIn => 'Anmelden';

  @override
  String get authConfirmEmail => 'Bestätige deine E-Mail';

  @override
  String authConfirmSent(String email) {
    return 'Wir haben einen Bestätigungslink an $email gesendet. Tippe darauf, um dein Konto zu aktivieren, und melde dich dann an.';
  }

  @override
  String get authContinueGoogle => 'Weiter mit Google';

  @override
  String get authContinueApple => 'Weiter mit Apple';

  @override
  String get authOr => 'oder';

  @override
  String get authUnavailableNote =>
      'Konten sind in diesem Build noch nicht verfügbar — du kannst als Gast weiterlernen. Die Anmeldung wird aktiviert, sobald das Backend konfiguriert ist.';

  @override
  String get liveMute => 'Stumm';

  @override
  String get liveUnmute => 'Ton an';

  @override
  String commonDurSeconds(int s) {
    return '$s s';
  }

  @override
  String commonDurMinutes(int m) {
    return '$m Min.';
  }

  @override
  String commonDurHours(int h) {
    return '$h Std.';
  }

  @override
  String commonDurHoursMinutes(int h, int m) {
    return '$h Std. $m Min.';
  }

  @override
  String practiceGradeInterval(String label, int days) {
    return '$label · $days T.';
  }

  @override
  String settingsGoalPerDay(int goal) {
    return '$goal XP pro Tag';
  }

  @override
  String settingsGoalReachedSub(int goal) {
    return '$goal XP pro Tag · ✓ heute erreicht';
  }

  @override
  String get settingsSoundEffects => 'Soundeffekte';

  @override
  String get settingsHaptics => 'Haptik';

  @override
  String get settingsProActive => 'RATEL PRO aktiv';

  @override
  String get settingsFreePlan => 'Kostenloser Plan';

  @override
  String get settingsReduceMotion => 'Bewegung reduzieren';

  @override
  String get settingsReduceMotionSub =>
      'Hauptschalter — schaltet jede Animation aus';

  @override
  String get settingsHighContrast => 'Hoher Kontrast';

  @override
  String get settingsNotifPush => 'Push-Benachrichtigungen';

  @override
  String get settingsNotifStreak => 'Serien-Erinnerungen';

  @override
  String get settingsNotifLeague => 'Liga-Updates';

  @override
  String get settingsNotifFriend => 'Freundes-Aktivität';

  @override
  String get settingsNotifFootnote =>
      'Deine Einstellungen sind jetzt gespeichert — die Zustellung wird aktiviert, sobald Push-Benachrichtigungen verfügbar sind.';

  @override
  String get settingsCourse => 'Kurs';

  @override
  String get settingsTheme => 'Thema';

  @override
  String get settingsWorld => 'Welt';

  @override
  String get settingsEditProfile => 'Profil bearbeiten';

  @override
  String get settingsPrivacy => 'Datenschutz & Daten';

  @override
  String get settingsHelp => 'Hilfe & Support';

  @override
  String get settingsLogOut => 'Abmelden';

  @override
  String get settingsGuestSub =>
      'Du lernst als Gast — registriere dich, um deinen Fortschritt zu sichern';

  @override
  String settingsCouldNotOpen(String url) {
    return '$url konnte nicht geöffnet werden';
  }

  @override
  String get settingsThemeSystem => 'Wie Gerät';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get mediaReadAloud => 'Vorlesen';

  @override
  String get mediaTranscript => 'Transkript';

  @override
  String get mediaCheckUnderstanding => 'Verständnis prüfen';

  @override
  String mediaChecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Verständnisfragen',
      one: '$count Verständnisfrage',
    );
    return '$_temp0';
  }

  @override
  String get mediaLoading => 'Wird geladen…';

  @override
  String get mediaPause => 'Pause';

  @override
  String get storiesTitle => 'Geschichten';

  @override
  String get storiesSub =>
      'Lesen & hören — abgestufte Geschichten mit Browser-Vorlesefunktion.';

  @override
  String get storiesEmpty => 'In diesem Kurs gibt es noch keine Geschichten.';

  @override
  String get storyFallbackTitle => 'Geschichte';

  @override
  String get podcastsSub =>
      'Hören — abgestufte Podcasts mit echtem Audio und Transkript.';

  @override
  String get podcastsEmpty => 'In diesem Kurs gibt es noch keine Podcasts.';

  @override
  String get podcastFallbackTitle => 'Podcast';

  @override
  String get podcastPlayEpisode => 'Folge abspielen';

  @override
  String get watchSub =>
      'Ansehen — kurze Clips mit Transkript und Verständnisfragen.';

  @override
  String get watchEmpty =>
      'In diesem Kurs gibt es noch keine Ansehen-Lektionen.';

  @override
  String get watchWebOnly => 'Video läuft in der Web-App';

  @override
  String get libraryAdventuresSub =>
      'Erkunde eine lebendige Welt und sprich dich durch echte Szenen.';

  @override
  String get roleplaySub =>
      'Übe echte Gespräche — wähle die richtige Antwort, erhalte sofort Feedback.';

  @override
  String get roleplayEmpty => 'In diesem Kurs gibt es noch keine Rollenspiele.';

  @override
  String get roleplayYourReply => 'Deine Antwort:';

  @override
  String get roleplaySceneComplete => '🎉 Szene abgeschlossen!';

  @override
  String get roleplayBack => 'Zurück zu den Rollenspielen';

  @override
  String get liveRoleplayTitle => 'Live-Rollenspiel';

  @override
  String get liveRoleplayCardSub => 'Sprich es mit Ratel durch — echte Stimme';

  @override
  String get liveIntro =>
      'Sprich es mit Ratel durch — Live-Sprach-Rollenspiel. Wähle eine Szene oder unterhalte dich einfach.';

  @override
  String get liveFreeConversation => 'Freies Gespräch';

  @override
  String get liveFreeConversationSub => 'Kein Skript — einfach reden';

  @override
  String get liveRoleplayScene => 'Eine Szene spielen';

  @override
  String get liveReconnecting => 'Verbindung wird wiederhergestellt…';

  @override
  String get liveConnectionLost =>
      'Verbindung verloren — die Live-Sitzung wurde getrennt.';

  @override
  String get liveReconnect => 'Neu verbinden';

  @override
  String get liveConnecting => 'Verbindung wird hergestellt…';

  @override
  String get liveStartTalking => 'Losreden';

  @override
  String get liveSceneEndedNote =>
      'Szene beendet. Starte neu, wann immer du willst — deine Live-Minuten sind eingeplant, nie ungenutzt.';

  @override
  String get liveStartAgain => 'Neu starten';

  @override
  String get liveProGate =>
      'Live-Sprach-Rollenspiel ist eine RATEL-PRO-Funktion — echtes Gespräch, Live-Feedback, kostengeschützte Minuten.';

  @override
  String get liveUnlockPro => 'RATEL PRO freischalten';

  @override
  String get liveNotEnabled =>
      'Live-Stimme ist in diesem Build noch nicht aktiviert — sie folgt in einem späteren Schritt. Nichts hier ist simuliert.';

  @override
  String get livePhaseIdle =>
      'Bereit, wenn du es bist — es ist ein echter Live-Anruf.';

  @override
  String get livePhaseListening => 'Hört zu — du bist dran.';

  @override
  String get livePhaseSpeaking => 'Ratel spricht — steig jederzeit ein.';

  @override
  String get livePhaseClosed => 'Szene beendet.';

  @override
  String get liveEndScene => 'Szene beenden';

  @override
  String get liveYou => 'Du';

  @override
  String get liveStartFailed =>
      'Die Live-Sitzung konnte nicht gestartet werden — versuch es erneut.';

  @override
  String get friendsHandleInvalid =>
      'Gib einen Handle wie @mia ein (2–20 Buchstaben, Zahlen, _).';

  @override
  String friendsAlreadyConnected(String handle) {
    return 'Du bist bereits mit @$handle verbunden.';
  }

  @override
  String get friendsRequests => 'Anfragen';

  @override
  String get friendsYourFriends => 'Deine Freunde';

  @override
  String get friendsPending => 'Ausstehend';

  @override
  String get friendsActivity => 'Freundes-Aktivität';

  @override
  String get friendsFootnote =>
      'Dein soziales Netzwerk ist echt und privat für dich. Freundschaftsanfragen werden zugestellt und „hat dich überholt“ erscheint, sobald das dauerhafte nutzerübergreifende Netzwerk aktiv ist — derselbe Go-live-Schritt wie bei jedem anderen dauerhaften Zähler. Nichts hier ist gefälscht.';

  @override
  String get friendsAddHint => 'Füge einen Freund per @handle hinzu…';

  @override
  String get friendsAccept => 'Annehmen';

  @override
  String friendsXpThisWeek(String handle, String xp) {
    return '@$handle · $xp XP diese Woche';
  }

  @override
  String get friendsPassedYou => 'Hat dich überholt';

  @override
  String get friendsRemove => 'Entfernen';

  @override
  String get friendsBlock => 'Blockieren';

  @override
  String get friendsReportBlock => 'Melden & blockieren';

  @override
  String get friendsRequestSent => 'Anfrage gesendet';

  @override
  String get friendsEmptyTitle => 'Noch keine Freunde';

  @override
  String get friendsEmptyBody =>
      'Füge jemanden per @handle hinzu, um Fortschritte zu teilen.';

  @override
  String get profileLearner => 'Lernende:r';

  @override
  String get profileGuest => 'Gast';

  @override
  String get editProfileSaved => 'Profil gespeichert';

  @override
  String get editProfileHandleSet =>
      'Gespeichert — dein @handle ist festgelegt.';

  @override
  String get editProfileSignInForHandle =>
      'Name gespeichert. Melde dich an, um deinen @handle zu sichern.';

  @override
  String get editProfileHandleFailed =>
      'Dieser @handle konnte nicht festgelegt werden.';

  @override
  String get editProfileDisplayName => 'Anzeigename';

  @override
  String get editProfileNameHint => 'Wie sollen wir dich ansprechen?';

  @override
  String get editProfileNameNote =>
      'Wird in deinem Profil angezeigt. Auf diesem Gerät gespeichert — synchronisiert mit deinem Konto, wenn du dich anmeldest.';

  @override
  String get editProfileHandle => 'Dein @handle';

  @override
  String get editProfileHandleNote =>
      'Andere Lernende fügen dich per @handle hinzu (2–20 Buchstaben, Zahlen oder _). Zum Sichern musst du angemeldet sein.';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get feedIsNowYourFriend => 'ist jetzt dein Freund';

  @override
  String feedReachedLevel(String level) {
    return 'hat $level erreicht';
  }

  @override
  String feedDayStreak(int count) {
    return '$count-Tage-Serie';
  }

  @override
  String get feedPassedYou => 'hat dich in deiner Liga überholt';

  @override
  String get leaguesSoloCaption => 'diese Woche · Einzelgruppe';

  @override
  String leaguesXpToRank(int xp, int rank) {
    return '$xp XP bis Rang $rank';
  }

  @override
  String get leaguesLeading => 'führt deine Gruppe an';

  @override
  String get leaguesSoloNote =>
      'Du bist diese Woche die/der einzige Lernende in deiner Gruppe. Echte Rivalen kommen dazu, während Ratel wächst — keine Bots, keine falschen Ranglisten. Sammle weiter XP, um bereit zu sein, wenn die Woche neu startet.';

  @override
  String questsGoalLine(int today, int goal) {
    return '$today / $goal XP · Ziel erreicht';
  }

  @override
  String questsGoalRemaining(int today, int goal, int remaining) {
    return '$today / $goal XP · noch $remaining XP';
  }

  @override
  String get worldLabelLight => 'Tageslicht';

  @override
  String get worldVehicleLight => 'Roller';

  @override
  String get worldLabelGalaxy => 'Weltraum';

  @override
  String get worldVehicleGalaxy => 'Sternenkapsel';

  @override
  String get worldLabelSavanna => 'Savanne';

  @override
  String get worldVehicleSavanna => 'Safari-Jeep';

  @override
  String get worldLabelOcean => 'Ozean';

  @override
  String get worldVehicleOcean => 'U-Boot';

  @override
  String get worldLabelForest => 'Wald';

  @override
  String get worldVehicleForest => 'Blättergleiter';

  @override
  String get worldLabelCandy => 'Süßigkeiten';

  @override
  String get worldVehicleCandy => 'Ballon';

  @override
  String get worldLabelNeon => 'Neon-Stadt';

  @override
  String get worldVehicleNeon => 'Schwebe-Bike';

  @override
  String get worldLabelStorm => 'Regensturm';

  @override
  String get worldVehicleStorm => 'Sturmgleiter';

  @override
  String get worldLabelSnow => 'Winter';

  @override
  String get worldVehicleSnow => 'Schneeschlitten';

  @override
  String get worldLabelSakura => 'Kirschblüte';

  @override
  String get worldVehicleSakura => 'Blütendrache';

  @override
  String get worldLabelAutumn => 'Herbst';

  @override
  String get worldVehicleAutumn => 'Blätterkarren';

  @override
  String get worldLabelAurora => 'Polarlicht';

  @override
  String get worldVehicleAurora => 'Polarlicht-Boot';

  @override
  String get worldLabelVolcano => 'Vulkan';

  @override
  String get worldVehicleVolcano => 'Magmabrett';

  @override
  String get worldLabelSunset => 'Sonnenuntergang';

  @override
  String get worldVehicleSunset => 'Gleiter';

  @override
  String get worldLabelDesert => 'Wüste';

  @override
  String get worldVehicleDesert => 'Dünenbuggy';

  @override
  String get worldLabelReef => 'Korallenriff';

  @override
  String get worldVehicleReef => 'Glasboot';

  @override
  String get worldLabelMeadow => 'Wiese';

  @override
  String get worldVehicleMeadow => 'Fahrrad';

  @override
  String get worldLabelDawn => 'Morgengrauen';

  @override
  String get worldVehicleDawn => 'Himmelsballon';

  @override
  String get worldLabelBeach => 'Tropenstrand';

  @override
  String get worldVehicleBeach => 'Katamaran';

  @override
  String get worldLabelMars => 'Mars';

  @override
  String get worldVehicleMars => 'Rover';

  @override
  String get worldLabelJungle => 'Regenwald';

  @override
  String get worldVehicleJungle => 'Seilrutsche';

  @override
  String get worldLabelCyberrain => 'Cyber-Regen';

  @override
  String get worldVehicleCyberrain => 'Schwebe-Bike';

  @override
  String get worldLabelAbyss => 'Tiefsee';

  @override
  String get worldVehicleAbyss => 'Tauchkugel';

  @override
  String get worldLabelAlpine => 'Alpen';

  @override
  String get worldVehicleAlpine => 'Seilbahn';

  @override
  String get worldLabelLavender => 'Lavendel';

  @override
  String get worldVehicleLavender => 'Vespa';

  @override
  String get worldLabelBamboo => 'Bambushain';

  @override
  String get worldVehicleBamboo => 'Rikscha';

  @override
  String get worldLabelLagoon => 'Lagunennacht';

  @override
  String get worldVehicleLagoon => 'Kajak';

  @override
  String get worldLabelThunder => 'Gewitterwolke';

  @override
  String get worldVehicleThunder => 'Sturmjäger';

  @override
  String get worldLabelNebula => 'Nebel';

  @override
  String get worldVehicleNebula => 'Sternenkreuzer';

  @override
  String get worldLabelSandstorm => 'Sandsturm';

  @override
  String get worldVehicleSandstorm => 'Karawane';

  @override
  String get worldLabelCherrynight => 'Kirschnacht';

  @override
  String get worldVehicleCherrynight => 'Papierlaterne';

  @override
  String get shopYourBadger => 'Dein Dachs';

  @override
  String get shopDiamondsNote =>
      'Ein Aufladen mit echtem Geld für 💎 kommt bald. Diamanten verdienst du, indem du Lektionen abschließt und dein Tagesziel erreichst, und jedes Power-up hier gibt sie wirklich aus — nichts ist gefälscht.';

  @override
  String get shopProBannerSub =>
      'Live-KI, werbefrei, offline · 7 Tage gratis testen';

  @override
  String get shopYourDiamonds => 'Deine Diamanten';

  @override
  String get shopEquipped => 'Ausgerüstet';

  @override
  String get shopEquip => 'Ausrüsten';

  @override
  String shopEquippedSnack(String name, String emoji) {
    return '$name $emoji ausgerüstet';
  }

  @override
  String get shopFree => 'Kostenlos';

  @override
  String get outfitClassic => 'Klassisch';

  @override
  String get outfitScholar => 'Gelehrter';

  @override
  String get outfitExplorer => 'Entdecker';

  @override
  String get outfitAstronaut => 'Astronaut';

  @override
  String get outfitWizard => 'Zauberer';

  @override
  String paywallAnnualLine(String annual, String perMonth) {
    return '$annual/Jahr  ·  $perMonth/Monat  ·  7 Tage gratis';
  }

  @override
  String paywallMonthlyLine(String monthly) {
    return '$monthly/Monat  ·  monatlich abgerechnet';
  }

  @override
  String paywallSavePercent(int percent) {
    return 'SPARE $percent%';
  }

  @override
  String get paywallIncluded => 'Was in Pro enthalten ist';

  @override
  String get paywallTerms => 'AGB';

  @override
  String get paywallPrivacy => 'Datenschutz';

  @override
  String get paywallNothingToRestore =>
      'Nichts wiederherzustellen — die Abrechnung ist in diesem Build noch nicht aktiv.';

  @override
  String get contentUnavailableTitle => 'Inhalt nicht verfügbar';

  @override
  String contentUnavailableBody(String noun) {
    return 'Diese/r $noun ist gerade nicht verfügbar. Falls du offline bist, prüfe deine Verbindung und versuch es erneut.';
  }

  @override
  String get contentNounStory => 'Geschichte';

  @override
  String get contentNounPodcast => 'Podcast';

  @override
  String get contentNounVideo => 'Video';

  @override
  String get contentNounAdventure => 'Abenteuer';

  @override
  String get contentNounRoleplay => 'Rollenspiel';

  @override
  String get commonGoBack => 'Zurück';

  @override
  String get placementTitle => 'Einstufungstest';

  @override
  String placementQuestionN(int n) {
    return 'Frage $n';
  }

  @override
  String get placementResultTitle => 'Dein Startpunkt';

  @override
  String placementResultBody(int count, String level) {
    return 'Basierend auf $count Fragen haben wir dich bei $level eingestuft. Du kannst das später jederzeit anpassen.';
  }

  @override
  String get lessonTypedNote => 'Tippe deine Antwort in der Zielsprache.';

  @override
  String lessonHintMinWords(int count) {
    return 'mindestens $count Wörter';
  }

  @override
  String lessonHintUseWords(String words) {
    return 'benutze: $words';
  }

  @override
  String get lessonHintEndPunct => 'ende mit . ! oder ?';

  @override
  String get lessonPlayAudio => 'Audio abspielen';

  @override
  String get lessonPlaySlowly => 'Langsam abspielen';

  @override
  String get lessonAudioUnavailable => 'Audio nicht verfügbar — lies den Text.';

  @override
  String get lessonPlaybackSpeed => 'Wiedergabegeschwindigkeit';

  @override
  String get authAccountsUnavailable =>
      'Konten sind in diesem Build noch nicht verfügbar — lerne einfach als Gast weiter.';

  @override
  String get liveNotEnabledShort =>
      'Live-KI ist in diesem Build nicht aktiviert.';

  @override
  String get liveMicUnavailable =>
      'Mikrofon nicht verfügbar — erlaube den Mikrofonzugriff, um mit dem Tutor zu sprechen.';

  @override
  String get liveUnavailable => 'Live-KI ist gerade nicht verfügbar.';

  @override
  String get liveNeedsPro => 'Live-KI ist Teil von RATEL PRO.';

  @override
  String get liveMinutesUsed =>
      'Du hast deine Live-Minuten für diesen Monat aufgebraucht.';

  @override
  String get commonNetworkError =>
      'Server nicht erreichbar. Versuch es erneut.';

  @override
  String get friendsHandleTaken => 'Dieser @handle ist schon vergeben.';

  @override
  String get friendsHandleFormat =>
      'Verwende 2–20 Buchstaben, Zahlen oder _ für deinen Handle.';

  @override
  String get friendsSignInForHandle =>
      'Melde dich an, um deinen @handle zu sichern.';

  @override
  String get friendsSetOwnHandleFirst =>
      'Lege zuerst deinen eigenen @handle fest (Profil bearbeiten).';

  @override
  String get paywallCheckoutUnavailable =>
      'Checkout folgt zum Launch — die Abrechnung ist in diesem Build noch nicht aktiv.';

  @override
  String get settingsManageUnavailable =>
      'Verwalte oder kündige in den Abo-Einstellungen deines Geräts — die App-Verknüpfung folgt zum Launch.';

  @override
  String get friendsAdd => 'Hinzufügen';

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
  String get adventureDistrictCafe => 'Café & Food';

  @override
  String get adventureDistrictMarket => 'Market Square';

  @override
  String get adventureDistrictMove => 'On the Move';

  @override
  String get adventureDistrictFriends => 'Making Friends';

  @override
  String get editProfileAvatar => 'Avatar';

  @override
  String get editProfileChangeAvatar => 'Change avatar';

  @override
  String get editProfileAvatarTitle => 'Choose your avatar';

  @override
  String get editProfileAvatarNote =>
      'Pick an emoji badger buddy. Saved on this device.';

  @override
  String get editProfileBio => 'Bio';

  @override
  String get editProfileBioHint => 'A short line about you';

  @override
  String get editProfileBioNote =>
      'A short note shown on your profile. Saved on this device.';

  @override
  String get streakTitle => 'Streak';

  @override
  String get streakDayLabel => 'DAY STREAK';

  @override
  String get streakFreezesLabel => 'Streak freezes';

  @override
  String get streakLongestLabel => 'Longest streak';

  @override
  String get streakLongestNone => 'No streak yet';

  @override
  String get streakFreezesTileSub =>
      'A freeze covers one missed day so your run survives.';

  @override
  String get streakDeadlineTitle => 'Keep it going today';

  @override
  String get streakDeadlineBody =>
      'Meet your daily goal before midnight to extend your streak.';

  @override
  String get streakTodayDone => 'Today\'s goal is met — your streak is safe.';

  @override
  String get streakZeroTitle => 'Start your streak today';

  @override
  String get streakZeroBody =>
      'Finish a lesson to light the flame. Every consecutive day you meet your goal adds one.';

  @override
  String get streakSocietyTitle => 'Streak Society';

  @override
  String get streakSocietySub => 'Friend streaks · societies · perks';

  @override
  String get streakSocietyHonest =>
      'Streak Society is not built yet — there is no friends-streak backend, so nothing here is faked. It arrives with real social features, like Leagues.';

  @override
  String get streakHonestNote =>
      'Your day count and freezes are your real numbers. RATEL does not show a day-by-day calendar here because it does not yet keep a per-day activity log — nothing is invented.';

  @override
  String get energyTitle => 'Energy';

  @override
  String energyCountLabel(int current, int max) {
    return '$current of $max energy';
  }

  @override
  String get energyUnlimitedLabel => 'Unlimited energy';

  @override
  String get energyLessonCost => 'Each lesson costs 1 ⚡';

  @override
  String get energyNeverBlocksTitle => 'Energy never blocks learning';

  @override
  String get energyNeverBlocksBody =>
      'You can always keep learning, even at 0 ⚡. Energy is a gentle pace signal — it never locks a lesson, and practice is always free.';

  @override
  String get energyRegenNote =>
      'Energy refills on its own over time toward the cap. Exact refill timing isn\'t finalised, so RATEL doesn\'t show a countdown it can\'t guarantee.';

  @override
  String get energyProTitle => 'You have unlimited energy';

  @override
  String get energyProBody =>
      'RATEL PRO removes the counter entirely — it always reads ∞.';

  @override
  String get energyPracticeFree => 'Practice for free';

  @override
  String get energyGoProUnlimited => 'Go PRO · unlimited energy';

  @override
  String get energyHonestNote =>
      'This is your real current energy. RATEL doesn\'t show a refill price or timer here because those numbers aren\'t finalised — it won\'t commit to a figure it can\'t back.';

  @override
  String get coursesTitle => 'Courses';

  @override
  String get coursesLearningHeader => 'LEARNING';

  @override
  String get coursesActive => 'Active';

  @override
  String get coursesSwitch => 'Switch';

  @override
  String get coursesSharedProgress =>
      'Your streak & XP are shared across courses — switching never loses progress.';

  @override
  String get coursesAddHeader => 'ADD A COURSE';

  @override
  String get coursesAddHonest =>
      'More languages are on the way. RATEL only lists courses it actually ships, so there\'s no fake catalog or \"50+ courses\" count here yet.';

  @override
  String get coursesDisplayHeader => 'DISPLAY';

  @override
  String get coursesMenuLanguage => 'Menu language';

  @override
  String get coursesMenuLanguageSub =>
      'Set the app\'s interface language in Settings';

  @override
  String get coursesImmersionMode => 'Immersion mode';

  @override
  String get coursesImmersionSub =>
      'Learn with the app interface in the language you\'re studying.';

  @override
  String coursesImmersionUnsupported(String language) {
    return 'Immersion isn\'t available for $language yet — the app interface isn\'t translated into it.';
  }

  @override
  String coursesSwitchedTo(String language) {
    return 'Switched to $language';
  }

  @override
  String coursesXpTotal(int xp) {
    return '⚡ $xp XP';
  }

  @override
  String get coursesSearchHint => 'Search languages';

  @override
  String get chatTitle => 'Ratel · Tutor';

  @override
  String get chatSubtitle => 'Chat with Ratel';

  @override
  String get chatIntroBubble =>
      'Hi! I\'m Ratel. Ask me anything, or paste a sentence and I\'ll give you feedback.';

  @override
  String get chatQuickHowSay => 'How do you say…?';

  @override
  String get chatQuickCorrect => 'Correct my sentence';

  @override
  String get chatQuickTalk => 'Let\'s chat';

  @override
  String get chatComposerHint => 'Type your message…';

  @override
  String get chatOfflineTitle => 'The tutor chat isn\'t connected yet';

  @override
  String get chatOfflineBody =>
      'Live AI chat is a moderated RATEL PRO feature that turns on in a later step. Until then, no reply is ever simulated — the composer stays here so the layout is ready, but Ratel won\'t send a made-up answer.';

  @override
  String get chatSendBlocked =>
      'The AI tutor isn\'t connected yet — no reply is simulated. Live chat turns on in a later step.';

  @override
  String get homeStreakChipTip => 'View your streak';

  @override
  String get homeEnergyChipTip => 'View your energy';

  @override
  String get diamondsSheetTitle => 'DIAMONDS';

  @override
  String diamondsSheetCount(int count) {
    return '$count diamonds';
  }

  @override
  String get diamondsSheetBody =>
      'Spend on streak freezes, energy refills and outfits in the Shop.';

  @override
  String diamondsSheetEarn(int lesson, int goal) {
    return 'You earn diamonds by finishing lessons (+$lesson each) and meeting your daily goal (+$goal). Everything in the Shop spends real diamonds — nothing here is faked.';
  }

  @override
  String get diamondsOpenShop => 'Open Shop';

  @override
  String get diamondsClose => 'Close';
}
