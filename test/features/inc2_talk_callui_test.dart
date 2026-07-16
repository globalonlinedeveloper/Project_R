// INC-2 (design #21 "Talk"): the in-call CHROME over the live-roleplay session.
// Pins that the dark call presentation renders — the "Ratel · Tutor" status
// row + timer/HD, the big circular avatar with a speaking/idle indicator, the
// self-view "You" PIP, Ratel's SCRIPTED greeting + quick-reply chips, and the
// bottom control bar (mic · camera · captions · red end-call) — AND that the
// fail-closed honesty holds: on the default (flag-off) build the screen states
// plainly that nothing is answered yet and NEVER shows a simulated live reply.
// [C-K1 · C-K2 · C-K4 · C-K5 · R-J1 · R-J3]
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/roleplay/live_roleplay_screen.dart';
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

  @override
  bool get isAvailable => true;

  @override
  Future<LiveSession> start({Map<String, Object?>? payload}) async => session;
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
          ],
        ),
      ],
    );

Future<void> _pump(
  WidgetTester tester, {
  bool pro = false,
  LiveSessionEngine? engine,
  bool freeForm = true, // default: skip the picker → straight to the call chrome
  String? scenarioId,
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
    child: MaterialApp(
      home: LiveRoleplayScreen(freeForm: freeForm, scenarioId: scenarioId),
    ),
  ));
  await tester.pumpAndSettle();
}

// The set of chrome keys design #21 requires — asserted as a group so a
// regression that drops any single part of the call UI fails loudly.
const List<String> _chromeKeys = <String>[
  'screen-live-roleplay', // the dark call canvas
  'live-call-role', // "Ratel · Tutor"
  'live-call-status', // the "00:00 · HD" status line
  'live-call-avatar', // big circular badger avatar
  'live-call-indicator', // speaking / idle label
  'live-call-selfview', // self-view PIP
  'live-call-greeting', // scripted greeting bubble
  'live-roleplay-mute', // control bar: mic
  'live-call-video', // control bar: camera
  'live-call-captions', // control bar: captions
  'live-roleplay-end', // control bar: red end-call
];

