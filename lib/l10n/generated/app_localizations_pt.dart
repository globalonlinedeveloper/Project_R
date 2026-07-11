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
      'Todo o resto — os 52 idiomas, áudio, revisão, ligas, roleplay e pronúncia no dispositivo — continua grátis para todos.';

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
  String get notifBodyLevel4 => 'Avançado (C1) — seu espanhol está forte.';

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
}
