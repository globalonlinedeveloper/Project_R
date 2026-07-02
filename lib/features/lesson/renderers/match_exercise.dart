import 'package:flutter/material.dart';
import 'package:ratel/core/core.dart';

/// A row to match. Pure data; the runner builds these from REAL CourseSpine pairs.
class MatchPair {
  final String prompt;
  final String answer;
  const MatchPair(this.prompt, this.answer);
}

/// Text **Match** exercise renderer — R-D7 (matching pairs). Design spec
/// §4.7 "Match" (text variant,
/// mockup `matchTap` L2031–2044 / tile styling L2143–2156).
///
/// Two columns: the left column lists the [MatchPair.prompt]s in authored order;
/// the right column lists the [MatchPair.answer]s in a DETERMINISTIC shuffle
/// (see [_shuffledRight] — a reversal / fixed rotation, never `dart:math`, so
/// widget tests are stable). The learner taps a prompt (teal-accent highlight),
/// then taps an answer:
///   • match  → both tiles turn green + lock (opacity .35, disabled);
///   • wrong  → a brief coral flash (600ms, matching the mockup) then deselect —
///              the flash is skipped entirely when [reduceMotion] is set.
/// A second tap in the SAME column just moves the selection (per the mockup).
///
/// Every mismatch is counted. When every prompt is matched, [onGraded] fires
/// EXACTLY once with `true` when there were zero mismatches. Auto-grades — there
/// is no Check button (the runner's footer shows "Continue" for Match).
///
/// Pure presentation: no provider reads, no navigation, no network, no
/// `dart:math`. Colours/space/shape come only from [RatelColors] / [RatelSpace]
/// / [RatelRadius] / `context.palette` + Theme text styles. Renders without
/// overflow at 360px width.
class MatchExercise extends StatefulWidget {
  const MatchExercise({
    super.key,
    required this.pairs,
    required this.onGraded,
    this.reduceMotion = false,
  });

  /// 3–5 real prompt→answer pairs projected from the CourseSpine.
  final List<MatchPair> pairs;

  /// Called ONCE when all pairs are resolved: `true` iff zero mismatches.
  final void Function(bool allCorrect) onGraded;

  /// Hard floor: no coral flash / scale animation when true.
  final bool reduceMotion;

  @override
  State<MatchExercise> createState() => _MatchExerciseState();
}

/// Which column a tile lives in.
enum _Col { prompt, answer }

class _MatchExerciseState extends State<MatchExercise> {
  /// Deterministic display order of the RIGHT column, as indices into
  /// [widget.pairs]. Built once — a plain reversal, falling back to a fixed
  /// single-step rotation only if the reversal would leave a tile aligned with
  /// its own prompt (which reversal does for the exact centre of an odd count).
  late final List<int> _rightOrder = _shuffledRight(widget.pairs.length);

  /// Pair-indices already matched + locked.
  final Set<int> _matched = <int>{};

  /// The currently selected tile, or null. Carries the column it was tapped in
  /// and the pair-index it represents.
  ({_Col col, int pair})? _selection;

  /// The pair-index currently flashing coral (a mismatched tap), or null.
  /// Both offending tiles flash. Never set when [MatchExercise.reduceMotion].
  ({int a, int b})? _wrong;

  /// Monotonic token so a stale flash-clear timer can't wipe a newer flash.
  int _wrongToken = 0;

  /// Running mismatch count → drives the final [onGraded] verdict.
  int _mismatches = 0;

  /// Guards the single [onGraded] call.
  bool _graded = false;

  static const Duration _flashDuration = Duration(milliseconds: 600);

  /// Deterministic right-column order. Reversal gives a visible shuffle for
  /// every length ≥ 2; for odd lengths the centre index maps to itself under
  /// reversal, so rotate by one to avoid a "free" aligned pair. No randomness.
  static List<int> _shuffledRight(int n) {
    if (n <= 1) {
      return <int>[for (int i = 0; i < n; i++) i];
    }
    final List<int> reversed = <int>[for (int i = n - 1; i >= 0; i--) i];
    // Reversal fixes the centre of an odd-length list (reversed[c] == c).
    if (n.isOdd) {
      return <int>[for (int i = 0; i < n; i++) reversed[(i + 1) % n]];
    }
    return reversed;
  }

