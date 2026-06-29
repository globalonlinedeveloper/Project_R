import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';

/// Onboarding wizard (design spec §4.11): Welcome → Language → Reason → Goal →
/// Placement. Captures the learner's stated choices and wires the REAL engines:
/// the daily goal persists through the `preferences` store, "I'm brand new"
/// cold-starts the learner at A1 (the real cold_start anchor via
/// [LearnerController.reset]), and the placement-test branch hands off to the
/// adaptive CAT quiz at `/placement`. A fresh install is a GUEST (the default
/// identity) — "try without an account" simply proceeds; "I already have an
/// account" routes to the (coming) login screen. NOTE: the active course is
/// engine-fixed to `es` today (no multi-course setter yet) — the language
/// choice is captured for personalisation only; a course-picker is a flagged
/// follow-up, never faked.
///
/// Requirements: R-L2 (onboarding flow: language → motivation → goal →
/// placement → first win), R-G7 (cold-start works from day one — the
/// brand-new path), R-I7 (daily goal), R-G4 (CAT placement-test entry).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _Language {
  const _Language(this.name, this.flag);
  final String name;
  final String flag;
}

class _Reason {
  const _Reason(this.emoji, this.label);
  final String emoji;
  final String label;
}

class _Goal {
  const _Goal(this.label, this.xp);
  final String label;
  final int xp;
}

const List<_Language> _kLanguages = <_Language>[
  _Language('Spanish', '🇪🇸'),
  _Language('French', '🇫🇷'),
  _Language('Japanese', '🇯🇵'),
  _Language('Tamil', '🇮🇳'),
  _Language('German', '🇩🇪'),
  _Language('Korean', '🇰🇷'),
];

const List<_Reason> _kReasons = <_Reason>[
  _Reason('✈️', 'Travel'),
  _Reason('🎭', 'Culture'),
  _Reason('💼', 'Career'),
  _Reason('👥', 'Family & friends'),
  _Reason('🧠', 'Brain training'),
  _Reason('🎮', 'Just for fun'),
];

