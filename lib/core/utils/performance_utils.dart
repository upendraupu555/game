import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../constants/app_constants.dart';
import '../logging/app_logger.dart';

/// Performance optimization utilities for the 2048 game
class PerformanceUtils {
  PerformanceUtils._();

  static final _frameTimeBuffer = Queue<Duration>();
  static const int _maxFrameTimeBufferSize = 60; // Track last 60 frames
  static int _frameCount = 0;
  static DateTime? _lastFrameTime;

  /// Monitor frame rate and detect performance issues
  static void trackFrameRate() {
    if (!AppConstants.enablePerformanceLogging) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);

      _frameTimeBuffer.add(frameDuration);
      if (_frameTimeBuffer.length > _maxFrameTimeBufferSize) {
        _frameTimeBuffer.removeFirst();
      }

      _frameCount++;

      // Log performance metrics every 60 frames
      if (_frameCount % 60 == 0) {
        _logPerformanceMetrics();
      }
    }
    _lastFrameTime = now;
  }

  /// Get current average FPS
  static double getCurrentFPS() {
    if (_frameTimeBuffer.isEmpty) return 60.0;

    final totalTime = _frameTimeBuffer.fold<Duration>(
      Duration.zero,
      (sum, duration) => sum + duration,
    );

    final averageFrameTime = totalTime.inMicroseconds / _frameTimeBuffer.length;
    return 1000000.0 / averageFrameTime; // Convert to FPS
  }

  /// Check if performance is acceptable
  static bool isPerformanceAcceptable() {
    return getCurrentFPS() >= 55.0; // Allow 5fps tolerance
  }

  /// Log performance metrics
  static void _logPerformanceMetrics() {
    final fps = getCurrentFPS();
    final isAcceptable = isPerformanceAcceptable();

    AppLogger.performance(
      'FRAME_RATE_METRICS',
      data: {
        'fps': fps.toStringAsFixed(1),
        'isAcceptable': isAcceptable,
        'frameCount': _frameCount,
        'bufferSize': _frameTimeBuffer.length,
      },
    );

    if (!isAcceptable) {
      AppLogger.warning(
        'Performance below target',
        tag: 'PerformanceUtils',
        data: {'currentFPS': fps.toStringAsFixed(1), 'targetFPS': '60.0'},
      );
    }
  }

  /// Reset performance tracking
  static void reset() {
    _frameTimeBuffer.clear();
    _frameCount = 0;
    _lastFrameTime = null;
  }
}

/// Object pool for frequently created objects to reduce garbage collection
class ObjectPool<T> {
  final Queue<T> _pool = Queue<T>();
  final T Function() _factory;
  final void Function(T)? _reset;
  final int _maxSize;

  ObjectPool({
    required T Function() factory,
    void Function(T)? reset,
    int maxSize = 50,
  }) : _factory = factory,
       _reset = reset,
       _maxSize = maxSize;

  /// Get an object from the pool or create a new one
  T acquire() {
    if (_pool.isNotEmpty) {
      return _pool.removeFirst();
    }
    return _factory();
  }

  /// Return an object to the pool
  void release(T object) {
    if (_pool.length < _maxSize) {
      _reset?.call(object);
      _pool.add(object);
    }
  }

  /// Clear the pool
  void clear() {
    _pool.clear();
  }

  /// Get current pool size
  int get size => _pool.length;
}

/// Optimized position calculation utilities
class PositionUtils {
  PositionUtils._();

  // Cache for position calculations to avoid repeated math
  static final Map<String, Offset> _positionCache = <String, Offset>{};
  static const double _tileSize = 56.0;
  static const double _tileSpacing = 6.0;
  static const double _boardSize = 320.0;

