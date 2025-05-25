import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/localization_providers.dart';

/// Localization manager for centralized access to localized strings
/// This provides a clean interface for accessing localized content throughout the app
/// Uses asset-based localization system with Riverpod for state management
class LocalizationManager {
  // Private constructor to prevent instantiation
  LocalizationManager._();

  /// Get translation for a key using WidgetRef
  static String translate(WidgetRef ref, String key, {String? fallback}) {
    return ref.read(translationProvider(key));
  }

  /// Get translation for a key with context (for widgets that don't have WidgetRef)
  static String translateWithContext(BuildContext context, String key, {String? fallback}) {
    try {
      final container = ProviderScope.containerOf(context);
      return container.read(translationProvider(key));
    } catch (e) {
      return fallback ?? key;
    }
  }

  /// Helper method to get localized string safely
  /// Returns the key if localization is not available (useful for testing)
  static String getString(WidgetRef ref, String key, {String? fallback}) {
    try {
      return translate(ref, key, fallback: fallback);
    } catch (e) {
      // Return fallback or key for debugging
      return fallback ?? key;
    }
  }

  // Convenience methods for common strings using WidgetRef
  static String appTitle(WidgetRef ref) => translate(ref, 'app_title');
  static String appVersion(WidgetRef ref) => translate(ref, 'app_version');
  static String loading(WidgetRef ref) => translate(ref, 'loading');
  static String error(WidgetRef ref) => translate(ref, 'error');
  static String retry(WidgetRef ref) => translate(ref, 'retry');
  static String reset(WidgetRef ref) => translate(ref, 'reset');
  static String current(WidgetRef ref) => translate(ref, 'current');
  static String preview(WidgetRef ref) => translate(ref, 'preview');

  // Game content
  static String welcomeMessage(WidgetRef ref) => translate(ref, 'welcome_message');
  static String startGame(WidgetRef ref) => translate(ref, 'start_game');
  static String startApp(WidgetRef ref) => translate(ref, 'start_app');
  static String gameComingSoon(WidgetRef ref) => translate(ref, 'coming_soon');
  static String comingSoon(WidgetRef ref) => translate(ref, 'coming_soon');

  // Theme related
  static String themeSettings(WidgetRef ref) => translate(ref, 'theme_settings');
  static String themeMode(WidgetRef ref) => translate(ref, 'theme_mode');
  static String lightThemePrimaryColor(WidgetRef ref) => translate(ref, 'light_primary_color');
  static String darkThemePrimaryColor(WidgetRef ref) => translate(ref, 'dark_primary_color');
  static String themePreviewText(WidgetRef ref) => translate(ref, 'theme_preview_text');
  static String themeResetMessage(WidgetRef ref) => translate(ref, 'theme_reset_message');

  // Font related
  static String fontSettings(WidgetRef ref) => translate(ref, 'font_settings');
  static String fontFamily(WidgetRef ref) => translate(ref, 'font_family');
  static String fontFamilyLabel(WidgetRef ref) => translate(ref, 'font_family_label');
  static String fontPreviewText(WidgetRef ref) => translate(ref, 'font_preview_text');
  static String fontPreviewNumbers(WidgetRef ref) => translate(ref, 'font_preview_numbers');
  static String fontResetMessage(WidgetRef ref) => translate(ref, 'font_reset_message');

  // Button text
  static String primaryButton(WidgetRef ref) => translate(ref, 'primary_button');
  static String outlinedButton(WidgetRef ref) => translate(ref, 'outlined_button');

  // Theme mode descriptions
  static String lightThemeDescription(WidgetRef ref) => translate(ref, 'light_description');
  static String darkThemeDescription(WidgetRef ref) => translate(ref, 'dark_description');
  static String systemThemeDescription(WidgetRef ref) => translate(ref, 'system_description');

