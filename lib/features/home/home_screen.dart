import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RatelScreen(
      title: 'Learn',
      child: Center(
        key: const Key('home-screen'),
        child: Text('Your lessons', style: RatelType.headline),
      ),
    );
  }
}
