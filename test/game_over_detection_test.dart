import 'package:flutter_test/flutter_test.dart';
import 'package:game/domain/entities/tile_entity.dart';
import 'package:game/domain/entities/game_entity.dart';
import 'package:game/data/repositories/game_repository_impl.dart';
import 'package:game/data/datasources/game_local_datasource.dart';
import 'package:game/domain/usecases/game_usecases.dart';
import 'package:game/data/models/game_model.dart';

void main() {
  group('Game Over Detection Tests', () {
    late GameRepositoryImpl repository;
    late MoveTilesUseCase moveTilesUseCase;
    late MockGameLocalDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockGameLocalDataSource();
      repository = GameRepositoryImpl(mockDataSource);
      moveTilesUseCase = MoveTilesUseCase(repository);
    });

    test('should detect game over after board fills up completely', () async {
      var game = GameEntity.newGame();

      // Create a completely full board with no possible moves
      // Pattern that prevents all merges
      for (int row = 0; row < 5; row++) {
        for (int col = 0; col < 5; col++) {
          // Alternate between 2 and 4 to prevent merges
          final value = (row + col) % 2 == 0 ? 2 : 4;
          final tile = TileEntity.withValue(value, row, col);
          game = game.setTileAt(row, col, tile);
        }
      }

      // Verify board is completely full and no moves possible
      expect(game.isBoardFull, true);
      expect(game.canMove, false);

      // Make a move attempt - should detect game over
      final newGame = await moveTilesUseCase.execute(game, MoveDirection.left);

      // Should be game over
      expect(newGame.isBoardFull, true);
      expect(newGame.canMove, false);
      expect(newGame.isGameOver, true);
    });

    test('should detect game over with blocker tiles blocking all moves', () async {
      var game = GameEntity.newGame();

      // Create a pattern where blocker tiles prevent all moves
      // [2][B][4][B][2]
      // [B][4][B][2][B]
      // [2][B][4][B][2]
      // [B][4][B][2][B]
      // [2][B][4][B][2] <- fill all spaces

      for (int row = 0; row < 5; row++) {
        for (int col = 0; col < 5; col++) {
          if ((row + col) % 2 == 1) {
            // Blocker tiles at odd positions
            final blockerTile = TileEntity.blocker(row, col);
            game = game.setTileAt(row, col, blockerTile);
          } else {
            // Normal tiles at even positions (alternating 2 and 4)
            final value = row % 2 == 0 ? 2 : 4;
            final tile = TileEntity.withValue(value, row, col);
            game = game.setTileAt(row, col, tile);
          }
        }
      }

      // Verify setup - board should be full and no moves possible
      expect(game.isBoardFull, true);
      expect(game.canMove, false);

      // Make a move attempt - should detect game over
      final newGame = await moveTilesUseCase.execute(game, MoveDirection.left);

      // Should be game over due to no possible moves
      expect(newGame.isBoardFull, true);
      expect(newGame.canMove, false);
      expect(newGame.isGameOver, true);
    });

    test('should not be game over if moves are still possible', () async {
      var game = GameEntity.newGame();

      // Create a board with possible merges
      game = game.setTileAt(0, 0, TileEntity.withValue(2, 0, 0));
      game = game.setTileAt(0, 1, TileEntity.withValue(2, 0, 1));
      game = game.setTileAt(1, 0, TileEntity.withValue(4, 1, 0));

      final newGame = await moveTilesUseCase.execute(game, MoveDirection.left);

      // Should not be game over - plenty of space and moves available
      expect(newGame.isGameOver, false);
      expect(newGame.canMove, true);
    });

    test('should handle blocker tile merges correctly in game over detection', () async {
      var game = GameEntity.newGame();

      // Create a scenario with two blocker tiles that can merge
      final blocker1 = TileEntity.blocker(0, 0);
      final blocker2 = TileEntity.blocker(0, 1);
      game = game.setTileAt(0, 0, blocker1);
      game = game.setTileAt(0, 1, blocker2);

      // Add a few more tiles but keep the board mostly empty
      game = game.setTileAt(1, 0, TileEntity.withValue(2, 1, 0));
      game = game.setTileAt(1, 1, TileEntity.withValue(4, 1, 1));

      // Move left - blockers should merge and disappear
      final newGame = await moveTilesUseCase.execute(game, MoveDirection.left);

      // Blockers should have disappeared, creating more space
      expect(newGame.getTileAt(0, 0), isNull);
      expect(newGame.getTileAt(0, 1), isNull);
      expect(newGame.isGameOver, false); // Should not be game over
    });
  });
}

// Mock implementation for testing
class MockGameLocalDataSource implements GameLocalDataSource {
  @override
  Future<void> clearAllData() async {}

  @override
  Future<void> clearGameState() async {}

  @override
  Future<int> loadBestScore() async => 0;

  @override
  Future<GameModel?> loadGameState() async => null;

  @override
  Future<GameStatisticsModel?> loadGameStatistics() async => null;

  @override
  Future<void> saveBestScore(int score) async {}

  @override
  Future<void> saveGameState(GameModel gameState) async {}

  @override
  Future<void> saveGameStatistics(GameStatisticsModel statistics) async {}
}
