import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/tile_entity.dart';
import '../constants/app_constants.dart';
import '../logging/app_logger.dart';

/// Optimized gesture detection utility for reliable 4-directional swipe recognition
class GestureUtils {
  GestureUtils._();

  /// Optimized swipe analysis for reliable 4-directional gesture detection
  static SwipeResult analyzeSwipe(
    DragEndDetails details, {
    Offset? startPosition,
    double? customVelocityThreshold,
    double? customDistanceThreshold,
  }) {
    // Use distance-based detection if start position is available (more reliable)
    if (startPosition != null) {
      return _analyzeSwipeByDistance(
        details,
        startPosition,
        customDistanceThreshold,
      );
    }

    // Fallback to simplified velocity-based detection
    return _analyzeSwipeByVelocity(details, customVelocityThreshold);
  }

  /// Distance-based swipe detection (primary method) - more reliable across devices
  static SwipeResult _analyzeSwipeByDistance(
    DragEndDetails details,
    Offset startPosition,
    double? customDistanceThreshold,
  ) {
    // Use velocity-based distance calculation with proper time integration
    // Assume typical swipe duration of 150-200ms for mobile gestures
    final velocity = details.velocity.pixelsPerSecond;
    const swipeDuration = 0.15; // 150ms - typical fast swipe duration

    // Calculate distance using velocity integration over time
    final deltaX = velocity.dx * swipeDuration;
    final deltaY = velocity.dy * swipeDuration;
    final distance = math.sqrt(deltaX * deltaX + deltaY * deltaY);

    final distanceThreshold =
        customDistanceThreshold ?? AppConstants.swipeDistanceThreshold;

    // Check minimum distance - must be a deliberate swipe
    if (distance < distanceThreshold) {
      return SwipeResult.invalid('Swipe too short');
    }

    // Simple cardinal direction detection - only 4 directions allowed
    final absDeltaX = deltaX.abs();
    final absDeltaY = deltaY.abs();

    // Determine direction based on dominant axis (no diagonal support)
    MoveDirection direction;
    double confidence;

    if (absDeltaX > absDeltaY) {
      // Horizontal movement is dominant
      direction = deltaX > 0 ? MoveDirection.right : MoveDirection.left;
      confidence = absDeltaY > 0 ? absDeltaX / absDeltaY : 10.0;
    } else {
      // Vertical movement is dominant
      direction = deltaY > 0 ? MoveDirection.down : MoveDirection.up;
      confidence = absDeltaX > 0 ? absDeltaY / absDeltaX : 10.0;
    }

    // Reject overly diagonal gestures (enforce cardinal directions)
    if (confidence < AppConstants.minimumSwipeRatio) {
      return SwipeResult.invalid('Gesture too diagonal');
    }

    return SwipeResult.valid(direction, distance, confidence);
  }

  /// Simplified velocity-based detection (fallback method)
  static SwipeResult _analyzeSwipeByVelocity(
    DragEndDetails details,
    double? customVelocityThreshold,
  ) {
    final velocity = details.velocity.pixelsPerSecond;
    final dx = velocity.dx;
    final dy = velocity.dy;
    final speed = velocity.distance;

    final velocityThreshold =
        customVelocityThreshold ?? AppConstants.swipeVelocityThreshold;

    // Check minimum velocity
    if (speed < velocityThreshold) {
      return SwipeResult.invalid('Swipe too slow');
    }

    // Simple direction detection based on velocity components
    final direction = getSwipeDirection(dx, dy);
    if (direction == null) {
      return SwipeResult.invalid('No clear direction');
    }

    // Calculate confidence based on velocity ratio
    final absDx = dx.abs();
    final absDy = dy.abs();
    final confidence = absDx > absDy
        ? (absDy > 0 ? absDx / absDy : 10.0)
        : (absDx > 0 ? absDy / absDx : 10.0);

    // Reject diagonal gestures using consistent threshold
    if (confidence < AppConstants.minimumSwipeRatio) {
      return SwipeResult.invalid('Gesture too diagonal');
    }

    return SwipeResult.valid(direction, speed, confidence);
  }

  /// Simple direction detection based on velocity components
  static MoveDirection? getSwipeDirection(double dx, double dy) {
    final absDx = dx.abs();
    final absDy = dy.abs();

    // Return null if no clear movement
    if (absDx < 5 && absDy < 5) return null;

    // Determine direction based on dominant axis (cardinal directions only)
    if (absDx > absDy) {
      return dx > 0 ? MoveDirection.right : MoveDirection.left;
    } else {
      return dy > 0 ? MoveDirection.down : MoveDirection.up;
    }
  }

