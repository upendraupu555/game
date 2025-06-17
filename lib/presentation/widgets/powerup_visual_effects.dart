import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/powerup_entity.dart';
import '../../domain/usecases/powerup_usecases.dart';
import '../../core/constants/app_constants.dart';
import '../providers/powerup_providers.dart';

/// Visual effects overlay for active powerups
class PowerupVisualEffects extends ConsumerStatefulWidget {
  final Widget child;

  const PowerupVisualEffects({super.key, required this.child});

  @override
  ConsumerState<PowerupVisualEffects> createState() =>
      _PowerupVisualEffectsState();
}

class _PowerupVisualEffectsState extends ConsumerState<PowerupVisualEffects>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visualEffects = ref.watch(powerupVisualEffectsProvider);
    final isTileFreezeActive = ref.watch(isTileFreezeActiveProvider);

    final isBlockerShieldActive = ref.watch(isBlockerShieldActiveProvider);

    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _pulseController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Base game board
            Transform.scale(
              scale: _shouldShowPulse(visualEffects)
                  ? _pulseAnimation.value
                  : 1.0,
              child: widget.child,
            ),

            // Tile Freeze effect - Blue glow around board edges
            if (isTileFreezeActive) _buildTileFreezeEffect(),

            // Blocker Shield effect - Green shield indicator
            if (isBlockerShieldActive) _buildBlockerShieldEffect(),
          ],
        );
      },
    );
  }

  bool _shouldShowPulse(Map<PowerupType, PowerupVisualEffect> effects) {
    return effects.values.any(
      (effect) =>
          effect.isActive && [PowerupType.valueUpgrade].contains(effect.type),
    );
  }

  Widget _buildTileFreezeEffect() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        // This allows touch events to pass through
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            border: Border.all(
              color: const Color(
                0xFF2196F3,
              ).withValues(alpha: _glowAnimation.value * 0.8),
              width: 4.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF2196F3,
                ).withValues(alpha: _glowAnimation.value * 0.3),
                blurRadius: 20.0,
                spreadRadius: 5.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockerShieldEffect() {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(
            0xFF4CAF50,
          ).withValues(alpha: _glowAnimation.value * 0.9),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF4CAF50,
              ).withValues(alpha: _glowAnimation.value * 0.5),
              blurRadius: 8.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Icon(
          Icons.shield,
          color: Colors.white.withValues(alpha: _glowAnimation.value),
          size: 20,
        ),
      ),
    );
  }
}

/// Powerup notification overlay for showing powerup acquisition/activation
class PowerupNotificationOverlay extends ConsumerStatefulWidget {
  final bool isScenicMode;

  const PowerupNotificationOverlay({super.key, this.isScenicMode = false});

  @override
  ConsumerState<PowerupNotificationOverlay> createState() =>
      _PowerupNotificationOverlayState();
}

class _PowerupNotificationOverlayState
    extends ConsumerState<PowerupNotificationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: Duration(
        milliseconds: AppConstants.powerupActivationAnimationDuration,
      ),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: AppConstants.powerupGlowEffectDuration),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(powerupNotificationProvider);

    if (!notificationState.hasNotifications) {
      return const SizedBox.shrink();
    }

    // Trigger animations when notifications appear
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (notificationState.hasNotifications) {
        _slideController.forward();
        _fadeController.forward();

        // Auto-hide after duration
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _slideController.reverse();
            _fadeController.reverse();
          }
        });
      }
    });

    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: Listenable.merge([_slideController, _fadeController]),
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildNotificationContent(notificationState),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationContent(PowerupNotificationState state) {
    final notifications = <Widget>[];

    // New powerup notifications
    for (final powerupType in state.newPowerups) {
      notifications.add(
        _buildNotificationCard(
          icon: powerupType.icon,
          title: 'New Powerup!',
          subtitle: powerupType.displayName,
          color: const Color(0xFF4CAF50),
        ),
      );
    }

    // Activated powerup notifications
    for (final powerupType in state.activatedPowerups) {
      notifications.add(
        _buildNotificationCard(
          icon: powerupType.icon,
          title: 'Powerup Activated!',
          subtitle: powerupType.displayName,
          color: const Color(0xFF2196F3),
        ),
      );
    }

    // Expired powerup notifications
    for (final powerupType in state.expiredPowerups) {
      notifications.add(
        _buildNotificationCard(
          icon: powerupType.icon,
          title: 'Powerup Expired',
          subtitle: powerupType.displayName,
          color: const Color(0xFF757575),
        ),
      );
    }

    return Column(children: notifications);
  }

  /// Build notification decoration with scenic mode support
  BoxDecoration _buildNotificationDecoration(Color color) {
    if (widget.isScenicMode) {
      // Enhanced transparency and glass-morphism for scenic mode
      return BoxDecoration(
        color: color.withValues(
          alpha: AppConstants.scenicPowerupNotificationOpacity,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12.0,
            spreadRadius: 2.0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8.0,
            spreadRadius: 1.0,
          ),
        ],
      );
    } else {
      // Regular notification decoration
      return BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8.0,
            spreadRadius: 2.0,
          ),
        ],
      );
    }
  }

  Widget _buildNotificationCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: _buildNotificationDecoration(color),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24, color: Colors.white)),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
