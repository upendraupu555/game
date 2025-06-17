import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../core/constants/app_constants.dart';

/// Reusable confetti widget for celebrations throughout the app
class CelebrationConfettiWidget extends StatefulWidget {
  final Widget child;
  final bool showConfetti;
  final VoidCallback? onAnimationComplete;
  final Color? primaryColor;
  final Duration duration;
  final int numberOfParticles;

  const CelebrationConfettiWidget({
    super.key,
    required this.child,
    this.showConfetti = false,
    this.onAnimationComplete,
    this.primaryColor,
    this.duration = const Duration(seconds: 3),
    this.numberOfParticles = 50,
  });

  @override
  State<CelebrationConfettiWidget> createState() =>
      _CelebrationConfettiWidgetState();
}

class _CelebrationConfettiWidgetState extends State<CelebrationConfettiWidget>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  List<Color>? _cachedColors;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: widget.duration);
  }

  @override
  void didUpdateWidget(CelebrationConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showConfetti && !oldWidget.showConfetti) {
      _confettiController.play();
    } else if (!widget.showConfetti && oldWidget.showConfetti) {
      _confettiController.stop();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cache colors to avoid recalculation on every build
    _cachedColors ??= _getConfettiColors(context);
    final colors = _cachedColors!;

    return RepaintBoundary(
      child: Stack(
        children: [
          widget.child,

          // Top-center confetti with RepaintBoundary for performance
          if (widget.showConfetti)
            Align(
              alignment: Alignment.topCenter,
              child: RepaintBoundary(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 1.57, // Down
                  blastDirectionality: BlastDirectionality.directional,
                  numberOfParticles: widget.numberOfParticles,
                  colors: colors,
                ),
              ),
            ),

          // Top-left confetti with RepaintBoundary for performance
          if (widget.showConfetti)
            Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 0.5, // Right-down
                  blastDirectionality: BlastDirectionality.directional,
                  numberOfParticles: widget.numberOfParticles ~/ 3,
                  colors: colors,
                ),
              ),
            ),

          // Top-right confetti with RepaintBoundary for performance
          if (widget.showConfetti)
            Align(
              alignment: Alignment.topRight,
              child: RepaintBoundary(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 2.6, // Left-down
                  blastDirectionality: BlastDirectionality.directional,
                  numberOfParticles: widget.numberOfParticles ~/ 3,
                  colors: colors,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Color> _getConfettiColors(BuildContext context) {
    final primaryColor =
        widget.primaryColor ?? Theme.of(context).colorScheme.primary;

    return [
      primaryColor,
      primaryColor.withValues(alpha: 0.8),
      Colors.amber,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.cyan,
    ];
  }
}

/// Specialized confetti widget for easter egg celebrations
class EasterEggConfettiWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTrigger;

  const EasterEggConfettiWidget({
    super.key,
    required this.child,
    this.onTrigger,
  });

  @override
  State<EasterEggConfettiWidget> createState() =>
      _EasterEggConfettiWidgetState();
}

class _EasterEggConfettiWidgetState extends State<EasterEggConfettiWidget>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  int _tapCount = 0;
  DateTime? _lastTapTime;
  static const int _requiredTaps = 3;
  static const Duration _tapTimeout = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleTap() {
    final now = DateTime.now();

    // Reset count if too much time has passed
    if (_lastTapTime != null && now.difference(_lastTapTime!) > _tapTimeout) {
      _tapCount = 0;
    }

    _tapCount++;
    _lastTapTime = now;

    if (_tapCount >= _requiredTaps) {
      _triggerEasterEgg();
      _tapCount = 0; // Reset for next time
    }
  }

  void _triggerEasterEgg() {
    _confettiController.play();
    widget.onTrigger?.call();

    // Show a fun message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.celebration, color: Colors.white),
              SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: Text('🎉 Easter egg found! You discovered a secret! 🎉'),
              ),
            ],
          ),
          backgroundColor: Colors.purple,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reduce particle count for better performance
    const optimizedParticleCount = 75;

    // Cache colors for performance
    const colors = [
      Colors.purple,
      Colors.pink,
      Colors.blue,
      Colors.cyan,
      Colors.yellow,
      Colors.orange,
      Colors.red,
      Colors.green,
    ];

    return GestureDetector(
      onTap: _handleTap,
      child: RepaintBoundary(
        child: Stack(
          children: [
            widget.child,

            // Confetti overlay with performance optimizations
            Positioned.fill(
              child: RepaintBoundary(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 1.57, // Down
                  blastDirectionality: BlastDirectionality.explosive,
                  numberOfParticles: optimizedParticleCount,
                  colors: colors,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Victory confetti widget for game celebrations
class VictoryConfettiWidget extends StatefulWidget {
  final Widget child;
  final bool showConfetti;
  final VoidCallback? onAnimationComplete;

  const VictoryConfettiWidget({
    super.key,
    required this.child,
    this.showConfetti = false,
    this.onAnimationComplete,
  });

  @override
  State<VictoryConfettiWidget> createState() => _VictoryConfettiWidgetState();
}

class _VictoryConfettiWidgetState extends State<VictoryConfettiWidget>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void didUpdateWidget(VictoryConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showConfetti && !oldWidget.showConfetti) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reduce particle count for better performance
    const optimizedParticleCount = 100;

    // Cache colors for performance
    const colors = [
      Color(0xFFFFD700), // Gold
      Colors.yellow,
      Colors.orange,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.green,
    ];

    return RepaintBoundary(
      child: Stack(
        children: [
          widget.child,

          // Victory confetti with performance optimizations
          if (widget.showConfetti)
            Align(
              alignment: Alignment.topCenter,
              child: RepaintBoundary(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 1.57, // Down
                  blastDirectionality: BlastDirectionality.directional,
                  numberOfParticles: optimizedParticleCount,
                  colors: colors,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
