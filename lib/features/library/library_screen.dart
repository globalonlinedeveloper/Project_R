import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/foundation_tab.dart';

/// Library tab (📚) — content catalog (design spec §4.2). Foundation placeholder.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const FoundationTab(
      key: ValueKey<String>('tab-library'),
      title: 'Library',
      topBar: RatelTopBar(flagEmoji: '🇪🇸', langCode: 'ES'),
      note: Text('Lessons, stories & the practice hub are built in P2.'),
    );
  }
}
