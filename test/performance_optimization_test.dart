import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/utils/performance_utils.dart';
import 'package:game/core/constants/app_constants.dart';
import 'package:game/domain/entities/game_entity.dart';
import 'package:game/domain/entities/tile_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Performance Optimization Tests', () {
    setUp(() {
      // Reset performance tracking before each test
      PerformanceUtils.reset();
    });

    test('should have optimized animation constants', () {
      // Verify that animation durations are optimized for 60fps
      expect(AppConstants.animationDurationFast, lessThanOrEqualTo(200));
      expect(AppConstants.animationDurationMedium, lessThanOrEqualTo(300));
      expect(AppConstants.animationDurationSlow, lessThanOrEqualTo(500));

      // Verify performance optimization flags
      expect(AppConstants.enableAnimationOptimizations, true);
      expect(AppConstants.maxConcurrentAnimations, 25); // For 5x5 board
    });

    test('should have optimized gesture constants', () {
      // Verify that gesture thresholds are optimized for responsiveness
      expect(AppConstants.swipeVelocityThreshold, 50.0); // Reduced from 100
      expect(AppConstants.swipeDistanceThreshold, 15.0); // Reduced from 20
      expect(
        AppConstants.swipeDebounceDelay.inMilliseconds,
        50,
      ); // Reduced from 100
      expect(AppConstants.minimumSwipeRatio, 1.2); // Reduced from 1.5
    });

    test('ObjectPool should manage memory efficiently', () {
      final pool = ObjectPool<String>(factory: () => 'test', maxSize: 5);

      // Test object acquisition and release
      final obj1 = pool.acquire();
      expect(obj1, 'test');
      expect(pool.size, 0);

      pool.release(obj1);
      expect(pool.size, 1);

      final obj2 = pool.acquire();
      expect(obj2, obj1); // Should reuse the same object
      expect(pool.size, 0);

      // Test max size limit
      for (int i = 0; i < 10; i++) {
        pool.release('item$i');
      }
      expect(pool.size, 5); // Should not exceed max size
    });

    test('AnimationOptimizer should track animations correctly', () {
      expect(AnimationOptimizer.activeAnimationCount, 0);
      expect(AnimationOptimizer.canStartAnimation(), true);

      // Register animations
      AnimationOptimizer.registerAnimation('tile1');
      AnimationOptimizer.registerAnimation('tile2');
      expect(AnimationOptimizer.activeAnimationCount, 2);
      expect(AnimationOptimizer.isTileAnimating('tile1'), true);
      expect(AnimationOptimizer.isTileAnimating('tile3'), false);

      // Unregister animation
      AnimationOptimizer.unregisterAnimation('tile1');
      expect(AnimationOptimizer.activeAnimationCount, 1);
      expect(AnimationOptimizer.isTileAnimating('tile1'), false);

      // Test animation limit
      for (int i = 0; i < 30; i++) {
        AnimationOptimizer.registerAnimation('tile$i');
      }
      expect(AnimationOptimizer.shouldSimplifyAnimations(), true);
    });

    test('BatchOperations should exist for performance optimization', () {
      // Test that BatchOperations class exists and has the expected methods
      expect(BatchOperations.addOperation, isA<Function>());
      expect(BatchOperations.clear, isA<Function>());

      // Clear any pending operations
      BatchOperations.clear();
    });

    test('GameEntity.isBoardFull should be optimized', () {
      // Create empty board
      final emptyGame = GameEntity.newGame();
      expect(emptyGame.isBoardFull, false);

      // Create full board
      final fullBoard = List.generate(
        5,
        (row) => List.generate(
          5,
          (col) => TileEntity(id: '$row-$col', value: 2, row: row, col: col),
        ),
      );
      final fullGame = emptyGame.copyWith(board: fullBoard);
      expect(fullGame.isBoardFull, true);
    });

    test('should handle performance tracking correctly', () {
      // Test frame rate tracking
      PerformanceUtils.trackFrameRate();
      expect(PerformanceUtils.getCurrentFPS(), greaterThanOrEqualTo(0));

      // Test performance acceptability
      expect(PerformanceUtils.isPerformanceAcceptable(), isA<bool>());

      // Test reset functionality
      PerformanceUtils.reset();
      expect(PerformanceUtils.getCurrentFPS(), 60.0); // Default when no data
    });

    test('MemoryOptimizer should track allocations when enabled', () {
      // Memory tracking only works when performance logging is enabled
      if (AppConstants.enablePerformanceLogging) {
        final initialCount = MemoryOptimizer.getAllocationCount(String);

        MemoryOptimizer.trackAllocation(String);
        MemoryOptimizer.trackAllocation(String);

        expect(MemoryOptimizer.getAllocationCount(String), initialCount + 2);

        MemoryOptimizer.reset();
        expect(MemoryOptimizer.getAllocationCount(String), 0);
      } else {
        // When performance logging is disabled, tracking should be no-op
        MemoryOptimizer.trackAllocation(String);
        expect(MemoryOptimizer.getAllocationCount(String), 0);
      }
    });

    test('should have efficient board state comparison', () {
      final game1 = GameEntity.newGame();
      final game2 = GameEntity.newGame();

      // Same reference should be identical
      expect(identical(game1, game1), true);

      // Different instances with same data should be equal
      expect(game1 == game2, true);

      // Different scores should be unequal (quick check)
      final game3 = game1.copyWith(score: 100);
      expect(game1 == game3, false);
    });

    test('should optimize empty position calculations', () {
      final game = GameEntity.newGame();

      // Test that isBoardFull doesn't create unnecessary lists
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        game.isBoardFull;
      }
      stopwatch.stop();

      // Should complete quickly (less than 10ms for 1000 iterations)
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });

    test('should have optimized tile position caching', () {
      // Test position cache functionality
      final pos1 = PositionUtils.getPositionForGrid(0, 0);
      final pos2 = PositionUtils.getPositionForGrid(0, 0);

      // Should return the same cached instance
      expect(identical(pos1, pos2), true);

      // Test cache size
      expect(PositionUtils.cacheSize, greaterThan(0));

      // Test cache clearing
      PositionUtils.clearCache();
      expect(PositionUtils.cacheSize, 0);
    });

    test('should handle concurrent animations efficiently', () {
      AnimationOptimizer.reset();

      // Test that we can handle the expected number of animations
      for (int i = 0; i < AppConstants.maxConcurrentAnimations; i++) {
        expect(AnimationOptimizer.canStartAnimation(), true);
        AnimationOptimizer.registerAnimation('tile$i');
      }

      // Should not allow more than max
      expect(AnimationOptimizer.canStartAnimation(), false);

      // Should suggest simplification when near limit
      AnimationOptimizer.reset();
      for (
        int i = 0;
        i < (AppConstants.maxConcurrentAnimations * 0.9).round();
        i++
      ) {
        AnimationOptimizer.registerAnimation('tile$i');
      }
      expect(AnimationOptimizer.shouldSimplifyAnimations(), true);
    });

    test('should maintain 60fps performance targets', () {
      // Verify that our constants support 60fps
      const targetFrameTime = 16.67; // 60fps = 16.67ms per frame

      expect(
        AppConstants.animationDurationFast,
        greaterThan(targetFrameTime * 2),
      );
      expect(AppConstants.swipeDebounceDelay.inMilliseconds, lessThan(100));

      // Animation durations should be reasonable for smooth animation
      expect(AppConstants.animationDurationFast, lessThanOrEqualTo(200));
      expect(AppConstants.animationDurationMedium, lessThanOrEqualTo(300));
    });
  });

  group('Memory Management Tests', () {
    test('should properly dispose resources', () {
      final pool = ObjectPool<List<int>>(
        factory: () => <int>[],
        reset: (list) => list.clear(),
        maxSize: 3,
      );

      // Test that reset function is called
      final list = pool.acquire();
      list.addAll([1, 2, 3]);
      expect(list.length, 3);

      pool.release(list);
      final reusedList = pool.acquire();
      expect(identical(list, reusedList), true);
      expect(reusedList.length, 0); // Should be cleared by reset function
    });

    test('should handle memory pressure gracefully', () {
      // Test that caches can be cleared under memory pressure
      for (int i = 0; i < 100; i++) {
        PositionUtils.getPositionForGrid(i.toDouble(), i.toDouble());
      }

      final initialCacheSize = PositionUtils.cacheSize;
      expect(initialCacheSize, 100);

      PositionUtils.clearCache();
      expect(PositionUtils.cacheSize, 0);
    });
  });
}
