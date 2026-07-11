import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart';
import 'package:ratel/services/video_relay/video_player.dart';

/// Watch (INF-9) -- the un-gated player for a Watch lesson (content `passage`,
/// kind=video). VIDEO-FIRST where the platform can render it: the lesson carries
/// a REAL pre-generated, language-neutral MP4 (its `video_ref` -> a `media_asset`
/// uri on R2), embedded via [videoRelayProvider] (a browser `<video controls>`
/// on web). It always renders the transcript (the resolved narration sentences),
/// and where the video surface is unavailable (non-web/tests) it degrades
/// HONESTLY to a poster + the transcript + the optional browser read-aloud
/// ([speechTtsProvider]). Then the comprehension checks (the passage's
/// `check_item_refs`, graded exactly like the runner grades them). [R-D5 - R-B3]
class WatchPlayerScreen extends ConsumerStatefulWidget {
  const WatchPlayerScreen({super.key, required this.passageId});

  /// The content `passage_id` to play, threaded from the Watch list.
  final String? passageId;

  @override
  ConsumerState<WatchPlayerScreen> createState() => _WatchPlayerScreenState();
}

class _WatchPlayerScreenState extends ConsumerState<WatchPlayerScreen> {
  AudioHandle? _voice; // the browser read-aloud fallback (off-web)

  @override
  void dispose() {
    _voice?.dispose();
    super.dispose();
  }

  CourseStory? _find(CourseSpine spine) {
    for (final CourseStory p in spine.watch) {
      if (p.id == widget.passageId) return p;
    }
    return null;
  }

  Future<void> _readAloud(String text) async {
    final SpeechTts tts = ref.read(speechTtsProvider);
    if (!tts.isAvailable || text.isEmpty) return;
    _voice?.dispose();
    _voice = tts.handleFor(text, lang: 'en');
    try {
      await _voice!.play();
    } catch (_) {
      // Honest degrade: a failed voice backend never blocks reading.
    }
  }

  @override
  Widget build(BuildContext context) {
    final CourseSpine spine = ref.watch(courseSpineProvider);
    final CourseStory? watch = _find(spine);
    final VideoRelay video = ref.watch(videoRelayProvider);
    final bool canPlay = watch?.videoUrl != null && video.isAvailable;
    final bool canRead = ref.watch(speechTtsProvider).isAvailable;

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
          watch?.title ?? 'Watch',
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
      body: watch == null
          ? _notFound(context)
          : ListView(
              padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                  RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    RatelChip.level(watch.cefr),
                    if (watch.theme != null &&
                        watch.theme!.isNotEmpty) ...<Widget>[
                      const SizedBox(width: RatelSpace.sm),
                      Expanded(
                        child: Text(
                          watch.theme!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: RatelFont.body,
                              fontSize: RatelType.small,
                              color: context.palette.muted),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: RatelSpace.md),
                // VIDEO-FIRST: the real MP4 where the platform can render it;
                // otherwise the honest poster + transcript + read-aloud fallback.
                ClipRRect(
                  borderRadius: BorderRadius.circular(RatelRadius.chip),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: canPlay
                        ? KeyedSubtree(
                            key: const ValueKey<String>('watch-video'),
                            child: video.viewFor(watch.videoUrl!),
                          )
                        : _poster(context),
                  ),
                ),
                if (!canPlay && canRead)
                  Padding(
                    padding: const EdgeInsets.only(top: RatelSpace.md),
                    child: RatelButton(
                      key: const ValueKey<String>('watch-read-aloud'),
                      label: 'Read aloud',
                      variant: RatelButtonVariant.secondary,
                      expand: false,
                      leading: const Text('🔊', style: TextStyle(fontSize: 18)),
                      onPressed: () => _readAloud(watch.sentences.join(' ')),
                    ),
                  ),
                const SizedBox(height: RatelSpace.md),
                const RatelSectionHeader(label: 'Transcript'),
                const SizedBox(height: RatelSpace.sm),
                RatelCard(
                  child: Column(
                    key: const ValueKey<String>('watch-body'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (final String line in watch.sentences)
                        Padding(
                          padding: const EdgeInsets.only(bottom: RatelSpace.sm),
                          child: Text(
                            line,
                            style: TextStyle(
                              fontFamily: RatelFont.body,
                              fontSize: RatelType.bodyLg,
                              height: 1.5,
                              color: context.palette.ink,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (watch.checkExercises.isNotEmpty) ...<Widget>[
                  const SizedBox(height: RatelSpace.lg),
                  const RatelSectionHeader(label: 'Check understanding'),
                  const SizedBox(height: RatelSpace.sm),
                  for (final CourseExercise e in watch.checkExercises)
                    Padding(
                      padding: const EdgeInsets.only(bottom: RatelSpace.cardGap),
                      child: _CheckQuestion(exercise: e),
                    ),
                ],
              ],
            ),
    );
  }

  /// Honest poster shown where the video surface is unavailable (non-web/tests):
  /// the learner still reads the transcript + answers the checks below.
  Widget _poster(BuildContext context) => Container(
        key: const ValueKey<String>('watch-poster'),
        color: RatelColors.ink,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('🎬', style: TextStyle(fontSize: 44)),
            const SizedBox(height: RatelSpace.sm),
            Text(
              'Video plays in the web app',
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: RatelColors.onColor),
            ),
          ],
        ),
      );

  Widget _notFound(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpace.xl),
          child: Text(
            'This video is not available.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.bodyLg,
                color: context.palette.muted),
          ),
        ),
      );
}

