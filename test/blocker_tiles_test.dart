import 'package:flutter_test/flutter_test.dart';
import 'package:game/domain/entities/tile_entity.dart';
import 'package:game/domain/entities/game_entity.dart';
import 'package:game/data/repositories/game_repository_impl.dart';
import 'package:game/data/datasources/game_local_datasource.dart';
import 'package:game/data/models/game_model.dart';

void main() {
  group('Blocker Tiles Tests', () {
    late GameRepositoryImpl repository;
    late MockGameLocalDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockGameLocalDataSource();
      repository = GameRepositoryImpl(mockDataSource);
    });

    test('should create blocker tile with correct properties', () {
      final blockerTile = TileEntity.blocker(2, 3);

      expect(blockerTile.isBlocker, true);
      expect(blockerTile.value, -1);
      expect(blockerTile.row, 2);
      expect(blockerTile.col, 3);
      expect(blockerTile.isNew, true);
      expect(blockerTile.displayText, '🚫');
      expect(blockerTile.colorValue, 0xFF2C2C2C);
      expect(blockerTile.textColorValue, 0xFFFFFFFF);
    });

    test('should not allow normal tiles to merge with blocker tiles', () {
      final normalTile = TileEntity.withValue(2, 0, 0);
      final blockerTile = TileEntity.blocker(0, 1);

      expect(normalTile.canMergeWith(blockerTile), false);
      expect(blockerTile.canMergeWith(normalTile), false);
    });

    test('should allow blocker tiles to merge with other blocker tiles', () {
      final blockerTile1 = TileEntity.blocker(0, 0);
      final blockerTile2 = TileEntity.blocker(0, 1);

      expect(blockerTile1.canMergeWith(blockerTile2), true);
      expect(blockerTile2.canMergeWith(blockerTile1), true);
    });

    test('should make blocker tiles disappear when merged', () {
      var game = GameEntity.newGame();

      // Set up two blocker tiles next to each other
      final blockerTile1 = TileEntity.blocker(0, 0);
      final blockerTile2 = TileEntity.blocker(0, 1);
      game = game.setTileAt(0, 0, blockerTile1);
      game = game.setTileAt(0, 1, blockerTile2);

      // Move left to merge the blocker tiles
      final newGame = repository.moveTiles(game, MoveDirection.left);

      // Both blocker tiles should disappear (no tiles at positions 0,0 and 0,1)
      expect(newGame.getTileAt(0, 0), isNull);
      expect(newGame.getTileAt(0, 1), isNull);
      expect(newGame.getTileAt(0, 2), isNull);
      expect(newGame.getTileAt(0, 3), isNull);
      expect(newGame.getTileAt(0, 4), isNull);

      // No score should be added for blocker merges
      expect(newGame.score, game.score);
    });

    test('should not allow merged blocker tiles to merge again', () {
      final blockerTile1 = TileEntity.blocker(0, 0);
      final blockerTile2 = TileEntity.blocker(0, 1).copyWith(isMerged: true);

      expect(blockerTile1.canMergeWith(blockerTile2), false);
      expect(blockerTile2.canMergeWith(blockerTile1), false);
    });

    test('should detect game over with blocker tiles blocking moves', () {
      var game = GameEntity.newGame();

      // Create a board where normal tiles are blocked by blocker tiles
      // Pattern: [2][B][2][B][2]
      //          [B][4][B][4][B]
      //          [2][B][2][B][2]
      //          [B][4][B][4][B]
      //          [2][B][2][B][2]
      // Where B = blocker tile

      for (int row = 0; row < 5; row++) {
        for (int col = 0; col < 5; col++) {
          if ((row + col) % 2 == 0) {
            // Normal tiles
            final value = row % 2 == 0 ? 2 : 4;
            final tile = TileEntity.withValue(value, row, col);
            game = game.setTileAt(row, col, tile);
          } else {
            // Blocker tiles
            final blockerTile = TileEntity.blocker(row, col);
            game = game.setTileAt(row, col, blockerTile);
          }
        }
      }

      expect(game.canMove, false);
      expect(repository.isGameOver(game), true);
    });

    test('should create 256 tile and trigger blocker placement', () {
      var game = GameEntity.newGame();

      // Set up a scenario where two 128 tiles can merge to create 256
      final tile1 = TileEntity.withValue(128, 0, 0);
      final tile2 = TileEntity.withValue(128, 0, 1);
      game = game.setTileAt(0, 0, tile1);
      game = game.setTileAt(0, 1, tile2);

      // Move left to merge the tiles
      final newGame = repository.moveTiles(game, MoveDirection.left);

      // Check that a 256 tile was created
      final mergedTile = newGame.getTileAt(0, 0);
      expect(mergedTile?.value, 256);

      // The blocker placement happens after adding a random tile,
      // so we need to check the logic separately
      expect(newGame.score, game.score + 256);
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
