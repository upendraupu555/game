import '../entities/game_entity.dart';
import '../entities/powerup_entity.dart';
import '../../core/logging/app_logger.dart';

/// Use case for executing tile destroyer powerup effect
class ExecuteTileDestroyerUseCase {
  ExecuteTileDestroyerUseCase();

  /// Execute tile destroyer effect on the specified position
  GameEntity execute(GameEntity gameState, int row, int col) {
    AppLogger.userAction('TILE_DESTROYER_EXECUTED', data: {
      'targetRow': row,
      'targetCol': col,
      'score': gameState.score,
    });

    // Validate position
    if (row < 0 || row >= gameState.board.length ||
        col < 0 || col >= gameState.board[0].length) {
      AppLogger.warning('Invalid tile position for destroyer', tag: 'ExecuteTileDestroyerUseCase', data: {
        'row': row,
        'col': col,
        'boardSize': '${gameState.board.length}x${gameState.board[0].length}',
      });
      return gameState;
    }

    // Check if there's a tile at the position
    if (gameState.board[row][col] == null) {
      AppLogger.warning('No tile to destroy at position', tag: 'ExecuteTileDestroyerUseCase', data: {
        'row': row,
        'col': col,
      });
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

    return gameState.copyWith(
      board: newBoard,
      score: gameState.score + scoreBonus,
    );
  }
}

/// Use case for executing row clear powerup effect
class ExecuteRowClearUseCase {
  ExecuteRowClearUseCase();

  /// Execute row clear effect on the specified row
  GameEntity execute(GameEntity gameState, int row, int col) {
    AppLogger.userAction('ROW_CLEAR_EXECUTED', data: {
      'targetRow': row,
      'targetCol': col,
      'score': gameState.score,
    });

    // Validate position
    if (row < 0 || row >= gameState.board.length) {
      AppLogger.warning('Invalid row for clear', tag: 'ExecuteRowClearUseCase', data: {
        'row': row,
        'boardHeight': gameState.board.length,
      });
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

    return gameState.copyWith(
      board: newBoard,
      score: gameState.score + scoreBonus,
    );
  }
}

/// Use case for executing column clear powerup effect
class ExecuteColumnClearUseCase {
  ExecuteColumnClearUseCase();

  /// Execute column clear effect on the specified column
  GameEntity execute(GameEntity gameState, int row, int col) {
    AppLogger.userAction('COLUMN_CLEAR_EXECUTED', data: {
      'targetRow': row,
      'targetCol': col,
      'score': gameState.score,
    });

    // Validate position
    if (col < 0 || col >= gameState.board[0].length) {
      AppLogger.warning('Invalid column for clear', tag: 'ExecuteColumnClearUseCase', data: {
        'col': col,
        'boardWidth': gameState.board[0].length,
      });
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

    return gameState.copyWith(
      board: newBoard,
      score: gameState.score + scoreBonus,
    );
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
  })  : _tileDestroyerUseCase = tileDestroyerUseCase ?? ExecuteTileDestroyerUseCase(),
        _rowClearUseCase = rowClearUseCase ?? ExecuteRowClearUseCase(),
        _columnClearUseCase = columnClearUseCase ?? ExecuteColumnClearUseCase();

  /// Execute the appropriate powerup effect based on type and position
  GameEntity execute(GameEntity gameState, PowerupType powerupType, int row, int col) {
    AppLogger.userAction('INTERACTIVE_POWERUP_EXECUTED', data: {
      'powerupType': powerupType.name,
      'powerupIcon': powerupType.icon,
      'targetRow': row,
      'targetCol': col,
      'score': gameState.score,
    });

    switch (powerupType) {
      case PowerupType.tileDestroyer:
        return _tileDestroyerUseCase.execute(gameState, row, col);
      case PowerupType.rowClear:
        return _rowClearUseCase.execute(gameState, row, col);
      case PowerupType.columnClear:
        return _columnClearUseCase.execute(gameState, row, col);
      default:
        AppLogger.warning('Unsupported interactive powerup type', tag: 'ExecuteInteractivePowerupUseCase', data: {
          'powerupType': powerupType.name,
        });
        return gameState;
    }
  }
}
