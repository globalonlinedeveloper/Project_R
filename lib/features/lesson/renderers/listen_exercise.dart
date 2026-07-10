import 'package:flutter/material.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart' show AudioHandle;

import 'listen_audio_controls.dart';

/// "Listen" (TTS audio) exercise renderer — hear the target phrase, then
/// assemble it from a word bank (the Build shell + a [ListenAudioControls]
/// row). Design: `SPEC_LISTEN_TTS.md` §2 / `SPEC_EXERCISES.md` §(a).3
/// (dc.html L431–451).
///
/// CONTROLLED component (C-7): the picked-order state and grading live in the
/// runner (`lesson_runner_screen.dart`, its `_answer`), exactly like the Build
/// word-bank — so the "Check" CTA sits in the runner's FIXED footer (`_bottom`),
/// consistent with every other exercise type, instead of a second Check button
/// buried in the scroll body. This widget is now pure presentation: it renders
/// the audio row + answer tray + bank and reports taps via [onPlace]/[onRemove].
///
/// HONESTY: only ever routed to when a REAL, playable audio source is wired
/// (content + delivery gates — SPEC §1/§5). Audio is INJECTED as an
/// [AudioHandle]; the shared [ListenAudioControls] shows a non-blocking hint on
/// a handle throw and the bank stays usable. When no audio is available the
/// RUNNER falls through to the typed renderer instead of building this widget.
///
/// Pure presentation: no provider reads, no navigation, no network, no
/// `dart:math`. Tokens/shape from the design system + `context.palette`. No
/// overflow at 360px. Mirrors [MatchExercise]'s discipline.
// R-D5 (listen — word-bank assembly variant).
class ListenExercise extends StatelessWidget {
  const ListenExercise({
    super.key,
    required this.audio,
    required this.tokens,
    required this.picked,
    required this.checked,
    required this.onPlace,
    required this.onRemove,
    this.reduceMotion = false,
  });

  /// The resolved, PLAYABLE audio source (never null here).
  final AudioHandle audio;

  /// Bank chips (already shuffled by the runner) — the Build shell.
  final List<String> tokens;

  /// Indices into [tokens] currently placed in the tray, in tap order. Owned by
  /// the runner (its `_answer`) so the FIXED footer Check can grade them.
  final List<int> picked;

  /// When true the bank is locked (post-Check) — taps are ignored.
  final bool checked;

  /// Report a bank-chip tap: append its index to the tray.
  final void Function(int index) onPlace;

  /// Report a tray-chip tap: remove its index from the tray.
  final void Function(int index) onRemove;

  /// Hard floor: no play-button pulse when true.
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final RatelPalette palette = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ListenAudioControls(audio: audio, reduceMotion: reduceMotion),
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
              for (final int i in picked)
                RatelWordTile(
                  word: tokens[i],
                  onTap: checked ? null : () => onRemove(i),
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
            for (int i = 0; i < tokens.length; i++)
              RatelWordTile(
                word: tokens[i],
                used: picked.contains(i),
                onTap: checked ? null : () => onPlace(i),
              ),
          ],
        ),
      ],
    );
  }
}
