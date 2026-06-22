import 'package:flutter/material.dart';
import 'core/design_system/design_system.dart';

/// RATEL — app entrypoint. Routed through the Stage-2 design system; the real
/// core-loop shell replaces [BootScreen] in a later increment.
void main() => runApp(const RatelApp());

class RatelApp extends StatelessWidget {
  const RatelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ratel',
      debugShowCheckedModeBanner: false,
      theme: RatelTheme.light(),
      darkTheme: RatelTheme.dark(),
      home: const BootScreen(),
    );
  }
}

/// Placeholder home shown until the Stage-2 core loop replaces it.
class BootScreen extends StatelessWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Ratel', key: Key('boot-marker')),
      ),
    );
  }
}
