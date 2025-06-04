import 'package:flutter/material.dart';
import '../../domain/entities/tile_entity.dart';
import '../constants/app_constants.dart';
import '../logging/app_logger.dart';

/// Enhanced gesture detection utility for reliable swipe recognition
class GestureUtils {
  GestureUtils._();

  /// Simplified swipe analysis for reliable gesture detection
  static SwipeResult analyzeSwipe(
    DragEndDetails details, {
    Offset? startPosition,
    double? customVelocityThreshold,
    double? customDistanceThreshold,
  }) {
    final velocity = details.velocity.pixelsPerSecond;
    final dx = velocity.dx;
    final dy = velocity.dy;
    final distance = velocity.distance;

    // Use custom thresholds or defaults
    final velocityThreshold =
        customVelocityThreshold ?? AppConstants.swipeVelocityThreshold;

    AppLogger.userAction(
      'SWIPE_ANALYSIS_START',
      data: {
        'velocityX': dx.toStringAsFixed(2),
        'velocityY': dy.toStringAsFixed(2),
        'distance': distance.toStringAsFixed(2),
        'velocityThreshold': velocityThreshold,
      },
    );

    // Check minimum velocity threshold
    if (distance < velocityThreshold) {
      AppLogger.userAction(
        'SWIPE_REJECTED_VELOCITY',
        data: {
          'reason': 'Velocity too low',
          'distance': distance.toStringAsFixed(2),
          'threshold': velocityThreshold,
        },
      );
      return SwipeResult.invalid(
        'Velocity too low: ${distance.toStringAsFixed(2)} < $velocityThreshold',
      );
    }

    // Check maximum velocity to prevent false positives
    if (distance > AppConstants.maxSwipeVelocity) {
      AppLogger.userAction(
        'SWIPE_REJECTED_MAX_VELOCITY',
        data: {
          'reason': 'Velocity too high',
          'distance': distance.toStringAsFixed(2),
          'maxThreshold': AppConstants.maxSwipeVelocity,
        },
      );
      return SwipeResult.invalid(
        'Velocity too high: ${distance.toStringAsFixed(2)} > ${AppConstants.maxSwipeVelocity}',
      );
    }

    // Calculate absolute values for comparison
    final absDx = dx.abs();
    final absDy = dy.abs();

    // Simplified direction detection - just check which axis is dominant
    MoveDirection direction;
    String dominantAxis;
    double ratio = 1.0;

    if (absDx > absDy) {
      // Horizontal swipe
      direction = dx > 0 ? MoveDirection.right : MoveDirection.left;
      dominantAxis = 'horizontal';
      ratio = absDy > 0 ? absDx / absDy : absDx;
    } else {
      // Vertical swipe
      direction = dy > 0 ? MoveDirection.down : MoveDirection.up;
      dominantAxis = 'vertical';
      ratio = absDx > 0 ? absDy / absDx : absDy;
    }

    // Only reject if the gesture is extremely diagonal (less permissive than before)
    if (ratio < AppConstants.minimumSwipeRatio && absDx > 0 && absDy > 0) {
      AppLogger.userAction(
        'SWIPE_REJECTED_DIRECTION',
        data: {
          'reason': 'Too diagonal',
          'ratio': ratio.toStringAsFixed(2),
          'minimumRatio': AppConstants.minimumSwipeRatio,
          'absDx': absDx.toStringAsFixed(2),
          'absDy': absDy.toStringAsFixed(2),
        },
      );
      return SwipeResult.invalid(
        'Too diagonal: ratio ${ratio.toStringAsFixed(2)} < ${AppConstants.minimumSwipeRatio}',
      );
    }

    AppLogger.userAction(
      'SWIPE_ACCEPTED',
      data: {
        'direction': direction.toString(),
        'dominantAxis': dominantAxis,
        'velocity': distance.toStringAsFixed(2),
        'ratio': ratio.toStringAsFixed(2),
        'dx': dx.toStringAsFixed(2),
        'dy': dy.toStringAsFixed(2),
      },
    );

    return SwipeResult.valid(direction, distance, ratio);
  }

  /// Simple direction detection based on velocity components
  static MoveDirection? getSwipeDirection(double dx, double dy) {
    final absDx = dx.abs();
    final absDy = dy.abs();

    // Return null if no clear movement
    if (absDx < 10 && absDy < 10) return null;

    // Determine direction based on dominant axis
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

/// Debouncer for preventing rapid gesture triggers
class GestureDebouncer {
  DateTime? _lastGestureTime;
  final Duration _debounceDelay;

  GestureDebouncer({Duration? debounceDelay})
    : _debounceDelay = debounceDelay ?? AppConstants.swipeDebounceDelay;

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

    AppLogger.userAction(
      'GESTURE_DEBOUNCED',
      data: {
        'timeSinceLastGesture': timeSinceLastGesture.inMilliseconds,
        'debounceDelay': _debounceDelay.inMilliseconds,
      },
    );
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
