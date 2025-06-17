import '../entities/game_entity.dart';
import '../entities/powerup_entity.dart';
import '../entities/tile_entity.dart';
import '../../core/logging/app_logger.dart';

/// Use case for executing tile destroyer powerup effect
class ExecuteTileDestroyerUseCase {
  ExecuteTileDestroyerUseCase();

  /// Execute tile destroyer effect on the specified position
  GameEntity execute(GameEntity gameState, int row, int col) {
    AppLogger.userAction(
      'TILE_DESTROYER_EXECUTED',
      data: {'targetRow': row, 'targetCol': col, 'score': gameState.score},
    );

    // Validate position
    if (row < 0 ||
        row >= gameState.board.length ||
        col < 0 ||
        col >= gameState.board[0].length) {
      AppLogger.warning(
        'Invalid tile position for destroyer',
        tag: 'ExecuteTileDestroyerUseCase',
        data: {
          'row': row,
          'col': col,
          'boardSize': '${gameState.board.length}x${gameState.board[0].length}',
        },
      );
      return gameState;
    }

    // Check if there's a tile at the position
    if (gameState.board[row][col] == null) {
      AppLogger.warning(
        'No tile to destroy at position',
        tag: 'ExecuteTileDestroyerUseCase',
        data: {'row': row, 'col': col},
      );
      return gameState;
    }

    // Create new board with the tile removed
    final newBoard = List.generate(
      gameState.board.length,
      (r) => List.generate(
        gameState.board[0].length,
        (c) => (r == row && c == col) ? null : gameState.board[r][c],
      ),
    );

    // Calculate score bonus for destroying a tile
    final destroyedTile = gameState.board[row][col]!;
    final scoreBonus = (destroyedTile.value * 0.1).round(); // 10% of tile value

    final newState = gameState.copyWith(
      board: newBoard,
      score: gameState.score + scoreBonus,
    );

    // Check if game over condition changed after tile destruction
    final isGameOver = !newState.canMove;

    return newState.copyWith(
      isGameOver: isGameOver,
      // hasWon is preserved automatically by copyWith
    );
  }
}

/// Use case for executing row clear powerup effect
class ExecuteRowClearUseCase {
  ExecuteRowClearUseCase();

  /// Execute row clear effect on the specified row
  GameEntity execute(GameEntity gameState, int row, int col) {
    AppLogger.userAction(
      'ROW_CLEAR_EXECUTED',
      data: {'targetRow': row, 'targetCol': col, 'score': gameState.score},
    );

    // Validate position
    if (row < 0 || row >= gameState.board.length) {
      AppLogger.warning(
        'Invalid row for clear',
        tag: 'ExecuteRowClearUseCase',
        data: {'row': row, 'boardHeight': gameState.board.length},
      );
      return gameState;
    }

    // Create new board with the entire row cleared
    final newBoard = List.generate(
      gameState.board.length,
      (r) => List.generate(
        gameState.board[0].length,
        (c) => (r == row) ? null : gameState.board[r][c],
      ),
    );

    // Calculate score bonus for clearing a row
    int scoreBonus = 0;
    for (int c = 0; c < gameState.board[0].length; c++) {
      final tile = gameState.board[row][c];
      if (tile != null) {
        scoreBonus += (tile.value * 0.05).round(); // 5% of each tile value
      }
    }

    final newState = gameState.copyWith(
      board: newBoard,
      score: gameState.score + scoreBonus,
    );

    // Check if game over condition changed after row clear
    final isGameOver = !newState.canMove;

    return newState.copyWith(
      isGameOver: isGameOver,
      // hasWon is preserved automatically by copyWith
    );
  }
}

/// Use case for executing column clear powerup effect
class ExecuteColumnClearUseCase {
  ExecuteColumnClearUseCase();

