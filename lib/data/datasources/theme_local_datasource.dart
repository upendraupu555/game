import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/theme_model.dart';

/// Local data source for theme persistence using SharedPreferences
abstract class ThemeLocalDataSource {
  Future<ThemeModel?> getThemeSettings();
  Future<void> saveThemeSettings(ThemeModel themeModel);
  Future<void> clearThemeSettings();
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  final SharedPreferences _prefs;
  static const String _themeKey = AppConstants.themeSettingsKey;

  ThemeLocalDataSourceImpl(this._prefs);

  @override
  Future<ThemeModel?> getThemeSettings() async {
    try {
      final themeJson = _prefs.getString(_themeKey);
      if (themeJson != null) {
        final themeMap = jsonDecode(themeJson) as Map<String, dynamic>;
        return ThemeModel.fromJson(themeMap);
      }
      return null;
    } catch (e) {
      // Log error in production app
      return null;
    }
  }

  @override
  Future<void> saveThemeSettings(ThemeModel themeModel) async {
    try {
      final themeJson = jsonEncode(themeModel.toJson());
      await _prefs.setString(_themeKey, themeJson);
    } catch (e) {
      // Log error in production app
      throw Exception('Failed to save theme settings: $e');
    }
  }

  @override
  Future<void> clearThemeSettings() async {
    try {
      await _prefs.remove(_themeKey);
    } catch (e) {
      // Log error in production app
      throw Exception('Failed to clear theme settings: $e');
    }
  }
}
