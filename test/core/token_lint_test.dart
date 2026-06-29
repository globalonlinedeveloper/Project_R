import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Design-token charter (spec §2): raw color literals may live ONLY in
/// lib/core/theme. Every component / screen / shell must reference [RatelColors]
/// tokens. This test fails the build if a raw `Color(0x…)`, `Color.fromARGB/RGBO`
/// or a `Colors.<name>` (except `Colors.transparent`) appears anywhere under
/// lib/ outside lib/core/theme/. Comments are ignored.
void main() {
  test('no raw color literals outside lib/core/theme', () {
    final Directory lib = Directory('lib');
    expect(lib.existsSync(), isTrue, reason: 'run from the package root');

    const String allowed = 'lib/core/theme/';
    final RegExp hex = RegExp(r'Color\(0x');
    final RegExp ctor = RegExp(r'Color\.from(ARGB|RGBO)\(');
    final RegExp colors = RegExp(r'\bColors\.(?!transparent\b)[A-Za-z]');

    final List<String> offenders = <String>[];
    for (final FileSystemEntity e in lib.listSync(recursive: true)) {
      if (e is! File || !e.path.endsWith('.dart')) continue;
      final String norm = e.path.replaceAll(r'\', '/');
      if (norm.startsWith(allowed)) continue;
      final List<String> lines = e.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        final String line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (hex.hasMatch(line) || ctor.hasMatch(line) || colors.hasMatch(line)) {
          offenders.add('$norm:${i + 1}: ${line.trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Raw color literals must live only in lib/core/theme/tokens.dart. '
          'Use RatelColors tokens instead:\n${offenders.join('\n')}',
    );
  });
}
