import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/learner/learner_controller.dart';

import 'router.dart';

/// Root app — Material 3 with the Ratel theme, driven by the [routerProvider]
/// shell.
///
/// A [WidgetsBindingObserver] refreshes the day-scoped learner surfaces (the
/// goal-gated streak's lapse + the xpToday reset) whenever the app returns to
/// the foreground: those values are derived against the wall clock, but a
/// cached snapshot only recomputes on a mutation/rebuild, so a session left
/// open across local midnight would otherwise show yesterday's streak/XP until
/// the next interaction. (Stateful so it can own the observer; `const` so the
/// existing boot tests' `const RatelApp()` keep compiling.)
class RatelApp extends ConsumerStatefulWidget {
  const RatelApp({super.key});

  @override
  ConsumerState<RatelApp> createState() => _RatelAppState();
}

class _RatelAppState extends ConsumerState<RatelApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(learnerControllerProvider.notifier).refreshDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Ratel',
      debugShowCheckedModeBanner: false,
      theme: RatelTheme.light(),
      routerConfig: router,
    );
  }
}
