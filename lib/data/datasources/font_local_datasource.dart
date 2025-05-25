import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/font_model.dart';

/// Local data source for font persistence using SharedPreferences
abstract class FontLocalDataSource {
  Future<FontModel?> getFontSettings();
  Future<void> saveFontSettings(FontModel fontModel);
  Future<void> clearFontSettings();
}

class FontLocalDataSourceImpl implements FontLocalDataSource {
  final SharedPreferences _prefs;
  static const String _fontKey = AppConstants.fontSettingsKey;

  FontLocalDataSourceImpl(this._prefs);

  @override
  Future<FontModel?> getFontSettings() async {
    try {
      final fontJson = _prefs.getString(_fontKey);
      if (fontJson != null) {
        final fontMap = jsonDecode(fontJson) as Map<String, dynamic>;
        return FontModel.fromJson(fontMap);
      }
      return null;
    } catch (e) {
      // Log error in production app
      return null;
    }
  }

  @override
  Future<void> saveFontSettings(FontModel fontModel) async {
    try {
      final fontJson = jsonEncode(fontModel.toJson());
      await _prefs.setString(_fontKey, fontJson);
    } catch (e) {
      // Log error in production app
      throw Exception('Failed to save font settings: $e');
    }
  }

  @override
  Future<void> clearFontSettings() async {
    try {
      await _prefs.remove(_fontKey);
    } catch (e) {
      // Log error in production app
      throw Exception('Failed to clear font settings: $e');
    }
  }
}
