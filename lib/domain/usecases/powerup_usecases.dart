import '../entities/game_entity.dart';
import '../entities/powerup_entity.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';

/// Use case for checking if a powerup should be awarded based on score
class CheckPowerupAwardUseCase {
  CheckPowerupAwardUseCase();

  /// Check if any powerups should be awarded for the current score
  List<PowerupType> execute(GameEntity gameState) {
    final score = gameState.score;
    final awardedPowerups = <PowerupType>[];

    // Calculate how many powerups should be unlocked based on score
    final powerupsEarned = _calculatePowerupsEarned(score);
    final currentPowerupsUnlocked = gameState.totalPowerupsUnlocked;

    // If player has earned more powerups than currently unlocked, award random ones
    if (powerupsEarned > currentPowerupsUnlocked) {
      final powerupsToAward = powerupsEarned - currentPowerupsUnlocked;

      // Get available powerup types that haven't been unlocked yet
      final availablePowerupTypes = PowerupType.values
          .where((type) => type.isPrimary)
          .where((type) => !gameState.isPowerupEverUnlocked(type))
          .toList();

      // Randomly select powerups to award
      availablePowerupTypes.shuffle();
      final selectedPowerups = availablePowerupTypes.take(powerupsToAward).toList();

      awardedPowerups.addAll(selectedPowerups);
    }

    AppLogger.debug('🎁 Checking powerup awards', tag: 'CheckPowerupAwardUseCase', data: {
      'score': score,
      'powerupsEarned': powerupsEarned,
      'currentPowerupsUnlocked': currentPowerupsUnlocked,
      'awardedPowerups': awardedPowerups.map((p) => p.name).toList(),
      'availablePowerups': gameState.availablePowerups.length,
    });

    return awardedPowerups;
  }

  /// Calculate how many powerups should be earned based on score
  /// First powerup at 1,000 points, then every 2,000 points after that
  int _calculatePowerupsEarned(int score) {
    if (score < 1000) return 0;

    // First powerup at 1,000, then every 2,000 points
    // 1,000 = 1 powerup
    // 3,000 = 2 powerups
    // 5,000 = 3 powerups
    // 7,000 = 4 powerups
    // etc.
    return 1 + ((score - 1000) ~/ 2000);
  }
}

/// Use case for activating a powerup
class ActivatePowerupUseCase {
  ActivatePowerupUseCase();

  /// Activate a powerup if available
  GameEntity execute(GameEntity gameState, PowerupType powerupType) {
    print('🔧 ActivatePowerupUseCase.execute called with powerupType: ${powerupType.name}');

    // Check if powerup is available
    final hasAvailablePowerup = gameState.availablePowerups.any((p) => p.type == powerupType);
    print('🔍 Checking if powerup is available: $hasAvailablePowerup');
    print('📋 Available powerups: ${gameState.availablePowerups.map((p) => '${p.type.name}(available:${p.isAvailable})').toList()}');

    if (!hasAvailablePowerup) {
      print('❌ ActivatePowerupUseCase: Powerup not available');
      AppLogger.warning('❌ Powerup not available', tag: 'ActivatePowerupUseCase', data: {
        'powerupType': powerupType.name,
        'availablePowerups': gameState.availablePowerups.map((p) => p.type.name).toList(),
      });
      return gameState;
    }

    // Check if powerup was already used
    final isAlreadyUsed = gameState.isPowerupUsed(powerupType);
    print('🔍 Checking if powerup was already used: $isAlreadyUsed');

    if (isAlreadyUsed) {
      print('❌ ActivatePowerupUseCase: Powerup already used');
      AppLogger.warning('❌ Powerup already used', tag: 'ActivatePowerupUseCase', data: {
        'powerupType': powerupType.name,
      });
      return gameState;
    }

    print('✅ ActivatePowerupUseCase: Calling gameState.activatePowerup...');
    final newGameState = gameState.activatePowerup(powerupType);
    print('✅ ActivatePowerupUseCase: gameState.activatePowerup completed');
    print('📊 Result: availablePowerups=${newGameState.availablePowerups.length}, activePowerups=${newGameState.activePowerups.length}');

    AppLogger.userAction('POWERUP_ACTIVATED', data: {
      'powerupType': powerupType.name,
      'powerupIcon': powerupType.icon,
      'duration': powerupType.defaultDuration,
      'score': gameState.score,
    });

    return newGameState;
  }
}

/// Use case for processing powerup effects during gameplay
class ProcessPowerupEffectsUseCase {
  ProcessPowerupEffectsUseCase();

  /// Process all active powerup effects and update their durations
  GameEntity execute(GameEntity gameState) {
    if (gameState.activePowerups.isEmpty) {
      return gameState;
    }

    final updatedGameState = gameState.processPowerupEffects();

    // Log expired powerups
    final expiredPowerups = gameState.activePowerups
        .where((powerup) => !updatedGameState.activePowerups.any((p) => p.id == powerup.id))
        .toList();

    for (final expiredPowerup in expiredPowerups) {
      AppLogger.debug('⏰ Powerup expired', tag: 'ProcessPowerupEffectsUseCase', data: {
        'powerupType': expiredPowerup.type.name,
        'powerupIcon': expiredPowerup.type.icon,
      });
    }

    return updatedGameState;
  }
}

