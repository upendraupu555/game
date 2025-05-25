import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Font manager utility class for consistent font application throughout the app
/// This provides a centralized way to apply fonts with proper fallbacks
class FontManager {
  // Private constructor to prevent instantiation
  FontManager._();

  /// Get TextTheme with the specified font family
  static TextTheme getTextTheme(String fontFamily, {Brightness? brightness}) {
    final baseTheme = brightness == Brightness.dark 
        ? ThemeData.dark().textTheme 
        : ThemeData.light().textTheme;

    return baseTheme.apply(
      fontFamily: fontFamily,
      fontFamilyFallback: _getFontFallbacks(fontFamily),
    );
  }

  /// Get font fallbacks for better cross-platform support
  static List<String> _getFontFallbacks(String fontFamily) {
    switch (fontFamily) {
      case AppConstants.fontFamilyBubblegumSans:
        return ['BubblegumSans', 'Comic Sans MS', 'cursive'];
      case AppConstants.fontFamilyChewy:
        return ['Chewy', 'Comic Sans MS', 'cursive'];
      case AppConstants.fontFamilyComicNeue:
        return ['ComicNeue', 'Comic Sans MS', 'cursive'];
      default:
        return ['BubblegumSans', 'Comic Sans MS', 'cursive'];
    }
  }

  /// Create a TextStyle with the specified font family
  static TextStyle createTextStyle({
    required String fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: _getFontFallbacks(fontFamily),
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  /// Get display name for a font family
  static String getFontDisplayName(String fontFamily) {
    switch (fontFamily) {
      case AppConstants.fontFamilyBubblegumSans:
        return AppConstants.fontNameBubblegumSans;
      case AppConstants.fontFamilyChewy:
        return AppConstants.fontNameChewy;
      case AppConstants.fontFamilyComicNeue:
        return AppConstants.fontNameComicNeue;
      default:
        return AppConstants.fontNameBubblegumSans;
    }
  }

  /// Check if a font family is available
  static bool isFontAvailable(String fontFamily) {
    const availableFonts = [
      AppConstants.fontFamilyBubblegumSans,
      AppConstants.fontFamilyChewy,
      AppConstants.fontFamilyComicNeue,
    ];
    return availableFonts.contains(fontFamily);
  }

  /// Get all available font families
  static List<String> getAvailableFontFamilies() {
    return const [
      AppConstants.fontFamilyBubblegumSans,
      AppConstants.fontFamilyChewy,
      AppConstants.fontFamilyComicNeue,
    ];
  }

  /// Apply font to existing TextTheme
  static TextTheme applyFontToTextTheme(TextTheme textTheme, String fontFamily) {
    return textTheme.apply(
      fontFamily: fontFamily,
      fontFamilyFallback: _getFontFallbacks(fontFamily),
    );
  }

  /// Create headline text style with font
  static TextStyle headlineStyle(String fontFamily, {Color? color}) {
    return createTextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  /// Create body text style with font
  static TextStyle bodyStyle(String fontFamily, {Color? color}) {
    return createTextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }

  /// Create button text style with font
  static TextStyle buttonStyle(String fontFamily, {Color? color}) {
    return createTextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.5,
    );
  }

  /// Create caption text style with font
  static TextStyle captionStyle(String fontFamily, {Color? color}) {
    return createTextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }
}
