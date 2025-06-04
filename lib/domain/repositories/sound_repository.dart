import '../entities/sound_entity.dart';

/// Abstract repository interface for sound management
/// This defines the contract for sound data operations following clean architecture
abstract class SoundRepository {
  /// Load sound settings from persistent storage
  /// Returns null if no settings are saved
  Future<SoundEntity?> loadSoundSettings();

  /// Save sound settings to persistent storage
  Future<void> saveSoundSettings(SoundEntity soundEntity);

  /// Get default sound settings
  SoundEntity getDefaultSoundSettings();

  /// Clear all sound settings (reset to defaults)
  Future<void> clearSoundSettings();

  /// Initialize the sound system
  Future<void> initializeSoundSystem();

  /// Dispose of sound system resources
  Future<void> disposeSoundSystem();

  /// Play a sound effect
  Future<void> playSound(SoundEventType soundType, {double? volumeOverride});

  /// Preload sound files for better performance
  Future<void> preloadSounds();

  /// Stop all currently playing sounds
  Future<void> stopAllSounds();

  /// Check if sound system is initialized
  bool get isInitialized;

  /// Check if sounds are currently muted (system-wide)
  bool get isSystemMuted;
}
