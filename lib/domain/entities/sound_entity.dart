/// Sound settings entity following clean architecture principles
/// This represents the core business object for sound configuration
class SoundEntity {
  final bool soundEnabled;
  final double masterVolume;
  final double uiVolume;
  final double gameVolume;
  final double powerupVolume;
  final double timerVolume;

  const SoundEntity({
    required this.soundEnabled,
    required this.masterVolume,
    required this.uiVolume,
    required this.gameVolume,
    required this.powerupVolume,
    required this.timerVolume,
  });

  /// Create a copy with updated values
  SoundEntity copyWith({
    bool? soundEnabled,
    double? masterVolume,
    double? uiVolume,
    double? gameVolume,
    double? powerupVolume,
    double? timerVolume,
  }) {
    return SoundEntity(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      masterVolume: masterVolume ?? this.masterVolume,
      uiVolume: uiVolume ?? this.uiVolume,
      gameVolume: gameVolume ?? this.gameVolume,
      powerupVolume: powerupVolume ?? this.powerupVolume,
      timerVolume: timerVolume ?? this.timerVolume,
    );
  }

  /// Calculate effective volume for UI sounds
  double get effectiveUIVolume => soundEnabled ? masterVolume * uiVolume : 0.0;

  /// Calculate effective volume for game sounds
  double get effectiveGameVolume => soundEnabled ? masterVolume * gameVolume : 0.0;

  /// Calculate effective volume for powerup sounds
  double get effectivePowerupVolume => soundEnabled ? masterVolume * powerupVolume : 0.0;

  /// Calculate effective volume for timer sounds
  double get effectiveTimerVolume => soundEnabled ? masterVolume * timerVolume : 0.0;

  /// Check if sound is effectively muted
  bool get isEffectivelyMuted => !soundEnabled || masterVolume == 0.0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SoundEntity &&
        other.soundEnabled == soundEnabled &&
        other.masterVolume == masterVolume &&
        other.uiVolume == uiVolume &&
        other.gameVolume == gameVolume &&
        other.powerupVolume == powerupVolume &&
        other.timerVolume == timerVolume;
  }

  @override
  int get hashCode {
    return Object.hash(
      soundEnabled,
      masterVolume,
      uiVolume,
      gameVolume,
      powerupVolume,
      timerVolume,
    );
  }

  @override
  String toString() {
    return 'SoundEntity('
        'soundEnabled: $soundEnabled, '
        'masterVolume: $masterVolume, '
        'uiVolume: $uiVolume, '
        'gameVolume: $gameVolume, '
        'powerupVolume: $powerupVolume, '
        'timerVolume: $timerVolume'
        ')';
  }
}

/// Sound event types for categorizing different sound effects
enum SoundEventType {
  // UI Events
  buttonTap,
  navigationTransition,
  menuOpen,
  menuClose,
  backButton,

  // Game Events
  tileMove,
  tileMerge,
  tileAppear,
  blockerCreate,
  blockerMerge,

  // Powerup Events
  powerupUnlock,
  powerupTileFreeze,
  powerupTileDestroyer,
  powerupRowClear,
  powerupColumnClear,

  // Time Attack Events
  timerTick,
  timerWarning,
  timeUp,

  // Game State Events
  gameOver,
  gameWin,
  newGame,
  pauseGame,
  resumeGame,
}

/// Extension to get volume category for each sound event type
extension SoundEventTypeExtension on SoundEventType {
  /// Get the volume category for this sound event type
  SoundVolumeCategory get volumeCategory {
    switch (this) {
      case SoundEventType.buttonTap:
      case SoundEventType.navigationTransition:
      case SoundEventType.menuOpen:
      case SoundEventType.menuClose:
      case SoundEventType.backButton:
        return SoundVolumeCategory.ui;

      case SoundEventType.tileMove:
      case SoundEventType.tileMerge:
      case SoundEventType.tileAppear:
      case SoundEventType.blockerCreate:
      case SoundEventType.blockerMerge:
      case SoundEventType.gameOver:
      case SoundEventType.gameWin:
      case SoundEventType.newGame:
      case SoundEventType.pauseGame:
      case SoundEventType.resumeGame:
        return SoundVolumeCategory.game;

      case SoundEventType.powerupUnlock:
      case SoundEventType.powerupTileFreeze:
      case SoundEventType.powerupTileDestroyer:
      case SoundEventType.powerupRowClear:
      case SoundEventType.powerupColumnClear:
        return SoundVolumeCategory.powerup;

      case SoundEventType.timerTick:
      case SoundEventType.timerWarning:
      case SoundEventType.timeUp:
        return SoundVolumeCategory.timer;
    }
  }
}

/// Volume categories for different types of sounds
enum SoundVolumeCategory {
  ui,
  game,
  powerup,
  timer,
}

/// Extension to get effective volume from sound entity
extension SoundVolumeCategoryExtension on SoundVolumeCategory {
  /// Get the effective volume for this category from sound settings
  double getEffectiveVolume(SoundEntity soundEntity) {
    switch (this) {
      case SoundVolumeCategory.ui:
        return soundEntity.effectiveUIVolume;
      case SoundVolumeCategory.game:
        return soundEntity.effectiveGameVolume;
      case SoundVolumeCategory.powerup:
        return soundEntity.effectivePowerupVolume;
      case SoundVolumeCategory.timer:
        return soundEntity.effectiveTimerVolume;
    }
  }
}
