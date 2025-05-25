import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';

/// Application color constants following clean architecture principles
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Brand color palette - using values from constants
  static const Color primaryBlue = Color(AppConstants.primaryBlueValue);
  static const Color primaryTeal = Color(AppConstants.primaryTealValue);
  static const Color primaryPink = Color(AppConstants.primaryPinkValue);
  static const Color primaryOrange = Color(AppConstants.primaryOrangeValue);
  static const Color primaryGray = Color(AppConstants.primaryGrayValue);
  static const Color primaryGreen = Color(AppConstants.primaryGreenValue);
  static const Color primaryYellow = Color(AppConstants.primaryYellowValue);

  // Default theme colors
  static const Color defaultLightPrimary = Color(AppConstants.defaultLightPrimaryValue);
  static const Color defaultDarkPrimary = Color(AppConstants.defaultDarkPrimaryValue);

  // Complete primary color options for user selection
  static const List<Color> primaryColorOptions = [
    primaryBlue,    // D00000
    primaryTeal,    // 084887
    primaryPink,    // F44174
    primaryOrange,  // F58A07
    primaryGray,    // D3D4D9
    primaryGreen,   // 0B5D1E
    primaryYellow,  // FEC601
  ];

  /// Get display name for a color
  static String getColorName(Color color, [BuildContext? context]) {
    if (context != null) {
      // Use localized names when context is available
      if (color == primaryBlue) return LocalizationManager.translateWithContext(context, 'color_crimson_red');
      if (color == primaryTeal) return LocalizationManager.translateWithContext(context, 'color_ocean_blue');
      if (color == primaryPink) return LocalizationManager.translateWithContext(context, 'color_rose_pink');
      if (color == primaryOrange) return LocalizationManager.translateWithContext(context, 'color_sunset_orange');
      if (color == primaryGray) return LocalizationManager.translateWithContext(context, 'color_silver_gray');
      if (color == primaryGreen) return LocalizationManager.translateWithContext(context, 'color_forest_green');
      if (color == primaryYellow) return LocalizationManager.translateWithContext(context, 'color_golden_yellow');
      return LocalizationManager.translateWithContext(context, 'color_custom');
    } else {
      // Fallback to constants when context is not available
      if (color == primaryBlue) return AppConstants.colorNameCrimsonRed;
      if (color == primaryTeal) return AppConstants.colorNameOceanBlue;
      if (color == primaryPink) return AppConstants.colorNameRosePink;
      if (color == primaryOrange) return AppConstants.colorNameSunsetOrange;
      if (color == primaryGray) return AppConstants.colorNameSilverGray;
      if (color == primaryGreen) return AppConstants.colorNameForestGreen;
      if (color == primaryYellow) return AppConstants.colorNameGoldenYellow;
      return AppConstants.colorNameCustom;
    }
  }

  /// Check if a color is part of the brand palette
  static bool isBrandColor(Color color) {
    return primaryColorOptions.contains(color);
  }

  /// Get color by hex value (for serialization/deserialization)
  static Color getColorByHex(int hexValue) {
    // Check against known color values from constants
    if (hexValue == AppConstants.primaryBlueValue) return primaryBlue;
    if (hexValue == AppConstants.primaryTealValue) return primaryTeal;
    if (hexValue == AppConstants.primaryPinkValue) return primaryPink;
    if (hexValue == AppConstants.primaryOrangeValue) return primaryOrange;
    if (hexValue == AppConstants.primaryGrayValue) return primaryGray;
    if (hexValue == AppConstants.primaryGreenValue) return primaryGreen;
    if (hexValue == AppConstants.primaryYellowValue) return primaryYellow;

    // Return custom color if not in palette
    return Color(hexValue);
  }
}