/// One comprehension check for a Watch lesson: an authored MCQ (tap an option ->
/// graded by `is_correct`, with "Explain this") or, when the check carries no
/// option bank, a typed answer graded against `accepted` under the same
/// fold-case normalization the runner uses. Identical to the Podcasts/Stories
/// check widget; self-contained + deterministic; no live AI.
class _CheckQuestion extends StatefulWidget {
  const _CheckQuestion({required this.exercise});

  final CourseExercise exercise;

  @override
  State<_CheckQuestion> createState() => _CheckQuestionState();
}

class _CheckQuestionState extends State<_CheckQuestion> {
  int? _picked;
  bool? _correct;
  bool _showExplain = false;
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isMcq => widget.exercise.options.isNotEmpty;

  void _gradeMcq(int i) {
    setState(() {
      _picked = i;
      _correct = widget.exercise.options[i].isCorrect;
    });
  }

  void _gradeTyped() {
    final String input = _ctrl.text.trim();
    if (input.isEmpty) return;
    final bool fold = widget.exercise.foldCase;
    final String norm = fold ? input.toLowerCase() : input;
    bool ok = false;
    for (final String a in widget.exercise.accepted) {
      final String an = fold ? a.trim().toLowerCase() : a.trim();
      if (an == norm) {
        ok = true;
        break;
      }
    }
    setState(() => _correct = ok);
  }

  @override
  Widget build(BuildContext context) {
    final CourseExercise e = widget.exercise;
    final String? explain = e.options.isNotEmpty && _picked != null
        ? e.options[_picked!].explain ?? e.explain
        : e.explain;
    return RatelCard(
      child: Column(
        key: ValueKey<String>('watch-check-${e.id}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            e.prompt,
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                fontSize: RatelType.bodyLg,
                color: context.palette.ink),
          ),
          const SizedBox(height: RatelSpace.sm),
          if (_isMcq)
            for (int i = 0; i < e.options.length; i++) _option(context, e, i)
          else ...<Widget>[
            TextField(
              key: ValueKey<String>('watch-check-input-${e.id}'),
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: 'Type your answer',
                filled: true,
                fillColor: context.palette.cream2,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: RatelSpace.sm),
            RatelButton(
              label: 'Check',
              expand: false,
              onPressed: _gradeTyped,
            ),
          ],
          if (_correct != null) ...<Widget>[
            const SizedBox(height: RatelSpace.sm),
            Text(
              _correct! ? '✓ Nicely done!' : '✕ Not quite',
              style: TextStyle(
                  fontFamily: RatelFont.display,
                  fontWeight: RatelType.extraBold,
                  fontSize: RatelType.bodyLg,
                  color: _correct! ? RatelColors.green : RatelColors.coral),
            ),
            if (explain != null && explain.isNotEmpty) ...<Widget>[
              const SizedBox(height: RatelSpace.xs),
              GestureDetector(
                key: ValueKey<String>('watch-explain-toggle-${e.id}'),
                onTap: () => setState(() => _showExplain = !_showExplain),
                child: Text(
                  '💡 Explain this',
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontWeight: RatelType.extraBold,
                      fontSize: RatelType.small,
                      color: RatelColors.teal),
                ),
              ),
              if (_showExplain) ...<Widget>[
                const SizedBox(height: RatelSpace.xs),
                Text(
                  explain,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      height: 1.4,
                      color: context.palette.muted),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }

  Widget _option(BuildContext context, CourseExercise e, int i) {
    final CourseOption o = e.options[i];
    final bool decided = _picked != null;
    final bool isPick = _picked == i;
    Color bg = context.palette.cream2;
    Color line = context.palette.border;
    if (decided && (isPick || o.isCorrect)) {
      final Color c = o.isCorrect ? RatelColors.green : RatelColors.coral;
      bg = c.withValues(alpha: 0.12);
      line = c;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: RatelSpace.xs),
      child: GestureDetector(
        key: ValueKey<String>('watch-opt-${e.id}-$i'),
        onTap: decided ? null : () => _gradeMcq(i),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(RatelSpace.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(RatelRadius.chip),
            border: Border.all(color: line),
          ),
          child: Text(
            o.text,
            style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.bodyLg,
                color: context.palette.ink),
          ),
        ),
      ),
    );
  }
}