void main() {
  group('INC-2 Talk call-UI chrome renders (design #21)', () {
    testWidgets('PRO + live engine: full chrome + self-view "You" + chips',
        (WidgetTester tester) async {
      await _pump(tester, pro: true, engine: _FakeEngine(_FakeSession()));

      for (final String k in _chromeKeys) {
        expect(find.byKey(ValueKey<String>(k)), findsOneWidget,
            reason: 'chrome part "$k" must render');
      }
      // The status line shows the "· HD" quality tag (never a fake clock).
      expect(find.textContaining('HD'), findsOneWidget);
      // Self-view PIP is labelled "You".
      expect(find.text('You'), findsOneWidget);
      // The scripted greeting + both quick-reply chips render.
      expect(find.textContaining('Ready to practice'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('live-call-chip-ready')),
          findsOneWidget);
      expect(find.byKey(const ValueKey<String>('live-call-chip-nervous')),
          findsOneWidget);
      // The greeting is HONESTLY labelled as a scripted opener, not a live turn.
      expect(find.textContaining('scripted opener'), findsOneWidget);
    });

    testWidgets(
        'scaffolded scene: chrome shows the scenario goal context strip',
        (WidgetTester tester) async {
      await _pump(tester,
          pro: true,
          engine: _FakeEngine(_FakeSession()),
          freeForm: false,
          scenarioId: 'rp1');
      expect(find.byKey(const ValueKey<String>('live-call-scenario')),
          findsOneWidget);
      expect(find.textContaining('Introduce yourself'), findsOneWidget);
      // Still the full call chrome, not the cream list.
      expect(find.byKey(const ValueKey<String>('live-call-avatar')),
          findsOneWidget);
    });

    testWidgets('avatar indicator follows the phase (idle → speaking)',
        (WidgetTester tester) async {
      final _FakeSession session = _FakeSession();
      await _pump(tester, pro: true, engine: _FakeEngine(session));
      await tester.tap(find.byKey(const ValueKey<String>('live-roleplay-start')));
      await tester.pumpAndSettle();

      session.emitPhase(LiveSessionPhase.listening);
      await tester.pump();
      expect(find.text('ready'), findsOneWidget,
          reason: 'idle/listening → the calm indicator');

      session.emitPhase(LiveSessionPhase.speaking);
      await tester.pump();
      expect(find.text('speaking…'), findsOneWidget,
          reason: 'tutor speaking → the speaking indicator');
    });

    testWidgets('captions + camera toggles reveal their HONEST gated panes',
        (WidgetTester tester) async {
      await _pump(tester, pro: true, engine: _FakeEngine(_FakeSession()));
      // Off by default.
      expect(find.byKey(const ValueKey<String>('live-call-captions-pane')),
          findsNothing);
      expect(find.byKey(const ValueKey<String>('live-call-camera-note')),
          findsNothing);

      await tester
          .tap(find.byKey(const ValueKey<String>('live-call-captions')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('live-call-captions-pane')),
          findsOneWidget);
      expect(find.textContaining('no transcript is invented'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('live-call-video')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('live-call-camera-note')),
          findsOneWidget);
      expect(find.textContaining('isn’t part of this build'), findsOneWidget);
    });

    testWidgets('red end-call closes an in-progress session honestly',
        (WidgetTester tester) async {
      final _FakeSession session = _FakeSession();
      await _pump(tester, pro: true, engine: _FakeEngine(session));

      // Start the live call, then end it from the red control-bar button.
      await tester
          .tap(find.byKey(const ValueKey<String>('live-roleplay-start')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('live-roleplay-end')));
      await tester.pumpAndSettle();

      // The session is really torn down (not left dangling), and the honest
      // ended card shows — the red button in-call is the true end-call.
      expect(session.closed, isTrue);
      expect(find.byKey(const ValueKey<String>('live-roleplay-ended')),
          findsOneWidget);
      expect(find.byKey(const ValueKey<String>('live-roleplay-again')),
          findsOneWidget);
    });
  });

  group('INC-2 fail-closed honesty (engine Unavailable — the real build)', () {
    testWidgets(
        'PRO but flag-off: chrome renders but states nothing is answered — '
        'and NO faked live reply appears',
        (WidgetTester tester) async {
      await _pump(tester, pro: true); // DEFAULT engine = UnavailableLiveSession

      // The chrome is there…
      expect(find.byKey(const ValueKey<String>('live-call-avatar')),
          findsOneWidget);
      expect(find.byKey(const ValueKey<String>('live-roleplay-end')),
          findsOneWidget);
      // …but the honest not-enabled state, not a live session.
      expect(find.byKey(const ValueKey<String>('live-not-enabled')),
          findsOneWidget);
      expect(find.textContaining('no reply is ever simulated'), findsOneWidget);
      // There is NO start button and NO transcript — nothing is faked.
      expect(find.byKey(const ValueKey<String>('live-roleplay-start')),
          findsNothing);
      expect(find.byKey(const ValueKey<String>('live-turn-0')), findsNothing);
      // Tapping the mic in this state cannot manufacture a turn.
      await tester.tap(find.byKey(const ValueKey<String>('live-roleplay-mute')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('live-turn-0')), findsNothing);
    });

    testWidgets('free (non-PRO): PRO lock inside the chrome, never a mic start',
        (WidgetTester tester) async {
      await _pump(tester, pro: false);
      // Still the dark call chrome…
      expect(find.byKey(const ValueKey<String>('live-call-avatar')),
          findsOneWidget);
      // …with the PRO paywall, not a live session.
      expect(find.text('Unlock RATEL PRO'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('live-roleplay-start')),
          findsNothing);
      expect(find.byKey(const ValueKey<String>('live-turn-0')), findsNothing);
    });
  });
}
