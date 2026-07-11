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

  @override
  String get onboardingWelcomeTitle => 'Oi, eu sou o Ratel!';

  @override
  String get onboardingWelcomeBody =>
      'Aprenda um idioma sem medo — em doses pequenas, divertido e grátis. Pronto para começar?';

  @override
  String get onboardingHaveAccount => 'Já tenho uma conta';

  @override
  String get onboardingTryWithoutAccount => 'Experimentar sem conta →';

  @override
  String get onboardingGetStarted => 'Começar';

  @override
  String get onboardingStartLearning => 'Começar a aprender';

  @override
  String get onboardingLanguageTitle => 'O que você quer aprender?';

  @override
  String get onboardingLanguageSubtitle => '52 idiomas disponíveis';

  @override
  String get onboardingReasonTitle => 'Por que você está aprendendo?';

  @override
  String get onboardingGoalTitle => 'Escolha uma meta diária';

  @override
  String get onboardingPlacementTitle => 'Encontre seu ponto de partida';

  @override
  String onboardingPlacementBody(String language) {
    return 'Novo em $language ou já sabe um pouco?';
  }

  @override
  String get onboardingBrandNew => 'Sou iniciante';

  @override
  String get onboardingBrandNewSub => 'Comece do zero';

  @override
  String get onboardingPlacementTest => 'Fazer um teste de nivelamento';

  @override
  String get onboardingPlacementTestSub => '~3 min · pule para o seu nível';

  @override
  String onboardingXpPerDay(int xp) {
    return '$xp XP / dia';
  }

  @override
  String get reasonTravel => 'Viagens';

  @override
  String get reasonCulture => 'Cultura';

  @override
  String get reasonCareer => 'Carreira';

  @override
  String get reasonFamilyFriends => 'Família e amigos';

  @override
  String get reasonBrainTraining => 'Treinar o cérebro';

  @override
  String get reasonJustForFun => 'Só por diversão';

  @override
  String get goalCasual => 'Casual';

  @override
  String get goalRegular => 'Regular';

  @override
  String get goalSerious => 'Sério';

  @override
  String get goalIntense => 'Intenso';

  @override
  String get langNameSpanish => 'Espanhol';

  @override
  String get langNameFrench => 'Francês';

  @override
  String get langNameJapanese => 'Japonês';

  @override
  String get langNameTamil => 'Tâmil';

  @override
  String get langNameGerman => 'Alemão';

  @override
  String get langNameKorean => 'Coreano';

  @override
  String get settingsDailyGoal => 'Meta diária';

  @override
  String settingsGoalRow(String label, int xp) {
    return '$label · $xp XP/dia';
  }

  @override
  String get profileAchievements => 'Conquistas';

  @override
  String get profileFriends => 'Amigos';

  @override
  String get profileShop => 'Loja';

  @override
  String get profileNotifications => 'Notificações';

  @override
  String get profileSeeOnboarding => 'Ver o fluxo de boas-vindas ↗';

  @override
  String get profileNotSignedIn => 'Não conectado';

  @override
  String get profileCreateAccount => 'Crie uma conta grátis';

  @override
  String get profileSaveProgress =>
      'Salve seu progresso em todos os dispositivos';

  @override
  String profileTodaysGoal(int today, int goal) {
    return 'Meta de hoje · $today/$goal XP';
  }

  @override
  String get profileViewProgress => 'Ver progresso →';

  @override
  String get profileUnlocked => 'Desbloqueado';

  @override
  String questsResetsIn(int h, int m) {
    return 'Reinicia em ${h}h ${m}min';
  }

  @override
  String get questsDailyRefresh => 'Atualização diária';

  @override
  String get questsFreshMix => 'Uma mistura nova de 5 perguntas';

  @override
  String get questsServedFromQueue =>
      'Servido da sua fila real de revisão — rende XP real.';

  @override
  String get questsGoalReached => 'Meta diária alcançada! 🎉';

  @override
  String questsReachGoal(int goal) {
    return 'Alcance $goal XP hoje';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return 'Missões diárias · $done/$total';
  }

  @override
  String get questsInfoNote =>
      'As missões acompanham seu progresso diário real. Baús de recompensa, missões com amigos e ranking semanal precisam de economia de backend — decisão do proprietário (§6). Nenhuma recompensa falsa é exibida.';

  @override
  String get questsStartRefresh => 'Começar a atualização diária';

  @override
  String get questsStart => 'Começar';

  @override
  String get questsPractisedToday => 'Praticou hoje — ofensiva segura';

  @override
  String get questsEarnAnyXp => 'Ganhe qualquer XP hoje';

  @override
  String questsXpToday(int current, int target) {
    return '$current/$target XP hoje';
  }

  @override
  String get leaguesYourGroup => 'SEU GRUPO';

  @override
  String leaguesThisWeek(int size) {
    return 'ESTA SEMANA · $size ALUNOS';
  }

  @override
  String get leaguesTiers => 'Divisões da liga';

  @override
  String leaguesTopClimb(int top, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '$days dia',
    );
    return 'Os $top primeiros sobem por semana · termina em $_temp0';
  }

  @override
  String get leaguesDemotionZone => 'Zona de rebaixamento';

  @override
  String get leaguesPromotionZone => 'Zona de promoção';

  @override
  String get leaguesSafeZone => 'Zona segura';

  @override
  String get leaguesYou => 'Você';

  @override
  String leaguesPromoteRelegate(int top, int bottom) {
    return 'Os $top primeiros sobem · os $bottom últimos caem no fim da semana.';
  }

  @override
  String get leaguesYouAreHere => 'Você está aqui';

  @override
  String get leaguesViewAllTiers => '🏆 Ver as 10 divisões ›';

  @override
  String get notifMarkAllRead => 'Marcar tudo como lido';

  @override
  String get notifEmptyTitle => 'Nenhuma notificação ainda';

  @override
  String get notifEmptyBody =>
      'Termine lições, monte uma ofensiva e suba de nível — seus marcos aparecerão aqui no momento em que você realmente os conquistar.';

  @override
  String get notifPushNote =>
      'Estes são marcos no app, exibidos no momento em que você os conquista. Notificações push e lembretes são decisão do proprietário e ainda não estão ativados — nada aqui é falso.';
}
