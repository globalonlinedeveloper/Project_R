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
  String get settingsSectionSubscription => 'Abonnement';

  @override
  String get settingsSectionAccessibility => 'Barrierefreiheit';

  @override
  String get settingsSectionNotifications => 'Benachrichtigungen';

  @override
  String get settingsSectionAppearanceAccount => 'Design & Konto';

  @override
  String get settingsAppLanguage => 'App-Sprache';

  @override
  String get settingsAppLanguageSystem => 'Systemstandard';

  @override
  String get homeCourseLoadingTitle => 'Dein Kurs wird vorbereitet';

  @override
  String get homeCourseLoadingBody =>
      'Lektionen werden hier angezeigt, sobald deine Kursinhalte geladen sind.';

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
  String get homeUnitGuideHeader => 'EINHEIT-GUIDE';

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
      'Sprechen, chatten & Rollenspiele — Schreib-Feedback';

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
      'Fehler, schwierige Wörter & Übungen · KOSTENLOS';

  @override
  String get librarySectionReadListen => 'Lesen & Hören';

  @override
  String get libraryGradedStories => 'Abgestufte Geschichten';

  @override
  String get libraryPodcasts => 'Podcasts';

  @override
  String get libraryWatch => 'Anschauen';

  @override
  String get librarySearchHint => 'Lektionen, Wörter, Geschichten suchen…';

  @override
  String get libraryFeaturedStory => 'HIGHLIGHT · GESCHICHTE';

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
  String libraryEstMinutes(int n) {
    return '~$n min';
  }

  @override
  String get lessonTypeWhatYouHear => 'Schreibe, was du hörst';

  @override
  String get lessonTapWhatYouHear => 'Tippe an, was du hörst';

  @override
  String get lessonTranslateSentence => 'Übersetze diesen Satz';

  @override
  String get lessonExplainThis => '💡 Erkläre das';

  @override
  String get lessonMatchPairs => 'Finde die Paare';

  @override
  String get lessonTypeAnswerHint => 'Gib deine Antwort ein…';

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
  String get lessonCompleteTitle => 'Lektion abgeschlossen!';

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
      'Lerne eine Sprache ohne Angst — in kleinen Portionen, mit Spaß und kostenlos. Bereit loszulegen?';

  @override
  String get onboardingHaveAccount => 'Ich habe schon ein Konto';

  @override
  String get onboardingTryWithoutAccount => 'Ohne Konto testen →';

  @override
  String get onboardingGetStarted => 'Los geht\'s';

  @override
  String get onboardingStartLearning => 'Jetzt lernen';

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
    return 'Ganz neu bei $language oder kennst du schon etwas?';
  }

  @override
  String get onboardingBrandNew => 'Ich bin ganz neu';

  @override
  String get onboardingBrandNewSub => 'Ganz von vorne anfangen';

  @override
  String get onboardingPlacementTest => 'Einstufungstest machen';

  @override
  String get onboardingPlacementTestSub =>
      '~3 Min. · springe direkt zu deinem Level';

  @override
  String onboardingXpPerDay(int xp) {
    return '$xp XP / Tag';
  }

  @override
  String get reasonTravel => 'Reisen';

  @override
  String get reasonCulture => 'Kultur';

  @override
  String get reasonCareer => 'Beruf';

  @override
  String get reasonFamilyFriends => 'Familie & Freunde';

  @override
  String get reasonBrainTraining => 'Gehirntraining';

  @override
  String get reasonJustForFun => 'Einfach so zum Spaß';

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
  String get profileSeeOnboarding => 'Onboarding-Ablauf ansehen ↗';

  @override
  String get profileNotSignedIn => 'Nicht angemeldet';

  @override
  String get profileCreateAccount => 'Kostenloses Konto erstellen';

  @override
  String get profileSaveProgress =>
      'Speichere deinen Fortschritt geräteübergreifend';

  @override
  String profileTodaysGoal(int today, int goal) {
    return 'Heutiges Ziel · $today/$goal XP';
  }

  @override
  String get profileViewProgress => 'Fortschritt ansehen →';

  @override
  String get profileUnlocked => 'Freigeschaltet';

  @override
  String questsResetsIn(int h, int m) {
    return 'Wird in ${h}h ${m}m zurückgesetzt';
  }

  @override
  String get questsDailyRefresh => 'Tägliche Aktualisierung';

  @override
  String get questsFreshMix => 'Ein frischer Mix aus 5 Fragen';

  @override
  String get questsServedFromQueue =>
      'Stammt aus deiner echten Warteschlange — bringt echte XP.';

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
      'Quests verfolgen deinen echten täglichen Fortschritt. Belohnungstruhen, Freundes-Quests und eine wöchentliche Rangliste erfordern eine Backend-Ökonomie — eine Entscheidung des Eigentümers (§6). Es werden keine falschen Belohnungen angezeigt.';

  @override
  String get questsRewardPending => 'Rewards soon';

  @override
  String get questsFriendQuest => 'Friend quest';

  @override
  String get questsFriendQuestSoon =>
      'Friend quests need a social backend — coming soon. No fake partners are shown.';

  @override
  String questsFriendQuestOutearn(String handle, int gap) {
    return 'Out-earn @$handle · $gap XP to catch up this week';
  }

  @override
  String questsCoopProgress(String handle, int done, int goal) {
    return 'Co-op with @$handle · $done of $goal lessons together';
  }

  @override
  String questsCoopInvited(String handle) {
    return '@$handle invited you to a co-op quest';
  }

  @override
  String get questsCoopAccept => 'Accept';

  @override
  String get questsCoopDecline => 'Decline';

  @override
  String questsCoopWaiting(String handle) {
    return 'Waiting for @$handle to accept';
  }

  @override
  String get questsCoopStart => 'Start a co-op quest';

  @override
  String get questsCoopStartHint => 'Finish 12 lessons together with a friend';

  @override
  String get questsCoopInviteTitle => 'Invite a friend';

  @override
  String get questsCoopInviteHint => 'friend\'s @handle';

  @override
  String get questsCoopInviteSend => 'Send';

  @override
  String get questsCoopInviteError =>
      'Couldn\'t start the quest. Check the @handle and try again.';

  @override
  String get questsStartRefresh => 'Tägliche Aktualisierung starten';

  @override
  String get questsStart => 'Start';

  @override
  String get questsPractisedToday => 'Heute geübt — Streak gesichert';

  @override
  String get questsEarnAnyXp => 'Verdiene heute beliebige XP';

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
    return 'Die besten $top steigen auf · die letzten $bottom steigen ab, wenn die Woche endet.';
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
      'Schließe Lektionen ab, baue einen Streak auf und steige im Level auf — deine Meilensteine erscheinen hier, sobald du sie dir wirklich verdient hast.';

  @override
  String get notifPushNote =>
      'Dies sind In-App-Meilensteine, die in dem Moment erscheinen, in dem du sie verdienst. Push-Benachrichtigungen und Erinnerungen sind eine Entscheidung des Eigentümers und noch nicht aktiviert — hier wird nichts vorgetäuscht.';

  @override
  String get shopPowerUps => 'Power-ups';

  @override
  String get shopStreakFreeze => 'Streak-Freeze';

  @override
  String get shopStreakFreezeDesc =>
      'Schützt deinen Streak für einen verpassten Tag. Wird automatisch verbraucht, wenn du dein Tagesziel verfehlst.';

  @override
  String shopOwned(int have, int max) {
    return 'Im Besitz $have/$max';
  }

  @override
  String get shopMaxedOut => 'Maximum erreicht';

  @override
  String shopBuyFor(int cost) {
    return 'Für $cost 💎 kaufen';
  }

  @override
  String get shopFreezeAdded => 'Streak-Freeze hinzugefügt 💪';

  @override
  String shopFreezeAtCap(int max) {
    return 'Du hast bereits die maximale Anzahl an Freezes ($max).';
  }

  @override
  String shopNotEnoughEarnCost(int cost) {
    return 'Nicht genug 💎 — verdiene $cost, indem du Lektionen abschließt.';
  }

  @override
  String get shopNotEnoughEarnMore =>
      'Nicht genug 💎 — verdiene mehr, indem du Lektionen abschließt.';

  @override
  String get shopEnergyRefill => 'Energie-Auffüllung';

  @override
  String get shopEnergyRefillDesc =>
      'Fülle deine Energie sofort wieder komplett auf. Energie dient nur der Anzeige — Lektionen werden nie blockiert.';

  @override
  String get shopAlreadyFull => 'Bereits voll';

  @override
  String get shopEnergyRefilled => 'Energie aufgefüllt ⚡';

  @override
  String get shopEnergyAlreadyFull => 'Deine Energie ist bereits voll.';

  @override
  String get shopStreakRepair => 'Streak-Reparatur';

  @override
  String get shopStreakRepairDesc =>
      'Streak verloren? Stelle ihn auf seine vorherige Länge wieder her und setze deinen Lauf fort.';

  @override
  String get shopStreakLapsed => 'Streak abgelaufen';

  @override
  String shopStreakDays(int days) {
    return '🔥 $days-Tage-Streak';
  }

  @override
  String shopRepairFor(int cost) {
    return 'Reparieren für $cost 💎';
  }

  @override
  String get shopStreakRestored => 'Streak wiederhergestellt 🔥';

  @override
  String get shopStreakSafe =>
      'Dein Streak ist sicher — im Moment gibt es nichts zu reparieren.';

  @override
  String get shopDoubleXp => 'Doppelte XP';

  @override
  String get shopDoubleXpDesc =>
      'Verdiene 15 Minuten lang 2× XP für jede Lektion.';

  @override
  String shopActiveLeft(int minutes) {
    return 'Aktiv · ${minutes}m verbleibend';
  }

  @override
  String get shopInactive => 'Inaktiv';

  @override
  String get shopActive => 'Aktiv';

  @override
  String get shopDoubleXpActive => 'Doppelte XP aktiv ✨';

  @override
  String get shopBoostRunning => 'Dein Boost läuft — XP werden verdoppelt.';

  @override
  String get shopBadgerOutfits => 'Dachs-Outfits';

  @override
  String get paywallTitle => 'RATEL PRO';

  @override
  String get paywallStartTrial => '7 Tage gratis testen';

  @override
  String paywallGoPro(String price) {
    return 'Hole dir Pro — $price/Mo.';
  }

  @override
  String get paywallRestore => 'Käufe wiederherstellen';

  @override
  String get paywallHero =>
      'Live-KI-Nachhilfe, werbefrei und Offline-Lektionen.';

  @override
  String get paywallAnnual => 'Jährlich';

  @override
  String get paywallMonthly => 'Monatlich';

  @override
  String get paywallTrialHow =>
      'Wie die 7-tägige kostenlose Testversion funktioniert';

  @override
  String get paywallTrialToday => 'Heute';

  @override
  String get paywallTrialTodayDesc =>
      'Vollständiger Pro-Zugang freigeschaltet. Keine Kosten.';

  @override
  String get paywallTrialDay5 => 'Tag 5';

  @override
  String get paywallTrialDay5Desc =>
      'Wir erinnern dich, bevor die Testphase endet.';

  @override
  String get paywallTrialDay7 => 'Tag 7';

  @override
  String paywallTrialDay7Desc(String price) {
    return '$price/Jahr beginnt, es sei denn, du kündigst.';
  }

  @override
  String get paywallFeatureLiveAi =>
      'Live-KI: Sprache, Tutor-Chat & Schreib-Feedback';

  @override
  String get paywallFeatureNoAds => 'Keine Werbung, nirgendwo';

  @override
  String get paywallFeatureOffline => 'Offline-Lektionen & Audio';

  @override
  String get paywallFeaturePronunciation => 'KI-Tipps fürs Aussprache-Coaching';

  @override
  String get paywallEverythingFree =>
      'Alles andere — Audio, Wiederholungen, Ligen, Rollenspiele und Aussprache auf dem Gerät — bleibt für alle kostenlos.';

  @override
  String get paywallYouArePro => 'Du nutzt RATEL PRO';

  @override
  String get paywallThanks =>
      'Danke für deine Unterstützung von Ratel. Du kannst dein Abo jederzeit unter Einstellungen → Abo verwalten verwalten oder kündigen.';

  @override
  String get paywallManage => 'Abo verwalten';

  @override
  String paywallFinePrint(String regions) {
    return 'Jederzeit in den Einstellungen kündbar. Die angezeigten Preise gelten für $regions; dein lokaler Preis wird von deinem App Store festgelegt.';
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
  String get questTitleOnFire => 'On fire';

  @override
  String get questDescOnFire => 'Verdiene das Dreifache deines Tagesziels';

  @override
  String get questTitleStreakKeeper => 'Streak-Retter';

  @override
  String get questDescStreakKeeper => 'Übe heute, um deinen Streak zu behalten';

  @override
  String get notifTitleLessons1 => 'Erste Lektion abgeschlossen';

  @override
  String get notifBodyLessons1 =>
      'Du hast deine erste Lektion beendet – ein toller Start!';

  @override
  String get notifTitleLessons5 => '5 Lektionen geschafft';

  @override
  String get notifBodyLessons5 =>
      'Du hast 5 Lektionen abgeschlossen. Bleib dran.';

  @override
  String get notifTitleLessons10 => '10 Lektionen geschafft';

  @override
  String get notifBodyLessons10 =>
      'Zehn Lektionen geschafft – du baust eine echte Gewohnheit auf.';

  @override
  String get notifTitleLessons25 => '25 Lektionen geschafft';

  @override
  String get notifBodyLessons25 =>
      'Fünfundzwanzig Lektionen abgeschlossen. Beeindruckende Hingabe!';

  @override
  String get notifTitleLessons50 => '50 Lektionen geschafft';

  @override
  String get notifBodyLessons50 =>
      'Fünfzig Lektionen – du bist auf einem sehr guten Weg.';

  @override
  String get notifTitleStreak3 => '3-Tage-Streak!';

  @override
  String get notifBodyStreak3 => 'Drei Tage in Folge. Beständigkeit ist alles.';

  @override
  String get notifTitleStreak7 => '7-Tage-Serie!';

  @override
  String get notifBodyStreak7 =>
      'Eine ganze Woche tägliches Üben. Hervorragend!';

  @override
  String get notifTitleStreak14 => '14-Tage-Streak!';

  @override
  String get notifBodyStreak14 =>
      'Zwei Wochen am Stück – du bist unaufhaltsam.';

  @override
  String get notifTitleStreak30 => '30-Tage-Streak!';

  @override
  String get notifBodyStreak30 =>
      'Ein ganzer Monat tägliches Üben. Unglaublich.';

  @override
  String get notifTitleXp100 => '100 XP verdient';

  @override
  String get notifBodyXp100 => 'Deine ersten hundert XP – du kommst in Fahrt.';

  @override
  String get notifTitleXp500 => '500 XP verdient';

  @override
  String get notifBodyXp500 => 'Fünfhundert XP. Du hängst dich richtig rein.';

  @override
  String get notifTitleXp1000 => '1.000 XP verdient';

  @override
  String get notifBodyXp1000 => 'Meilenstein von tausend XP erreicht!';

  @override
  String get notifTitleXp2500 => '2.500 XP verdient';

  @override
  String get notifBodyXp2500 =>
      'Zweitausendfünfhundert XP – ernsthafter Fortschritt.';

  @override
  String get notifTitleLevel1 => 'Level A2 erreicht';

  @override
  String get notifBodyLevel1 =>
      'Deine Fähigkeiten haben sich von A1 auf A2 verbessert. Weiter so!';

  @override
  String get notifTitleLevel2 => 'Level B1 erreicht';

  @override
  String get notifBodyLevel2 => 'Du bist jetzt auf mittlerem Niveau (B1).';

  @override
  String get notifTitleLevel3 => 'Level B2 erreicht';

  @override
  String get notifBodyLevel3 =>
      'Gehobenes Mittelstufenniveau (B2) erreicht. Brillant.';

  @override
  String get notifTitleLevel4 => 'Level C1 erreicht';

  @override
  String get notifBodyLevel4 =>
      'Fortgeschritten (C1) – dein Englisch ist stark.';

  @override
  String get notifTitleLevel5 => 'Level C2 erreicht';

  @override
  String get notifBodyLevel5 => 'Meisterschaft (C2) – die Spitze der Skala!';

  @override
  String get achTitleFirstSteps => 'Erste Schritte';

  @override
  String get achTitleScholar => 'Gelehrter';

  @override
  String get achTitleWildfire => 'Lauffeuer';

  @override
  String get achTitlePointMaker => 'Punktesammler';

  @override
  String get achTitleCollector => 'Sammler';

  @override
  String get achTitleRisingStar => 'Aufgehender Stern';

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
  String get cefrNameUpperIntermediate => 'Gehobene Mittelstufe';

  @override
  String get cefrNameAdvanced => 'Fortgeschritten';

  @override
  String get cefrNameProficient => 'Meisterschaft';

  @override
  String leaguesTierLeague(String tier) {
    return '$tier-Liga';
  }

  @override
  String leaguesYoureIn(String tier) {
    return 'Du bist in $tier · die besten 7 steigen jede Woche auf';
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
      'Level, XP, Lektionen, Streak und gespeicherte Wörter sind der echte Engine-Status – sie beginnen bei einem neuen Konto bei null.';

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
    return '$count fällig für verteilte Wiederholung';
  }

  @override
  String get practiceAllUpToDate =>
      'Alle Wiederholungen sind auf dem neuesten Stand';

  @override
  String practiceCaughtUp(String tail) {
    return 'Alles erledigt – im Moment ist nichts fällig$tail.';
  }

  @override
  String practiceNextTail(String when) {
    return ' · als Nächstes $when';
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
      'Wiederholungen werden von der echten FSRS-6 Spaced-Repetition-Engine geplant. Fälligkeitsdaten bleiben für diese Sitzung erhalten; sie über Neustarts hinweg zu speichern, ist ein Go-Live-Schritt – hier ist nichts erfunden.';

  @override
  String get practiceNoSavedWords => 'Noch keine gespeicherten Wörter';

  @override
  String get practiceSaveWordHint =>
      'Speichere ein Wort, während du eine Lektion übst, und es landet hier als Karteikarte. Wiederholungen werden dann von der echten FSRS-Spaced-Repetition-Engine geplant – nichts ist vorausgefüllt.';

  @override
  String get practiceStartLesson => 'Lektion starten';

  @override
  String practiceWordOf(int n, int total) {
    return 'Wort $n von $total';
  }

  @override
  String get practiceShowAnswer => 'Antwort anzeigen';

  @override
  String get practiceRecallHint =>
      'Erinnere dich an die Bedeutung und bewerte dann, wie gut du dich erinnert hast.';

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
      'FSRS-6 plant die nächste Wiederholung basierend auf deiner Bewertung';

  @override
  String get practiceReviewComplete => 'Wiederholung abgeschlossen';

  @override
  String practiceReviewedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Du hast $count Wörter wiederholt. Sie werden von FSRS neu geplant.',
      one: 'Du hast 1 Wort wiederholt. Es wird von FSRS neu geplant.',
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
    return 'in $hours h';
  }

  @override
  String practiceRelInMinutes(int minutes) {
    return 'in $minutes m';
  }

  @override
  String get practiceRelSoon => 'bald';

  @override
  String get progressTitle => 'Fortschritt';

  @override
  String get progressYourLevel => 'YOUR LEVEL';

  @override
  String get progressShareMilestone => 'Meilenstein teilen';

  @override
  String get progressLast7Days => 'Letzte 7 Tage';

  @override
  String get progressAccuracyRetention => 'Genauigkeit & Merkfähigkeit';

  @override
  String get progressHonestyNote =>
      'Alles hier ist ein realer, aufgezeichneter Status — Level, Fähigkeit, gespeicherte Wörter, XP, Lektionen, Streak, deine 7-Tage-Historie, Genauigkeit und Lernzeit beginnen alle bei null und wachsen, während du lernst. Die Merkfähigkeit ist die vorhergesagte Erinnerung dieser Sitzung (der dauerhafte sitzungsübergreifende Planer ist Live-Verkabelung); nichts ist erfunden.';

  @override
  String progressShareText(int streak, int xp, int lessons) {
    return '🦡 RATEL\n🔥 $streak Tage Streak · ⚡ $xp XP · 📘 $lessons Lektionen\nLernen auf learnwithratel.com';
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
  String get progressStatDayStreak => 'Tage-Streak';

  @override
  String get progressStatTotalXp => 'Gesamt-XP';

  @override
  String get progressStatTodaysXp => 'Heutige XP';

  @override
  String get progressStatCefrLevel => 'GER-Niveau';

  @override
  String get progressAccuracy => 'Genauigkeit';

  @override
  String get progressStudyTime => 'Lernzeit';

  @override
  String get progressRetention => 'Merkfähigkeit';

  @override
  String get progressNoData => 'Noch keine Daten';

  @override
  String get progressAccuracyEmpty =>
      'Beantworte bewertete Übungen, um zu beginnen';

  @override
  String progressAccuracyDetail(int correct, int total) {
    return '$correct von $total richtig';
  }

  @override
  String get progressTimeEmpty => 'Hier summiert sich die Zeit in Lektionen';

  @override
  String get progressTimeDetail => 'über alle deine Lektionen hinweg';

  @override
  String get progressRetentionEmpty =>
      'Wiederhole Einträge, um die vorhergesagte Erinnerung zu sehen';

  @override
  String progressRetentionDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'vorhergesagte 1-Tages-Erinnerung · $count Elemente in dieser Sitzung',
      one: 'vorhergesagte 1-Tages-Erinnerung · 1 Element in dieser Sitzung',
    );
    return '$_temp0';
  }

  @override
  String progressWeekTotal(int xp) {
    return '$xp XP · letzte 7 Tage';
  }

  @override
  String get progressNoXpYet => 'Noch keine XP aufgezeichnet';

  @override
  String get progressChartEmptyNote =>
      'Schließe eine Lektion ab, um deine 7-Tage-Historie zu starten — inaktive Tage bleiben bei null, nichts ist erfunden.';

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
  String get searchHint => 'Suche Lektionen, Wörter, Geschichten …';

  @override
  String get searchRecent => 'Zuletzt gesucht';

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
      'Durchsucht Titel, Tags und Lektionsinhalte deines Kurses, gespeicherte Wörter und Seiten. Ein Server-Inhaltsindex und Trends sind die verbleibenden R-L12 Fast-Follows — nichts hier ist vorgetäuscht.';

  @override
  String get searchNoMatchNote =>
      'Durchsucht deine veröffentlichten Kurs-Lektionen, gespeicherten Wörter und App-Seiten (Titel + Tags). Geschichten/Podcasts und Volltext sind die R-L12 Fast-Follows — niemals vorgetäuscht.';

  @override
  String get searchFooterNote =>
      'Titel + Tags zum Start. Volltext, Geschichten/Podcasts und Multi-Kurs-Umfang sind die R-L12 Fast-Follows — niemals vorgetäuscht.';

  @override
  String get searchDestPracticeHub => 'Übungszentrum';

  @override
  String get searchDestPracticeHubSub => 'Fehler, schwache Wörter & Übungen';

  @override
  String get searchDestAiTutor => 'KI-Tutor';

  @override
  String get searchDestAiTutorSub => 'Sprechen, Chat & Rollenspiel';

  @override
  String get searchDestAdventures => 'Abenteuer';

  @override
  String get searchDestAdventuresSub => 'Echte Unterhaltungen — kostenlos';

  @override
  String get searchDestLeagues => 'Ligen';

  @override
  String get searchDestLeaguesSub => 'Deine wöchentliche Liga';

  @override
  String get searchDestQuests => 'Quests';

  @override
  String get searchDestQuestsSub => 'Tagesziele & Quests';

  @override
  String get searchDestProgress => 'Fortschritt';

  @override
  String get searchDestProgressSub => 'Deine Statistiken & dein Streak';

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
      'Gestaltet die gesamte App neu — tippen für eine Live-Vorschau';

  @override
  String themesVehicle(String vehicle) {
    return 'Fahrzeug · $vehicle';
  }

  @override
  String get tutorHeader => 'Übe ein echtes Gespräch';

  @override
  String get tutorHeaderSub =>
      'Wähle eine Szene und chatte mit Ratel — keine falschen Antworten, einfach nur Übung.';

  @override
  String get tutorTalkTitle => 'Mit Ratel sprechen';

  @override
  String get tutorTalkSub => 'Live-Sprach- & Video-Sprechübungen';

  @override
  String get tutorChatTitle => 'Chatte mit Ratel';

  @override
  String get tutorChatSub => 'KI-Chat · Schreib-Feedback';

  @override
  String get tutorRoleplayTitle => 'Rollenspiel-Szenen';

  @override
  String get tutorRoleplayGuided => 'Geführte Rollenspiel-Unterhaltungen';

  @override
  String tutorScenesCount(int count) {
    return '$count Szenen';
  }

  @override
  String get tutorUnlockPro => 'RATEL PRO freischalten';

  @override
  String get tutorRelayNote =>
      'Live-KI-Nachhilfe läuft über ein moderiertes, kostenüberwachtes Relay und ist eine RATEL PRO Funktion. Antworten werden niemals simuliert — ein Modus startet erst, wenn sowohl PRO als auch das Relay aktiv sind.';

  @override
  String get tutorStatusReadyPro =>
      'PRO aktiv und der Live-Tutor ist verbunden — wähle einen Modus, um zu beginnen.';

  @override
  String get tutorStatusReadyFree =>
      'Der Live-Tutor ist verbunden. Live-Nachhilfe ist eine RATEL PRO Funktion.';

  @override
  String get tutorStatusOffline =>
      'Der moderierte Live-Tutor ist in diesem Build noch nicht verbunden — Live-Nachhilfe wird in einem späteren Schritt aktiviert. Nichts weiter unten ist simuliert.';

  @override
  String get tutorAnnounceNeedsPro =>
      'RATEL PRO schaltet Live-KI-Nachhilfe frei.';

  @override
  String get tutorAnnounceNeedsRelay =>
      'KI-Nachhilfe verbindet sich, sobald das moderierte Relay aktiviert ist.';

  @override
  String get tutorAnnounceStarting => 'Deine Sitzung wird gestartet …';

  @override
  String get adventuresTitle => 'Abenteuer';

  @override
  String get adventuresFreeChip => 'KOSTENLOS';

  @override
  String get adventuresHeaderSub => 'Erkunde eine Welt · rede dich hindurch';

  @override
  String get adventuresHeroTitle => 'Wähle einen Ort und tauche ein';

  @override
  String get adventuresHeroSub =>
      'Jede Szene ist eine echte Unterhaltung — keine falschen Antworten und es ist immer kostenlos.';

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
  String get adventureOpeningScene => 'ERÖFFNUNGSSZENE';

  @override
  String get adventureStart => 'Abenteuer starten';

  @override
  String get adventurePlayerFallbackTitle => 'Abenteuer';

  @override
  String get adventureTheEnd => '🏁 Das Ende';

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
      'Gut gemacht! +15 XP · +5 💎 verdient — erkunde die nächste Szene, wann immer du möchtest.';

  @override
  String adventureDistrictProgress(int done, int total) {
    return '$done/$total erkundet';
  }

  @override
  String get adventureDistrictDone => '✓ Fertig';

  @override
  String get adventureDistrictCafe => 'Café & Food';

  @override
  String get adventureDistrictMarket => 'Market Square';

  @override
  String get adventureDistrictMove => 'On the Move';

  @override
  String get adventureDistrictFriends => 'Making Friends';

  @override
  String get adventuresEmpty => 'Noch keine Abenteuer in diesem Kurs.';

  @override
  String get authWelcomeTitle => 'Willkommen bei Ratel';

  @override
  String get authWelcomeSubtitle =>
      'Lektionen, Geschichten, Podcasts und mehr —\nwähle, wie du anfangen möchtest.';

  @override
  String get authCreateFreeAccount => 'Kostenloses Konto erstellen';

  @override
  String get authAlreadyHaveAccount => 'Ich habe schon ein Konto';

  @override
  String get authSettingUp => 'Wird eingerichtet …';

  @override
  String get authContinueAsGuest => 'Als Gast fortfahren';

  @override
  String get authGuestNote =>
      'Der Gastfortschritt bleibt auf diesem Gerät — erstelle jederzeit in den Einstellungen ein kostenloses Konto, um ihn überall zu behalten.';

  @override
  String get authEnterYourEmail => 'Gib deine E-Mail-Adresse ein';

  @override
  String get authEnterValidEmail => 'Gib eine gültige E-Mail-Adresse ein';

  @override
  String get authEnterYourPassword => 'Gib dein Passwort ein';

  @override
  String get authCouldNotSignIn =>
      'Anmeldung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get authSomethingWentWrong =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get authSocialComingSoon =>
      'Social Sign-in (Google / Apple) kommt bald.';

  @override
  String get authResetTitle => 'Setze dein Passwort zurück';

  @override
  String get authWelcomeBack => 'Willkommen zurück!';

  @override
  String get authResetSubtitle =>
      'Gib deine E-Mail-Adresse ein und wir senden dir einen Link zum Zurücksetzen.';

  @override
  String get authPickUpWhereYouLeft =>
      'Mache dort weiter, wo du aufgehört hast';

  @override
  String get authEmailHint => 'E-Mail';

  @override
  String get authPasswordHint => 'Passwort';

  @override
  String get authForgotPassword => 'Passwort vergessen?';

  @override
  String get authSendResetLink => 'Link zum Zurücksetzen senden';

  @override
  String get authLogIn => 'Anmelden';

  @override
  String get authBackToLogIn => 'Zurück zur Anmeldung';

  @override
  String get authNewToRatel => 'Neu bei Ratel? ';

  @override
  String get authSignUp => 'Registrieren';

  @override
  String get authCheckYourInbox => 'Überprüfe deinen Posteingang';

  @override
  String authResetSent(String email) {
    return 'Wir haben einen Link zum Zurücksetzen des Passworts an $email gesendet. Öffne ihn, um ein neues Passwort zu wählen.';
  }

  @override
  String get authCreatePassword => 'Passwort erstellen';

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
  String get authAlreadyAccountLead => 'Hast du bereits ein Konto? ';

  @override
  String get authSignIn => 'Anmelden';

  @override
  String get authConfirmEmail => 'Bestätige deine E-Mail-Adresse';

  @override
  String authConfirmSent(String email) {
    return 'Wir haben einen Bestätigungslink an $email gesendet. Tippe darauf, um dein Konto zu aktivieren, und komme dann zurück, um dich anzumelden.';
  }

  @override
  String get authContinueGoogle => 'Weiter mit Google';

  @override
  String get authContinueApple => 'Weiter mit Apple';

  @override
  String get authOr => 'oder';

  @override
  String get authUnavailableNote =>
      'Konten sind in dieser Version noch nicht verfügbar — du kannst als Gast weiterlernen. Die Anmeldung wird aktiviert, sobald das Backend konfiguriert ist.';

  @override
  String get liveMute => 'Stummschalten';

  @override
  String get liveUnmute => 'Stummschaltung aufheben';

  @override
  String commonDurSeconds(int s) {
    return '${s}s';
  }

  @override
  String commonDurMinutes(int m) {
    return '${m}m';
  }

  @override
  String commonDurHours(int h) {
    return '${h}h';
  }

  @override
  String commonDurHoursMinutes(int h, int m) {
    return '${h}h ${m}m';
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
      'Hauptschalter — schaltet alle Animationen aus';

  @override
  String get settingsHighContrast => 'Hoher Kontrast';

  @override
  String get settingsNotifPush => 'Push-Benachrichtigungen';

  @override
  String get settingsNotifStreak => 'Streak-Erinnerungen';

  @override
  String get settingsNotifLeague => 'Liga-Updates';

  @override
  String get settingsNotifFriend => 'Freundesaktivitäten';

  @override
  String get settingsNotifFootnote =>
      'Deine Auswahl ist jetzt gespeichert — die Zustellung wird aktiviert, sobald Push-Benachrichtigungen veröffentlicht werden.';

  @override
  String get settingsCourse => 'Kurs';

  @override
  String get settingsTheme => 'Design';

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
      'Du lernst als Gast — registriere dich, um deinen Fortschritt zu speichern';

  @override
  String settingsCouldNotOpen(String url) {
    return 'Konnte $url nicht öffnen';
  }

  @override
  String get settingsThemeSystem => 'Geräteeinstellung';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get mediaReadAloud => 'Laut vorlesen';

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
  String get mediaLoading => 'Laden…';

  @override
  String get mediaPause => 'Pause';

  @override
  String get storiesTitle => 'Geschichten';

  @override
  String get storiesSub =>
      'Lesen & Hören — abgestufte Geschichten mit Vorlesefunktion im Browser.';

  @override
  String get storiesEmpty => 'Noch keine Geschichten in diesem Kurs.';

  @override
  String get storyFallbackTitle => 'Geschichte';

  @override
  String get podcastsSub =>
      'Hören — abgestufte Podcasts mit echtem Audio und einem Transkript.';

  @override
  String get podcastsEmpty => 'Noch keine Podcasts in diesem Kurs.';

  @override
  String get podcastFallbackTitle => 'Podcast';

  @override
  String get podcastPlayEpisode => 'Episode abspielen';

  @override
  String get watchSub =>
      'Ansehen -- kurze Clips mit Transkript und Verständnisfragen.';

  @override
  String get watchEmpty => 'Noch keine Video-Lektionen in diesem Kurs.';

  @override
  String get watchWebOnly => 'Video wird in der Web-App abgespielt';

  @override
  String get libraryAdventuresSub =>
      'Erkunde eine lebendige Welt und sprich dich durch reale Szenen.';

  @override
  String get roleplaySub =>
      'Übe echte Unterhaltungen -- wähle die richtige Antwort, erhalte sofortiges Feedback.';

  @override
  String get roleplayEmpty => 'Noch keine Rollenspiele in diesem Kurs.';

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
  String get roleplayYourReply => 'Deine Antwort:';

  @override
  String get roleplaySceneComplete => '🎉 Szene abgeschlossen!';

  @override
  String get roleplayBack => 'Zurück zu Rollenspielen';

  @override
  String get liveRoleplayTitle => 'Live-Rollenspiel';

  @override
  String get liveRoleplayCardSub => 'Sprich dich aus mit Ratel — echte Stimme';

  @override
  String get liveIntro =>
      'Sprich dich aus mit Ratel — Live-Sprachrollenspiel. Wähle eine Szene oder führe einfach ein Gespräch.';

  @override
  String get liveFreeConversation => 'Freies Gespräch';

  @override
  String get liveFreeConversationSub => 'Kein Skript — einfach reden';

  @override
  String get liveRoleplayScene => 'Spiele eine Szene';

  @override
  String get liveReconnecting => 'Verbindung wird wiederhergestellt…';

  @override
  String get liveConnectionLost =>
      'Verbindung unterbrochen — die Live-Sitzung wurde abgebrochen.';

  @override
  String get liveReconnect => 'Neu verbinden';

  @override
  String get liveConnecting => 'Verbinde…';

  @override
  String get liveStartTalking => 'Beginne zu sprechen';

  @override
  String get liveSceneEndedNote =>
      'Szene beendet. Starte jederzeit neu — deine Live-Minuten sind budgetiert, niemals still.';

  @override
  String get liveStartAgain => 'Neu starten';

  @override
  String get liveProGate =>
      'Live-Sprachrollenspiele sind ein RATEL PRO-Feature — echte Gespräche, Live-Feedback, kostengeschützte Minuten.';

  @override
  String get liveUnlockPro => 'RATEL PRO freischalten';

  @override
  String get liveNotEnabled =>
      'Live-Sprache ist in dieser Version noch nicht aktiviert — sie wird in einem späteren Schritt freigeschaltet. Nichts hier wird simuliert.';

  @override
  String get livePhaseIdle =>
      'Bereit, wenn du es bist — es ist ein echter Live-Anruf.';

  @override
  String get livePhaseListening => 'Hört zu — du bist dran.';

  @override
  String get livePhaseSpeaking => 'Ratel spricht — misch dich jederzeit ein.';

  @override
  String get livePhaseClosed => 'Szene beendet.';

  @override
  String get liveEndScene => 'Szene beenden';

  @override
  String get liveYou => 'Du';

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
  String get liveStartFailed =>
      'Die Live-Sitzung konnte nicht gestartet werden — versuche es erneut.';

  @override
  String get friendsHandleInvalid =>
      'Gib ein Handle wie @mia ein (2–20 Buchstaben, Zahlen, _).';

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
  String get friendsActivity => 'Freundesaktivität';

  @override
  String get friendsFootnote =>
      'Dein Social Graph ist echt und für dich privat. Freundschaftsanfragen werden zugestellt und \"hat dich überholt\" wird angezeigt, sobald der dauerhafte benutzerübergreifende Graph live geht — derselbe Live-Gang wie bei jedem anderen dauerhaften Zähler. Nichts hier ist vorgetäuscht.';

  @override
  String get friendsAddHint => 'Füge einen Freund per @handle hinzu…';

  @override
  String get friendsAccept => 'Akzeptieren';

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
      'Füge jemanden über sein @handle hinzu, um Fortschritte zu teilen.';

  @override
  String get profileLearner => 'Lernender';

  @override
  String get profileGuest => 'Gast';

  @override
  String get editProfileSaved => 'Profil gespeichert';

  @override
  String get editProfileHandleSet =>
      'Gespeichert — dein @handle ist festgelegt.';

  @override
  String get editProfileSignInForHandle =>
      'Name gespeichert. Melde dich an, um dein @handle zu beanspruchen.';

  @override
  String get editProfileHandleFailed =>
      'Dieses @handle konnte nicht festgelegt werden.';

  @override
  String get editProfileDisplayName => 'Anzeigename';

  @override
  String get editProfileNameHint => 'Wie sollen wir dich nennen?';

  @override
  String get editProfileNameNote =>
      'Wird in deinem Profil angezeigt. Auf diesem Gerät gespeichert — es wird mit deinem Konto synchronisiert, wenn du dich anmeldest.';

  @override
  String get editProfileHandle => 'Dein @handle';

  @override
  String get editProfileHandleNote =>
      'Andere Lernende fügen dich über dein @handle hinzu (2–20 Buchstaben, Zahlen oder _). Um es zu beanspruchen, musst du angemeldet sein.';

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
    return '$count-Tage-Streak';
  }

  @override
  String get feedPassedYou => 'hat dich in deiner Liga überholt';

  @override
  String get leaguesSoloCaption => 'diese Woche · Solo-Gruppe';

  @override
  String leaguesXpToRank(int xp, int rank) {
    return '$xp XP bis Rang $rank';
  }

  @override
  String get leaguesLeading => 'führt deine Gruppe an';

  @override
  String get leaguesSoloNote =>
      'Du bist diese Woche der einzige Lernende in deiner Gruppe. Echte Rivalen kommen hinzu, während Ratel wächst — keine Bots, keine gefälschten Bestenlisten. Verdiene weiter XP, um bereit zum Aufsteigen zu sein, wenn die Woche zurückgesetzt wird.';

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
  String get worldVehicleForest => 'Blattgleiter';

  @override
  String get worldLabelCandy => 'Süßigkeiten';

  @override
  String get worldVehicleCandy => 'Ballon';

  @override
  String get worldLabelNeon => 'Neonstadt';

  @override
  String get worldVehicleNeon => 'Hoverbike';

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
  String get worldVehicleSakura => 'Blütendrachen';

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
  String get worldVehicleVolcano => 'Magmaboard';

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
  String get worldVehicleReef => 'Glasbodenboot';

  @override
  String get worldLabelMeadow => 'Wiese';

  @override
  String get worldVehicleMeadow => 'Fahrrad';

  @override
  String get worldLabelDawn => 'Morgengrauen';

  @override
  String get worldVehicleDawn => 'Heißluftballon';

  @override
  String get worldLabelBeach => 'Tropischer Strand';

  @override
  String get worldVehicleBeach => 'Katamaran';

  @override
  String get worldLabelMars => 'Mars';

  @override
  String get worldVehicleMars => 'Rover';

  @override
  String get worldLabelJungle => 'Regenwald';

  @override
  String get worldVehicleJungle => 'Zipline';

  @override
  String get worldLabelCyberrain => 'Cyber-Regen';

  @override
  String get worldVehicleCyberrain => 'Hoverbike';

  @override
  String get worldLabelAbyss => 'Tiefsee';

  @override
  String get worldVehicleAbyss => 'Bathysphäre';

  @override
  String get worldLabelAlpine => 'Alpin';

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
  String get worldLabelNebula => 'Sternennebel';

  @override
  String get worldVehicleNebula => 'Sternenkreuzer';

  @override
  String get worldLabelSandstorm => 'Sandsturm';

  @override
  String get worldVehicleSandstorm => 'Karawane';

  @override
  String get worldLabelCherrynight => 'Kirschblütennacht';

  @override
  String get worldVehicleCherrynight => 'Papierlaterne';

  @override
  String get shopYourBadger => 'Dein Dachs';

  @override
  String get shopDiamondsNote =>
      'Eine Echtgeld-💎-Aufladung kommt bald. Diamanten verdienst du, indem du Lektionen abschließt und dein Tagesziel erreichst, und jedes Power-up hier kostet echte Diamanten — nichts ist gefälscht.';

  @override
  String get shopProBannerSub =>
      'Live-KI, keine Werbung, offline · 7 Tage kostenlos testen';

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
    return '$annual/Jahr  ·  $perMonth/Monat  ·  7 Tage kostenlos';
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
  String get paywallTerms => 'Nutzungsbedingungen';

  @override
  String get paywallPrivacy => 'Datenschutz';

  @override
  String get paywallNothingToRestore =>
      'Nichts zum Wiederherstellen — die Abrechnung ist in diesem Build noch nicht aktiv.';

  @override
  String get contentUnavailableTitle => 'Inhalt nicht verfügbar';

  @override
  String contentUnavailableBody(String noun) {
    return 'Dieser Inhalt ($noun) ist im Moment nicht verfügbar. Wenn du offline bist, überprüfe deine Verbindung und versuche es erneut.';
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
  String get commonGoBack => 'Zurückgehen';

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
    return 'Basierend auf $count Fragen haben wir dich auf $level eingestuft. Du kannst das später jederzeit anpassen.';
  }

  @override
  String get lessonTypedNote => 'Tippe deine Antwort in der Zielsprache ein.';

  @override
  String lessonHintMinWords(int count) {
    return 'mindestens $count Wörter';
  }

  @override
  String lessonHintUseWords(String words) {
    return 'verwende: $words';
  }

  @override
  String get lessonHintEndPunct => 'beende mit . ! oder ?';

  @override
  String get lessonPlayAudio => 'Audio abspielen';

  @override
  String get lessonPlaySlowly => 'Langsam abspielen';

  @override
  String get lessonAudioUnavailable =>
      'Audio nicht verfügbar — lies die Aufgabenstellung.';

  @override
  String get lessonPlaybackSpeed => 'Wiedergabegeschwindigkeit';

  @override
  String get authAccountsUnavailable =>
      'Konten sind in diesem Build noch nicht verfügbar — lerne als Gast weiter.';

  @override
  String get liveNotEnabledShort =>
      'Live-KI ist in diesem Build nicht aktiviert.';

  @override
  String get liveMicUnavailable =>
      'Mikrofon nicht verfügbar — erlaube den Mikrofonzugriff, um mit dem Tutor zu sprechen.';

  @override
  String get liveUnavailable => 'Live-KI ist im Moment nicht verfügbar.';

  @override
  String get liveNeedsPro => 'Live-KI ist Teil von RATEL PRO.';

  @override
  String get liveMinutesUsed =>
      'Du hast deine Live-Minuten für diesen Monat aufgebraucht.';

  @override
  String get commonNetworkError =>
      'Server konnte nicht erreicht werden. Versuche es erneut.';

  @override
  String get friendsHandleTaken => 'Dieses @handle ist bereits vergeben.';

  @override
  String get friendsHandleFormat =>
      'Verwende 2–20 Buchstaben, Zahlen oder _ für dein @handle.';

  @override
  String get friendsSignInForHandle =>
      'Melde dich an, um dir dein @handle zu sichern.';

  @override
  String get friendsSetOwnHandleFirst =>
      'Lege zuerst dein eigenes @handle fest (Profil bearbeiten).';

  @override
  String get paywallCheckoutUnavailable =>
      'Die Kasse öffnet beim Start — die Store-Abrechnung ist in diesem Build noch nicht aktiv.';

  @override
  String get settingsManageUnavailable =>
      'Verwalte oder kündige in den Abonnement-Einstellungen deines Geräts — die In-App-Verknüpfung öffnet sich beim Start.';

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
      'Your day count and freezes are your real numbers. Active days are days you earned XP — nothing is invented.';

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
