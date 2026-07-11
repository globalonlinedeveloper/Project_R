import 'package:flutter/material.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart'
    show AudioHandle, RateControlledAudio;

/// The Listen audio-control row: a large 🔊 play button + a smaller 🐢
/// slow-replay button, with a reduce-motion-aware press pulse and a
/// NON-blocking "audio unavailable" hint. Pure presentation; the [AudioHandle]
/// is injected (never a plugin import here), so it is unit-testable with a fake.
///
/// Shared by the word-bank [ListenExercise] and the runner's type-what-you-hear
/// Listen. Never traps the learner behind broken audio (SPEC_LISTEN_TTS §5): a
/// handle throw only surfaces the hint; interaction elsewhere is unaffected.
// R-D5 · R-D8 — the Listen/dictation audio-control row.
class ListenAudioControls extends StatefulWidget {
  const ListenAudioControls({
    super.key,
    required this.audio,
    this.reduceMotion = false,
  });

  /// The resolved, PLAYABLE audio source.
  final AudioHandle audio;

  /// Hard floor: no press pulse (and no pulse timer scheduled) when true. Audio
  /// itself is content, not motion, so playback is NOT gated by this.
  final bool reduceMotion;

  @override
  State<ListenAudioControls> createState() => _ListenAudioControlsState();
}

class _ListenAudioControlsState extends State<ListenAudioControls> {
  /// Q-6: playback-speed cycle for the main play button (design-approved
  /// quick win). 1x -> 1.25x -> 0.75x -> 1x; the turtle keeps its dedicated
  /// extra-slow replay. Applied via [RateControlledAudio] where the handle
  /// supports it (browser TTS); otherwise normal [AudioHandle.play] — the
  /// toggle never breaks playback where rate control does not exist.
  static const List<double> _kRates = <double>[1.0, 1.25, 0.75];
  int _rateIx = 0;

  bool _audioError = false;
  int _pulseWhich = -1; // 0 = play, 1 = slow, -1 = none
  int _pulseToken = 0;

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
      final double rate = _kRates[_rateIx];
      final AudioHandle audio = widget.audio;
      if (slow) {
        await audio.playSlow();
      } else if (rate != 1.0 && audio is RateControlledAudio) {
        // Explicit cast: RateControlledAudio is not a subtype of
        // AudioHandle, so `is` cannot promote across the interfaces.
        await (audio as RateControlledAudio).playAt(rate);
      } else {
        await audio.play();
      }
      if (mounted && _audioError) setState(() => _audioError = false);
    } catch (_) {
      if (mounted) setState(() => _audioError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final RatelPalette palette = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
            const SizedBox(width: RatelSpace.md),
            _speedChip(context),
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
      ],
    );
  }

  /// The cycling speed chip: 1x -> 1.25x -> 0.75x. Compact label ("1.25x"),
  /// announced as a button with the CURRENT speed so screen-reader users
  /// hear what the next play will use.
  Widget _speedChip(BuildContext context) {
    final double rate = _kRates[_rateIx];
    final String label = rate == 1.0 ? '1\u00d7' : '$rate\u00d7';
    // Label + child text merge ("Playback speed / 1x") and the tap action
    // stays with the GestureDetector — never excludeSemantics here.
    return Semantics(
      button: true,
      label: 'Playback speed',
      child: GestureDetector(
        key: const ValueKey<String>('listen-speed-toggle'),
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            setState(() => _rateIx = (_rateIx + 1) % _kRates.length),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: RatelSpace.md,
            vertical: RatelSpace.sm,
          ),
          decoration: BoxDecoration(
            color: context.palette.white,
            borderRadius: BorderRadius.circular(RatelRadius.chip),
            border: Border.all(color: context.palette.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: RatelFont.display,
              fontWeight: RatelType.semiBold,
              fontSize: RatelType.small,
              color: context.palette.ink,
            ),
          ),
        ),
      ),
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
