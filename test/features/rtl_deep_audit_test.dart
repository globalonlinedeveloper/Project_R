import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/adventures/adventures_screen.dart';
import 'package:ratel/features/auth/welcome_screen.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/library/library_search_screen.dart';
import 'package:ratel/features/notifications/notifications_screen.dart';
import 'package:ratel/features/paywall/paywall_screen.dart';
import 'package:ratel/features/practice/practice_hub_screen.dart';
import 'package:ratel/features/progress/progress_screen.dart';
import 'package:ratel/features/settings/settings_screen.dart';
import 'package:ratel/features/shop/shop_screen.dart';
import 'package:ratel/features/themes/themes_screen.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';
import 'package:ratel/services/preferences/ui_locale_store.dart';

/// L-2 RTL deep-audit (S130b) — every localized push-surface plus the full
/// 5-tab shell renders under Arabic with RTL directionality and ZERO overflow
/// at phone widths (any overflow throws and reds the run). Honest scope note:
/// this gauntlet catches layout breakage and direction; visual MIRRORING
/// polish (physical vs directional paddings) needs owner-eyes screenshots.
const CourseSpine _spine = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(
      section: 'SECTION 1 · LEVEL A1',
      title: 'Level A1',
      lessons: <CourseLesson>[
        CourseLesson(
            id: 'l_greet',
            title: 'Saludos',
            cefr: 'A1',
            exercises: <CourseExercise>[
              CourseExercise(
                  id: 'i1',
                  exerciseType: 'mcq',
                  prompt: 'Say hello',
                  accepted: <String>['hola']),
            ]),
      ]),
]);

Future<void> _pumpAr(WidgetTester tester, Widget home, double width) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spine),
      settingsStoreProvider.overrideWithValue(
          InMemorySettingsStore(const AppSettings(reduceMotion: true))),
    ],
    child: MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  ));
  await tester.pumpAndSettle();
  expect(
    Directionality.of(tester.element(find.byType(Scaffold).first)),
    TextDirection.rtl,
    reason: 'ar must lay out RTL at ${width.toInt()}px',
  );
}

void main() {
  final AppLocalizations ar = lookupAppLocalizations(const Locale('ar'));

  // (screen builder, a string that must render — proves the delegates fed the
  // surface real Arabic, not the English fallback).
  final Map<String, (Widget, String)> surfaces = <String, (Widget, String)>{
    'settings': (const SettingsScreen(), ar.settingsTitle),
    'practice': (const PracticeHubScreen(), ar.practiceTitle),
    'progress': (const ProgressScreen(), ar.progressTitle),
    'notifications': (const NotificationsScreen(), ar.notifEmptyTitle),
    'shop': (const ShopScreen(), ar.shopPowerUps),
    'paywall': (const PaywallScreen(), ar.paywallTitle),
    'themes': (const ThemesScreen(), ar.themesTitle),
    'adventures': (const AdventuresScreen(), ar.adventuresTitle),
    'welcome': (const WelcomeScreen(), ar.authWelcomeTitle),
    'search': (const LibrarySearchScreen(), ar.searchTitle),
  };

  for (final MapEntry<String, (Widget, String)> e in surfaces.entries) {
    for (final double width in <double>[360, 430]) {
      testWidgets('RTL deep-audit: ${e.key} @$width renders ar, no overflow',
          (WidgetTester tester) async {
        await _pumpAr(tester, e.value.$1, width);
        expect(find.textContaining(e.value.$2, findRichText: true),
            findsWidgets);
      });
    }
  }

  testWidgets('RTL deep-audit: full 5-tab shell sweep @360 stays RTL',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_spine),
        settingsStoreProvider.overrideWithValue(
            InMemorySettingsStore(const AppSettings(reduceMotion: true))),
        uiLocaleStoreProvider.overrideWithValue(InMemoryUiLocaleStore('ar')),
      ],
      child: const RatelApp(),
    ));
    await tester.pumpAndSettle();
    for (final String tab in <String>[
      ar.navLibrary,
      ar.navLeagues,
      ar.navQuests,
      ar.navProfile,
      ar.navHome,
    ]) {
      await tester.tap(find.text(tab).first);
      await tester.pumpAndSettle();
      expect(
        Directionality.of(tester.element(find.byType(Scaffold).first)),
        TextDirection.rtl,
        reason: 'tab $tab must stay RTL',
      );
    }
  });
}
