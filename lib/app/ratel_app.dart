import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';

import 'router.dart';

/// Root app — Material 3 with the Ratel theme, driven by the [routerProvider]
/// shell. (`ConsumerWidget` so the theme can later react to settings such as
/// high-contrast.)
class RatelApp extends ConsumerWidget {
  const RatelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Ratel',
      debugShowCheckedModeBanner: false,
      theme: RatelTheme.light(),
      routerConfig: router,
    );
  }
}
