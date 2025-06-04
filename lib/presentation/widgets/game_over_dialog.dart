import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../domain/entities/game_entity.dart';
import '../providers/theme_providers.dart';
import '../providers/font_providers.dart';

/// Game Over Dialog that appears when the player can no longer make moves
class GameOverDialog extends ConsumerWidget {
  final GameEntity gameState;
  final VoidCallback onNewGame;
  final VoidCallback? onClose;
  final VoidCallback? onGameCompleted;

  const GameOverDialog({
    super.key,
    required this.gameState,
    required this.onNewGame,
    this.onClose,
    this.onGameCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFont = ref.watch(currentFontProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          color:
              Theme.of(context).dialogTheme.backgroundColor ??
              Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Game Over Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sentiment_dissatisfied,
                size: 48,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Game Over Title
            Text(
              LocalizationManager.gameOver(ref),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontFamily: currentFont?.fontFamily,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Final Score
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingMedium,
              ),
              decoration: BoxDecoration(
                color: currentPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
                border: Border.all(
                  color: currentPrimaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    LocalizationManager.score(ref),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      fontFamily: currentFont?.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gameState.score.toString(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: currentPrimaryColor,
                      fontFamily: currentFont?.fontFamily,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Best Score (if achieved)
            if (gameState.score == gameState.bestScore &&
                gameState.score > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      LocalizationManager.newBestScore(ref),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade700,
                        fontFamily: currentFont?.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
            ],

            // Action Buttons
            Row(
              children: [
                // Close Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onGameCompleted?.call();
                      onClose?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: currentPrimaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusSmall,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      LocalizationManager.close(ref),
                      style: TextStyle(
                        color: currentPrimaryColor,
                        fontFamily: currentFont?.fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppConstants.paddingMedium),

                // New Game Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onNewGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusSmall,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      LocalizationManager.newGame(ref),
                      style: TextStyle(
                        fontFamily: currentFont?.fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
