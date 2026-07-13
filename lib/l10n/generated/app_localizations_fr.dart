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
  String get lessonExplainThis => '💡 Explique-moi ça';

  @override
  String get lessonMatchPairs => 'Associe les paires';

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
  String get onboardingLanguageSubtitle =>
      'Apprends l\'anglais depuis 10 langues';

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
  String get langNameEnglish => 'Anglais';

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

  @override
  String get shopPowerUps => 'Bonus';

  @override
  String get shopStreakFreeze => 'Gel de série';

  @override
  String get shopStreakFreezeDesc =>
      'Protège ta série pour un jour manqué. Utilisé automatiquement si tu rates ton objectif quotidien.';

  @override
  String shopOwned(int have, int max) {
    return 'Possédés : $have/$max';
  }

  @override
  String get shopMaxedOut => 'Maximum atteint';

  @override
  String shopBuyFor(int cost) {
    return 'Acheter pour $cost 💎';
  }

  @override
  String get shopFreezeAdded => 'Gel de série ajouté 💪';

  @override
  String shopFreezeAtCap(int max) {
    return 'Tu as déjà le maximum de gels ($max).';
  }

  @override
  String shopNotEnoughEarnCost(int cost) {
    return 'Pas assez de 💎 — gagne $cost en terminant des leçons.';
  }

  @override
  String get shopNotEnoughEarnMore =>
      'Pas assez de 💎 — gagnes-en plus en terminant des leçons.';

  @override
  String get shopEnergyRefill => 'Recharge d\'énergie';

  @override
  String get shopEnergyRefillDesc =>
      'Remets ton énergie au maximum. L\'énergie est purement indicative — les leçons ne bloquent jamais.';

  @override
  String get shopAlreadyFull => 'Déjà pleine';

  @override
  String get shopEnergyRefilled => 'Énergie rechargée ⚡';

  @override
  String get shopEnergyAlreadyFull => 'Ton énergie est déjà pleine.';

  @override
  String get shopStreakRepair => 'Réparation de série';

  @override
  String get shopStreakRepairDesc =>
      'Série perdue ? Restaure sa longueur précédente et continue sur ta lancée.';

  @override
  String get shopStreakLapsed => 'Série interrompue';

  @override
  String shopStreakDays(int days) {
    return '🔥 Série de $days jours';
  }

  @override
  String shopRepairFor(int cost) {
    return 'Réparer pour $cost 💎';
  }

  @override
  String get shopStreakRestored => 'Série restaurée 🔥';

  @override
  String get shopStreakSafe =>
      'Ta série est en sécurité — rien à réparer pour l\'instant.';

  @override
  String get shopDoubleXp => 'XP double';

  @override
  String get shopDoubleXpDesc =>
      'Gagne 2× XP sur chaque leçon pendant 15 minutes.';

  @override
  String shopActiveLeft(int minutes) {
    return 'Actif · $minutes min restantes';
  }

  @override
  String get shopInactive => 'Inactif';

  @override
  String get shopActive => 'Actif';

  @override
  String get shopDoubleXpActive => 'XP double activé ✨';

  @override
  String get shopBoostRunning => 'Ton boost est en cours — l\'XP est doublé.';

  @override
  String get shopBadgerOutfits => 'Tenues du blaireau';

  @override
  String get paywallTitle => 'RATEL PRO';

  @override
  String get paywallStartTrial => 'Commencer l\'essai gratuit de 7 jours';

  @override
  String paywallGoPro(String price) {
    return 'Passer Pro — $price/mois';
  }

  @override
  String get paywallRestore => 'Restaurer les achats';

  @override
  String get paywallHero =>
      'Tutorat IA en direct, sans pub, leçons hors ligne.';

  @override
  String get paywallAnnual => 'Annuel';

  @override
  String get paywallMonthly => 'Mensuel';

  @override
  String get paywallTrialHow =>
      'Comment fonctionne l\'essai gratuit de 7 jours';

  @override
  String get paywallTrialToday => 'Aujourd\'hui';

  @override
  String get paywallTrialTodayDesc =>
      'Accès Pro complet débloqué. Aucun débit.';

  @override
  String get paywallTrialDay5 => 'Jour 5';

  @override
  String get paywallTrialDay5Desc => 'On te prévient avant la fin de l\'essai.';

  @override
  String get paywallTrialDay7 => 'Jour 7';

  @override
  String paywallTrialDay7Desc(String price) {
    return '$price/an démarre sauf annulation.';
  }

  @override
  String get paywallFeatureLiveAi =>
      'IA en direct : voix, chat tuteur et retours d\'écriture';

  @override
  String get paywallFeatureNoAds => 'Zéro pub, nulle part';

  @override
  String get paywallFeatureOffline => 'Leçons et audio hors ligne';

  @override
  String get paywallFeaturePronunciation => 'Conseils de prononciation par IA';

  @override
  String get paywallEverythingFree =>
      'Tout le reste — l\'audio, les révisions, les ligues, le jeu de rôle et la prononciation sur l\'appareil — reste gratuit pour tout le monde.';

  @override
  String get paywallYouArePro => 'Tu es sur RATEL PRO';

  @override
  String get paywallThanks =>
      'Merci de soutenir Ratel. Gère ou annule à tout moment depuis Paramètres → Gérer l\'abonnement.';

  @override
  String get paywallManage => 'Gérer l\'abonnement';

  @override
  String paywallFinePrint(String regions) {
    return 'Annulable à tout moment dans les paramètres. Prix affichés pour $regions ; ton prix local est fixé par ta boutique d\'applications.';
  }

  @override
  String get questTitlePowerSession => 'Session intensive';

  @override
  String get questDescPowerSession =>
      'Gagne le double de ton objectif quotidien';

  @override
  String get questTitleOnFire => 'En feu';

  @override
  String get questDescOnFire => 'Gagne le triple de ton objectif quotidien';

  @override
  String get questTitleStreakKeeper => 'Gardien de la série';

  @override
  String get questDescStreakKeeper =>
      'Pratique aujourd\'hui pour garder ta série';

  @override
  String get notifTitleLessons1 => 'Première leçon terminée';

  @override
  String get notifBodyLessons1 =>
      'Tu as terminé ta première leçon — super départ !';

  @override
  String get notifTitleLessons5 => '5 leçons terminées';

  @override
  String get notifBodyLessons5 => 'Tu as terminé 5 leçons. Garde le rythme.';

  @override
  String get notifTitleLessons10 => '10 leçons terminées';

  @override
  String get notifBodyLessons10 =>
      'Dix leçons — tu construis une vraie habitude.';

  @override
  String get notifTitleLessons25 => '25 leçons terminées';

  @override
  String get notifBodyLessons25 =>
      'Vingt-cinq leçons terminées. Une belle assiduité !';

  @override
  String get notifTitleLessons50 => '50 leçons terminées';

  @override
  String get notifBodyLessons50 =>
      'Cinquante leçons — tu es sur la bonne voie.';

  @override
  String get notifTitleStreak3 => 'Série de 3 jours !';

  @override
  String get notifBodyStreak3 =>
      'Trois jours d\'affilée. La régularité fait tout.';

  @override
  String get notifTitleStreak7 => 'Série de 7 jours !';

  @override
  String get notifBodyStreak7 =>
      'Une semaine entière de pratique quotidienne. Remarquable !';

  @override
  String get notifTitleStreak14 => 'Série de 14 jours !';

  @override
  String get notifBodyStreak14 =>
      'Deux semaines d\'affilée — rien ne t\'arrête.';

  @override
  String get notifTitleStreak30 => 'Série de 30 jours !';

  @override
  String get notifBodyStreak30 =>
      'Un mois entier de pratique quotidienne. Incroyable.';

  @override
  String get notifTitleXp100 => '100 XP gagnés';

  @override
  String get notifBodyXp100 => 'Tes cent premiers XP — l\'élan se construit.';

  @override
  String get notifTitleXp500 => '500 XP gagnés';

  @override
  String get notifBodyXp500 => 'Cinq cents XP. Tu fais le travail.';

  @override
  String get notifTitleXp1000 => '1 000 XP gagnés';

  @override
  String get notifBodyXp1000 => 'Cap des mille XP atteint !';

  @override
  String get notifTitleXp2500 => '2 500 XP gagnés';

  @override
  String get notifBodyXp2500 => 'Deux mille cinq cents XP — de vrais progrès.';

  @override
  String get notifTitleLevel1 => 'Niveau A2 atteint';

  @override
  String get notifBodyLevel1 => 'Ton niveau est passé de A1 à A2. En avant !';

  @override
  String get notifTitleLevel2 => 'Niveau B1 atteint';

  @override
  String get notifBodyLevel2 =>
      'Tu es maintenant un apprenant intermédiaire (B1).';

  @override
  String get notifTitleLevel3 => 'Niveau B2 atteint';

  @override
  String get notifBodyLevel3 =>
      'Intermédiaire supérieur (B2) atteint. Brillant.';

  @override
  String get notifTitleLevel4 => 'Niveau C1 atteint';

  @override
  String get notifBodyLevel4 => 'Avancé (C1) — ton anglais est solide.';

  @override
  String get notifTitleLevel5 => 'Niveau C2 atteint';

  @override
  String get notifBodyLevel5 => 'Maîtrise (C2) — le sommet de l\'échelle !';

  @override
  String get achTitleFirstSteps => 'Premiers pas';

  @override
  String get achTitleScholar => 'Érudit';

  @override
  String get achTitleWildfire => 'Feu de forêt';

  @override
  String get achTitlePointMaker => 'Marqueur de points';

  @override
  String get achTitleCollector => 'Collectionneur';

  @override
  String get achTitleRisingStar => 'Étoile montante';

  @override
  String get leagueTierBronze => 'Bronze';

  @override
  String get leagueTierSilver => 'Argent';

  @override
  String get leagueTierGold => 'Or';

  @override
  String get leagueTierSapphire => 'Saphir';

  @override
  String get leagueTierRuby => 'Rubis';

  @override
  String get leagueTierEmerald => 'Émeraude';

  @override
  String get leagueTierAmethyst => 'Améthyste';

  @override
  String get leagueTierPearl => 'Perle';

  @override
  String get leagueTierObsidian => 'Obsidienne';

  @override
  String get leagueTierDiamond => 'Diamant';

  @override
  String get cefrNameBeginner => 'Débutant';

  @override
  String get cefrNameElementary => 'Élémentaire';

  @override
  String get cefrNameIntermediate => 'Intermédiaire';

  @override
  String get cefrNameUpperIntermediate => 'Intermédiaire supérieur';

  @override
  String get cefrNameAdvanced => 'Avancé';

  @override
  String get cefrNameProficient => 'Maîtrise';

  @override
  String leaguesTierLeague(String tier) {
    return 'Ligue $tier';
  }

  @override
  String leaguesYoureIn(String tier) {
    return 'Tu es en ligue $tier · le top 7 monte chaque semaine';
  }

  @override
  String get leaguesZonePromotion => '⬆ ZONE DE PROMOTION';

  @override
  String get leaguesZoneDemotion => '⬇ ZONE DE RELÉGATION';

  @override
  String profileAchievementsSummary(int unlocked, int total) {
    return '$unlocked sur $total débloqués · progression réelle';
  }

  @override
  String get profileRealStateNote =>
      'Niveau, XP, leçons, série et mots enregistrés sont l\'état réel du moteur — ils partent de zéro sur un nouveau compte.';

  @override
  String get practiceTitle => 'Pratique';

  @override
  String practiceReviewWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Réviser $count mots',
      one: 'Réviser 1 mot',
    );
    return '$_temp0';
  }

  @override
  String get practiceYourWords => 'Tes mots';

  @override
  String practiceSavedWordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mots enregistrés',
      one: '$count mot enregistré',
    );
    return '$_temp0';
  }

  @override
  String practiceDueForReview(int count) {
    return '$count à réviser (répétition espacée)';
  }

  @override
  String get practiceAllUpToDate => 'Toutes les révisions sont à jour';

  @override
  String practiceCaughtUp(String tail) {
    return 'Tout est à jour — rien à réviser pour l\'instant$tail.';
  }

  @override
  String practiceNextTail(String when) {
    return ' · prochaine $when';
  }

  @override
  String get practiceZeroDue => '0 à réviser';

  @override
  String get practiceDueNow => 'À réviser maintenant';

  @override
  String practiceDueWhen(String when) {
    return 'À réviser $when';
  }

  @override
  String get practiceChipDue => 'À réviser';

  @override
  String get practiceChipScheduled => 'Planifiée';

  @override
  String get practiceScheduleNote =>
      'Les révisions sont planifiées par le vrai moteur de répétition espacée FSRS-6. Les échéances valent pour cette session ; les conserver entre les redémarrages est une étape du lancement — rien ici n\'est inventé.';

  @override
  String get practiceNoSavedWords => 'Aucun mot enregistré pour l\'instant';

  @override
  String get practiceSaveWordHint =>
      'Enregistre un mot pendant une leçon et il arrive ici en carte mémoire. Les révisions sont ensuite planifiées par le vrai moteur FSRS — rien n\'est prérempli.';

  @override
  String get practiceStartLesson => 'Commencer une leçon';

  @override
  String practiceWordOf(int n, int total) {
    return 'Mot $n sur $total';
  }

  @override
  String get practiceShowAnswer => 'Voir la réponse';

  @override
  String get practiceRecallHint =>
      'Rappelle-toi le sens, puis évalue à quel point tu t\'en souvenais.';

  @override
  String get practiceGradeAgain => 'Encore';

  @override
  String get practiceGradeHard => 'Difficile';

  @override
  String get practiceGradeGood => 'Bien';

  @override
  String get practiceGradeEasy => 'Facile';

  @override
  String get practiceFsrsGradeNote =>
      'FSRS-6 planifie la prochaine révision selon ta note';

  @override
  String get practiceReviewComplete => 'Révision terminée';

  @override
  String practiceReviewedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tu as révisé $count mots. FSRS les a replanifiés.',
      one: 'Tu as révisé 1 mot. FSRS l\'a replanifié.',
    );
    return '$_temp0';
  }

  @override
  String get practiceDone => 'Terminé';

  @override
  String get practiceRelTomorrow => 'demain';

  @override
  String practiceRelInDays(int days) {
    return 'dans $days jours';
  }

  @override
  String practiceRelInHours(int hours) {
    return 'dans $hours h';
  }

  @override
  String practiceRelInMinutes(int minutes) {
    return 'dans $minutes min';
  }

  @override
  String get practiceRelSoon => 'bientôt';

  @override
  String get progressTitle => 'Progression';

  @override
  String get progressShareMilestone => 'Partager le jalon';

  @override
  String get progressLast7Days => '7 derniers jours';

  @override
  String get progressAccuracyRetention => 'Précision et rétention';

  @override
  String get progressHonestyNote =>
      'Tout ici est un état réel enregistré — niveau, capacité, mots enregistrés, XP, leçons, série, ton historique sur 7 jours, précision et temps d\'étude partent de zéro et grandissent avec ton apprentissage. La rétention est le rappel prédit de cette session (le planificateur inter-sessions relève du lancement) ; rien n\'est inventé.';

  @override
  String progressShareText(
    String level,
    String levelName,
    int streak,
    int xp,
    int lessons,
  ) {
    return '🦡 RATEL · Niveau $level ($levelName)\n🔥 Série de $streak jours · ⚡ $xp XP · 📘 $lessons leçons\nJ\'apprends sur learnwithratel.com';
  }

  @override
  String get progressShareCopied =>
      'Jalon copié dans le presse-papiers — partage-le où tu veux !';

  @override
  String progressAbilityLine(String theta) {
    return 'Capacité θ $theta · estimation réelle';
  }

  @override
  String get progressStatSavedWords => 'Mots enregistrés';

  @override
  String get progressStatLessons => 'Leçons';

  @override
  String get progressStatDayStreak => 'Jours de série';

  @override
  String get progressStatTotalXp => 'XP total';

  @override
  String get progressStatTodaysXp => 'XP du jour';

  @override
  String get progressStatCefrLevel => 'Niveau CECR';

  @override
  String get progressAccuracy => 'Précision';

  @override
  String get progressStudyTime => 'Temps d\'étude';

  @override
  String get progressRetention => 'Rétention';

  @override
  String get progressNoData => 'Pas encore de données';

  @override
  String get progressAccuracyEmpty =>
      'Réponds à des exercices notés pour commencer';

  @override
  String progressAccuracyDetail(int correct, int total) {
    return '$correct sur $total correctes';
  }

  @override
  String get progressTimeEmpty => 'Le temps des leçons s\'additionne ici';

  @override
  String get progressTimeDetail => 'sur toutes tes leçons';

  @override
  String get progressRetentionEmpty =>
      'Révise des éléments pour voir le rappel prédit';

  @override
  String progressRetentionDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'rappel prédit à 1 jour · $count éléments cette session',
      one: 'rappel prédit à 1 jour · 1 élément cette session',
    );
    return '$_temp0';
  }

  @override
  String progressWeekTotal(int xp) {
    return '$xp XP · 7 derniers jours';
  }

  @override
  String get progressNoXpYet => 'Aucun XP enregistré pour l\'instant';

  @override
  String get progressChartEmptyNote =>
      'Termine une leçon pour démarrer ton historique de 7 jours — les jours inactifs restent à zéro, rien n\'est inventé.';

  @override
  String get commonDowMon => 'Lu';

  @override
  String get commonDowTue => 'Ma';

  @override
  String get commonDowWed => 'Me';

  @override
  String get commonDowThu => 'Je';

  @override
  String get commonDowFri => 'Ve';

  @override
  String get commonDowSat => 'Sa';

  @override
  String get commonDowSun => 'Di';

  @override
  String get searchTitle => 'Recherche';

  @override
  String get searchHint => 'Cherche leçons, mots, histoires…';

  @override
  String get searchRecent => 'Récents';

  @override
  String get searchClear => 'Effacer';

  @override
  String get searchJumpTo => 'Aller à';

  @override
  String get searchTagPage => 'Page';

  @override
  String get searchTagWord => 'Mot';

  @override
  String get searchSubtitleSavedWord => 'Mot enregistré';

  @override
  String searchLessonSubtitle(String unit) {
    return '$unit · Leçon';
  }

  @override
  String searchNoMatches(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get searchEmptyNote =>
      'Recherche dans les titres, tags et contenus de leçons de ton cours, tes mots enregistrés et les pages. L\'index de contenu serveur et les tendances sont la suite de R-L12 — rien ici n\'est truqué.';

  @override
  String get searchNoMatchNote =>
      'Recherche dans tes leçons publiées, tes mots enregistrés et les pages de l\'appli (titres + tags). Histoires/podcasts et texte intégral sont la suite de R-L12 — jamais truqué.';

  @override
  String get searchFooterNote =>
      'Au lancement : titres + tags. Texte intégral, histoires/podcasts et multi-cours sont la suite de R-L12 — jamais truqué.';

  @override
  String get searchDestPracticeHub => 'Espace pratique';

  @override
  String get searchDestPracticeHubSub => 'Erreurs, mots faibles & exercices';

  @override
  String get searchDestAiTutor => 'Tuteur IA';

  @override
  String get searchDestAiTutorSub => 'Parle, discute & joue des scènes';

  @override
  String get searchDestAdventures => 'Aventures';

  @override
  String get searchDestAdventuresSub => 'Vraies conversations — gratuit';

  @override
  String get searchDestLeagues => 'Ligues';

  @override
  String get searchDestLeaguesSub => 'Ta ligue hebdomadaire';

  @override
  String get searchDestQuests => 'Quêtes';

  @override
  String get searchDestQuestsSub => 'Objectifs & quêtes du jour';

  @override
  String get searchDestProgress => 'Progression';

  @override
  String get searchDestProgressSub => 'Tes stats & ta série';

  @override
  String get searchDestProfile => 'Profil';

  @override
  String get searchDestProfileSub => 'Ton profil';

  @override
  String get searchDestSettings => 'Paramètres';

  @override
  String get searchDestSettingsSub => 'Compte & préférences';

  @override
  String get searchDestShop => 'Boutique';

  @override
  String get searchDestShopSub => 'Dépense tes diamants';

  @override
  String get searchDestNotifications => 'Notifications';

  @override
  String get searchDestNotificationsSub => 'Ta boîte à jalons';

  @override
  String get themesTitle => 'Thèmes';

  @override
  String get themesSubtitle =>
      'Restyle toute l\'appli — touche pour prévisualiser en direct';

  @override
  String themesVehicle(String vehicle) {
    return 'Véhicule · $vehicle';
  }

  @override
  String get tutorHeader => 'Pratique une vraie conversation';

  @override
  String get tutorHeaderSub =>
      'Choisis une scène et discute avec Ratel — pas de mauvaises réponses, juste de la pratique.';

  @override
  String get tutorTalkTitle => 'Parler à Ratel';

  @override
  String get tutorTalkSub => 'Pratique orale en direct, voix & vidéo';

  @override
  String get tutorChatTitle => 'Discuter avec Ratel';

  @override
  String get tutorChatSub => 'Chat IA · retours d\'écriture';

  @override
  String get tutorRoleplayTitle => 'Scènes de jeu de rôle';

  @override
  String get tutorRoleplayGuided => 'Conversations de jeu de rôle guidées';

  @override
  String tutorScenesCount(int count) {
    return '$count scènes';
  }

  @override
  String get tutorUnlockPro => 'Débloquer RATEL PRO';

  @override
  String get tutorRelayNote =>
      'Le tutorat IA en direct passe par un relais modéré à coûts maîtrisés et relève de RATEL PRO. Les réponses ne sont jamais simulées — un mode ne démarre que lorsque PRO et le relais sont actifs.';

  @override
  String get tutorStatusReadyPro =>
      'PRO actif et tuteur en direct connecté — choisis un mode pour commencer.';

  @override
  String get tutorStatusReadyFree =>
      'Le tuteur en direct est connecté. Le tutorat en direct relève de RATEL PRO.';

  @override
  String get tutorStatusOffline =>
      'Le tuteur en direct modéré n\'est pas encore connecté dans cette version — le tutorat en direct arrivera plus tard. Rien ci-dessous n\'est simulé.';

  @override
  String get tutorAnnounceNeedsPro =>
      'RATEL PRO débloque le tutorat IA en direct.';

  @override
  String get tutorAnnounceNeedsRelay =>
      'Le tutorat IA se connecte dès que le relais modéré est activé.';

  @override
  String get tutorAnnounceStarting => 'Démarrage de ta session…';

  @override
  String get adventuresTitle => 'Aventures';

  @override
  String get adventuresFreeChip => 'GRATUIT';

  @override
  String get adventuresHeaderSub => 'Explorez un monde · parlez à votre façon';

  @override
  String get adventuresHeroTitle => 'Choisissez un lieu et lancez-vous';

  @override
  String get adventuresHeroSub =>
      'Chaque scène est une vraie conversation — pas de mauvaises réponses, et c’est toujours gratuit.';

  @override
  String get adventuresFallbackWorld => 'Aventure';

  @override
  String adventureSheetKicker(String cefr) {
    return '🗺️ AVENTURE · $cefr';
  }

  @override
  String adventureScenesCount(int count) {
    return '$count scènes';
  }

  @override
  String adventureChoicePoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points de décision',
      one: '$count point de décision',
    );
    return '$_temp0';
  }

  @override
  String get adventureOpeningScene => 'SCÈNE D\'OUVERTURE';

  @override
  String get adventureStart => 'Commencer l\'aventure';

  @override
  String get adventurePlayerFallbackTitle => 'Aventure';

  @override
  String get adventureTheEnd => '🏁 Fin';

  @override
  String get adventureStartOver => 'Recommencer';

  @override
  String get adventureDone => 'Terminé';

  @override
  String get adventureCompleteKicker => 'AVENTURE TERMINÉE';

  @override
  String adventureCompleteTitle(String title) {
    return '$title ✓';
  }

  @override
  String get adventureCompleteBody =>
      'Bien joué ! +15 XP · +5 💎 gagnés — explorez la scène suivante quand vous voulez.';

  @override
  String adventureDistrictProgress(int done, int total) {
    return '$done/$total explorées';
  }

  @override
  String get adventureDistrictDone => '✓ Terminé';

  @override
  String get adventuresEmpty => 'Pas encore d\'aventures dans ce cours.';

  @override
  String get authWelcomeTitle => 'Bienvenue sur Ratel';

  @override
  String get authWelcomeSubtitle =>
      'Leçons, histoires, podcasts et plus —\nchoisis comment commencer.';

  @override
  String get authCreateFreeAccount => 'Créer un compte gratuit';

  @override
  String get authAlreadyHaveAccount => 'J\'ai déjà un compte';

  @override
  String get authSettingUp => 'Préparation…';

  @override
  String get authContinueAsGuest => 'Continuer en invité';

  @override
  String get authGuestNote =>
      'La progression invité reste sur cet appareil — crée un compte gratuit à tout moment dans Paramètres pour la garder partout.';

  @override
  String get authEnterYourEmail => 'Saisis ton e-mail';

  @override
  String get authEnterValidEmail => 'Saisis un e-mail valide';

  @override
  String get authEnterYourPassword => 'Saisis ton mot de passe';

  @override
  String get authCouldNotSignIn => 'Connexion impossible. Réessaie.';

  @override
  String get authSomethingWentWrong => 'Un problème est survenu. Réessaie.';

  @override
  String get authSocialComingSoon =>
      'La connexion Google / Apple arrive bientôt.';

  @override
  String get authResetTitle => 'Réinitialise ton mot de passe';

  @override
  String get authWelcomeBack => 'Content de te revoir !';

  @override
  String get authResetSubtitle =>
      'Saisis ton e-mail et nous t\'enverrons un lien de réinitialisation.';

  @override
  String get authPickUpWhereYouLeft => 'Reprends là où tu t\'étais arrêté';

  @override
  String get authEmailHint => 'E-mail';

  @override
  String get authPasswordHint => 'Mot de passe';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authSendResetLink => 'Envoyer le lien';

  @override
  String get authLogIn => 'Se connecter';

  @override
  String get authBackToLogIn => 'Retour à la connexion';

  @override
  String get authNewToRatel => 'Nouveau sur Ratel ? ';

  @override
  String get authSignUp => 'S\'inscrire';

  @override
  String get authCheckYourInbox => 'Vérifie ta boîte mail';

  @override
  String authResetSent(String email) {
    return 'Nous avons envoyé un lien de réinitialisation à $email. Ouvre-le pour choisir un nouveau mot de passe.';
  }

  @override
  String get authCreatePassword => 'Crée un mot de passe';

  @override
  String get authAtLeast8Chars => 'Au moins 8 caractères';

  @override
  String get authCreateYourAccount => 'Crée ton compte';

  @override
  String get authSignupSubtitle =>
      'Gratuit pour toujours · apprends l\'anglais depuis 10 langues';

  @override
  String get authPassword8Hint => 'Mot de passe (8 caractères ou plus)';

  @override
  String get authCreateAccount => 'Créer le compte';

  @override
  String get authAlreadyAccountLead => 'Déjà un compte ? ';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authConfirmEmail => 'Confirme ton e-mail';

  @override
  String authConfirmSent(String email) {
    return 'Nous avons envoyé un lien de confirmation à $email. Touche-le pour activer ton compte, puis reviens te connecter.';
  }

  @override
  String get authContinueGoogle => 'Continuer avec Google';

  @override
  String get authContinueApple => 'Continuer avec Apple';

  @override
  String get authOr => 'ou';

  @override
  String get authUnavailableNote =>
      'Les comptes ne sont pas encore disponibles dans cette version — tu peux continuer à apprendre en invité. La connexion s\'activera quand le backend sera configuré.';

  @override
  String get liveMute => 'Couper le micro';

  @override
  String get liveUnmute => 'Réactiver le micro';

  @override
  String commonDurSeconds(int s) {
    return '$s s';
  }

  @override
  String commonDurMinutes(int m) {
    return '$m min';
  }

  @override
  String commonDurHours(int h) {
    return '$h h';
  }

  @override
  String commonDurHoursMinutes(int h, int m) {
    return '$h h $m min';
  }

  @override
  String practiceGradeInterval(String label, int days) {
    return '$label · $days j';
  }

  @override
  String settingsGoalPerDay(int goal) {
    return '$goal XP par jour';
  }

  @override
  String settingsGoalReachedSub(int goal) {
    return '$goal XP par jour · ✓ atteint aujourd\'hui';
  }

  @override
  String get settingsSoundEffects => 'Effets sonores';

  @override
  String get settingsHaptics => 'Retour haptique';

  @override
  String get settingsProActive => 'RATEL PRO actif';

  @override
  String get settingsFreePlan => 'Formule gratuite';

  @override
  String get settingsReduceMotion => 'Réduire les animations';

  @override
  String get settingsReduceMotionSub =>
      'Interrupteur général — désactive toutes les animations';

  @override
  String get settingsHighContrast => 'Contraste élevé';

  @override
  String get settingsNotifPush => 'Notifications push';

  @override
  String get settingsNotifStreak => 'Rappels de série';

  @override
  String get settingsNotifLeague => 'Nouvelles de la ligue';

  @override
  String get settingsNotifFriend => 'Activité des amis';

  @override
  String get settingsNotifFootnote =>
      'Tes choix sont enregistrés dès maintenant — l\'envoi s\'active quand les notifications push arriveront.';

  @override
  String get settingsCourse => 'Cours';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsWorld => 'Monde';

  @override
  String get settingsEditProfile => 'Modifier le profil';

  @override
  String get settingsPrivacy => 'Confidentialité et données';

  @override
  String get settingsHelp => 'Aide et assistance';

  @override
  String get settingsLogOut => 'Se déconnecter';

  @override
  String get settingsGuestSub =>
      'Tu apprends en invité — inscris-toi pour sauvegarder ta progression';

  @override
  String settingsCouldNotOpen(String url) {
    return 'Impossible d\'ouvrir $url';
  }

  @override
  String get settingsThemeSystem => 'Selon l\'appareil';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get mediaReadAloud => 'Lire à voix haute';

  @override
  String get mediaTranscript => 'Transcription';

  @override
  String get mediaCheckUnderstanding => 'Vérifier la compréhension';

  @override
  String mediaChecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions de compréhension',
      one: '$count question de compréhension',
    );
    return '$_temp0';
  }

  @override
  String get mediaLoading => 'Chargement…';

  @override
  String get mediaPause => 'Pause';

  @override
  String get storiesTitle => 'Histoires';

  @override
  String get storiesSub =>
      'Lis et écoute — histoires graduées avec lecture à voix haute du navigateur.';

  @override
  String get storiesEmpty => 'Pas encore d\'histoires dans ce cours.';

  @override
  String get storyFallbackTitle => 'Histoire';

  @override
  String get podcastsSub =>
      'Écoute — podcasts gradués avec un vrai audio et une transcription.';

  @override
  String get podcastsEmpty => 'Pas encore de podcasts dans ce cours.';

  @override
  String get podcastFallbackTitle => 'Podcast';

  @override
  String get podcastPlayEpisode => 'Lire l\'épisode';

  @override
  String get watchSub =>
      'Regarde — courts clips avec une transcription et des questions de compréhension.';

  @override
  String get watchEmpty => 'Pas encore de leçons vidéo dans ce cours.';

  @override
  String get watchWebOnly => 'La vidéo se lit dans l\'appli web';

  @override
  String get libraryAdventuresSub =>
      'Parcours un monde vivant et fraie-toi un chemin à travers de vraies scènes.';

  @override
  String get roleplaySub =>
      'Entraîne-toi à de vraies conversations — choisis la bonne réponse, reçois un retour instantané.';

  @override
  String get roleplayEmpty => 'Pas encore de jeux de rôle dans ce cours.';

  @override
  String get roleplayYourReply => 'Ta réponse :';

  @override
  String get roleplaySceneComplete => '🎉 Scène terminée !';

  @override
  String get roleplayBack => 'Retour aux jeux de rôle';

  @override
  String get liveRoleplayTitle => 'Jeu de rôle en direct';

  @override
  String get liveRoleplayCardSub =>
      'Discute de vive voix avec Ratel — vraie voix';

  @override
  String get liveIntro =>
      'Discute de vive voix avec Ratel — jeu de rôle vocal en direct. Choisis une scène, ou lance simplement une conversation.';

  @override
  String get liveFreeConversation => 'Conversation libre';

  @override
  String get liveFreeConversationSub =>
      'Pas de script — parle, tout simplement';

  @override
  String get liveRoleplayScene => 'Jouer une scène';

  @override
  String get liveReconnecting => 'Reconnexion…';

  @override
  String get liveConnectionLost =>
      'Connexion perdue — la session en direct a été interrompue.';

  @override
  String get liveReconnect => 'Se reconnecter';

  @override
  String get liveConnecting => 'Connexion…';

  @override
  String get liveStartTalking => 'Commencer à parler';

  @override
  String get liveSceneEndedNote =>
      'Scène terminée. Recommence quand tu veux — tes minutes en direct sont budgétées, jamais silencieuses.';

  @override
  String get liveStartAgain => 'Recommencer';

  @override
  String get liveProGate =>
      'Le jeu de rôle vocal en direct est une fonctionnalité RATEL PRO — vraie conversation, retour en direct, minutes à coûts maîtrisés.';

  @override
  String get liveUnlockPro => 'Débloquer RATEL PRO';

  @override
  String get liveNotEnabled =>
      'La voix en direct n\'est pas encore activée dans cette version — elle s\'active plus tard. Rien ici n\'est simulé.';

  @override
  String get livePhaseIdle =>
      'Prêt quand tu l\'es — c\'est un vrai appel en direct.';

  @override
  String get livePhaseListening => 'À l\'écoute — à toi.';

  @override
  String get livePhaseSpeaking => 'Ratel parle — interviens quand tu veux.';

  @override
  String get livePhaseClosed => 'Scène terminée.';

  @override
  String get liveEndScene => 'Terminer la scène';

  @override
  String get liveYou => 'Toi';

  @override
  String get liveStartFailed =>
      'Impossible de démarrer la session en direct — réessaie.';

  @override
  String get friendsHandleInvalid =>
      'Saisis un identifiant comme @mia (2–20 lettres, chiffres, _).';

  @override
  String friendsAlreadyConnected(String handle) {
    return 'Tu es déjà en relation avec @$handle.';
  }

  @override
  String get friendsRequests => 'Demandes';

  @override
  String get friendsYourFriends => 'Tes amis';

  @override
  String get friendsPending => 'En attente';

  @override
  String get friendsActivity => 'Activité des amis';

  @override
  String get friendsFootnote =>
      'Ton graphe social est réel et privé. Les demandes d\'ami sont envoyées, et « t\'a dépassé » apparaît, une fois le graphe inter-utilisateurs durable en ligne — la même étape de lancement que tous les autres compteurs durables. Rien ici n\'est truqué.';

  @override
  String get friendsAddHint => 'Ajoute un ami par @identifiant…';

  @override
  String get friendsAccept => 'Accepter';

  @override
  String friendsXpThisWeek(String handle, String xp) {
    return '@$handle · $xp XP cette semaine';
  }

  @override
  String get friendsPassedYou => 'T\'a dépassé';

  @override
  String get friendsRemove => 'Retirer';

  @override
  String get friendsBlock => 'Bloquer';

  @override
  String get friendsReportBlock => 'Signaler et bloquer';

  @override
  String get friendsRequestSent => 'Demande envoyée';

  @override
  String get friendsEmptyTitle => 'Pas encore d\'amis';

  @override
  String get friendsEmptyBody =>
      'Ajoute quelqu\'un par son @identifiant pour commencer à partager ta progression.';

  @override
  String get profileLearner => 'Apprenant';

  @override
  String get profileGuest => 'Invité';

  @override
  String get editProfileSaved => 'Profil enregistré';

  @override
  String get editProfileHandleSet =>
      'Enregistré — ton @identifiant est défini.';

  @override
  String get editProfileSignInForHandle =>
      'Nom enregistré. Connecte-toi pour revendiquer ton @identifiant.';

  @override
  String get editProfileHandleFailed =>
      'Impossible de définir cet @identifiant.';

  @override
  String get editProfileDisplayName => 'Nom d\'affichage';

  @override
  String get editProfileNameHint => 'Comment devons-nous t\'appeler ?';

  @override
  String get editProfileNameNote =>
      'Affiché sur ton profil. Enregistré sur cet appareil — il se synchronise avec ton compte quand tu te connectes.';

  @override
  String get editProfileHandle => 'Ton @identifiant';

  @override
  String get editProfileHandleNote =>
      'Les autres apprenants t\'ajoutent par ton @identifiant (2–20 lettres, chiffres ou _). Pour le revendiquer, tu dois être connecté.';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get feedIsNowYourFriend => 'est maintenant ton ami';

  @override
  String feedReachedLevel(String level) {
    return 'a atteint $level';
  }

  @override
  String feedDayStreak(int count) {
    return 'série de $count jours';
  }

  @override
  String get feedPassedYou => 't\'a dépassé dans ta ligue';

  @override
  String get leaguesSoloCaption => 'cette semaine · groupe solo';

  @override
  String leaguesXpToRank(int xp, int rank) {
    return '$xp XP pour le rang $rank';
  }

  @override
  String get leaguesLeading => 'en tête de ton groupe';

  @override
  String get leaguesSoloNote =>
      'Tu es le seul apprenant de ton groupe cette semaine. De vrais rivaux te rejoindront à mesure que Ratel grandit — aucun bot, aucun faux classement. Continue à gagner du XP pour être prêt à grimper au prochain reset de la semaine.';

  @override
  String questsGoalLine(int today, int goal) {
    return '$today / $goal XP · objectif atteint';
  }

  @override
  String questsGoalRemaining(int today, int goal, int remaining) {
    return '$today / $goal XP · $remaining XP restants';
  }

  @override
  String get worldLabelLight => 'Plein jour';

  @override
  String get worldVehicleLight => 'Trottinette';

  @override
  String get worldLabelGalaxy => 'Espace';

  @override
  String get worldVehicleGalaxy => 'Nef stellaire';

  @override
  String get worldLabelSavanna => 'Savane';

  @override
  String get worldVehicleSavanna => 'Jeep de safari';

  @override
  String get worldLabelOcean => 'Océan';

  @override
  String get worldVehicleOcean => 'Sous-marin';

  @override
  String get worldLabelForest => 'Forêt';

  @override
  String get worldVehicleForest => 'Planeur-feuille';

  @override
  String get worldLabelCandy => 'Bonbons';

  @override
  String get worldVehicleCandy => 'Montgolfière';

  @override
  String get worldLabelNeon => 'Cité néon';

  @override
  String get worldVehicleNeon => 'Moto volante';

  @override
  String get worldLabelStorm => 'Averse';

  @override
  String get worldVehicleStorm => 'Planeur d\'orage';

  @override
  String get worldLabelSnow => 'Hiver';

  @override
  String get worldVehicleSnow => 'Luge';

  @override
  String get worldLabelSakura => 'Fleurs de cerisier';

  @override
  String get worldVehicleSakura => 'Cerf-volant pétale';

  @override
  String get worldLabelAutumn => 'Automne';

  @override
  String get worldVehicleAutumn => 'Charrette à feuilles';

  @override
  String get worldLabelAurora => 'Aurore boréale';

  @override
  String get worldVehicleAurora => 'Esquif d\'aurore';

  @override
  String get worldLabelVolcano => 'Volcan';

  @override
  String get worldVehicleVolcano => 'Planche de magma';

  @override
  String get worldLabelSunset => 'Coucher de soleil';

  @override
  String get worldVehicleSunset => 'Planeur';

  @override
  String get worldLabelDesert => 'Désert';

  @override
  String get worldVehicleDesert => 'Buggy des dunes';

  @override
  String get worldLabelReef => 'Récif corallien';

  @override
  String get worldVehicleReef => 'Bateau de verre';

  @override
  String get worldLabelMeadow => 'Prairie';

  @override
  String get worldVehicleMeadow => 'Vélo';

  @override
  String get worldLabelDawn => 'Aube';

  @override
  String get worldVehicleDawn => 'Ballon céleste';

  @override
  String get worldLabelBeach => 'Plage tropicale';

  @override
  String get worldVehicleBeach => 'Catamaran';

  @override
  String get worldLabelMars => 'Mars';

  @override
  String get worldVehicleMars => 'Rover';

  @override
  String get worldLabelJungle => 'Forêt tropicale';

  @override
  String get worldVehicleJungle => 'Tyrolienne';

  @override
  String get worldLabelCyberrain => 'Pluie cyber';

  @override
  String get worldVehicleCyberrain => 'Moto volante';

  @override
  String get worldLabelAbyss => 'Grand fond';

  @override
  String get worldVehicleAbyss => 'Bathysphère';

  @override
  String get worldLabelAlpine => 'Alpin';

  @override
  String get worldVehicleAlpine => 'Téléphérique';

  @override
  String get worldLabelLavender => 'Lavande';

  @override
  String get worldVehicleLavender => 'Vespa';

  @override
  String get worldLabelBamboo => 'Bambouseraie';

  @override
  String get worldVehicleBamboo => 'Pousse-pousse';

  @override
  String get worldLabelLagoon => 'Lagon nocturne';

  @override
  String get worldVehicleLagoon => 'Kayak';

  @override
  String get worldLabelThunder => 'Nuée d\'orage';

  @override
  String get worldVehicleThunder => 'Chasseur d\'orage';

  @override
  String get worldLabelNebula => 'Nébuleuse';

  @override
  String get worldVehicleNebula => 'Croiseur stellaire';

  @override
  String get worldLabelSandstorm => 'Tempête de sable';

  @override
  String get worldVehicleSandstorm => 'Caravane';

  @override
  String get worldLabelCherrynight => 'Nuit des cerisiers';

  @override
  String get worldVehicleCherrynight => 'Lanterne de papier';

  @override
  String get shopYourBadger => 'Ton blaireau';

  @override
  String get shopDiamondsNote =>
      'Une recharge de 💎 en argent réel arrive. Les diamants se gagnent en terminant des leçons et en atteignant ton objectif quotidien, et chaque bonus ici les dépense pour de vrai — rien n\'est truqué.';

  @override
  String get shopProBannerSub =>
      'IA en direct, sans pub, hors ligne · Essaie 7 jours gratuits';

  @override
  String get shopYourDiamonds => 'Tes diamants';

  @override
  String get shopEquipped => 'Équipé';

  @override
  String get shopEquip => 'Équiper';

  @override
  String shopEquippedSnack(String name, String emoji) {
    return '$name $emoji équipé';
  }

  @override
  String get shopFree => 'Gratuit';

  @override
  String get outfitClassic => 'Classique';

  @override
  String get outfitScholar => 'Érudit';

  @override
  String get outfitExplorer => 'Explorateur';

  @override
  String get outfitAstronaut => 'Astronaute';

  @override
  String get outfitWizard => 'Magicien';

  @override
  String paywallAnnualLine(String annual, String perMonth) {
    return '$annual/an  ·  $perMonth/mois  ·  7 jours gratuits';
  }

  @override
  String paywallMonthlyLine(String monthly) {
    return '$monthly/mois  ·  facturé mensuellement';
  }

  @override
  String paywallSavePercent(int percent) {
    return 'ÉCONOMISE $percent%';
  }

  @override
  String get paywallIncluded => 'Ce qui est inclus avec Pro';

  @override
  String get paywallTerms => 'Conditions';

  @override
  String get paywallPrivacy => 'Confidentialité';

  @override
  String get paywallNothingToRestore =>
      'Rien à restaurer — la facturation n\'est pas encore active dans cette version.';

  @override
  String get contentUnavailableTitle => 'Contenu indisponible';

  @override
  String contentUnavailableBody(String noun) {
    return 'Ce/cette $noun n\'est pas disponible pour l\'instant. Si tu es hors ligne, vérifie ta connexion et réessaie.';
  }

  @override
  String get contentNounStory => 'histoire';

  @override
  String get contentNounPodcast => 'podcast';

  @override
  String get contentNounVideo => 'vidéo';

  @override
  String get contentNounAdventure => 'aventure';

  @override
  String get contentNounRoleplay => 'jeu de rôle';

  @override
  String get commonGoBack => 'Retour';

  @override
  String get placementTitle => 'Test de niveau';

  @override
  String placementQuestionN(int n) {
    return 'Question $n';
  }

  @override
  String get placementResultTitle => 'Ton point de départ';

  @override
  String placementResultBody(int count, String level) {
    return 'D\'après $count questions, nous t\'avons placé au niveau $level. Tu pourras toujours ajuster plus tard.';
  }

  @override
  String get lessonTypedNote => 'Écris ta réponse dans la langue cible.';

  @override
  String lessonHintMinWords(int count) {
    return 'au moins $count mots';
  }

  @override
  String lessonHintUseWords(String words) {
    return 'utilise : $words';
  }

  @override
  String get lessonHintEndPunct => 'termine par . ! ou ?';

  @override
  String get lessonPlayAudio => 'Lire l\'audio';

  @override
  String get lessonPlaySlowly => 'Lire lentement';

  @override
  String get lessonAudioUnavailable => 'Audio indisponible — lis la consigne.';

  @override
  String get lessonPlaybackSpeed => 'Vitesse de lecture';

  @override
  String get authAccountsUnavailable =>
      'Les comptes ne sont pas encore disponibles dans cette version — continue à apprendre en invité.';

  @override
  String get liveNotEnabledShort =>
      'la voix en direct n\'est pas activée dans cette version.';

  @override
  String get liveMicUnavailable =>
      'microphone indisponible — autorise l\'accès au micro pour parler avec le tuteur.';

  @override
  String get liveUnavailable =>
      'la voix en direct est indisponible pour le moment.';

  @override
  String get liveNeedsPro => 'La voix en direct fait partie de RATEL PRO.';

  @override
  String get liveMinutesUsed =>
      'Tu as utilisé tes minutes en direct de ce mois-ci.';

  @override
  String get commonNetworkError =>
      'Impossible de joindre le serveur. Réessaie.';

  @override
  String get friendsHandleTaken => 'Cet @identifiant est déjà pris.';

  @override
  String get friendsHandleFormat =>
      'Utilise 2–20 lettres, chiffres ou _ pour ton identifiant.';

  @override
  String get friendsSignInForHandle =>
      'Connecte-toi pour revendiquer ton @identifiant.';

  @override
  String get friendsSetOwnHandleFirst =>
      'Définis d\'abord ton propre @identifiant (Modifier le profil).';

  @override
  String get paywallCheckoutUnavailable =>
      'Le paiement s\'active plus tard — la facturation du store n\'est pas encore active dans cette version.';

  @override
  String get settingsManageUnavailable =>
      'Gère ou annule dans les réglages Abonnements de ton appareil — le raccourci dans l\'app s\'active plus tard.';

  @override
  String get friendsAdd => 'Ajouter';
}
