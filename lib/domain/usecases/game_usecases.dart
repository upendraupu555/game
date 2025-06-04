import '../entities/game_entity.dart';
import '../entities/tile_entity.dart';
import '../repositories/game_repository.dart';
import '../../core/logging/app_logger.dart';
import 'powerup_usecases.dart';

/// Use case for initializing a new game
class InitializeGameUseCase {
  final GameRepository _repository;

  InitializeGameUseCase(this._repository);

  Future<GameEntity> execute() async {
    final gameState = await _repository.initializeGame();

    // Add two initial tiles
    var stateWithFirstTile = _repository.addRandomTile(gameState);
    var stateWithSecondTile = _repository.addRandomTile(stateWithFirstTile);

    // Save the initial state
    await _repository.saveGameState(stateWithSecondTile);

    return stateWithSecondTile;
  }
}

/// Use case for moving tiles in a direction
class MoveTilesUseCase {
  final GameRepository _repository;
  final CheckTileSpawnPreventionUseCase _checkTileSpawnPreventionUseCase;
  final ProcessPowerupEffectsUseCase _processPowerupEffectsUseCase;
  final CheckPowerupAwardUseCase _checkPowerupAwardUseCase;
  final AddPowerupUseCase _addPowerupUseCase;

  MoveTilesUseCase(
    this._repository, {
    CheckTileSpawnPreventionUseCase? checkTileSpawnPreventionUseCase,
    ProcessPowerupEffectsUseCase? processPowerupEffectsUseCase,
    CheckPowerupAwardUseCase? checkPowerupAwardUseCase,
    AddPowerupUseCase? addPowerupUseCase,
  }) : _checkTileSpawnPreventionUseCase =
           checkTileSpawnPreventionUseCase ?? CheckTileSpawnPreventionUseCase(),
       _processPowerupEffectsUseCase =
           processPowerupEffectsUseCase ?? ProcessPowerupEffectsUseCase(),
       _checkPowerupAwardUseCase =
           checkPowerupAwardUseCase ?? CheckPowerupAwardUseCase(),
       _addPowerupUseCase = addPowerupUseCase ?? AddPowerupUseCase();

  Future<GameEntity> execute(
    GameEntity currentState,
    MoveDirection direction,
  ) async {
    // Check if move is possible
    final newState = _repository.moveTiles(currentState, direction);

    // If no change occurred, check if game is over
    if (_isSameState(currentState, newState)) {
      // No tiles moved, but check if we need to update game over state
      final isGameOver = _repository.isGameOver(currentState);
      final hasWon = _repository.hasPlayerWon(currentState);

      AppLogger.debug(
        '🚫 No move possible',
        tag: 'MoveTilesUseCase',
        data: {
          'boardFull': currentState.isBoardFull,
          'canMove': currentState.canMove,
          'isGameOver': isGameOver,
          'hasWon': hasWon,
        },
      );

      // Return updated state with correct game over status
      return currentState.copyWith(isGameOver: isGameOver, hasWon: hasWon);
    }

    // Process powerup effects after move
    var stateAfterPowerupEffects = _processPowerupEffectsUseCase.execute(
      newState,
    );

    // Check if tile spawning should be prevented (Tile Freeze effect)
    final shouldPreventTileSpawn = _checkTileSpawnPreventionUseCase.execute(
      stateAfterPowerupEffects,
    );

    // Add random tile after successful move (unless prevented by powerup)
    var stateWithNewTile = shouldPreventTileSpawn
        ? stateAfterPowerupEffects
        : _repository.addRandomTile(stateAfterPowerupEffects);

    // Check for powerup awards based on new score
    final awardedPowerups = _checkPowerupAwardUseCase.execute(stateWithNewTile);
    for (final powerupType in awardedPowerups) {
      stateWithNewTile = _addPowerupUseCase.execute(
        stateWithNewTile,
        powerupType,
      );
    }

    // Check game over condition AFTER adding the random tile
    final isGameOver = _repository.isGameOver(stateWithNewTile);
    final hasWon = _repository.hasPlayerWon(stateWithNewTile);

    AppLogger.debug(
      '🎯 Game state check after move',
      tag: 'MoveTilesUseCase',
      data: {
        'boardFull': stateWithNewTile.isBoardFull,
        'canMove': stateWithNewTile.canMove,
        'isGameOver': isGameOver,
        'hasWon': hasWon,
        'tilesCount': stateWithNewTile.allTiles.length,
        'emptySpaces': stateWithNewTile.emptyPositions.length,
      },
    );

    // Update the state with final game over and win conditions
    stateWithNewTile = stateWithNewTile.copyWith(
      isGameOver: isGameOver,
      hasWon: hasWon,
    );

    // Update best score if needed
    if (stateWithNewTile.score > stateWithNewTile.bestScore) {
      final updatedState = stateWithNewTile.copyWith(
        bestScore: stateWithNewTile.score,
      );
      await _repository.saveBestScore(updatedState.score);
      await _repository.saveGameState(updatedState);
      return updatedState;
    }

    // Save game state
    await _repository.saveGameState(stateWithNewTile);

    return stateWithNewTile;
  }

