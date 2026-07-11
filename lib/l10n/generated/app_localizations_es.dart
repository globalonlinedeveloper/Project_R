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
}