  /// Execute column clear effect on the specified column
  GameEntity execute(GameEntity gameState, int row, int col) {
    AppLogger.userAction(
      'COLUMN_CLEAR_EXECUTED',
      data: {'targetRow': row, 'targetCol': col, 'score': gameState.score},
    );

    // Validate position
    if (col < 0 || col >= gameState.board[0].length) {
      AppLogger.warning(
        'Invalid column for clear',
        tag: 'ExecuteColumnClearUseCase',
        data: {'col': col, 'boardWidth': gameState.board[0].length},
      );
      return gameState;
    }

    // Create new board with the entire column cleared
    final newBoard = List.generate(
      gameState.board.length,
      (r) => List.generate(
        gameState.board[0].length,
        (c) => (c == col) ? null : gameState.board[r][c],
      ),
    );

    // Calculate score bonus for clearing a column
    int scoreBonus = 0;
    for (int r = 0; r < gameState.board.length; r++) {
      final tile = gameState.board[r][col];
      if (tile != null) {
        scoreBonus += (tile.value * 0.05).round(); // 5% of each tile value
      }
    }

    final newState = gameState.copyWith(
      board: newBoard,
      score: gameState.score + scoreBonus,
    );

    // Check if game over condition changed after column clear
    final isGameOver = !newState.canMove;

    return newState.copyWith(
      isGameOver: isGameOver,
      // hasWon is preserved automatically by copyWith
    );
  }
}

/// Use case for executing value upgrade powerup effect
class ExecuteValueUpgradeUseCase {
  ExecuteValueUpgradeUseCase();

  /// Execute value upgrade effect - upgrades all tiles on the board to their next power of 2
  GameEntity execute(GameEntity gameState) {
    AppLogger.userAction(
      'VALUE_UPGRADE_EXECUTED',
      data: {
        'score': gameState.score,
        'tilesOnBoard': gameState.allTiles.length,
      },
    );

    // Create new board with all tiles upgraded
    final newBoard = List.generate(
      gameState.board.length,
      (r) => List.generate(gameState.board[0].length, (c) {
        final tile = gameState.board[r][c];
        if (tile == null) {
          return null; // Empty tiles remain empty
        }
        if (tile.isBlocker) {
          return tile; // Blocker tiles remain unchanged
        }
        // Upgrade regular tiles to next power of 2
        return tile.copyWith(value: tile.value * 2);
      }),
    );

    // Calculate score bonus based on the total value increase
    int scoreBonus = 0;
    for (int r = 0; r < gameState.board.length; r++) {
      for (int c = 0; c < gameState.board[0].length; c++) {
        final originalTile = gameState.board[r][c];
        if (originalTile != null && !originalTile.isBlocker) {
          // Award 10% of the original tile value as bonus
          scoreBonus += (originalTile.value * 0.1).round();
        }
      }
    }

    final newState = gameState.copyWith(
      board: newBoard,
      score: gameState.score + scoreBonus,
    );

    // Check if game over condition changed after value upgrade
    final isGameOver = !newState.canMove;

    // Check if win condition is achieved after upgrade
    final hasWon =
        newState.hasWon || newState.allTiles.any((tile) => tile.isWinningTile);

    AppLogger.info(
      'Value upgrade completed',
      tag: 'ExecuteValueUpgradeUseCase',
      data: {
        'tilesUpgraded': gameState.allTiles.where((t) => !t.isBlocker).length,
        'scoreBonus': scoreBonus,
        'newScore': newState.score,
        'hasWon': hasWon,
      },
    );

    return newState.copyWith(isGameOver: isGameOver, hasWon: hasWon);
  }
}

/// Use case for executing undo move powerup effect
class ExecuteUndoMoveUseCase {
  ExecuteUndoMoveUseCase();

  /// Execute undo move effect - reverts the game board to the previous state
  GameEntity execute(GameEntity gameState) {
    AppLogger.userAction(
      'UNDO_MOVE_EXECUTED',
      data: {'score': gameState.score, 'canUndo': gameState.canUndo},
    );

    // Check if undo is possible
    if (gameState.previousState == null) {
      AppLogger.warning(
        'Cannot undo - no previous state available',
        tag: 'ExecuteUndoMoveUseCase',
      );
      return gameState;
    }

    final previousState = gameState.previousState!;

    // Restore the previous state but keep powerup usage status
    final restoredState = previousState.copyWith(
      // Keep current powerup usage to prevent re-using the same powerup
      usedPowerupTypes: gameState.usedPowerupTypes,
      // Keep available powerups from current state
      availablePowerups: gameState.availablePowerups,
      // Clear active powerups since we're reverting
      activePowerups: [],
      // Clear previous state to prevent multiple undos
      previousState: null,
      // Update canUndo to false since we just used it
      canUndo: false,
    );

    AppLogger.info(
      'Undo move completed',
      tag: 'ExecuteUndoMoveUseCase',
      data: {
        'restoredScore': restoredState.score,
        'currentScore': gameState.score,
        'scoreDifference': gameState.score - restoredState.score,
      },
    );

    return restoredState;
  }
}

