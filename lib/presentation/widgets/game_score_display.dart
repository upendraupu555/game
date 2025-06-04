import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../providers/game_providers.dart';
import '../providers/theme_providers.dart';

/// Widget that displays the current score and best score
class GameScoreDisplay extends ConsumerWidget {
  const GameScoreDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScore = ref.watch(gameScoreProvider);
    final bestScore = ref.watch(gameBestScoreProvider);
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final gameHasWon = ref.watch(gameHasWonProvider);
    final gameIsOver = ref.watch(gameIsOverProvider);

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          // Win/Game Over status
          if (gameHasWon || gameIsOver) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: gameHasWon ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: Text(
                gameHasWon
                    ? LocalizationManager.youWin(ref)
                    : LocalizationManager.gameOver(ref),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],

          // Score cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ScoreCard(
                title: LocalizationManager.score(ref),
                value: currentScore,
                color: currentPrimaryColor,
                isAnimated: true,
              ),
              _ScoreCard(
                title: LocalizationManager.bestScore(ref),
                value: bestScore,
                color: currentPrimaryColor.withValues(alpha: 0.7),
                isAnimated: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual score card widget
class _ScoreCard extends StatefulWidget {
  final String title;
  final int value;
  final Color color;
  final bool isAnimated;

  const _ScoreCard({
    required this.title,
    required this.value,
    required this.color,
    required this.isAnimated,
  });

  @override
  State<_ScoreCard> createState() => _ScoreCardState();
}

class _ScoreCardState extends State<_ScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(_ScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate when score changes
    if (widget.isAnimated &&
        widget.value != _previousValue &&
        widget.value > _previousValue) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
    _previousValue = widget.value;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 120,
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _formatScore(widget.value),
                    key: ValueKey(widget.value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
