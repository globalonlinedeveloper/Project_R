import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/roleplay/live_roleplay_screen.dart';
import 'package:ratel/services/billing/billing.dart';
import 'package:ratel/services/live_session/live_session.dart';

// M-4 (screen review 2026-07 §2): the live-roleplay connection band.
// An UNEXPECTED close (transport drop) raises an honest band with a REAL
// one-tap Reconnect (a silent auto-reconnect would break the browser
// user-gesture mic rules — pinned in the screen). 'Reconnecting…' renders
// exactly while a reconnect attempt is in flight. A USER-ended scene shows
// the normal 'Scene ended' card and NO band.

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
  LiveSessionPhase _phase = LiveSessionPhase.listening;
  bool closed = false;

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
  void setMicMuted(bool muted) {}
  @override
  Future<void> close() async {
    closed = true;
    emitPhase(LiveSessionPhase.closed);
  }
}

/// Returns a FRESH session per start (a dropped socket cannot be reused) and
/// optionally gates the connect on a completer so 'Reconnecting…' is
/// observable mid-flight.
class _FakeEngine implements LiveSessionEngine {
  int starts = 0;
  _FakeSession? current;
  Completer<void>? gate;

  @override
  bool get isAvailable => true;

  @override
  Future<LiveSession> start({Map<String, Object?>? payload}) async {
    starts++;
    if (gate != null) await gate!.future;
    return current = _FakeSession();
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
          scenes: <CourseScene>[
            CourseScene(sceneId: 'sc1', speaker: 'Ben', line: 'Hi.'),
          ],
        ),
      ],
    );

Future<void> _pump(WidgetTester tester, _FakeEngine engine) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spine()),
      entitlementsProvider.overrideWithValue(const _ProEntitlements()),
      liveSessionEngineProvider.overrideWithValue(engine),
    ],
    child: const MaterialApp(home: LiveRoleplayScreen(scenarioId: 'rp1')),
  ));
  await tester.pumpAndSettle();
}

Finder get _band => find.byKey(const ValueKey<String>('live-reconnect-band'));
Finder get _reconnect => find.byKey(const ValueKey<String>('live-reconnect'));

void main() {
  testWidgets('transport drop raises the band; user end does NOT',
      (WidgetTester tester) async {
    final _FakeEngine engine = _FakeEngine();
    await _pump(tester, engine);

    await tester.tap(find.byKey(const ValueKey<String>('live-roleplay-start')));
    await tester.pumpAndSettle();
    expect(_band, findsNothing);

    // WSS drop: the session closes WITHOUT the user asking.
    engine.current!.emitPhase(LiveSessionPhase.closed);
    await tester.pumpAndSettle();

    expect(_band, findsOneWidget);
    expect(find.text('Connection lost — the live session dropped.'),
        findsOneWidget);
    expect(_reconnect, findsOneWidget);
    // The misleading 'Scene ended' card must NOT show for a drop.
    expect(find.textContaining('Scene ended'), findsNothing);
  });

  testWidgets('Reconnect shows Reconnecting… in flight, then clears the band',
      (WidgetTester tester) async {
    final _FakeEngine engine = _FakeEngine();
    await _pump(tester, engine);
    await tester.tap(find.byKey(const ValueKey<String>('live-roleplay-start')));
    await tester.pumpAndSettle();
    engine.current!.emitPhase(LiveSessionPhase.closed);
    await tester.pumpAndSettle();
    expect(_band, findsOneWidget);

    // Gate the next connect so the in-flight state is observable.
    engine.gate = Completer<void>();
    await tester.tap(_reconnect);
    await tester.pump();
    expect(find.text('Reconnecting…'), findsOneWidget);
    expect(_reconnect, findsNothing); // no second tap while in flight

    engine.gate!.complete();
    engine.gate = null;
    await tester.pumpAndSettle();

    expect(_band, findsNothing, reason: 'reconnected — band comes down');
    expect(engine.starts, 2);
    expect(find.byKey(const ValueKey<String>('live-roleplay-end')),
        findsOneWidget, reason: 'a live session is running again');
  });

  testWidgets('user-ended scene keeps the normal ended card, no band',
      (WidgetTester tester) async {
    final _FakeEngine engine = _FakeEngine();
    await _pump(tester, engine);
    await tester.tap(find.byKey(const ValueKey<String>('live-roleplay-start')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('live-roleplay-end')));
    await tester.pumpAndSettle();

    expect(_band, findsNothing);
    expect(find.textContaining('Scene ended'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('live-roleplay-again')),
        findsOneWidget);
  });
}
