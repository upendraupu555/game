import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

/// Local data source for storing locale preferences using SharedPreferences
abstract class LocalizationLocalDataSource {
  Future<String?> getCurrentLocale();
  Future<void> saveCurrentLocale(String locale);
  Future<void> clearCurrentLocale();
}

class LocalizationLocalDataSourceImpl implements LocalizationLocalDataSource {
  final SharedPreferences _prefs;
  static const String _localeKey = AppConstants.localeSettingsKey;

  LocalizationLocalDataSourceImpl(this._prefs);

  @override
  Future<String?> getCurrentLocale() async {
    try {
      return _prefs.getString(_localeKey);
    } catch (e) {
      // Log error in production app
      return null;
    }
  }

  @override
  Future<void> saveCurrentLocale(String locale) async {
    try {
      await _prefs.setString(_localeKey, locale);
    } catch (e) {
      // Log error in production app
      throw Exception('Failed to save current locale: $e');
    }
  }

  @override
  Future<void> clearCurrentLocale() async {
    try {
      await _prefs.remove(_localeKey);
    } catch (e) {
      // Log error in production app
      throw Exception('Failed to clear current locale: $e');
    }
  }
}