  void _tap(_Col col, int pair) {
    if (_matched.contains(pair)) return; // locked tile — inert

    final ({_Col col, int pair})? sel = _selection;

    // First selection (or re-selecting after a mismatch cleared the pick).
    if (sel == null) {
      setState(() {
        _selection = (col: col, pair: pair);
        _wrong = null;
      });
      return;
    }

    // Tapping again within the same column just moves the selection.
    if (sel.col == col) {
      setState(() => _selection = (col: col, pair: pair));
      return;
    }

    // Cross-column commit.
    if (sel.pair == pair) {
      // Correct match → lock both tiles green.
      setState(() {
        _matched.add(pair);
        _selection = null;
        _wrong = null;
      });
      if (_matched.length == widget.pairs.length && !_graded) {
        _graded = true;
        widget.onGraded(_mismatches == 0);
      }
    } else {
      // Mismatch → count it, flash both offenders (unless reduce-motion), clear.
      _mismatches++;
      setState(() {
        _selection = null;
        if (!widget.reduceMotion) {
          _wrong = (a: sel.pair, b: pair);
        }
      });
      if (!widget.reduceMotion) {
        final int token = ++_wrongToken;
        Future<void>.delayed(_flashDuration, () {
          if (!mounted || token != _wrongToken) return;
          setState(() => _wrong = null);
        });
      }
    }
  }

  bool _isSelected(int pair) => _selection?.pair == pair && !_matched.contains(pair);

  bool _isWrong(int pair) {
    final ({int a, int b})? w = _wrong;
    return w != null && (w.a == pair || w.b == pair);
  }

  @override
  Widget build(BuildContext context) {
    final RatelPalette palette = context.palette;

    // Left column: prompts in authored order (pair index == list index).
    final List<Widget> left = <Widget>[
      for (int i = 0; i < widget.pairs.length; i++)
        _tile(
          context: context,
          palette: palette,
          text: widget.pairs[i].prompt,
          pair: i,
          col: _Col.prompt,
        ),
    ];

    // Right column: answers in the deterministic shuffle.
    final List<Widget> right = <Widget>[
      for (final int i in _rightOrder)
        _tile(
          context: context,
          palette: palette,
          text: widget.pairs[i].answer,
          pair: i,
          col: _Col.answer,
        ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _withGaps(left),
          ),
        ),
        const SizedBox(width: RatelSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _withGaps(right),
          ),
        ),
      ],
    );
  }

  /// Interleaves a vertical gap between column tiles (design: 11px ≈ [RatelSpace.md]).
  List<Widget> _withGaps(List<Widget> tiles) {
    final List<Widget> out = <Widget>[];
    for (int i = 0; i < tiles.length; i++) {
      if (i > 0) out.add(const SizedBox(height: RatelSpace.md));
      out.add(tiles[i]);
    }
    return out;
  }

  Widget _tile({
    required BuildContext context,
    required RatelPalette palette,
    required String text,
    required int pair,
    required _Col col,
  }) {
    final bool matched = _matched.contains(pair);
    final bool selected = _isSelected(pair);
    final bool wrong = _isWrong(pair);

    // Border / background / text colour precedence mirrors the mockup:
    // matched (green, faded) > wrong (coral) > selected (teal) > idle.
    Color border = palette.border;
    Color background = palette.white;
    Color textColor = palette.ink;

    if (matched) {
      border = RatelColors.green;
    } else if (wrong) {
      border = RatelColors.coral;
      background = RatelColors.coral.withValues(alpha: 0.12);
    } else if (selected) {
      border = RatelColors.teal;
      background = RatelColors.teal.withValues(alpha: 0.12);
      textColor = RatelColors.teal;
    }

    final Widget tile = AnimatedOpacity(
      duration: widget.reduceMotion ? Duration.zero : RatelMotion.fast,
      opacity: matched ? 0.35 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(RatelRadius.card),
          border: Border.all(color: border, width: 2.5),
          // Chunky flat drop shadow (mockup `0 3px 0`), tinted to the border.
          boxShadow: <BoxShadow>[
            BoxShadow(color: border, offset: const Offset(0, 3)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RatelSpace.md,
            vertical: RatelSpace.lg,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle())
                .copyWith(
              fontFamily: RatelFont.display,
              fontWeight: RatelType.extraBold,
              fontSize: RatelType.bodyLg,
              color: textColor,
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: !matched,
      selected: selected,
      enabled: !matched,
      label: text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: matched ? null : () => _tap(col, pair),
        child: tile,
      ),
    );
  }
}