const List<_Goal> _kGoals = <_Goal>[
  _Goal('Casual', 10),
  _Goal('Regular', 20),
  _Goal('Serious', 30),
  _Goal('Intense', 50),
];

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _kSteps = 5;

  int _step = 0;
  String _language = 'Spanish';
  String? _reason;
  int _goalXp = 20;
  bool _placementTest = true; // design default = "Take a placement test"

  void _next() => setState(() => _step++);
  void _back() => setState(() => _step--);

  void _finishBrandNew() {
    // Persist the chosen daily goal through the REAL preferences engine.
    ref.read(appSettingsControllerProvider.notifier).setDailyGoal(_goalXp);
    // "Start from the very beginning" = the real A1 cold-start.
    ref.read(learnerControllerProvider.notifier).reset();
    context.go('/home');
  }

  void _startPlacement() {
    ref.read(appSettingsControllerProvider.notifier).setDailyGoal(_goalXp);
    // Hand off to the adaptive CAT placement quiz, which seeds θ then routes
    // home (see /placement).
    context.push('/placement');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: RatelSpace.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: RatelSpace.md),
              _header(),
              const SizedBox(height: RatelSpace.lg),
              Expanded(child: _body()),
              _cta(),
              const SizedBox(height: RatelSpace.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 40,
          child: _step > 0
              ? GestureDetector(
                  onTap: _back,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(RatelIcons.arrowBack, color: context.palette.ink),
                  ),
                )
              : null,
        ),
        Expanded(
          child: RatelProgressBar(
            value: (_step + 1) / _kSteps,
            color: RatelColors.teal,
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _body() {
    switch (_step) {
      case 0:
        return _welcome();
      case 1:
        return _languageStep();
      case 2:
        return _reasonStep();
      case 3:
        return _goalStep();
      default:
        return _placementStep();
    }
  }

  Widget _cta() {
    String label = 'Continue';
    VoidCallback onPressed = _next;
    if (_step == 0) {
      label = 'Get started';
    } else if (_step == 4) {
      label = 'Start learning';
      onPressed = _placementTest ? _startPlacement : _finishBrandNew;
    }
    return RatelButton(label: label, onPressed: onPressed);
  }

  Widget _title(String text, {bool center = false}) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontFamily: RatelFont.display,
        fontWeight: RatelType.extraBold,
        fontSize: RatelType.screenTitle,
        color: context.palette.ink,
      ),
    );
  }

  Widget _subtitle(String text, {bool center = false}) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontFamily: RatelFont.body,
        fontSize: RatelType.body,
        color: context.palette.muted,
      ),
    );
  }

  Widget _welcome() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(height: RatelSpace.xl),
          const Text('🦡', style: TextStyle(fontSize: 96)),
          const SizedBox(height: RatelSpace.lg),
          Text(
            "Hi, I'm Ratel!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: RatelFont.display,
              fontWeight: RatelType.extraBold,
              fontSize: RatelType.hero,
              color: context.palette.ink,
            ),
          ),
          const SizedBox(height: RatelSpace.md),
          Text(
            'Learn a language the fearless way — bite-sized, fun, and free. '
            'Ready to dig in?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: RatelFont.body,
              fontSize: RatelType.bodyLg,
              color: context.palette.muted,
            ),
          ),
          const SizedBox(height: RatelSpace.xl),
          TextButton(
            onPressed: () => context.push('/login'),
            child: const Text(
              'I already have an account',
              style: TextStyle(
                fontFamily: RatelFont.body,
                fontWeight: RatelType.semiBold,
                color: RatelColors.teal,
              ),
            ),
          ),
          TextButton(
            onPressed: _next,
            child: Text(
              'Try without an account →',
              style: TextStyle(
                fontFamily: RatelFont.body,
                color: context.palette.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _title('What do you want to learn?'),
        const SizedBox(height: RatelSpace.xs),
        _subtitle('52 languages available'),
        const SizedBox(height: RatelSpace.lg),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: RatelSpace.cardGap,
            crossAxisSpacing: RatelSpace.cardGap,
            childAspectRatio: 2.4,
            children: <Widget>[
              for (final _Language l in _kLanguages)
                RatelOptionCard(
                  emoji: l.flag,
                  label: l.name,
                  state: _language == l.name
                      ? RatelOptionState.selected
                      : RatelOptionState.idle,
                  onTap: () => setState(() => _language = l.name),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reasonStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _title('Why are you learning?'),
        const SizedBox(height: RatelSpace.lg),
        Expanded(
          child: ListView(
            children: <Widget>[
              for (final _Reason r in _kReasons) ...<Widget>[
                RatelOptionCard(
                  emoji: r.emoji,
                  label: r.label,
                  state: _reason == r.label
                      ? RatelOptionState.selected
                      : RatelOptionState.idle,
                  onTap: () => setState(() => _reason = r.label),
                ),
                const SizedBox(height: RatelSpace.cardGap),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _goalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _title('Pick a daily goal'),
        const SizedBox(height: RatelSpace.lg),
        Expanded(
          child: ListView(
            children: <Widget>[
              for (final _Goal g in _kGoals) ...<Widget>[
                _GoalRow(
                  label: g.label,
                  xp: g.xp,
                  selected: _goalXp == g.xp,
                  onTap: () => setState(() => _goalXp = g.xp),
                ),
                const SizedBox(height: RatelSpace.cardGap),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _placementStep() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(height: RatelSpace.lg),
          const Text('🧭', style: TextStyle(fontSize: 72)),
          const SizedBox(height: RatelSpace.lg),
          _title('Find your starting point', center: true),
          const SizedBox(height: RatelSpace.sm),
          _subtitle(
            'New to $_language, or do you know some already?',
            center: true,
          ),
          const SizedBox(height: RatelSpace.lg),
          _ChoiceCard(
            emoji: '🌱',
            title: "I'm brand new",
            subtitle: 'Start from the very beginning',
            selected: !_placementTest,
            onTap: () => setState(() => _placementTest = false),
          ),
          const SizedBox(height: RatelSpace.cardGap),
          _ChoiceCard(
            emoji: '📊',
            title: 'Take a placement test',
            subtitle: '~3 min · skip ahead to your level',
            selected: _placementTest,
            onTap: () => setState(() => _placementTest = true),
          ),
        ],
      ),
    );
  }
}

/// A selectable daily-goal row: label on the left, XP/day on the right, with a
/// teal selection border (design spec §4.11 goal step).
class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.label,
    required this.xp,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int xp;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RatelSpace.lg,
          vertical: RatelSpace.lg,
        ),
        decoration: BoxDecoration(
          color: context.palette.white,
          borderRadius: BorderRadius.circular(RatelRadius.card),
          border: Border.all(
            color: selected ? RatelColors.teal : context.palette.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.semiBold,
                fontSize: RatelType.cardTitle,
                color: context.palette.ink,
              ),
            ),
            const Spacer(),
            Text(
              '$xp XP / day',
              style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.body,
                color: context.palette.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A selectable placement choice card (emoji + title + subtitle) with a teal
/// selection border (design spec §4.11 placement step).
class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(RatelSpace.lg),
        decoration: BoxDecoration(
          color: context.palette.white,
          borderRadius: BorderRadius.circular(RatelRadius.card),
          border: Border.all(
            color: selected ? RatelColors.teal : context.palette.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: RatelFont.display,
                      fontWeight: RatelType.semiBold,
                      fontSize: RatelType.cardTitle,
                      color: context.palette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      color: context.palette.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