  /// Get cached position for grid coordinates
  static Offset getPositionForGrid(double row, double col) {
    final key = '${row.toStringAsFixed(2)}_${col.toStringAsFixed(2)}';

    return _positionCache.putIfAbsent(key, () {
      const gridWidth = 5 * _tileSize + 6 * _tileSpacing;
      const gridHeight = 5 * _tileSize + 6 * _tileSpacing;

      final offsetX = (_boardSize - gridWidth) / 2;
      final offsetY = (_boardSize - gridHeight) / 2;

      final x = offsetX + _tileSpacing + col * (_tileSize + _tileSpacing);
      final y = offsetY + _tileSpacing + row * (_tileSize + _tileSpacing);

      return Offset(x, y);
    });
  }

  /// Clear position cache when needed
  static void clearCache() {
    _positionCache.clear();
  }

  /// Get cache size for monitoring
  static int get cacheSize => _positionCache.length;
}

/// Animation optimization utilities
class AnimationOptimizer {
  AnimationOptimizer._();

  static int _activeAnimations = 0;
  static final Set<String> _animatingTiles = <String>{};

  /// Check if we can start a new animation
  static bool canStartAnimation() {
    return _activeAnimations < AppConstants.maxConcurrentAnimations;
  }

  /// Register a new animation
  static void registerAnimation(String tileId) {
    if (!_animatingTiles.contains(tileId)) {
      _animatingTiles.add(tileId);
      _activeAnimations++;
    }
  }

  /// Unregister an animation
  static void unregisterAnimation(String tileId) {
    if (_animatingTiles.remove(tileId)) {
      _activeAnimations--;
    }
  }

  /// Check if a tile is currently animating
  static bool isTileAnimating(String tileId) {
    return _animatingTiles.contains(tileId);
  }

  /// Get current animation count
  static int get activeAnimationCount => _activeAnimations;

  /// Reset animation tracking
  static void reset() {
    _animatingTiles.clear();
    _activeAnimations = 0;
  }

  /// Check if animations should be simplified for performance
  static bool shouldSimplifyAnimations() {
    return _activeAnimations > (AppConstants.maxConcurrentAnimations * 0.8);
  }
}

/// Memory optimization utilities
class MemoryOptimizer {
  MemoryOptimizer._();

  static int _allocationCount = 0;
  static final Map<Type, int> _allocationsByType = <Type, int>{};

  /// Track object allocation for monitoring
  static void trackAllocation(Type type) {
    if (!AppConstants.enablePerformanceLogging) return;

    _allocationCount++;
    _allocationsByType[type] = (_allocationsByType[type] ?? 0) + 1;

    // Log memory usage every 1000 allocations
    if (_allocationCount % 1000 == 0) {
      _logMemoryMetrics();
    }
  }

  /// Log memory allocation metrics
  static void _logMemoryMetrics() {
    AppLogger.performance(
      'MEMORY_ALLOCATION_METRICS',
      data: {
        'totalAllocations': _allocationCount,
        'allocationsByType': _allocationsByType.toString(),
      },
    );
  }

  /// Reset memory tracking
  static void reset() {
    _allocationCount = 0;
    _allocationsByType.clear();
  }

  /// Get allocation count for a specific type
  static int getAllocationCount(Type type) {
    return _allocationsByType[type] ?? 0;
  }
}

/// Batch operation utilities for reducing setState calls
class BatchOperations {
  BatchOperations._();

  static final Map<String, List<VoidCallback>> _pendingOperations = {};
  static final Map<String, bool> _scheduledBatches = {};

  /// Add operation to batch
  static void addOperation(String batchKey, VoidCallback operation) {
    _pendingOperations.putIfAbsent(batchKey, () => []).add(operation);

    if (!(_scheduledBatches[batchKey] ?? false)) {
      _scheduledBatches[batchKey] = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _executeBatch(batchKey);
      });
    }
  }

  /// Execute all operations in a batch
  static void _executeBatch(String batchKey) {
    final operations = _pendingOperations.remove(batchKey);
    _scheduledBatches.remove(batchKey);

    if (operations != null) {
      for (final operation in operations) {
        operation();
      }
    }
  }

  /// Clear all pending operations
  static void clear() {
    _pendingOperations.clear();
    _scheduledBatches.clear();
  }
}
