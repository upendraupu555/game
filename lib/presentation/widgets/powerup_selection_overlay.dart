import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/powerup_entity.dart';
import '../../core/constants/app_constants.dart';
import '../providers/powerup_selection_providers.dart';
import '../providers/game_providers.dart';

/// Overlay widget that appears when in powerup selection mode
class PowerupSelectionOverlay extends ConsumerWidget {
  const PowerupSelectionOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(powerupSelectionProvider);

    if (!selectionState.isSelectionMode ||
        selectionState.activePowerupType == null) {
      return const SizedBox.shrink();
    }

    // Get safe area dimensions for proper positioning
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false, // Allow interaction with overlay elements
        child: Stack(
          children: [
            // Top instruction banner - positioned at the safe area top
            Positioned(
              top: safeAreaTop + AppConstants.paddingMedium,
              left: AppConstants.paddingMedium,
              right: AppConstants.paddingMedium,
              child: _buildInstructionBanner(context, ref, selectionState),
            ),

            // Cancel button - positioned at the bottom with safe area consideration
            Positioned(
              bottom:
                  safeAreaBottom +
                  AppConstants.paddingLarge +
                  60, // Account for banner ad height
              left: AppConstants.paddingLarge,
              right: AppConstants.paddingLarge,
              child: _buildCancelButton(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionBanner(
    BuildContext context,
    WidgetRef ref,
    PowerupSelectionState selectionState,
  ) {
    final powerupType = selectionState.activePowerupType!;
    final message = selectionState.selectionMessage ?? 'Tap to select target';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: _getPowerupColor(powerupType).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12.0,
            spreadRadius: 2.0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: _getPowerupColor(powerupType).withValues(alpha: 0.4),
            blurRadius: 8.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                powerupType.icon,
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      powerupType.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      message,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ref.read(gameProvider.notifier).cancelPowerupSelection();
        },
        icon: const Icon(Icons.close, color: Colors.white),
        label: const Text(
          'Cancel Selection',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          elevation: AppConstants.elevationMedium,
          shadowColor: Colors.black.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Color _getPowerupColor(PowerupType powerupType) {
    switch (powerupType) {
      case PowerupType.tileDestroyer:
        return const Color(0xFFF44336); // Red
      case PowerupType.rowClear:
        return const Color(0xFFFF9800); // Orange
      case PowerupType.columnClear:
        return const Color(0xFFFF5722); // Deep Orange
      default:
        return const Color(0xFF2196F3); // Blue
    }
  }
}

/// Widget that provides visual feedback for tiles during selection mode
class TileSelectionHighlight extends ConsumerWidget {
  final int row;
  final int col;
  final Widget child;
  final bool hasTile; // Whether this position has a tile entity

  const TileSelectionHighlight({
    super.key,
    required this.row,
    required this.col,
    required this.child,
    this.hasTile = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(powerupSelectionProvider);

    if (!selectionState.isSelectionMode ||
        selectionState.activePowerupType == null) {
      return child;
    }

    final powerupType = selectionState.activePowerupType!;
    final shouldHighlight = _shouldHighlightTile(powerupType, row, col);

    if (!shouldHighlight) {
      return child;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _getPowerupColor(powerupType), width: 2),
        boxShadow: [
          BoxShadow(
            color: _getPowerupColor(powerupType).withValues(alpha: 0.3),
            blurRadius: 8.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: child,
    );
  }

  bool _shouldHighlightTile(PowerupType powerupType, int row, int col) {
    switch (powerupType) {
      case PowerupType.tileDestroyer:
        // Only highlight tiles that actually have a tile entity
        return hasTile;
      case PowerupType.rowClear:
      case PowerupType.columnClear:
        // Highlight all positions since we can clear empty rows/columns too
        return true;
      default:
        return true;
    }
  }

  Color _getPowerupColor(PowerupType powerupType) {
    switch (powerupType) {
      case PowerupType.tileDestroyer:
        return const Color(0xFFF44336); // Red
      case PowerupType.rowClear:
        return const Color(0xFFFF9800); // Orange
      case PowerupType.columnClear:
        return const Color(0xFFFF5722); // Deep Orange
      default:
        return const Color(0xFF2196F3); // Blue
    }
  }
}

/// Widget that shows row/column indicators during selection mode
class SelectionModeIndicators extends ConsumerWidget {
  final int boardSize;

  const SelectionModeIndicators({super.key, required this.boardSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(powerupSelectionProvider);

    if (!selectionState.isSelectionMode ||
        selectionState.activePowerupType == null) {
      return const SizedBox.shrink();
    }

    final powerupType = selectionState.activePowerupType!;

    if (powerupType == PowerupType.rowClear) {
      return _buildRowIndicators();
    } else if (powerupType == PowerupType.columnClear) {
      return _buildColumnIndicators();
    }

    return const SizedBox.shrink();
  }

  Widget _buildRowIndicators() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Column(
          children: List.generate(boardSize, (index) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 1),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildColumnIndicators() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Row(
          children: List.generate(boardSize, (index) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFFF5722).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
