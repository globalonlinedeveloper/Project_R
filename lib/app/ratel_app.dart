import 'package:flutter/material.dart';
import '../core/design_system/design_system.dart';
import 'router.dart';

/// Root app — Material 3 + the Ratel design system + go_router IA.
class RatelApp extends StatelessWidget {
  const RatelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ratel',
      debugShowCheckedModeBanner: false,
      theme: RatelTheme.light(),
      darkTheme: RatelTheme.dark(),
      routerConfig: ratelRouter,
    );
  }
}
