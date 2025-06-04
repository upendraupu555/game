import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/game_entity.dart';
import '../providers/game_providers.dart';

class TimeAttackTimer extends ConsumerStatefulWidget {
  const TimeAttackTimer({super.key});

  @override
  ConsumerState<TimeAttackTimer> createState() => _TimeAttackTimerState();
}

class _TimeAttackTimerState extends ConsumerState<TimeAttackTimer>
    with TickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _warningController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _warningAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _warningController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _warningAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _warningController,
      curve: Curves.easeInOut,
    ));

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _warningController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final gameState = ref.read(gameProvider).value;
      if (gameState != null && gameState.isTimeAttackMode) {
        // Don't update timer if game is paused
        if (gameState.isPaused) {
          return;
        }

        // Check for time expiration and trigger game over if needed
        await ref.read(gameProvider.notifier).checkTimeExpiration();

        // Update UI if still mounted and game is still active
        if (mounted) {
          final updatedGameState = ref.read(gameProvider).value;
          if (updatedGameState != null && updatedGameState.isTimeAttackMode && !updatedGameState.isGameOver) {
            setState(() {});
            _updateAnimations(updatedGameState);
          } else if (updatedGameState?.isGameOver == true) {
            // Game over, cancel timer
            timer.cancel();
          }
        }
      }
    });
  }

  void _updateAnimations(GameEntity gameState) {
    final remainingSeconds = gameState.remainingTimeSeconds;
    final totalSeconds = gameState.timeLimit ?? 0;

    // Start warning animation when less than 30 seconds or 10% of time remaining
    final warningThreshold = math.min(30, (totalSeconds * 0.1).round());

    if (remainingSeconds <= warningThreshold) {
      if (!_warningController.isAnimating) {
        _warningController.repeat(reverse: true);
      }

      // Start pulsing when very critical (last 10 seconds)
      if (remainingSeconds <= 10) {
        if (!_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        }
      }
    } else {
      _warningController.reset();
      _pulseController.reset();
    }
  }

  Color _getTimerColor(GameEntity gameState) {
    final remainingSeconds = gameState.remainingTimeSeconds;
    final totalSeconds = gameState.timeLimit ?? 0;
    final percentage = remainingSeconds / totalSeconds;

    if (percentage > 0.3) {
      return Colors.green; // Safe time
    } else if (percentage > 0.1) {
      return Colors.orange; // Warning time
    } else {
      return Colors.red; // Critical time
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(gameProvider);

    return gameAsync.when(
      data: (gameState) {
        if (!gameState.isTimeAttackMode) {
          return const SizedBox.shrink();
        }

        final remainingSeconds = gameState.remainingTimeSeconds;
        final totalSeconds = gameState.timeLimit ?? 0;
        final progress = remainingSeconds / totalSeconds;
        final timerColor = _getTimerColor(gameState);

        return AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _warningAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                  border: Border.all(
                    color: timerColor.withValues(
                      alpha: 0.3 + (_warningAnimation.value * 0.7),
                    ),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: timerColor.withValues(
                        alpha: 0.2 + (_warningAnimation.value * 0.3),
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Circular progress indicator
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Stack(
                        children: [
                          // Background circle
                          CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 3,
                            backgroundColor: timerColor.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              timerColor.withValues(alpha: 0.1),
                            ),
                          ),
                          // Progress circle
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                          ),
                          // Timer icon
                          Center(
                            child: Icon(
                              Icons.timer,
                              size: 12,
                              color: timerColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppConstants.paddingSmall),

                    // Time text
                    Text(
                      _formatTime(remainingSeconds),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: timerColor,
                        fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
