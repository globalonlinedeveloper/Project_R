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
  String homeSectionN(int n) {
    return 'SEÇÃO $n';
  }

  @override
  String homeSectionLevel(int n, String band) {
    return 'SEÇÃO $n · NÍVEL $band';
  }

  @override
  String homeLevelBand(String band) {
    return 'Nível $band';
  }

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
  String get lessonExplainThis => '💡 Explicar isto';

  @override
  String get lessonMatchPairs => 'Combine os pares';

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
  String get onboardingLanguageSubtitle =>
      'Aprenda inglês a partir de 10 idiomas';

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
  String get langNameEnglish => 'Inglês';

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

  @override
  String get shopPowerUps => 'Potencializadores';

  @override
  String get shopStreakFreeze => 'Congelamento de ofensiva';

  @override
  String get shopStreakFreezeDesc =>
      'Protege sua ofensiva por um dia perdido. Gasto automaticamente quando você perde a meta diária.';

  @override
  String shopOwned(int have, int max) {
    return 'Possui $have/$max';
  }

  @override
  String get shopMaxedOut => 'No máximo';

  @override
  String shopBuyFor(int cost) {
    return 'Comprar por $cost 💎';
  }

  @override
  String get shopFreezeAdded => 'Congelamento adicionado 💪';

  @override
  String shopFreezeAtCap(int max) {
    return 'Você já tem o máximo de congelamentos ($max).';
  }

  @override
  String shopNotEnoughEarnCost(int cost) {
    return '💎 insuficientes — ganhe $cost concluindo lições.';
  }

  @override
  String get shopNotEnoughEarnMore =>
      '💎 insuficientes — ganhe mais concluindo lições.';

  @override
  String get shopEnergyRefill => 'Recarga de energia';

  @override
  String get shopEnergyRefillDesc =>
      'Recarregue sua energia até o máximo. A energia é só visual — as lições nunca bloqueiam.';

  @override
  String get shopAlreadyFull => 'Já cheia';

  @override
  String get shopEnergyRefilled => 'Energia recarregada ⚡';

  @override
  String get shopEnergyAlreadyFull => 'Sua energia já está cheia.';

  @override
  String get shopStreakRepair => 'Reparo de ofensiva';

  @override
  String get shopStreakRepairDesc =>
      'Perdeu a ofensiva? Restaure o tamanho anterior e continue em frente.';

  @override
  String get shopStreakLapsed => 'Ofensiva perdida';

  @override
  String shopStreakDays(int days) {
    return '🔥 Ofensiva de $days dias';
  }

  @override
  String shopRepairFor(int cost) {
    return 'Reparar por $cost 💎';
  }

  @override
  String get shopStreakRestored => 'Ofensiva restaurada 🔥';

  @override
  String get shopStreakSafe =>
      'Sua ofensiva está segura — nada a reparar agora.';

  @override
  String get shopDoubleXp => 'XP em dobro';

  @override
  String get shopDoubleXpDesc => 'Ganhe 2× XP em cada lição por 15 minutos.';

  @override
  String shopActiveLeft(int minutes) {
    return 'Ativo · faltam ${minutes}min';
  }

  @override
  String get shopInactive => 'Inativo';

  @override
  String get shopActive => 'Ativo';

  @override
  String get shopDoubleXpActive => 'XP em dobro ativado ✨';

  @override
  String get shopBoostRunning => 'Seu bônus está rodando — o XP está dobrado.';

  @override
  String get shopBadgerOutfits => 'Trajes do texugo';

  @override
  String get paywallTitle => 'RATEL PRO';

  @override
  String get paywallStartTrial => 'Iniciar teste grátis de 7 dias';

  @override
  String paywallGoPro(String price) {
    return 'Seja Pro — $price/mês';
  }

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallHero =>
      'Tutoria com IA ao vivo, sem anúncios e lições offline.';

  @override
  String get paywallAnnual => 'Anual';

  @override
  String get paywallMonthly => 'Mensal';

  @override
  String get paywallTrialHow => 'Como funciona o teste grátis de 7 dias';

  @override
  String get paywallTrialToday => 'Hoje';

  @override
  String get paywallTrialTodayDesc =>
      'Acesso Pro completo liberado. Sem cobrança.';

  @override
  String get paywallTrialDay5 => 'Dia 5';

  @override
  String get paywallTrialDay5Desc => 'Lembramos você antes do fim do teste.';

  @override
  String get paywallTrialDay7 => 'Dia 7';

  @override
  String paywallTrialDay7Desc(String price) {
    return '$price/ano começa a valer, a menos que você cancele.';
  }

  @override
  String get paywallFeatureLiveAi =>
      'IA ao vivo: voz, chat com tutor e feedback de escrita';

  @override
  String get paywallFeatureNoAds => 'Sem anúncios, em lugar nenhum';

  @override
  String get paywallFeatureOffline => 'Lições e áudio offline';

  @override
  String get paywallFeaturePronunciation => 'Dicas de pronúncia com IA';

  @override
  String get paywallEverythingFree =>
      'Todo o resto — áudio, revisão, ligas, roleplay e pronúncia no dispositivo — continua grátis para todos.';

  @override
  String get paywallYouArePro => 'Você está no RATEL PRO';

  @override
  String get paywallThanks =>
      'Obrigado por apoiar o Ratel. Gerencie ou cancele quando quiser em Configurações → Gerenciar assinatura.';

  @override
  String get paywallManage => 'Gerenciar assinatura';

  @override
  String paywallFinePrint(String regions) {
    return 'Cancele quando quiser nas Configurações. Preços exibidos para $regions; seu preço local é definido pela loja de aplicativos.';
  }

  @override
  String get paywallRegionsTier1 => 'EUA, UE, Japão, Austrália';

  @override
  String get paywallRegionsMid =>
      'América Latina, Sudeste Asiático, Europa Oriental';

  @override
  String get paywallRegionsLowPpp => 'Índia, Paquistão, Nigéria, Bangladesh';

  @override
  String get questTitlePowerSession => 'Sessão intensa';

  @override
  String get questDescPowerSession => 'Ganhe o dobro da sua meta diária';

  @override
  String get questTitleOnFire => 'Em chamas';

  @override
  String get questDescOnFire => 'Ganhe o triplo da sua meta diária';

  @override
  String get questTitleStreakKeeper => 'Guardião da ofensiva';

  @override
  String get questDescStreakKeeper => 'Pratique hoje para manter sua ofensiva';

  @override
  String get notifTitleLessons1 => 'Primeira lição concluída';

  @override
  String get notifBodyLessons1 =>
      'Você terminou sua primeira lição — ótimo começo!';

  @override
  String get notifTitleLessons5 => '5 lições concluídas';

  @override
  String get notifBodyLessons5 => 'Você completou 5 lições. Mantenha o ritmo.';

  @override
  String get notifTitleLessons10 => '10 lições concluídas';

  @override
  String get notifBodyLessons10 =>
      'Dez lições — você está criando um hábito de verdade.';

  @override
  String get notifTitleLessons25 => '25 lições concluídas';

  @override
  String get notifBodyLessons25 =>
      'Vinte e cinco lições concluídas. Dedicação impressionante!';

  @override
  String get notifTitleLessons50 => '50 lições concluídas';

  @override
  String get notifBodyLessons50 =>
      'Cinquenta lições — você está no caminho certo.';

  @override
  String get notifTitleStreak3 => 'Ofensiva de 3 dias!';

  @override
  String get notifBodyStreak3 => 'Três dias seguidos. Constância é tudo.';

  @override
  String get notifTitleStreak7 => 'Ofensiva de 7 dias!';

  @override
  String get notifBodyStreak7 =>
      'Uma semana inteira de prática diária. Extraordinário!';

  @override
  String get notifTitleStreak14 => 'Ofensiva de 14 dias!';

  @override
  String get notifBodyStreak14 =>
      'Duas semanas seguidas — você está imparável.';

  @override
  String get notifTitleStreak30 => 'Ofensiva de 30 dias!';

  @override
  String get notifBodyStreak30 => 'Um mês inteiro de prática diária. Incrível.';

  @override
  String get notifTitleXp100 => '100 XP ganhos';

  @override
  String get notifBodyXp100 =>
      'Seus primeiros cem XP — o ritmo está crescendo.';

  @override
  String get notifTitleXp500 => '500 XP ganhos';

  @override
  String get notifBodyXp500 => 'Quinhentos XP. Você está se dedicando.';

  @override
  String get notifTitleXp1000 => '1.000 XP ganhos';

  @override
  String get notifBodyXp1000 => 'Marco de mil XP alcançado!';

  @override
  String get notifTitleXp2500 => '2.500 XP ganhos';

  @override
  String get notifBodyXp2500 => 'Dois mil e quinhentos XP — progresso sério.';

  @override
  String get notifTitleLevel1 => 'Nível A2 alcançado';

  @override
  String get notifBodyLevel1 => 'Sua habilidade cresceu de A1 para A2. Avante!';

  @override
  String get notifTitleLevel2 => 'Nível B1 alcançado';

  @override
  String get notifBodyLevel2 => 'Você agora é um aprendiz intermediário (B1).';

  @override
  String get notifTitleLevel3 => 'Nível B2 alcançado';

  @override
  String get notifBodyLevel3 =>
      'Intermediário superior (B2) alcançado. Brilhante.';

  @override
  String get notifTitleLevel4 => 'Nível C1 alcançado';

  @override
  String get notifBodyLevel4 => 'Avançado (C1) — seu inglês está forte.';

  @override
  String get notifTitleLevel5 => 'Nível C2 alcançado';

  @override
  String get notifBodyLevel5 => 'Proficiência (C2) — o topo da escala!';

  @override
  String get achTitleFirstSteps => 'Primeiros Passos';

  @override
  String get achTitleScholar => 'Erudito';

  @override
  String get achTitleWildfire => 'Fogo Selvagem';

  @override
  String get achTitlePointMaker => 'Pontuador';

  @override
  String get achTitleCollector => 'Colecionador';

  @override
  String get achTitleRisingStar => 'Estrela em Ascensão';

  @override
  String get leagueTierBronze => 'Bronze';

  @override
  String get leagueTierSilver => 'Prata';

  @override
  String get leagueTierGold => 'Ouro';

  @override
  String get leagueTierSapphire => 'Safira';

  @override
  String get leagueTierRuby => 'Rubi';

  @override
  String get leagueTierEmerald => 'Esmeralda';

  @override
  String get leagueTierAmethyst => 'Ametista';

  @override
  String get leagueTierPearl => 'Pérola';

  @override
  String get leagueTierObsidian => 'Obsidiana';

  @override
  String get leagueTierDiamond => 'Diamante';

  @override
  String get cefrNameBeginner => 'Iniciante';

  @override
  String get cefrNameElementary => 'Elementar';

  @override
  String get cefrNameIntermediate => 'Intermediário';

  @override
  String get cefrNameUpperIntermediate => 'Intermediário superior';

  @override
  String get cefrNameAdvanced => 'Avançado';

  @override
  String get cefrNameProficient => 'Proficiente';

  @override
  String leaguesTierLeague(String tier) {
    return 'Liga $tier';
  }

  @override
  String leaguesYoureIn(String tier) {
    return 'Você está em $tier · os 7 primeiros sobem a cada semana';
  }

  @override
  String get leaguesZonePromotion => '⬆ ZONA DE PROMOÇÃO';

  @override
  String get leaguesZoneDemotion => '⬇ ZONA DE REBAIXAMENTO';

  @override
  String profileAchievementsSummary(int unlocked, int total) {
    return '$unlocked de $total desbloqueadas · progresso real';
  }

  @override
  String get profileRealStateNote =>
      'Nível, XP, lições, ofensiva e palavras salvas são estado real do motor — começam do zero numa conta nova.';

  @override
  String get practiceTitle => 'Prática';

  @override
  String practiceReviewWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Revisar $count palavras',
      one: 'Revisar 1 palavra',
    );
    return '$_temp0';
  }

  @override
  String get practiceYourWords => 'Suas palavras';

  @override
  String practiceSavedWordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palavras salvas',
      one: '$count palavra salva',
    );
    return '$_temp0';
  }

  @override
  String practiceDueForReview(int count) {
    return '$count pendentes de revisão espaçada';
  }

  @override
  String get practiceAllUpToDate => 'Todas as revisões em dia';

  @override
  String practiceCaughtUp(String tail) {
    return 'Tudo em dia — nada pendente agora$tail.';
  }

  @override
  String practiceNextTail(String when) {
    return ' · próxima $when';
  }

  @override
  String get practiceZeroDue => '0 pendentes';

  @override
  String get practiceDueNow => 'Pendente agora';

  @override
  String practiceDueWhen(String when) {
    return 'Pendente $when';
  }

  @override
  String get practiceChipDue => 'Pendente';

  @override
  String get practiceChipScheduled => 'Agendada';

  @override
  String get practiceScheduleNote =>
      'As revisões são agendadas pelo motor real de repetição espaçada FSRS-6. As datas persistem nesta sessão; salvá-las entre reinícios é etapa de lançamento — nada aqui é inventado.';

  @override
  String get practiceNoSavedWords => 'Nenhuma palavra salva ainda';

  @override
  String get practiceSaveWordHint =>
      'Salve uma palavra enquanto pratica uma lição e ela chega aqui como flashcard. As revisões são então agendadas pelo motor real FSRS de repetição espaçada — nada vem pré-preenchido.';

  @override
  String get practiceStartLesson => 'Começar uma lição';

  @override
  String practiceWordOf(int n, int total) {
    return 'Palavra $n de $total';
  }

  @override
  String get practiceShowAnswer => 'Mostrar resposta';

  @override
  String get practiceRecallHint =>
      'Lembre o significado e depois avalie quão bem você lembrou.';

  @override
  String get practiceGradeAgain => 'De novo';

  @override
  String get practiceGradeHard => 'Difícil';

  @override
  String get practiceGradeGood => 'Bom';

  @override
  String get practiceGradeEasy => 'Fácil';

  @override
  String get practiceFsrsGradeNote =>
      'O FSRS-6 agenda a próxima revisão a partir da sua avaliação';

  @override
  String get practiceReviewComplete => 'Revisão concluída';

  @override
  String practiceReviewedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Você revisou $count palavras. O FSRS as reagendou.',
      one: 'Você revisou 1 palavra. O FSRS a reagendou.',
    );
    return '$_temp0';
  }

  @override
  String get practiceDone => 'Concluir';

  @override
  String get practiceRelTomorrow => 'amanhã';

  @override
  String practiceRelInDays(int days) {
    return 'em $days dias';
  }

  @override
  String practiceRelInHours(int hours) {
    return 'em $hours h';
  }

  @override
  String practiceRelInMinutes(int minutes) {
    return 'em $minutes min';
  }

  @override
  String get practiceRelSoon => 'em breve';

  @override
  String get progressTitle => 'Progresso';

  @override
  String get progressYourLevel => 'YOUR LEVEL';

  @override
  String get progressShareMilestone => 'Compartilhar marco';

  @override
  String get progressLast7Days => 'Últimos 7 dias';

  @override
  String get progressAccuracyRetention => 'Precisão e retenção';

  @override
  String get progressHonestyNote =>
      'Tudo aqui é estado real registrado — nível, habilidade, palavras salvas, XP, lições, ofensiva, seu histórico de 7 dias, precisão e tempo de estudo começam do zero e crescem com o aprendizado. Retenção é a recordação prevista desta sessão (o agendador entre sessões é trabalho de lançamento); nada é inventado.';

  @override
  String progressShareText(
    String level,
    String levelName,
    int streak,
    int xp,
    int lessons,
  ) {
    return '🦡 RATEL · Nível $level ($levelName)\n🔥 Ofensiva de $streak dias · ⚡ $xp XP · 📘 $lessons lições\nAprendendo em learnwithratel.com';
  }

  @override
  String get progressShareCopied =>
      'Marco copiado para a área de transferência — compartilhe onde quiser!';

  @override
  String progressAbilityLine(String theta) {
    return 'Habilidade θ $theta · estimativa real';
  }

  @override
  String get progressStatSavedWords => 'Palavras salvas';

  @override
  String get progressStatLessons => 'Lições';

  @override
  String get progressStatDayStreak => 'Dias de ofensiva';

  @override
  String get progressStatTotalXp => 'XP total';

  @override
  String get progressStatTodaysXp => 'XP de hoje';

  @override
  String get progressStatCefrLevel => 'Nível CEFR';

  @override
  String get progressAccuracy => 'Precisão';

  @override
  String get progressStudyTime => 'Tempo de estudo';

  @override
  String get progressRetention => 'Retenção';

  @override
  String get progressNoData => 'Sem dados ainda';

  @override
  String get progressAccuracyEmpty =>
      'Responda exercícios avaliados para começar';

  @override
  String progressAccuracyDetail(int correct, int total) {
    return '$correct de $total corretas';
  }

  @override
  String get progressTimeEmpty => 'O tempo das lições soma aqui';

  @override
  String get progressTimeDetail => 'em todas as suas lições';

  @override
  String get progressRetentionEmpty =>
      'Revise itens para ver a recordação prevista';

  @override
  String progressRetentionDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recordação prevista de 1 dia · $count itens nesta sessão',
      one: 'recordação prevista de 1 dia · 1 item nesta sessão',
    );
    return '$_temp0';
  }

  @override
  String progressWeekTotal(int xp) {
    return '$xp XP · últimos 7 dias';
  }

  @override
  String get progressNoXpYet => 'Nenhum XP registrado ainda';

  @override
  String get progressChartEmptyNote =>
      'Termine uma lição para iniciar seu histórico de 7 dias — dias inativos ficam em zero, nada é inventado.';

  @override
  String get commonDowMon => 'Se';

  @override
  String get commonDowTue => 'Te';

  @override
  String get commonDowWed => 'Qa';

  @override
  String get commonDowThu => 'Qi';

  @override
  String get commonDowFri => 'Sx';

  @override
  String get commonDowSat => 'Sá';

  @override
  String get commonDowSun => 'Do';

  @override
  String get searchTitle => 'Buscar';

  @override
  String get searchHint => 'Busque lições, palavras, histórias…';

  @override
  String get searchRecent => 'Recentes';

  @override
  String get searchClear => 'Limpar';

  @override
  String get searchJumpTo => 'Ir para';

  @override
  String get searchTagPage => 'Página';

  @override
  String get searchTagWord => 'Palavra';

  @override
  String get searchSubtitleSavedWord => 'Palavra salva';

  @override
  String searchLessonSubtitle(String unit) {
    return '$unit · Lição';
  }

  @override
  String searchNoMatches(String query) {
    return 'Nenhum resultado para “$query”';
  }

  @override
  String get searchEmptyNote =>
      'Busca em títulos, tags e conteúdo das lições do seu curso, palavras salvas e páginas. O índice de conteúdo no servidor e tendências são o próximo passo do R-L12 — nada aqui é falso.';

  @override
  String get searchNoMatchNote =>
      'Busca nas lições publicadas do seu curso, palavras salvas e páginas do app (títulos + tags). Histórias/podcasts e texto completo são o próximo passo do R-L12 — nunca falsificado.';

  @override
  String get searchFooterNote =>
      'Títulos + tags no lançamento. Texto completo, histórias/podcasts e multi-curso são o próximo passo do R-L12 — nunca falsificado.';

  @override
  String get searchDestPracticeHub => 'Central de prática';

  @override
  String get searchDestPracticeHubSub => 'Erros, palavras fracas e exercícios';

  @override
  String get searchDestAiTutor => 'Tutor de IA';

  @override
  String get searchDestAiTutorSub => 'Fale, converse e faça roleplay';

  @override
  String get searchDestAdventures => 'Aventuras';

  @override
  String get searchDestAdventuresSub => 'Conversas reais — grátis';

  @override
  String get searchDestLeagues => 'Ligas';

  @override
  String get searchDestLeaguesSub => 'Sua liga semanal';

  @override
  String get searchDestQuests => 'Missões';

  @override
  String get searchDestQuestsSub => 'Metas e missões diárias';

  @override
  String get searchDestProgress => 'Progresso';

  @override
  String get searchDestProgressSub => 'Suas estatísticas e ofensiva';

  @override
  String get searchDestProfile => 'Perfil';

  @override
  String get searchDestProfileSub => 'Seu perfil';

  @override
  String get searchDestSettings => 'Configurações';

  @override
  String get searchDestSettingsSub => 'Conta e preferências';

  @override
  String get searchDestShop => 'Loja';

  @override
  String get searchDestShopSub => 'Gaste seus diamantes';

  @override
  String get searchDestNotifications => 'Notificações';

  @override
  String get searchDestNotificationsSub => 'Sua caixa de marcos';

  @override
  String get themesTitle => 'Temas';

  @override
  String get themesSubtitle =>
      'Muda o estilo do app inteiro — toque para pré-visualizar ao vivo';

  @override
  String themesVehicle(String vehicle) {
    return 'Veículo · $vehicle';
  }

  @override
  String get tutorHeader => 'Pratique uma conversa real';

  @override
  String get tutorHeaderSub =>
      'Escolha uma cena e converse com o Ratel — sem respostas erradas, só prática.';

  @override
  String get tutorTalkTitle => 'Fale com o Ratel';

  @override
  String get tutorTalkSub => 'Prática de fala ao vivo com voz e vídeo';

  @override
  String get tutorChatTitle => 'Converse com o Ratel';

  @override
  String get tutorChatSub => 'Chat com IA · feedback de escrita';

  @override
  String get tutorRoleplayTitle => 'Cenas de roleplay';

  @override
  String get tutorRoleplayGuided => 'Conversas de roleplay guiadas';

  @override
  String tutorScenesCount(int count) {
    return '$count cenas';
  }

  @override
  String get tutorUnlockPro => 'Desbloquear RATEL PRO';

  @override
  String get tutorRelayNote =>
      'A tutoria de IA ao vivo roda em um relay moderado e com custo controlado, e é um recurso RATEL PRO. As respostas nunca são simuladas — um modo só inicia quando PRO e relay estão ativos.';

  @override
  String get tutorStatusReadyPro =>
      'PRO ativo e tutor ao vivo conectado — escolha um modo para começar.';

  @override
  String get tutorStatusReadyFree =>
      'O tutor ao vivo está conectado. A tutoria ao vivo é um recurso RATEL PRO.';

  @override
  String get tutorStatusOffline =>
      'O tutor ao vivo moderado ainda não está conectado nesta versão — a tutoria ao vivo será ativada em uma etapa futura. Nada abaixo é simulado.';

  @override
  String get tutorAnnounceNeedsPro =>
      'O RATEL PRO desbloqueia a tutoria de IA ao vivo.';

  @override
  String get tutorAnnounceNeedsRelay =>
      'A tutoria de IA conecta assim que o relay moderado for habilitado.';

  @override
  String get tutorAnnounceStarting => 'Iniciando sua sessão…';

  @override
  String get adventuresTitle => 'Aventuras';

  @override
  String get adventuresFreeChip => 'GRÁTIS';

  @override
  String get adventuresHeaderSub => 'Explore um mundo · converse do seu jeito';

  @override
  String get adventuresHeroTitle => 'Escolha um lugar e mergulhe';

  @override
  String get adventuresHeroSub =>
      'Cada cena é uma conversa real — sem respostas erradas, e sempre grátis.';

  @override
  String get adventuresFallbackWorld => 'Aventura';

  @override
  String adventureSheetKicker(String cefr) {
    return '🗺️ AVENTURA · $cefr';
  }

  @override
  String adventureScenesCount(int count) {
    return '$count cenas';
  }

  @override
  String adventureChoicePoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pontos de decisão',
      one: '$count ponto de decisão',
    );
    return '$_temp0';
  }

  @override
  String get adventureOpeningScene => 'CENA DE ABERTURA';

  @override
  String get adventureStart => 'Começar aventura';

  @override
  String get adventurePlayerFallbackTitle => 'Aventura';

  @override
  String get adventureTheEnd => '🏁 Fim';

  @override
  String get adventureStartOver => 'Recomeçar';

  @override
  String get adventureDone => 'Concluído';

  @override
  String get adventureCompleteKicker => 'AVENTURA CONCLUÍDA';

  @override
  String adventureCompleteTitle(String title) {
    return '$title ✓';
  }

  @override
  String get adventureCompleteBody =>
      'Muito bem! +15 XP · +5 💎 ganhos — explore a próxima cena quando quiser.';

  @override
  String adventureDistrictProgress(int done, int total) {
    return '$done/$total exploradas';
  }

  @override
  String get adventureDistrictDone => '✓ Concluído';

  @override
  String get adventureDistrictCafe => 'Café & Food';

  @override
  String get adventureDistrictMarket => 'Market Square';

  @override
  String get adventureDistrictMove => 'On the Move';

  @override
  String get adventureDistrictFriends => 'Making Friends';

  @override
  String get adventuresEmpty => 'Ainda não há aventuras neste curso.';

  @override
  String get authWelcomeTitle => 'Bem-vindo ao Ratel';

  @override
  String get authWelcomeSubtitle =>
      'Lições, histórias, podcasts e mais —\nescolha como quer começar.';

  @override
  String get authCreateFreeAccount => 'Criar conta grátis';

  @override
  String get authAlreadyHaveAccount => 'Já tenho uma conta';

  @override
  String get authSettingUp => 'Preparando tudo…';

  @override
  String get authContinueAsGuest => 'Continuar como convidado';

  @override
  String get authGuestNote =>
      'O progresso de convidado fica neste aparelho — crie uma conta grátis em Configurações quando quiser para levá-lo a qualquer lugar.';

  @override
  String get authEnterYourEmail => 'Digite seu e-mail';

  @override
  String get authEnterValidEmail => 'Digite um e-mail válido';

  @override
  String get authEnterYourPassword => 'Digite sua senha';

  @override
  String get authCouldNotSignIn => 'Não foi possível entrar. Tente de novo.';

  @override
  String get authSomethingWentWrong => 'Algo deu errado. Tente de novo.';

  @override
  String get authSocialComingSoon => 'Login com Google / Apple chega em breve.';

  @override
  String get authResetTitle => 'Redefina sua senha';

  @override
  String get authWelcomeBack => 'Bem-vindo de volta!';

  @override
  String get authResetSubtitle =>
      'Digite seu e-mail e enviaremos um link de redefinição.';

  @override
  String get authPickUpWhereYouLeft => 'Continue de onde parou';

  @override
  String get authEmailHint => 'E-mail';

  @override
  String get authPasswordHint => 'Senha';

  @override
  String get authForgotPassword => 'Esqueceu a senha?';

  @override
  String get authSendResetLink => 'Enviar link';

  @override
  String get authLogIn => 'Entrar';

  @override
  String get authBackToLogIn => 'Voltar ao login';

  @override
  String get authNewToRatel => 'Novo no Ratel? ';

  @override
  String get authSignUp => 'Cadastre-se';

  @override
  String get authCheckYourInbox => 'Confira sua caixa de entrada';

  @override
  String authResetSent(String email) {
    return 'Enviamos um link de redefinição de senha para $email. Abra-o para escolher uma nova senha.';
  }

  @override
  String get authCreatePassword => 'Crie uma senha';

  @override
  String get authAtLeast8Chars => 'Pelo menos 8 caracteres';

  @override
  String get authCreateYourAccount => 'Crie sua conta';

  @override
  String get authSignupSubtitle =>
      'Grátis para sempre · aprenda inglês a partir de 10 idiomas';

  @override
  String get authPassword8Hint => 'Senha (8+ caracteres)';

  @override
  String get authCreateAccount => 'Criar conta';

  @override
  String get authAlreadyAccountLead => 'Já tem uma conta? ';

  @override
  String get authSignIn => 'Entrar';

  @override
  String get authConfirmEmail => 'Confirme seu e-mail';

  @override
  String authConfirmSent(String email) {
    return 'Enviamos um link de confirmação para $email. Toque nele para ativar sua conta e volte para entrar.';
  }

  @override
  String get authContinueGoogle => 'Continuar com Google';

  @override
  String get authContinueApple => 'Continuar com Apple';

  @override
  String get authOr => 'ou';

  @override
  String get authUnavailableNote =>
      'Contas ainda não estão disponíveis nesta versão — você pode continuar aprendendo como convidado. O login será ativado quando o backend for configurado.';

  @override
  String get liveMute => 'Silenciar';

  @override
  String get liveUnmute => 'Ativar som';

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
    return '$label · $days d';
  }

  @override
  String settingsGoalPerDay(int goal) {
    return '$goal XP por dia';
  }

  @override
  String settingsGoalReachedSub(int goal) {
    return '$goal XP por dia · ✓ atingida hoje';
  }

  @override
  String get settingsSoundEffects => 'Efeitos sonoros';

  @override
  String get settingsHaptics => 'Vibração';

  @override
  String get settingsProActive => 'RATEL PRO ativo';

  @override
  String get settingsFreePlan => 'Plano grátis';

  @override
  String get settingsReduceMotion => 'Reduzir movimento';

  @override
  String get settingsReduceMotionSub =>
      'Chave-mestra — desliga todas as animações';

  @override
  String get settingsHighContrast => 'Alto contraste';

  @override
  String get settingsNotifPush => 'Notificações push';

  @override
  String get settingsNotifStreak => 'Lembretes de ofensiva';

  @override
  String get settingsNotifLeague => 'Atualizações da liga';

  @override
  String get settingsNotifFriend => 'Atividade dos amigos';

  @override
  String get settingsNotifFootnote =>
      'Suas escolhas já ficam salvas — a entrega é ativada quando as notificações push forem lançadas.';

  @override
  String get settingsCourse => 'Curso';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsWorld => 'Mundo';

  @override
  String get settingsEditProfile => 'Editar perfil';

  @override
  String get settingsPrivacy => 'Privacidade e dados';

  @override
  String get settingsHelp => 'Ajuda e suporte';

  @override
  String get settingsLogOut => 'Sair';

  @override
  String get settingsGuestSub =>
      'Você está aprendendo como convidado — cadastre-se para salvar o progresso';

  @override
  String settingsCouldNotOpen(String url) {
    return 'Não foi possível abrir $url';
  }

  @override
  String get settingsThemeSystem => 'Igual ao aparelho';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get mediaReadAloud => 'Ler em voz alta';

  @override
  String get mediaTranscript => 'Transcrição';

  @override
  String get mediaCheckUnderstanding => 'Verificar compreensão';

  @override
  String mediaChecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verificações de compreensão',
      one: '$count verificação de compreensão',
    );
    return '$_temp0';
  }

  @override
  String get mediaLoading => 'Carregando…';

  @override
  String get mediaPause => 'Pausar';

  @override
  String get storiesTitle => 'Histórias';

  @override
  String get storiesSub =>
      'Leia e ouça — histórias graduadas com leitura em voz alta no navegador.';

  @override
  String get storiesEmpty => 'Ainda não há histórias neste curso.';

  @override
  String get storyFallbackTitle => 'História';

  @override
  String get podcastsSub =>
      'Ouça — podcasts graduados com áudio real e transcrição.';

  @override
  String get podcastsEmpty => 'Ainda não há podcasts neste curso.';

  @override
  String get podcastFallbackTitle => 'Podcast';

  @override
  String get podcastPlayEpisode => 'Reproduzir episódio';

  @override
  String get watchSub =>
      'Assista — clipes curtos com transcrição e verificações de compreensão.';

  @override
  String get watchEmpty => 'Ainda não há lições de vídeo neste curso.';

  @override
  String get watchWebOnly => 'O vídeo é reproduzido no aplicativo web';

  @override
  String get libraryAdventuresSub =>
      'Percorra um mundo vivo e converse pelas cenas reais.';

  @override
  String get roleplaySub =>
      'Pratique conversas reais — escolha a resposta certa e receba feedback na hora.';

  @override
  String get roleplayEmpty => 'Ainda não há roleplays neste curso.';

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
  String get roleplayYourReply => 'Sua resposta:';

  @override
  String get roleplaySceneComplete => '🎉 Cena concluída!';

  @override
  String get roleplayBack => 'Voltar aos roleplays';

  @override
  String get liveRoleplayTitle => 'Roleplay ao vivo';

  @override
  String get liveRoleplayCardSub => 'Converse com o Ratel — voz real';

  @override
  String get liveIntro =>
      'Converse com o Ratel — roleplay de voz ao vivo. Escolha uma cena ou simplesmente converse.';

  @override
  String get liveFreeConversation => 'Conversa livre';

  @override
  String get liveFreeConversationSub => 'Sem roteiro — só conversar';

  @override
  String get liveRoleplayScene => 'Encenar uma cena';

  @override
  String get liveReconnecting => 'Reconectando…';

  @override
  String get liveConnectionLost => 'Conexão perdida — a sessão ao vivo caiu.';

  @override
  String get liveReconnect => 'Reconectar';

  @override
  String get liveConnecting => 'Conectando…';

  @override
  String get liveStartTalking => 'Começar a falar';

  @override
  String get liveSceneEndedNote =>
      'A cena terminou. Recomece quando quiser — seus minutos ao vivo têm orçamento, nunca ficam em silêncio.';

  @override
  String get liveStartAgain => 'Recomeçar';

  @override
  String get liveProGate =>
      'O roleplay de voz ao vivo é um recurso RATEL PRO — conversa real, feedback ao vivo, minutos com custo controlado.';

  @override
  String get liveUnlockPro => 'Desbloquear RATEL PRO';

  @override
  String get liveNotEnabled =>
      'A voz ao vivo ainda não está habilitada nesta versão — ela é ativada em uma etapa futura. Nada aqui é simulado.';

  @override
  String get livePhaseIdle =>
      'Quando você quiser — é uma chamada ao vivo de verdade.';

  @override
  String get livePhaseListening => 'Ouvindo — é a sua vez.';

  @override
  String get livePhaseSpeaking =>
      'O Ratel está falando — participe quando quiser.';

  @override
  String get livePhaseClosed => 'A cena terminou.';

  @override
  String get liveEndScene => 'Encerrar cena';

  @override
  String get liveYou => 'Você';

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
      'Não foi possível iniciar a sessão ao vivo — tente de novo.';

  @override
  String get friendsHandleInvalid =>
      'Digite um @handle como @mia (2–20 letras, números, _).';

  @override
  String friendsAlreadyConnected(String handle) {
    return 'Você já tem uma conexão com @$handle.';
  }

  @override
  String get friendsRequests => 'Solicitações';

  @override
  String get friendsYourFriends => 'Seus amigos';

  @override
  String get friendsPending => 'Pendente';

  @override
  String get friendsActivity => 'Atividade dos amigos';

  @override
  String get friendsFootnote =>
      'Sua rede social é real e privada só sua. As solicitações de amizade são entregues, e “passou você” aparece, assim que o grafo durável entre usuários entrar no ar — a mesma etapa de lançamento de todos os outros contadores duráveis. Nada aqui é falso.';

  @override
  String get friendsAddHint => 'Adicionar um amigo por @handle…';

  @override
  String get friendsAccept => 'Aceitar';

  @override
  String friendsXpThisWeek(String handle, String xp) {
    return '@$handle · $xp XP esta semana';
  }

  @override
  String get friendsPassedYou => 'Passou você';

  @override
  String get friendsRemove => 'Remover';

  @override
  String get friendsBlock => 'Bloquear';

  @override
  String get friendsReportBlock => 'Denunciar e bloquear';

  @override
  String get friendsRequestSent => 'Solicitação enviada';

  @override
  String get friendsEmptyTitle => 'Nenhum amigo ainda';

  @override
  String get friendsEmptyBody =>
      'Adicione alguém pelo @handle para começar a compartilhar o progresso.';

  @override
  String get profileLearner => 'Aluno';

  @override
  String get profileGuest => 'Convidado';

  @override
  String get editProfileSaved => 'Perfil salvo';

  @override
  String get editProfileHandleSet => 'Salvo — seu @handle está definido.';

  @override
  String get editProfileSignInForHandle =>
      'Nome salvo. Entre para reservar seu @handle.';

  @override
  String get editProfileHandleFailed =>
      'Não foi possível definir esse @handle.';

  @override
  String get editProfileDisplayName => 'Nome de exibição';

  @override
  String get editProfileNameHint => 'Como devemos te chamar?';

  @override
  String get editProfileNameNote =>
      'Exibido no seu perfil. Salvo neste aparelho — sincroniza com sua conta quando você entra.';

  @override
  String get editProfileHandle => 'Seu @handle';

  @override
  String get editProfileHandleNote =>
      'Outros alunos te adicionam pelo seu @handle (2–20 letras, números ou _). Para reservá-lo, você precisa estar conectado.';

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
  String get commonSave => 'Salvar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get feedIsNowYourFriend => 'agora é seu amigo';

  @override
  String feedReachedLevel(String level) {
    return 'alcançou $level';
  }

  @override
  String feedDayStreak(int count) {
    return 'ofensiva de $count dias';
  }

  @override
  String get feedPassedYou => 'passou você na sua liga';

  @override
  String get leaguesSoloCaption => 'esta semana · grupo individual';

  @override
  String leaguesXpToRank(int xp, int rank) {
    return '$xp XP para o $rankº lugar';
  }

  @override
  String get leaguesLeading => 'liderando seu grupo';

  @override
  String get leaguesSoloNote =>
      'Você é o único aluno no seu grupo esta semana. Rivais reais entram conforme o Ratel cresce — sem bots, sem rankings falsos. Continue ganhando XP para estar pronto a subir quando a semana reiniciar.';

  @override
  String questsGoalLine(int today, int goal) {
    return '$today / $goal XP · meta atingida';
  }

  @override
  String questsGoalRemaining(int today, int goal, int remaining) {
    return '$today / $goal XP · faltam $remaining XP';
  }

  @override
  String get worldLabelLight => 'Dia claro';

  @override
  String get worldVehicleLight => 'Patinete';

  @override
  String get worldLabelGalaxy => 'Espaço';

  @override
  String get worldVehicleGalaxy => 'Cápsula estelar';

  @override
  String get worldLabelSavanna => 'Savana';

  @override
  String get worldVehicleSavanna => 'Jipe de safári';

  @override
  String get worldLabelOcean => 'Oceano';

  @override
  String get worldVehicleOcean => 'Submarino';

  @override
  String get worldLabelForest => 'Floresta';

  @override
  String get worldVehicleForest => 'Planador de folha';

  @override
  String get worldLabelCandy => 'Doces';

  @override
  String get worldVehicleCandy => 'Balão';

  @override
  String get worldLabelNeon => 'Cidade Neon';

  @override
  String get worldVehicleNeon => 'Moto voadora';

  @override
  String get worldLabelStorm => 'Tempestade';

  @override
  String get worldVehicleStorm => 'Planador da tempestade';

  @override
  String get worldLabelSnow => 'Inverno';

  @override
  String get worldVehicleSnow => 'Trenó de neve';

  @override
  String get worldLabelSakura => 'Flor de Cerejeira';

  @override
  String get worldVehicleSakura => 'Pipa de pétalas';

  @override
  String get worldLabelAutumn => 'Outono';

  @override
  String get worldVehicleAutumn => 'Carrinho de folhas';

  @override
  String get worldLabelAurora => 'Aurora';

  @override
  String get worldVehicleAurora => 'Barco da aurora';

  @override
  String get worldLabelVolcano => 'Vulcão';

  @override
  String get worldVehicleVolcano => 'Prancha de magma';

  @override
  String get worldLabelSunset => 'Pôr do sol';

  @override
  String get worldVehicleSunset => 'Planador';

  @override
  String get worldLabelDesert => 'Deserto';

  @override
  String get worldVehicleDesert => 'Buggy das dunas';

  @override
  String get worldLabelReef => 'Recife de Coral';

  @override
  String get worldVehicleReef => 'Barco de vidro';

  @override
  String get worldLabelMeadow => 'Campina';

  @override
  String get worldVehicleMeadow => 'Bicicleta';

  @override
  String get worldLabelDawn => 'Amanhecer';

  @override
  String get worldVehicleDawn => 'Balão do céu';

  @override
  String get worldLabelBeach => 'Praia Tropical';

  @override
  String get worldVehicleBeach => 'Catamarã';

  @override
  String get worldLabelMars => 'Marte';

  @override
  String get worldVehicleMars => 'Rover';

  @override
  String get worldLabelJungle => 'Floresta Tropical';

  @override
  String get worldVehicleJungle => 'Tirolesa';

  @override
  String get worldLabelCyberrain => 'Chuva Cibernética';

  @override
  String get worldVehicleCyberrain => 'Moto voadora';

  @override
  String get worldLabelAbyss => 'Mar Profundo';

  @override
  String get worldVehicleAbyss => 'Batisfera';

  @override
  String get worldLabelAlpine => 'Alpes';

  @override
  String get worldVehicleAlpine => 'Teleférico';

  @override
  String get worldLabelLavender => 'Lavanda';

  @override
  String get worldVehicleLavender => 'Vespa';

  @override
  String get worldLabelBamboo => 'Bambuzal';

  @override
  String get worldVehicleBamboo => 'Riquixá';

  @override
  String get worldLabelLagoon => 'Lagoa à Noite';

  @override
  String get worldVehicleLagoon => 'Caiaque';

  @override
  String get worldLabelThunder => 'Trovoada';

  @override
  String get worldVehicleThunder => 'Caçador de tempestades';

  @override
  String get worldLabelNebula => 'Nebulosa';

  @override
  String get worldVehicleNebula => 'Cruzador estelar';

  @override
  String get worldLabelSandstorm => 'Tempestade de Areia';

  @override
  String get worldVehicleSandstorm => 'Caravana';

  @override
  String get worldLabelCherrynight => 'Noite de Cerejeira';

  @override
  String get worldVehicleCherrynight => 'Lanterna de papel';

  @override
  String get shopYourBadger => 'Seu texugo';

  @override
  String get shopDiamondsNote =>
      'Uma recarga de 💎 com dinheiro real está chegando. Os diamantes são ganhos concluindo lições e batendo sua meta diária, e cada potencializador aqui os gasta de verdade — nada é falso.';

  @override
  String get shopProBannerSub =>
      'IA ao vivo, sem anúncios, offline · Teste 7 dias grátis';

  @override
  String get shopYourDiamonds => 'Seus diamantes';

  @override
  String get shopEquipped => 'Equipado';

  @override
  String get shopEquip => 'Equipar';

  @override
  String shopEquippedSnack(String name, String emoji) {
    return '$name $emoji equipado';
  }

  @override
  String get shopFree => 'Grátis';

  @override
  String get outfitClassic => 'Clássico';

  @override
  String get outfitScholar => 'Erudito';

  @override
  String get outfitExplorer => 'Explorador';

  @override
  String get outfitAstronaut => 'Astronauta';

  @override
  String get outfitWizard => 'Mago';

  @override
  String paywallAnnualLine(String annual, String perMonth) {
    return '$annual/ano  ·  $perMonth/mês  ·  7 dias grátis';
  }

  @override
  String paywallMonthlyLine(String monthly) {
    return '$monthly/mês  ·  cobrança mensal';
  }

  @override
  String paywallSavePercent(int percent) {
    return 'ECONOMIZE $percent%';
  }

  @override
  String get paywallIncluded => 'O que está incluído no Pro';

  @override
  String get paywallTerms => 'Termos';

  @override
  String get paywallPrivacy => 'Privacidade';

  @override
  String get paywallNothingToRestore =>
      'Nada a restaurar — a cobrança ainda não está ativa nesta versão.';

  @override
  String get contentUnavailableTitle => 'Conteúdo indisponível';

  @override
  String contentUnavailableBody(String noun) {
    return 'Este(a) $noun não está disponível agora. Se você estiver offline, verifique sua conexão e tente de novo.';
  }

  @override
  String get contentNounStory => 'história';

  @override
  String get contentNounPodcast => 'podcast';

  @override
  String get contentNounVideo => 'vídeo';

  @override
  String get contentNounAdventure => 'aventura';

  @override
  String get contentNounRoleplay => 'roleplay';

  @override
  String get commonGoBack => 'Voltar';

  @override
  String get placementTitle => 'Teste de nivelamento';

  @override
  String placementQuestionN(int n) {
    return 'Pergunta $n';
  }

  @override
  String get placementResultTitle => 'Seu ponto de partida';

  @override
  String placementResultBody(int count, String level) {
    return 'Com base em $count perguntas, colocamos você no nível $level. Você sempre pode ajustar depois.';
  }

  @override
  String get lessonTypedNote => 'Digite sua resposta no idioma-alvo.';

  @override
  String lessonHintMinWords(int count) {
    return 'pelo menos $count palavras';
  }

  @override
  String lessonHintUseWords(String words) {
    return 'use: $words';
  }

  @override
  String get lessonHintEndPunct => 'termine com . ! ou ?';

  @override
  String get lessonPlayAudio => 'Reproduzir áudio';

  @override
  String get lessonPlaySlowly => 'Reproduzir devagar';

  @override
  String get lessonAudioUnavailable => 'Áudio indisponível — leia o enunciado.';

  @override
  String get lessonPlaybackSpeed => 'Velocidade de reprodução';

  @override
  String get authAccountsUnavailable =>
      'As contas ainda não estão disponíveis nesta versão — continue aprendendo como convidado.';

  @override
  String get liveNotEnabledShort =>
      'a IA ao vivo não está habilitada nesta versão.';

  @override
  String get liveMicUnavailable =>
      'microfone indisponível — permita o acesso ao microfone para falar com o tutor.';

  @override
  String get liveUnavailable => 'a IA ao vivo está indisponível no momento.';

  @override
  String get liveNeedsPro => 'A IA ao vivo faz parte do RATEL PRO.';

  @override
  String get liveMinutesUsed => 'Você usou seus minutos ao vivo deste mês.';

  @override
  String get commonNetworkError =>
      'Não foi possível conectar ao servidor. Tente de novo.';

  @override
  String get friendsHandleTaken => 'Esse @handle já está em uso.';

  @override
  String get friendsHandleFormat =>
      'Use 2–20 letras, números ou _ para o seu @handle.';

  @override
  String get friendsSignInForHandle => 'Entre para reservar seu @handle.';

  @override
  String get friendsSetOwnHandleFirst =>
      'Defina primeiro o seu @handle (Editar perfil).';

  @override
  String get paywallCheckoutUnavailable =>
      'O checkout abre no lançamento — a cobrança da loja ainda não está ativa nesta versão.';

  @override
  String get settingsManageUnavailable =>
      'Gerencie ou cancele nas configurações de Assinaturas do seu dispositivo — o atalho no app abre no lançamento.';

  @override
  String get friendsAdd => 'Adicionar';

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
}
