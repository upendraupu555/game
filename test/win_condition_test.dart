import 'package:flutter_test/flutter_test.dart';
import 'package:game/domain/entities/game_entity.dart';
import 'package:game/domain/entities/tile_entity.dart';
import 'package:game/data/repositories/game_repository_impl.dart';
import 'package:game/data/datasources/game_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Win Condition Tests', () {
    late GameRepositoryImpl repository;
    late GameLocalDataSourceImpl dataSource;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      dataSource = GameLocalDataSourceImpl(sharedPreferences);
      repository = GameRepositoryImpl(dataSource);
    });

    test('should detect win condition when 2048 tile is created', () {
      // Create a game state with a 2048 tile
      var gameState = GameEntity.newGame();
      final tile2048 = TileEntity.withValue(2048, 0, 0);
      gameState = gameState.setTileAt(0, 0, tile2048);

      // Check win condition
      final hasWon = repository.hasPlayerWon(gameState);
      expect(hasWon, true);
    });

    test('should preserve win condition once achieved', () {
      // Create a game state with a 2048 tile and hasWon = true
      var gameState = GameEntity.newGame().copyWith(hasWon: true);
      final tile2048 = TileEntity.withValue(2048, 0, 0);
      gameState = gameState.setTileAt(0, 0, tile2048);

      // Check win condition is preserved
      final hasWon = repository.hasPlayerWon(gameState);
      expect(hasWon, true);
    });

    test('should preserve win condition when adding random tile', () {
      // Create a game state with a 2048 tile and hasWon = true
      var gameState = GameEntity.newGame().copyWith(hasWon: true);
      final tile2048 = TileEntity.withValue(2048, 0, 0);
      gameState = gameState.setTileAt(0, 0, tile2048);

      // Add a random tile (this should preserve the win state)
      final newGameState = repository.addRandomTile(gameState);
      
      expect(newGameState.hasWon, true);
    });

    test('should detect win condition with tiles higher than 2048', () {
      // Create a game state with a 4096 tile
      var gameState = GameEntity.newGame();
      final tile4096 = TileEntity.withValue(4096, 0, 0);
      gameState = gameState.setTileAt(0, 0, tile4096);

      // Check win condition
      final hasWon = repository.hasPlayerWon(gameState);
      expect(hasWon, true);
    });

    test('should not detect win condition with tiles less than 2048', () {
      // Create a game state with a 1024 tile
      var gameState = GameEntity.newGame();
      final tile1024 = TileEntity.withValue(1024, 0, 0);
      gameState = gameState.setTileAt(0, 0, tile1024);

      // Check win condition
      final hasWon = repository.hasPlayerWon(gameState);
      expect(hasWon, false);
    });

    test('should preserve win state during tile movement', () {
      // Create a game state with hasWon = true and some tiles
      var gameState = GameEntity.newGame().copyWith(hasWon: true);
      final tile2 = TileEntity.withValue(2, 0, 0);
      final tile4 = TileEntity.withValue(4, 0, 1);
      gameState = gameState.setTileAt(0, 0, tile2);
      gameState = gameState.setTileAt(0, 1, tile4);

      // Move tiles (this should preserve the win state)
      final newGameState = repository.moveTiles(gameState, MoveDirection.left);
      
      expect(newGameState.hasWon, true);
    });

    test('should detect win condition during tile movement when 2048 is created', () {
      // Create a game state with two 1024 tiles that can merge to 2048
      var gameState = GameEntity.newGame();
      final tile1024_1 = TileEntity.withValue(1024, 0, 0);
      final tile1024_2 = TileEntity.withValue(1024, 0, 1);
      gameState = gameState.setTileAt(0, 0, tile1024_1);
      gameState = gameState.setTileAt(0, 1, tile1024_2);

      // Move tiles left to merge them into 2048
      final newGameState = repository.moveTiles(gameState, MoveDirection.left);
      
      expect(newGameState.hasWon, true);
      
      // Check that a 2048 tile was created
      final tiles = newGameState.allTiles;
      final has2048Tile = tiles.any((tile) => tile.value == 2048);
      expect(has2048Tile, true);
    });

    test('should handle game over condition correctly when won', () {
      // Create a full board with a 2048 tile and no possible moves
      var gameState = GameEntity.newGame().copyWith(hasWon: true);
      
      // Fill the board with alternating values that can't merge
      for (int row = 0; row < 5; row++) {
        for (int col = 0; col < 5; col++) {
          int value;
          if (row == 0 && col == 0) {
            value = 2048; // Winning tile
          } else {
            value = (row + col) % 2 == 0 ? 2 : 4; // Alternating pattern
          }
          final tile = TileEntity.withValue(value, row, col);
          gameState = gameState.setTileAt(row, col, tile);
        }
      }

      // Check that the game is both won and over
      expect(gameState.hasWon, true);
      expect(repository.isGameOver(gameState), true);
      expect(repository.hasPlayerWon(gameState), true);
    });

    test('should continue playing after winning', () {
      // Create a game state with a 2048 tile but still has empty spaces
      var gameState = GameEntity.newGame().copyWith(hasWon: true);
      final tile2048 = TileEntity.withValue(2048, 0, 0);
      final tile2 = TileEntity.withValue(2, 1, 0);
      gameState = gameState.setTileAt(0, 0, tile2048);
      gameState = gameState.setTileAt(1, 0, tile2);

      // Game should be won but not over (can continue playing)
      expect(gameState.hasWon, true);
      expect(repository.isGameOver(gameState), false);
      expect(gameState.canMove, true);
    });
  });
}
