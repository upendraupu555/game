import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/utils/gesture_utils.dart';
import 'package:game/domain/entities/tile_entity.dart';

void main() {
  group('Improved Gesture Detection Tests', () {
    test('should detect horizontal swipes with lower velocity threshold', () {
      // Test right swipe with low velocity (should now be accepted)
      final rightSwipeDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(60, 10)), // Above new 50 threshold
      );
      
      final rightResult = GestureUtils.analyzeSwipe(rightSwipeDetails);
      expect(rightResult.isValid, true);
      expect(rightResult.direction, MoveDirection.right);

      // Test left swipe with low velocity
      final leftSwipeDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(-60, 10)),
      );
      
      final leftResult = GestureUtils.analyzeSwipe(leftSwipeDetails);
      expect(leftResult.isValid, true);
      expect(leftResult.direction, MoveDirection.left);
    });

    test('should detect vertical swipes with lower velocity threshold', () {
      // Test up swipe with low velocity
      final upSwipeDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(10, -60)),
      );
      
      final upResult = GestureUtils.analyzeSwipe(upSwipeDetails);
      expect(upResult.isValid, true);
      expect(upResult.direction, MoveDirection.up);

      // Test down swipe with low velocity
      final downSwipeDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(10, 60)),
      );
      
      final downResult = GestureUtils.analyzeSwipe(downSwipeDetails);
      expect(downResult.isValid, true);
      expect(downResult.direction, MoveDirection.down);
    });

    test('should accept more diagonal swipes with relaxed ratio', () {
      // Test diagonal swipe that would have been rejected before (ratio 1.3)
      final diagonalSwipeDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(65, 50)), // ratio = 1.3
      );
      
      final result = GestureUtils.analyzeSwipe(diagonalSwipeDetails);
      expect(result.isValid, true); // Should be accepted with new 1.2 threshold
      expect(result.direction, MoveDirection.right); // Horizontal is dominant
    });

    test('should reject extremely slow swipes', () {
      // Test very slow swipe (below 50 threshold)
      final slowSwipeDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(30, 5)),
      );
      
      final result = GestureUtils.analyzeSwipe(slowSwipeDetails);
      expect(result.isValid, false);
      expect(result.reason, contains('Velocity too low'));
    });

    test('should reject extremely fast swipes', () {
      // Test very fast swipe (above 3000 threshold)
      final fastSwipeDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(3500, 100)),
      );
      
      final result = GestureUtils.analyzeSwipe(fastSwipeDetails);
      expect(result.isValid, false);
      expect(result.reason, contains('Velocity too high'));
    });

    test('should handle edge cases correctly', () {
      // Test pure horizontal swipe
      final pureHorizontalDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(100, 0)),
      );
      
      final horizontalResult = GestureUtils.analyzeSwipe(pureHorizontalDetails);
      expect(horizontalResult.isValid, true);
      expect(horizontalResult.direction, MoveDirection.right);

      // Test pure vertical swipe
      final pureVerticalDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(0, -100)),
      );
      
      final verticalResult = GestureUtils.analyzeSwipe(pureVerticalDetails);
      expect(verticalResult.isValid, true);
      expect(verticalResult.direction, MoveDirection.up);
    });

    test('getSwipeDirection helper should work correctly', () {
      // Test simple direction detection
      expect(GestureUtils.getSwipeDirection(50, 10), MoveDirection.right);
      expect(GestureUtils.getSwipeDirection(-50, 10), MoveDirection.left);
      expect(GestureUtils.getSwipeDirection(10, 50), MoveDirection.down);
      expect(GestureUtils.getSwipeDirection(10, -50), MoveDirection.up);
      
      // Test no movement
      expect(GestureUtils.getSwipeDirection(5, 5), null);
    });

    test('should provide meaningful descriptions', () {
      final validSwipeDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(100, 20)),
      );
      
      final result = GestureUtils.analyzeSwipe(validSwipeDetails);
      final description = GestureUtils.getSwipeDescription(result);
      
      expect(description, contains('Valid'));
      expect(description, contains('right'));
      expect(description, contains('velocity'));
      expect(description, contains('ratio'));
    });
  });

  group('GestureDebouncer Tests', () {
    test('should allow first gesture immediately', () {
      final debouncer = GestureDebouncer();
      expect(debouncer.canProcessGesture(), true);
    });

    test('should block rapid gestures within debounce period', () {
      final debouncer = GestureDebouncer();
      
      // First gesture should be allowed
      expect(debouncer.canProcessGesture(), true);
      
      // Immediate second gesture should be blocked
      expect(debouncer.canProcessGesture(), false);
    });

    test('should allow gestures after debounce period', () async {
      final debouncer = GestureDebouncer(
        debounceDelay: const Duration(milliseconds: 10),
      );
      
      // First gesture
      expect(debouncer.canProcessGesture(), true);
      
      // Wait for debounce period
      await Future.delayed(const Duration(milliseconds: 15));
      
      // Second gesture should be allowed
      expect(debouncer.canProcessGesture(), true);
    });

    test('should reset correctly', () {
      final debouncer = GestureDebouncer();
      
      // Process a gesture
      debouncer.canProcessGesture();
      
      // Reset
      debouncer.reset();
      
      // Should allow immediate gesture after reset
      expect(debouncer.canProcessGesture(), true);
    });
  });
}
