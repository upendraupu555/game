import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../models/localization_model.dart';

/// Asset data source for loading localization files from assets
abstract class LocalizationAssetDataSource {
  Future<LocalizationModel> loadLocalization(String locale);
  Future<List<String>> getAvailableLocales();
  Future<bool> isLocaleSupported(String locale);
}

class LocalizationAssetDataSourceImpl implements LocalizationAssetDataSource {
  @override
  Future<LocalizationModel> loadLocalization(String locale) async {
    try {
      final assetPath = '${AppConstants.localizationAssetPath}$locale${AppConstants.localizationFileExtension}';
      final jsonString = await rootBundle.loadString(assetPath);
      return LocalizationModel.fromJson(jsonString);
    } catch (e) {
      // If the requested locale fails to load, try to load default locale
      if (locale != AppConstants.defaultLocale) {
        try {
          final defaultAssetPath = '${AppConstants.localizationAssetPath}${AppConstants.defaultLocale}${AppConstants.localizationFileExtension}';
          final jsonString = await rootBundle.loadString(defaultAssetPath);
          return LocalizationModel.fromJson(jsonString);
        } catch (defaultError) {
          // If even default locale fails, return hardcoded fallback
          return LocalizationModel.defaultEnglish();
        }
      } else {
        // If default locale fails, return hardcoded fallback
        return LocalizationModel.defaultEnglish();
      }
    }
  }

  @override
  Future<List<String>> getAvailableLocales() async {
    final availableLocales = <String>[];
    
    // Check each supported locale to see if it exists
    for (final locale in AppConstants.supportedLocales) {
      if (await isLocaleSupported(locale)) {
        availableLocales.add(locale);
      }
    }
    
    // Ensure default locale is always available
    if (!availableLocales.contains(AppConstants.defaultLocale)) {
      availableLocales.add(AppConstants.defaultLocale);
    }
    
    return availableLocales;
  }

  @override
  Future<bool> isLocaleSupported(String locale) async {
    try {
      final assetPath = '${AppConstants.localizationAssetPath}$locale${AppConstants.localizationFileExtension}';
      await rootBundle.loadString(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }
}
