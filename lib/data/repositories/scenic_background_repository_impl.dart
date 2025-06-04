import 'package:flutter/services.dart';
import '../../domain/entities/scenic_background_entity.dart';
import '../../domain/repositories/scenic_background_repository.dart';
import '../datasources/scenic_background_local_datasource.dart';
import '../models/scenic_background_model.dart';
import '../../core/logging/app_logger.dart';

/// Implementation of scenic background repository
/// This handles the coordination between data sources and domain layer
class ScenicBackgroundRepositoryImpl implements ScenicBackgroundRepository {
  final ScenicBackgroundLocalDataSource _localDataSource;
  final Set<int> _preloadedBackgrounds = <int>{};

  ScenicBackgroundRepositoryImpl(this._localDataSource);

  @override
  Future<List<ScenicBackgroundEntity>> getAllBackgrounds() async {
    try {
      final backgroundModels = await _localDataSource.getAllBackgrounds();
      final backgrounds = backgroundModels
          .map((model) => model.toDomain())
          .toList();

      AppLogger.info('Retrieved ${backgrounds.length} scenic backgrounds');
      return backgrounds;
    } catch (e) {
      AppLogger.error('Failed to get all scenic backgrounds: $e');
      rethrow;
    }
  }

  @override
  Future<ScenicBackgroundEntity> getRandomBackground() async {
    try {
      final backgroundModel = await _localDataSource.getRandomBackground();
      final background = backgroundModel.toDomain();

      AppLogger.info('Random scenic background selected: ${background.name}');
      return background;
    } catch (e) {
      AppLogger.error('Failed to get random scenic background: $e');
      rethrow;
    }
  }

  @override
  Future<ScenicBackgroundEntity?> getBackgroundByIndex(int index) async {
    try {
      final backgroundModel = await _localDataSource.getBackgroundByIndex(
        index,
      );
      if (backgroundModel == null) {
        AppLogger.warning('Scenic background not found for index: $index');
        return null;
      }

      final background = backgroundModel.toDomain();
      AppLogger.info('Scenic background loaded: ${background.name}');
      return background;
    } catch (e) {
      AppLogger.error('Failed to get scenic background by index $index: $e');
      rethrow;
    }
  }

  @override
  Future<void> preloadBackgrounds(List<int> indices) async {
    try {
      AppLogger.info('Preloading scenic backgrounds: $indices');

      for (final index in indices) {
        if (!_preloadedBackgrounds.contains(index)) {
          final background = await getBackgroundByIndex(index);
          if (background != null) {
            try {
              // Preload the image asset
              await rootBundle.load(background.assetPath);
              _preloadedBackgrounds.add(index);
              AppLogger.info('Preloaded scenic background: ${background.name}');
            } catch (e) {
              AppLogger.warning(
                'Failed to preload background ${background.name}: $e',
              );
            }
          }
        }
      }

      AppLogger.info('Scenic backgrounds preloading completed');
    } catch (e) {
      AppLogger.error('Failed to preload scenic backgrounds: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveCurrentBackgroundIndex(int index) async {
    try {
      await _localDataSource.saveCurrentBackgroundIndex(index);
      AppLogger.info('Current scenic background index saved: $index');
    } catch (e) {
      AppLogger.error('Failed to save current scenic background index: $e');
      rethrow;
    }
  }

  @override
  Future<int?> loadCurrentBackgroundIndex() async {
    try {
      final index = await _localDataSource.loadCurrentBackgroundIndex();
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

  @override
  Future<void> clearCache() async {
    try {
      await _localDataSource.clearCache();
      _preloadedBackgrounds.clear();
      AppLogger.info('Scenic background cache cleared');
    } catch (e) {
      AppLogger.error('Failed to clear scenic background cache: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isBackgroundLoaded(int index) async {
    try {
      final isLoaded = _preloadedBackgrounds.contains(index);
      AppLogger.info('Background $index loaded status: $isLoaded');
      return isLoaded;
    } catch (e) {
      AppLogger.error('Failed to check if background $index is loaded: $e');
      return false;
    }
  }

  @override
  Future<ScenicModeSettings> getScenicModeSettings() async {
    try {
      final settingsModel = await _localDataSource.getScenicModeSettings();
      final settings = settingsModel.toDomain();
      AppLogger.info('Scenic mode settings loaded: $settings');
      return settings;
    } catch (e) {
      AppLogger.error('Failed to get scenic mode settings: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveScenicModeSettings(ScenicModeSettings settings) async {
    try {
      final settingsModel = ScenicModeSettingsModel.fromDomain(settings);
      await _localDataSource.saveScenicModeSettings(settingsModel);
      AppLogger.info('Scenic mode settings saved: $settings');
    } catch (e) {
      AppLogger.error('Failed to save scenic mode settings: $e');
      rethrow;
    }
  }
}
