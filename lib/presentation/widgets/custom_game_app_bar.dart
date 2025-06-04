import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/navigation/navigation_service.dart';
import '../providers/game_providers.dart';
import '../providers/theme_providers.dart';
import '../providers/font_providers.dart';
import 'pause_menu_overlay.dart';
import 'statistics_dialog.dart';
import 'time_attack_timer.dart';

/// Custom app bar widget for the game screen
/// Displays back button, current score, and pause button in a Row layout
class CustomGameAppBar extends ConsumerWidget {
  const CustomGameAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScore = ref.watch(gameScoreProvider);
    final isPaused = ref.watch(gameIsPausedProvider);
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFontFamily = ref.watch(currentFontFamilyProvider);
    final gameState = ref.watch(gameProvider).value;
    final isTimeAttackMode = gameState?.isTimeAttackMode ?? false;
    final isScenicMode = gameState?.isScenicMode ?? false;

    return Container(
      height: isTimeAttackMode ? 130 : 100,
      decoration: _buildAppBarDecoration(currentPrimaryColor, isScenicMode),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
          child: isTimeAttackMode
              ? _buildTimeAttackLayout(
                  currentScore: currentScore,
                  isPaused: isPaused,
                  currentFontFamily: currentFontFamily,
                  context: context,
                  ref: ref,
                  isScenicMode: isScenicMode,
                )
              : _buildRegularLayout(
                  currentScore: currentScore,
                  isPaused: isPaused,
                  currentFontFamily: currentFontFamily,
                  context: context,
                  ref: ref,
                  isScenicMode: isScenicMode,
                ),
        ),
      ),
    );
  }

  /// Build app bar decoration based on game mode
  BoxDecoration _buildAppBarDecoration(Color primaryColor, bool isScenicMode) {
    if (isScenicMode) {
      // Transparent app bar for scenic mode with blur effect
      return BoxDecoration(
        color: Color(
          AppConstants.scenicAppBarColorValue,
        ).withValues(alpha: AppConstants.scenicAppBarOpacity),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      );
    } else {
      // Regular app bar decoration
      return BoxDecoration(
        color: primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
  }

  Widget _buildRegularLayout({
    required int currentScore,
    required bool isPaused,
    required String currentFontFamily,
    required BuildContext context,
    required WidgetRef ref,
    required bool isScenicMode,
  }) {
    // Enhanced text color for scenic mode readability
    final textColor = isScenicMode ? Colors.white : Colors.white;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back button (left)
        _BackButton(
          color: textColor,
          fontFamily: currentFontFamily,
          isScenicMode: isScenicMode,
        ),

        // Current score (center)
        Flexible(
          child: _ScoreDisplay(
            score: currentScore,
            color: textColor,
            fontFamily: currentFontFamily,
            isScenicMode: isScenicMode,
          ),
        ),

        // Pause button (right)
        _PauseButton(
          isPaused: isPaused,
          color: textColor,
          fontFamily: currentFontFamily,
          isScenicMode: isScenicMode,
          onPressed: () {
            _showPauseMenu(context, ref);
          },
        ),
      ],
    );
  }

  Widget _buildTimeAttackLayout({
    required int currentScore,
    required bool isPaused,
    required String currentFontFamily,
    required BuildContext context,
    required WidgetRef ref,
    required bool isScenicMode,
  }) {
    // Enhanced text color for scenic mode readability
    final textColor = isScenicMode ? Colors.white : Colors.white;

    return Column(
      children: [
        // Top row: Back button, Timer, Pause button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back button (left)
            _BackButton(
              color: textColor,
              fontFamily: currentFontFamily,
              isScenicMode: isScenicMode,
            ),

            // Timer (center)
            const TimeAttackTimer(),
            // Bottom row: Score (centered)
            _ScoreDisplay(
              score: currentScore,
              color: textColor,
              fontFamily: currentFontFamily,
              isScenicMode: isScenicMode,
            ),
            // Pause button (right)
            _PauseButton(
              isPaused: isPaused,
              color: textColor,
              fontFamily: currentFontFamily,
              isScenicMode: isScenicMode,
              onPressed: () {
                _showPauseMenu(context, ref);
              },
            ),
          ],
        ),

        const SizedBox(height: 4),
      ],
    );
  }

  /// Show the pause menu overlay
  static void _showPauseMenu(BuildContext context, WidgetRef ref) {
    // Pause the game first
    ref.read(gameProvider.notifier).pauseGame();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => PauseMenuOverlay(
        onResume: () {
          Navigator.of(context).pop();
          ref.read(gameProvider.notifier).resumeGame();
        },
        onNewGame: () {
          Navigator.of(context).pop();
          ref.read(gameProvider.notifier).restart();
        },
        onShowStatistics: () {
          showDialog(
            context: context,
            builder: (context) => const StatisticsDialog(),
          );
        },
      ),
    ).then((_) {
      // If dialog is dismissed by tapping outside, resume the game
      final gameState = ref.read(gameProvider).value;
      if (gameState?.isPaused == true) {
        ref.read(gameProvider.notifier).resumeGame();
      }
    });
  }
}

/// Back button widget
class _BackButton extends ConsumerWidget {
  final Color color;
  final String fontFamily;
  final bool isScenicMode;

  const _BackButton({
    required this.color,
    required this.fontFamily,
    this.isScenicMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        // Handle time attack pause before navigation
        final gameState = ref.read(gameProvider).value;
        if (gameState != null &&
            gameState.isTimeAttackMode &&
            !gameState.isGameOver &&
            !gameState.isPaused) {
          // Auto-pause the game when navigating away
          ref.read(gameProvider.notifier).pauseGame();
        }
        NavigationService.pop();
      },
      icon: isScenicMode
          ? Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back, color: color, size: 24),
            )
          : Icon(Icons.arrow_back, color: color, size: 24),
      tooltip: 'Back',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}

/// Score display widget
class _ScoreDisplay extends StatelessWidget {
  final int score;
  final Color color;
  final String fontFamily;
  final bool isScenicMode;

  const _ScoreDisplay({
    required this.score,
    required this.color,
    required this.fontFamily,
    this.isScenicMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // Enhanced text shadows for scenic mode readability
    final textShadows = isScenicMode
        ? [
            Shadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
            Shadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : <Shadow>[];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SCORE',
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            letterSpacing: 1.0,
            shadows: textShadows,
          ),
        ),
        const SizedBox(width: AppConstants.paddingSmall),
        Text(
          _formatScore(score),
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            shadows: textShadows,
          ),
        ),
      ],
    );
  }

  /// Format score with 'k' abbreviation for values over 10,000
  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score > 10000) {
      return '${(score / 1000).toStringAsFixed(1)}k';
    } else {
      return score.toString();
    }
  }
}

/// Pause button widget
class _PauseButton extends StatelessWidget {
  final bool isPaused;
  final Color color;
  final String fontFamily;
  final VoidCallback onPressed;
  final bool isScenicMode;

  const _PauseButton({
    required this.isPaused,
    required this.color,
    required this.fontFamily,
    required this.onPressed,
    this.isScenicMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: isScenicMode
          ? Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                isPaused ? Icons.play_arrow : Icons.pause,
                color: color,
                size: 24,
              ),
            )
          : Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: color,
              size: 24,
            ),
      tooltip: isPaused ? 'Game Paused' : 'Pause Menu',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}
