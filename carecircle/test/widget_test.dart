import 'package:flutter_test/flutter_test.dart';
import 'package:carecircle/main.dart';

void main() {
  testWidgets('CareCircle app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const CareCircleApp());

    expect(find.byType(CareCircleApp), findsOneWidget);
    expect(find.text('CareCircle'), findsOneWidget);
  });
}