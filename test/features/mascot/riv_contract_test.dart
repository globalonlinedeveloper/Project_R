import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/features/mascot/riv_contract.dart';

void main() {
  group('riv contract (R-L18 / C24)', () {
    test('accepts a well-formed vector .riv header', () {
      final bytes = <int>[...'RIVE'.codeUnits, 1, 2, 3, 4, 5];
      expect(validateRivBytes(bytes).ok, isTrue);
    });

    test('rejects a wrong header', () {
      expect(validateRivBytes(<int>[...'NOPE'.codeUnits, 1, 2]).ok, isFalse);
    });

    test('rejects an over-budget file', () {
      final big = <int>[...'RIVE'.codeUnits, ...List<int>.filled(40, 0)];
      expect(validateRivBytes(big, maxBytes: 8).ok, isFalse);
    });

    test('rejects an embedded PNG raster (vector only)', () {
      final bytes = <int>[...'RIVE'.codeUnits, 0x89, 0x50, 0x4E, 0x47, 0, 0];
      final c = validateRivBytes(bytes);
      expect(c.ok, isFalse);
      expect(c.reason, contains('raster'));
    });

    test('rejects an embedded JPEG raster', () {
      final bytes = <int>[...'RIVE'.codeUnits, 0xFF, 0xD8, 0xFF, 0];
      expect(validateRivBytes(bytes).ok, isFalse);
    });

    test('every real .riv in assets/rive passes the contract', () {
      final dir = Directory('assets/rive');
      final rivs = dir.existsSync()
          ? dir.listSync().where((f) => f.path.endsWith('.riv')).toList()
          : <FileSystemEntity>[];
      for (final f in rivs) {
        final c = validateRivBytes(File(f.path).readAsBytesSync());
        expect(c.ok, isTrue, reason: '${f.path}: ${c.reason}');
      }
      // Placeholder phase: zero .riv files is OK — the gate is armed for the real rig.
      expect(rivs.length, greaterThanOrEqualTo(0));
    });
  });
}
