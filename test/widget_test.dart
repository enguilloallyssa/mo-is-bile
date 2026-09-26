import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/main.dart';

void main() {
  testWidgets('SARI app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SariApp());

    expect(find.byType(SariApp), findsOneWidget);
  });
}