  /// Get a human-readable description of the swipe
  static String getSwipeDescription(SwipeResult result) {
    if (!result.isValid) {
      return 'Invalid swipe: ${result.reason}';
    }

    return 'Valid ${result.direction.toString().split('.').last} swipe '
        '(velocity: ${result.velocity.toStringAsFixed(1)}, '
        'ratio: ${result.directionRatio.toStringAsFixed(2)})';
  }
}

/// Result of swipe analysis
class SwipeResult {
  final bool isValid;
  final MoveDirection? direction;
  final double velocity;
  final double directionRatio;
  final String reason;

  const SwipeResult._({
    required this.isValid,
    this.direction,
    required this.velocity,
    required this.directionRatio,
    required this.reason,
  });

  /// Create a valid swipe result
  factory SwipeResult.valid(
    MoveDirection direction,
    double velocity,
    double ratio,
  ) {
    return SwipeResult._(
      isValid: true,
      direction: direction,
      velocity: velocity,
      directionRatio: ratio,
      reason: 'Valid swipe',
    );
  }

  /// Create an invalid swipe result
  factory SwipeResult.invalid(String reason) {
    return SwipeResult._(
      isValid: false,
      direction: null,
      velocity: 0.0,
      directionRatio: 0.0,
      reason: reason,
    );
  }

  @override
  String toString() {
    return 'SwipeResult(isValid: $isValid, direction: $direction, '
        'velocity: ${velocity.toStringAsFixed(2)}, '
        'ratio: ${directionRatio.toStringAsFixed(2)}, reason: $reason)';
  }
}

/// Optimized debouncer for preventing rapid gesture triggers while maintaining responsiveness
class GestureDebouncer {
  DateTime? _lastGestureTime;
  final Duration _debounceDelay;

  GestureDebouncer({Duration? debounceDelay})
    : _debounceDelay = debounceDelay ?? const Duration(milliseconds: 100);

  /// Check if enough time has passed since the last gesture
  bool canProcessGesture() {
    final now = DateTime.now();
    if (_lastGestureTime == null) {
      _lastGestureTime = now;
      return true;
    }

    final timeSinceLastGesture = now.difference(_lastGestureTime!);
    if (timeSinceLastGesture >= _debounceDelay) {
      _lastGestureTime = now;
      return true;
    }

    // Reduced logging for better performance
    return false;
  }

  /// Reset the debouncer
  void reset() {
    _lastGestureTime = null;
  }
}

/// Enhanced gesture detector with improved swipe recognition
class EnhancedGestureDetector extends StatefulWidget {
  final Widget child;
  final Function(MoveDirection)? onSwipe;
  final bool enabled;
  final double? customVelocityThreshold;
  final double? customDistanceThreshold;
  final bool enableDebouncing;

  const EnhancedGestureDetector({
    super.key,
    required this.child,
    this.onSwipe,
    this.enabled = true,
    this.customVelocityThreshold,
    this.customDistanceThreshold,
    this.enableDebouncing = true,
  });

  @override
  State<EnhancedGestureDetector> createState() =>
      _EnhancedGestureDetectorState();
}

class _EnhancedGestureDetectorState extends State<EnhancedGestureDetector> {
  final GestureDebouncer _debouncer = GestureDebouncer();
  Offset? _panStartPosition;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanEnd: _handlePanEnd,
      child: widget.child,
    );
  }

  void _handlePanStart(DragStartDetails details) {
    _panStartPosition = details.localPosition;
    AppLogger.userAction(
      'PAN_START',
      data: {
        'startPosition':
            '(${details.localPosition.dx.toStringAsFixed(2)}, ${details.localPosition.dy.toStringAsFixed(2)})',
      },
    );
  }

  void _handlePanEnd(DragEndDetails details) {
    if (widget.onSwipe == null) return;

    // Check debouncing if enabled
    if (widget.enableDebouncing && !_debouncer.canProcessGesture()) {
      return;
    }

    // Analyze the swipe
    final result = GestureUtils.analyzeSwipe(
      details,
      startPosition: _panStartPosition,
      customVelocityThreshold: widget.customVelocityThreshold,
      customDistanceThreshold: widget.customDistanceThreshold,
    );

    AppLogger.userAction(
      'GESTURE_ANALYSIS_COMPLETE',
      data: {
        'result': result.toString(),
        'description': GestureUtils.getSwipeDescription(result),
      },
    );

    // Execute callback if swipe is valid
    if (result.isValid && result.direction != null) {
      widget.onSwipe!(result.direction!);
    }
  }
}
