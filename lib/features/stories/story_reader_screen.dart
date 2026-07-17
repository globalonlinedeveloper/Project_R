import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/common/content_unavailable_card.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/library/last_read_controller.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart';

/// Read & Listen — the un-gated reading surface for a graded story (content
/// `passage`, kind=story), INF-6. TEXT-FIRST: it renders the resolved passage
/// sentences, an OPTIONAL browser read-aloud (client SpeechSynthesis via
/// [speechTtsProvider] — shown ONLY when available, degrading honestly on
/// non-web/tests exactly like the Listen exercise), then the comprehension
/// checks (the passage's `check_item_refs`, graded the same way the runner
/// grades them: MCQ by authored `is_correct`, typed against `accepted`).
///
/// HONESTY: `audio_ref` is null today, so nothing pretends to stream
/// pre-generated audio; the browser voice is the only audio source and it is
/// offered only where the platform provides it. Real pre-generated audio/video
/// stays the owner-gated media piece (§3d). [R-D5 · R-B3 · R-B4]
class StoryReaderScreen extends ConsumerStatefulWidget {
  const StoryReaderScreen({super.key, required this.passageId});

  /// The content `passage_id` to read, threaded from the Stories list.
  final String? passageId;

  @override
  ConsumerState<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends ConsumerState<StoryReaderScreen> {
  AudioHandle? _handle;

  /// Guards the resume-pointer write to fire at most ONCE per mount
  /// (s163 INC-C2) — recording is a side effect of opening, not of
  /// every rebuild.
  bool _recorded = false;

  @override
  void dispose() {
    _handle?.dispose();
    super.dispose();
  }

  /// Resolve the story to read. INC-7 graceful default (DESIGN_VS_LIVE §S):
  ///
  ///  * exact `passageId` match -> that authored story (the Stories LIST always
  ///    threads an explicit `?passage=<id>`, so normal navigation is unchanged);
  ///  * COLD nav (`passageId == null`, e.g. a bare `/story` deep-link) OR an
  ///    explicit id that is not in the loaded spine -> the FIRST authored story
  ///    (deterministic: authored spine order), so the surface opens a REAL story
  ///    instead of a dead-end;
  ///  * only when the spine authors NO stories at all does this return null, so
  ///    the caller renders the honest [ContentUnavailableCard] -- the "no
  ///    content" state stays reserved for a genuinely empty course.
  CourseStory? _resolve(CourseSpine spine) {
    if (spine.stories.isEmpty) return null;
    for (final CourseStory s in spine.stories) {
      if (s.id == widget.passageId) return s;
    }
    return spine.stories.first;
  }

  Future<void> _readAloud(String text) async {
    final SpeechTts tts = ref.read(speechTtsProvider);
    if (!tts.isAvailable || text.isEmpty) return;
    _handle?.dispose();
    _handle = tts.handleFor(text, lang: 'en');
    try {
      await _handle!.play();
    } catch (_) {
      // Honest degrade: a failed voice backend never blocks reading.
    }
  }

  @override
  Widget build(BuildContext context) {
    final CourseSpine spine = ref.watch(courseSpineProvider);
    final CourseStory? story = _resolve(spine);
    final bool canRead = ref.watch(speechTtsProvider).isAvailable;

    // s163 INC-C2 — record the device-local resume pointer ONCE per mount,
    // and ONLY for a REAL resolved story (never the ContentUnavailableCard
    // path). Post-frame so it never mutates a provider mid-build. We store no
    // progress %/offset — reopen-to-story is the honest scope.
    if (story != null && !_recorded) {
      _recorded = true;
      final CourseStory opened = story;
      final String courseCode = spine.courseCode;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(lastReadControllerProvider.notifier).record(
              LastReadRef(
                courseCode: courseCode,
                passageId: opened.id,
                title: opened.title,
                cefr: opened.cefr,
                kind: 'story',
              ),
            );
      });
    }

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
          story?.title ?? context.l10n.storyFallbackTitle,
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
      body: story == null
          ? const ContentUnavailableCard(noun: 'story')
          : ListView(
              padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                  RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    RatelChip.level(story.cefr),
                    if (story.theme != null && story.theme!.isNotEmpty) ...<Widget>[
                      const SizedBox(width: RatelSpace.sm),
                      Expanded(
                        child: Text(
                          story.theme!,
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
                if (canRead)
                  Padding(
                    padding: const EdgeInsets.only(bottom: RatelSpace.md),
                    child: RatelButton(
                      key: const ValueKey<String>('story-read-aloud'),
                      label: context.l10n.mediaReadAloud,
                      variant: RatelButtonVariant.secondary,
                      expand: false,
                      leading: const Text('🔊', style: TextStyle(fontSize: 18)),
                      onPressed: () => _readAloud(story.sentences.join(' ')),
                    ),
                  ),
                RatelCard(
                  child: Column(
                    key: const ValueKey<String>('story-body'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (final String line in story.sentences)
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
                if (story.checkExercises.isNotEmpty) ...<Widget>[
                  const SizedBox(height: RatelSpace.lg),
                  RatelSectionHeader(label: context.l10n.mediaCheckUnderstanding),
                  const SizedBox(height: RatelSpace.sm),
                  for (final CourseExercise e in story.checkExercises)
                    Padding(
                      padding: const EdgeInsets.only(bottom: RatelSpace.cardGap),
                      child: _CheckQuestion(exercise: e),
                    ),
                ],
              ],
            ),
    );
  }

}

/// One comprehension check for a story: an authored MCQ (tap an option → graded
/// by `is_correct`, with "Explain this") or, when the check carries no option
/// bank, a typed answer graded against `accepted` under the same fold-case
/// normalization the runner uses. Self-contained + deterministic; no live AI.
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
        key: ValueKey<String>('story-check-${e.id}'),
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
              key: ValueKey<String>('story-check-input-${e.id}'),
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: context.l10n.lessonTypeAnswerHint,
                filled: true,
                fillColor: context.palette.cream2,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: RatelSpace.sm),
            RatelButton(
              label: context.l10n.lessonCheck,
              expand: false,
              onPressed: _gradeTyped,
            ),
          ],
          if (_correct != null) ...<Widget>[
            const SizedBox(height: RatelSpace.sm),
            Text(
              _correct! ? context.l10n.lessonNicelyDone : context.l10n.lessonNotQuite,
              style: TextStyle(
                  fontFamily: RatelFont.display,
                  fontWeight: RatelType.extraBold,
                  fontSize: RatelType.bodyLg,
                  color: _correct! ? RatelColors.green : RatelColors.coral),
            ),
            if (explain != null && explain.isNotEmpty) ...<Widget>[
              const SizedBox(height: RatelSpace.xs),
              GestureDetector(
                key: ValueKey<String>('story-explain-toggle-${e.id}'),
                onTap: () => setState(() => _showExplain = !_showExplain),
                child: Text(
                  context.l10n.lessonExplainThis,
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
        key: ValueKey<String>('story-opt-${e.id}-$i'),
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
