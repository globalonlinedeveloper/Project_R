import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/design_system/design_system.dart';

void main() {
  test('contrastRatio sanity: black on white == 21', () {
    expect(
      contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21.0, 0.1),
    );
  });

  void checkScheme(String name, RatelColorTokens t) {
    final pairs = <String, List<Color>>{
      'onSurface/surface': [t.onSurface, t.surface],
      'onSurfaceVariant/surface': [t.onSurfaceVariant, t.surface],
      'onSurface/surfaceVariant': [t.onSurface, t.surfaceVariant],
      'onPrimary/primary': [t.onPrimary, t.primary],
      'onAccent/accent': [t.onAccent, t.accent],
      'onSuccess/success': [t.onSuccess, t.success],
      'onDanger/danger': [t.onDanger, t.danger],
    };
    pairs.forEach((label, c) {
      final ratio = contrastRatio(c[0], c[1]);
      expect(
        ratio,
        greaterThanOrEqualTo(kAaNormalText),
        reason: '$name $label contrast ${ratio.toStringAsFixed(2)} < $kAaNormalText',
      );
    });
  }

  test('light tokens meet WCAG 2.2 AA normal-text contrast (R-K8)', () {
    checkScheme('light', RatelColorTokens.light);
  });

  test('dark tokens meet WCAG 2.2 AA normal-text contrast (R-K8)', () {
    checkScheme('dark', RatelColorTokens.dark);
  });

  test('outline meets >=3:1 vs surface (UI component, WCAG 1.4.11)', () {
    for (final t in [RatelColorTokens.light, RatelColorTokens.dark]) {
      expect(
        contrastRatio(t.outline, t.surface),
        greaterThanOrEqualTo(kAaLargeTextOrUi),
      );
    }
  });
}
