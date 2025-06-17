import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/gestures.dart';
import 'package:game/core/utils/gesture_utils.dart';
import 'package:game/domain/entities/tile_entity.dart';
import 'package:game/core/constants/app_constants.dart';

void main() {
  group('Comprehensive Gesture Detection Tests', () {
    test('should detect all four cardinal directions reliably', () {
      final testCases = [
        {
          'name': 'Right swipe',
          'velocity': const Offset(200, 10),
          'expectedDirection': MoveDirection.right,
        },
        {
          'name': 'Left swipe',
          'velocity': const Offset(-200, 10),
          'expectedDirection': MoveDirection.left,
        },
        {
          'name': 'Up swipe',
          'velocity': const Offset(10, -200),
          'expectedDirection': MoveDirection.up,
        },
        {
          'name': 'Down swipe',
          'velocity': const Offset(10, 200),
          'expectedDirection': MoveDirection.down,
        },
      ];

      for (final testCase in testCases) {
        // Test velocity-based detection
        final velocityDetails = DragEndDetails(
          velocity: Velocity(pixelsPerSecond: testCase['velocity'] as Offset),
        );
        final velocityResult = GestureUtils.analyzeSwipe(velocityDetails);

        expect(velocityResult.isValid, true, reason: '${testCase['name']} velocity-based should be valid');
        expect(velocityResult.direction, testCase['expectedDirection'], reason: '${testCase['name']} velocity-based direction');

        // Test distance-based detection
        final distanceResult = GestureUtils.analyzeSwipe(
          velocityDetails,
          startPosition: const Offset(100, 100),
        );

        expect(distanceResult.isValid, true, reason: '${testCase['name']} distance-based should be valid');
        expect(distanceResult.direction, testCase['expectedDirection'], reason: '${testCase['name']} distance-based direction');
      }
    });

    test('should reject diagonal swipes consistently', () {
      final diagonalCases = [
        {'name': 'Diagonal right-down', 'velocity': const Offset(100, 80)}, // ratio 1.25 < 1.5
        {'name': 'Diagonal left-up', 'velocity': const Offset(-100, -80)},
        {'name': 'Diagonal right-up', 'velocity': const Offset(100, -80)},
        {'name': 'Diagonal left-down', 'velocity': const Offset(-100, 80)},
      ];

      for (final testCase in diagonalCases) {
        // Test velocity-based detection
        final velocityDetails = DragEndDetails(
          velocity: Velocity(pixelsPerSecond: testCase['velocity'] as Offset),
        );
        final velocityResult = GestureUtils.analyzeSwipe(velocityDetails);

        expect(velocityResult.isValid, false, reason: '${testCase['name']} velocity-based should be rejected');
        expect(velocityResult.reason, contains('diagonal'), reason: '${testCase['name']} should be rejected for being diagonal');

        // Test distance-based detection
        final distanceResult = GestureUtils.analyzeSwipe(
          velocityDetails,
          startPosition: const Offset(100, 100),
        );

        expect(distanceResult.isValid, false, reason: '${testCase['name']} distance-based should be rejected');
        expect(distanceResult.reason, contains('diagonal'), reason: '${testCase['name']} should be rejected for being diagonal');
      }
    });

    test('should handle edge cases properly', () {
      // Test very slow swipes
      final slowSwipe = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(20, 2)),
      );
      final slowResult = GestureUtils.analyzeSwipe(slowSwipe);
      expect(slowResult.isValid, false, reason: 'Very slow swipe should be rejected');
      expect(slowResult.reason, contains('slow'), reason: 'Should be rejected for being too slow');

      // Test very short distance swipes
      final shortDistanceResult = GestureUtils.analyzeSwipe(
        slowSwipe,
        startPosition: const Offset(100, 100),
      );
      expect(shortDistanceResult.isValid, false, reason: 'Very short distance swipe should be rejected');
      expect(shortDistanceResult.reason, contains('short'), reason: 'Should be rejected for being too short');

      // Test zero velocity
      final zeroVelocity = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset.zero),
      );
      final zeroResult = GestureUtils.analyzeSwipe(zeroVelocity);
      expect(zeroResult.isValid, false, reason: 'Zero velocity should be rejected');

      // Test very high velocity (should still work)
      final highVelocity = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(2000, 100)),
      );
      final highResult = GestureUtils.analyzeSwipe(highVelocity);
      expect(highResult.isValid, true, reason: 'High velocity should be accepted');
      expect(highResult.direction, MoveDirection.right, reason: 'High velocity should detect correct direction');
    });

    test('should maintain performance requirements', () {
      // Test processing time for 100 gestures
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 100; i++) {
        final details = DragEndDetails(
          velocity: Velocity(pixelsPerSecond: Offset(200 + i.toDouble(), 10)),
        );
        
        // Test both detection methods
        GestureUtils.analyzeSwipe(details);
        GestureUtils.analyzeSwipe(details, startPosition: const Offset(100, 100));
      }
      
      stopwatch.stop();
      
      // Should process 200 gestures (100 velocity + 100 distance) in less than 20ms
      expect(stopwatch.elapsedMilliseconds, lessThan(20), reason: 'Gesture processing should be fast');
    });

    test('should have consistent thresholds', () {
      // Verify that constants are properly set
      expect(AppConstants.swipeVelocityThreshold, 30.0);
      expect(AppConstants.swipeDistanceThreshold, 15.0);
      expect(AppConstants.minimumSwipeRatio, 1.5);
      expect(AppConstants.swipeDebounceDelay.inMilliseconds, 100);

      // Test threshold boundaries
      final justAboveVelocityThreshold = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(31, 2)),
      );
      final velocityResult = GestureUtils.analyzeSwipe(justAboveVelocityThreshold);
      expect(velocityResult.isValid, true, reason: 'Just above velocity threshold should pass');

      final justBelowVelocityThreshold = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(29, 2)),
      );
      final velocityResultBelow = GestureUtils.analyzeSwipe(justBelowVelocityThreshold);
      expect(velocityResultBelow.isValid, false, reason: 'Just below velocity threshold should fail');
    });

    test('should handle debouncer correctly', () {
      final debouncer = GestureDebouncer();
      
      // First gesture should be allowed
      expect(debouncer.canProcessGesture(), true, reason: 'First gesture should be allowed');
      
      // Immediate second gesture should be blocked
      expect(debouncer.canProcessGesture(), false, reason: 'Immediate second gesture should be blocked');
      
      // Reset and test again
      debouncer.reset();
      expect(debouncer.canProcessGesture(), true, reason: 'After reset, gesture should be allowed');
    });

    test('should provide meaningful result descriptions', () {
      // Test valid swipe description
      final validSwipe = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(200, 10)),
      );
      final validResult = GestureUtils.analyzeSwipe(validSwipe);
      final description = GestureUtils.getSwipeDescription(validResult);
      
      expect(description, contains('Valid'), reason: 'Valid swipe should have "Valid" in description');
      expect(description, contains('right'), reason: 'Right swipe should mention direction');
      expect(description, contains('velocity'), reason: 'Description should include velocity info');

      // Test invalid swipe description
      final invalidSwipe = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(10, 5)),
      );
      final invalidResult = GestureUtils.analyzeSwipe(invalidSwipe);
      final invalidDescription = GestureUtils.getSwipeDescription(invalidResult);
      
      expect(invalidDescription, contains('Invalid'), reason: 'Invalid swipe should have "Invalid" in description');
      expect(invalidDescription, contains(invalidResult.reason), reason: 'Description should include reason');
    });

    test('should maintain 95%+ recognition rate for valid gestures', () {
      int validGestures = 0;
      int recognizedGestures = 0;
      
      // Test 100 valid cardinal direction gestures
      for (int i = 0; i < 100; i++) {
        final directions = [
          const Offset(200, 10),  // Right
          const Offset(-200, 10), // Left
          const Offset(10, 200),  // Down
          const Offset(10, -200), // Up
        ];
        
        final velocity = directions[i % 4];
        final details = DragEndDetails(
          velocity: Velocity(pixelsPerSecond: velocity),
        );
        
        validGestures++;
        
        // Test both detection methods
        final velocityResult = GestureUtils.analyzeSwipe(details);
        final distanceResult = GestureUtils.analyzeSwipe(
          details,
          startPosition: const Offset(100, 100),
        );
        
        if (velocityResult.isValid && distanceResult.isValid) {
          recognizedGestures++;
        }
      }
      
      final recognitionRate = recognizedGestures / validGestures;
      expect(recognitionRate, greaterThanOrEqualTo(0.95), reason: 'Recognition rate should be 95% or higher');
    });
  });
}
