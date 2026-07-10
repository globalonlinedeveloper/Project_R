import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/auth_gate.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/auth/welcome_screen.dart';

// AUTH-1 (S112): the first-launch Welcome gate — Register / Log in / Continue
// as guest. §11 preconditions: the gate + entry seams default OFF/no-op
// app-wide, so every test here sets its preconditions explicitly.

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  List<Override> overrides = const <Override>[],
  VoidCallback? onRegister,
  VoidCallback? onLogin,
  VoidCallback? onEntered,
}) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final ProviderContainer container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: RatelTheme.light(),
      home: WelcomeScreen(
          onRegister: onRegister, onLogin: onLogin, onEntered: onEntered),
    ),
  ));
  await tester.pump();
  return container;
}

void main() {
  testWidgets('renders the three entry actions + the guest note',
      (WidgetTester tester) async {
    await _pump(tester);
    expect(find.byKey(const Key('welcome')), findsOneWidget);
    expect(find.byKey(const Key('welcome-register')), findsOneWidget);
    expect(find.text('Create free account'), findsOneWidget);
    expect(find.byKey(const Key('welcome-login')), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
    expect(find.byKey(const Key('welcome-guest')), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
    expect(find.textContaining('Guest progress lives on this device'),
        findsOneWidget);
  });

  testWidgets(
      'Continue as guest: runs the entry action, persists the choice, '
      'drops the gate, then navigates', (WidgetTester tester) async {
    bool guestCalled = false;
    bool entered = false;
    final List<String> persisted = <String>[];
    final ProviderContainer container = await _pump(
      tester,
      overrides: <Override>[
        welcomeGateNeededProvider.overrideWith((ref) => true),
        guestEntryProvider.overrideWithValue(() async {
          guestCalled = true;
        }),
        authChoicePersisterProvider.overrideWithValue((String choice) async {
          persisted.add(choice);
        }),
      ],
      onEntered: () => entered = true,
    );
    await tester.tap(find.byKey(const Key('welcome-guest')));
    await tester.pump();
    expect(guestCalled, isTrue);
    expect(persisted, <String>[kAuthChoiceGuest]);
    expect(container.read(welcomeGateNeededProvider), isFalse);
    expect(entered, isTrue);
  });

  testWidgets('Register / Log in hand off to the router callbacks',
      (WidgetTester tester) async {
    bool register = false;
    bool login = false;
    await _pump(tester,
        onRegister: () => register = true, onLogin: () => login = true);
    await tester.tap(find.byKey(const Key('welcome-register')));
    await tester.pump();
    expect(register, isTrue);
    expect(login, isFalse);
    await tester.tap(find.byKey(const Key('welcome-login')));
    await tester.pump();
    expect(login, isTrue);
  });
}
