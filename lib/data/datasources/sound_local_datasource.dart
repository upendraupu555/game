import 'package:shared_preferences/shared_preferences.dart';
import '../models/sound_model.dart';
import '../../core/constants/app_constants.dart';

/// Abstract interface for sound local data source
abstract class SoundLocalDataSource {
  /// Get sound settings from local storage
  Future<SoundModel?> getSoundSettings();

  /// Save sound settings to local storage
  Future<void> saveSoundSettings(SoundModel soundModel);

  /// Clear sound settings from local storage
  Future<void> clearSoundSettings();

  /// Check if sound settings exist in local storage
  Future<bool> hasSoundSettings();
}

/// Implementation of sound local data source using SharedPreferences
class SoundLocalDataSourceImpl implements SoundLocalDataSource {
  final SharedPreferences _prefs;

  SoundLocalDataSourceImpl(this._prefs);

  @override
  Future<SoundModel?> getSoundSettings() async {
    try {
      final jsonString = _prefs.getString(AppConstants.soundSettingsKey);
      if (jsonString == null) {
        return null;
      }
      
      return SoundModel.fromJsonString(jsonString);
    } catch (e) {
      // If there's an error parsing the saved settings, return null
      // This will cause the app to use default settings
      return null;
    }
  }

  @override
  Future<void> saveSoundSettings(SoundModel soundModel) async {
    try {
      final jsonString = soundModel.toJsonString();
      await _prefs.setString(AppConstants.soundSettingsKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save sound settings: $e');
    }
  }

  @override
  Future<void> clearSoundSettings() async {
    try {
      await _prefs.remove(AppConstants.soundSettingsKey);
    } catch (e) {
      throw Exception('Failed to clear sound settings: $e');
    }
  }

  @override
  Future<bool> hasSoundSettings() async {
    try {
      return _prefs.containsKey(AppConstants.soundSettingsKey);
    } catch (e) {
      return false;
    }
  }
}
