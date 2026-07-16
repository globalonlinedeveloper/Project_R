import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/roleplay/live_roleplay_scaffold.dart';
import 'package:ratel/services/live_session/live_session.dart';

/// LIVE Roleplay / Talk (L-3, S113 — plan `RATEL_LIVE_AI_PLAN.md` §B; design
/// #21 "Talk"). Pick an authored scene (or free conversation) from the cream
/// picker, then TALK it out with the live tutor inside the dark in-call
/// **chrome** (INC-2): a full-bleed call canvas with the "Ratel · Tutor"
/// status row + timer/HD + signal, the big circular badger avatar with a
/// speaking/idle label, a self-view "You" PIP, Ratel's scripted greeting +
/// quick-reply chips, and a bottom control bar (mic · camera · captions · red
/// end-call).
///
/// HONESTY (design spec §6 "don't fake depth"): the surface is gated by TWO
/// real signals — the PRO entitlement AND an available live engine
/// ([liveSessionEngineProvider], the honest Unavailable default until the
/// RATEL_LIVE_AI flag flips at L-5). A free user sees the PRO paywall; a PRO
/// user on a flag-off build sees plainly WHY live voice isn't on yet, framed
/// inside the same chrome. No session, reply, transcript, camera frame, or
/// caption is ever simulated — the greeting is a clearly-labelled scripted
/// opener, not a live turn. The scenario scaffold rides the token mint; the
/// system prompt is built SERVER-side by `live-token` v2.
/// [R-H2 · R-H6 · R-H7 · R-D11 · R-J1 · R-J3 · C-K1 · C-K2]
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
  // M-4: distinguish a user-ended scene from an UNEXPECTED drop (WSS died).
  bool _userEnded = false;
  bool _dropped = false;
  // LV-1: transcription streams as incremental deltas; a phase change
  // seals the open bubble so the next delta opens a fresh one.
  bool _sealOpenTurn = false;
  // INC-2 chrome toggles — captions/camera are UI affordances only; both are
  // honestly gated (no live engine => no real frame/transcript is produced).
  bool _captionsOn = false;
  bool _cameraOn = false;

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

  Future<void> _start(
    LiveSessionEngine engine,
    CourseSpine spine,
    CourseScenario? scenario,
  ) async {
    if (_starting || _session != null) return;
    setState(() {
      _starting = true;
      _ended = false;
      _userEnded = false; // M-4: a fresh attempt is not a user-ended scene
      _turns.clear();
      _sealOpenTurn = false;
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
        _dropped = false; // M-4: reconnected — the band comes down
      });
      _phaseSub = session.phases.listen((LiveSessionPhase p) {
        if (!mounted) return;
        setState(() {
          // A phase change is a turn boundary — seal the open transcript
          // bubble so the next delta (even same speaker) starts fresh (LV-1).
          if (p != _phase) _sealOpenTurn = true;
          _phase = p;
          if (p == LiveSessionPhase.closed) {
            _ended = true;
            _session = null;
            // M-4: closed WITHOUT the user asking = the transport dropped.
            if (!_userEnded) _dropped = true;
          }
        });
      });
      _turnSub = session.transcript.listen((LiveTurn t) {
        if (!mounted) return;
        setState(() => _appendTurn(t));
      });
    } on LiveSessionUnavailable catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                e.code == null ? e.reason : ratelLiveError(context, e.code!),
              ),
            ),
          );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(context.l10n.liveStartFailed)));
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  // LV-1: coalesce consecutive same-speaker deltas into ONE bubble; a new
  // bubble starts on speaker change or after a phase boundary sealed the
  // open turn. Gemini streams many partial fragments per turn — the old
  // `_turns.add` produced a bubble per word.
  void _appendTurn(LiveTurn t) {
    if (!_sealOpenTurn &&
        _turns.isNotEmpty &&
        _turns.last.speaker == t.speaker) {
      final LiveTurn prev = _turns.last;
      _turns[_turns.length - 1] = LiveTurn(
        speaker: prev.speaker,
        text: prev.text + t.text,
      );
    } else {
      _turns.add(t);
      _sealOpenTurn = false;
    }
  }

  Future<void> _end() async {
    final LiveSession? s = _session;
    if (s == null) return;
    _userEnded = true; // M-4: set BEFORE close so the phase listener knows
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

    // The cream scene picker stays the entry (design keeps the list); the dark
    // call CHROME is what opens when a scene (or free conversation) starts.
    if (picking) {
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
          title: Text(
            context.l10n.liveRoleplayTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: RatelFont.display,
              fontWeight: RatelType.extraBold,
              color: context.palette.ink,
              fontSize: RatelType.cardTitle,
            ),
          ),
        ),
        body: SafeArea(top: false, child: _picker(context, spine, isPro)),
      );
    }
    return _callChrome(context, spine, scenario, isPro, engine);
  }

  // ---- scene picker (no scenario chosen yet) -------------------------------
  Widget _picker(BuildContext context, CourseSpine spine, bool isPro) {
    final List<CourseScenario> items = spine.roleplays;
    return ListView(
      key: const ValueKey<String>('screen-live-roleplay-picker'),
      padding: const EdgeInsets.fromLTRB(
        RatelSpace.screen,
        RatelSpace.lg,
        RatelSpace.screen,
        RatelSpace.xl,
      ),
      children: <Widget>[
        Text(
          context.l10n.liveIntro,
          style: TextStyle(
            fontFamily: RatelFont.body,
            fontSize: RatelType.small,
            color: context.palette.muted,
          ),
        ),
        const SizedBox(height: RatelSpace.lg),
        RatelListRow(
          key: const ValueKey<String>('live-roleplay-freeform'),
          leadingEmoji: '💬',
          leadingColor: RatelColors.teal,
          title: context.l10n.liveFreeConversation,
          subtitle: context.l10n.liveFreeConversationSub,
          onTap: () => setState(() => _freeForm = true),
        ),
        const SizedBox(height: RatelSpace.md),
        if (items.isNotEmpty) ...<Widget>[
          RatelSectionHeader(label: context.l10n.liveRoleplayScene),
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

  // ---- the dark in-call CHROME (design #21) --------------------------------
  // A full-bleed dark canvas that presents the live-roleplay session: status
  // row, big avatar, self-view PIP, greeting + chips, and the bottom control
  // bar. The centre "stage" swaps on the real gate — PRO lock / not-enabled /
  // live — so the fail-closed state is shown HONESTLY inside the same frame.
  Widget _callChrome(
    BuildContext context,
    CourseSpine spine,
    CourseScenario? scenario,
    bool isPro,
    LiveSessionEngine engine,
  ) {
    final bool live = isPro && engine.isAvailable;
    return Scaffold(
      backgroundColor: RatelColors.spaceBackdrop,
      body: SafeArea(
        child: Padding(
          key: const ValueKey<String>('screen-live-roleplay'),
          padding: const EdgeInsets.fromLTRB(
            RatelSpace.screen,
            RatelSpace.md,
            RatelSpace.screen,
            RatelSpace.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _statusRow(context, scenario),
              Expanded(
                child: ListView(
                  key: const ValueKey<String>('live-call-stage'),
                  padding: const EdgeInsets.only(top: RatelSpace.lg),
                  children: <Widget>[
                    if (scenario != null) ...<Widget>[
                      _scenarioContext(context, scenario),
                      const SizedBox(height: RatelSpace.md),
                    ],
                    _avatar(context),
                    const SizedBox(height: RatelSpace.md),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _selfViewPip(context),
                    ),
                    const SizedBox(height: RatelSpace.lg),
                    _greeting(context),
                    const SizedBox(height: RatelSpace.md),
                    if (!isPro)
                      _proLock(context)
                    else if (!engine.isAvailable)
                      _notEnabled(context)
                    else
                      _liveStage(context, spine, scenario, engine),
                    if (_captionsOn) ...<Widget>[
                      const SizedBox(height: RatelSpace.md),
                      _captionsPane(context, live),
                    ],
                    if (_cameraOn) ...<Widget>[
                      const SizedBox(height: RatelSpace.md),
                      _cameraNote(context),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: RatelSpace.sm),
              _controlBar(context, spine, scenario, engine),
            ],
          ),
        ),
      ),
    );
  }

  // Top row: "Ratel · Tutor" + timer/HD status + a small signal glyph.
  Widget _statusRow(BuildContext context, CourseScenario? scenario) {
    return Row(
      children: <Widget>[
        // A green presence dot + the tutor role label.
        Container(
          width: 9,
          height: 9,
          decoration: const BoxDecoration(
            color: RatelColors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: RatelSpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                context.l10n.liveTutorRole,
                key: const ValueKey<String>('live-call-role'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: RatelFont.display,
                  fontWeight: RatelType.extraBold,
                  fontSize: RatelType.body,
                  color: RatelColors.darkInk,
                ),
              ),
              Text(
                // "00:00 · HD" — a real status line (no live engine => the
                // call is 00:00; we NEVER fake a ticking clock).
                '${_elapsedLabel()} · ${context.l10n.liveHd}',
                key: const ValueKey<String>('live-call-status'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: RatelColors.darkMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: RatelSpace.sm),
        // Signal strength glyph (static — reflects UI chrome, not a live link).
        const Text('📶', style: TextStyle(fontSize: 16)),
        const SizedBox(width: RatelSpace.sm),
        IconButton(
          key: const ValueKey<String>('live-call-close'),
          tooltip: context.l10n.liveEndCall,
          visualDensity: VisualDensity.compact,
          onPressed: () => context.pop(),
          icon: const Icon(
            RatelIcons.close,
            color: RatelColors.darkMuted,
            size: 20,
          ),
        ),
      ],
    );
  }

  // A compact scenario-context strip (goal · CEFR) so a scaffolded scene names
  // what the learner is here to practise — the same context the pre-INC-2 card
  // carried, restyled for the dark canvas.
  Widget _scenarioContext(BuildContext context, CourseScenario scenario) =>
      Container(
        key: const ValueKey<String>('live-call-scenario'),
        padding: const EdgeInsets.all(RatelSpace.md),
        decoration: BoxDecoration(
          color: RatelColors.darkBg2,
          borderRadius: BorderRadius.circular(RatelRadius.card),
          border: Border.all(color: RatelColors.darkBorder),
        ),
        child: Row(
          children: <Widget>[
            const Text('🎯', style: TextStyle(fontSize: 18)),
            const SizedBox(width: RatelSpace.sm),
            Expanded(
              child: Text(
                scenario.goal == null || scenario.goal!.isEmpty
                    ? '${scenario.title} · ${scenario.cefr}'
                    : '${scenario.goal!} · ${scenario.cefr}',
                style: const TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: RatelColors.darkMuted,
                ),
              ),
            ),
          ],
        ),
      );

  // Big centred circular avatar (the Ratel badger) + speaking/idle label +
  // the tutor name below.
  Widget _avatar(BuildContext context) {
    final bool speaking = _phase == LiveSessionPhase.speaking;
    return Column(
      children: <Widget>[
        Container(
          key: const ValueKey<String>('live-call-avatar'),
          width: 168,
          height: 168,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: <Color>[RatelColors.tealDark, RatelColors.navy],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: RatelColors.teal.withValues(alpha: speaking ? 0.55 : 0.2),
                blurRadius: speaking ? 44 : 24,
                spreadRadius: speaking ? 6 : 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text('🦡', style: TextStyle(fontSize: 76)),
        ),
        const SizedBox(height: RatelSpace.md),
        Text(
          context.l10n.liveTutorName,
          style: const TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            fontSize: RatelType.cardTitle,
            color: RatelColors.darkInk,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          speaking
              ? context.l10n.liveSpeakingIndicator
              : context.l10n.liveIdleIndicator,
          key: const ValueKey<String>('live-call-indicator'),
          style: const TextStyle(
            fontFamily: RatelFont.body,
            fontSize: RatelType.small,
            color: RatelColors.darkMuted,
          ),
        ),
      ],
    );
  }

  // Self-view PIP: a small rounded tile labelled "You" with a mic glyph.
  Widget _selfViewPip(BuildContext context) => Container(
    key: const ValueKey<String>('live-call-selfview'),
    width: 92,
    height: 116,
    decoration: BoxDecoration(
      color: RatelColors.darkSurface,
      borderRadius: BorderRadius.circular(RatelRadius.card),
      border: Border.all(color: RatelColors.darkBorder),
    ),
    padding: const EdgeInsets.all(RatelSpace.sm),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(_muted ? '🔇' : '🎙️', style: const TextStyle(fontSize: 18)),
        Text(
          context.l10n.liveYou,
          style: const TextStyle(
            fontFamily: RatelFont.body,
            fontWeight: RatelType.semiBold,
            fontSize: RatelType.small,
            color: RatelColors.darkInk,
          ),
        ),
      ],
    ),
  );

  // The tutor greeting bubble + 1-2 quick-reply chips. Scripted opener — the
  // greeting, NOT a faked live reply (labelled as such for honesty).
  Widget _greeting(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Container(
        key: const ValueKey<String>('live-call-greeting'),
        padding: const EdgeInsets.all(RatelSpace.md),
        decoration: BoxDecoration(
          color: RatelColors.darkSurface,
          borderRadius: BorderRadius.circular(RatelRadius.card),
          border: Border.all(color: RatelColors.darkBorder),
        ),
        child: Text(
          context.l10n.liveGreeting,
          style: const TextStyle(
            fontFamily: RatelFont.body,
            fontSize: RatelType.body,
            height: 1.35,
            color: RatelColors.darkInk,
          ),
        ),
      ),
      const SizedBox(height: RatelSpace.sm),
      Wrap(
        spacing: RatelSpace.sm,
        runSpacing: RatelSpace.sm,
        children: <Widget>[
          _quickChip(context, const ValueKey<String>('live-call-chip-ready'),
              context.l10n.liveQuickReplyReady),
          _quickChip(context, const ValueKey<String>('live-call-chip-nervous'),
              context.l10n.liveQuickReplyNervous),
        ],
      ),
      const SizedBox(height: RatelSpace.xs),
      Text(
        context.l10n.liveGreetingNote,
        style: const TextStyle(
          fontFamily: RatelFont.body,
          fontSize: RatelType.caption,
          color: RatelColors.darkMuted,
        ),
      ),
    ],
  );

  Widget _quickChip(BuildContext context, Key key, String label) => Material(
    key: key,
    color: RatelColors.darkBg3,
    borderRadius: BorderRadius.circular(RatelRadius.pill),
    child: InkWell(
      borderRadius: BorderRadius.circular(RatelRadius.pill),
      // Honest: a quick-reply chip cannot send a real turn (engine fail-closed);
      // tapping surfaces the same honest "no live reply" note as the mic.
      onTap: () => _announceGated(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RatelSpace.md,
          vertical: RatelSpace.sm,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: RatelFont.body,
            fontWeight: RatelType.semiBold,
            fontSize: RatelType.small,
            color: RatelColors.darkInk,
          ),
        ),
      ),
    ),
  );

  // The live "stage" content beneath the greeting when PRO + engine available:
  // the start button, phase indicator, in-call controls, transcript and the
  // honest ended card — all keys/strings preserved from the pre-INC-2 UI so
  // the live-session behaviour (and its tests) are unchanged.
  Widget _liveStage(
    BuildContext context,
    CourseSpine spine,
    CourseScenario? scenario,
    LiveSessionEngine engine,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_dropped) ...<Widget>[
          _reconnectBand(context, spine, scenario, engine),
          const SizedBox(height: RatelSpace.md),
        ],
        if (!_ended) ...<Widget>[
          _phaseCard(context),
          const SizedBox(height: RatelSpace.md),
        ],
        if (_session == null && !_ended)
          RatelButton(
            key: const ValueKey<String>('live-roleplay-start'),
            label: _starting
                ? context.l10n.liveConnecting
                : context.l10n.liveStartTalking,
            onPressed: _starting ? null : () => _start(engine, spine, scenario),
          ),
        if (_session != null)
          Text(
            _muted ? context.l10n.liveUnmute : context.l10n.liveMute,
            key: const ValueKey<String>('live-roleplay-controls'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: RatelFont.body,
              fontSize: RatelType.small,
              color: RatelColors.darkMuted,
            ),
          ),
        if (_ended && !_dropped) ...<Widget>[
          Container(
            key: const ValueKey<String>('live-roleplay-ended'),
            padding: const EdgeInsets.all(RatelSpace.md),
            decoration: BoxDecoration(
              color: RatelColors.darkSurface,
              borderRadius: BorderRadius.circular(RatelRadius.card),
              border: Border.all(color: RatelColors.darkBorder),
            ),
            child: Row(
              children: <Widget>[
                const Text('🏁', style: TextStyle(fontSize: 22)),
                const SizedBox(width: RatelSpace.md),
                Expanded(
                  child: Text(
                    context.l10n.liveSceneEndedNote,
                    style: const TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.body,
                      color: RatelColors.darkMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RatelSpace.md),
          RatelButton(
            key: const ValueKey<String>('live-roleplay-again'),
            label: context.l10n.liveStartAgain,
            onPressed: _starting ? null : () => _start(engine, spine, scenario),
          ),
        ],
        if (_turns.isNotEmpty) ...<Widget>[
          const SizedBox(height: RatelSpace.lg),
          Text(
            context.l10n.mediaTranscript,
            style: const TextStyle(
              fontFamily: RatelFont.body,
              fontWeight: RatelType.semiBold,
              fontSize: RatelType.caption,
              color: RatelColors.darkMuted,
            ),
          ),
          const SizedBox(height: RatelSpace.sm),
          for (int i = 0; i < _turns.length; i++) _turn(context, i),
        ],
      ],
    );
  }

  Widget _reconnectBand(
    BuildContext context,
    CourseSpine spine,
    CourseScenario? scenario,
    LiveSessionEngine engine,
  ) {
    // M-4: an UNEXPECTED drop is named honestly and offers a REAL one-tap
    // reconnect (the tap IS the user gesture the browser mic rules require).
    return Container(
      key: const ValueKey<String>('live-reconnect-band'),
      padding: const EdgeInsets.all(RatelSpace.md),
      decoration: BoxDecoration(
        color: RatelColors.amber.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(RatelRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('📡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: RatelSpace.sm),
              Expanded(
                child: Text(
                  _starting
                      ? context.l10n.liveReconnecting
                      : context.l10n.liveConnectionLost,
                  key: const ValueKey<String>('live-reconnect-status'),
                  style: const TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    fontWeight: RatelType.semiBold,
                    color: RatelColors.darkInk,
                  ),
                ),
              ),
            ],
          ),
          if (!_starting) ...<Widget>[
            const SizedBox(height: RatelSpace.sm),
            RatelButton(
              key: const ValueKey<String>('live-reconnect'),
              label: context.l10n.liveReconnect,
              variant: RatelButtonVariant.secondary,
              expand: false,
              onPressed: () => _start(engine, spine, scenario),
            ),
          ],
        ],
      ),
    );
  }

  Widget _proLock(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Container(
        padding: const EdgeInsets.all(RatelSpace.md),
        decoration: BoxDecoration(
          color: RatelColors.darkSurface,
          borderRadius: BorderRadius.circular(RatelRadius.card),
          border: Border.all(color: RatelColors.darkBorder),
        ),
        child: Row(
          children: <Widget>[
            const Text('🎙️', style: TextStyle(fontSize: 22)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Text(
                context.l10n.liveProGate,
                style: const TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.body,
                  color: RatelColors.darkMuted,
                ),
              ),
            ),
            const SizedBox(width: RatelSpace.sm),
            RatelChip.pro(),
          ],
        ),
      ),
      const SizedBox(height: RatelSpace.md),
      RatelButton(
        label: context.l10n.liveUnlockPro,
        onPressed: () => context.push('/paywall?source=live-roleplay'),
      ),
    ],
  );

  Widget _notEnabled(BuildContext context) => Container(
    key: const ValueKey<String>('live-not-enabled'),
    padding: const EdgeInsets.all(RatelSpace.md),
    decoration: BoxDecoration(
      color: RatelColors.darkSurface,
      borderRadius: BorderRadius.circular(RatelRadius.card),
      border: Border.all(color: RatelColors.darkBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text('🔌', style: TextStyle(fontSize: 22)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Text(
                context.l10n.liveNotEnabled,
                style: const TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.body,
                  color: RatelColors.darkInk,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: RatelSpace.sm),
        Text(
          context.l10n.liveConnectPrompt,
          style: const TextStyle(
            fontFamily: RatelFont.body,
            fontSize: RatelType.small,
            height: 1.35,
            color: RatelColors.darkMuted,
          ),
        ),
      ],
    ),
  );

  Widget _phaseCard(BuildContext context) {
    final (String emoji, String label) = _phaseChrome(context);
    return Container(
      key: const ValueKey<String>('live-roleplay-phase'),
      padding: const EdgeInsets.all(RatelSpace.md),
      decoration: BoxDecoration(
        color: RatelColors.darkSurface,
        borderRadius: BorderRadius.circular(RatelRadius.card),
        border: Border.all(color: RatelColors.darkBorder),
      ),
      child: Row(
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.body,
                color: RatelColors.darkInk,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // The bottom control bar: mic toggle · camera toggle · captions toggle · a
  // red end-call button that returns to the scene list.
  Widget _controlBar(
    BuildContext context,
    CourseSpine spine,
    CourseScenario? scenario,
    LiveSessionEngine engine,
  ) {
    final bool inCall = _session != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _controlButton(
          key: const ValueKey<String>('live-roleplay-mute'),
          tooltip: _muted ? context.l10n.liveUnmute : context.l10n.liveMute,
          glyph: _muted ? '🔇' : '🎙️',
          active: !_muted,
          onTap: () {
            setState(() => _muted = !_muted);
            if (inCall) {
              _session?.setMicMuted(_muted);
            } else {
              _announceGated(context);
            }
          },
        ),
        _controlButton(
          key: const ValueKey<String>('live-call-video'),
          tooltip: _cameraOn
              ? context.l10n.liveVideoOn
              : context.l10n.liveVideoOff,
          glyph: _cameraOn ? '📹' : '📷',
          active: _cameraOn,
          onTap: () => setState(() => _cameraOn = !_cameraOn),
        ),
        _controlButton(
          key: const ValueKey<String>('live-call-captions'),
          tooltip: _captionsOn
              ? context.l10n.liveCaptionsOn
              : context.l10n.liveCaptionsOff,
          glyph: '💬',
          active: _captionsOn,
          onTap: () => setState(() => _captionsOn = !_captionsOn),
        ),
        _controlButton(
          key: const ValueKey<String>('live-roleplay-end'),
          tooltip: context.l10n.liveEndCall,
          glyph: '📞',
          danger: true,
          active: true,
          onTap: () async {
            if (inCall) {
              await _end();
            } else {
              if (context.mounted) context.pop();
            }
          },
        ),
      ],
    );
  }

  Widget _controlButton({
    required Key key,
    required String tooltip,
    required String glyph,
    required VoidCallback onTap,
    bool danger = false,
    bool active = false,
  }) {
    final Color bg = danger
        ? RatelColors.coral
        : (active
            ? RatelColors.darkBg3
            : RatelColors.darkSurface);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: InkResponse(
          key: key,
          onTap: onTap,
          radius: 34,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: danger
                  ? null
                  : Border.all(color: RatelColors.darkBorder),
              boxShadow: danger
                  ? <BoxShadow>[
                      BoxShadow(
                        color: RatelColors.coral.withValues(alpha: 0.5),
                        blurRadius: 22,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(glyph, style: const TextStyle(fontSize: 22)),
          ),
        ),
      ),
    );
  }

  Widget _captionsPane(BuildContext context, bool live) => Container(
    key: const ValueKey<String>('live-call-captions-pane'),
    width: double.infinity,
    padding: const EdgeInsets.all(RatelSpace.md),
    decoration: BoxDecoration(
      color: RatelColors.darkBg2,
      borderRadius: BorderRadius.circular(RatelRadius.card),
      border: Border.all(color: RatelColors.darkBorder),
    ),
    child: Text(
      // Honest: with no live engine there is no transcript to caption; when
      // live, the real transcript renders in the stage above, never invented.
      context.l10n.liveCaptionsGated,
      style: const TextStyle(
        fontFamily: RatelFont.body,
        fontSize: RatelType.small,
        height: 1.35,
        color: RatelColors.darkMuted,
      ),
    ),
  );

  Widget _cameraNote(BuildContext context) => Container(
    key: const ValueKey<String>('live-call-camera-note'),
    width: double.infinity,
    padding: const EdgeInsets.all(RatelSpace.md),
    decoration: BoxDecoration(
      color: RatelColors.darkBg2,
      borderRadius: BorderRadius.circular(RatelRadius.card),
      border: Border.all(color: RatelColors.darkBorder),
    ),
    child: Text(
      context.l10n.liveCameraGated,
      style: const TextStyle(
        fontFamily: RatelFont.body,
        fontSize: RatelType.small,
        height: 1.35,
        color: RatelColors.darkMuted,
      ),
    ),
  );

  void _announceGated(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(context.l10n.liveConnectPrompt)),
      );
  }

  // Phase -> (emoji, label). Shared by the status row and the phase card so
  // the honest phase copy stays single-sourced (strings unchanged from L-3).
  (String, String) _phaseChrome(BuildContext context) => switch (_phase) {
    LiveSessionPhase.idle => ('🎙️', context.l10n.livePhaseIdle),
    LiveSessionPhase.connecting => ('⏳', context.l10n.liveConnecting),
    LiveSessionPhase.listening => ('🎤', context.l10n.livePhaseListening),
    LiveSessionPhase.speaking => ('🔊', context.l10n.livePhaseSpeaking),
    LiveSessionPhase.closed => ('🏁', context.l10n.livePhaseClosed),
  };

  // The status clock. No live engine => no real elapsed time, so it stays
  // 00:00 (design shows a short timer; we NEVER fake a ticking clock).
  String _elapsedLabel() => '00:00';

  Widget _turn(BuildContext context, int i) {
    final LiveTurn t = _turns[i];
    final bool you = t.speaker == LiveSpeaker.you;
    return Padding(
      key: ValueKey<String>('live-turn-$i'),
      padding: const EdgeInsets.only(bottom: RatelSpace.sm),
      child: Row(
        mainAxisAlignment: you
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: RatelSpace.md,
                vertical: RatelSpace.sm,
              ),
              decoration: BoxDecoration(
                color: you ? RatelColors.teal : RatelColors.darkSurface,
                borderRadius: BorderRadius.circular(RatelRadius.card),
              ),
              child: Text(
                '${you ? context.l10n.liveYou : '🦡 Ratel'}: ${t.text}',
                style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.body,
                  color: you ? RatelColors.onColor : RatelColors.darkInk,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
