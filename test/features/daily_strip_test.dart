import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/energy/energy_controller.dart';
import 'package:ratel/features/energy/energy_state.dart';
import 'package:ratel/features/home/home_screen.dart';
import 'package:ratel/features/practice/practice_controller.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// Daily strip (spec §8): goal-ring picker (persisted dailyGoal), the real
/// energy refill countdown, and the real due-reviews count.
Widget _app({
  InMemorySettingsStore? store,
  EnergyState? energy,
  List<ReviewCard>? due,
  bool reduceMotion = false,
}) {
  final child = ProviderScope(
    overrides: [
      settingsStoreProvider.overrideWithValue(store ??
          InMemorySettingsStore(const AppSettings(world: WorldThemeId.space))),
      if (energy != null)
        energyControllerProvider.overrideWith((ref) => EnergyController(energy)),
      if (due != null)
        practiceControllerProvider.overrideWith((ref) => PracticeController(due)),
    ],
    child: MaterialApp(theme: RatelTheme.space(), home: const HomeScreen()),
  );
  if (!reduceMotion) return child;
  return MediaQuery(
      data: const MediaQueryData(disableAnimations: true), child: child);
}

void main() {
  testWidgets('goal ring shows real session XP toward the persisted goal',
      (tester) async {
    await tester.pumpWidget(_app(energy: const EnergyState(xpToday: 10)));
    await tester.pump();
    expect(find.text('10/20'), findsOneWidget); // default goal = Regular(20)
  });

  testWidgets('goal picker sets and persists the daily goal', (tester) async {
    final store =
        InMemorySettingsStore(const AppSettings(world: WorldThemeId.space));
    await tester.pumpWidget(_app(store: store));
    await tester.pump();
    await tester.tap(find.byKey(const Key('goal-chip')));
    await tester.pumpAndSettle(); // full tank default -> no timer, settles
    expect(find.text('DAILY GOAL'), findsOneWidget);
    await tester.tap(find.text('Serious'));
    await tester.pump();
    expect(store.current.dailyGoal, 30); // persisted through the store
  });

  testWidgets('due chip reflects the real practice queue count', (tester) async {
    await tester.pumpWidget(_app(due: const [
      ReviewCard(id: 'a', front: 'uno'),
      ReviewCard(id: 'b', front: 'dos'),
    ]));
    await tester.pump();
    expect(find.text('2 due'), findsOneWidget);
  });

  testWidgets('due chip shows All clear with an empty queue', (tester) async {
    await tester.pumpWidget(_app(due: const <ReviewCard>[]));
    await tester.pump();
    expect(find.text('All clear'), findsOneWidget);
  });

  testWidgets('energy chip shows a live refill countdown (real regen model)',
      (tester) async {
    final state = EnergyState(
        energy: 2,
        dailyFreeUsed: true,
        refillAtMs: DateTime.now().millisecondsSinceEpoch + 90 * 1000);
    await tester.pumpWidget(_app(energy: state));
    await tester.pump();
    expect(find.text('2/5'), findsOneWidget);
    expect(find.textContaining('+1 in'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull); // 1s timer ticks, never hangs
  });

  testWidgets('energy countdown is reduce-motion safe (clock runs, no hang)',
      (tester) async {
    final state = EnergyState(
        energy: 1,
        dailyFreeUsed: true,
        refillAtMs: DateTime.now().millisecondsSinceEpoch + 30 * 1000);
    await tester.pumpWidget(_app(energy: state, reduceMotion: true));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const Key('energy-chip')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('dailyGoal survives serialization (toMap/fromMap round-trip)', () {
    final restored =
        AppSettings.fromMap(const AppSettings(dailyGoal: 30).toMap());
    expect(restored.dailyGoal, 30);
  });
}
