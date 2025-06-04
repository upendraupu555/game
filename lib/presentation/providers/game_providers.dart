import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/tile_entity.dart';
import '../../domain/entities/powerup_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/usecases/game_usecases.dart';
import '../../domain/usecases/powerup_usecases.dart';
import '../../domain/usecases/interactive_powerup_usecases.dart';
import '../../data/datasources/game_local_datasource.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../core/logging/app_logger.dart';
import '../../core/utils/performance_utils.dart';
import '../../core/constants/app_constants.dart';
import 'theme_providers.dart';
import 'powerup_providers.dart';
import 'powerup_selection_providers.dart';

// Data source providers
final gameLocalDataSourceProvider = Provider<GameLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return GameLocalDataSourceImpl(sharedPreferences);
});

// Repository providers
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final localDataSource = ref.watch(gameLocalDataSourceProvider);
  return GameRepositoryImpl(localDataSource);
});

// Use case providers
final initializeGameUseCaseProvider = Provider<InitializeGameUseCase>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return InitializeGameUseCase(repository);
});

final moveTilesUseCaseProvider = Provider<MoveTilesUseCase>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return MoveTilesUseCase(repository);
});

final loadGameStateUseCaseProvider = Provider<LoadGameStateUseCase>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return LoadGameStateUseCase(repository);
});

final saveGameStateUseCaseProvider = Provider<SaveGameStateUseCase>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return SaveGameStateUseCase(repository);
});

final checkGameOverUseCaseProvider = Provider<CheckGameOverUseCase>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return CheckGameOverUseCase(repository);
});

final checkWinConditionUseCaseProvider = Provider<CheckWinConditionUseCase>((
  ref,
) {
  final repository = ref.watch(gameRepositoryProvider);
  return CheckWinConditionUseCase(repository);
});

final restartGameUseCaseProvider = Provider<RestartGameUseCase>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return RestartGameUseCase(repository);
});

final getGameStatisticsUseCaseProvider = Provider<GetGameStatisticsUseCase>((
  ref,
) {
  final repository = ref.watch(gameRepositoryProvider);
  return GetGameStatisticsUseCase(repository);
});

final updateGameStatisticsUseCaseProvider =
    Provider<UpdateGameStatisticsUseCase>((ref) {
      final repository = ref.watch(gameRepositoryProvider);
      return UpdateGameStatisticsUseCase(repository);
    });

final resetAllDataUseCaseProvider = Provider<ResetAllDataUseCase>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return ResetAllDataUseCase(repository);
});

// Interactive powerup use case providers
final executeTileDestroyerUseCaseProvider =
    Provider<ExecuteTileDestroyerUseCase>((ref) {
      return ExecuteTileDestroyerUseCase();
    });

final executeRowClearUseCaseProvider = Provider<ExecuteRowClearUseCase>((ref) {
  return ExecuteRowClearUseCase();
});

final executeColumnClearUseCaseProvider = Provider<ExecuteColumnClearUseCase>((
  ref,
) {
  return ExecuteColumnClearUseCase();
});

final executeInteractivePowerupUseCaseProvider =
    Provider<ExecuteInteractivePowerupUseCase>((ref) {
      return ExecuteInteractivePowerupUseCase(
        tileDestroyerUseCase: ref.watch(executeTileDestroyerUseCaseProvider),
        rowClearUseCase: ref.watch(executeRowClearUseCaseProvider),
        columnClearUseCase: ref.watch(executeColumnClearUseCaseProvider),
      );
    });

// Game state notifier
class GameNotifier extends StateNotifier<AsyncValue<GameEntity>> {
  final Ref _ref;
  DateTime? _gameStartTime;
  DateTime? _pauseStartTime;

  GameNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadGame();
  }

  Future<void> _loadGame() async {
    try {
      final loadUseCase = _ref.read(loadGameStateUseCaseProvider);
      final savedGame = await loadUseCase.execute();

      // Check if saved game has correct board size (5x5)
      if (savedGame != null &&
          savedGame.board.length == 5 &&
          savedGame.board[0].length == 5) {
        state = AsyncValue.data(savedGame);
      } else {
        // Clear incompatible saved data and start new game
        if (savedGame != null) {
          final resetUseCase = _ref.read(resetAllDataUseCaseProvider);
          await resetUseCase.execute();
        }
        await _initializeNewGame();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> _initializeNewGame() async {
    try {
      final initializeUseCase = _ref.read(initializeGameUseCaseProvider);
      final newGame = await initializeUseCase.execute();
      _gameStartTime = DateTime.now();
      state = AsyncValue.data(newGame);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> move(MoveDirection direction) async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isGameOver ||
        currentState.isPaused) {
      return;
    }

    // Check for time expiration in time attack mode
    if (currentState.isTimeAttackMode && currentState.isTimeExpired) {
      // End the game due to time expiration
      final gameOverState = currentState.copyWith(isGameOver: true);
      state = AsyncValue.data(gameOverState);
      await saveGame();
      await _updateGameStatistics(gameOverState);
      return;
    }

    try {
      final moveUseCase = _ref.read(moveTilesUseCaseProvider);
      final newState = await moveUseCase.execute(currentState, direction);

      // Check if move was successful (optimized comparison)
      final moveSuccessful =
          !identical(newState, currentState) && newState != currentState;

      // Check for newly awarded powerups
      if (moveSuccessful) {
        final oldPowerupTypes = currentState.availablePowerups
            .map((p) => p.type)
            .toSet();
        final newPowerupTypes = newState.availablePowerups
            .map((p) => p.type)
            .toSet();
        final awardedPowerups = newPowerupTypes.difference(oldPowerupTypes);

        // Trigger notifications for new powerups
        for (final powerupType in awardedPowerups) {
          _ref
              .read(powerupNotificationProvider.notifier)
              .showNewPowerup(powerupType);
        }

        // Check for expired powerups
        final oldActivePowerups = currentState.activePowerups
            .map((p) => p.type)
            .toSet();
        final newActivePowerups = newState.activePowerups
            .map((p) => p.type)
            .toSet();
        final expiredPowerups = oldActivePowerups.difference(newActivePowerups);

        // Trigger notifications for expired powerups
        for (final powerupType in expiredPowerups) {
          _ref
              .read(powerupNotificationProvider.notifier)
              .showExpiredPowerup(powerupType);
        }
      }

      state = AsyncValue.data(newState);

      // Update statistics if game is over
      if (newState.isGameOver || newState.hasWon) {
        AppLogger.gameState(
          newState.isGameOver ? 'GAME_OVER' : 'GAME_WON',
          score: newState.score,
          bestScore: newState.bestScore,
          tilesCount: newState.allTiles.length,
          isGameOver: newState.isGameOver,
          hasWon: newState.hasWon,
        );
        await _updateGameStatistics(newState);
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        '❌ Move failed',
        tag: 'GameNotifier',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> restart() async {
    try {
      final currentState = state.value;
      if (currentState != null) {
        await _updateGameStatistics(currentState);
      }

      final restartUseCase = _ref.read(restartGameUseCaseProvider);
      final newGame = await restartUseCase.execute(
        currentState ?? GameEntity.newGame(),
      );
      _gameStartTime = DateTime.now();
      state = AsyncValue.data(newGame);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> startTimeAttack(int timeLimitSeconds) async {
    try {
      final currentState = state.value;
      if (currentState != null) {
        await _updateGameStatistics(currentState);
      }

      // Create a new time attack game
      final newGame = GameEntity.newTimeAttackGame(timeLimitSeconds);

      // Add initial tiles
      final initializeUseCase = _ref.read(initializeGameUseCaseProvider);
      final gameWithTiles = await initializeUseCase.execute();

      // Copy the board with tiles to the time attack game
      final timeAttackGame = newGame.copyWith(board: gameWithTiles.board);

      _gameStartTime = DateTime.now();
      state = AsyncValue.data(timeAttackGame);
      await saveGame();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> startScenicMode() async {
    try {
      final currentState = state.value;
      if (currentState != null) {
        await _updateGameStatistics(currentState);
      }

      // Get a random scenic background
      final randomIndex = (DateTime.now().millisecondsSinceEpoch % 19) + 1;

      // Create a new scenic mode game
      final newGame = GameEntity.newScenicGame(randomIndex);

      // Add initial tiles
      final initializeUseCase = _ref.read(initializeGameUseCaseProvider);
      final gameWithTiles = await initializeUseCase.execute();

      // Copy the board with tiles to the scenic game
      final scenicGame = newGame.copyWith(board: gameWithTiles.board);

      _gameStartTime = DateTime.now();
      state = AsyncValue.data(scenicGame);
      await saveGame();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> _updateGameStatistics(GameEntity gameState) async {
    if (_gameStartTime == null) return;

    try {
      final updateStatsUseCase = _ref.read(updateGameStatisticsUseCaseProvider);
      final playTime = DateTime.now().difference(_gameStartTime!);

      await updateStatsUseCase.execute(
        gameCompleted: gameState.isGameOver || gameState.hasWon,
        gameWon: gameState.hasWon,
        finalScore: gameState.score,
        playTime: playTime,
      );
    } catch (error) {
      AppLogger.error(
        'Failed to update statistics',
        tag: 'GameNotifier',
        error: error,
      );
    }
  }

  Future<void> saveGame() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final saveUseCase = _ref.read(saveGameStateUseCaseProvider);
      await saveUseCase.execute(currentState);
    } catch (error) {
      AppLogger.error('Failed to save game', tag: 'GameNotifier', error: error);
    }
  }

  Future<void> resetAllData() async {
    try {
      final resetUseCase = _ref.read(resetAllDataUseCaseProvider);
      await resetUseCase.execute();
      await _initializeNewGame();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Activate a powerup
  Future<void> activatePowerup(PowerupType powerupType) async {
    AppLogger.userAction(
      'POWERUP_ACTIVATION_REQUESTED',
      data: {'powerupType': powerupType.name, 'powerupIcon': powerupType.icon},
    );

    final currentState = state.value;
    if (currentState == null || currentState.isGameOver) {
      AppLogger.warning(
        '🚫 Powerup activation blocked',
        tag: 'GameNotifier',
        data: {
          'reason': currentState == null ? 'No current state' : 'Game is over',
          'powerupType': powerupType.name,
        },
      );
      return;
    }

    // Check if this is an interactive powerup that requires selection
    if (powerupType.requiresInteractiveSelection) {
      // Enter selection mode instead of immediately activating
      _ref
          .read(powerupSelectionProvider.notifier)
          .enterSelectionMode(powerupType);

      AppLogger.userAction(
        'POWERUP_SELECTION_MODE_ENTERED',
        data: {
          'powerupType': powerupType.name,
          'powerupIcon': powerupType.icon,
        },
      );
      return;
    }

    // For non-interactive powerups, activate immediately
    try {
      final activateUseCase = ActivatePowerupUseCase();
      final newState = activateUseCase.execute(currentState, powerupType);

      if (newState != currentState) {
        state = AsyncValue.data(newState);
        await saveGame();

        // Trigger powerup activation notification
        _ref
            .read(powerupNotificationProvider.notifier)
            .showActivatedPowerup(powerupType);

        AppLogger.userAction(
          'POWERUP_ACTIVATED',
          data: {
            'powerupType': powerupType.name,
            'powerupIcon': powerupType.icon,
            'score': newState.score,
          },
        );
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to activate powerup',
        tag: 'GameNotifier',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Handle tile selection for interactive powerups
  Future<void> selectTileForPowerup(int row, int col) async {
    final selectionState = _ref.read(powerupSelectionProvider);

    if (!selectionState.isSelectionMode ||
        selectionState.activePowerupType == null) {
      AppLogger.warning(
        'Tile selection attempted but not in selection mode',
        tag: 'GameNotifier',
        data: {
          'row': row,
          'col': col,
          'isSelectionMode': selectionState.isSelectionMode,
          'activePowerupType': selectionState.activePowerupType?.name,
        },
      );
      return;
    }

    final currentState = state.value;
    if (currentState == null || currentState.isGameOver) {
      AppLogger.warning(
        'Tile selection blocked - invalid game state',
        tag: 'GameNotifier',
        data: {
          'row': row,
          'col': col,
          'currentState': currentState?.toString(),
        },
      );
      return;
    }

    final powerupType = selectionState.activePowerupType!;

    try {
      // First, consume the powerup from available powerups
      final powerupIndex = currentState.availablePowerups.indexWhere(
        (p) => p.type == powerupType && p.isAvailable,
      );
      if (powerupIndex == -1) {
        AppLogger.warning(
          'Powerup not found in available list',
          tag: 'GameNotifier',
          data: {
            'powerupType': powerupType.name,
            'availablePowerups': currentState.availablePowerups
                .map((p) => p.type.name)
                .toList(),
          },
        );
        _ref.read(powerupSelectionProvider.notifier).exitSelectionMode();
        return;
      }

      // Remove the powerup from available list and add to used types
      final newAvailablePowerups = List<PowerupEntity>.from(
        currentState.availablePowerups,
      )..removeAt(powerupIndex);
      final newUsedPowerupTypes = Set<PowerupType>.from(
        currentState.usedPowerupTypes,
      )..add(powerupType);

      // Execute the interactive powerup effect
      final executeUseCase = _ref.read(
        executeInteractivePowerupUseCaseProvider,
      );
      final stateAfterPowerupConsumption = currentState.copyWith(
        availablePowerups: newAvailablePowerups,
        usedPowerupTypes: newUsedPowerupTypes,
      );
      final newState = executeUseCase.execute(
        stateAfterPowerupConsumption,
        powerupType,
        row,
        col,
      );

      // Update game state
      state = AsyncValue.data(newState);
      await saveGame();

      // Exit selection mode
      _ref.read(powerupSelectionProvider.notifier).exitSelectionMode();

      // Trigger powerup activation notification
      _ref
          .read(powerupNotificationProvider.notifier)
          .showActivatedPowerup(powerupType);

      AppLogger.userAction(
        'INTERACTIVE_POWERUP_COMPLETED',
        data: {
          'powerupType': powerupType.name,
          'powerupIcon': powerupType.icon,
          'targetRow': row,
          'targetCol': col,
          'score': newState.score,
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to execute interactive powerup',
        tag: 'GameNotifier',
        error: error,
      );
      _ref.read(powerupSelectionProvider.notifier).exitSelectionMode();
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Cancel interactive powerup selection
  Future<void> cancelPowerupSelection() async {
    final selectionState = _ref.read(powerupSelectionProvider);

    if (selectionState.isSelectionMode) {
      _ref.read(powerupSelectionProvider.notifier).exitSelectionMode();

      AppLogger.userAction(
        'POWERUP_SELECTION_CANCELLED',
        data: {'powerupType': selectionState.activePowerupType?.name},
      );
    }
  }

  /// Pause the game
  Future<void> pauseGame() async {
    final currentState = state.value;
    if (currentState == null || currentState.isPaused) return;

    try {
      // Record pause start time for time attack mode
      if (currentState.isTimeAttackMode) {
        _pauseStartTime = DateTime.now();
      }

      final newState = currentState.copyWith(isPaused: true);
      state = AsyncValue.data(newState);
      await saveGame();

      AppLogger.debug('⏸️ Game paused', tag: 'GameNotifier');
    } catch (error) {
      AppLogger.error(
        'Failed to pause game',
        tag: 'GameNotifier',
        error: error,
      );
    }
  }

  /// Resume the game
  Future<void> resumeGame() async {
    final currentState = state.value;
    if (currentState == null || !currentState.isPaused) return;

    try {
      GameEntity newState = currentState.copyWith(isPaused: false);

      // Update paused time for time attack mode
      if (currentState.isTimeAttackMode && _pauseStartTime != null) {
        final pauseDuration = DateTime.now().difference(_pauseStartTime!);
        final totalPausedTime =
            currentState.pausedTimeSeconds + pauseDuration.inSeconds;
        newState = newState.copyWith(pausedTimeSeconds: totalPausedTime);
        _pauseStartTime = null;
      }

      state = AsyncValue.data(newState);
      await saveGame();

      AppLogger.debug('▶️ Game resumed', tag: 'GameNotifier');
    } catch (error) {
      AppLogger.error(
        'Failed to resume game',
        tag: 'GameNotifier',
        error: error,
      );
    }
  }

  /// Toggle pause state
  Future<void> togglePause() async {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.isPaused) {
      await resumeGame();
    } else {
      await pauseGame();
    }
  }

  /// Check for time expiration in time attack mode and trigger game over if needed
  Future<void> checkTimeExpiration() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.isTimeAttackMode ||
        currentState.isGameOver ||
        currentState.isPaused) {
      return;
    }

    if (currentState.isTimeExpired) {
      // End the game due to time expiration
      final gameOverState = currentState.copyWith(isGameOver: true);
      state = AsyncValue.data(gameOverState);
      await saveGame();
      await _updateGameStatistics(gameOverState);

      AppLogger.gameState(
        'TIME_EXPIRED_GAME_OVER',
        score: gameOverState.score,
        bestScore: gameOverState.bestScore,
        tilesCount: gameOverState.allTiles.length,
        isGameOver: true,
        hasWon: false,
      );
    }
  }

  /// Debug method to manually add a powerup for testing
  Future<void> debugAddPowerup(PowerupType powerupType) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final addPowerupUseCase = AddPowerupUseCase();
      final newState = addPowerupUseCase.execute(currentState, powerupType);

      if (newState != currentState) {
        state = AsyncValue.data(newState);
        await saveGame();

        // Trigger new powerup notification
        _ref
            .read(powerupNotificationProvider.notifier)
            .showNewPowerup(powerupType);

        AppLogger.debug(
          '🎁 Debug powerup added',
          tag: 'GameNotifier',
          data: {
            'powerupType': powerupType.name,
            'powerupIcon': powerupType.icon,
          },
        );
      }
    } catch (error) {
      AppLogger.error(
        'Failed to add debug powerup',
        tag: 'GameNotifier',
        error: error,
      );
    }
  }

  /// Alternative direct activation method for testing
  Future<void> debugDirectActivatePowerup(PowerupType powerupType) async {
    print(
      '🔧 GameNotifier.debugDirectActivatePowerup called with powerupType: ${powerupType.name}',
    );

    final currentState = state.value;
    if (currentState == null) {
      print('❌ No current state');
      return;
    }

    try {
      // Find the powerup in available list
      final powerupIndex = currentState.availablePowerups.indexWhere(
        (p) => p.type == powerupType,
      );
      if (powerupIndex == -1) {
        print('❌ Powerup not found in available list');
        return;
      }

      final powerup = currentState.availablePowerups[powerupIndex];
      print(
        '✅ Found powerup: ${powerup.type.name}, creating activated version...',
      );

      // Create activated powerup
      final activatedPowerup = powerup.activate();

      // Create new state manually
      final newAvailablePowerups = List<PowerupEntity>.from(
        currentState.availablePowerups,
      )..removeAt(powerupIndex);
      final newActivePowerups = List<PowerupEntity>.from(
        currentState.activePowerups,
      )..add(activatedPowerup);
      final newUsedPowerupTypes = Set<PowerupType>.from(
        currentState.usedPowerupTypes,
      )..add(powerupType);

      final newState = currentState.copyWith(
        availablePowerups: newAvailablePowerups,
        activePowerups: newActivePowerups,
        usedPowerupTypes: newUsedPowerupTypes,
      );

      print(
        '📊 Direct activation result: availablePowerups=${newState.availablePowerups.length}, activePowerups=${newState.activePowerups.length}',
      );

      state = AsyncValue.data(newState);
      await saveGame();

      // Trigger notification
      _ref
          .read(powerupNotificationProvider.notifier)
          .showActivatedPowerup(powerupType);

      print('🎉 Direct powerup activation completed successfully');
    } catch (error) {
      print('💥 Error in debugDirectActivatePowerup: $error');
    }
  }
}

// Main game provider
final gameProvider =
    StateNotifierProvider<GameNotifier, AsyncValue<GameEntity>>((ref) {
      return GameNotifier(ref);
    });

// Computed providers for UI convenience
final gameScoreProvider = Provider<int>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.value?.score ?? 0;
});

final gameBestScoreProvider = Provider<int>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.value?.bestScore ?? 0;
});

final gameIsOverProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.value?.isGameOver ?? false;
});

final gameHasWonProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.value?.hasWon ?? false;
});

final gameIsPausedProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.value?.isPaused ?? false;
});

final gameBoardProvider = Provider<List<List<TileEntity?>>>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.value?.board ??
      List.generate(5, (_) => List.generate(5, (_) => null));
});

// Game statistics provider
final gameStatisticsProvider = FutureProvider<GameStatistics>((ref) async {
  final getStatsUseCase = ref.watch(getGameStatisticsUseCaseProvider);
  return await getStatsUseCase.execute();
});

// Game loading state provider
final gameLoadingProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.isLoading;
});

// Game error provider
final gameErrorProvider = Provider<String?>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.hasError ? gameState.error.toString() : null;
});

// Provider to check if there's a resumable game (not game over and has progress)
final hasResumableGameProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameProvider);
  final game = gameState.value;

  if (game == null) return false;

  // Check if game is not over and has some progress (score > 0 or tiles on board)
  final hasProgress = game.score > 0 || game.allTiles.isNotEmpty;
  return !game.isGameOver && hasProgress;
});

// Provider for resumable game info (score, etc.)
final resumableGameInfoProvider = Provider<GameEntity?>((ref) {
  final hasResumable = ref.watch(hasResumableGameProvider);
  if (!hasResumable) return null;

  final gameState = ref.watch(gameProvider);
  return gameState.value;
});
