import 'package:flutter_test/flutter_test.dart';
import 'package:carecircle/main.dart';

void main() {
  testWidgets('CareCircle app starts and opens welcome screen',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CareCircleApp());

        // Verify the splash screen appears.
        expect(find.text('CareCircle'), findsOneWidget);

        // Advance the test clock beyond the splash screen's 2-second timer.
        await tester.pump(const Duration(seconds: 2));

        // Allow the navigation transition to finish.
        await tester.pumpAndSettle();

        // Verify that the splash screen has navigated away.
        expect(find.text('Connected care. Peace of mind.'), findsNothing);
      });
}