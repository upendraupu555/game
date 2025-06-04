import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game/domain/entities/game_entity.dart';
import 'package:game/domain/entities/tile_entity.dart';
import 'package:game/presentation/widgets/sliding_game_board.dart';

void main() {
  group('SlidingGameBoard Widget Tests', () {
    testWidgets('should render empty game board correctly', (
      WidgetTester tester,
    ) async {
      // Create an empty game state
      final gameState = GameEntity.newGame();
      bool moveCalled = false;
      MoveDirection? lastDirection;

      // Build the widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SlidingGameBoard(
                gameState: gameState,
                onMove: (direction) {
                  moveCalled = true;
                  lastDirection = direction;
                },
              ),
            ),
          ),
        ),
      );

      // Verify the widget renders
      expect(find.byType(SlidingGameBoard), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should render game board with tiles correctly', (
      WidgetTester tester,
    ) async {
      // Create a game state with some tiles
      final gameState = GameEntity.newGame()
          .setTileAt(0, 0, TileEntity.withValue(2, 0, 0))
          .setTileAt(1, 1, TileEntity.withValue(4, 1, 1))
          .setTileAt(2, 2, TileEntity.withValue(8, 2, 2));

      bool moveCalled = false;

      // Build the widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SlidingGameBoard(
                gameState: gameState,
                onMove: (direction) {
                  moveCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Verify tiles are rendered
      expect(find.text('2'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('should handle swipe gestures correctly', (
      WidgetTester tester,
    ) async {
      final gameState = GameEntity.newGame().setTileAt(
        0,
        0,
        TileEntity.withValue(2, 0, 0),
      );

      MoveDirection? lastDirection;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SlidingGameBoard(
                gameState: gameState,
                onMove: (direction) {
                  lastDirection = direction;
                },
              ),
            ),
          ),
        ),
      );

      // Find the gesture detector
      final gestureDetector = find.byType(GestureDetector);
      expect(gestureDetector, findsOneWidget);

      // Test right swipe
      await tester.fling(gestureDetector, const Offset(100, 0), 1000);
      await tester.pumpAndSettle();
      expect(lastDirection, MoveDirection.right);

      // Reset for next test
      lastDirection = null;
    });

    testWidgets('should render tiles with correct values', (
      WidgetTester tester,
    ) async {
      // Create game state with tiles
      final gameState = GameEntity.newGame()
          .setTileAt(0, 0, TileEntity.withValue(2, 0, 0))
          .setTileAt(1, 1, TileEntity.withValue(4, 1, 1));

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

      // Wait for render to complete
      await tester.pumpAndSettle();

      // Verify tiles are displayed instantly without entrance animation
      expect(find.text('2'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });
  });
}
