import 'dart:math' as math;
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/tile_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../../core/logging/app_logger.dart';
import '../datasources/game_local_datasource.dart';
import '../models/game_model.dart';

/// Implementation of game repository
/// Following clean architecture - data layer implements domain contracts
class GameRepositoryImpl implements GameRepository {
  final GameLocalDataSource _localDataSource;
  final math.Random _random = math.Random();

  GameRepositoryImpl(this._localDataSource);

  @override
  Future<GameEntity> initializeGame() async {
    final bestScore = await loadBestScore();
    return GameEntity.newGame().copyWith(bestScore: bestScore);
  }

  @override
  Future<void> saveGameState(GameEntity gameState) async {
    final model = GameModel.fromEntity(gameState);
    await _localDataSource.saveGameState(model);
  }

  @override
  Future<GameEntity?> loadGameState() async {
    final model = await _localDataSource.loadGameState();
    return model?.toEntity();
  }

  @override
  Future<void> clearGameState() async {
    await _localDataSource.clearGameState();
  }

  @override
  Future<void> saveBestScore(int score) async {
    await _localDataSource.saveBestScore(score);
  }

  @override
  Future<int> loadBestScore() async {
    return await _localDataSource.loadBestScore();
  }

  @override
  GameEntity moveTiles(GameEntity currentState, MoveDirection direction) {
    // Optimized board copying - only copy non-null tiles
    final newBoard = List.generate(
      5,
      (row) => List<TileEntity?>.filled(5, null),
    );

    // Copy and reset flags in one pass
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        final tile = currentState.board[row][col];
        if (tile != null) {
          newBoard[row][col] = tile.resetFlags();
        }
      }
    }

    int scoreIncrease = 0;
    bool moved = false;
    final List<TileEntity> highValueMerges = []; // Track 256+ merges

    switch (direction) {
      case MoveDirection.left:
        for (int row = 0; row < 5; row++) {
          final result = _moveRowLeft(newBoard[row]);
          newBoard[row] = result.tiles;
          scoreIncrease += result.score;
          if (result.moved) moved = true;
          highValueMerges.addAll(result.highValueMerges);
        }
        break;
      case MoveDirection.right:
        for (int row = 0; row < 5; row++) {
          final result = _moveRowRight(newBoard[row]);
          newBoard[row] = result.tiles;
          scoreIncrease += result.score;
          if (result.moved) moved = true;
          highValueMerges.addAll(result.highValueMerges);
        }
        break;
      case MoveDirection.up:
        for (int col = 0; col < 5; col++) {
          final column = List.generate(5, (row) => newBoard[row][col]);
          final result = _moveRowLeft(column);
          for (int row = 0; row < 5; row++) {
            newBoard[row][col] = result.tiles[row];
          }
          scoreIncrease += result.score;
          if (result.moved) moved = true;
          highValueMerges.addAll(result.highValueMerges);
        }
        break;
      case MoveDirection.down:
        for (int col = 0; col < 5; col++) {
          final column = List.generate(5, (row) => newBoard[row][col]);
          final result = _moveRowRight(column);
          for (int row = 0; row < 5; row++) {
            newBoard[row][col] = result.tiles[row];
          }
          scoreIncrease += result.score;
          if (result.moved) moved = true;
          highValueMerges.addAll(result.highValueMerges);
        }
        break;
    }

    if (!moved) return currentState;

    final newScore = currentState.score + scoreIncrease;
    var newState = currentState.copyWith(
      board: newBoard,
      score: newScore,
      lastPlayed: DateTime.now(),
    );

    // Add blocker tiles if any 256+ merges occurred
    if (highValueMerges.isNotEmpty) {
      newState = _addBlockerTiles(newState, highValueMerges.length);
    }

    // Check win condition
    final hasWon = hasPlayerWon(newState);

    // Check game over condition
    final isGameOver = this.isGameOver(newState);

    return newState.copyWith(hasWon: hasWon, isGameOver: isGameOver);
  }

  @override
  GameEntity addRandomTile(GameEntity currentState) {
    final emptyPositions = currentState.emptyPositions;

    AppLogger.debug(
      '🎯 Adding random tile',
      tag: 'GameRepository',
      data: {
        'emptyPositionsCount': emptyPositions.length,
        'emptyPositions': emptyPositions
            .map((p) => '(${p.row},${p.col})')
            .toList(),
      },
    );

    if (emptyPositions.isEmpty) {
      AppLogger.warning(
        '❌ No empty positions available for new tile',
        tag: 'GameRepository',
      );
      return currentState;
    }

    final randomPosition =
        emptyPositions[_random.nextInt(emptyPositions.length)];
    final newTile = TileEntity.random(randomPosition.row, randomPosition.col);

    AppLogger.newTile(
      value: newTile.value,
      row: newTile.row,
      col: newTile.col,
      tileId: newTile.id,
      emptyPositionsCount: emptyPositions.length,
    );

    return currentState.setTileAt(
      randomPosition.row,
      randomPosition.col,
      newTile,
    );
  }

  @override
  bool isGameOver(GameEntity gameState) {
    return !gameState.canMove;
  }

  @override
  bool hasPlayerWon(GameEntity gameState) {
    if (gameState.hasWon) return true;

    for (final tile in gameState.allTiles) {
      if (tile.value >= 2048) return true;
    }
    return false;
  }

  @override
  int calculateMoveScore(GameEntity beforeState, GameEntity afterState) {
    return afterState.score - beforeState.score;
  }

  @override
  Future<GameStatistics> getGameStatistics() async {
    final model = await _localDataSource.loadGameStatistics();
    return model?.toEntity() ?? GameStatistics.empty();
  }

  @override
  Future<void> saveGameStatistics(GameStatistics statistics) async {
    final model = GameStatisticsModel.fromEntity(statistics);
    await _localDataSource.saveGameStatistics(model);
  }

  @override
  Future<void> resetAllData() async {
    await _localDataSource.clearAllData();
  }

  /// Move a row to the left (or up when applied to columns)
  MoveResult _moveRowLeft(List<TileEntity?> row) {
    final tiles = List<TileEntity?>.from(row);
    final nonNullTiles = tiles
        .where((tile) => tile != null)
        .cast<TileEntity>()
        .toList();

    if (nonNullTiles.isEmpty) {
      return MoveResult(tiles: tiles, score: 0, moved: false);
    }

    final newTiles = <TileEntity?>[]..length = 5;
    int score = 0;
    bool moved = false;
    int writeIndex = 0;
    final List<TileEntity> highValueMerges = [];

    for (int i = 0; i < nonNullTiles.length; i++) {
      final currentTile = nonNullTiles[i];

      if (i < nonNullTiles.length - 1) {
        final nextTile = nonNullTiles[i + 1];

        if (currentTile.canMergeWith(nextTile)) {
          // Special handling for blocker tiles - they disappear when merged
          if (currentTile.isBlocker && nextTile.isBlocker) {
            // Blocker tiles disappear when merged, don't add anything to the board
            moved = true;
            // No score increase for blocker merges
            // No tile added to writeIndex position
            i++; // Skip next tile as it's been merged
            continue;
          } else {
            // Normal tile merge
            final mergedTile = currentTile.merge().copyWith(
              row: writeIndex ~/ 4,
              col: writeIndex % 4,
            );
            newTiles[writeIndex] = mergedTile;
            score += mergedTile.value;
            moved = true;

            // Track high-value merges (256+) for blocker placement
            if (!mergedTile.isBlocker && mergedTile.value >= 256) {
              highValueMerges.add(mergedTile);
            }

            writeIndex++;
            i++; // Skip next tile as it's been merged
            continue;
          }
        }
      }

      // Move tile to new position
      final movedTile = currentTile.copyWith(
        row: writeIndex ~/ 4,
        col: writeIndex % 4,
      );

      if (movedTile.row != currentTile.row ||
          movedTile.col != currentTile.col) {
        moved = true;
      }

      newTiles[writeIndex] = movedTile;
      writeIndex++;
    }

    // Fill remaining positions with null
    for (int i = writeIndex; i < 5; i++) {
      newTiles[i] = null;
    }

    return MoveResult(
      tiles: newTiles,
      score: score,
      moved: moved,
      highValueMerges: highValueMerges,
    );
  }

  /// Move a row to the right (or down when applied to columns)
  MoveResult _moveRowRight(List<TileEntity?> row) {
    final reversed = row.reversed.toList();
    final result = _moveRowLeft(reversed);
    final tiles = result.tiles.reversed.toList();

    return MoveResult(
      tiles: tiles,
      score: result.score,
      moved: result.moved,
      highValueMerges: result.highValueMerges,
    );
  }

  /// Add blocker tiles to the board after high-value merges
  GameEntity _addBlockerTiles(GameEntity gameState, int blockerCount) {
    final emptyPositions = gameState.emptyPositions;

    if (emptyPositions.isEmpty) {
      return gameState; // No space for blockers
    }

    var newBoard = List.generate(
      5,
      (row) => List.generate(5, (col) => gameState.board[row][col]),
    );

    // Add one blocker tile for each high-value merge (up to available empty spaces)
    final blockersToAdd = math.min(blockerCount, emptyPositions.length);

    for (int i = 0; i < blockersToAdd; i++) {
      final randomIndex = _random.nextInt(emptyPositions.length - i);
      final position = emptyPositions[randomIndex];

      // Create blocker tile
      final blockerTile = TileEntity.blocker(position.row, position.col);
      newBoard[position.row][position.col] = blockerTile;

      // Remove this position from available positions
      emptyPositions.removeAt(randomIndex);

      AppLogger.debug(
        '🚫 Blocker tile added',
        tag: 'GameRepository',
        data: {
          'position': '(${position.row},${position.col})',
          'blockerCount': i + 1,
          'totalBlockers': blockersToAdd,
        },
      );
    }

    return gameState.copyWith(board: newBoard);
  }
}

/// Result of a move operation
class MoveResult {
  final List<TileEntity?> tiles;
  final int score;
  final bool moved;
  final List<TileEntity> highValueMerges;

  const MoveResult({
    required this.tiles,
    required this.score,
    required this.moved,
    this.highValueMerges = const [],
  });
}