/// Use case for executing shuffle board powerup effect
class ExecuteShuffleBoardUseCase {
  ExecuteShuffleBoardUseCase();

  /// Execute shuffle board effect - randomly rearranges all non-empty tiles
  GameEntity execute(GameEntity gameState) {
    AppLogger.userAction(
      'SHUFFLE_BOARD_EXECUTED',
      data: {
        'score': gameState.score,
        'tilesOnBoard': gameState.allTiles.length,
      },
    );

    // Get all non-empty tiles
    final allTiles = gameState.allTiles;
    if (allTiles.isEmpty) {
      AppLogger.warning(
        'Cannot shuffle - no tiles on board',
        tag: 'ExecuteShuffleBoardUseCase',
      );
      return gameState;
    }

    // Get all empty positions
    final emptyPositions = gameState.emptyPositions;
    final totalPositions = <Position>[];

    // Add all positions (both empty and occupied)
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        totalPositions.add(Position(row, col));
      }
    }

    // Shuffle the positions
    totalPositions.shuffle();

    // Create new board with shuffled tiles
    final newBoard = List.generate(
      5,
      (r) => List<TileEntity?>.generate(5, (c) => null),
    );

    // Place tiles in shuffled positions
    for (int i = 0; i < allTiles.length; i++) {
      final position = totalPositions[i];
      newBoard[position.row][position.col] = allTiles[i];
    }

    final newState = gameState.copyWith(board: newBoard);

    // Check if game over condition changed after shuffle
    final isGameOver = !newState.canMove;

    AppLogger.info(
      'Shuffle board completed',
      tag: 'ExecuteShuffleBoardUseCase',
      data: {
        'tilesShuffled': allTiles.length,
        'emptySpaces': emptyPositions.length,
        'isGameOver': isGameOver,
      },
    );

    return newState.copyWith(isGameOver: isGameOver);
  }
}

/// Use case for executing interactive powerup effects based on type and position
class ExecuteInteractivePowerupUseCase {
  final ExecuteTileDestroyerUseCase _tileDestroyerUseCase;
  final ExecuteRowClearUseCase _rowClearUseCase;
  final ExecuteColumnClearUseCase _columnClearUseCase;

  ExecuteInteractivePowerupUseCase({
    ExecuteTileDestroyerUseCase? tileDestroyerUseCase,
    ExecuteRowClearUseCase? rowClearUseCase,
    ExecuteColumnClearUseCase? columnClearUseCase,
  }) : _tileDestroyerUseCase =
           tileDestroyerUseCase ?? ExecuteTileDestroyerUseCase(),
       _rowClearUseCase = rowClearUseCase ?? ExecuteRowClearUseCase(),
       _columnClearUseCase = columnClearUseCase ?? ExecuteColumnClearUseCase();

  /// Execute the appropriate powerup effect based on type and position
  GameEntity execute(
    GameEntity gameState,
    PowerupType powerupType,
    int row,
    int col,
  ) {
    AppLogger.userAction(
      'INTERACTIVE_POWERUP_EXECUTED',
      data: {
        'powerupType': powerupType.name,
        'powerupIcon': powerupType.icon,
        'targetRow': row,
        'targetCol': col,
        'score': gameState.score,
      },
    );

    switch (powerupType) {
      case PowerupType.tileDestroyer:
        return _tileDestroyerUseCase.execute(gameState, row, col);
      case PowerupType.rowClear:
        return _rowClearUseCase.execute(gameState, row, col);
      case PowerupType.columnClear:
        return _columnClearUseCase.execute(gameState, row, col);
      default:
        AppLogger.warning(
          'Unsupported interactive powerup type',
          tag: 'ExecuteInteractivePowerupUseCase',
          data: {'powerupType': powerupType.name},
        );
        return gameState;
    }
  }
}
