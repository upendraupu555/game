import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test to verify error dialogs display as modal overlays, not navigation screens
void main() {
  group('Dialog Display Tests', () {
    testWidgets('showDialog displays as modal overlay, not navigation', (
      WidgetTester tester,
    ) async {
      bool dialogShown = false;

      // Create a test app that shows a simple dialog
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    // Test showing a simple dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Test Error'),
                        content: const Text('This is a test error message'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              dialogShown = true;
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show error dialog
      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      // Verify dialog is displayed as overlay (AlertDialog should be present)
      expect(find.byType(AlertDialog), findsOneWidget);

      // Verify dialog content
      expect(find.text('Test Error'), findsOneWidget);
      expect(find.text('This is a test error message'), findsOneWidget);

      // Verify action button is present
      expect(find.text('OK'), findsOneWidget);

      // Verify the original screen is still underneath (not navigated away)
      expect(find.text('Show Error'), findsOneWidget);

      // Test dismissing the dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(find.byType(AlertDialog), findsNothing);
      expect(dialogShown, isTrue);

      // Verify we're still on the original screen
      expect(find.text('Show Error'), findsOneWidget);
    });
  });
}
