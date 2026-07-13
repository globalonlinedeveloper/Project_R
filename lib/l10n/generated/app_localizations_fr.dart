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
  String get lessonExplainThis => '💡 Explain this';

  @override
  String get lessonMatchPairs => 'Match the pairs';

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
    return '$goal XP per day';
  }

  @override
  String settingsGoalReachedSub(int goal) {
    return '$goal XP per day · ✓ reached today';
  }

  @override
  String get settingsSoundEffects => 'Sound effects';

  @override
  String get settingsHaptics => 'Haptics';

  @override
  String get settingsProActive => 'RATEL PRO active';

  @override
  String get settingsFreePlan => 'Free plan';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceMotionSub =>
      'Master switch — turns off every animation';

  @override
  String get settingsHighContrast => 'High contrast';

  @override
  String get settingsNotifPush => 'Push notifications';

  @override
  String get settingsNotifStreak => 'Streak reminders';

  @override
  String get settingsNotifLeague => 'League updates';

  @override
  String get settingsNotifFriend => 'Friend activity';

  @override
  String get settingsNotifFootnote =>
      'Your choices are saved now — delivery switches on when push notifications ship.';

  @override
  String get settingsCourse => 'Course';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsWorld => 'World';

  @override
  String get settingsEditProfile => 'Edit profile';

  @override
  String get settingsPrivacy => 'Privacy & data';

  @override
  String get settingsHelp => 'Help & support';

  @override
  String get settingsLogOut => 'Log out';

  @override
  String get settingsGuestSub =>
      'You are learning as a guest — sign up to save progress';

  @override
  String settingsCouldNotOpen(String url) {
    return 'Could not open $url';
  }

  @override
  String get settingsThemeSystem => 'Match device';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get mediaReadAloud => 'Read aloud';

  @override
  String get mediaTranscript => 'Transcript';

  @override
  String get mediaCheckUnderstanding => 'Check understanding';

  @override
  String mediaChecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comprehension checks',
      one: '$count comprehension check',
    );
    return '$_temp0';
  }

  @override
  String get mediaLoading => 'Loading…';

  @override
  String get mediaPause => 'Pause';

  @override
  String get storiesTitle => 'Stories';

  @override
  String get storiesSub =>
      'Read & listen — graded stories with browser read-aloud.';

  @override
  String get storiesEmpty => 'No stories in this course yet.';

  @override
  String get storyFallbackTitle => 'Story';

  @override
  String get podcastsSub =>
      'Listen -- graded podcasts with real audio and a transcript.';

  @override
  String get podcastsEmpty => 'No podcasts in this course yet.';

  @override
  String get podcastFallbackTitle => 'Podcast';

  @override
  String get podcastPlayEpisode => 'Play episode';

  @override
  String get watchSub =>
      'Watch -- short clips with a transcript and comprehension checks.';

  @override
  String get watchEmpty => 'No watch lessons in this course yet.';

  @override
  String get watchWebOnly => 'Video plays in the web app';

  @override
  String get libraryAdventuresSub =>
      'Walk a living world and talk your way through real scenes.';

  @override
  String get roleplaySub =>
      'Practice real conversations -- pick the right reply, get instant feedback.';

  @override
  String get roleplayEmpty => 'No roleplays in this course yet.';

  @override
  String get roleplayYourReply => 'Your reply:';

  @override
  String get roleplaySceneComplete => '🎉 Scene complete!';

  @override
  String get roleplayBack => 'Back to roleplays';

  @override
  String get liveRoleplayTitle => 'Live Roleplay';

  @override
  String get liveRoleplayCardSub => 'Talk it out with Ratel — real voice';

  @override
  String get liveIntro =>
      'Talk it out with Ratel — live voice roleplay. Pick a scene, or just have a conversation.';

  @override
  String get liveFreeConversation => 'Free conversation';

  @override
  String get liveFreeConversationSub => 'No script — just talk';

  @override
  String get liveRoleplayScene => 'Roleplay a scene';

  @override
  String get liveReconnecting => 'Reconnecting…';

  @override
  String get liveConnectionLost =>
      'Connection lost — the live session dropped.';

  @override
  String get liveReconnect => 'Reconnect';

  @override
  String get liveConnecting => 'Connecting…';

  @override
  String get liveStartTalking => 'Start talking';

  @override
  String get liveSceneEndedNote =>
      'Scene ended. Start again whenever you like — your live minutes are budgeted, never silent.';

  @override
  String get liveStartAgain => 'Start again';

  @override
  String get liveProGate =>
      'Live voice roleplay is a RATEL PRO feature — real conversation, live feedback, cost-guarded minutes.';

  @override
  String get liveUnlockPro => 'Unlock RATEL PRO';

  @override
  String get liveNotEnabled =>
      'Live voice is not enabled in this build yet — it turns on in a later step. Nothing here is simulated.';

  @override
  String get livePhaseIdle => 'Ready when you are — it’s a real live call.';

  @override
  String get livePhaseListening => 'Listening — your turn.';

  @override
  String get livePhaseSpeaking => 'Ratel is speaking — jump in any time.';

  @override
  String get livePhaseClosed => 'Scene ended.';

  @override
  String get liveEndScene => 'End scene';

  @override
  String get liveYou => 'You';

  @override
  String get liveStartFailed => 'Could not start the live session — try again.';

  @override
  String get friendsHandleInvalid =>
      'Enter a handle like @mia (2–20 letters, numbers, _).';

  @override
  String friendsAlreadyConnected(String handle) {
    return 'You already have a connection with @$handle.';
  }

  @override
  String get friendsRequests => 'Requests';

  @override
  String get friendsYourFriends => 'Your friends';

  @override
  String get friendsPending => 'Pending';

  @override
  String get friendsActivity => 'Friend activity';

  @override
  String get friendsFootnote =>
      'Your social graph is real and private to you. Friend requests are delivered, and \"passed you\" appears, once the durable cross-user graph goes live — the same go-live step as every other durable counter. Nothing here is faked.';

  @override
  String get friendsAddHint => 'Add a friend by @handle…';

  @override
  String get friendsAccept => 'Accept';

  @override
  String friendsXpThisWeek(String handle, String xp) {
    return '@$handle · $xp XP this week';
  }

  @override
  String get friendsPassedYou => 'Passed you';

  @override
  String get friendsRemove => 'Remove';

  @override
  String get friendsBlock => 'Block';

  @override
  String get friendsReportBlock => 'Report & block';

  @override
  String get friendsRequestSent => 'Request sent';

  @override
  String get friendsEmptyTitle => 'No friends yet';

  @override
  String get friendsEmptyBody =>
      'Add someone by their @handle to start sharing progress.';

  @override
  String get profileLearner => 'Learner';

  @override
  String get profileGuest => 'Guest';

  @override
  String get editProfileSaved => 'Profile saved';

  @override
  String get editProfileHandleSet => 'Saved — your @handle is set.';

  @override
  String get editProfileSignInForHandle =>
      'Name saved. Sign in to claim your @handle.';

  @override
  String get editProfileHandleFailed => 'That @handle could not be set.';

  @override
  String get editProfileDisplayName => 'Display name';

  @override
  String get editProfileNameHint => 'How should we greet you?';

  @override
  String get editProfileNameNote =>
      'Shown on your profile. Saved on this device — it syncs to your account when you sign in.';

  @override
  String get editProfileHandle => 'Your @handle';

  @override
  String get editProfileHandleNote =>
      'Other learners add you by your @handle (2–20 letters, numbers or _). Claiming it needs you to be signed in.';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get feedIsNowYourFriend => 'is now your friend';

  @override
  String feedReachedLevel(String level) {
    return 'reached $level';
  }

  @override
  String feedDayStreak(int count) {
    return '$count-day streak';
  }

  @override
  String get feedPassedYou => 'passed you in your league';

  @override
  String get leaguesSoloCaption => 'this week · solo group';

  @override
  String leaguesXpToRank(int xp, int rank) {
    return '$xp XP to rank $rank';
  }

  @override
  String get leaguesLeading => 'leading your group';

  @override
  String get leaguesSoloNote =>
      'You\'re the only learner in your group this week. Real rivals join as Ratel grows — no bots, no fake leaderboards. Keep earning XP to be ready to climb when the week resets.';

  @override
  String questsGoalLine(int today, int goal) {
    return '$today / $goal XP · goal reached';
  }

  @override
  String questsGoalRemaining(int today, int goal, int remaining) {
    return '$today / $goal XP · $remaining XP to go';
  }

  @override
  String get worldLabelLight => 'Daylight';

  @override
  String get worldVehicleLight => 'Scooter';

  @override
  String get worldLabelGalaxy => 'Space';

  @override
  String get worldVehicleGalaxy => 'Star pod';

  @override
  String get worldLabelSavanna => 'Savanna';

  @override
  String get worldVehicleSavanna => 'Safari jeep';

  @override
  String get worldLabelOcean => 'Ocean';

  @override
  String get worldVehicleOcean => 'Submarine';

  @override
  String get worldLabelForest => 'Forest';

  @override
  String get worldVehicleForest => 'Leaf glider';

  @override
  String get worldLabelCandy => 'Candy';

  @override
  String get worldVehicleCandy => 'Balloon';

  @override
  String get worldLabelNeon => 'Neon City';

  @override
  String get worldVehicleNeon => 'Hover-bike';

  @override
  String get worldLabelStorm => 'Rainstorm';

  @override
  String get worldVehicleStorm => 'Storm glider';

  @override
  String get worldLabelSnow => 'Winter';

  @override
  String get worldVehicleSnow => 'Snow sled';

  @override
  String get worldLabelSakura => 'Cherry Blossom';

  @override
  String get worldVehicleSakura => 'Petal kite';

  @override
  String get worldLabelAutumn => 'Autumn';

  @override
  String get worldVehicleAutumn => 'Leaf-cart';

  @override
  String get worldLabelAurora => 'Aurora';

  @override
  String get worldVehicleAurora => 'Aurora skiff';

  @override
  String get worldLabelVolcano => 'Volcano';

  @override
  String get worldVehicleVolcano => 'Magma board';

  @override
  String get worldLabelSunset => 'Sunset';

  @override
  String get worldVehicleSunset => 'Glider';

  @override
  String get worldLabelDesert => 'Desert';

  @override
  String get worldVehicleDesert => 'Dune buggy';

  @override
  String get worldLabelReef => 'Coral Reef';

  @override
  String get worldVehicleReef => 'Glass boat';

  @override
  String get worldLabelMeadow => 'Meadow';

  @override
  String get worldVehicleMeadow => 'Bicycle';

  @override
  String get worldLabelDawn => 'Dawn';

  @override
  String get worldVehicleDawn => 'Sky balloon';

  @override
  String get worldLabelBeach => 'Tropical Beach';

  @override
  String get worldVehicleBeach => 'Catamaran';

  @override
  String get worldLabelMars => 'Mars';

  @override
  String get worldVehicleMars => 'Rover';

  @override
  String get worldLabelJungle => 'Rainforest';

  @override
  String get worldVehicleJungle => 'Zipline';

  @override
  String get worldLabelCyberrain => 'Cyber Rain';

  @override
  String get worldVehicleCyberrain => 'Hover-bike';

  @override
  String get worldLabelAbyss => 'Deep Sea';

  @override
  String get worldVehicleAbyss => 'Bathysphere';

  @override
  String get worldLabelAlpine => 'Alpine';

  @override
  String get worldVehicleAlpine => 'Cable car';

  @override
  String get worldLabelLavender => 'Lavender';

  @override
  String get worldVehicleLavender => 'Vespa';

  @override
  String get worldLabelBamboo => 'Bamboo Grove';

  @override
  String get worldVehicleBamboo => 'Rickshaw';

  @override
  String get worldLabelLagoon => 'Lagoon Night';

  @override
  String get worldVehicleLagoon => 'Kayak';

  @override
  String get worldLabelThunder => 'Thunderhead';

  @override
  String get worldVehicleThunder => 'Storm chaser';

  @override
  String get worldLabelNebula => 'Nebula';

  @override
  String get worldVehicleNebula => 'Star cruiser';

  @override
  String get worldLabelSandstorm => 'Sandstorm';

  @override
  String get worldVehicleSandstorm => 'Caravan';

  @override
  String get worldLabelCherrynight => 'Cherry Night';

  @override
  String get worldVehicleCherrynight => 'Paper lantern';

  @override
  String get shopYourBadger => 'Your badger';

  @override
  String get shopDiamondsNote =>
      'A real-money 💎 top-up is coming. Diamonds are earned by finishing lessons and meeting your daily goal, and every power-up here spends them for real — nothing is faked.';

  @override
  String get shopProBannerSub => 'Live AI, no ads, offline · Try 7 days free';

  @override
  String get shopYourDiamonds => 'Your diamonds';

  @override
  String get shopEquipped => 'Equipped';

  @override
  String get shopEquip => 'Equip';

  @override
  String shopEquippedSnack(String name, String emoji) {
    return 'Equipped $name $emoji';
  }

  @override
  String get shopFree => 'Free';

  @override
  String get outfitClassic => 'Classic';

  @override
  String get outfitScholar => 'Scholar';

  @override
  String get outfitExplorer => 'Explorer';

  @override
  String get outfitAstronaut => 'Astronaut';

  @override
  String get outfitWizard => 'Wizard';

  @override
  String paywallAnnualLine(String annual, String perMonth) {
    return '$annual/yr  ·  $perMonth/mo  ·  7 days free';
  }

  @override
  String paywallMonthlyLine(String monthly) {
    return '$monthly/mo  ·  billed monthly';
  }

  @override
  String paywallSavePercent(int percent) {
    return 'SAVE $percent%';
  }

  @override
  String get paywallIncluded => 'What\'s included with Pro';

  @override
  String get paywallTerms => 'Terms';

  @override
  String get paywallPrivacy => 'Privacy';

  @override
  String get paywallNothingToRestore =>
      'Nothing to restore — billing isn\'t live in this build yet.';
}
