import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/powerup_entity.dart';
import '../../domain/usecases/powerup_usecases.dart';
import '../../core/logging/app_logger.dart';
import 'game_providers.dart';

// Use case providers
final checkPowerupAwardUseCaseProvider = Provider<CheckPowerupAwardUseCase>((ref) {
  return CheckPowerupAwardUseCase();
});

final activatePowerupUseCaseProvider = Provider<ActivatePowerupUseCase>((ref) {
  return ActivatePowerupUseCase();
});

final processPowerupEffectsUseCaseProvider = Provider<ProcessPowerupEffectsUseCase>((ref) {
  return ProcessPowerupEffectsUseCase();
});

final addPowerupUseCaseProvider = Provider<AddPowerupUseCase>((ref) {
  return AddPowerupUseCase();
});

final checkTileSpawnPreventionUseCaseProvider = Provider<CheckTileSpawnPreventionUseCase>((ref) {
  return CheckTileSpawnPreventionUseCase();
});

final checkMergeBoostUseCaseProvider = Provider<CheckMergeBoostUseCase>((ref) {
  return CheckMergeBoostUseCase();
});

final checkBlockerShieldUseCaseProvider = Provider<CheckBlockerShieldUseCase>((ref) {
  return CheckBlockerShieldUseCase();
});

final getPowerupVisualEffectsUseCaseProvider = Provider<GetPowerupVisualEffectsUseCase>((ref) {
  return GetPowerupVisualEffectsUseCase();
});

// Powerup state providers
final availablePowerupsProvider = Provider<List<PowerupEntity>>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.value?.availablePowerups ?? [];
});

final activePowerupsProvider = Provider<List<PowerupEntity>>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.value?.activePowerups ?? [];
});

final usedPowerupTypesProvider = Provider<Set<PowerupType>>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.value?.usedPowerupTypes ?? {};
});

// Powerup effect providers
final isTileFreezeActiveProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.value?.isTileFreezeActive ?? false;
});

final isMergeBoostActiveProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.value?.isMergeBoostActive ?? false;
});

final isBlockerShieldActiveProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.value?.isBlockerShieldActive ?? false;
});

// Powerup visual effects provider
final powerupVisualEffectsProvider = Provider<Map<PowerupType, PowerupVisualEffect>>((ref) {
  final gameState = ref.watch(gameProvider);
  final getEffectsUseCase = ref.watch(getPowerupVisualEffectsUseCaseProvider);
  
  if (gameState.value == null) return {};
  
  return getEffectsUseCase.execute(gameState.value!);
});

// Powerup availability provider
final powerupAvailabilityProvider = Provider<Map<PowerupType, bool>>((ref) {
  final gameState = ref.watch(gameProvider);
  final availablePowerups = ref.watch(availablePowerupsProvider);
  final usedPowerupTypes = ref.watch(usedPowerupTypesProvider);
  
  if (gameState.value == null) return {};
  
  final availability = <PowerupType, bool>{};
  
  for (final powerupType in PowerupType.values) {
    final isAvailable = availablePowerups.any((p) => p.type == powerupType);
    final isUsed = usedPowerupTypes.contains(powerupType);
    final canUse = isAvailable && !isUsed && !gameState.value!.isGameOver;
    
    availability[powerupType] = canUse;
  }
  
  return availability;
});

// Powerup acquisition provider - checks if new powerups should be awarded
final powerupAcquisitionProvider = Provider<List<PowerupType>>((ref) {
  final gameState = ref.watch(gameProvider);
  final checkAwardUseCase = ref.watch(checkPowerupAwardUseCaseProvider);
  
  if (gameState.value == null) return [];
  
  return checkAwardUseCase.execute(gameState.value!);
});

// Powerup notification provider for showing powerup acquisition notifications
final powerupNotificationProvider = StateNotifierProvider<PowerupNotificationNotifier, PowerupNotificationState>((ref) {
  return PowerupNotificationNotifier();
});

class PowerupNotificationState {
  final List<PowerupType> newPowerups;
  final List<PowerupType> activatedPowerups;
  final List<PowerupType> expiredPowerups;

  const PowerupNotificationState({
    this.newPowerups = const [],
    this.activatedPowerups = const [],
    this.expiredPowerups = const [],
  });

  PowerupNotificationState copyWith({
    List<PowerupType>? newPowerups,
    List<PowerupType>? activatedPowerups,
    List<PowerupType>? expiredPowerups,
  }) {
    return PowerupNotificationState(
      newPowerups: newPowerups ?? this.newPowerups,
      activatedPowerups: activatedPowerups ?? this.activatedPowerups,
      expiredPowerups: expiredPowerups ?? this.expiredPowerups,
    );
  }

  bool get hasNotifications => 
      newPowerups.isNotEmpty || 
      activatedPowerups.isNotEmpty || 
      expiredPowerups.isNotEmpty;
}

class PowerupNotificationNotifier extends StateNotifier<PowerupNotificationState> {
  PowerupNotificationNotifier() : super(const PowerupNotificationState());

  void showNewPowerup(PowerupType powerupType) {
    state = state.copyWith(
      newPowerups: [...state.newPowerups, powerupType],
    );

    AppLogger.debug('🎁 New powerup notification', tag: 'PowerupNotificationNotifier', data: {
      'powerupType': powerupType.name,
      'powerupIcon': powerupType.icon,
    });

    // Auto-clear after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      clearNewPowerup(powerupType);
    });
  }

  void showActivatedPowerup(PowerupType powerupType) {
    state = state.copyWith(
      activatedPowerups: [...state.activatedPowerups, powerupType],
    );

    AppLogger.debug('⚡ Powerup activated notification', tag: 'PowerupNotificationNotifier', data: {
      'powerupType': powerupType.name,
      'powerupIcon': powerupType.icon,
    });

    // Auto-clear after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      clearActivatedPowerup(powerupType);
    });
  }

  void showExpiredPowerup(PowerupType powerupType) {
    state = state.copyWith(
      expiredPowerups: [...state.expiredPowerups, powerupType],
    );

    AppLogger.debug('⏰ Powerup expired notification', tag: 'PowerupNotificationNotifier', data: {
      'powerupType': powerupType.name,
      'powerupIcon': powerupType.icon,
    });

    // Auto-clear after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      clearExpiredPowerup(powerupType);
    });
  }

  void clearNewPowerup(PowerupType powerupType) {
    state = state.copyWith(
      newPowerups: state.newPowerups.where((p) => p != powerupType).toList(),
    );
  }

  void clearActivatedPowerup(PowerupType powerupType) {
    state = state.copyWith(
      activatedPowerups: state.activatedPowerups.where((p) => p != powerupType).toList(),
    );
  }

  void clearExpiredPowerup(PowerupType powerupType) {
    state = state.copyWith(
      expiredPowerups: state.expiredPowerups.where((p) => p != powerupType).toList(),
    );
  }

  void clearAllNotifications() {
    state = const PowerupNotificationState();
  }
}

// Powerup tutorial provider for showing first-time usage hints
final powerupTutorialProvider = StateNotifierProvider<PowerupTutorialNotifier, Set<PowerupType>>((ref) {
  return PowerupTutorialNotifier();
});

class PowerupTutorialNotifier extends StateNotifier<Set<PowerupType>> {
  PowerupTutorialNotifier() : super(<PowerupType>{});

  void markTutorialShown(PowerupType powerupType) {
    state = {...state, powerupType};
  }

  bool shouldShowTutorial(PowerupType powerupType) {
    return !state.contains(powerupType);
  }

  void resetTutorials() {
    state = <PowerupType>{};
  }
}
