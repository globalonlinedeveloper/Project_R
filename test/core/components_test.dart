import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/core.dart';

Widget _host(Widget child, {double width = 360}) => MaterialApp(
      theme: RatelTheme.light(),
      home: Scaffold(
        body: Center(child: SizedBox(width: width, child: child)),
      ),
    );

void _noop(int _) {}

void main() {
  group('RatelButton', () {
    testWidgets('primary fires onPressed', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(RatelButton(label: 'Start lesson', onPressed: () => taps++)),
      );
      await tester.tap(find.text('Start lesson'));
      expect(taps, 1);
    });

    testWidgets('disabled (null onPressed) does not throw or fire',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const RatelButton(label: 'Disabled')));
      await tester.tap(find.text('Disabled'));
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('RatelToggle flips value', (WidgetTester tester) async {
    bool v = false;
    await tester.pumpWidget(_host(
      StatefulBuilder(
        builder: (BuildContext c, StateSetter setState) => RatelToggle(
          value: v,
          onChanged: (bool nv) => setState(() => v = nv),
        ),
      ),
    ));
    await tester.tap(find.byType(RatelToggle));
    await tester.pump(RatelMotion.fast);
    expect(v, isTrue);
  });

  testWidgets('RatelBottomNav reports the tapped index',
      (WidgetTester tester) async {
    int? tapped;
    await tester.pumpWidget(
      _host(RatelBottomNav(currentIndex: 0, onTap: (int i) => tapped = i)),
    );
    await tester.tap(find.text('Quests'));
    expect(tapped, 3);
  });

  testWidgets('RatelTopBar surfaces only non-null stats (honest §6)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      const RatelTopBar(flagEmoji: '🇪🇸', langCode: 'ES', streak: 7),
    ));
    expect(find.text('7'), findsOneWidget); // streak shown
    expect(find.text('💎'), findsNothing); // diamonds hidden — no engine
  });

  testWidgets('RatelSectionHeader uppercases + fires action',
      (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(_host(RatelSectionHeader(
      label: 'read & listen',
      action: 'View all',
      onAction: () => tapped = true,
    )));
    expect(find.text('READ & LISTEN'), findsOneWidget);
    await tester.tap(find.textContaining('View all'));
    expect(tapped, isTrue);
  });

  testWidgets('RatelChip factories render PRO/FREE/level',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      Wrap(children: <Widget>[
        RatelChip.pro(),
        RatelChip.free(),
        RatelChip.level('A2'),
      ]),
    ));
    expect(find.text('PRO'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);
    expect(find.text('A2'), findsOneWidget);
  });

  testWidgets('RatelOptionCard renders wrong state', (WidgetTester tester) async {
    await tester.pumpWidget(_host(const RatelOptionCard(
      emoji: '🍎',
      label: 'la manzana',
      state: RatelOptionState.wrong,
    )));
    expect(find.text('la manzana'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Progress bar + ring render with center',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(const Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        RatelProgressBar(value: 0.5),
        SizedBox(height: 8),
        RatelProgressRing(value: 0.45, center: Text('72')),
      ],
    )));
    expect(find.text('72'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RatelListRow shows chevron + fires tap',
      (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(_host(RatelListRow(
      leadingEmoji: '⚙️',
      title: 'Settings',
      subtitle: 'Preferences',
      onTap: () => tapped = true,
    )));
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    expect(tapped, isTrue);
  });

  testWidgets('360px gauntlet — every component, no overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      theme: RatelTheme.light(),
      home: Scaffold(
        body: ListView(
          children: <Widget>[
            const RatelTopBar(
              flagEmoji: '🇪🇸',
              langCode: 'ES',
              streakFreeze: 3,
              streak: 7,
              energy: 4,
              diamonds: '1.24k',
            ),
            const RatelCard(child: Text('card')),
            const SizedBox(height: 8),
            const RatelButton(
              label: 'A very long primary button label that should ellipsize',
            ),
            const SizedBox(height: 8),
            const RatelSectionHeader(
              label: 'daily quests',
              action: 'View all 10 tiers',
            ),
            const RatelListRow(
              leadingEmoji: '🏅',
              title: 'A long row title that keeps going and going and going',
              subtitle: 'and a subtitle that is also quite long indeed yes',
              trailing: Text('500'),
            ),
            const RatelOptionCard(emoji: '🍎', label: 'la manzana'),
          ],
        ),
        bottomNavigationBar: RatelBottomNav(currentIndex: 0, onTap: _noop),
      ),
    ));
    expect(tester.takeException(), isNull);
  });
}
