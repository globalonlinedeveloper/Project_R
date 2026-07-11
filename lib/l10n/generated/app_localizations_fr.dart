// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navHome => 'Accueil';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navLeagues => 'Ligues';

  @override
  String get navQuests => 'Quêtes';

  @override
  String get navProfile => 'Profil';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSectionLearning => 'Apprentissage';

  @override
  String get settingsSectionSubscription => 'Abonnement';

  @override
  String get settingsSectionAccessibility => 'Accessibilité';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsSectionAppearanceAccount => 'Apparence et compte';

  @override
  String get settingsAppLanguage => 'Langue de l\'application';

  @override
  String get settingsAppLanguageSystem => 'Par défaut du système';

  @override
  String get homeCourseLoadingTitle => 'Ton cours se prépare';

  @override
  String get homeCourseLoadingBody =>
      'Les leçons apparaîtront ici une fois le contenu du cours chargé.';

  @override
  String get homeGuideChip => 'Guide';

  @override
  String get homeStartNode => 'COMMENCER';

  @override
  String get homeUnitGuideHeader => 'GUIDE DE L\'UNITÉ';

  @override
  String get commonDone => 'Terminé';

  @override
  String homeUnitKicker(String unit) {
    return 'UNITÉ · $unit';
  }

  @override
  String homeLessonMeta(int num, int count, String exercises) {
    return 'Leçon $num sur $count · $exercises.';
  }

  @override
  String homeQuickExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercices rapides',
      one: '$count exercice rapide',
    );
    return '$_temp0';
  }

  @override
  String get homeEnergyChip => '−1 ⚡ énergie';

  @override
  String get homeXpChip => '+20 XP';

  @override
  String get homeStartLesson => 'Commencer la leçon';

  @override
  String get homeTutorChip => 'Tuteur';

  @override
  String get libraryAiTutor => 'Tuteur IA';

  @override
  String get libraryAiTutorSub =>
      'Parle, discute et joue des scènes — retours sur l\'écrit';

  @override
  String get libraryRoleplay => 'Jeu de rôle';

  @override
  String get libraryRoleplaySub =>
      'Entraîne-toi à répondre — noté, toujours gratuit';

  @override
  String get librarySectionPractice => 'Entraînement';

  @override
  String get libraryPracticeHub => 'Centre d\'entraînement';

  @override
  String get libraryPracticeHubSub =>
      'Erreurs, mots fragiles et exercices · GRATUIT';

  @override
  String get librarySectionReadListen => 'Lire et écouter';

  @override
  String get libraryGradedStories => 'Histoires graduées';

  @override
  String get libraryPodcasts => 'Podcasts';

  @override
  String get libraryWatch => 'Regarder';

  @override
  String get librarySearchHint =>
      'Cherche des leçons, des mots, des histoires…';

  @override
  String get libraryFeaturedStory => 'À LA UNE · HISTOIRE';

  @override
  String commonLevel(String cefr) {
    return 'Niveau $cefr';
  }

  @override
  String get libraryReadNow => 'Lire maintenant';

  @override
  String get libraryNewExplore => 'NOUVEAU · EXPLORER';

  @override
  String get libraryAdventures => 'Aventures';

  @override
  String get libraryStartExploring => 'Commence à explorer →';

  @override
  String get libraryKindStory => 'Histoire';

  @override
  String get libraryKindPodcast => 'Podcast';

  @override
  String get libraryKindVideo => 'Vidéo';

  @override
  String get libraryAllStories => 'Toutes les histoires';

  @override
  String get libraryAllPodcasts => 'Tous les podcasts';

  @override
  String get libraryAllVideos => 'Toutes les vidéos';

  @override
  String get lessonTypeWhatYouHear => 'Écris ce que tu entends';

  @override
  String get lessonTapWhatYouHear => 'Touche ce que tu entends';

  @override
  String get lessonTranslateSentence => 'Traduis cette phrase';

  @override
  String get lessonTypeAnswerHint => 'Écris ta réponse…';

  @override
  String get lessonWriteAnswerHint => 'Rédige ta réponse…';

  @override
  String get lessonContinue => 'Continuer';

  @override
  String get lessonSkip => 'Passer';

  @override
  String get lessonCheck => 'Vérifier';

  @override
  String get lessonNicelyDone => '✓ Bien joué !';

  @override
  String get lessonNotQuite => '✕ Pas tout à fait';

  @override
  String lessonAnswerReveal(String answer) {
    return 'Réponse : $answer';
  }

  @override
  String get lessonCompleteKicker => 'LEÇON TERMINÉE';

  @override
  String get lessonCompleteTitle => 'Leçon terminée !';

  @override
  String lessonCompleteSummary(int correct, int graded, String level) {
    return '$correct sur $graded justes · maintenant $level';
  }

  @override
  String get lessonStatTotalXp => 'XP TOTAL';

  @override
  String get lessonStatAccuracy => 'PRÉCISION';

  @override
  String get lessonStatTime => 'TEMPS';

  @override
  String get onboardingWelcomeTitle => 'Salut, moi c\'est Ratel !';

  @override
  String get onboardingWelcomeBody =>
      'Apprends une langue sans peur — par petites bouchées, fun et gratuit. Prêt à creuser ?';

  @override
  String get onboardingHaveAccount => 'J\'ai déjà un compte';

  @override
  String get onboardingTryWithoutAccount => 'Essayer sans compte →';

  @override
  String get onboardingGetStarted => 'C\'est parti';

  @override
  String get onboardingStartLearning => 'Commencer à apprendre';

  @override
  String get onboardingLanguageTitle => 'Que veux-tu apprendre ?';

  @override
  String get onboardingLanguageSubtitle => '52 langues disponibles';

  @override
  String get onboardingReasonTitle => 'Pourquoi apprends-tu ?';

  @override
  String get onboardingGoalTitle => 'Choisis un objectif quotidien';

  @override
  String get onboardingPlacementTitle => 'Trouve ton point de départ';

  @override
  String onboardingPlacementBody(String language) {
    return 'Débutant en $language, ou tu en sais déjà un peu ?';
  }

  @override
  String get onboardingBrandNew => 'Je débute complètement';

  @override
  String get onboardingBrandNewSub => 'Commencer tout au début';

  @override
  String get onboardingPlacementTest => 'Passer un test de niveau';

  @override
  String get onboardingPlacementTestSub => '~3 min · rejoins ton niveau';

  @override
  String onboardingXpPerDay(int xp) {
    return '$xp XP / jour';
  }

  @override
  String get reasonTravel => 'Voyages';

  @override
  String get reasonCulture => 'Culture';

  @override
  String get reasonCareer => 'Carrière';

  @override
  String get reasonFamilyFriends => 'Famille et amis';

  @override
  String get reasonBrainTraining => 'Entraînement cérébral';

  @override
  String get reasonJustForFun => 'Juste pour le fun';

  @override
  String get goalCasual => 'Tranquille';

  @override
  String get goalRegular => 'Régulier';

  @override
  String get goalSerious => 'Sérieux';

  @override
  String get goalIntense => 'Intense';

  @override
  String get langNameSpanish => 'Espagnol';

  @override
  String get langNameFrench => 'Français';

  @override
  String get langNameJapanese => 'Japonais';

  @override
  String get langNameTamil => 'Tamoul';

  @override
  String get langNameGerman => 'Allemand';

  @override
  String get langNameKorean => 'Coréen';

  @override
  String get settingsDailyGoal => 'Objectif quotidien';

  @override
  String settingsGoalRow(String label, int xp) {
    return '$label · $xp XP/jour';
  }

  @override
  String get profileAchievements => 'Succès';

  @override
  String get profileFriends => 'Amis';

  @override
  String get profileShop => 'Boutique';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileSeeOnboarding => 'Voir le parcours de bienvenue ↗';

  @override
  String get profileNotSignedIn => 'Non connecté';

  @override
  String get profileCreateAccount => 'Créer un compte gratuit';

  @override
  String get profileSaveProgress =>
      'Sauvegarde ta progression sur tous tes appareils';

  @override
  String profileTodaysGoal(int today, int goal) {
    return 'Objectif du jour · $today/$goal XP';
  }

  @override
  String get profileViewProgress => 'Voir la progression →';

  @override
  String get profileUnlocked => 'Débloqué';

  @override
  String questsResetsIn(int h, int m) {
    return 'Réinitialisation dans ${h}h ${m}min';
  }

  @override
  String get questsDailyRefresh => 'Rafraîchissement quotidien';

  @override
  String get questsFreshMix => 'Un mix tout frais de 5 questions';

  @override
  String get questsServedFromQueue =>
      'Servi depuis ta vraie file de révision — rapporte du vrai XP.';

  @override
  String get questsGoalReached => 'Objectif du jour atteint ! 🎉';

  @override
  String questsReachGoal(int goal) {
    return 'Atteins $goal XP aujourd\'hui';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return 'Quêtes quotidiennes · $done/$total';
  }

  @override
  String get questsInfoNote =>
      'Les quêtes suivent ta vraie progression quotidienne. Coffres de récompense, quêtes entre amis et classement hebdomadaire nécessitent une économie backend — décision du propriétaire (§6). Aucune fausse récompense n\'est affichée.';

  @override
  String get questsStartRefresh => 'Lancer le rafraîchissement quotidien';

  @override
  String get questsStart => 'Démarrer';

  @override
  String get questsPractisedToday =>
      'Pratiqué aujourd\'hui — série en sécurité';

  @override
  String get questsEarnAnyXp => 'Gagne du XP aujourd\'hui';

  @override
  String questsXpToday(int current, int target) {
    return '$current/$target XP aujourd\'hui';
  }

  @override
  String get leaguesYourGroup => 'TON GROUPE';

  @override
  String leaguesThisWeek(int size) {
    return 'CETTE SEMAINE · $size APPRENANTS';
  }

  @override
  String get leaguesTiers => 'Divisions de la ligue';

  @override
  String leaguesTopClimb(int top, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '$days jour',
    );
    return 'Le top $top monte chaque semaine · fin dans $_temp0';
  }

  @override
  String get leaguesDemotionZone => 'Zone de relégation';

  @override
  String get leaguesPromotionZone => 'Zone de promotion';

  @override
  String get leaguesSafeZone => 'Zone sûre';

  @override
  String get leaguesYou => 'Toi';

  @override
  String leaguesPromoteRelegate(int top, int bottom) {
    return 'Le top $top monte · les $bottom derniers descendent à la fin de la semaine.';
  }

  @override
  String get leaguesYouAreHere => 'Tu es ici';

  @override
  String get leaguesViewAllTiers => '🏆 Voir les 10 divisions ›';

  @override
  String get notifMarkAllRead => 'Tout marquer comme lu';

  @override
  String get notifEmptyTitle => 'Pas encore de notifications';

  @override
  String get notifEmptyBody =>
      'Termine des leçons, construis une série et monte de niveau — tes jalons apparaîtront ici dès que tu les auras vraiment atteints.';

  @override
  String get notifPushNote =>
      'Ce sont des jalons in-app, affichés au moment où tu les gagnes. Les notifications push et les rappels sont une décision du propriétaire et pas encore activés — rien ici n\'est truqué.';
}
