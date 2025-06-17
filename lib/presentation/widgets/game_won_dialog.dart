import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/navigation/navigation_service.dart';
import '../../domain/entities/game_entity.dart';
import '../providers/theme_providers.dart';
import '../providers/font_providers.dart';
import 'confetti_widget.dart';

/// Game Won Dialog that appears when the player reaches 2048
class GameWonDialog extends ConsumerWidget {
  final GameEntity gameState;
  final VoidCallback onContinuePlaying;
  final VoidCallback onReturnToHome;
  final VoidCallback? onGameCompleted;

  const GameWonDialog({
    super.key,
    required this.gameState,
    required this.onContinuePlaying,
    required this.onReturnToHome,
    this.onGameCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFont = ref.watch(currentFontProvider);

    return VictoryConfettiWidget(
      showConfetti: true,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            color:
                Theme.of(context).dialogTheme.backgroundColor ??
                Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration Icon with Animation
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFD700), // Gold
                        const Color(0xFFFFA500), // Orange
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Congratulations Title
                Text(
                  LocalizationManager.congratulations(ref),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD700),
                    fontFamily: currentFont?.fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.paddingSmall),

                // You Won Message
                Text(
                  LocalizationManager.youWon(ref),
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: currentFont?.fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Score Display
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
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
                        LocalizationManager.finalScore(ref),
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
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: currentPrimaryColor,
                          fontFamily: currentFont?.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.paddingMedium),

                // Best Score Display (if this is a new best)
                if (gameState.score >= gameState.bestScore)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                      vertical: AppConstants.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusSmall,
                      ),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFD700),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          LocalizationManager.newBestScore(ref),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFD700),
                            fontFamily: currentFont?.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Motivational Message
                Text(
                  LocalizationManager.continueForHigherScore(ref),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    fontFamily: currentFont?.fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Action Buttons
                Column(
                  children: [
                    // Continue Playing Button (Primary)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onContinuePlaying();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusSmall,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          LocalizationManager.continuePlaying(ref),
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: currentFont?.fontFamily,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingMedium),

                    // Return to Home Button (Secondary)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onGameCompleted?.call();
                          onReturnToHome();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: currentPrimaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusSmall,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          LocalizationManager.returnToHome(ref),
                          style: TextStyle(
                            fontSize: 16,
                            color: currentPrimaryColor,
                            fontFamily: currentFont?.fontFamily,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingMedium),

                    // Statistics button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          NavigationService.pushNamed(
                            AppRoutes.leaderboard,
                            arguments: {
                              'initialTab': 1,
                            }, // Statistics tab index
                          );
                        },
                        icon: Icon(
                          Icons.bar_chart,
                          color: Colors.blue,
                          size: 18,
                        ),
                        label: Text(
                          'View Statistics',
                          style: TextStyle(
                            color: Colors.blue,
                            fontFamily: currentFont?.fontFamily,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.paddingSmall,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusSmall,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
