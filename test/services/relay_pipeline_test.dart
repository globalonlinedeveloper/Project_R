// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// COST-1 [R-M8 · R-H7] tests for buildModeratedBudgetedRelay — the cost-safe relay stack
// ModeratedAiRelay(BudgetedAiRelay(model)). Proves the output-moderation cost-bypass is
// closed: a model call that produces output is METERED the instant it returns, BEFORE output
// moderation runs, so an output BLOCK (or an output-moderation FAILURE) still counts against
// the per-user / global cap. Input blocks and over-cap denials short-circuit BEFORE the model
// and are never charged; the happy path charges exactly once. No network, no key.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

/// Model spy: counts calls; optionally throws (a failed/unavailable model produces no output).
class _SpyModel implements AiRelay {
  _SpyModel({this.out = 'model reply', this.throwOnCall = false});
  final String out;
  final bool throwOnCall;
  int calls = 0;
  @override
  bool get isAvailable => true;
  @override
  Future<RelayText> complete(String prompt) async {
    calls++;
    if (throwOnCall) throw const RelayUnavailable('model down');
    return RelayText(out);
  }
}

/// Moderation provider driven by (text, callIndex): call 0 = input, call 1 = output.
class _FnProvider implements ModerationProvider {
  _FnProvider(this.fn);
  final Future<ModerationVerdict> Function(String text, int call) fn;
  int call = 0;
  @override
  Future<ModerationVerdict> classify(String text) => fn(text, call++);
}

const _prompt = 'please summarize this paragraph'; // no injection markers => sanitize is a no-op
const _guard = CostGuard(); // defaults: estimate 4 for a short prompt, perUserDailyCap 50

void main() {
  final estimate = _guard.estimateCost(_prompt); // exact expected charge on a metered attempt

  test('THE FIX: output-moderation BLOCK still charges (model ran -> metered before block)',
      () async {
    final model = _SpyModel();
    var recorded = 0;
    final relay = buildModeratedBudgetedRelay(
      model: model,
      moderationProvider: _FnProvider((t, c) async =>
          c == 0 ? ModerationVerdict.allowed : ModerationVerdict.blocked),
      userSpentToday: () async => 0,
      globalSpentToday: () async => 0,
      recordSpend: (c) async => recorded += c,
      guard: _guard,
    );
    await expectLater(relay.complete(_prompt), throwsA(isA<ModerationBlocked>()));
    expect(model.calls, 1, reason: 'the model was called (cost incurred)');
    expect(recorded, estimate, reason: 'output block must NOT bypass the spend cap');
  });

  test('output-moderation FAILURE (unknown/timeout) also charges (model ran)', () async {
    final model = _SpyModel();
    var recorded = 0;
    final relay = buildModeratedBudgetedRelay(
      model: model,
      moderationProvider: _FnProvider((t, c) async {
        if (c == 0) return ModerationVerdict.allowed; // input ok
        throw StateError('moderation provider down on output');
      }),
      userSpentToday: () async => 0,
      globalSpentToday: () async => 0,
      recordSpend: (c) async => recorded += c,
      guard: _guard,
    );
    await expectLater(relay.complete(_prompt), throwsA(isA<ModerationUnavailable>()));
    expect(model.calls, 1);
    expect(recorded, estimate);
  });

  test('INPUT-moderation block does NOT charge (model never called)', () async {
    final model = _SpyModel();
    var recorded = 0;
    final relay = buildModeratedBudgetedRelay(
      model: model,
      moderationProvider:
          _FnProvider((t, c) async => ModerationVerdict.blocked), // blocks input first
      userSpentToday: () async => 0,
      globalSpentToday: () async => 0,
      recordSpend: (c) async => recorded += c,
      guard: _guard,
    );
    await expectLater(relay.complete(_prompt), throwsA(isA<ModerationBlocked>()));
    expect(model.calls, 0, reason: 'input block short-circuits before the model');
    expect(recorded, 0);
  });

  test('over-cap denies before the model and does NOT charge', () async {
    final model = _SpyModel();
    var recorded = 0;
    final relay = buildModeratedBudgetedRelay(
      model: model,
      moderationProvider: _FnProvider((t, c) async => ModerationVerdict.allowed),
      userSpentToday: () async => 50, // == default perUserDailyCap -> any estimate exceeds it
      globalSpentToday: () async => 0,
      recordSpend: (c) async => recorded += c,
      guard: _guard,
    );
    await expectLater(relay.complete(_prompt), throwsA(isA<RelayBudgetExceeded>()));
    expect(model.calls, 0);
    expect(recorded, 0);
  });

  test('model FAILURE (no output) is not charged', () async {
    final model = _SpyModel(throwOnCall: true);
    var recorded = 0;
    final relay = buildModeratedBudgetedRelay(
      model: model,
      moderationProvider: _FnProvider((t, c) async => ModerationVerdict.allowed),
      userSpentToday: () async => 0,
      globalSpentToday: () async => 0,
      recordSpend: (c) async => recorded += c,
      guard: _guard,
    );
    await expectLater(relay.complete(_prompt), throwsA(isA<RelayUnavailable>()));
    expect(model.calls, 1, reason: 'the model was attempted');
    expect(recorded, 0, reason: 'a failed model call produced no output -> no charge');
  });

  test('happy path: returns output and charges EXACTLY once', () async {
    final model = _SpyModel(out: 'clean answer');
    var recorded = 0;
    var charges = 0;
    final relay = buildModeratedBudgetedRelay(
      model: model,
      moderationProvider: _FnProvider((t, c) async => ModerationVerdict.allowed),
      userSpentToday: () async => 0,
      globalSpentToday: () async => 0,
      recordSpend: (c) async {
        recorded += c;
        charges += 1;
      },
      guard: _guard,
    );
    final out = await relay.complete(_prompt);
    expect(out.plain, 'clean answer');
    expect(model.calls, 1);
    expect(charges, 1, reason: 'no double-charge');
    expect(recorded, estimate);
  });
}
