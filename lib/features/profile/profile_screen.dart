import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RatelScreen(
      title: 'Profile',
      child: Center(
        key: const Key('profile-screen'),
        child: Text('You', style: RatelType.headline),
      ),
    );
  }
}
