// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navHome => 'Inicio';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navLeagues => 'Ligas';

  @override
  String get navQuests => 'Misiones';

  @override
  String get navProfile => 'Perfil';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionLearning => 'Aprendizaje';

  @override
  String get settingsSectionSubscription => 'Suscripción';

  @override
  String get settingsSectionAccessibility => 'Accesibilidad';

  @override
  String get settingsSectionNotifications => 'Notificaciones';

  @override
  String get settingsSectionAppearanceAccount => 'Apariencia y cuenta';

  @override
  String get settingsAppLanguage => 'Idioma de la aplicación';

  @override
  String get settingsAppLanguageSystem => 'Predeterminado del sistema';

  @override
  String get homeCourseLoadingTitle => 'Tu curso se está preparando';

  @override
  String get homeCourseLoadingBody =>
      'Las lecciones aparecerán aquí cuando se cargue el contenido del curso.';

  @override
  String get homeGuideChip => 'Guía';

  @override
  String get homeStartNode => 'EMPEZAR';

  @override
  String get homeUnitGuideHeader => 'GUÍA DE LA UNIDAD';

  @override
  String get commonDone => 'Listo';

  @override
  String homeUnitKicker(String unit) {
    return 'UNIDAD · $unit';
  }

  @override
  String homeLessonMeta(int num, int count, String exercises) {
    return 'Lección $num de $count · $exercises.';
  }

  @override
  String homeQuickExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ejercicios rápidos',
      one: '$count ejercicio rápido',
    );
    return '$_temp0';
  }

  @override
  String get homeEnergyChip => '−1 ⚡ energía';

  @override
  String get homeXpChip => '+20 XP';

  @override
  String get homeStartLesson => 'Empezar lección';

  @override
  String get homeTutorChip => 'Tutor';

  @override
  String get libraryAiTutor => 'Tutor de IA';

  @override
  String get libraryAiTutorSub =>
      'Habla, chatea y actúa — corrección de escritura';

  @override
  String get libraryRoleplay => 'Juego de rol';

  @override
  String get libraryRoleplaySub =>
      'Practica respuestas — calificado, siempre gratis';

  @override
  String get librarySectionPractice => 'Práctica';

  @override
  String get libraryPracticeHub => 'Centro de práctica';

  @override
  String get libraryPracticeHubSub =>
      'Errores, palabras débiles y ejercicios · GRATIS';

  @override
  String get librarySectionReadListen => 'Leer y escuchar';

  @override
  String get libraryGradedStories => 'Historias graduadas';

  @override
  String get libraryPodcasts => 'Pódcasts';

  @override
  String get libraryWatch => 'Ver';

  @override
  String get librarySearchHint => 'Busca lecciones, palabras, historias…';

  @override
  String get libraryFeaturedStory => 'DESTACADO · HISTORIA';

  @override
  String commonLevel(String cefr) {
    return 'Nivel $cefr';
  }

  @override
  String get libraryReadNow => 'Leer ahora';

  @override
  String get libraryNewExplore => 'NUEVO · EXPLORA';

  @override
  String get libraryAdventures => 'Aventuras';

  @override
  String get libraryStartExploring => 'Empieza a explorar →';

  @override
  String get libraryKindStory => 'Historia';

  @override
  String get libraryKindPodcast => 'Pódcast';

  @override
  String get libraryKindVideo => 'Vídeo';

  @override
  String get libraryAllStories => 'Todas las historias';

  @override
  String get libraryAllPodcasts => 'Todos los pódcasts';

  @override
  String get libraryAllVideos => 'Todos los vídeos';

  @override
  String get lessonTypeWhatYouHear => 'Escribe lo que oyes';

  @override
  String get lessonTapWhatYouHear => 'Toca lo que oyes';

  @override
  String get lessonTranslateSentence => 'Traduce esta frase';

  @override
  String get lessonTypeAnswerHint => 'Escribe tu respuesta…';

  @override
  String get lessonWriteAnswerHint => 'Redacta tu respuesta…';

  @override
  String get lessonContinue => 'Continuar';

  @override
  String get lessonSkip => 'Saltar';

  @override
  String get lessonCheck => 'Comprobar';

  @override
  String get lessonNicelyDone => '✓ ¡Bien hecho!';

  @override
  String get lessonNotQuite => '✕ No exactamente';

  @override
  String lessonAnswerReveal(String answer) {
    return 'Respuesta: $answer';
  }

  @override
  String get lessonCompleteKicker => 'LECCIÓN COMPLETADA';

  @override
  String get lessonCompleteTitle => '¡Lección completada!';

  @override
  String lessonCompleteSummary(int correct, int graded, String level) {
    return '$correct de $graded correctas · ahora $level';
  }

  @override
  String get lessonStatTotalXp => 'XP TOTAL';

  @override
  String get lessonStatAccuracy => 'PRECISIÓN';

  @override
  String get lessonStatTime => 'TIEMPO';

  @override
  String get onboardingWelcomeTitle => '¡Hola, soy Ratel!';

  @override
  String get onboardingWelcomeBody =>
      'Aprende un idioma sin miedo: en dosis pequeñas, divertido y gratis. ¿Listo para empezar?';

  @override
  String get onboardingHaveAccount => 'Ya tengo una cuenta';

  @override
  String get onboardingTryWithoutAccount => 'Probar sin cuenta →';

  @override
  String get onboardingGetStarted => 'Empezar';

  @override
  String get onboardingStartLearning => 'Empezar a aprender';

  @override
  String get onboardingLanguageTitle => '¿Qué quieres aprender?';

  @override
  String get onboardingLanguageSubtitle => '52 idiomas disponibles';

  @override
  String get onboardingReasonTitle => '¿Por qué estás aprendiendo?';

  @override
  String get onboardingGoalTitle => 'Elige una meta diaria';

  @override
  String get onboardingPlacementTitle => 'Encuentra tu punto de partida';

  @override
  String onboardingPlacementBody(String language) {
    return '¿Nuevo en $language o ya sabes algo?';
  }

  @override
  String get onboardingBrandNew => 'Soy principiante';

  @override
  String get onboardingBrandNewSub => 'Empieza desde el principio';

  @override
  String get onboardingPlacementTest => 'Hacer una prueba de nivel';

  @override
  String get onboardingPlacementTestSub => '~3 min · salta a tu nivel';

  @override
  String onboardingXpPerDay(int xp) {
    return '$xp XP / día';
  }

  @override
  String get reasonTravel => 'Viajes';

  @override
  String get reasonCulture => 'Cultura';

  @override
  String get reasonCareer => 'Carrera';

  @override
  String get reasonFamilyFriends => 'Familia y amigos';

  @override
  String get reasonBrainTraining => 'Entrenar la mente';

  @override
  String get reasonJustForFun => 'Por diversión';

  @override
  String get goalCasual => 'Relajado';

  @override
  String get goalRegular => 'Regular';

  @override
  String get goalSerious => 'Serio';

  @override
  String get goalIntense => 'Intenso';

  @override
  String get langNameSpanish => 'Español';

  @override
  String get langNameFrench => 'Francés';

  @override
  String get langNameJapanese => 'Japonés';

  @override
  String get langNameTamil => 'Tamil';

  @override
  String get langNameGerman => 'Alemán';

  @override
  String get langNameKorean => 'Coreano';

  @override
  String get settingsDailyGoal => 'Meta diaria';

  @override
  String settingsGoalRow(String label, int xp) {
    return '$label · $xp XP/día';
  }

  @override
  String get profileAchievements => 'Logros';

  @override
  String get profileFriends => 'Amigos';

  @override
  String get profileShop => 'Tienda';

  @override
  String get profileNotifications => 'Notificaciones';

  @override
  String get profileSeeOnboarding => 'Ver el flujo de bienvenida ↗';

  @override
  String get profileNotSignedIn => 'Sin sesión iniciada';

  @override
  String get profileCreateAccount => 'Crea una cuenta gratis';

  @override
  String get profileSaveProgress =>
      'Guarda tu progreso en todos tus dispositivos';

  @override
  String profileTodaysGoal(int today, int goal) {
    return 'Meta de hoy · $today/$goal XP';
  }

  @override
  String get profileViewProgress => 'Ver progreso →';

  @override
  String get profileUnlocked => 'Desbloqueado';

  @override
  String questsResetsIn(int h, int m) {
    return 'Se reinicia en ${h}h ${m}m';
  }

  @override
  String get questsDailyRefresh => 'Refresco diario';

  @override
  String get questsFreshMix => 'Una mezcla fresca de 5 preguntas';

  @override
  String get questsServedFromQueue =>
      'Servido desde tu cola real de repaso — gana XP real.';

  @override
  String get questsGoalReached => '¡Meta diaria alcanzada! 🎉';

  @override
  String questsReachGoal(int goal) {
    return 'Consigue $goal XP hoy';
  }

  @override
  String questsDailyQuests(int done, int total) {
    return 'Misiones diarias · $done/$total';
  }

  @override
  String get questsInfoNote =>
      'Las misiones siguen tu progreso diario real. Los cofres de recompensa, las misiones con amigos y la clasificación semanal necesitan una economía de backend — decisión del propietario (§6). No se muestran recompensas falsas.';

  @override
  String get questsStartRefresh => 'Empezar el refresco diario';

  @override
  String get questsStart => 'Empezar';

  @override
  String get questsPractisedToday => 'Practicado hoy — racha a salvo';

  @override
  String get questsEarnAnyXp => 'Gana XP hoy';

  @override
  String questsXpToday(int current, int target) {
    return '$current/$target XP hoy';
  }

  @override
  String get leaguesYourGroup => 'TU GRUPO';

  @override
  String leaguesThisWeek(int size) {
    return 'ESTA SEMANA · $size ESTUDIANTES';
  }

  @override
  String get leaguesTiers => 'Divisiones de la liga';

  @override
  String leaguesTopClimb(int top, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '$days día',
    );
    return 'Los $top primeros suben cada semana · termina en $_temp0';
  }

  @override
  String get leaguesDemotionZone => 'Zona de descenso';

  @override
  String get leaguesPromotionZone => 'Zona de ascenso';

  @override
  String get leaguesSafeZone => 'Zona segura';

  @override
  String get leaguesYou => 'Tú';

  @override
  String leaguesPromoteRelegate(int top, int bottom) {
    return 'Los $top primeros ascienden · los últimos $bottom descienden al acabar la semana.';
  }

  @override
  String get leaguesYouAreHere => 'Estás aquí';

  @override
  String get leaguesViewAllTiers => '🏆 Ver las 10 divisiones ›';

  @override
  String get notifMarkAllRead => 'Marcar todo como leído';

  @override
  String get notifEmptyTitle => 'Aún no hay notificaciones';

  @override
  String get notifEmptyBody =>
      'Termina lecciones, construye una racha y sube de nivel — tus hitos aparecerán aquí en cuanto los consigas de verdad.';

  @override
  String get notifPushNote =>
      'Son hitos dentro de la app, mostrados en el momento en que los logras. Las notificaciones push y los recordatorios son una decisión del propietario y aún no están activados — nada aquí es falso.';

  @override
  String get shopPowerUps => 'Potenciadores';

  @override
  String get shopStreakFreeze => 'Protector de racha';

  @override
  String get shopStreakFreezeDesc =>
      'Protege tu racha un día que faltes. Se gasta automáticamente cuando no cumples tu meta diaria.';

  @override
  String shopOwned(int have, int max) {
    return 'En posesión: $have/$max';
  }

  @override
  String get shopMaxedOut => 'Al máximo';

  @override
  String shopBuyFor(int cost) {
    return 'Comprar por $cost 💎';
  }

  @override
  String get shopFreezeAdded => 'Protector de racha añadido 💪';

  @override
  String shopFreezeAtCap(int max) {
    return 'Ya tienes el máximo de protectores ($max).';
  }

  @override
  String shopNotEnoughEarnCost(int cost) {
    return 'No hay suficientes 💎 — consigue $cost terminando lecciones.';
  }

  @override
  String get shopNotEnoughEarnMore =>
      'No hay suficientes 💎 — consigue más terminando lecciones.';

  @override
  String get shopEnergyRefill => 'Recarga de energía';

  @override
  String get shopEnergyRefillDesc =>
      'Recarga tu energía al máximo. La energía es solo visual — las lecciones nunca se bloquean.';

  @override
  String get shopAlreadyFull => 'Ya está llena';

  @override
  String get shopEnergyRefilled => 'Energía recargada ⚡';

  @override
  String get shopEnergyAlreadyFull => 'Tu energía ya está llena.';

  @override
  String get shopStreakRepair => 'Reparar racha';

  @override
  String get shopStreakRepairDesc =>
      '¿Perdiste tu racha? Restáurala a su longitud anterior y sigue adelante.';

  @override
  String get shopStreakLapsed => 'Racha perdida';

  @override
  String shopStreakDays(int days) {
    return '🔥 Racha de $days días';
  }

  @override
  String shopRepairFor(int cost) {
    return 'Reparar por $cost 💎';
  }

  @override
  String get shopStreakRestored => 'Racha restaurada 🔥';

  @override
  String get shopStreakSafe =>
      'Tu racha está a salvo — nada que reparar ahora.';

  @override
  String get shopDoubleXp => 'XP doble';

  @override
  String get shopDoubleXpDesc =>
      'Gana 2× XP en cada lección durante 15 minutos.';

  @override
  String shopActiveLeft(int minutes) {
    return 'Activo · quedan ${minutes}m';
  }

  @override
  String get shopInactive => 'Inactivo';

  @override
  String get shopActive => 'Activo';

  @override
  String get shopDoubleXpActive => 'XP doble activado ✨';

  @override
  String get shopBoostRunning =>
      'Tu potenciador está en marcha — el XP se duplica.';

  @override
  String get shopBadgerOutfits => 'Atuendos del tejón';

  @override
  String get paywallTitle => 'RATEL PRO';

  @override
  String get paywallStartTrial => 'Prueba gratis de 7 días';

  @override
  String paywallGoPro(String price) {
    return 'Hazte Pro — $price/mes';
  }

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallHero =>
      'Tutoría con IA en vivo, sin anuncios y lecciones sin conexión.';

  @override
  String get paywallAnnual => 'Anual';

  @override
  String get paywallMonthly => 'Mensual';

  @override
  String get paywallTrialHow => 'Cómo funciona la prueba gratis de 7 días';

  @override
  String get paywallTrialToday => 'Hoy';

  @override
  String get paywallTrialTodayDesc =>
      'Se desbloquea todo el acceso Pro. Sin cargo.';

  @override
  String get paywallTrialDay5 => 'Día 5';

  @override
  String get paywallTrialDay5Desc =>
      'Te avisamos antes de que termine la prueba.';

  @override
  String get paywallTrialDay7 => 'Día 7';

  @override
  String paywallTrialDay7Desc(String price) {
    return 'Comienza $price/año salvo que canceles.';
  }

  @override
  String get paywallFeatureLiveAi =>
      'IA en vivo: voz, chat con tutor y corrección de escritura';

  @override
  String get paywallFeatureNoAds => 'Sin anuncios, en ningún sitio';

  @override
  String get paywallFeatureOffline => 'Lecciones y audio sin conexión';

  @override
  String get paywallFeaturePronunciation => 'Consejos de pronunciación con IA';

  @override
  String get paywallEverythingFree =>
      'Todo lo demás — los 52 idiomas, audio, repaso, ligas, roleplay y pronunciación en el dispositivo — sigue gratis para todos.';

  @override
  String get paywallYouArePro => 'Tienes RATEL PRO';

  @override
  String get paywallThanks =>
      'Gracias por apoyar a Ratel. Gestiona o cancela cuando quieras desde Ajustes → Gestionar suscripción.';

  @override
  String get paywallManage => 'Gestionar suscripción';

  @override
  String paywallFinePrint(String regions) {
    return 'Cancela cuando quieras en Ajustes. Precios mostrados para $regions; tu precio local lo fija tu tienda de aplicaciones.';
  }

  @override
  String get questTitlePowerSession => 'Sesión intensa';

  @override
  String get questDescPowerSession => 'Gana el doble de tu meta diaria';

  @override
  String get questTitleOnFire => 'En llamas';

  @override
  String get questDescOnFire => 'Gana el triple de tu meta diaria';

  @override
  String get questTitleStreakKeeper => 'Guardián de la racha';

  @override
  String get questDescStreakKeeper => 'Practica hoy para mantener tu racha';

  @override
  String get notifTitleLessons1 => 'Primera lección completada';

  @override
  String get notifBodyLessons1 =>
      'Terminaste tu primera lección — ¡gran comienzo!';

  @override
  String get notifTitleLessons5 => '5 lecciones hechas';

  @override
  String get notifBodyLessons5 =>
      'Has completado 5 lecciones. Mantén el impulso.';

  @override
  String get notifTitleLessons10 => '10 lecciones hechas';

  @override
  String get notifBodyLessons10 =>
      'Diez lecciones — estás creando un hábito real.';

  @override
  String get notifTitleLessons25 => '25 lecciones hechas';

  @override
  String get notifBodyLessons25 =>
      'Veinticinco lecciones completadas. ¡Dedicación admirable!';

  @override
  String get notifTitleLessons50 => '50 lecciones hechas';

  @override
  String get notifBodyLessons50 =>
      'Cincuenta lecciones — vas por muy buen camino.';

  @override
  String get notifTitleStreak3 => '¡Racha de 3 días!';

  @override
  String get notifBodyStreak3 =>
      'Tres días seguidos. La constancia lo es todo.';

  @override
  String get notifTitleStreak7 => '¡Racha de 7 días!';

  @override
  String get notifBodyStreak7 =>
      'Una semana entera de práctica diaria. ¡Extraordinario!';

  @override
  String get notifTitleStreak14 => '¡Racha de 14 días!';

  @override
  String get notifBodyStreak14 => 'Dos semanas seguidas — eres imparable.';

  @override
  String get notifTitleStreak30 => '¡Racha de 30 días!';

  @override
  String get notifBodyStreak30 =>
      'Un mes entero de práctica diaria. Increíble.';

  @override
  String get notifTitleXp100 => '100 XP ganados';

  @override
  String get notifBodyXp100 => 'Tus primeros cien XP — el impulso crece.';

  @override
  String get notifTitleXp500 => '500 XP ganados';

  @override
  String get notifBodyXp500 => 'Quinientos XP. Estás poniendo el esfuerzo.';

  @override
  String get notifTitleXp1000 => '1.000 XP ganados';

  @override
  String get notifBodyXp1000 => '¡Hito de mil XP alcanzado!';

  @override
  String get notifTitleXp2500 => '2.500 XP ganados';

  @override
  String get notifBodyXp2500 => 'Dos mil quinientos XP — progreso serio.';

  @override
  String get notifTitleLevel1 => 'Nivel A2 alcanzado';

  @override
  String get notifBodyLevel1 => 'Tu nivel subió de A1 a A2. ¡Adelante!';

  @override
  String get notifTitleLevel2 => 'Nivel B1 alcanzado';

  @override
  String get notifBodyLevel2 => 'Ya eres un estudiante intermedio (B1).';

  @override
  String get notifTitleLevel3 => 'Nivel B2 alcanzado';

  @override
  String get notifBodyLevel3 => 'Intermedio alto (B2) alcanzado. Brillante.';

  @override
  String get notifTitleLevel4 => 'Nivel C1 alcanzado';

  @override
  String get notifBodyLevel4 => 'Avanzado (C1) — tu español es sólido.';

  @override
  String get notifTitleLevel5 => 'Nivel C2 alcanzado';

  @override
  String get notifBodyLevel5 => 'Maestría (C2) — ¡la cima de la escala!';

  @override
  String get achTitleFirstSteps => 'Primeros pasos';

  @override
  String get achTitleScholar => 'Erudito';

  @override
  String get achTitleWildfire => 'Llamarada';

  @override
  String get achTitlePointMaker => 'Anotador';

  @override
  String get achTitleCollector => 'Coleccionista';

  @override
  String get achTitleRisingStar => 'Estrella emergente';

  @override
  String get leagueTierBronze => 'Bronce';

  @override
  String get leagueTierSilver => 'Plata';

  @override
  String get leagueTierGold => 'Oro';

  @override
  String get leagueTierSapphire => 'Zafiro';

  @override
  String get leagueTierRuby => 'Rubí';

  @override
  String get leagueTierEmerald => 'Esmeralda';

  @override
  String get leagueTierAmethyst => 'Amatista';

  @override
  String get leagueTierPearl => 'Perla';

  @override
  String get leagueTierObsidian => 'Obsidiana';

  @override
  String get leagueTierDiamond => 'Diamante';

  @override
  String get cefrNameBeginner => 'Principiante';

  @override
  String get cefrNameElementary => 'Elemental';

  @override
  String get cefrNameIntermediate => 'Intermedio';

  @override
  String get cefrNameUpperIntermediate => 'Intermedio alto';

  @override
  String get cefrNameAdvanced => 'Avanzado';

  @override
  String get cefrNameProficient => 'Competente';

  @override
  String leaguesTierLeague(String tier) {
    return 'Liga de $tier';
  }

  @override
  String leaguesYoureIn(String tier) {
    return 'Estás en $tier · los 7 primeros suben cada semana';
  }

  @override
  String get leaguesZonePromotion => '⬆ ZONA DE ASCENSO';

  @override
  String get leaguesZoneDemotion => '⬇ ZONA DE DESCENSO';

  @override
  String profileAchievementsSummary(int unlocked, int total) {
    return '$unlocked de $total desbloqueados · progreso real';
  }

  @override
  String get profileRealStateNote =>
      'Nivel, XP, lecciones, racha y palabras guardadas son estado real del motor — empiezan en cero en una cuenta nueva.';
}
