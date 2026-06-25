import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/energy/energy_controller.dart';
import 'package:ratel/features/energy/energy_state.dart';
import 'package:ratel/features/home/home_screen.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// Course-progress bar + section map (spec §7).
Widget _app({EnergyState? energy}) {
  return ProviderScope(
    overrides: [
      settingsStoreProvider.overrideWithValue(
          InMemorySettingsStore(const AppSettings(world: WorldThemeId.space))),
      if (energy != null)
        energyControllerProvider.overrideWith((ref) => EnergyController(energy)),
    ],
    child: MaterialApp(theme: RatelTheme.space(), home: const HomeScreen()),
  );
}

void main() {
  testWidgets('course bar shows the active section and live percent',
      (tester) async {
    await tester.pumpWidget(_app()); // new user -> active section 0, 0%
    await tester.pump();
    expect(find.byKey(const Key('course-bar')), findsOneWidget);
    expect(find.textContaining('SECTION 1 / 3'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
  });

  testWidgets('tapping the course bar opens the section map', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump();
    await tester.tap(find.byKey(const Key('course-bar')));
    await tester.pumpAndSettle();
    expect(find.text('Course map'), findsOneWidget);
    expect(find.text('3 sections · tap to jump.'), findsOneWidget);
  });

  testWidgets('a section row jumps and closes the sheet without throwing',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump();
    await tester.tap(find.byKey(const Key('course-bar')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Section 3 · AURORA EXPANSE')); // map row (title-case)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    expect(find.text('Course map'), findsNothing); // sheet closed
  });

  testWidgets('new user: section 0 In progress, later sections Locked',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump();
    await tester.tap(find.byKey(const Key('course-bar')));
    await tester.pumpAndSettle();
    expect(find.textContaining('In progress'), findsOneWidget);
    expect(find.textContaining('Locked'), findsWidgets);
  });

  testWidgets('finished progress shows Done sections', (tester) async {
    await tester
        .pumpWidget(_app(energy: const EnergyState(lessonsCompleted: 999)));
    await tester.pump();
    await tester.tap(find.byKey(const Key('course-bar')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Done'), findsWidgets);
  });
}
