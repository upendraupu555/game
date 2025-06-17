import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/navigation/navigation_service.dart';
import '../../domain/entities/tile_entity.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/powerup_entity.dart';
import '../providers/game_providers.dart';
import '../providers/powerup_providers.dart';

import '../widgets/sliding_game_board.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/game_won_dialog.dart';
import '../widgets/powerup_tray.dart';
import '../widgets/powerup_visual_effects.dart';
import '../widgets/powerup_selection_overlay.dart';
import '../widgets/custom_game_app_bar.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/interstitial_ad_service.dart';
import '../widgets/scenic_background_widget.dart';
import '../../core/utils/performance_optimizer.dart';

/// Main game screen that displays the 2048 game
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver, GameCompletionAdMixin {
  bool _previousGameOverState = false;
  bool _previousWonState = false;
  bool _hasShownWinDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize performance optimizations
    PerformanceOptimizer.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PerformanceOptimizer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final gameState = ref.read(gameProvider).value;
    if (gameState != null &&
        gameState.isTimeAttackMode &&
        !gameState.isGameOver) {
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
        case AppLifecycleState.detached:
          // App is going to background or being closed, pause the game
          if (!gameState.isPaused) {
            ref.read(gameProvider.notifier).pauseGame();
          }
          break;
        case AppLifecycleState.resumed:
          // App is coming back to foreground - don't auto-resume, let user decide
          break;
        case AppLifecycleState.hidden:
          // App is hidden but still running
          if (!gameState.isPaused) {
            ref.read(gameProvider.notifier).pauseGame();
          }
          break;
      }
    }
  }

  void _handleMove(MoveDirection direction) {
    ref.read(gameProvider.notifier).move(direction);
  }

  void _handleRestart() {
    ref.read(gameProvider.notifier).restart();
  }

  void _handlePowerupTap(PowerupType powerupType) {
    ref.read(gameProvider.notifier).activatePowerup(powerupType);
  }

  void _checkGameOverState(GameEntity? gameState) {
    if (gameState == null) return;

    // Check for win condition first (only show once per game)
    if (gameState.hasWon && !_previousWonState && !_hasShownWinDialog) {
      _hasShownWinDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameWonDialog(gameState);
      });
    }

    // Check for game over condition (only after win dialog has been handled)
    if (gameState.isGameOver && !_previousGameOverState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialog(gameState);
      });
    }

    _previousGameOverState = gameState.isGameOver;
    _previousWonState = gameState.hasWon;
  }

  void _showGameWonDialog(GameEntity gameState) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => GameWonDialog(
        gameState: gameState,
        onContinuePlaying: () {
          // Allow the player to continue playing beyond 2048
          // Reset the completion flag so the continued game can be processed separately
          ref.read(gameProvider.notifier).continueAfterWin();
        },
        onReturnToHome: () {
          Navigator.of(context).pop(); // Close dialog
          // Navigator.of(context).pop(); // Return to home
        },
        onGameCompleted: _handleGameCompleted,
      ),
    );
  }

  void _showGameOverDialog(GameEntity gameState) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => GameOverDialog(
        gameState: gameState,
        onNewGame: () {
          // Navigate to game mode selection instead of restarting current game
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Return to home
          NavigationService.pushNamed(AppRoutes.gameModeSelection);
        },
        onClose: () {
          // Return to home when close is pressed
          Navigator.of(context).pop(); // Return to home
        },
        onGameCompleted: _handleGameCompleted,
      ),
    );
  }

  /// Handle game completion with potential interstitial ad display
  void _handleGameCompleted() {
    handleGameCompletionWithAd(
      onCompleted: () {
        // Ad completed or no ad to show, continue with normal flow
        // The dialog will handle navigation back to main menu
      },
    );
  }

  void _handleNavigationAway() {
    final gameState = ref.read(gameProvider).value;
    if (gameState != null &&
        gameState.isTimeAttackMode &&
        !gameState.isGameOver &&
        !gameState.isPaused) {
      // Auto-pause the game when navigating away
      ref.read(gameProvider.notifier).pauseGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final isLoading = ref.watch(gameLoadingProvider);
    final error = ref.watch(gameErrorProvider);

    // Check for game over state changes
    _checkGameOverState(gameState.value);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _handleNavigationAway();
        }
      },
      child: Scaffold(
        body: _buildGameScreenContent(gameState, isLoading, error),
      ),
    );
  }

  Widget _buildGameScreenContent(
    AsyncValue<GameEntity> gameState,
    bool isLoading,
    String? error,
  ) {
    final game = gameState.value;

    // Check if we're in scenic mode
    if (game != null &&
        game.isScenicMode &&
        game.scenicBackgroundIndex != null) {
      return GameScenicBackgroundWidget(
        backgroundIndex: game.scenicBackgroundIndex!,
        child: _buildMainGameContent(gameState, isLoading, error),
      );
    } else {
      return _buildMainGameContent(gameState, isLoading, error);
    }
  }

  Widget _buildMainGameContent(
    AsyncValue<GameEntity> gameState,
    bool isLoading,
    String? error,
  ) {
    return Column(
      children: [
        // Custom app bar
        const CustomGameAppBar(),

        // Game content
        Expanded(
          child: SafeArea(
            top: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    // Score display
                    // const GameScoreDisplay(),
                    const SizedBox(height: AppConstants.paddingSmall),

                    // Game area
                    Expanded(
                      child: Center(
                        child: _buildGameContent(gameState, isLoading, error),
                      ),
                    ),

                    // Powerup tray
                    _buildPowerupTray(gameState.value),

                    const SizedBox(height: AppConstants.paddingSmall),
                  ],
                ),

                // Powerup notification overlay
                PowerupNotificationOverlay(
                  isScenicMode: gameState.value?.isScenicMode ?? false,
                ),

                // Powerup selection overlay - positioned at screen level
                const PowerupSelectionOverlay(),
              ],
            ),
          ),
        ),

        // Banner advertisement at the bottom
        const BannerAdWidget(),
      ],
    );
  }

  Widget _buildGameContent(
    AsyncValue gameState,
    bool isLoading,
    String? error,
  ) {
    if (isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(LocalizationManager.loadingGame(ref)),
        ],
      );
    }

    if (error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            '${LocalizationManager.errorLoadingGame(ref)}: $error',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ElevatedButton(
            onPressed: () {
              ref.read(gameProvider.notifier).restart();
            },
            child: Text(LocalizationManager.tryAgain(ref)),
          ),
        ],
      );
    }

    return gameState.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            '${LocalizationManager.errorLoadingGame(ref)}: $error',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ElevatedButton(
            onPressed: _handleRestart,
            child: Text(LocalizationManager.tryAgain(ref)),
          ),
        ],
      ),
      data: (game) {
        return RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: RepaintBoundary(
              child: PowerupVisualEffects(
                child: SlidingGameBoard(gameState: game, onMove: _handleMove),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPowerupTray(GameEntity? gameState) {
    if (gameState == null) {
      return const SizedBox.shrink();
    }

    final availablePowerups = ref.watch(availablePowerupsProvider);
    final activePowerups = ref.watch(activePowerupsProvider);

    return PowerupTray(
      availablePowerups: availablePowerups,
      activePowerups: activePowerups,
      onPowerupTap: _handlePowerupTap,
      isGameActive: !gameState.isGameOver,
      isScenicMode: gameState.isScenicMode,
    );
  }
}