/// Use case for adding powerups to the game state
class AddPowerupUseCase {
  AddPowerupUseCase();

  /// Add a powerup to the available powerups list
  GameEntity execute(GameEntity gameState, PowerupType powerupType) {
    // Check if inventory is full
    if (gameState.availablePowerups.length >= AppConstants.maxPowerupsInInventory) {
      AppLogger.warning('📦 Powerup inventory full', tag: 'AddPowerupUseCase', data: {
        'powerupType': powerupType.name,
        'inventorySize': gameState.availablePowerups.length,
        'maxInventorySize': AppConstants.maxPowerupsInInventory,
      });
      return gameState;
    }

    // Check if powerup already exists
    if (gameState.availablePowerups.any((p) => p.type == powerupType)) {
      AppLogger.warning('🔄 Powerup already in inventory', tag: 'AddPowerupUseCase', data: {
        'powerupType': powerupType.name,
      });
      return gameState;
    }

    final powerup = PowerupEntity.create(powerupType);
    final newGameState = gameState.addPowerup(powerup);

    AppLogger.debug('🎁 Powerup added to inventory', tag: 'AddPowerupUseCase', data: {
      'powerupType': powerupType.name,
      'powerupIcon': powerupType.icon,
      'inventorySize': newGameState.availablePowerups.length,
    });

    return newGameState;
  }
}

/// Use case for checking if tile spawning should be prevented (Tile Freeze effect)
class CheckTileSpawnPreventionUseCase {
  CheckTileSpawnPreventionUseCase();

  /// Check if new tile spawning should be prevented due to active powerups
  bool execute(GameEntity gameState) {
    final isTileFreezeActive = gameState.isTileFreezeActive;

    if (isTileFreezeActive) {
      AppLogger.debug('🧊 Tile spawning prevented by Tile Freeze', tag: 'CheckTileSpawnPreventionUseCase', data: {
        'tileFreezeMovesRemaining': gameState.getActivePowerup(PowerupType.tileFreeze)?.movesRemaining,
      });
    }

    return isTileFreezeActive;
  }
}

/// Use case for checking if merge boost is active (allows different value merges)
class CheckMergeBoostUseCase {
  CheckMergeBoostUseCase();

  /// Check if merge boost is active, allowing tiles with different values to merge
  bool execute(GameEntity gameState) {
    final isMergeBoostActive = gameState.isMergeBoostActive;

    if (isMergeBoostActive) {
      AppLogger.debug('🔄 Merge boost active', tag: 'CheckMergeBoostUseCase', data: {
        'mergeBoostMovesRemaining': gameState.getActivePowerup(PowerupType.mergeBoost)?.movesRemaining,
      });
    }

    return isMergeBoostActive;
  }
}

/// Use case for checking if blocker shield is active (prevents blocker tiles)
class CheckBlockerShieldUseCase {
  CheckBlockerShieldUseCase();

  /// Check if blocker shield is active, preventing blocker tile spawning
  bool execute(GameEntity gameState) {
    final isBlockerShieldActive = gameState.isBlockerShieldActive;

    if (isBlockerShieldActive) {
      AppLogger.debug('🛡️ Blocker shield active', tag: 'CheckBlockerShieldUseCase', data: {
        'blockerShieldMovesRemaining': gameState.getActivePowerup(PowerupType.blockerShield)?.movesRemaining,
      });
    }

    return isBlockerShieldActive;
  }
}

/// Use case for getting powerup visual effects data
class GetPowerupVisualEffectsUseCase {
  GetPowerupVisualEffectsUseCase();

  /// Get visual effects data for active powerups
  Map<PowerupType, PowerupVisualEffect> execute(GameEntity gameState) {
    final effects = <PowerupType, PowerupVisualEffect>{};

    for (final powerup in gameState.activePowerups) {
      effects[powerup.type] = PowerupVisualEffect(
        type: powerup.type,
        movesRemaining: powerup.movesRemaining,
        isActive: powerup.isActive,
      );
    }

    return effects;
  }
}

/// Data class for powerup visual effects
class PowerupVisualEffect {
  final PowerupType type;
  final int movesRemaining;
  final bool isActive;

  const PowerupVisualEffect({
    required this.type,
    required this.movesRemaining,
    required this.isActive,
  });

  /// Get the visual indicator color for this powerup
  int get indicatorColor {
    switch (type) {
      case PowerupType.tileFreeze:
        return 0xFF2196F3; // Blue
      case PowerupType.mergeBoost:
        return 0xFF9C27B0; // Purple
      case PowerupType.doubleMerge:
        return 0xFFFFD700; // Gold
      case PowerupType.blockerShield:
        return 0xFF4CAF50; // Green
      default:
        return 0xFFFF9800; // Orange
    }
  }

  /// Get the glow intensity based on moves remaining
  double get glowIntensity {
    if (!isActive) return 0.0;
    return (movesRemaining / 5.0).clamp(0.2, 1.0);
  }
}
