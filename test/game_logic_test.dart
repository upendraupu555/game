import 'package:flutter_test/flutter_test.dart';
import 'package:game/domain/entities/game_entity.dart';
import 'package:game/domain/entities/tile_entity.dart';
import 'package:game/data/repositories/game_repository_impl.dart';
import 'package:game/data/datasources/game_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('2048 Game Logic Tests', () {
    late GameRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final dataSource = GameLocalDataSourceImpl(prefs);
      repository = GameRepositoryImpl(dataSource);
    });

    test('should initialize empty game', () async {
      final game = await repository.initializeGame();

      expect(game.score, 0);
      expect(game.isGameOver, false);
      expect(game.hasWon, false);
      expect(game.board.length, 5);
      expect(game.board[0].length, 5);

      // All tiles should be null initially
      for (int row = 0; row < 5; row++) {
        for (int col = 0; col < 5; col++) {
          expect(game.board[row][col], isNull);
        }
      }
    });

    test('should add random tile to empty board', () {
      final emptyGame = GameEntity.newGame();
      final gameWithTile = repository.addRandomTile(emptyGame);

      // Should have exactly one tile
      final tiles = gameWithTile.allTiles;
      expect(tiles.length, 1);

      // Tile should have value 2 or 4
      final tile = tiles.first;
      expect([2, 4].contains(tile.value), true);
      expect(tile.isNew, true);
    });

    test('should move tiles left correctly', () {
      // Create a game with tiles in specific positions
      var game = GameEntity.newGame();

      // Add tiles manually for testing
      final tile1 = TileEntity.withValue(2, 0, 1);
      final tile2 = TileEntity.withValue(2, 0, 3);

      game = game.setTileAt(0, 1, tile1);
      game = game.setTileAt(0, 3, tile2);

      // Move left
      final movedGame = repository.moveTiles(game, MoveDirection.left);

      // Tiles should move to leftmost positions
      expect(movedGame.getTileAt(0, 0)?.value, 4); // Merged tile
      expect(movedGame.getTileAt(0, 1), isNull);
      expect(movedGame.getTileAt(0, 2), isNull);
      expect(movedGame.getTileAt(0, 3), isNull);

      // Score should increase
      expect(movedGame.score, 4);
    });

    test('should detect win condition', () {
      var game = GameEntity.newGame();

      // Add a 2048 tile
      final winningTile = TileEntity.withValue(2048, 0, 0);
      game = game.setTileAt(0, 0, winningTile);

      final hasWon = repository.hasPlayerWon(game);
      expect(hasWon, true);
    });

    test('should detect game over condition', () {
      // Create a full board with no possible moves
      var game = GameEntity.newGame();

      // Fill board with alternating values that can't merge
      for (int row = 0; row < 5; row++) {
        for (int col = 0; col < 5; col++) {
          final value = (row + col) % 2 == 0 ? 2 : 4;
          final tile = TileEntity.withValue(value, row, col);
          game = game.setTileAt(row, col, tile);
        }
      }

      final isGameOver = repository.isGameOver(game);
      expect(isGameOver, true);
    });

    test('should not move tiles when no movement possible', () {
      // Create a game with tiles that can't move left
      var game = GameEntity.newGame();

      final tile1 = TileEntity.withValue(2, 0, 0);
      final tile2 = TileEntity.withValue(4, 0, 1);

      game = game.setTileAt(0, 0, tile1);
      game = game.setTileAt(0, 1, tile2);

      // Try to move left (should not change anything)
      final movedGame = repository.moveTiles(game, MoveDirection.left);

      // Game state should be unchanged
      expect(movedGame.getTileAt(0, 0)?.value, 2);
      expect(movedGame.getTileAt(0, 1)?.value, 4);
      expect(movedGame.score, 0);
    });

    test('should merge multiple pairs in one move', () {
      var game = GameEntity.newGame();

      // Create a row with two pairs that can merge: [2, 2, 4, 4]
      game = game.setTileAt(0, 0, TileEntity.withValue(2, 0, 0));
      game = game.setTileAt(0, 1, TileEntity.withValue(2, 0, 1));
      game = game.setTileAt(0, 2, TileEntity.withValue(4, 0, 2));
      game = game.setTileAt(0, 3, TileEntity.withValue(4, 0, 3));

      final movedGame = repository.moveTiles(game, MoveDirection.left);

      // Should result in [4, 8, null, null]
      expect(movedGame.getTileAt(0, 0)?.value, 4);
      expect(movedGame.getTileAt(0, 1)?.value, 8);
      expect(movedGame.getTileAt(0, 2), isNull);
      expect(movedGame.getTileAt(0, 3), isNull);

      // Score should be 4 + 8 = 12
      expect(movedGame.score, 12);
    });

    test('should handle vertical movement correctly', () {
      var game = GameEntity.newGame();

      // Create a column with tiles that can merge
      game = game.setTileAt(1, 0, TileEntity.withValue(2, 1, 0));
      game = game.setTileAt(3, 0, TileEntity.withValue(2, 3, 0));

      final movedGame = repository.moveTiles(game, MoveDirection.up);

      // Should merge to top
      expect(movedGame.getTileAt(0, 0)?.value, 4);
      expect(movedGame.getTileAt(1, 0), isNull);
      expect(movedGame.getTileAt(2, 0), isNull);
      expect(movedGame.getTileAt(3, 0), isNull);

      expect(movedGame.score, 4);
    });
  });
}
