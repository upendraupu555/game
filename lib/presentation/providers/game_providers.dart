import 'package:flutter/material.dart';
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
import '../../core/constants/app_constants.dart';
import '../../core/navigation/navigation_service.dart';
import 'theme_providers.dart';
import 'powerup_providers.dart';
import 'powerup_selection_providers.dart';
import 'leaderboard_providers.dart';
import 'comprehensive_statistics_providers.dart';
import '../widgets/powerup_inventory_dialog.dart';

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

final clearGameStateUseCaseProvider = Provider<ClearGameStateUseCase>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return ClearGameStateUseCase(repository);
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

final executeValueUpgradeUseCaseProvider = Provider<ExecuteValueUpgradeUseCase>(
  (ref) {
    return ExecuteValueUpgradeUseCase();
  },
);

final executeUndoMoveUseCaseProvider = Provider<ExecuteUndoMoveUseCase>((ref) {
  return ExecuteUndoMoveUseCase();
});

final executeShuffleBoardUseCaseProvider = Provider<ExecuteShuffleBoardUseCase>(
  (ref) {
    return ExecuteShuffleBoardUseCase();
  },
);

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
  bool _gameCompletionProcessed = false;

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
      _gameCompletionProcessed = false; // Reset completion flag for new game
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

      // Check for newly awarded powerups and handle inventory management
      if (moveSuccessful) {
        final oldPowerupTypes = currentState.availablePowerups
            .map((p) => p.type)
            .toSet();
        final newPowerupTypes = newState.availablePowerups
            .map((p) => p.type)
            .toSet();
        final awardedPowerups = newPowerupTypes.difference(oldPowerupTypes);

        // Handle each awarded powerup with proper inventory management
        for (final powerupType in awardedPowerups) {
          // Powerup was successfully added - show notification
          _ref
              .read(powerupNotificationProvider.notifier)
              .showNewPowerup(powerupType);
        }

        // Check if any powerups were earned but couldn't be added due to full inventory
        // This requires checking the score-based powerup earning logic
        final checkPowerupAwardUseCase = _ref.read(
          checkPowerupAwardUseCaseProvider,
        );
        final potentialPowerups = checkPowerupAwardUseCase.execute(newState);

        // Find powerups that should have been earned but weren't added and haven't been offered yet
        final missedPowerups = potentialPowerups.where((powerupType) {
          return !newState.availablePowerups.any(
                (p) => p.type == powerupType,
              ) &&
              !currentState.availablePowerups.any(
                (p) => p.type == powerupType,
              ) &&
              !newState.isPowerupOffered(
                powerupType,
              ); // Check if already offered
        }).toList();

        // Handle missed powerups due to inventory being full
        GameEntity finalState = newState;
        for (final powerupType in missedPowerups) {
          // Mark powerup as offered to prevent duplicate dialogs
          finalState = finalState.markPowerupAsOffered(powerupType);

          // Show inventory management dialog for each missed powerup
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final context = NavigationService.navigatorKey.currentContext;
            if (context != null) {
              await handlePowerupEarning(context, powerupType);
            }
          });
        }

        // Check for expired powerups
        final oldActivePowerups = currentState.activePowerups
            .map((p) => p.type)
            .toSet();
        final newActivePowerups = finalState.activePowerups
            .map((p) => p.type)
            .toSet();
        final expiredPowerups = oldActivePowerups.difference(newActivePowerups);

        // Trigger notifications for expired powerups
        for (final powerupType in expiredPowerups) {
          _ref
              .read(powerupNotificationProvider.notifier)
              .showExpiredPowerup(powerupType);
        }

        // Use the updated state with offered powerups marked
        state = AsyncValue.data(finalState);
      } else {
        // No move was successful, just use the original state
        state = AsyncValue.data(newState);
      }

      // Update statistics if game is over (use the current state value)
      final currentGameState = state.value;
      if (currentGameState != null &&
          (currentGameState.isGameOver || currentGameState.hasWon)) {
        AppLogger.gameState(
          currentGameState.isGameOver ? 'GAME_OVER' : 'GAME_WON',
          score: currentGameState.score,
          bestScore: currentGameState.bestScore,
          tilesCount: currentGameState.allTiles.length,
          isGameOver: currentGameState.isGameOver,
          hasWon: currentGameState.hasWon,
        );
        await _updateGameStatistics(currentGameState);
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
      // No need to update statistics here - they're updated when game ends naturally
      final currentState = state.value;
      final restartUseCase = _ref.read(restartGameUseCaseProvider);
      final newGame = await restartUseCase.execute(
        currentState ?? GameEntity.newGame(),
      );
      _gameStartTime = DateTime.now();
      _gameCompletionProcessed = false; // Reset completion flag for new game
      state = AsyncValue.data(newGame);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> startTimeAttack(int timeLimitSeconds) async {
    try {
      // No need to update statistics here - they're updated when game ends naturally
      // Create a new time attack game
      final newGame = GameEntity.newTimeAttackGame(timeLimitSeconds);

      // Add initial tiles
      final initializeUseCase = _ref.read(initializeGameUseCaseProvider);
      final gameWithTiles = await initializeUseCase.execute();

      // Copy the board with tiles to the time attack game
      final timeAttackGame = newGame.copyWith(board: gameWithTiles.board);

      _gameStartTime = DateTime.now();
      _gameCompletionProcessed = false; // Reset completion flag for new game
      state = AsyncValue.data(timeAttackGame);
      await saveGame();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> startScenicMode() async {
    try {
      // No need to update statistics here - they're updated when game ends naturally
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
      _gameCompletionProcessed = false; // Reset completion flag for new game
      state = AsyncValue.data(scenicGame);
      await saveGame();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> _updateGameStatistics(GameEntity gameState) async {
    if (_gameStartTime == null) return;

    try {
      final playTime = DateTime.now().difference(_gameStartTime!);
      final gameCompleted = gameState.isGameOver || gameState.hasWon;

      // Prevent duplicate processing of the same game completion
      if (gameCompleted && _gameCompletionProcessed) {
        AppLogger.debug(
          '🚫 Game completion already processed, skipping duplicate update',
          tag: 'GameNotifier',
        );
        return;
      }

      // Only update comprehensive statistics to avoid double counting
      // The comprehensive statistics include all the basic statistics data

      // Add to leaderboard if game is completed
      if (gameCompleted) {
        try {
          final addToLeaderboardUseCase = _ref.read(
            addGameToLeaderboardUseCaseProvider,
          );
          final wasAdded = await addToLeaderboardUseCase.execute(
            gameState: gameState,
            gameDuration: playTime,
          );

          if (wasAdded) {
            AppLogger.info(
              '🏆 Game added to leaderboard',
              tag: 'GameNotifier',
              data: {'score': gameState.score, 'duration': playTime.inSeconds},
            );

            // Refresh both leaderboard providers and wait for completion
            await Future.wait([
              _ref.read(leaderboardProvider.notifier).refresh(),
              _ref.read(groupedLeaderboardProvider.notifier).refresh(),
            ]);
          }
        } catch (leaderboardError) {
          AppLogger.error(
            'Failed to add game to leaderboard',
            tag: 'GameNotifier',
            error: leaderboardError,
          );
          // Don't rethrow - leaderboard failure shouldn't break game flow
        }
      }

      // Update comprehensive statistics if game is completed
      if (gameCompleted) {
        try {
          final comprehensiveStatsUseCase = _ref.read(
            updateComprehensiveStatisticsUseCaseProvider,
          );

          // Determine game mode
          final gameMode = _determineGameMode(gameState);

          // Get powerups used (if any)
          final powerupsUsed = <PowerupType>[];
          // TODO: Track powerups used during the game

          await comprehensiveStatsUseCase.execute(
            gameState: gameState,
            gameCompleted: true,
            gameWon: gameState.hasWon,
            playTime: playTime,
            gameMode: gameMode,
            powerupsUsed: powerupsUsed,
          );

          // Refresh comprehensive statistics provider and wait for completion
          await _ref
              .read(comprehensiveStatisticsNotifierProvider.notifier)
              .refresh();

          AppLogger.info(
            '📊 Comprehensive statistics updated',
            tag: 'GameNotifier',
            data: {
              'gameMode': gameMode,
              'score': gameState.score,
              'won': gameState.hasWon,
            },
          );

          // Mark game completion as processed to prevent duplicates
          if (gameCompleted) {
            _gameCompletionProcessed = true;

            // Clear saved game state when game is completed to prevent it from showing as resumable
            try {
              final clearGameStateUseCase = _ref.read(
                clearGameStateUseCaseProvider,
              );
              await clearGameStateUseCase.execute();
              AppLogger.info(
                '🧹 Cleared saved game state after completion',
                tag: 'GameNotifier',
              );
            } catch (clearError) {
              AppLogger.error(
                'Failed to clear game state after completion',
                tag: 'GameNotifier',
                error: clearError,
              );
              // Don't rethrow - clearing failure shouldn't break game flow
            }
          }
        } catch (statsError) {
          AppLogger.error(
            'Failed to update comprehensive statistics',
            tag: 'GameNotifier',
            error: statsError,
          );
          // Don't rethrow - statistics failure shouldn't break game flow
        }
      }
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

      // Refresh all providers after data reset
      await Future.wait([
        _ref.read(leaderboardProvider.notifier).refresh(),
        _ref.read(groupedLeaderboardProvider.notifier).refresh(),
        _ref.read(comprehensiveStatisticsNotifierProvider.notifier).refresh(),
      ]);
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
      final (newState, result) = addPowerupUseCase.execute(
        currentState,
        powerupType,
      );

      if (result == AddPowerupResult.success) {
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

  /// Handle powerup earning with inventory management
  Future<void> handlePowerupEarning(
    BuildContext context,
    PowerupType newPowerupType,
  ) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final addPowerupUseCase = AddPowerupUseCase();
      final (newState, result) = addPowerupUseCase.execute(
        currentState,
        newPowerupType,
      );

      switch (result) {
        case AddPowerupResult.success:
          state = AsyncValue.data(newState);
          await saveGame();

          // Show notification for the new powerup
          _ref
              .read(powerupNotificationProvider.notifier)
              .showNewPowerup(newPowerupType);

          AppLogger.debug(
            '🎁 Powerup earned and added',
            tag: 'GameNotifier',
            data: {
              'powerupType': newPowerupType.name,
              'powerupIcon': newPowerupType.icon,
            },
          );
          break;

        case AddPowerupResult.inventoryFull:
          // Show inventory management dialog
          await _showInventoryManagementDialog(context, newPowerupType);
          break;

        case AddPowerupResult.alreadyExists:
          AppLogger.warning(
            '🔄 Powerup not added - already exists',
            tag: 'GameNotifier',
            data: {'powerupType': newPowerupType.name},
          );
          break;
      }
    } catch (error) {
      AppLogger.error(
        'Failed to handle powerup earning',
        tag: 'GameNotifier',
        error: error,
      );
    }
  }

  /// Show inventory management dialog when inventory is full
  Future<void> _showInventoryManagementDialog(
    BuildContext context,
    PowerupType newPowerupType,
  ) async {
    final currentState = state.value;
    if (currentState == null) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PowerupInventoryDialog(
        newPowerupType: newPowerupType,
        currentPowerups: currentState.availablePowerups,
        onReplacePowerup: (powerupTypeToReplace) async {
          await _replacePowerup(powerupTypeToReplace, newPowerupType);
        },
        onDiscardNewPowerup: () {
          // Clear the offered status for this powerup since user chose to discard it
          final updatedOfferedPowerups = Set<PowerupType>.from(
            currentState.offeredPowerupTypes,
          )..remove(newPowerupType);
          final newState = currentState.copyWith(
            offeredPowerupTypes: updatedOfferedPowerups,
          );
          state = AsyncValue.data(newState);
          saveGame();

          AppLogger.info(
            '🗑️ New powerup discarded by user choice',
            tag: 'GameNotifier',
            data: {'powerupType': newPowerupType.name},
          );
        },
      ),
    );
  }

  /// Replace an existing powerup with a new one
  Future<void> _replacePowerup(
    PowerupType powerupTypeToReplace,
    PowerupType newPowerupType,
  ) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      // Remove the old powerup
      final updatedPowerups = currentState.availablePowerups
          .where((p) => p.type != powerupTypeToReplace)
          .toList();

      // Add the new powerup
      final newPowerup = PowerupEntity.create(newPowerupType);
      updatedPowerups.add(newPowerup);

      // Clear the offered status for this powerup since it's now successfully added
      final updatedOfferedPowerups = Set<PowerupType>.from(
        currentState.offeredPowerupTypes,
      )..remove(newPowerupType);

      final newState = currentState.copyWith(
        availablePowerups: updatedPowerups,
        // offeredPowerupTypes: updatedOfferedPowerups,
      );

      state = AsyncValue.data(newState);
      await saveGame();

      // Show notification for the new powerup
      _ref
          .read(powerupNotificationProvider.notifier)
          .showNewPowerup(newPowerupType);

      AppLogger.info(
        '🔄 Powerup replaced successfully',
        tag: 'GameNotifier',
        data: {
          'replacedPowerup': powerupTypeToReplace.name,
          'newPowerup': newPowerupType.name,
        },
      );
    } catch (error) {
      AppLogger.error(
        'Failed to replace powerup',
        tag: 'GameNotifier',
        error: error,
      );
    }
  }

  /// Debug method to test game completion processing
  Future<void> debugProcessGameCompletion(GameEntity gameState) async {
    await _updateGameStatistics(gameState);
  }

  /// Continue playing after winning a game
  /// This resets the completion flag to allow the continued game to be processed separately
  Future<void> continueAfterWin() async {
    _gameCompletionProcessed = false;
    AppLogger.info(
      '🔄 Continue after win: Reset completion flag for continued game',
      tag: 'GameNotifier',
    );
  }

  /// Debug method to test continue after win flow
  Future<void> debugContinueAfterWin() async {
    await continueAfterWin();
  }

  /// Alternative direct activation method for testing
  Future<void> debugDirectActivatePowerup(PowerupType powerupType) async {
    AppLogger.debug(
      'GameNotifier.debugDirectActivatePowerup called',
      tag: 'GameNotifier',
      data: {'powerupType': powerupType.name},
    );

    final currentState = state.value;
    if (currentState == null) {
      AppLogger.warning('No current state available', tag: 'GameNotifier');
      return;
    }

    try {
      // Find the powerup in available list
      final powerupIndex = currentState.availablePowerups.indexWhere(
        (p) => p.type == powerupType,
      );
      if (powerupIndex == -1) {
        AppLogger.warning(
          'Powerup not found in available list',
          tag: 'GameNotifier',
          data: {'powerupType': powerupType.name},
        );
        return;
      }

      final powerup = currentState.availablePowerups[powerupIndex];
      AppLogger.debug(
        'Found powerup, creating activated version',
        tag: 'GameNotifier',
        data: {'powerupType': powerup.type.name},
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

      AppLogger.debug(
        'Direct activation result',
        tag: 'GameNotifier',
        data: {
          'availablePowerups': newState.availablePowerups.length,
          'activePowerups': newState.activePowerups.length,
        },
      );

      state = AsyncValue.data(newState);
      await saveGame();

      // Trigger notification
      _ref
          .read(powerupNotificationProvider.notifier)
          .showActivatedPowerup(powerupType);

      AppLogger.debug(
        'Direct powerup activation completed successfully',
        tag: 'GameNotifier',
      );
    } catch (error) {
      AppLogger.error(
        'Error in debugDirectActivatePowerup',
        tag: 'GameNotifier',
        error: error,
      );
    }
  }

  /// Determine game mode from game state
  String _determineGameMode(GameEntity gameState) {
    if (gameState.isTimeAttackMode) {
      return AppConstants.gameModeTimeAttack;
    } else if (gameState.isScenicMode) {
      return AppConstants.gameModeScenicMode;
    } else {
      return AppConstants.gameModeClassic;
    }
  }
}

// Main game provider
final gameProvider =
    StateNotifierProvider<GameNotifier, AsyncValue<GameEntity>>((ref) {
      return GameNotifier(ref);
    });

// Optimized computed providers for UI convenience - using select for better performance
final gameScoreProvider = Provider<int>((ref) {
  return ref.watch(gameProvider.select((state) => state.value?.score ?? 0));
});

final gameBestScoreProvider = Provider<int>((ref) {
  return ref.watch(gameProvider.select((state) => state.value?.bestScore ?? 0));
});

final gameIsOverProvider = Provider<bool>((ref) {
  return ref.watch(
    gameProvider.select((state) => state.value?.isGameOver ?? false),
  );
});

final gameHasWonProvider = Provider<bool>((ref) {
  return ref.watch(
    gameProvider.select((state) => state.value?.hasWon ?? false),
  );
});

final gameIsPausedProvider = Provider<bool>((ref) {
  return ref.watch(
    gameProvider.select((state) => state.value?.isPaused ?? false),
  );
});

final gameBoardProvider = Provider<List<List<TileEntity?>>>((ref) {
  return ref.watch(
    gameProvider.select(
      (state) =>
          state.value?.board ??
          List.generate(5, (_) => List.generate(5, (_) => null)),
    ),
  );
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

// Provider to check if there's a resumable game (not game over and has actual progress)
final hasResumableGameProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameProvider);
  final game = gameState.value;

  if (game == null) return false;

  // Game must not be over to be resumable
  if (game.isGameOver) return false;

  // Check if game has actual progress beyond initial state
  // A fresh game starts with 2 tiles and score 0
  // We consider it resumable only if:
  // 1. Score > 0 (player made successful merges), OR
  // 2. More than 2 tiles on board (player made moves that added tiles), OR
  // 3. Game has been paused (indicating user interaction), OR
  // 4. Game has powerups (indicating progression)
  final hasScore = game.score > 0;
  final hasMoreThanInitialTiles = game.allTiles.length > 2;
  final wasPaused = game.isPaused;
  final hasPowerups =
      game.availablePowerups.isNotEmpty || game.usedPowerupTypes.isNotEmpty;

  // A game is resumable if it shows clear signs of being played
  return hasScore || hasMoreThanInitialTiles || wasPaused || hasPowerups;
});

// Provider for resumable game info (score, etc.)
final resumableGameInfoProvider = Provider<GameEntity?>((ref) {
  final hasResumable = ref.watch(hasResumableGameProvider);
  if (!hasResumable) return null;

  final gameState = ref.watch(gameProvider);
  return gameState.value;
});
