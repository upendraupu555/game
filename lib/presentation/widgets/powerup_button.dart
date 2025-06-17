import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/powerup_entity.dart';
import '../../core/constants/app_constants.dart';

/// Individual powerup button widget with distinguishable UI
class PowerupButton extends ConsumerStatefulWidget {
  final PowerupEntity powerup;
  final VoidCallback onTap;
  final bool isEnabled;
  final bool showTooltip;
  final bool isActive; // New parameter to show if powerup is currently active

  const PowerupButton({
    super.key,
    required this.powerup,
    required this.onTap,
    this.isEnabled = true,
    this.showTooltip = true,
    this.isActive = false,
  });

  @override
  ConsumerState<PowerupButton> createState() => _PowerupButtonState();
}

class _PowerupButtonState extends ConsumerState<PowerupButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(
        milliseconds: AppConstants.powerupActivationAnimationDuration,
      ),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Debug logging removed for performance
    if (!widget.isEnabled) {
      return;
    }

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    widget.onTap();
  }

  Color _getPowerupColor() {
    switch (widget.powerup.type) {
      case PowerupType.tileFreeze:
        return const Color(0xFF2196F3); // Blue
      case PowerupType.undoMove:
        return const Color(0xFF9C27B0); // Purple
      case PowerupType.shuffleBoard:
        return const Color(0xFFFFD700); // Gold
      case PowerupType.tileDestroyer:
        return const Color(0xFFF44336); // Red
      case PowerupType.valueUpgrade:
        return const Color(0xFF4CAF50); // Green
      case PowerupType.rowClear:
        return const Color(0xFFFF9800); // Orange
      case PowerupType.columnClear:
        return const Color(0xFFFF5722); // Deep Orange
      case PowerupType.blockerShield:
        return const Color(0xFF8BC34A); // Light Green
      case PowerupType.tileShrink:
        return const Color(0xFFE91E63); // Pink
      case PowerupType.lockTile:
        return const Color(0xFF3F51B5); // Indigo
      case PowerupType.valueTarget:
        return const Color(0xFFFF5722); // Deep Orange
      case PowerupType.timeSlow:
        return const Color(0xFF00BCD4); // Cyan
      case PowerupType.valueFinder:
        return const Color(0xFFCDDC39); // Lime
      case PowerupType.cornerGather:
        return const Color(0xFF673AB7); // Deep Purple
      case PowerupType.rowColumnClear: // Legacy support
        return const Color(0xFFFF9800); // Orange
    }
  }

  @override
  Widget build(BuildContext context) {
    final powerupColor = _getPowerupColor();
    final isCurrentlyActive = widget.isActive;

    // Different visual states for active vs available powerups
    final backgroundColor = isCurrentlyActive
        ? powerupColor.withValues(alpha: 0.9)
        : widget.isEnabled
        ? powerupColor.withValues(alpha: 0.7)
        : Colors.grey.shade400;

    final borderColor = isCurrentlyActive
        ? Colors.white
        : widget.isEnabled
        ? powerupColor.withValues(alpha: 0.8)
        : Colors.grey.shade300;

    final borderWidth = isCurrentlyActive ? 3.0 : 2.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              color: backgroundColor,
              boxShadow: [
                if (isCurrentlyActive) ...[
                  // Strong glow for active powerups
                  BoxShadow(
                    color: powerupColor.withValues(
                      alpha: 0.6 * _glowAnimation.value,
                    ),
                    blurRadius: 15.0 * _glowAnimation.value,
                    spreadRadius: 3.0 * _glowAnimation.value,
                  ),
                ] else if (widget.isEnabled) ...[
                  // Subtle glow for available powerups
                  BoxShadow(
                    color: powerupColor.withValues(
                      alpha: 0.3 * _glowAnimation.value,
                    ),
                    blurRadius: 8.0 * _glowAnimation.value,
                    spreadRadius: 2.0 * _glowAnimation.value,
                  ),
                ],
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
                onTap: widget.isEnabled ? _handleTap : null,
                child: widget.showTooltip
                    ? Tooltip(
                        message:
                            '${widget.powerup.type.displayName}\n${widget.powerup.type.description}',
                        preferBelow: false,
                        child: _buildContent(),
                      )
                    : _buildContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    final isCurrentlyActive = widget.isActive;
    final powerupColor = _getPowerupColor();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.powerup.type.icon,
          style: TextStyle(
            fontSize: isCurrentlyActive ? 28 : 24, // Larger icon when active
            color: widget.isEnabled ? Colors.white : Colors.grey.shade600,
          ),
        ),
        if (widget.powerup.type.defaultDuration > 1) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: widget.isEnabled
                  ? (isCurrentlyActive
                        ? Colors.white.withValues(alpha: 1.0)
                        : Colors.white.withValues(alpha: 0.9))
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isCurrentlyActive
                  ? '${widget.powerup.movesRemaining}' // Show remaining moves when active
                  : '${widget.powerup.type.defaultDuration}', // Show default duration when available
              style: TextStyle(
                fontSize: isCurrentlyActive ? 12 : 10,
                fontWeight: FontWeight.bold,
                color: widget.isEnabled
                    ? (isCurrentlyActive ? powerupColor : powerupColor)
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ],
        // Add "ACTIVE" label for active powerups
        if (isCurrentlyActive) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'ACTIVE',
              style: TextStyle(
                fontSize: 6,
                fontWeight: FontWeight.bold,
                color: powerupColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Powerup button for active powerups showing remaining moves
class ActivePowerupIndicator extends ConsumerWidget {
  final PowerupEntity powerup;

  const ActivePowerupIndicator({super.key, required this.powerup});

  Color _getPowerupColor() {
    switch (powerup.type) {
      case PowerupType.tileFreeze:
        return const Color(0xFF2196F3); // Blue
      case PowerupType.undoMove:
        return const Color(0xFF9C27B0); // Purple
      case PowerupType.shuffleBoard:
        return const Color(0xFFFFD700); // Gold
      case PowerupType.tileDestroyer:
        return const Color(0xFFF44336); // Red
      case PowerupType.valueUpgrade:
        return const Color(0xFF4CAF50); // Green
      case PowerupType.rowClear:
        return const Color(0xFFFF9800); // Orange
      case PowerupType.columnClear:
        return const Color(0xFFFF5722); // Deep Orange
      case PowerupType.blockerShield:
        return const Color(0xFF8BC34A); // Light Green
      case PowerupType.tileShrink:
        return const Color(0xFFE91E63); // Pink
      case PowerupType.lockTile:
        return const Color(0xFF3F51B5); // Indigo
      case PowerupType.valueTarget:
        return const Color(0xFFFF5722); // Deep Orange
      case PowerupType.timeSlow:
        return const Color(0xFF00BCD4); // Cyan
      case PowerupType.valueFinder:
        return const Color(0xFFCDDC39); // Lime
      case PowerupType.cornerGather:
        return const Color(0xFF673AB7); // Deep Purple
      case PowerupType.rowColumnClear: // Legacy support
        return const Color(0xFFFF9800); // Orange
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final powerupColor = _getPowerupColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: powerupColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: powerupColor.withValues(alpha: 0.3),
            blurRadius: 4.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            powerup.type.icon,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Text(
            '${powerup.movesRemaining}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