  // Color names
  static String colorNameCrimsonRed(WidgetRef ref) => translate(ref, 'color_crimson_red');
  static String colorNameOceanBlue(WidgetRef ref) => translate(ref, 'color_ocean_blue');
  static String colorNameRosePink(WidgetRef ref) => translate(ref, 'color_rose_pink');
  static String colorNameSunsetOrange(WidgetRef ref) => translate(ref, 'color_sunset_orange');
  static String colorNameSilverGray(WidgetRef ref) => translate(ref, 'color_silver_gray');
  static String colorNameForestGreen(WidgetRef ref) => translate(ref, 'color_forest_green');
  static String colorNameGoldenYellow(WidgetRef ref) => translate(ref, 'color_golden_yellow');
  static String colorNameCustom(WidgetRef ref) => translate(ref, 'color_custom');

  // Font names
  static String fontNameBubblegumSans(WidgetRef ref) => translate(ref, 'font_bubblegum_sans');
  static String fontNameChewy(WidgetRef ref) => translate(ref, 'font_chewy');
  static String fontNameComicNeue(WidgetRef ref) => translate(ref, 'font_comic_neue');

  // Error messages
  static String errorLoadingTheme(WidgetRef ref) => translate(ref, 'error_loading_theme');
  static String errorSavingTheme(WidgetRef ref) => translate(ref, 'error_saving_theme');
  static String errorClearingTheme(WidgetRef ref) => translate(ref, 'error_clearing_theme');
  static String errorResetTheme(WidgetRef ref) => translate(ref, 'error_reset_theme');
  static String errorLoadingFont(WidgetRef ref) => translate(ref, 'error_loading_font');
  static String errorSavingFont(WidgetRef ref) => translate(ref, 'error_saving_font');
  static String errorLoadingLocalization(WidgetRef ref) => translate(ref, 'error_loading_localization');
  static String errorNetwork(WidgetRef ref) => translate(ref, 'error_network');
  static String errorUnknown(WidgetRef ref) => translate(ref, 'error_unknown');

  // Navigation related
  static String navHome(WidgetRef ref) => translate(ref, 'nav_home');
  static String navGame(WidgetRef ref) => translate(ref, 'nav_game');
  static String navApp(WidgetRef ref) => translate(ref, 'nav_app');
  static String navSettings(WidgetRef ref) => translate(ref, 'nav_settings');
  static String navBack(WidgetRef ref) => translate(ref, 'nav_back');
  static String navClose(WidgetRef ref) => translate(ref, 'nav_close');
  static String navAbout(WidgetRef ref) => translate(ref, 'nav_about');
  static String navHelp(WidgetRef ref) => translate(ref, 'nav_help');
  static String navFeedback(WidgetRef ref) => translate(ref, 'nav_feedback');
  static String navGameScreen(WidgetRef ref) => translate(ref, 'nav_game_screen');
  static String navLanguageSettings(WidgetRef ref) => translate(ref, 'nav_language_settings');

  // About, Help, and Feedback content
  static String aboutTitle(WidgetRef ref) => translate(ref, 'about_title');
  static String aboutDescription(WidgetRef ref) => translate(ref, 'about_description');
  static String helpTitle(WidgetRef ref) => translate(ref, 'help_title');
  static String helpDescription(WidgetRef ref) => translate(ref, 'help_description');
  static String feedbackTitle(WidgetRef ref) => translate(ref, 'feedback_title');
  static String feedbackDescription(WidgetRef ref) => translate(ref, 'feedback_description');
  static String versionInfo(WidgetRef ref) => translate(ref, 'version_info');
  static String companyInfo(WidgetRef ref) => translate(ref, 'company_info');
  static String contactUs(WidgetRef ref) => translate(ref, 'contact_us');
  static String privacyPolicy(WidgetRef ref) => translate(ref, 'privacy_policy');
  static String termsOfService(WidgetRef ref) => translate(ref, 'terms_of_service');

  // Context-based convenience methods (for widgets without WidgetRef)
  static String appTitleWithContext(BuildContext context) => translateWithContext(context, 'app_title');
  static String loadingWithContext(BuildContext context) => translateWithContext(context, 'loading');
  static String errorWithContext(BuildContext context) => translateWithContext(context, 'error');
  static String retryWithContext(BuildContext context) => translateWithContext(context, 'retry');
}
