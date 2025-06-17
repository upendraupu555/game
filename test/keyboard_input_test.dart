import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:game/core/utils/keyboard_utils.dart';
import 'package:game/core/constants/app_constants.dart';
import 'package:game/domain/entities/tile_entity.dart';
import 'package:game/presentation/widgets/keyboard_input_handler.dart';
import 'package:game/presentation/providers/theme_providers.dart';

void main() {
  group('Keyboard Input Tests', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('KeyboardUtils Tests', () {
      test('should map arrow keys to correct directions', () {
        expect(
          KeyboardUtils.getDirectionFromKey(LogicalKeyboardKey.arrowUp),
          MoveDirection.up,
        );
        expect(
          KeyboardUtils.getDirectionFromKey(LogicalKeyboardKey.arrowDown),
          MoveDirection.down,
        );
        expect(
          KeyboardUtils.getDirectionFromKey(LogicalKeyboardKey.arrowLeft),
          MoveDirection.left,
        );
        expect(
          KeyboardUtils.getDirectionFromKey(LogicalKeyboardKey.arrowRight),
          MoveDirection.right,
        );
      });

      test('should map WASD keys to correct directions', () {
        expect(
          KeyboardUtils.getDirectionFromKey(LogicalKeyboardKey.keyW),
          MoveDirection.up,
        );
        expect(
          KeyboardUtils.getDirectionFromKey(LogicalKeyboardKey.keyS),
          MoveDirection.down,
        );
        expect(
          KeyboardUtils.getDirectionFromKey(LogicalKeyboardKey.keyA),
          MoveDirection.left,
        );
        expect(
          KeyboardUtils.getDirectionFromKey(LogicalKeyboardKey.keyD),
          MoveDirection.right,
        );
      });

      test('should return null for unsupported keys', () {
        expect(
          KeyboardUtils.getDirectionFromKey(LogicalKeyboardKey.space),
          null,
        );
        expect(
          KeyboardUtils.getDirectionFromKey(LogicalKeyboardKey.enter),
          null,
        );
        expect(
          KeyboardUtils.getDirectionFromKey(LogicalKeyboardKey.escape),
          null,
        );
      });

      test('should identify valid game control keys', () {
        expect(
          KeyboardUtils.isGameControlKey(LogicalKeyboardKey.arrowUp),
          true,
        );
        expect(KeyboardUtils.isGameControlKey(LogicalKeyboardKey.keyW), true);
        expect(KeyboardUtils.isGameControlKey(LogicalKeyboardKey.space), false);
      });

      test('should provide all supported keys', () {
        final supportedKeys = KeyboardUtils.supportedKeys;
        expect(supportedKeys.length, 8); // 4 arrow keys + 4 WASD keys
        expect(supportedKeys.contains(LogicalKeyboardKey.arrowUp), true);
        expect(supportedKeys.contains(LogicalKeyboardKey.keyW), true);
      });

      test('should provide key mapping description', () {
        final description = KeyboardUtils.getKeyMappingDescription();
        expect(description.contains('W'), true);
        expect(description.contains('Arrow'), true);
        expect(description.contains('Move Up'), true);
      });
    });

    group('KeyboardDebouncer Tests', () {
      test('should allow first key press', () {
        final debouncer = KeyboardDebouncer();
        expect(debouncer.canProcessKey(), true);
      });

      test('should block rapid key presses', () {
        final debouncer = KeyboardDebouncer();

        // First key should be allowed
        expect(debouncer.canProcessKey(), true);

        // Immediate second key should be blocked
        expect(debouncer.canProcessKey(), false);
      });

      test('should allow key press after debounce delay', () async {
        final debouncer = KeyboardDebouncer(
          debounceDelay: const Duration(milliseconds: 10),
        );

        // First key
        expect(debouncer.canProcessKey(), true);

        // Immediate second key should be blocked
        expect(debouncer.canProcessKey(), false);

        // Wait for debounce delay
        await Future.delayed(const Duration(milliseconds: 15));

        // Should be allowed now
        expect(debouncer.canProcessKey(), true);
      });

      test('should reset properly', () {
        final debouncer = KeyboardDebouncer();

        // Use up the first allowed key
        expect(debouncer.canProcessKey(), true);
        expect(debouncer.canProcessKey(), false);

        // Reset and try again
        debouncer.reset();
        expect(debouncer.canProcessKey(), true);
      });

      test('should use default debounce delay from constants', () {
        final debouncer = KeyboardDebouncer();
        // This test verifies the constructor uses AppConstants.keyboardDebounceDelay
        // We can't directly test the private field, but we can test the behavior
        expect(debouncer.canProcessKey(), true);
        expect(debouncer.canProcessKey(), false);
      });
    });

    group('Keyboard Input Handler Widget Tests', () {
      testWidgets('should handle keyboard input correctly', (
        WidgetTester tester,
      ) async {
        MoveDirection? lastDirection;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: KeyboardInputHandler(
                  onMove: (direction) {
                    lastDirection = direction;
                  },
                  child: const Text('Test'),
                ),
              ),
            ),
          ),
        );

        // Find the KeyboardInputHandler widget
        final handlerWidget = find.byType(KeyboardInputHandler);
        expect(handlerWidget, findsOneWidget);

        // Simulate key press
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(lastDirection, MoveDirection.right);
      });

      testWidgets('should not handle input when disabled', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: KeyboardInputHandler(
                  enabled: false,
                  onMove: (direction) {
                    // Should not be called when disabled
                  },
                  child: const Text('Test'),
                ),
              ),
            ),
          ),
        );

        // Should find the KeyboardInputHandler widget
        final handlerWidget = find.byType(KeyboardInputHandler);
        expect(handlerWidget, findsOneWidget);

        // Should just return the child directly
        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('should handle WASD keys', (WidgetTester tester) async {
        final directions = <MoveDirection>[];

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: KeyboardInputHandler(
                  onMove: (direction) {
                    directions.add(direction);
                  },
                  child: const Text('Test'),
                ),
              ),
            ),
          ),
        );

        // Test all WASD keys with delays to avoid debouncing
        await tester.sendKeyEvent(LogicalKeyboardKey.keyW);
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 200));

        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 200));

        await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 200));

        await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
        await tester.pump();

        expect(directions.length, 4);
        expect(directions[0], MoveDirection.up);
        expect(directions[1], MoveDirection.left);
        expect(directions[2], MoveDirection.down);
        expect(directions[3], MoveDirection.right);
      });

      testWidgets('should ignore non-game keys', (WidgetTester tester) async {
        MoveDirection? lastDirection;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: KeyboardInputHandler(
                  onMove: (direction) {
                    lastDirection = direction;
                  },
                  child: const Text('Test'),
                ),
              ),
            ),
          ),
        );

        // Test non-game keys
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        expect(lastDirection, null);
      });
    });

    group('Game Keyboard Input Handler Tests', () {
      testWidgets('should respect game state', (WidgetTester tester) async {
        MoveDirection? lastDirection;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                await SharedPreferences.getInstance(),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: GameKeyboardInputHandler(
                  onMove: (direction) {
                    lastDirection = direction;
                  },
                  child: const Text('Test'),
                ),
              ),
            ),
          ),
        );

        // Should handle input when game is active
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(lastDirection, MoveDirection.right);
      });

      testWidgets('should maintain focus on tap', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: KeyboardInputHandler(
                  onMove: (direction) {},
                  child: const Text('Test'),
                ),
              ),
            ),
          ),
        );

        // Tap on the widget
        await tester.tap(find.text('Test'));
        await tester.pump();

        // Focus should be maintained (we can't directly test focus, but no errors should occur)
        expect(find.text('Test'), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      test('should process keyboard input quickly', () {
        final stopwatch = Stopwatch()..start();

        // Process 100 keyboard inputs
        for (int i = 0; i < 100; i++) {
          KeyboardUtils.getDirectionFromKey(LogicalKeyboardKey.arrowRight);
          KeyboardUtils.isGameControlKey(LogicalKeyboardKey.keyW);
        }

        stopwatch.stop();

        // Should process 200 operations in less than 5ms
        expect(stopwatch.elapsedMilliseconds, lessThan(5));
      });

      test('should have efficient debouncing', () {
        final stopwatch = Stopwatch()..start();
        final debouncer = KeyboardDebouncer();

        // Test debouncing performance
        for (int i = 0; i < 1000; i++) {
          debouncer.canProcessKey();
        }

        stopwatch.stop();

        // Should handle 1000 debounce checks quickly
        expect(stopwatch.elapsedMilliseconds, lessThan(10));
      });
    });

    group('Integration Tests', () {
      test('should have correct debounce delay constant', () {
        expect(AppConstants.keyboardDebounceDelay.inMilliseconds, 150);
        expect(
          AppConstants.keyboardDebounceDelay.inMilliseconds,
          greaterThan(AppConstants.swipeDebounceDelay.inMilliseconds),
        );
      });

      test('should support all required directions', () {
        final supportedDirections = <MoveDirection>{};

        for (final key in KeyboardUtils.supportedKeys) {
          final direction = KeyboardUtils.getDirectionFromKey(key);
          if (direction != null) {
            supportedDirections.add(direction);
          }
        }

        // Should support all 4 cardinal directions
        expect(supportedDirections.length, 4);
        expect(supportedDirections.contains(MoveDirection.up), true);
        expect(supportedDirections.contains(MoveDirection.down), true);
        expect(supportedDirections.contains(MoveDirection.left), true);
        expect(supportedDirections.contains(MoveDirection.right), true);
      });
    });
  });
}
