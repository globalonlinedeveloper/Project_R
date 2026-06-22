import 'package:flutter/material.dart';
import '../context_ext.dart';
import '../tokens/ratel_spacing.dart';
import '../tokens/ratel_typography.dart';

/// Screen scaffold that centers content within [RatelSpacing.maxContentWidth]
/// (beachhead phones first; graceful on tablet/desktop) with safe-area padding.
class RatelScreen extends StatelessWidget {
  const RatelScreen({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.leading,
    this.padding,
    this.bottomBar,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.surface,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!, style: RatelType.title),
              backgroundColor: t.surface,
              foregroundColor: t.onSurface,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: leading,
              actions: actions,
            ),
      bottomNavigationBar: bottomBar,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: RatelSpacing.maxContentWidth),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(RatelSpacing.lg),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
