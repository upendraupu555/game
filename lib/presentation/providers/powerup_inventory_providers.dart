import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/powerup_entity.dart';
import '../../domain/usecases/powerup_usecases.dart';
import '../../core/logging/app_logger.dart';
import '../widgets/powerup_inventory_dialog.dart';
import 'powerup_providers.dart';

/// State for powerup inventory management
class PowerupInventoryState {
  final bool isDialogShowing;
  final PowerupType? pendingPowerupType;

  const PowerupInventoryState({
    this.isDialogShowing = false,
    this.pendingPowerupType,
  });

  PowerupInventoryState copyWith({
    bool? isDialogShowing,
    PowerupType? pendingPowerupType,
  }) {
    return PowerupInventoryState(
      isDialogShowing: isDialogShowing ?? this.isDialogShowing,
      pendingPowerupType: pendingPowerupType ?? this.pendingPowerupType,
    );
  }
}

/// Notifier for managing powerup inventory when full
class PowerupInventoryNotifier extends StateNotifier<PowerupInventoryState> {
  final Ref _ref;

  PowerupInventoryNotifier(this._ref) : super(const PowerupInventoryState());

  /// Attempt to add a powerup, showing dialog if inventory is full
  Future<bool> attemptAddPowerup(
    BuildContext context,
    GameEntity gameState,
    PowerupType powerupType,
  ) async {
    try {
      final addPowerupUseCase = AddPowerupUseCase();
      final (newState, result) = addPowerupUseCase.execute(
        gameState,
        powerupType,
      );

      switch (result) {
        case AddPowerupResult.success:
          // Powerup was successfully added
          _ref
              .read(powerupNotificationProvider.notifier)
              .showNewPowerup(powerupType);

          AppLogger.debug(
            '🎁 Powerup earned and added',
            tag: 'PowerupInventoryNotifier',
            data: {
              'powerupType': powerupType.name,
              'powerupIcon': powerupType.icon,
            },
          );
          return true;

        case AddPowerupResult.inventoryFull:
          // Show inventory management dialog
          await _showInventoryManagementDialog(context, gameState, powerupType);
          return false;

        case AddPowerupResult.alreadyExists:
          AppLogger.warning(
            '🔄 Powerup not added - already exists',
            tag: 'PowerupInventoryNotifier',
            data: {'powerupType': powerupType.name},
          );
          return false;
      }
    } catch (error) {
      AppLogger.error(
        'Failed to attempt add powerup',
        tag: 'PowerupInventoryNotifier',
        error: error,
      );
      return false;
    }
  }

  /// Show inventory management dialog when inventory is full
  Future<void> _showInventoryManagementDialog(
    BuildContext context,
    GameEntity gameState,
    PowerupType newPowerupType,
  ) async {
    if (state.isDialogShowing) {
      return; // Prevent multiple dialogs
    }

    state = state.copyWith(
      isDialogShowing: true,
      pendingPowerupType: newPowerupType,
    );

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PowerupInventoryDialog(
          newPowerupType: newPowerupType,
          currentPowerups: gameState.availablePowerups,
          onReplacePowerup: (powerupTypeToReplace) async {
            await _replacePowerup(
              gameState,
              powerupTypeToReplace,
              newPowerupType,
            );
          },
          onDiscardNewPowerup: () {
            AppLogger.info(
              '🗑️ New powerup discarded by user choice',
              tag: 'PowerupInventoryNotifier',
              data: {'powerupType': newPowerupType.name},
            );
          },
        ),
      );
    } finally {
      state = state.copyWith(isDialogShowing: false, pendingPowerupType: null);
    }
  }

  /// Replace an existing powerup with a new one
  Future<void> _replacePowerup(
    GameEntity gameState,
    PowerupType powerupTypeToReplace,
    PowerupType newPowerupType,
  ) async {
    try {
      // Remove the old powerup
      final updatedPowerups = gameState.availablePowerups
          .where((p) => p.type != powerupTypeToReplace)
          .toList();

      // Add the new powerup
      final newPowerup = PowerupEntity.create(newPowerupType);
      updatedPowerups.add(newPowerup);

      // This would need to be handled by the game provider
      // For now, we'll just log the action
      AppLogger.info(
        '🔄 Powerup replacement requested',
        tag: 'PowerupInventoryNotifier',
        data: {
          'replacedPowerup': powerupTypeToReplace.name,
          'newPowerup': newPowerupType.name,
        },
      );

      // Show notification for the new powerup
      _ref
          .read(powerupNotificationProvider.notifier)
          .showNewPowerup(newPowerupType);
    } catch (error) {
      AppLogger.error(
        'Failed to replace powerup',
        tag: 'PowerupInventoryNotifier',
        error: error,
      );
    }
  }
}

/// Provider for powerup inventory management
final powerupInventoryProvider =
    StateNotifierProvider<PowerupInventoryNotifier, PowerupInventoryState>((
      ref,
    ) {
      return PowerupInventoryNotifier(ref);
    });

/// Provider to check if powerup inventory dialog is showing
final isInventoryDialogShowingProvider = Provider<bool>((ref) {
  return ref.watch(powerupInventoryProvider).isDialogShowing;
});
