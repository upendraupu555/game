import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/powerup_entity.dart';
import '../../core/logging/app_logger.dart';

/// State for interactive powerup selection mode
class PowerupSelectionState {
  final bool isSelectionMode;
  final PowerupType? activePowerupType;
  final String? selectionMessage;

  const PowerupSelectionState({
    this.isSelectionMode = false,
    this.activePowerupType,
    this.selectionMessage,
  });

  PowerupSelectionState copyWith({
    bool? isSelectionMode,
    PowerupType? activePowerupType,
    String? selectionMessage,
  }) {
    return PowerupSelectionState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      activePowerupType: activePowerupType ?? this.activePowerupType,
      selectionMessage: selectionMessage ?? this.selectionMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PowerupSelectionState &&
          runtimeType == other.runtimeType &&
          isSelectionMode == other.isSelectionMode &&
          activePowerupType == other.activePowerupType &&
          selectionMessage == other.selectionMessage;

  @override
  int get hashCode =>
      isSelectionMode.hashCode ^
      activePowerupType.hashCode ^
      selectionMessage.hashCode;

  @override
  String toString() {
    return 'PowerupSelectionState{isSelectionMode: $isSelectionMode, activePowerupType: $activePowerupType, selectionMessage: $selectionMessage}';
  }
}

/// Notifier for managing interactive powerup selection state
class PowerupSelectionNotifier extends StateNotifier<PowerupSelectionState> {
  PowerupSelectionNotifier() : super(const PowerupSelectionState());

  /// Enter selection mode for an interactive powerup
  void enterSelectionMode(PowerupType powerupType) {
    final message = _getSelectionMessage(powerupType);
    
    state = state.copyWith(
      isSelectionMode: true,
      activePowerupType: powerupType,
      selectionMessage: message,
    );

    AppLogger.userAction('POWERUP_SELECTION_MODE_ENTERED', data: {
      'powerupType': powerupType.name,
      'powerupIcon': powerupType.icon,
      'selectionMessage': message,
    });
  }

  /// Exit selection mode
  void exitSelectionMode() {
    final previousPowerupType = state.activePowerupType;
    
    state = const PowerupSelectionState();

    if (previousPowerupType != null) {
      AppLogger.userAction('POWERUP_SELECTION_MODE_EXITED', data: {
        'previousPowerupType': previousPowerupType.name,
      });
    }
  }

  /// Get the appropriate selection message for a powerup type
  String _getSelectionMessage(PowerupType powerupType) {
    switch (powerupType) {
      case PowerupType.tileDestroyer:
        return 'Tap any tile to destroy it';
      case PowerupType.rowClear:
        return 'Tap any tile to clear its entire row';
      case PowerupType.columnClear:
        return 'Tap any tile to clear its entire column';
      default:
        return 'Tap to select target';
    }
  }
}

/// Provider for powerup selection state
final powerupSelectionProvider = StateNotifierProvider<PowerupSelectionNotifier, PowerupSelectionState>((ref) {
  return PowerupSelectionNotifier();
});

/// Computed provider to check if we're in selection mode
final isInSelectionModeProvider = Provider<bool>((ref) {
  final selectionState = ref.watch(powerupSelectionProvider);
  return selectionState.isSelectionMode;
});

/// Computed provider to get the active powerup type during selection
final activePowerupTypeProvider = Provider<PowerupType?>((ref) {
  final selectionState = ref.watch(powerupSelectionProvider);
  return selectionState.activePowerupType;
});

/// Computed provider to get the selection message
final selectionMessageProvider = Provider<String?>((ref) {
  final selectionState = ref.watch(powerupSelectionProvider);
  return selectionState.selectionMessage;
});

/// Provider to check if a specific powerup type is currently being selected
final isPowerupBeingSelectedProvider = Provider.family<bool, PowerupType>((ref, powerupType) {
  final activePowerupType = ref.watch(activePowerupTypeProvider);
  return activePowerupType == powerupType;
});
