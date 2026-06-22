import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/main.dart';

void main() {
  testWidgets('app boots and shows the Ratel boot marker', (tester) async {
    await tester.pumpWidget(const RatelApp());
    expect(find.byKey(const Key('boot-marker')), findsOneWidget);
    expect(find.text('Ratel'), findsOneWidget);
  });
}
