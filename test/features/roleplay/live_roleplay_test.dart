// L-3 (S113): the LIVE Roleplay PRO surface (plan RATEL_LIVE_AI_PLAN.md §B).
// Pins (1) the client scenario-scaffold payload (structure only — the system
// prompt is built SERVER-side by live-token v2), (2) the two-signal honesty
// gate (PRO entitlement AND an available engine; the default build shows the
// paywall / honest not-enabled copy, never a fake session), and (3) the live
// session UI over a FAKE engine: payload capture, phase indicator, transcript
// bubbles, mute, end-of-scene. [R-H2 · R-H6 · R-H7 · R-D11 · R-J1]
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/features/roleplay/live_roleplay_scaffold.dart';
import 'package:ratel/features/roleplay/live_roleplay_screen.dart';
import 'package:ratel/features/roleplay/roleplay_screen.dart';
import 'package:ratel/services/billing/billing.dart';
import 'package:ratel/services/live_session/live_session.dart';

class _ProEntitlements implements Entitlements {
  const _ProEntitlements();
  @override
  bool get isPro => true;
}

class _FakeSession implements LiveSession {
  final StreamController<LiveSessionPhase> _phases =
      StreamController<LiveSessionPhase>.broadcast();
  final StreamController<LiveTurn> _turns =
      StreamController<LiveTurn>.broadcast();
  LiveSessionPhase _phase = LiveSessionPhase.connecting;
  bool closed = false;
  bool? lastMuted;

  void emitPhase(LiveSessionPhase p) {
    _phase = p;
    _phases.add(p);
  }

  void emitTurn(LiveTurn t) => _turns.add(t);

  @override
  Stream<LiveSessionPhase> get phases => _phases.stream;
  @override
  Stream<LiveTurn> get transcript => _turns.stream;
  @override
  LiveSessionPhase get phase => _phase;
  @override
  void setMicMuted(bool muted) => lastMuted = muted;
  @override
  Future<void> close() async {
    closed = true;
    emitPhase(LiveSessionPhase.closed);
  }
}

class _FakeEngine implements LiveSessionEngine {
  _FakeEngine(this.session);
  final _FakeSession session;
  Map<String, Object?>? captured;
  int starts = 0;

  @override
  bool get isAvailable => true;

  @override
  Future<LiveSession> start({Map<String, Object?>? payload}) async {
    starts++;
    captured = payload;
    return session;
  }
}

CourseSpine _spine() => const CourseSpine(
      courseCode: 'en',
      units: <CourseUnit>[],
      roleplays: <CourseScenario>[
        CourseScenario(
          id: 'rp1',
          kind: 'roleplay',
          title: 'Meet a friend',
          cefr: 'A1',
          goal: 'Introduce yourself',
          world: 'A sunny park',
          scenes: <CourseScene>[
            CourseScene(sceneId: 'sc1', speaker: 'Ben', line: 'Hi, I am Ben.'),
            CourseScene(
              sceneId: 'sc2',
              speaker: 'you',
              line: 'How do you reply?',
              choices: <CourseChoice>[
                CourseChoice(label: 'Hello!', isCorrect: true),
              ],
            ),
            CourseScene(
                sceneId: 'sc3', speaker: 'Ben', line: 'Nice to meet you!'),
          ],
        ),
      ],
    );

