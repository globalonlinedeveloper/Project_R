import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// R-N6 token-lint: screen code in `lib/features` (and `lib/app`) must consume
/// design tokens, never raw color/motion literals. The design_system folder is
/// the only sanctioned home for those literals. Guards every Stage-2 screen.
void main() {
  test('no raw color/motion literals in lib/features or lib/app', () {
    const dirs = ['lib/features', 'lib/app'];
    final patterns = <RegExp>[
      RegExp(r'Color\(0x'),
      RegExp(r'\bColors\.'),
      RegExp(r'\bDuration\('),
      RegExp(r'\bCurves\.'),
      RegExp(r'\bCubic\('),
    ];
    final offenders = <String>[];
    for (final d in dirs) {
      final dir = Directory(d);
      if (!dir.existsSync()) continue;
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.path.endsWith('.g.dart') ||
            entity.path.endsWith('.freezed.dart')) {
          continue;
        }
        final src = entity.readAsStringSync();
        for (final p in patterns) {
          if (p.hasMatch(src)) offenders.add('${entity.path} :: ${p.pattern}');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason: 'Move these to design tokens (R-N6):\n${offenders.join('\n')}',
    );
  });
}
