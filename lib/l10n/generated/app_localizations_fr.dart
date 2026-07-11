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
}
