import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

class AdventuresScreen extends StatelessWidget {
  const AdventuresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RatelScreen(
      title: 'Adventures',
      child: Center(
        key: const Key('adventures-screen'),
        child: Text('Explore', style: RatelType.headline),
      ),
    );
  }
}