  bool _isSameState(GameEntity state1, GameEntity state2) {
    // Quick reference check first
    if (identical(state1, state2)) return true;

    // Check score first as it's faster than board comparison
    if (state1.score != state2.score) return false;

    // Optimized board comparison - early exit on first difference
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        final tile1 = state1.board[row][col];
        final tile2 = state2.board[row][col];

        // Quick null checks
        if (tile1 == null && tile2 == null) continue;
        if (tile1 == null || tile2 == null) return false;

        // Compare values directly for performance
        if (tile1.value != tile2.value) return false;
      }
    }
    return true;
  }
}

/// Use case for loading saved game state
class LoadGameStateUseCase {
  final GameRepository _repository;

  LoadGameStateUseCase(this._repository);

  Future<GameEntity?> execute() async {
    final savedState = await _repository.loadGameState();
    if (savedState == null) return null;

    // Load best score and update if needed
    final bestScore = await _repository.loadBestScore();
    if (bestScore > savedState.bestScore) {
      return savedState.copyWith(bestScore: bestScore);
    }

    return savedState;
  }
}

/// Use case for saving game state
class SaveGameStateUseCase {
  final GameRepository _repository;

  SaveGameStateUseCase(this._repository);

  Future<void> execute(GameEntity gameState) async {
    await _repository.saveGameState(gameState);

    // Update best score if needed
    if (gameState.score > gameState.bestScore) {
      await _repository.saveBestScore(gameState.score);
    }
  }
}

/// Use case for checking if game is over
class CheckGameOverUseCase {
  final GameRepository _repository;

  CheckGameOverUseCase(this._repository);

  bool execute(GameEntity gameState) {
    return _repository.isGameOver(gameState);
  }
}

/// Use case for checking if player has won
class CheckWinConditionUseCase {
  final GameRepository _repository;

  CheckWinConditionUseCase(this._repository);

  bool execute(GameEntity gameState) {
    return _repository.hasPlayerWon(gameState);
  }
}

/// Use case for restarting the game
class RestartGameUseCase {
  final GameRepository _repository;

  RestartGameUseCase(this._repository);

  Future<GameEntity> execute(GameEntity currentState) async {
    // Keep the best score
    final bestScore = await _repository.loadBestScore();
    final maxScore = bestScore > currentState.bestScore
        ? bestScore
        : currentState.bestScore;

    // Initialize new game
    final newGame = await _repository.initializeGame();
    final gameWithBestScore = newGame.copyWith(bestScore: maxScore);

    // Add two initial tiles
    var stateWithFirstTile = _repository.addRandomTile(gameWithBestScore);
    var stateWithSecondTile = _repository.addRandomTile(stateWithFirstTile);

    // Save the new state
    await _repository.saveGameState(stateWithSecondTile);

    return stateWithSecondTile;
  }
}

/// Use case for getting game statistics
class GetGameStatisticsUseCase {
  final GameRepository _repository;

  GetGameStatisticsUseCase(this._repository);

  Future<GameStatistics> execute() async {
    return await _repository.getGameStatistics();
  }
}

/// Use case for updating game statistics
class UpdateGameStatisticsUseCase {
  final GameRepository _repository;

  UpdateGameStatisticsUseCase(this._repository);

  Future<void> execute({
    required bool gameCompleted,
    required bool gameWon,
    required int finalScore,
    required Duration playTime,
  }) async {
    final currentStats = await _repository.getGameStatistics();

    final updatedStats = currentStats.copyWith(
      gamesPlayed: gameCompleted
          ? currentStats.gamesPlayed + 1
          : currentStats.gamesPlayed,
      gamesWon: gameWon ? currentStats.gamesWon + 1 : currentStats.gamesWon,
      bestScore: finalScore > currentStats.bestScore
          ? finalScore
          : currentStats.bestScore,
      totalScore: currentStats.totalScore + finalScore,
      totalPlayTime: currentStats.totalPlayTime + playTime,
      lastPlayed: DateTime.now(),
    );

    await _repository.saveGameStatistics(updatedStats);
  }
}

/// Use case for resetting all game data
class ResetAllDataUseCase {
  final GameRepository _repository;

  ResetAllDataUseCase(this._repository);

  Future<void> execute() async {
    await _repository.resetAllData();
  }
}
