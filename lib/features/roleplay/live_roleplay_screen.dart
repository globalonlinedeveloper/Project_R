import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/roleplay/live_roleplay_scaffold.dart';
import 'package:ratel/services/live_session/live_session.dart';

/// LIVE Roleplay (L-3, S113 — plan `RATEL_LIVE_AI_PLAN.md` §B): the PRO voice
/// surface beside the pre-generated 🎭 roleplay library. Pick an authored
/// scene (or free conversation) and TALK it out with the live tutor — mic up,
/// tutor voice back, live transcript, honest phase indicator, end-of-scene
/// feedback spoken by the tutor (instructed server-side).
///
/// HONESTY (design spec §6 "don't fake depth"): the surface is gated by TWO
/// real signals — the PRO entitlement AND an available live engine
/// ([liveSessionEngineProvider], the honest Unavailable default until the
/// RATEL_LIVE_AI flag flips at L-5). A free user sees the PRO paywall; a PRO
/// user on a flag-off build sees plainly WHY live voice isn't on yet. No
/// session, reply, or transcript is ever simulated. The scenario scaffold
/// rides the token mint; the system prompt is built SERVER-side by
/// `live-token` v2. [R-H2 · R-H6 · R-H7 · R-D11 · R-J1 · R-J3]
class LiveRoleplayScreen extends ConsumerStatefulWidget {
  const LiveRoleplayScreen({super.key, this.scenarioId, this.freeForm = false});

  /// Optional authored scenario to scaffold the scene (null => picker).
  final String? scenarioId;

  /// Skip the picker straight into a free conversation (L-4: the Tutor
  /// screen's "Talk to Ratel" entry — no scenario scaffold, lang only).
  final bool freeForm;

  @override
  ConsumerState<LiveRoleplayScreen> createState() => _LiveRoleplayScreenState();
}

class _LiveRoleplayScreenState extends ConsumerState<LiveRoleplayScreen> {
  String? _selectedId; // picked scenario (seeded from the route param)
  bool _freeForm = false; // explicit "Free conversation" choice

