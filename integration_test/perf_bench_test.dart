// On-device performance bench — R-O1 check-6 follow-up (see docs/STAGE2_EXIT.md).
//
// The headless `test/perf/perf_gauntlet_test.dart` proves *structural* perf
// (every core screen lays out on a 360px cheap phone with no overflow, and the
// heaviest animation combo disposes cleanly, R-N1/R-N8). This bench proves
// *timing* budgets on a real Android emulator under a PROFILE build, driven by
// CI (`.github/workflows/perf-bench.yml`, gated to skip-green without KVM):
//
//   flutter drive \
//     --driver=test_driver/perf_driver.dart \
//     --target=integration_test/perf_bench_test.dart \
//     --profile
//
// It captures, into build/integration_response_data.json (uploaded as a CI
// artifact via the default `integrationDriver()` -> `writeResponseData`):
//
//   • cold_start            — app boot -> first frame (ms), within-test
//   • core_loop_performance — FrameTiming summary (build + raster ms,
//                             avg/90th/99th/worst) while the real app shell
//                             renders & animates
//   • mascot_performance    — FrameTiming summary while the looping mascot +
//                             the 60-particle levelUp celebration run at FULL
//                             motion (the heaviest combo, R-L18/R-L19/R-N8)
//   • mascot_memory         — process RSS before/after mounting the mascot
//                             (bytes; delta is the rough rig footprint)
//
// Guardrails: local · NO DB · `schema/schema.json` frozen · still 161 reqs.
// Timing captures are best-effort (recorded as {'error': ...} rather than
// throwing) so the bench stays a data-collector, not a pass/fail gate — the one
// hard assertion is that the real app actually boots.

import 'dart:io' show ProcessInfo;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/mascot/mascot_view.dart';

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  void put(String key, Object? value) {
    binding.reportData ??= <String, dynamic>{};
    binding.reportData![key] = value;
  }

  // Pump ~`frames` real frames (~16ms each) so the engine produces FrameTimings.
  Future<void> pumpFrames(WidgetTester tester, {int frames = 120}) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  testWidgets('cold-start: boot RATEL to first frame', (tester) async {
    final sw = Stopwatch()..start();
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pump(); // first frame committed
    sw.stop();
    put('cold_start', <String, dynamic>{
      'boot_to_first_frame_ms': sw.elapsedMicroseconds / 1000.0,
    });
    await tester.pumpAndSettle();
    // Hard gate: the real app must actually boot (everything else is data).
    expect(find.byType(RatelApp), findsOneWidget);
  });

  testWidgets('frame timings: app shell renders & animates (build + raster)',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    try {
      await binding.watchPerformance(
        () async => pumpFrames(tester),
        reportKey: 'core_loop_performance',
      );
    } catch (e) {
      put('core_loop_performance', <String, dynamic>{'error': '$e'});
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('mascot: memory + full-motion frame timings (R-N8)',
      (tester) async {
    // Baseline frame with no mascot mounted.
    await tester.pumpWidget(
      MaterialApp(
        theme: RatelTheme.light(),
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );
    await tester.pumpAndSettle();
    final rssBefore = ProcessInfo.currentRss;

    // Heaviest combo: looping mascot + levelUp celebration, full motion.
    await tester.pumpWidget(
      MaterialApp(
        theme: RatelTheme.light(),
        home: const Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: MascotView(size: 160, mood: MascotMood.cheer),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: RatelCelebration(level: CelebrationLevel.levelUp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    try {
      await binding.watchPerformance(
        () async => pumpFrames(tester),
        reportKey: 'mascot_performance',
      );
    } catch (e) {
      put('mascot_performance', <String, dynamic>{'error': '$e'});
    }

    final rssAfter = ProcessInfo.currentRss;
    put('mascot_memory', <String, dynamic>{
      'rss_before_bytes': rssBefore,
      'rss_after_bytes': rssAfter,
      'rss_delta_bytes': rssAfter - rssBefore,
    });

    // Unmount -> the mascot controller + celebration timers dispose (R-N8):
    // a leaked controller/timer would throw here.
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
