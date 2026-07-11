// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get navHome => 'Início';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navLeagues => 'Ligas';

  @override
  String get navQuests => 'Missões';

  @override
  String get navProfile => 'Perfil';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSectionLearning => 'Aprendizado';

  @override
  String get settingsSectionSubscription => 'Assinatura';

  @override
  String get settingsSectionAccessibility => 'Acessibilidade';

  @override
  String get settingsSectionNotifications => 'Notificações';

  @override
  String get settingsSectionAppearanceAccount => 'Aparência e conta';

  @override
  String get settingsAppLanguage => 'Idioma do aplicativo';

  @override
  String get settingsAppLanguageSystem => 'Padrão do sistema';

  @override
  String get homeCourseLoadingTitle => 'Seu curso está sendo preparado';

  @override
  String get homeCourseLoadingBody =>
      'As lições aparecerão aqui quando o conteúdo do curso carregar.';

  @override
  String get homeGuideChip => 'Guia';

  @override
  String get homeStartNode => 'COMEÇAR';

  @override
  String get homeUnitGuideHeader => 'GUIA DA UNIDADE';

  @override
  String get commonDone => 'Concluído';

  @override
  String homeUnitKicker(String unit) {
    return 'UNIDADE · $unit';
  }

  @override
  String homeLessonMeta(int num, int count, String exercises) {
    return 'Lição $num de $count · $exercises.';
  }

  @override
  String homeQuickExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercícios rápidos',
      one: '$count exercício rápido',
    );
    return '$_temp0';
  }

  @override
  String get homeEnergyChip => '−1 ⚡ energia';

  @override
  String get homeXpChip => '+20 XP';

  @override
  String get homeStartLesson => 'Começar lição';

  @override
  String get homeTutorChip => 'Tutor';

  @override
  String get libraryAiTutor => 'Tutor de IA';

  @override
  String get libraryAiTutorSub =>
      'Fale, converse e encene — feedback de escrita';

  @override
  String get libraryRoleplay => 'Roleplay';

  @override
  String get libraryRoleplaySub =>
      'Pratique respostas — avaliado, sempre grátis';

  @override
  String get librarySectionPractice => 'Prática';

  @override
  String get libraryPracticeHub => 'Central de prática';

  @override
  String get libraryPracticeHubSub =>
      'Erros, palavras fracas e exercícios · GRÁTIS';

  @override
  String get librarySectionReadListen => 'Ler e ouvir';

  @override
  String get libraryGradedStories => 'Histórias graduadas';

  @override
  String get libraryPodcasts => 'Podcasts';

  @override
  String get libraryWatch => 'Assistir';

  @override
  String get librarySearchHint => 'Busque lições, palavras, histórias…';

  @override
  String get libraryFeaturedStory => 'DESTAQUE · HISTÓRIA';

  @override
  String commonLevel(String cefr) {
    return 'Nível $cefr';
  }

  @override
  String get libraryReadNow => 'Ler agora';

  @override
  String get libraryNewExplore => 'NOVO · EXPLORAR';

  @override
  String get libraryAdventures => 'Aventuras';

  @override
  String get libraryStartExploring => 'Comece a explorar →';

  @override
  String get libraryKindStory => 'História';

  @override
  String get libraryKindPodcast => 'Podcast';

  @override
  String get libraryKindVideo => 'Vídeo';

  @override
  String get libraryAllStories => 'Todas as histórias';

  @override
  String get libraryAllPodcasts => 'Todos os podcasts';

  @override
  String get libraryAllVideos => 'Todos os vídeos';

  @override
  String get lessonTypeWhatYouHear => 'Digite o que você ouvir';

  @override
  String get lessonTapWhatYouHear => 'Toque no que você ouvir';

  @override
  String get lessonTranslateSentence => 'Traduza esta frase';

  @override
  String get lessonTypeAnswerHint => 'Digite sua resposta…';

  @override
  String get lessonWriteAnswerHint => 'Escreva sua resposta…';

  @override
  String get lessonContinue => 'Continuar';

  @override
  String get lessonSkip => 'Pular';

  @override
  String get lessonCheck => 'Verificar';

  @override
  String get lessonNicelyDone => '✓ Muito bem!';

  @override
  String get lessonNotQuite => '✕ Não foi dessa vez';

  @override
  String lessonAnswerReveal(String answer) {
    return 'Resposta: $answer';
  }

  @override
  String get lessonCompleteKicker => 'LIÇÃO CONCLUÍDA';

  @override
  String get lessonCompleteTitle => 'Lição concluída!';

  @override
  String lessonCompleteSummary(int correct, int graded, String level) {
    return '$correct de $graded corretas · agora $level';
  }

  @override
  String get lessonStatTotalXp => 'XP TOTAL';

  @override
  String get lessonStatAccuracy => 'PRECISÃO';

  @override
  String get lessonStatTime => 'TEMPO';
}
