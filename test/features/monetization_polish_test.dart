// R-J1 (pre-tap PRO badge on the Home Tutor pill) + R-J6 (manage-subscription seam).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/settings/settings_screen.dart';
import 'package:ratel/services/billing/billing.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

class _ProEntitlements implements Entitlements {
  const _ProEntitlements();
  @override
  bool get isPro => true;
}

const CourseSpine _spine = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(section: 'SECTION 1 · LEVEL A1', title: 'Level A1', lessons: <CourseLesson>[
    CourseLesson(id: 'l_greet', title: 'Saludos', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'i1', exerciseType: 'mcq', prompt: 'Say hello', accepted: <String>['hola']),
    ]),
  ]),
]);

Widget _homeApp({required bool pro}) => ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_spine),
        settingsStoreProvider.overrideWithValue(
            InMemorySettingsStore(const AppSettings(reduceMotion: true))),
        if (pro) entitlementsProvider.overrideWithValue(const _ProEntitlements()),
      ],
      child: const RatelApp(),
    );

void main() {
  test('R-J6 default manage-subscription seam is unavailable + honest (opens nothing)',
      () async {
    final ManageResult r = await const UnavailableManageSubscription().open();
    expect(r.status, ManageStatus.unavailable);
    expect(r.isAvailable, isFalse);
    expect(r.message, contains('Subscriptions'));
  });

  testWidgets('R-J1 Home Tutor pill shows the pre-tap PRO badge for free users',
      (WidgetTester tester) async {
    await tester.pumpWidget(_homeApp(pro: false));
    await tester.pumpAndSettle();
    expect(find.text('🦡 Tutor'), findsOneWidget);
    expect(find.text('PRO'), findsOneWidget);
  });

  testWidgets('R-J1 Pro users see NO PRO badge on the Tutor pill',
      (WidgetTester tester) async {
    await tester.pumpWidget(_homeApp(pro: true));
    await tester.pumpAndSettle();
    expect(find.text('🦡 Tutor'), findsOneWidget);
    expect(find.text('PRO'), findsNothing);
  });

  testWidgets('R-J6 Settings → Manage subscription (Pro) routes through the honest seam',
      (WidgetTester tester) async {
    // Settings is a long scrollable list — pump TALL so the bottom 'Account'
    // section builds before find/tap (§11 lazy-ListView).
    tester.view.physicalSize = const Size(450, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        entitlementsProvider.overrideWithValue(const _ProEntitlements()),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Manage subscription'), findsOneWidget);
    await tester.tap(find.text('Manage subscription'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Subscriptions'), findsWidgets);
  });
}
