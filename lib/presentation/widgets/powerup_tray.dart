import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/powerup_entity.dart';
import '../../core/constants/app_constants.dart';
import 'powerup_button.dart';

/// Powerup tray widget that displays available powerups at the bottom of the game screen
class PowerupTray extends ConsumerWidget {
  final List<PowerupEntity> availablePowerups;
  final List<PowerupEntity> activePowerups;
  final Function(PowerupType) onPowerupTap;
  final bool isGameActive;
  final bool isScenicMode;

  const PowerupTray({
    super.key,
    required this.availablePowerups,
    required this.activePowerups,
    required this.onPowerupTap,
    this.isGameActive = true,
    this.isScenicMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: _buildPowerupTrayDecoration(theme),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active powerups indicator
          if (activePowerups.isNotEmpty) ...[
            _buildActivePowerupsSection(),
            const SizedBox(height: AppConstants.paddingMedium),
          ],

          // Available powerups section
          _buildAvailablePowerupsSection(theme),
        ],
      ),
    );
  }

  /// Build powerup tray decoration with scenic mode support
  BoxDecoration _buildPowerupTrayDecoration(ThemeData theme) {
    if (isScenicMode) {
      // Semi-transparent powerup tray for scenic mode with glass-morphism effect
      return BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: AppConstants.scenicPowerupTrayOpacity,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusLarge),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12.0,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6.0,
            offset: const Offset(0, -2),
          ),
        ],
      );
    } else {
      // Regular powerup tray decoration
      return BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      );
    }
  }

  Widget _buildActivePowerupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Powerups',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: activePowerups
              .map((powerup) => ActivePowerupIndicator(powerup: powerup))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAvailablePowerupsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Powerups',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${availablePowerups.length}/${AppConstants.maxPowerupsInInventory}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),

        // Powerup slots
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(AppConstants.maxPowerupsInInventory, (index) {
            if (index < availablePowerups.length) {
              final powerup = availablePowerups[index];
              // Check if this powerup type is currently active
              final isActive = activePowerups.any(
                (p) => p.type == powerup.type,
              );
              final isEnabled =
                  isGameActive && powerup.isAvailable && !isActive;

              print(
                '🎮 PowerupTray: powerup=${powerup.type.name}, isGameActive=$isGameActive, powerup.isAvailable=${powerup.isAvailable}, isActive=$isActive, isEnabled=$isEnabled',
              );

              return PowerupButton(
                powerup: powerup,
                onTap: () => onPowerupTap(powerup.type),
                isEnabled: isEnabled,
                showTooltip: true,
                isActive: isActive,
              );
            } else {
              return _buildEmptySlot(theme);
            }
          }),
        ),

        // Powerup acquisition hint
        if (availablePowerups.isEmpty) ...[
          const SizedBox(height: AppConstants.paddingSmall),
          _buildPowerupHint(theme),
        ],
      ],
    );
  }

  Widget _buildEmptySlot(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 2.0,
          style: BorderStyle.solid,
        ),
      ),
      child: Icon(
        Icons.add,
        color: theme.colorScheme.outline.withOpacity(0.5),
        size: 24,
      ),
    );
  }

  Widget _buildPowerupHint(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Reach score milestones to unlock powerups!',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact powerup tray for smaller screens
class CompactPowerupTray extends ConsumerWidget {
  final List<PowerupEntity> availablePowerups;
  final List<PowerupEntity> activePowerups;
  final Function(PowerupType) onPowerupTap;
  final bool isGameActive;

  const CompactPowerupTray({
    super.key,
    required this.availablePowerups,
    required this.activePowerups,
    required this.onPowerupTap,
    this.isGameActive = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Active powerups
          if (activePowerups.isNotEmpty) ...[
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: activePowerups
                      .map(
                        (powerup) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActivePowerupIndicator(powerup: powerup),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.outline.withOpacity(0.3),
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],

          // Available powerups
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                AppConstants.maxPowerupsInInventory.clamp(0, 3),
                (index) {
                  if (index < availablePowerups.length) {
                    final powerup = availablePowerups[index];
                    // Check if this powerup type is currently active
                    final isActive = activePowerups.any(
                      (p) => p.type == powerup.type,
                    );
                    return PowerupButton(
                      powerup: powerup,
                      onTap: () => onPowerupTap(powerup.type),
                      isEnabled:
                          isGameActive && powerup.isAvailable && !isActive,
                      showTooltip: false, // Compact mode - no tooltips
                      isActive: isActive,
                    );
                  } else {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusSmall,
                        ),
                        color: theme.colorScheme.surface,
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        color: theme.colorScheme.outline.withOpacity(0.3),
                        size: 20,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
