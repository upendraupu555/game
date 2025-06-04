import '../entities/scenic_background_entity.dart';
import '../repositories/scenic_background_repository.dart';
import '../../core/logging/app_logger.dart';

/// Use case for getting a random scenic background
class GetRandomScenicBackgroundUseCase {
  final ScenicBackgroundRepository _repository;

  GetRandomScenicBackgroundUseCase(this._repository);

  Future<ScenicBackgroundEntity> execute() async {
    try {
      final background = await _repository.getRandomBackground();
      AppLogger.info('Random scenic background selected: ${background.name}');
      return background;
    } catch (e) {
      AppLogger.error('Failed to get random scenic background: $e');
      rethrow;
    }
  }
}

/// Use case for getting a specific scenic background by index
class GetScenicBackgroundByIndexUseCase {
  final ScenicBackgroundRepository _repository;

  GetScenicBackgroundByIndexUseCase(this._repository);

  Future<ScenicBackgroundEntity?> execute(int index) async {
    try {
      final background = await _repository.getBackgroundByIndex(index);
      if (background != null) {
        AppLogger.info('Scenic background loaded: ${background.name}');
      } else {
        AppLogger.warning('Scenic background not found for index: $index');
      }
      return background;
    } catch (e) {
      AppLogger.error('Failed to get scenic background by index $index: $e');
      rethrow;
    }
  }
}

/// Use case for preloading scenic backgrounds
class PreloadScenicBackgroundsUseCase {
  final ScenicBackgroundRepository _repository;

  PreloadScenicBackgroundsUseCase(this._repository);

  Future<void> execute(List<int> indices) async {
    try {
      AppLogger.info('Preloading scenic backgrounds: $indices');
      await _repository.preloadBackgrounds(indices);
      AppLogger.info('Scenic backgrounds preloaded successfully');
    } catch (e) {
      AppLogger.error('Failed to preload scenic backgrounds: $e');
      rethrow;
    }
  }
}

/// Use case for getting all available scenic backgrounds
class GetAllScenicBackgroundsUseCase {
  final ScenicBackgroundRepository _repository;

  GetAllScenicBackgroundsUseCase(this._repository);

  Future<List<ScenicBackgroundEntity>> execute() async {
    try {
      final backgrounds = await _repository.getAllBackgrounds();
      AppLogger.info('Retrieved ${backgrounds.length} scenic backgrounds');
      return backgrounds;
    } catch (e) {
      AppLogger.error('Failed to get all scenic backgrounds: $e');
      rethrow;
    }
  }
}

/// Use case for saving current scenic background
class SaveCurrentScenicBackgroundUseCase {
  final ScenicBackgroundRepository _repository;

  SaveCurrentScenicBackgroundUseCase(this._repository);

  Future<void> execute(int index) async {
    try {
      await _repository.saveCurrentBackgroundIndex(index);
      AppLogger.info('Current scenic background index saved: $index');
    } catch (e) {
      AppLogger.error('Failed to save current scenic background index: $e');
      rethrow;
    }
  }
}

/// Use case for loading current scenic background
class LoadCurrentScenicBackgroundUseCase {
  final ScenicBackgroundRepository _repository;

  LoadCurrentScenicBackgroundUseCase(this._repository);

  Future<int?> execute() async {
    try {
      final index = await _repository.loadCurrentBackgroundIndex();
      if (index != null) {
        AppLogger.info('Current scenic background index loaded: $index');
      } else {
        AppLogger.info('No saved scenic background index found');
      }
      return index;
    } catch (e) {
      AppLogger.error('Failed to load current scenic background index: $e');
      rethrow;
    }
  }
}

/// Use case for managing scenic mode settings
class GetScenicModeSettingsUseCase {
  final ScenicBackgroundRepository _repository;

  GetScenicModeSettingsUseCase(this._repository);

  Future<ScenicModeSettings> execute() async {
    try {
      final settings = await _repository.getScenicModeSettings();
      AppLogger.info('Scenic mode settings loaded: $settings');
      return settings;
    } catch (e) {
      AppLogger.error('Failed to get scenic mode settings: $e');
      rethrow;
    }
  }
}

/// Use case for saving scenic mode settings
class SaveScenicModeSettingsUseCase {
  final ScenicBackgroundRepository _repository;

  SaveScenicModeSettingsUseCase(this._repository);

  Future<void> execute(ScenicModeSettings settings) async {
    try {
      await _repository.saveScenicModeSettings(settings);
      AppLogger.info('Scenic mode settings saved: $settings');
    } catch (e) {
      AppLogger.error('Failed to save scenic mode settings: $e');
      rethrow;
    }
  }
}
