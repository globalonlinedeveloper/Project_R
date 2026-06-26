import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/main.dart';

/// Boot smoke — the minimal S35 placeholder app builds and shows its shell.
/// Replaces the old design-system widget tests removed in the UI reset.
void main() {
  testWidgets('app boots to the rebuilding placeholder', (tester) async {
    await tester.pumpWidget(const RatelApp());
    expect(find.text('Ratel'), findsOneWidget);
    expect(find.text("We're rebuilding the experience."), findsOneWidget);
  });
}
