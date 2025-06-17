/// Whitelabel application configuration
/// This file contains all configurable values that can be customized for different apps
class AppConfig {
  AppConfig._();

  // ==================== APP IDENTITY ====================

  /// App name displayed throughout the application
  static const String appName = 'Ultra 2048';

  /// App version
  static const String appVersion = '1.0.0';

  /// App description for stores and about pages
  static const String appDescription =
      'A beautiful Ultra 2048 puzzle game built with Flutter and clean architecture';

  /// Company/Developer name
  static const String companyName = 'Game Studio';

  /// App bundle identifier (should be unique)
  static const String bundleId = 'com.ultra2048';

  /// Copyright notice
  static const String copyright =
      'Copyright © 2025 Devisetti Upendra. All rights reserved.';

  // ==================== BRANDING ====================

  /// Primary brand colors (hex values without 0xFF prefix)
  static const int primaryLightColor = 0xD00000; // Crimson Red
  static const int primaryDarkColor = 0x084887; // Ocean Blue

  /// Secondary brand colors
  static const int secondaryLightColor = 0xF44174; // Rose Pink
  static const int secondaryDarkColor = 0x0B5D1E; // Forest Green

  /// Accent colors
  static const int accentColor = 0xF58A07; // Sunset Orange
  static const int warningColor = 0xFEC601; // Golden Yellow
  static const int errorColor = 0xD00000; // Crimson Red
  static const int successColor = 0x0B5D1E; // Forest Green

  /// Available theme colors for user selection
  static const List<int> availableColors = [
    0xD00000, // Crimson Red
    0x084887, // Ocean Blue
    0xF44174, // Rose Pink
    0xF58A07, // Sunset Orange
    0xD3D4D9, // Silver Gray
    0x0B5D1E, // Forest Green
    0xFEC601, // Golden Yellow
  ];

  // ==================== TYPOGRAPHY ====================

  /// Default font family
  static const String defaultFontFamily = 'BubblegumSans';

  /// Available fonts for user selection
  static const List<String> availableFonts = [
    'BubblegumSans',
    'Chewy',
    'ComicNeue',
  ];

  /// Font display names
  static const Map<String, String> fontDisplayNames = {
    'BubblegumSans': 'Bubblegum Sans',
    'Chewy': 'Chewy',
    'ComicNeue': 'Comic Neue',
  };

  // ==================== LOCALIZATION ====================

  /// Default language
  static const String defaultLanguage = 'en';

  /// Supported languages - comprehensive multi-language support
  static const List<String> supportedLanguages = [
    'en', // English
    'te', // Telugu
    'hi', // Hindi
    'zh', // Chinese Simplified
    'ja', // Japanese
    'ko', // Korean
    'es', // Spanish
    'fr', // French
    'ar', // Arabic
  ];

  /// Language display names
  static const Map<String, String> languageDisplayNames = {
    'en': 'English',
    'te': 'తెలుగు', // Telugu
    'hi': 'हिन्दी', // Hindi
    'zh': '简体中文', // Chinese Simplified
    'ja': '日本語', // Japanese
    'ko': '한국어', // Korean
    'es': 'Español', // Spanish
    'fr': 'Français', // French
    'ar': 'العربية', // Arabic
  };

  // ==================== FEATURES ====================

  /// Enable/disable specific features
  static const bool enableThemeCustomization = true;
  static const bool enableFontCustomization = true;
  static const bool enableLanguageSelection =
      true; // Enabled - Multi-language support
  static const bool enableDarkMode = true;
  static const bool enableSystemTheme = true;

  /// Feature-specific settings
  static const bool allowCustomColors =
      false; // Set to true to allow color picker
  static const bool showAdvancedSettings = false;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;

  // ==================== CONTENT ====================

  /// Welcome message key (will be localized)
  static const String welcomeMessageKey = 'welcome_message';

  /// Main action button text key
  static const String mainActionKey = 'start_game';

  /// App icon (Material Icons)
  static const String appIcon = 'games'; // Game-specific icon

  /// Home screen icon
  static const String homeIcon = 'home';

