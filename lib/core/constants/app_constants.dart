import '../config/app_config.dart';

/// Application-wide constants following clean architecture principles
/// All static values should be defined here for better maintainability
/// Values are now configurable through AppConfig for whitelabel support
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ==================== APP INFORMATION ====================
  static const String appTitle = AppConfig.appName;
  static const String appVersion = AppConfig.appVersion;
  static const String appDescription = AppConfig.appDescription;
  static const String companyName = AppConfig.companyName;
  static const String bundleId = AppConfig.bundleId;
  static const String copyright = AppConfig.copyright;

  // ==================== THEME CONSTANTS ====================

  // Theme mode strings for persistence
  static const String themeModeLight = 'light';
  static const String themeModeDark = 'dark';
  static const String themeModeSystem = 'system';

  // Default theme mode
  static const String defaultThemeMode = themeModeSystem;

  // ==================== LOCALIZATION CONSTANTS ====================

  // Localization configuration from AppConfig (English only for now)
  static const String defaultLocale = AppConfig.defaultLanguage;
  static const List<String> supportedLocales = AppConfig.supportedLanguages;
  static const Map<String, String> languageDisplayNames = AppConfig.languageDisplayNames;

  // Localization asset paths
  static const String localizationAssetPath = 'assets/localization/';
  static const String localizationFileExtension = '.json';

  // Localization storage key
  static const String localeSettingsKey = AppConfig.localeStorageKey;

  // ==================== FONT CONSTANTS ====================

  // Font configuration from AppConfig
  static const String defaultFontFamily = AppConfig.defaultFontFamily;
  static const List<String> availableFonts = AppConfig.availableFonts;
  static const Map<String, String> fontDisplayNames = AppConfig.fontDisplayNames;

  // Font family names (for backward compatibility)
  static const String fontFamilyBubblegumSans = 'BubblegumSans';
  static const String fontFamilyChewy = 'Chewy';
  static const String fontFamilyComicNeue = 'ComicNeue';

  // Font display names (for backward compatibility)
  static const String fontNameBubblegumSans = 'Bubblegum Sans';
  static const String fontNameChewy = 'Chewy';
  static const String fontNameComicNeue = 'Comic Neue';

  // Font settings key for persistence
  static const String fontSettingsKey = AppConfig.fontStorageKey;

  // ==================== COLOR CONSTANTS ====================

  // Brand color palette - exact hex values as specified
  static const int primaryBlueValue = 0xFFD00000;    // Crimson Red
  static const int primaryTealValue = 0xFF084887;    // Ocean Blue
  static const int primaryPinkValue = 0xFFF44174;    // Rose Pink
  static const int primaryOrangeValue = 0xFFF58A07;  // Sunset Orange
  static const int primaryGrayValue = 0xFFD3D4D9;   // Silver Gray
  static const int primaryGreenValue = 0xFF0B5D1E;  // Forest Green
  static const int primaryYellowValue = 0xFFFEC601; // Golden Yellow

  // Color names for display
  static const String colorNameCrimsonRed = 'Crimson Red';
  static const String colorNameOceanBlue = 'Ocean Blue';
  static const String colorNameRosePink = 'Rose Pink';
  static const String colorNameSunsetOrange = 'Sunset Orange';
  static const String colorNameSilverGray = 'Silver Gray';
  static const String colorNameForestGreen = 'Forest Green';
  static const String colorNameGoldenYellow = 'Golden Yellow';
  static const String colorNameCustom = 'Custom Color';

  // Default colors
  static const int defaultLightPrimaryValue = primaryBlueValue;  // D00000
  static const int defaultDarkPrimaryValue = primaryTealValue;   // 084887

  // ==================== STORAGE CONSTANTS ====================

  // SharedPreferences keys from configuration
  static const String themeSettingsKey = AppConfig.themeStorageKey;
  static const String localeStorageKey = AppConfig.localeStorageKey;
  static const String userPreferencesKey = AppConfig.userPreferencesKey;

  // ==================== UI CONSTANTS ====================

  // Spacing and sizing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 64.0;

  // Button dimensions
  static const double buttonHeight = 48.0;
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;

  // ==================== ANIMATION CONSTANTS ====================

  // Duration in milliseconds
  static const int animationDurationFast = 200;
  static const int animationDurationMedium = 300;
  static const int animationDurationSlow = 500;

  // ==================== TEXT CONSTANTS ====================

  // App text content
  static const String welcomeMessage = 'Welcome to 2048!';
  static const String gameComingSoon = 'Game coming soon!';
  static const String themeSettings = 'Theme Settings';
  static const String startGame = 'Start Game';
  static const String reset = 'Reset';
  static const String loading = 'Loading...';

  // Theme related text
  static const String themeMode = 'Theme Mode';
  static const String lightThemePrimaryColor = 'Light Theme Primary Color';
  static const String darkThemePrimaryColor = 'Dark Theme Primary Color';
  static const String preview = 'Preview';
  static const String current = 'Current';
  static const String primaryButton = 'Primary Button';
  static const String outlinedButton = 'Outlined Button';
  static const String themePreviewText = 'This is how your theme colors will look in the app';
  static const String themeResetMessage = 'Theme reset to defaults';

  // Font related text
  static const String fontFamily = 'Font Family';
  static const String fontSettings = 'Font Settings';
  static const String fontPreviewText = 'This is how your selected font will look in the app';
  static const String fontResetMessage = 'Font reset to default';

  // Theme mode descriptions
  static const String lightThemeDescription = 'Always use light theme';
  static const String darkThemeDescription = 'Always use dark theme';
  static const String systemThemeDescription = 'Follow system setting';

  // Error messages
  static const String errorLoadingTheme = 'Error loading theme';
  static const String errorSavingTheme = 'Failed to save theme settings';
  static const String errorClearingTheme = 'Failed to clear theme settings';
  static const String errorResetTheme = 'Failed to reset theme settings';

  // ==================== TESTING CONSTANTS ====================

  // Test timeouts and delays
  static const int testTimeoutSeconds = 10;
  static const int testDelayMilliseconds = 100;
  static const int maxTestRetries = 10;

  // ==================== GAME CONSTANTS ====================
  // (Future game-related constants can be added here)

  static const int gameGridSize = 4;
  static const int winningTile = 2048;
  static const int initialTileCount = 2;
  static const int newTileValue = 2;

  // ==================== VALIDATION CONSTANTS ====================

  // Color validation
  static const int minColorValue = 0x00000000;
  static const int maxColorValue = 0xFFFFFFFF;

  // Alpha channel values
  static const int alphaTransparent = 0;
  static const int alphaOpaque = 255;

  // Opacity values
  static const double opacityLow = 0.1;
  static const double opacityMedium = 0.5;
  static const double opacityHigh = 0.8;
  static const double opacityFull = 1.0;
}

