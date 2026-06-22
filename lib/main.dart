import 'package:flutter/material.dart';

/// RATEL — app entrypoint (Stage-1 genesis shell).
/// The modern design system + real screens are built fresh in Stage 2;
/// this is the minimal bootable shell that the CI gate validates.
void main() => runApp(const RatelApp());

class RatelApp extends StatelessWidget {
  const RatelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ratel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E7D32),
      ),
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