Future<void> _pump(
  WidgetTester tester, {
  String? scenarioId,
  bool pro = false,
  LiveSessionEngine? engine,
}) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spine()),
      if (pro) entitlementsProvider.overrideWithValue(const _ProEntitlements()),
      if (engine != null) liveSessionEngineProvider.overrideWithValue(engine),
    ],
    child: MaterialApp(home: LiveRoleplayScreen(scenarioId: scenarioId)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('liveRoleplayPayload (client scaffold — server builds the prompt)', () {
    test('carries lang + authored fields and ONLY non-decision script lines',
        () {
      final CourseScenario s = _spine().roleplays.single;
      final Map<String, Object?> p =
          liveRoleplayPayload(scenario: s, courseCode: 'en');
      expect(p['lang'], 'en');
      final Map<String, Object?> sc = p['scenario']! as Map<String, Object?>;
      expect(sc['title'], 'Meet a friend');
      expect(sc['cefr'], 'A1');
      expect(sc['goal'], 'Introduce yourself');
      expect(sc['world'], 'A sunny park');
      final List<dynamic> lines = sc['lines']! as List<dynamic>;
      expect(lines.length, 2, reason: 'the decision scene is NOT script');
      expect((lines.first as Map<String, String>)['speaker'], 'Ben');
      expect(
          lines.any((dynamic l) =>
              (l as Map<String, String>)['line']!.contains('How do you')),
          isFalse,
          reason: 'meta prompts never reach the scaffold');
    });

    test('free-form => lang only; blank course code => empty payload', () {
      expect(liveRoleplayPayload(courseCode: 'en'),
          <String, Object?>{'lang': 'en'});
      expect(liveRoleplayPayload(courseCode: '  '), isEmpty);
    });

    test('caps script lines at maxLines', () {
      final CourseScenario s = CourseScenario(
        id: 'x',
        kind: 'roleplay',
        title: 'Long',
        cefr: 'B1',
        scenes: <CourseScene>[
          for (int i = 0; i < 20; i++)
            CourseScene(sceneId: 's$i', speaker: 'N', line: 'Line $i'),
        ],
      );
      final Map<String, Object?> p =
          liveRoleplayPayload(scenario: s, courseCode: 'en', maxLines: 6);
      final Map<String, Object?> sc = p['scenario']! as Map<String, Object?>;
      expect((sc['lines']! as List<dynamic>).length, 6);
    });
  });

  group('two-signal honesty gate', () {
    testWidgets('free user sees the PRO lock + paywall CTA, never a mic',
        (WidgetTester tester) async {
      await _pump(tester, scenarioId: 'rp1', pro: false);
      expect(find.text('Unlock RATEL PRO'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('live-roleplay-start')),
          findsNothing);
    });

    testWidgets(
        'PRO user on the default (flag-off) build sees the honest not-enabled copy',
        (WidgetTester tester) async {
      await _pump(tester, scenarioId: 'rp1', pro: true); // default engine
      expect(find.textContaining('not enabled in this build'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('live-roleplay-start')),
          findsNothing);
      expect(find.text('Unlock RATEL PRO'), findsNothing);
    });
  });

  group('live session over a fake engine (PRO + available)', () {
    testWidgets(
        'start captures the scenario payload; phases + transcript + mute + end all render honestly',
        (WidgetTester tester) async {
      final _FakeSession session = _FakeSession();
      final _FakeEngine engine = _FakeEngine(session);
      await _pump(tester, scenarioId: 'rp1', pro: true, engine: engine);

      // Scenario context card + start button.
      expect(find.textContaining('Introduce yourself'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('live-roleplay-start')));
      await tester.pumpAndSettle();
      expect(engine.starts, 1);
      expect(engine.captured?['lang'], 'en');
      final Map<String, Object?> sc =
          engine.captured?['scenario']! as Map<String, Object?>;
      expect(sc['title'], 'Meet a friend');

      // Phase indicator follows the stream.
      session.emitPhase(LiveSessionPhase.listening);
      await tester.pumpAndSettle();
      expect(find.textContaining('your turn'), findsOneWidget);
      session.emitPhase(LiveSessionPhase.speaking);
      await tester.pumpAndSettle();
      expect(find.textContaining('Ratel is speaking'), findsOneWidget);
      session.emitPhase(LiveSessionPhase.listening); // barge-in
      await tester.pumpAndSettle();
      expect(find.textContaining('your turn'), findsOneWidget);

      // Transcript bubbles (you right / tutor left).
      session.emitTurn(const LiveTurn(speaker: LiveSpeaker.you, text: 'Hello'));
      session.emitTurn(
          const LiveTurn(speaker: LiveSpeaker.tutor, text: 'Hi there!'));
      await tester.pumpAndSettle();
      expect(find.textContaining('You: Hello'), findsOneWidget);
      expect(find.textContaining('Ratel: Hi there!'), findsOneWidget);

      // Mute toggles through to the session.
      await tester.tap(find.byKey(const ValueKey<String>('live-roleplay-mute')));
      await tester.pumpAndSettle();
      expect(session.lastMuted, isTrue);

      // End closes the session and lands on the honest ended state.
      await tester.tap(find.byKey(const ValueKey<String>('live-roleplay-end')));
      await tester.pumpAndSettle();
      expect(session.closed, isTrue);
      expect(find.textContaining('Scene ended'), findsWidgets);
      expect(find.byKey(const ValueKey<String>('live-roleplay-again')),
          findsOneWidget);
      // The transcript survives the scene end.
      expect(find.textContaining('You: Hello'), findsOneWidget);
    });

    testWidgets('picker: free conversation + authored scenes; picking scaffolds',
        (WidgetTester tester) async {
      final _FakeEngine engine = _FakeEngine(_FakeSession());
      await _pump(tester, pro: true, engine: engine); // no scenarioId => picker
      expect(find.byKey(const ValueKey<String>('screen-live-roleplay-picker')),
          findsOneWidget);
      expect(find.text('Free conversation'), findsOneWidget);
      await tester
          .tap(find.byKey(const ValueKey<String>('live-roleplay-pick-rp1')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Introduce yourself'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('live-roleplay-start')));
      await tester.pumpAndSettle();
      expect((engine.captured?['scenario']! as Map<String, Object?>)['title'],
          'Meet a friend');
    });

    testWidgets('free-form choice starts with a lang-only payload',
        (WidgetTester tester) async {
      final _FakeEngine engine = _FakeEngine(_FakeSession());
      await _pump(tester, pro: true, engine: engine);
      await tester
          .tap(find.byKey(const ValueKey<String>('live-roleplay-freeform')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('live-roleplay-start')));
      await tester.pumpAndSettle();
      expect(engine.captured, <String, Object?>{'lang': 'en'});
    });
  });

  group('RoleplayScreen live entry (additive beside the authored list)', () {
    testWidgets('shows the Live Roleplay card AND keeps the authored rows',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(460, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[
          courseSpineProvider.overrideWithValue(_spine()),
        ],
        child: const MaterialApp(home: RoleplayScreen()),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('live-roleplay-entry')),
          findsOneWidget);
      expect(find.text('PRO'), findsOneWidget,
          reason: 'free users see the pre-tap PRO badge (R-J1)');
      expect(find.byKey(const ValueKey<String>('roleplay-row-rp1')),
          findsOneWidget,
          reason: 'the pre-generated surface is untouched (anti-goal §D)');
    });
  });

  // ---- L-4 (S113): Tutor "Talk" wiring over the REAL router ----------------
  group('L-4: Tutor Talk wiring (real router)', () {
    Future<void> pumpApp(WidgetTester tester, _FakeEngine engine) async {
      tester.view.physicalSize = const Size(460, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[
          courseSpineProvider.overrideWithValue(_spine()),
          settingsStoreProvider.overrideWithValue(
              InMemorySettingsStore(const AppSettings(reduceMotion: true))),
          entitlementsProvider.overrideWithValue(const _ProEntitlements()),
          liveSessionEngineProvider.overrideWithValue(engine),
        ],
        child: const RatelApp(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('AI Tutor'));
      await tester.pumpAndSettle();
    }

    testWidgets(
        'PRO + live engine: Talk to Ratel goes straight to a free conversation',
        (WidgetTester tester) async {
      final _FakeEngine engine = _FakeEngine(_FakeSession());
      await pumpApp(tester, engine);
      await tester.tap(find.text('Talk to Ratel'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('screen-live-roleplay')),
          findsOneWidget,
          reason: 'free-form skips the picker');
      expect(find.byKey(const ValueKey<String>('live-roleplay-start')),
          findsOneWidget);
    });

    testWidgets('PRO + live engine: Roleplay scenes opens the live picker',
        (WidgetTester tester) async {
      final _FakeEngine engine = _FakeEngine(_FakeSession());
      await pumpApp(tester, engine);
      await tester.tap(find.text('Roleplay scenes'));
      await tester.pumpAndSettle();
      expect(
          find.byKey(const ValueKey<String>('screen-live-roleplay-picker')),
          findsOneWidget);
      expect(find.text('Free conversation'), findsOneWidget);
    });

    testWidgets(
        'PRO but flag-off (default engine): tap stays the honest announce',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(460, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[
          courseSpineProvider.overrideWithValue(_spine()),
          settingsStoreProvider.overrideWithValue(
              InMemorySettingsStore(const AppSettings(reduceMotion: true))),
          entitlementsProvider.overrideWithValue(const _ProEntitlements()),
        ],
        child: const RatelApp(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('AI Tutor'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Talk to Ratel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('connects once the moderated relay'),
          findsOneWidget,
          reason: 'no navigation, no fake session — honest announce');
      expect(find.byKey(const ValueKey<String>('screen-live-roleplay')),
          findsNothing);
    });
  });
}
