import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RatelScreen(
      title: 'Practice your mistakes',
      child: Center(
        key: const Key('practice-screen'),
        child: Text('Smart review', style: RatelType.headline),
      ),
    );
  }
}
