import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/utils/gesture_utils.dart';
import 'package:game/domain/entities/tile_entity.dart';

void main() {
  group('Debug Gesture Detection', () {
    test('should debug left swipe detection', () {
      // Simulate what tester.fling with Offset(-100, 0) would create
      // tester.fling creates a velocity based on the offset and speed
      final leftSwipeDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(-1000, 0)), // Negative X = left
      );
      
      final result = GestureUtils.analyzeSwipe(leftSwipeDetails);
      print('Left swipe result: ${result.toString()}');
      print('Direction: ${result.direction}');
      print('Is valid: ${result.isValid}');
      
      expect(result.isValid, true);
      expect(result.direction, MoveDirection.left);
    });

    test('should debug right swipe detection', () {
      // Simulate what tester.fling with Offset(100, 0) would create
      final rightSwipeDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(1000, 0)), // Positive X = right
      );
      
      final result = GestureUtils.analyzeSwipe(rightSwipeDetails);
      print('Right swipe result: ${result.toString()}');
      print('Direction: ${result.direction}');
      print('Is valid: ${result.isValid}');
      
      expect(result.isValid, true);
      expect(result.direction, MoveDirection.right);
    });

    test('should debug up swipe detection', () {
      final upSwipeDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(0, -1000)), // Negative Y = up
      );
      
      final result = GestureUtils.analyzeSwipe(upSwipeDetails);
      print('Up swipe result: ${result.toString()}');
      print('Direction: ${result.direction}');
      print('Is valid: ${result.isValid}');
      
      expect(result.isValid, true);
      expect(result.direction, MoveDirection.up);
    });

    test('should debug down swipe detection', () {
      final downSwipeDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(0, 1000)), // Positive Y = down
      );
      
      final result = GestureUtils.analyzeSwipe(downSwipeDetails);
      print('Down swipe result: ${result.toString()}');
      print('Direction: ${result.direction}');
      print('Is valid: ${result.isValid}');
      
      expect(result.isValid, true);
      expect(result.direction, MoveDirection.down);
    });

    test('should test edge case velocities', () {
      // Test with exact threshold velocity
      final thresholdSwipeDetails = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(50, 0)), // Exactly at threshold
      );
      
      final result = GestureUtils.analyzeSwipe(thresholdSwipeDetails);
      print('Threshold swipe result: ${result.toString()}');
      
      expect(result.isValid, true);
      expect(result.direction, MoveDirection.right);
    });
  });
}
