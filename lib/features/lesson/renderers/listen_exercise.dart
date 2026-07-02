import 'package:flutter/material.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart' show AudioHandle;

/// "Listen" (TTS audio) exercise renderer — hear the target phrase, then assemble
/// it from a word bank (the Build shell + an audio control row). Design:
/// `SPEC_LISTEN_TTS.md` §2 / `SPEC_EXERCISES.md` §(a).3 (dc.html L431–451).
///
/// HONESTY: this widget is only ever routed to when a REAL, playable audio source
/// is wired (content gate + delivery gate — SPEC §1/§5). It NEVER draws a play
/// button that plays nothing: audio is INJECTED as an [AudioHandle]; if a wired
/// handle throws at tap time the widget catches it, shows a brief NON-blocking
/// hint, and the bank + Check stay fully usable (read-the-prompt degrade). When
/// no audio is available the RUNNER falls through to the typed renderer instead
/// of building this widget at all.
///
/// Pure presentation: no provider reads, no navigation, no network, no
/// `dart:math`. Colours/space/shape only from [RatelColors] / [RatelSpace] /
/// [RatelRadius] / [RatelMotion] + `context.palette`. Renders without overflow at
/// 360px width. Mirrors [MatchExercise]'s discipline verbatim.
class ListenExercise extends StatefulWidget {
  const ListenExercise({
    super.key,
    required this.audio,
    required this.tokens,
    required this.target,
    required this.onGraded,
    this.reduceMotion = false,
  });

  /// The resolved, PLAYABLE audio source (never null here — the runner only
  /// builds this widget when a real handle exists).
  final AudioHandle audio;

  /// Bank chips (already shuffled by the runner) — the Build shell.
  final List<String> tokens;

  /// The ordered correct assembly (grading = ordered token-join vs this).
  final List<String> target;

  /// Fired EXACTLY once when Check is tapped: `true` iff the assembly matches.
  final void Function(bool allCorrect) onGraded;

  /// Hard floor: no play-button pulse when true. Audio itself is CONTENT, not
  /// motion, so playback is not gated by this — only the visual pulse is.
  final bool reduceMotion;

  @override
  State<ListenExercise> createState() => _ListenExerciseState();
}

class _ListenExerciseState extends State<ListenExercise> {
  /// Indices into [ListenExercise.tokens] placed into the tray, in tap order.
  final List<int> _picked = <int>[];

  /// Guards the single [ListenExercise.onGraded] call + locks the bank on Check.
  bool _checked = false;

  /// Non-blocking "audio unavailable" hint shown after an [AudioHandle] throw.
  bool _audioError = false;

  /// Which control is mid-pulse (0 = play, 1 = slow, -1 = none). Never set under
  /// reduce-motion (no pulse, no timer scheduled).
  int _pulseWhich = -1;
  int _pulseToken = 0;

  bool get _canCheck => _picked.isNotEmpty && !_checked;

  Future<void> _playAudio({required bool slow}) async {
    final int which = slow ? 1 : 0;
    if (!widget.reduceMotion) {
      final int token = ++_pulseToken;
      setState(() => _pulseWhich = which);
      Future<void>.delayed(RatelMotion.fast, () {
        if (!mounted || token != _pulseToken) return;
        setState(() => _pulseWhich = -1);
      });
    }
    try {
      if (slow) {
        await widget.audio.playSlow();
      } else {
        await widget.audio.play();
      }
      if (mounted && _audioError) setState(() => _audioError = false);
    } catch (_) {
      // Never trap the learner behind broken audio (SPEC §5).
      if (mounted) setState(() => _audioError = true);
    }
  }

  void _place(int i) {
    if (_checked || _picked.contains(i)) return;
    setState(() => _picked.add(i));
  }

  void _remove(int i) {
    if (_checked) return;
    setState(() => _picked.remove(i));
  }

  void _check() {
    if (!_canCheck) return;
    final List<String> assembled = <String>[
      for (final int i in _picked) widget.tokens[i],
    ];
    final bool correct = _seqEq(assembled, widget.target);
    setState(() => _checked = true);
    widget.onGraded(correct);
  }

  static bool _seqEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final RatelPalette palette = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Audio control row: big play + smaller slow-replay.
        Row(
          children: <Widget>[
            _audioButton(
              which: 0,
              emoji: '🔊',
              size: 62,
              label: 'Play audio',
              onTap: () => _playAudio(slow: false),
            ),
            const SizedBox(width: RatelSpace.md),
            _audioButton(
              which: 1,
              emoji: '🐢',
              size: 44,
              label: 'Play slowly',
              onTap: () => _playAudio(slow: true),
            ),
          ],
        ),
        if (_audioError) ...<Widget>[
          const SizedBox(height: RatelSpace.sm),
          Text(
            'Audio unavailable — read the prompt.',
            style: TextStyle(
              fontFamily: RatelFont.body,
              fontSize: RatelType.body,
              color: palette.muted,
            ),
          ),
        ],
        const SizedBox(height: RatelSpace.lg),
        // Answer tray (bottom-bordered) — reuses the Build shell tile styling.
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(vertical: RatelSpace.sm),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: palette.border)),
          ),
          child: Wrap(
            spacing: RatelSpace.sm,
            runSpacing: RatelSpace.sm,
            children: <Widget>[
              for (final int i in _picked)
                RatelWordTile(
                  word: widget.tokens[i],
                  onTap: _checked ? null : () => _remove(i),
                ),
            ],
          ),
        ),
        const SizedBox(height: RatelSpace.lg),
        // Bank.
        Wrap(
          spacing: RatelSpace.sm,
          runSpacing: RatelSpace.sm,
          children: <Widget>[
            for (int i = 0; i < widget.tokens.length; i++)
              RatelWordTile(
                word: widget.tokens[i],
                used: _picked.contains(i),
                onTap: _checked ? null : () => _place(i),
              ),
          ],
        ),
        const SizedBox(height: RatelSpace.lg),
        RatelButton(
          label: 'Check',
          onPressed: _canCheck ? _check : null,
        ),
      ],
    );
  }

  Widget _audioButton({
    required int which,
    required String emoji,
    required double size,
    required String label,
    required VoidCallback onTap,
  }) {
    final Widget circle = AnimatedScale(
      scale: _pulseWhich == which ? 1.08 : 1.0,
      duration: widget.reduceMotion ? Duration.zero : RatelMotion.fast,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: RatelColors.teal,
          shape: BoxShape.circle,
          // Chunky flat drop shadow (mockup `0 3px 0`), tinted teal-dark.
          boxShadow: <BoxShadow>[
            BoxShadow(color: RatelColors.tealDark, offset: Offset(0, 3)),
          ],
        ),
        child: Text(emoji, style: TextStyle(fontSize: size * 0.42)),
      ),
    );
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: circle,
      ),
    );
  }
}
