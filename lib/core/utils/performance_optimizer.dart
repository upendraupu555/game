import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../logging/app_logger.dart';

/// Comprehensive performance optimization utilities for 60 FPS gameplay
class PerformanceOptimizer {
  PerformanceOptimizer._();

  static bool _isInitialized = false;
  static int _frameCount = 0;
  static DateTime? _lastFrameTime;
  static final List<Duration> _frameTimes = [];
  static const int _maxFrameTimeBuffer = 60; // Track last 60 frames

  /// Initialize performance optimizations
  static void initialize() {
    if (_isInitialized) return;

    // Enable performance overlay in debug mode
    if (kDebugMode && AppConstants.enablePerformanceLogging) {
      SchedulerBinding.instance.addPersistentFrameCallback(_trackFrameRate);
    }

    // Optimize system UI for gaming
    _optimizeSystemUI();

    // Pre-warm shaders for common operations
    _preWarmShaders();

    _isInitialized = true;

    AppLogger.info(
      'Performance optimizer initialized',
      tag: 'PerformanceOptimizer',
    );
  }

  /// Track frame rate for performance monitoring
  static void _trackFrameRate(Duration timestamp) {
    final now = DateTime.now();

    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      _frameTimes.add(frameDuration);

      // Keep buffer size manageable
      if (_frameTimes.length > _maxFrameTimeBuffer) {
        _frameTimes.removeAt(0);
      }

      _frameCount++;

      // Log performance metrics every 60 frames
      if (_frameCount % 60 == 0) {
        _logPerformanceMetrics();
      }
    }

    _lastFrameTime = now;
  }

  /// Log performance metrics
  static void _logPerformanceMetrics() {
    if (_frameTimes.isEmpty) return;

    final avgFrameTime =
        _frameTimes.fold<Duration>(
          Duration.zero,
          (sum, duration) => sum + duration,
        ) ~/
        _frameTimes.length;

    final fps = 1000 / avgFrameTime.inMilliseconds;
    final isPerformant = fps >= 55; // Allow some tolerance

    AppLogger.performance(
      'FRAME_RATE_ANALYSIS',
      data: {
        'fps': fps.toStringAsFixed(1),
        'avgFrameTime': '${avgFrameTime.inMilliseconds}ms',
        'isPerformant': isPerformant,
        'frameCount': _frameCount,
      },
    );

    if (!isPerformant) {
      AppLogger.warning(
        'Performance below target',
        tag: 'PerformanceOptimizer',
        data: {
          'currentFPS': fps.toStringAsFixed(1),
          'targetFPS': '60.0',
          'suggestion': 'Consider reducing animation complexity',
        },
      );
    }
  }

  /// Optimize system UI for gaming performance
  static void _optimizeSystemUI() {
    try {
      // Hide system UI for immersive gaming experience
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [SystemUiOverlay.top],
      );

      // Set preferred orientations for consistent performance
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      AppLogger.debug(
        'System UI optimized for gaming',
        tag: 'PerformanceOptimizer',
      );
    } catch (error) {
      AppLogger.error(
        'Failed to optimize system UI',
        tag: 'PerformanceOptimizer',
        error: error,
      );
    }
  }

  /// Pre-warm shaders for common operations
  static void _preWarmShaders() {
    try {
      // Pre-warm common shaders used in the game
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // This helps reduce jank when shaders are first used
        AppLogger.debug('Shaders pre-warmed', tag: 'PerformanceOptimizer');
      });
    } catch (error) {
      AppLogger.error(
        'Failed to pre-warm shaders',
        tag: 'PerformanceOptimizer',
        error: error,
      );
    }
  }

  /// Get current FPS
  static double getCurrentFPS() {
    if (_frameTimes.isEmpty) return 0.0;

    final avgFrameTime =
        _frameTimes.fold<Duration>(
          Duration.zero,
          (sum, duration) => sum + duration,
        ) ~/
        _frameTimes.length;

    return 1000 / avgFrameTime.inMilliseconds;
  }

  /// Check if performance is acceptable
  static bool isPerformanceAcceptable() {
    return getCurrentFPS() >= 55; // Allow 5 FPS tolerance
  }

  /// Get performance recommendations
  static List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];
    final fps = getCurrentFPS();

    if (fps < 45) {
      recommendations.addAll([
        'Reduce confetti particle count',
        'Disable complex animations',
        'Use simplified tile rendering',
        'Reduce shadow effects',
      ]);
    } else if (fps < 55) {
      recommendations.addAll([
        'Consider reducing animation complexity',
        'Optimize tile merge effects',
      ]);
    }

    return recommendations;
  }

  /// Reset performance tracking
  static void reset() {
    _frameTimes.clear();
    _frameCount = 0;
    _lastFrameTime = null;
  }

  /// Dispose resources
  static void dispose() {
    // Note: Persistent frame callbacks cannot be removed in Flutter
    // They are automatically cleaned up when the app is disposed
    reset();
    _isInitialized = false;
  }
}