  /// Settings icon
  static const String settingsIcon = 'settings';

  // ==================== NAVIGATION ====================

  /// Enable/disable specific screens
  static const bool enableGameScreen = true; // Enable 2048 game screen
  static const bool enableAboutScreen = true;
  static const bool enableHelpScreen = true;
  static const bool enableFeedbackScreen = true;

  /// Default route
  static const String defaultRoute = '/';

  // ==================== STORAGE ====================

  /// SharedPreferences keys (should be unique per app)
  static const String themeStorageKey = '${bundleId}_theme_settings';
  static const String fontStorageKey = '${bundleId}_font_settings';
  static const String localeStorageKey = '${bundleId}_locale_settings';
  static const String userPreferencesKey = '${bundleId}_user_preferences';

  // ==================== NETWORK ====================

  /// API configuration (if needed)
  static const String baseApiUrl = 'https://api.yourcompany.com';
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  static const int maxRetries = 3;

  /// Enable/disable network features
  static const bool enableNetworking = false;
  static const bool enableOfflineMode = true;

  // ==================== VALIDATION ====================

  /// Validation rules
  static const int minAppNameLength = 1;
  static const int maxAppNameLength = 50;
  static const int minVersionLength = 5; // e.g., "1.0.0"

  /// Color validation
  static const int minColorValue = 0x00000000;
  static const int maxColorValue = 0xFFFFFFFF;

  // ==================== DEVELOPMENT ====================

  /// Debug settings
  static const bool enableDebugMode = true;
  static const bool enableLogging = true;
  static const bool enablePerformanceMonitoring = false;

  /// Test settings
  static const int testTimeoutSeconds = 10;
  static const int testDelayMilliseconds = 100;

  // ==================== HELPER METHODS ====================

  /// Get app display name
  static String get displayName => appName;

  /// Get full app version
  static String get fullVersion => '$appName v$appVersion';

  /// Get about text
  static String get aboutText => '$appDescription\n\n$copyright';

  /// Check if feature is enabled
  static bool isFeatureEnabled(String feature) {
    switch (feature) {
      case 'theme_customization':
        return enableThemeCustomization;
      case 'font_customization':
        return enableFontCustomization;
      case 'language_selection':
        return enableLanguageSelection;
      case 'dark_mode':
        return enableDarkMode;
      case 'system_theme':
        return enableSystemTheme;
      case 'custom_colors':
        return allowCustomColors;
      case 'advanced_settings':
        return showAdvancedSettings;
      case 'analytics':
        return enableAnalytics;
      case 'crash_reporting':
        return enableCrashReporting;
      case 'game_screen':
        return enableGameScreen;
      case 'about_screen':
        return enableAboutScreen;
      case 'help_screen':
        return enableHelpScreen;
      case 'feedback_screen':
        return enableFeedbackScreen;
      case 'networking':
        return enableNetworking;
      case 'offline_mode':
        return enableOfflineMode;
      default:
        return false;
    }
  }

  /// Get color by name
  static int? getColorByName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'primary_light':
        return primaryLightColor;
      case 'primary_dark':
        return primaryDarkColor;
      case 'secondary_light':
        return secondaryLightColor;
      case 'secondary_dark':
        return secondaryDarkColor;
      case 'accent':
        return accentColor;
      case 'warning':
        return warningColor;
      case 'error':
        return errorColor;
      case 'success':
        return successColor;
      default:
        return null;
    }
  }

  /// Validate configuration
  static bool validateConfig() {
    // Validate app name
    if (appName.length < minAppNameLength ||
        appName.length > maxAppNameLength) {
      return false;
    }

    // Validate version
    if (appVersion.length < minVersionLength) {
      return false;
    }

    // Validate colors
    for (final color in availableColors) {
      if (color < minColorValue || color > maxColorValue) {
        return false;
      }
    }

    // Validate fonts
    if (availableFonts.isEmpty || !availableFonts.contains(defaultFontFamily)) {
      return false;
    }

    // Validate languages
    if (supportedLanguages.isEmpty ||
        !supportedLanguages.contains(defaultLanguage)) {
      return false;
    }

    return true;
  }
}
