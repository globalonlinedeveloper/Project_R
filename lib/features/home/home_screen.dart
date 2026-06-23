import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';

/// Learn tab home. The real streak/continue surface lands next (R-L4/L8);
/// this slice gives a real entry into the lesson runner (R-L3).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RatelScreen(
      title: 'Learn',
      child: ListView(
        key: const Key('home-screen'),
        children: [
          const SizedBox(height: RatelSpacing.sm),
          Text('Your lessons', style: RatelType.headline),
          const SizedBox(height: RatelSpacing.lg),
          RatelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily lesson', style: RatelType.title),
                const SizedBox(height: RatelSpacing.xs),
                Text(
                  'A few quick exercises to keep your streak going.',
                  style: RatelType.body,
                ),
                const SizedBox(height: RatelSpacing.lg),
                RatelButton(
                  label: 'Start lesson',
                  icon: Icons.play_arrow_rounded,
                  expand: true,
                  onPressed: () => context.push('/lesson'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
