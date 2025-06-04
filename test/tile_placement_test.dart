import 'package:flutter_test/flutter_test.dart';
import 'package:game/domain/entities/game_entity.dart';
import 'package:game/domain/entities/tile_entity.dart';
import 'package:game/data/repositories/game_repository_impl.dart';
import 'package:game/data/datasources/game_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Tile Placement Tests', () {
    late GameRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final dataSource = GameLocalDataSourceImpl(sharedPreferences);
      repository = GameRepositoryImpl(dataSource);
    });

    test('should place new tiles only in empty positions', () {
      // Create a game with some tiles already placed
      final gameState = GameEntity.newGame()
          .setTileAt(0, 0, TileEntity.withValue(2, 0, 0))
          .setTileAt(1, 1, TileEntity.withValue(4, 1, 1))
          .setTileAt(2, 2, TileEntity.withValue(8, 2, 2));

      // Get empty positions before adding new tile
      final emptyPositionsBefore = gameState.emptyPositions;
      expect(emptyPositionsBefore.length, 22); // 25 - 3 = 22 empty positions

      // Add a random tile
      final gameWithNewTile = repository.addRandomTile(gameState);

      // Verify that a new tile was added
      expect(gameWithNewTile.allTiles.length, 4);

      // Find the new tile
      final newTiles = gameWithNewTile.allTiles
          .where((tile) => !gameState.allTiles.any((existing) => existing.id == tile.id))
          .toList();

      expect(newTiles.length, 1);
      final newTile = newTiles.first;

      // Verify the new tile is placed in a previously empty position
      final newTilePosition = Position(newTile.row, newTile.col);
      expect(emptyPositionsBefore.contains(newTilePosition), true,
          reason: 'New tile at (${newTile.row}, ${newTile.col}) should be in a previously empty position');

      // Verify the position is no longer empty
      expect(gameWithNewTile.board[newTile.row][newTile.col], isNotNull);
      expect(gameWithNewTile.board[newTile.row][newTile.col]!.value, newTile.value);
    });

    test('should not add tile when board is full', () {
      // Create a full board
      var gameState = GameEntity.newGame();

      // Fill all positions
      for (int row = 0; row < 5; row++) {
        for (int col = 0; col < 5; col++) {
          gameState = gameState.setTileAt(row, col, TileEntity.withValue(2, row, col));
        }
      }

      expect(gameState.emptyPositions.length, 0);
      expect(gameState.isBoardFull, true);

      // Try to add a new tile
      final gameWithAttemptedTile = repository.addRandomTile(gameState);

      // Should be the same state (no new tile added)
      expect(gameWithAttemptedTile.allTiles.length, gameState.allTiles.length);
      expect(gameWithAttemptedTile, equals(gameState));
    });

    test('should place tiles randomly in different empty positions', () {
      final gameState = GameEntity.newGame()
          .setTileAt(2, 2, TileEntity.withValue(2, 2, 2)); // Place one tile in center

      final placedPositions = <Position>{};
      placedPositions.add(Position(2, 2)); // Add the initial tile position

      // Add multiple tiles and verify they're placed in different positions
      var currentState = gameState;
      for (int i = 0; i < 5; i++) { // Reduced to 5 to avoid complexity
        final emptyPositionsBefore = currentState.emptyPositions;
        currentState = repository.addRandomTile(currentState);

        // Find the newest tile by comparing with previous state
        final newTiles = currentState.allTiles
            .where((tile) => !placedPositions.any((pos) => pos.row == tile.row && pos.col == tile.col))
            .toList();

        expect(newTiles.length, 1, reason: 'Should have exactly one new tile');
        final newestTile = newTiles.first;
        final position = Position(newestTile.row, newestTile.col);

        // Verify it was placed in a previously empty position
        expect(emptyPositionsBefore.contains(position), true,
            reason: 'New tile should be placed in a previously empty position');

        placedPositions.add(position);
      }

      // Should have placed 5 new tiles plus the original one
      expect(currentState.allTiles.length, 6);
      expect(placedPositions.length, 6);
    });

    test('should create tiles with correct properties', () {
      final gameState = GameEntity.newGame();
      final gameWithNewTile = repository.addRandomTile(gameState);

      final newTile = gameWithNewTile.allTiles.first;

      // Verify tile properties
      expect([2, 4].contains(newTile.value), true, reason: 'New tile should have value 2 or 4');
      expect(newTile.isNew, true, reason: 'New tile should be marked as new');
      expect(newTile.isMerged, false, reason: 'New tile should not be marked as merged');
      expect(newTile.id.isNotEmpty, true, reason: 'New tile should have a unique ID');
      expect(newTile.row >= 0 && newTile.row < 5, true, reason: 'Row should be within bounds');
      expect(newTile.col >= 0 && newTile.col < 5, true, reason: 'Column should be within bounds');
    });

    test('should maintain game state consistency after adding tiles', () {
      var gameState = GameEntity.newGame();

      // Add several tiles
      for (int i = 0; i < 5; i++) {
        gameState = repository.addRandomTile(gameState);

        // Verify board consistency
        int tilesOnBoard = 0;
        for (int row = 0; row < 5; row++) {
          for (int col = 0; col < 5; col++) {
            if (gameState.board[row][col] != null) {
              tilesOnBoard++;
            }
          }
        }

        expect(tilesOnBoard, gameState.allTiles.length,
            reason: 'Number of tiles on board should match allTiles count');

        // Verify empty positions count
        expect(gameState.emptyPositions.length, 25 - tilesOnBoard,
            reason: 'Empty positions count should be correct');
      }
    });
  });
}
