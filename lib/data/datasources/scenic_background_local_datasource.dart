import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scenic_background_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';

/// Abstract interface for scenic background local data source
abstract class ScenicBackgroundLocalDataSource {
  Future<List<ScenicBackgroundModel>> getAllBackgrounds();
  Future<ScenicBackgroundModel> getRandomBackground();
  Future<ScenicBackgroundModel?> getBackgroundByIndex(int index);
  Future<void> saveCurrentBackgroundIndex(int index);
  Future<int?> loadCurrentBackgroundIndex();
  Future<ScenicModeSettingsModel> getScenicModeSettings();
  Future<void> saveScenicModeSettings(ScenicModeSettingsModel settings);
  Future<void> clearCache();
}

/// Implementation of scenic background local data source using SharedPreferences
class ScenicBackgroundLocalDataSourceImpl implements ScenicBackgroundLocalDataSource {
  final SharedPreferences _sharedPreferences;
  final Random _random = Random();

  ScenicBackgroundLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<List<ScenicBackgroundModel>> getAllBackgrounds() async {
    try {
      final backgrounds = <ScenicBackgroundModel>[];
      
      for (int i = 1; i <= AppConstants.scenicBackgroundCount; i++) {
        final paddedIndex = i.toString().padLeft(2, '0');
        final assetPath = '${AppConstants.scenicBackgroundBasePath}'
            '${AppConstants.scenicBackgroundPrefix}$paddedIndex'
            '${AppConstants.scenicBackgroundFileExtension}';
        
        final background = ScenicBackgroundModel(
          index: i,
          assetPath: assetPath,
          name: 'Scenic Background $i',
        );
        
        backgrounds.add(background);
      }
      
      AppLogger.info('Generated ${backgrounds.length} scenic backgrounds');
      return backgrounds;
    } catch (e) {
      AppLogger.error('Failed to get all scenic backgrounds: $e');
      rethrow;
    }
  }

  @override
  Future<ScenicBackgroundModel> getRandomBackground() async {
    try {
      final randomIndex = _random.nextInt(AppConstants.scenicBackgroundCount) + 1;
      final background = await getBackgroundByIndex(randomIndex);
      
      if (background == null) {
        throw Exception('Failed to get random background at index $randomIndex');
      }
      
      AppLogger.info('Random scenic background selected: ${background.name}');
      return background;
    } catch (e) {
      AppLogger.error('Failed to get random scenic background: $e');
      rethrow;
    }
  }

  @override
  Future<ScenicBackgroundModel?> getBackgroundByIndex(int index) async {
    try {
      if (index < 1 || index > AppConstants.scenicBackgroundCount) {
        AppLogger.warning('Invalid scenic background index: $index');
        return null;
      }
      
      final paddedIndex = index.toString().padLeft(2, '0');
      final assetPath = '${AppConstants.scenicBackgroundBasePath}'
          '${AppConstants.scenicBackgroundPrefix}$paddedIndex'
          '${AppConstants.scenicBackgroundFileExtension}';
      
      final background = ScenicBackgroundModel(
        index: index,
        assetPath: assetPath,
        name: 'Scenic Background $index',
      );
      
      AppLogger.info('Scenic background retrieved: ${background.name}');
      return background;
    } catch (e) {
      AppLogger.error('Failed to get scenic background by index $index: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveCurrentBackgroundIndex(int index) async {
    try {
      await _sharedPreferences.setInt(
        AppConstants.scenicBackgroundIndexKey,
        index,
      );
      AppLogger.info('Current scenic background index saved: $index');
    } catch (e) {
      AppLogger.error('Failed to save current scenic background index: $e');
      rethrow;
    }
  }

  @override
  Future<int?> loadCurrentBackgroundIndex() async {
    try {
      final index = _sharedPreferences.getInt(
        AppConstants.scenicBackgroundIndexKey,
      );
      
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
  Future<ScenicModeSettingsModel> getScenicModeSettings() async {
    try {
      final settingsJson = _sharedPreferences.getString(
        AppConstants.scenicModeSettingsKey,
      );
      
      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        final settings = ScenicModeSettingsModel.fromJson(settingsMap);
        AppLogger.info('Scenic mode settings loaded: $settings');
        return settings;
      } else {
        // Return default settings
        const defaultSettings = ScenicModeSettingsModel();
        AppLogger.info('Using default scenic mode settings');
        return defaultSettings;
      }
    } catch (e) {
      AppLogger.error('Failed to get scenic mode settings: $e');
      // Return default settings on error
      return const ScenicModeSettingsModel();
    }
  }

  @override
  Future<void> saveScenicModeSettings(ScenicModeSettingsModel settings) async {
    try {
      final settingsJson = jsonEncode(settings.toJson());
      await _sharedPreferences.setString(
        AppConstants.scenicModeSettingsKey,
        settingsJson,
      );
      AppLogger.info('Scenic mode settings saved: $settings');
    } catch (e) {
      AppLogger.error('Failed to save scenic mode settings: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _sharedPreferences.remove(AppConstants.scenicBackgroundIndexKey);
      await _sharedPreferences.remove(AppConstants.scenicModeSettingsKey);
      AppLogger.info('Scenic background cache cleared');
    } catch (e) {
      AppLogger.error('Failed to clear scenic background cache: $e');
      rethrow;
    }
  }
}