  LiveSession? _session;
  StreamSubscription<LiveSessionPhase>? _phaseSub;
  StreamSubscription<LiveTurn>? _turnSub;
  LiveSessionPhase _phase = LiveSessionPhase.idle;
  final List<LiveTurn> _turns = <LiveTurn>[];
  bool _starting = false;
  bool _muted = false;
  bool _ended = false;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.scenarioId;
    _freeForm = widget.freeForm;
  }

  @override
  void dispose() {
    _phaseSub?.cancel();
    _turnSub?.cancel();
    _session?.close();
    super.dispose();
  }

  CourseScenario? _find(CourseSpine spine, String? id) {
    if (id == null) return null;
    for (final CourseScenario s in spine.roleplays) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> _start(LiveSessionEngine engine, CourseSpine spine,
      CourseScenario? scenario) async {
    if (_starting || _session != null) return;
    setState(() {
      _starting = true;
      _ended = false;
      _turns.clear();
    });
    try {
      // The AudioContexts + mic prompt live inside start() — this call MUST
      // stay in the tap handler (browser user-gesture rules, plan §A).
      final LiveSession session = await engine.start(
        payload: liveRoleplayPayload(
          scenario: scenario,
          courseCode: spine.courseCode,
        ),
      );
      if (!mounted) {
        await session.close();
        return;
      }
      setState(() {
        _session = session;
        _phase = session.phase;
      });
      _phaseSub = session.phases.listen((LiveSessionPhase p) {
        if (!mounted) return;
        setState(() {
          _phase = p;
          if (p == LiveSessionPhase.closed) {
            _ended = true;
            _session = null;
          }
        });
      });
      _turnSub = session.transcript.listen((LiveTurn t) {
        if (!mounted) return;
        setState(() => _turns.add(t));
      });
    } on LiveSessionUnavailable catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.reason)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
              content: Text('Could not start the live session — try again.')));
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _end() async {
    final LiveSession? s = _session;
    if (s == null) return;
    await s.close();
    if (mounted) {
      setState(() {
        _ended = true;
        _session = null;
        _phase = LiveSessionPhase.closed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final CourseSpine spine = ref.watch(courseSpineProvider);
    final bool isPro = ref.watch(isProProvider);
    final LiveSessionEngine engine = ref.watch(liveSessionEngineProvider);
    final CourseScenario? scenario = _find(spine, _selectedId);
    final bool picking =
        scenario == null && !_freeForm && _session == null && !_ended;

    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.cream,
        surfaceTintColor: context.palette.cream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(RatelIcons.arrowBack, color: context.palette.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(scenario?.title ?? 'Live Roleplay',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                color: context.palette.ink,
                fontSize: RatelType.cardTitle)),
      ),
      body: SafeArea(
        top: false,
        child: picking
            ? _picker(context, spine, isPro)
            : _scene(context, spine, scenario, isPro, engine),
      ),
    );
  }

  // ---- scene picker (no scenario chosen yet) -------------------------------
  Widget _picker(BuildContext context, CourseSpine spine, bool isPro) {
    final List<CourseScenario> items = spine.roleplays;
    return ListView(
      key: const ValueKey<String>('screen-live-roleplay-picker'),
      padding: const EdgeInsets.fromLTRB(
          RatelSpace.screen, RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
      children: <Widget>[
        Text(
          'Talk it out with Ratel — live voice roleplay. Pick a scene, or just have a conversation.',
          style: TextStyle(
              fontFamily: RatelFont.body,
              fontSize: RatelType.small,
              color: context.palette.muted),
        ),
        const SizedBox(height: RatelSpace.lg),
        RatelListRow(
          key: const ValueKey<String>('live-roleplay-freeform'),
          leadingEmoji: '💬',
          leadingColor: RatelColors.teal,
          title: 'Free conversation',
          subtitle: 'No script — just talk',
          onTap: () => setState(() => _freeForm = true),
        ),
        const SizedBox(height: RatelSpace.md),
        if (items.isNotEmpty) ...<Widget>[
          RatelSectionHeader(label: 'Roleplay a scene'),
          const SizedBox(height: RatelSpace.sm),
          for (final CourseScenario s in items) ...<Widget>[
            RatelListRow(
              key: ValueKey<String>('live-roleplay-pick-${s.id}'),
              leadingEmoji: '🎙️',
              leadingColor: RatelColors.purple,
              title: s.title,
              subtitle:
                  '${s.cefr}${s.goal == null || s.goal!.isEmpty ? '' : ' · ${s.goal!}'}',
              onTap: () => setState(() => _selectedId = s.id),
            ),
            const SizedBox(height: RatelSpace.sm),
          ],
        ],
      ],
    );
  }

  // ---- the live scene ------------------------------------------------------
  Widget _scene(BuildContext context, CourseSpine spine,
      CourseScenario? scenario, bool isPro, LiveSessionEngine engine) {
    return ListView(
      key: const ValueKey<String>('screen-live-roleplay'),
      padding: const EdgeInsets.fromLTRB(
          RatelSpace.screen, RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
      children: <Widget>[
        if (scenario != null) ...<Widget>[
          RatelCard(
            color: context.palette.cream2,
            child: Row(children: <Widget>[
              const Text('🎯', style: TextStyle(fontSize: 20)),
              const SizedBox(width: RatelSpace.sm),
              Expanded(
                child: Text(
                  scenario.goal == null || scenario.goal!.isEmpty
                      ? '${scenario.title} · ${scenario.cefr}'
                      : '${scenario.goal!} · ${scenario.cefr}',
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      color: context.palette.muted),
                ),
              ),
            ]),
          ),
          const SizedBox(height: RatelSpace.md),
        ],
        if (!isPro)
          _proLock(context)
        else if (!engine.isAvailable)
          _notEnabled(context)
        else ...<Widget>[
          _phaseCard(context),
          const SizedBox(height: RatelSpace.md),
          if (_session == null && !_ended)
            RatelButton(
              key: const ValueKey<String>('live-roleplay-start'),
              label: _starting ? 'Connecting…' : 'Start talking',
              onPressed: _starting
                  ? null
                  : () => _start(engine, spine, scenario),
            ),
          if (_session != null) _controls(context),
          if (_ended) ...<Widget>[
            RatelCard(
              color: context.palette.cream2,
              child: Row(children: <Widget>[
                const Text('🏁', style: TextStyle(fontSize: 22)),
                const SizedBox(width: RatelSpace.md),
                Expanded(
                  child: Text(
                    'Scene ended. Start again whenever you like — your live minutes are budgeted, never silent.',
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.body,
                        color: context.palette.muted),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: RatelSpace.md),
            RatelButton(
              key: const ValueKey<String>('live-roleplay-again'),
              label: 'Start again',
              onPressed: _starting
                  ? null
                  : () => _start(engine, spine, scenario),
            ),
          ],
          if (_turns.isNotEmpty) ...<Widget>[
            const SizedBox(height: RatelSpace.lg),
            RatelSectionHeader(label: 'Transcript'),
            const SizedBox(height: RatelSpace.sm),
            for (int i = 0; i < _turns.length; i++) _turn(context, i),
          ],
        ],
      ],
    );
  }

  Widget _proLock(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RatelCard(
            color: context.palette.cream2,
            child: Row(children: <Widget>[
              const Text('🎙️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: RatelSpace.md),
              Expanded(
                child: Text(
                  'Live voice roleplay is a RATEL PRO feature — real conversation, live feedback, cost-guarded minutes.',
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.body,
                      color: context.palette.muted),
                ),
              ),
              const SizedBox(width: RatelSpace.sm),
              RatelChip.pro(),
            ]),
          ),
          const SizedBox(height: RatelSpace.md),
          RatelButton(
            label: 'Unlock RATEL PRO',
            onPressed: () => context.push('/paywall?source=live-roleplay'),
          ),
        ],
      );

  Widget _notEnabled(BuildContext context) => RatelCard(
        color: context.palette.cream2,
        child: Row(children: <Widget>[
          const Text('🔌', style: TextStyle(fontSize: 22)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Text(
              'Live voice is not enabled in this build yet — it turns on in a later step. Nothing here is simulated.',
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.body,
                  color: context.palette.muted),
            ),
          ),
        ]),
      );

  Widget _phaseCard(BuildContext context) {
    final (String emoji, String label) = switch (_phase) {
      LiveSessionPhase.idle => ('🎙️', 'Ready when you are — it’s a real live call.'),
      LiveSessionPhase.connecting => ('⏳', 'Connecting…'),
      LiveSessionPhase.listening => ('🎤', 'Listening — your turn.'),
      LiveSessionPhase.speaking => ('🔊', 'Ratel is speaking — jump in any time.'),
      LiveSessionPhase.closed => ('🏁', 'Scene ended.'),
    };
    return RatelCard(
      key: const ValueKey<String>('live-roleplay-phase'),
      color: context.palette.cream2,
      child: Row(children: <Widget>[
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: RatelSpace.md),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.body,
                  color: context.palette.ink)),
        ),
      ]),
    );
  }

  Widget _controls(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: RatelButton(
              key: const ValueKey<String>('live-roleplay-end'),
              label: 'End scene',
              onPressed: _end,
            ),
          ),
          const SizedBox(width: RatelSpace.md),
          IconButton(
            key: const ValueKey<String>('live-roleplay-mute'),
            tooltip: _muted ? 'Unmute' : 'Mute',
            onPressed: () {
              setState(() => _muted = !_muted);
              _session?.setMicMuted(_muted);
            },
            icon: Text(_muted ? '🔇' : '🎙️',
                style: const TextStyle(fontSize: 22)),
          ),
        ],
      );

  Widget _turn(BuildContext context, int i) {
    final LiveTurn t = _turns[i];
    final bool you = t.speaker == LiveSpeaker.you;
    return Padding(
      key: ValueKey<String>('live-turn-$i'),
      padding: const EdgeInsets.only(bottom: RatelSpace.sm),
      child: Row(
        mainAxisAlignment:
            you ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: RatelSpace.md, vertical: RatelSpace.sm),
              decoration: BoxDecoration(
                color: you ? RatelColors.teal : context.palette.cream2,
                borderRadius: BorderRadius.circular(RatelRadius.card),
              ),
              child: Text(
                '${you ? 'You' : '🦡 Ratel'}: ${t.text}',
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: you ? RatelColors.onColor : context.palette.ink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
