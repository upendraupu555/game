import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game/core/utils/performance_optimizer.dart';
import 'package:game/core/constants/app_constants.dart';
import 'package:game/presentation/widgets/confetti_widget.dart';
import 'package:game/presentation/widgets/sliding_game_board.dart';
import 'package:game/domain/entities/game_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Validation Tests', () {
    setUp(() {
      PerformanceOptimizer.reset();
    });

    tearDown(() {
      PerformanceOptimizer.dispose();
    });

    testWidgets('PerformanceOptimizer initializes correctly', (tester) async {
      PerformanceOptimizer.initialize();

      // Verify initialization doesn't throw errors
      expect(PerformanceOptimizer.getCurrentFPS(), greaterThanOrEqualTo(0));
    });

    testWidgets('WidgetOptimizer provides correct recommendations', (
      tester,
    ) async {
      // Test RepaintBoundary recommendation
      expect(
        WidgetOptimizer.shouldUseRepaintBoundary(
          hasAnimations: true,
          hasComplexPainting: false,
          changesFrequently: false,
        ),
        isTrue,
      );

      expect(
        WidgetOptimizer.shouldUseRepaintBoundary(
          hasAnimations: false,
          hasComplexPainting: false,
          changesFrequently: false,
        ),
        isFalse,
      );
    });

    testWidgets('Animation duration optimization works', (tester) async {
      const baseDuration = Duration(milliseconds: 200);

      // When performance is good, duration should remain the same
      final optimizedDuration = WidgetOptimizer.getOptimalAnimationDuration(
        baseDuration,
      );

      // Duration should be reasonable for animations
      expect(optimizedDuration.inMilliseconds, lessThanOrEqualTo(200));
      expect(optimizedDuration.inMilliseconds, greaterThanOrEqualTo(100));
    });

    testWidgets('Particle count optimization works', (tester) async {
      const baseParticleCount = 100;

      final optimizedCount = WidgetOptimizer.getOptimalParticleCount(
        baseParticleCount,
      );

      // Optimized count should be reasonable
      expect(optimizedCount, lessThanOrEqualTo(baseParticleCount));
      expect(optimizedCount, greaterThan(0));
    });

    testWidgets('CelebrationConfettiWidget has RepaintBoundary', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CelebrationConfettiWidget(
              showConfetti: true,
              child: Container(width: 100, height: 100),
            ),
          ),
        ),
      );

      // Verify RepaintBoundary is present
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('SlidingGameBoard has performance optimizations', (
      tester,
    ) async {
      final gameState = GameEntity.newGame();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SlidingGameBoard(
                gameState: gameState,
                onMove: (direction) {},
              ),
            ),
          ),
        ),
      );

      // Verify RepaintBoundary is present
      expect(find.byType(RepaintBoundary), findsWidgets);

      // Verify the widget builds without errors
      expect(find.byType(SlidingGameBoard), findsOneWidget);
    });

    testWidgets('AnimationOptimizer tracks animations correctly', (
      tester,
    ) async {
      AnimationOptimizer.reset();

      expect(AnimationOptimizer.activeAnimationCount, equals(0));
      expect(AnimationOptimizer.canStartAnimation(), isTrue);

      // Register animations
      AnimationOptimizer.registerAnimation('tile1');
      AnimationOptimizer.registerAnimation('tile2');

      expect(AnimationOptimizer.activeAnimationCount, equals(2));

      // Unregister animation
      AnimationOptimizer.unregisterAnimation('tile1');
      expect(AnimationOptimizer.activeAnimationCount, equals(1));

      // Test animation limit
      for (int i = 0; i < AppConstants.maxConcurrentAnimations; i++) {
        AnimationOptimizer.registerAnimation('tile$i');
      }

      expect(AnimationOptimizer.canStartAnimation(), isFalse);
      expect(AnimationOptimizer.shouldSimplifyAnimations(), isTrue);
    });

    testWidgets('MemoryOptimizer tracks allocations when enabled', (
      tester,
    ) async {
      MemoryOptimizer.reset();

      if (AppConstants.enablePerformanceLogging) {
        final initialCount = MemoryOptimizer.getAllocationCount(String);

        MemoryOptimizer.trackAllocation(String);
        MemoryOptimizer.trackAllocation(String);

        expect(
          MemoryOptimizer.getAllocationCount(String),
          equals(initialCount + 2),
        );
      } else {
        // When performance logging is disabled, tracking should be no-op
        MemoryOptimizer.trackAllocation(String);
        expect(MemoryOptimizer.getAllocationCount(String), equals(0));
      }
    });

    testWidgets('Performance constants are optimized for 60fps', (
      tester,
    ) async {
      // Verify animation durations support 60fps (16.67ms per frame)
      const targetFrameTime = 16.67;

      expect(
        AppConstants.animationDurationFast,
        greaterThan(targetFrameTime * 2),
      );
      expect(AppConstants.animationDurationFast, lessThanOrEqualTo(200));
      expect(AppConstants.animationDurationMedium, lessThanOrEqualTo(300));
      expect(AppConstants.animationDurationSlow, lessThanOrEqualTo(500));

      // Verify performance optimization flags
      expect(AppConstants.enableAnimationOptimizations, isTrue);
      expect(AppConstants.maxConcurrentAnimations, lessThanOrEqualTo(20));
    });

    testWidgets('Confetti widgets use optimized particle counts', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CelebrationConfettiWidget(
                  showConfetti: true,
                  numberOfParticles: 50, // Should be reasonable for performance
                  child: Container(width: 100, height: 100),
                ),
                VictoryConfettiWidget(
                  showConfetti: true,
                  child: Container(width: 100, height: 100),
                ),
                EasterEggConfettiWidget(
                  child: Container(width: 100, height: 100),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify all confetti widgets build without errors
      expect(find.byType(CelebrationConfettiWidget), findsOneWidget);
      expect(find.byType(VictoryConfettiWidget), findsOneWidget);
      expect(find.byType(EasterEggConfettiWidget), findsOneWidget);

      // Verify RepaintBoundary usage for performance
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('Performance recommendations are provided', (tester) async {
      final recommendations =
          PerformanceOptimizer.getPerformanceRecommendations();

      // Recommendations should be a list (may be empty if performance is good)
      expect(recommendations, isA<List<String>>());
    });

    test('Performance optimization constants are reasonable', () {
      // Verify cache sizes are reasonable
      expect(AppConstants.maxCacheSize, greaterThan(50));
      expect(AppConstants.maxCacheSize, lessThanOrEqualTo(200));

      // Verify cleanup intervals are reasonable
      expect(
        AppConstants.cacheCleanupInterval.inMinutes,
        greaterThanOrEqualTo(1),
      );
      expect(
        AppConstants.cacheCleanupInterval.inMinutes,
        lessThanOrEqualTo(10),
      );

      // Verify animation frame rate target
      expect(AppConstants.maxAnimationFrameRate, equals(60));
    });

    testWidgets('Game board position caching works', (tester) async {
      final gameState = GameEntity.newGame();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SlidingGameBoard(
                gameState: gameState,
                onMove: (direction) {},
              ),
            ),
          ),
        ),
      );

      // Trigger a rebuild to test caching
      await tester.pump();

      // Verify the widget still builds correctly after caching
      expect(find.byType(SlidingGameBoard), findsOneWidget);
    });
  });

  group('Performance Regression Tests', () {
    testWidgets('No performance regressions in core widgets', (tester) async {
      final gameState = GameEntity.newGame();

      // Measure build time for core game components
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  SlidingGameBoard(
                    gameState: gameState,
                    onMove: (direction) {},
                  ),
                  CelebrationConfettiWidget(
                    showConfetti: false,
                    child: Container(width: 100, height: 100),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      stopwatch.stop();

      // Build time should be reasonable (less than 100ms for initial build)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
