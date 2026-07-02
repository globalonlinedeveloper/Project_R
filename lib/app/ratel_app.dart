import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'app_providers.dart';
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
    // Registry-driven world theme (WS3): light/galaxy keep their hand-tuned
    // builders; the other 29 design worlds build from their ported palette via
    // RatelTheme.world(). Galaxy (space) also paints the app-wide starfield.
    final ThemeWorld world = ref.watch(activeWorldProvider);
    final bool isLight = world.id == 'light';
    final bool space = world.id == 'galaxy';
    final bool hasBackdrop = kBackdropPainters.containsKey(world.backdrop);
    final ThemeData lightTheme = isLight
        ? RatelTheme.light()
        : space
            ? RatelTheme.space()
            : RatelTheme.world(world);
    final ThemeData darkTheme = isLight
        ? RatelTheme.dark()
        : space
            ? RatelTheme.space()
            : RatelTheme.world(world);
    return MaterialApp.router(
      title: 'Ratel',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        // Reduce-motion (HABITS · §4.9): honor the persisted toggle app-wide,
        // with the OS reduce-motion setting as a hard floor on top.
        final MediaQueryData mq = MediaQuery.of(context);
        final Widget content = MediaQuery(
          data: mq.copyWith(
              disableAnimations:
                  mq.disableAnimations || ref.watch(reduceMotionProvider)),
          // Backdrop worlds paint their animated field behind the app (the
          // R-WT1 per-theme painter layer, wired live from the registry); it
          // lives INSIDE this MediaQuery so WorldBackdrop honors the combined
          // reduce-motion floor (OS setting OR the in-app toggle).
          child: hasBackdrop
              ? WorldBackdrop(
                  world: world, child: child ?? const SizedBox.shrink())
              : (child ?? const SizedBox.shrink()),
        );
        // Galaxy ('stars') now has a registered animated painter, so it
        // renders through the generic `WorldBackdrop` path above -- like every
        // other world, no special-case starfield Stack. `RatelTheme.space()`
        // keeps its hand-tuned translucent chrome (spaceBg alpha 0.80) so the
        // animated field shows through. `StarfieldPainter` is retained as the
        // reduce-motion static fallback frame (painted by WorldBackdrop at t=0).
        return content;
      },
    );
  }
}