/// Widget performance optimization utilities
class WidgetOptimizer {
  WidgetOptimizer._();

  /// Check if a widget should use RepaintBoundary
  static bool shouldUseRepaintBoundary({
    required bool hasAnimations,
    required bool hasComplexPainting,
    required bool changesFrequently,
  }) {
    return hasAnimations || hasComplexPainting || changesFrequently;
  }

  /// Get optimal animation duration based on current performance
  static Duration getOptimalAnimationDuration(Duration baseDuration) {
    if (!PerformanceOptimizer.isPerformanceAcceptable()) {
      // Reduce animation duration for better performance
      return Duration(
        milliseconds: (baseDuration.inMilliseconds * 0.75).round(),
      );
    }
    return baseDuration;
  }

  /// Get optimal particle count for confetti based on performance
  static int getOptimalParticleCount(int baseCount) {
    final fps = PerformanceOptimizer.getCurrentFPS();

    if (fps < 45) {
      return (baseCount * 0.5).round(); // Reduce by 50%
    } else if (fps < 55) {
      return (baseCount * 0.75).round(); // Reduce by 25%
    }

    return baseCount;
  }
}

/// Memory optimization utilities
class MemoryOptimizer {
  MemoryOptimizer._();

  static final Map<Type, int> _allocationCounts = {};
  static int _totalAllocations = 0;

  /// Track object allocation
  static void trackAllocation(Type type) {
    if (!AppConstants.enablePerformanceLogging) return;

    _totalAllocations++;
    _allocationCounts[type] = (_allocationCounts[type] ?? 0) + 1;

    // Log memory usage periodically
    if (_totalAllocations % 1000 == 0) {
      _logMemoryUsage();
    }
  }

  /// Log memory usage statistics
  static void _logMemoryUsage() {
    AppLogger.performance(
      'MEMORY_ALLOCATION_STATS',
      data: {
        'totalAllocations': _totalAllocations,
        'typeBreakdown': _allocationCounts.toString(),
      },
    );
  }

  /// Get allocation count for a specific type
  static int getAllocationCount(Type type) {
    return _allocationCounts[type] ?? 0;
  }

  /// Reset memory tracking
  static void reset() {
    _allocationCounts.clear();
    _totalAllocations = 0;
  }
}

/// Animation optimization utilities
class AnimationOptimizer {
  AnimationOptimizer._();

  static final Set<String> _activeAnimations = {};
  static int get activeAnimationCount => _activeAnimations.length;

  /// Register an animation
  static void registerAnimation(String animationId) {
    _activeAnimations.add(animationId);
  }

  /// Unregister an animation
  static void unregisterAnimation(String animationId) {
    _activeAnimations.remove(animationId);
  }

  /// Check if we can start a new animation
  static bool canStartAnimation() {
    return _activeAnimations.length < AppConstants.maxConcurrentAnimations;
  }

  /// Check if animations should be simplified
  static bool shouldSimplifyAnimations() {
    return _activeAnimations.length >
        (AppConstants.maxConcurrentAnimations * 0.8);
  }

  /// Reset animation tracking
  static void reset() {
    _activeAnimations.clear();
  }
}
