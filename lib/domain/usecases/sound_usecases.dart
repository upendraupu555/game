import '../entities/sound_entity.dart';
import '../repositories/sound_repository.dart';
import '../../core/constants/app_constants.dart';

/// Use case for getting current sound settings
class GetSoundSettingsUseCase {
  final SoundRepository _repository;

  GetSoundSettingsUseCase(this._repository);

  Future<SoundEntity> execute() async {
    final savedSound = await _repository.loadSoundSettings();
    return savedSound ?? _repository.getDefaultSoundSettings();
  }
}

/// Use case for updating sound settings
class UpdateSoundSettingsUseCase {
  final SoundRepository _repository;

  UpdateSoundSettingsUseCase(this._repository);

  Future<SoundEntity> execute(SoundEntity newSoundSettings) async {
    // Validate volume ranges
    final validatedSettings = _validateSoundSettings(newSoundSettings);
    
    await _repository.saveSoundSettings(validatedSettings);
    return validatedSettings;
  }

  SoundEntity _validateSoundSettings(SoundEntity settings) {
    return settings.copyWith(
      masterVolume: _clampVolume(settings.masterVolume),
      uiVolume: _clampVolume(settings.uiVolume),
      gameVolume: _clampVolume(settings.gameVolume),
      powerupVolume: _clampVolume(settings.powerupVolume),
      timerVolume: _clampVolume(settings.timerVolume),
    );
  }

  double _clampVolume(double volume) {
    return volume.clamp(AppConstants.minVolume, AppConstants.maxVolume);
  }
}

/// Use case for toggling sound on/off
class ToggleSoundUseCase {
  final SoundRepository _repository;

  ToggleSoundUseCase(this._repository);

  Future<SoundEntity> execute(SoundEntity currentSettings) async {
    final newSettings = currentSettings.copyWith(
      soundEnabled: !currentSettings.soundEnabled,
    );
    
    await _repository.saveSoundSettings(newSettings);
    return newSettings;
  }
}

/// Use case for updating master volume
class UpdateMasterVolumeUseCase {
  final SoundRepository _repository;

  UpdateMasterVolumeUseCase(this._repository);

  Future<SoundEntity> execute(SoundEntity currentSettings, double newVolume) async {
    final clampedVolume = newVolume.clamp(AppConstants.minVolume, AppConstants.maxVolume);
    
    final newSettings = currentSettings.copyWith(
      masterVolume: clampedVolume,
    );
    
    await _repository.saveSoundSettings(newSettings);
    return newSettings;
  }
}

/// Use case for updating category-specific volume
class UpdateCategoryVolumeUseCase {
  final SoundRepository _repository;

  UpdateCategoryVolumeUseCase(this._repository);

  Future<SoundEntity> execute(
    SoundEntity currentSettings, 
    SoundVolumeCategory category, 
    double newVolume,
  ) async {
    final clampedVolume = newVolume.clamp(AppConstants.minVolume, AppConstants.maxVolume);
    
    SoundEntity newSettings;
    switch (category) {
      case SoundVolumeCategory.ui:
        newSettings = currentSettings.copyWith(uiVolume: clampedVolume);
        break;
      case SoundVolumeCategory.game:
        newSettings = currentSettings.copyWith(gameVolume: clampedVolume);
        break;
      case SoundVolumeCategory.powerup:
        newSettings = currentSettings.copyWith(powerupVolume: clampedVolume);
        break;
      case SoundVolumeCategory.timer:
        newSettings = currentSettings.copyWith(timerVolume: clampedVolume);
        break;
    }
    
    await _repository.saveSoundSettings(newSettings);
    return newSettings;
  }
}

/// Use case for playing sound effects
class PlaySoundUseCase {
  final SoundRepository _repository;

  PlaySoundUseCase(this._repository);

  Future<void> execute(
    SoundEventType soundType, 
    SoundEntity soundSettings, {
    double? volumeOverride,
  }) async {
    // Don't play if sound is disabled
    if (!soundSettings.soundEnabled) return;
    
    // Don't play if master volume is 0
    if (soundSettings.masterVolume == 0.0) return;
    
    // Calculate effective volume
    final categoryVolume = soundType.volumeCategory.getEffectiveVolume(soundSettings);
    final finalVolume = volumeOverride ?? categoryVolume;
    
    // Don't play if final volume is 0
    if (finalVolume == 0.0) return;
    
    await _repository.playSound(soundType, volumeOverride: finalVolume);
  }
}

/// Use case for initializing the sound system
class InitializeSoundSystemUseCase {
  final SoundRepository _repository;

  InitializeSoundSystemUseCase(this._repository);

  Future<void> execute() async {
    await _repository.initializeSoundSystem();
    
    if (AppConstants.preloadSounds) {
      await _repository.preloadSounds();
    }
  }
}

/// Use case for resetting sound settings to defaults
class ResetSoundSettingsUseCase {
  final SoundRepository _repository;

  ResetSoundSettingsUseCase(this._repository);

  Future<SoundEntity> execute() async {
    await _repository.clearSoundSettings();
    return _repository.getDefaultSoundSettings();
  }
}