/// Route constants for navigation
class AppRoutes {
  AppRoutes._();

  // Main routes
  static const String home = '/';
  static const String game = '/game';
  static const String about = '/about';
  static const String help = '/help';
  static const String feedback = '/feedback';

  // Settings routes
  static const String settings = '/settings';
  static const String themeSettings = '/settings/theme';
  static const String fontSettings = '/settings/font';
  static const String languageSettings = '/settings/language';

  // Route names for analytics/logging
  static const String homeRouteName = 'home';
  static const String gameRouteName = 'game';
  static const String aboutRouteName = 'about';
  static const String helpRouteName = 'help';
  static const String feedbackRouteName = 'feedback';
  static const String settingsRouteName = 'settings';
  static const String themeSettingsRouteName = 'theme_settings';
  static const String fontSettingsRouteName = 'font_settings';
  static const String languageSettingsRouteName = 'language_settings';

  // Default route from configuration
  static const String defaultRoute = AppConfig.defaultRoute;

  // Feature-based route availability
  static bool get isGameScreenEnabled => AppConfig.isFeatureEnabled('game_screen');
  static bool get isAboutScreenEnabled => AppConfig.isFeatureEnabled('about_screen');
  static bool get isHelpScreenEnabled => AppConfig.isFeatureEnabled('help_screen');
  static bool get isFeedbackScreenEnabled => AppConfig.isFeatureEnabled('feedback_screen');
}

/// Asset paths constants
class AppAssets {
  AppAssets._();

  // Icons
  static const String iconPalette = 'palette';
  static const String iconGames = 'games';
  static const String iconLightbulb = 'lightbulb';
  static const String iconStar = 'star';
  static const String iconCheck = 'check';
  static const String iconError = 'error';
}

/// API and Network constants (for future use)
class AppNetwork {
  AppNetwork._();

  // Network configuration from AppConfig
  static const String baseApiUrl = AppConfig.baseApiUrl;
  static const int connectionTimeoutSeconds = AppConfig.connectionTimeout;
  static const int receiveTimeoutSeconds = AppConfig.receiveTimeout;
  static const int maxRetries = AppConfig.maxRetries;
  static const bool enableNetworking = AppConfig.enableNetworking;
  static const bool enableOfflineMode = AppConfig.enableOfflineMode;
}
