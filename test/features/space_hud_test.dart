import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/design_system/design_system.dart';

/// Animated header HUD (spec §6): tier-gated vector chips. Loops run only at
/// MotionTier.full; lower tiers paint the still frame (reduce-motion HARD floor).
Widget _host(MotionTier tier) => MaterialApp(
      theme: RatelTheme.space(),
      home: Scaffold(
        backgroundColor: SpacePalette.phoneBg,
        body: SpaceHud(streak: 3, energyLabel: '4', flameHue: 208, tier: tier),
      ),
    );

void main() {
  testWidgets('renders flame/bolt/gem-soon/bell + language chips',
      (tester) async {
    await tester.pumpWidget(_host(MotionTier.full));
    await tester.pump();
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    expect(find.text('3'), findsOneWidget); // streak number
    expect(find.byIcon(Icons.bolt), findsWidgets); // glow + core
    expect(find.text('4'), findsOneWidget); // energy
    expect(find.text('soon'), findsOneWidget); // honest gem placeholder
    expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduce-motion freezes the HUD (static — settles, no hang)',
      (tester) async {
    await tester.pumpWidget(_host(MotionTier.minimal));
    await tester.pumpAndSettle(); // no looping controller -> settles cleanly
    expect(find.text('soon'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('full motion keeps looping (advances frame-by-frame safely)',
      (tester) async {
    await tester.pumpWidget(_host(MotionTier.full));
    await tester.pump();
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(tester.takeException(), isNull);
  });
}
