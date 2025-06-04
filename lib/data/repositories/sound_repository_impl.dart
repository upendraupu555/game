import '../../domain/entities/sound_entity.dart';
import '../../domain/repositories/sound_repository.dart';
import '../datasources/sound_local_datasource.dart';
import '../models/sound_model.dart';
import '../../core/services/sound_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';

/// Implementation of sound repository
/// This is the data layer that implements the domain contract
class SoundRepositoryImpl implements SoundRepository {
  final SoundLocalDataSource _localDataSource;
  final SoundService _soundService;

  SoundRepositoryImpl(this._localDataSource, this._soundService);

  @override
  Future<SoundEntity?> loadSoundSettings() async {
    try {
      final soundModel = await _localDataSource.getSoundSettings();
      return soundModel?.toDomain();
    } catch (e) {
      AppLogger.error('Failed to load sound settings', tag: 'SoundRepository', error: e);
      return null;
    }
  }

  @override
  Future<void> saveSoundSettings(SoundEntity soundEntity) async {
    try {
      final soundModel = SoundModel.fromDomain(soundEntity);
      await _localDataSource.saveSoundSettings(soundModel);

      AppLogger.info('Sound settings saved', tag: 'SoundRepository', data: {
        'soundEnabled': soundEntity.soundEnabled,
        'masterVolume': soundEntity.masterVolume,
      });
    } catch (e) {
      AppLogger.error('Failed to save sound settings', tag: 'SoundRepository', error: e);
      throw Exception('Failed to save sound settings: $e');
    }
  }

  @override
  SoundEntity getDefaultSoundSettings() {
    return const SoundEntity(
      soundEnabled: AppConstants.defaultSoundEnabled,
      masterVolume: AppConstants.defaultMasterVolume,
      uiVolume: AppConstants.defaultUIVolume,
      gameVolume: AppConstants.defaultGameVolume,
      powerupVolume: AppConstants.defaultPowerupVolume,
      timerVolume: AppConstants.defaultTimerVolume,
    );
  }

  @override
  Future<void> clearSoundSettings() async {
    try {
      await _localDataSource.clearSoundSettings();
      AppLogger.info('Sound settings cleared', tag: 'SoundRepository');
    } catch (e) {
      AppLogger.error('Failed to clear sound settings', tag: 'SoundRepository', error: e);
      throw Exception('Failed to clear sound settings: $e');
    }
  }

  @override
  Future<void> initializeSoundSystem() async {
    try {
      await _soundService.initialize();
      AppLogger.info('Sound system initialized', tag: 'SoundRepository');
    } catch (e) {
      AppLogger.error('Failed to initialize sound system', tag: 'SoundRepository', error: e);
      throw Exception('Failed to initialize sound system: $e');
    }
  }

  @override
  Future<void> disposeSoundSystem() async {
    try {
      await _soundService.dispose();
      AppLogger.info('Sound system disposed', tag: 'SoundRepository');
    } catch (e) {
      AppLogger.error('Failed to dispose sound system', tag: 'SoundRepository', error: e);
    }
  }

  @override
  Future<void> playSound(SoundEventType soundType, {double? volumeOverride}) async {
    try {
      final volume = volumeOverride ?? 1.0;
      await _soundService.playSound(soundType, volume: volume);

      AppLogger.debug('Sound played via repository', tag: 'SoundRepository', data: {
        'soundType': soundType.name,
        'volume': volume,
      });
    } catch (e) {
      AppLogger.error('Failed to play sound: ${soundType.name} with volume override $volumeOverride', tag: 'SoundRepository', error: e);
    }
  }

  @override
  Future<void> preloadSounds() async {
    try {
      await _soundService.preloadSounds();
      AppLogger.info('Sounds preloaded via repository', tag: 'SoundRepository');
    } catch (e) {
      AppLogger.error('Failed to preload sounds', tag: 'SoundRepository', error: e);
    }
  }

  @override
  Future<void> stopAllSounds() async {
    try {
      await _soundService.stopAllSounds();
      AppLogger.debug('All sounds stopped via repository', tag: 'SoundRepository');
    } catch (e) {
      AppLogger.error('Failed to stop all sounds', tag: 'SoundRepository', error: e);
    }
  }

  @override
  bool get isInitialized => _soundService.isInitialized;

  @override
  bool get isSystemMuted => _soundService.isSystemMuted;
}
