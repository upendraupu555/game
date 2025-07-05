import 'dart:io';

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
  static const Map<String, String> languageDisplayNames =
      AppConfig.languageDisplayNames;

  // Localization asset paths
  static const String localizationAssetPath = 'assets/localization/';
  static const String localizationFileExtension = '.json';

  // Localization storage key
  static const String localeSettingsKey = AppConfig.localeStorageKey;

  // ==================== FONT CONSTANTS ====================

  // Font configuration from AppConfig
  static const String defaultFontFamily = AppConfig.defaultFontFamily;
  static const List<String> availableFonts = AppConfig.availableFonts;
  static const Map<String, String> fontDisplayNames =
      AppConfig.fontDisplayNames;

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
  static const int primaryBlueValue = 0xFFD00000; // Crimson Red
  static const int primaryTealValue = 0xFF084887; // Ocean Blue
  static const int primaryPinkValue = 0xFFF44174; // Rose Pink
  static const int primaryOrangeValue = 0xFFF58A07; // Sunset Orange
  static const int primaryGrayValue = 0xFFD3D4D9; // Silver Gray
  static const int primaryGreenValue = 0xFF0B5D1E; // Forest Green
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
  static const int defaultLightPrimaryValue = primaryBlueValue; // D00000
  static const int defaultDarkPrimaryValue = primaryTealValue; // 084887

  // ==================== STORAGE CONSTANTS ====================

  // SharedPreferences keys from configuration
  static const String themeSettingsKey = AppConfig.themeStorageKey;
  static const String localeStorageKey = AppConfig.localeStorageKey;
  static const String userPreferencesKey = AppConfig.userPreferencesKey;

  // User system storage keys
  static const String userDataKey = '${AppConfig.bundleId}_user_data';
  static const String userStatisticsKey =
      '${AppConfig.bundleId}_user_statistics';
  static const String currentUserIdKey =
      '${AppConfig.bundleId}_current_user_id';

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
  static const double borderRadiusExtraLarge = 24.0;

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

  // Optimized animation durations for 60fps performance
  static const int animationDurationFast = 150; // Reduced for snappier feel
  static const int animationDurationMedium =
      250; // Optimized for smooth movement
  static const int animationDurationSlow = 400; // Reduced to prevent lag

  // Performance optimization constants - optimized for 60fps
  static const int maxConcurrentAnimations =
      15; // Reduced for better performance
  static const bool enableAnimationOptimizations = true;
  static const bool enablePerformanceLogging = false; // Disable in production

  // Animation performance settings
  static const Duration tileAnimationDuration = Duration(milliseconds: 150);
  static const Duration mergeAnimationDuration = Duration(milliseconds: 200);
  static const int maxAnimationFrameRate = 60;

  // Memory management settings
  static const int maxCacheSize = 100; // Maximum cached position calculations
  static const Duration cacheCleanupInterval = Duration(minutes: 5);

  // UI performance settings
  static const bool useRepaintBoundaries = true;
  static const bool optimizeRebuilds = true;

  // ==================== TEXT CONSTANTS ====================

  // App text content
  static const String welcomeMessage = 'Welcome to Ultra 2048!';
  static const String gameComingSoon = 'Game coming soon!';
  static const String themeSettings = 'Theme Settings';
  static const String startGame = 'Start Game';
  static const String reset = 'Reset';
  static const String loading = 'Loading...';

  // Score formatting utility
  static String formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score > 10000) {
      return '${(score / 1000).toStringAsFixed(1)}k';
    } else {
      return score.toString();
    }
  }

  // Theme related text
  static const String themeMode = 'Theme Mode';
  static const String lightThemePrimaryColor = 'Light Theme Primary Color';
  static const String darkThemePrimaryColor = 'Dark Theme Primary Color';
  static const String preview = 'Preview';
  static const String current = 'Current';
  static const String primaryButton = 'Primary Button';
  static const String outlinedButton = 'Outlined Button';
  static const String themePreviewText =
      'This is how your theme colors will look in the app';
  static const String themeResetMessage = 'Theme reset to defaults';

  // Font related text
  static const String fontFamily = 'Font Family';
  static const String fontSettings = 'Font Settings';
  static const String fontPreviewText =
      'This is how your selected font will look in the app';
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
  static const String errorLoadingFont = 'Error loading font';
  static const String errorSavingFont = 'Failed to save font settings';
  static const String errorLoadingLocalization = 'Failed to load localization';
  static const String errorNetwork = 'Network connection error';
  static const String errorUnknown = 'Unknown error occurred';

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

  // ==================== SCENIC MODE CONSTANTS ====================

  // Scenic mode configuration
  static const bool scenicModeEnabled = true;
  static const int scenicBackgroundCount = 19; // bg_01.JPG to bg_19.JPG
  static const String scenicBackgroundBasePath = 'assets/images/scenes/';
  static const String scenicBackgroundFileExtension = '.JPG';
  static const String scenicBackgroundPrefix = 'bg_';

  // Scenic background display settings - optimized for maximum visibility
  static const double scenicBackgroundOpacity =
      1.0; // Full opacity for maximum impact
  static const double scenicBackgroundBlur =
      0.0; // No blur for crisp scenic images
  static const bool scenicBackgroundCacheEnabled = true;
  static const Duration scenicBackgroundCacheDuration = Duration(hours: 2);

  // Scenic mode overlay settings for readability (using int values for colors)
  static const double scenicOverlayOpacity =
      0.02; // Minimal overlay for maximum scenic visibility
  static const double scenicOverlayOpacityRegular =
      0.4; // Regular overlay for non-scenic modes
  static const int scenicOverlayColorLightValue =
      0x0A000000; // Very light overlay for dark themes
  static const int scenicOverlayColorDarkValue =
      0x0A000000; // Very light overlay for light themes

  // App bar transparency settings for scenic mode
  static const double scenicAppBarOpacity =
      0.1; // Highly transparent app bar in scenic mode
  static const double scenicAppBarBlur =
      8.0; // Blur effect for app bar background
  static const int scenicAppBarColorValue =
      0x1A000000; // Semi-transparent black for app bar

  // Game board scenic mode settings
  static const double scenicGameBoardOpacity =
      0.15; // Semi-transparent game board
  static const double scenicGameBoardBlur = 6.0; // Blur effect for game board
  static const int scenicGameBoardColorValue =
      0x1A000000; // Semi-transparent background

  // Powerup scenic mode settings
  static const double scenicPowerupTrayOpacity =
      0.2; // Semi-transparent powerup tray
  static const double scenicPowerupNotificationOpacity =
      0.25; // Powerup notifications
  static const double scenicPowerupSelectionOpacity =
      0.3; // Powerup selection overlay
  static const double scenicPowerupBlur =
      8.0; // Blur effect for powerup elements

  // Tile scenic mode settings
  static const double scenicTileOpacity = 0.9; // Slightly transparent tiles
  static const double scenicTileShadowOpacity = 0.8; // Enhanced tile shadows
  static const double scenicTileShadowBlur = 6.0; // Tile shadow blur radius

  // Dialog and overlay scenic mode settings
  static const double scenicDialogOpacity = 0.25; // Semi-transparent dialogs
  static const double scenicOverlayBlur = 12.0; // Blur effect for overlays
  static const int scenicDialogColorValue =
      0x40000000; // Dialog background color

  // Scenic mode storage keys
  static const String scenicModeSettingsKey =
      '${AppConfig.bundleId}_scenic_mode_settings';
  static const String scenicBackgroundIndexKey =
      '${AppConfig.bundleId}_scenic_background_index';
  static const String scenicModeEnabledKey =
      '${AppConfig.bundleId}_scenic_mode_enabled';

  // ==================== USER SYSTEM CONSTANTS ====================

  // Default user settings
  static const String defaultUsername = 'guest';
  static const int gameIdLength = 16;
  static const String guestUserPrefix = 'guest_';

  // User authentication states
  static const String userStateGuest = 'guest';
  static const String userStateAuthenticated = 'authenticated';

  // ==================== SUPABASE CONSTANTS ====================

  // Supabase configuration
  static const String supabaseUrl = 'https://lzspoqxsxqthugrsrzfb.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx6c3BvcXhzeHF0aHVncnNyemZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg3OTAzMTksImV4cCI6MjA2NDM2NjMxOX0.8OlOED2MwM_kAI_NZ9xLCUegwg_Av5_jPmcoW37N2pM';

  // Supabase table names
  static const String usersTable = 'users';
  static const String userStatisticsTable = 'user_statistics';
  static const String userPurchasesTable = 'user_purchases';

  // Supabase column names for user_purchases table
  static const String purchaseIdColumn = 'id';
  static const String purchaseUserIdColumn = 'user_id';
  static const String purchaseProductTypeColumn = 'product_type';
  static const String purchaseStatusColumn = 'status';
  static const String purchaseTransactionIdColumn = 'transaction_id';
  static const String purchaseAmountColumn = 'amount';
  static const String purchaseCurrencyColumn = 'currency';
  static const String purchasePurchasedAtColumn = 'purchased_at';
  static const String purchaseCreatedAtColumn = 'created_at';
  static const String purchaseUpdatedAtColumn = 'updated_at';
  static const String purchaseMetadataColumn = 'metadata';

  // Purchase product types
  static const String adRemovalProductType = 'ad_removal';

  // Purchase statuses
  static const String purchaseStatusCompleted = 'completed';
  static const String purchaseStatusPending = 'pending';
  static const String purchaseStatusFailed = 'failed';
  static const String purchaseStatusRefunded = 'refunded';

  // ==================== FEATURE FLAGS ====================

  // TODO: Temporary feature flags for disabling sound and font customization
  // Set these to true to re-enable the features
  static const bool enableSoundSystem = false; // Temporarily disabled
  static const bool enableFontCustomization = false; // Temporarily disabled

  // ==================== SOUND CONSTANTS ====================

  // Sound settings storage key
  static const String soundSettingsKey = '${AppConfig.bundleId}_sound_settings';

  // Default sound settings
  static const bool defaultSoundEnabled = true;
  static const double defaultMasterVolume = 0.7;
  static const double defaultUIVolume = 0.8;
  static const double defaultGameVolume = 0.9;
  static const double defaultPowerupVolume = 1.0;
  static const double defaultTimerVolume = 0.6;

  // Volume ranges
  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;
  static const double volumeStep = 0.1;

  // Sound file paths
  static const String soundAssetPath = 'assets/sounds/';
  static const String soundFileExtension = '.mp3';

  // Preload settings
  static const bool preloadSounds = true;
  static const int maxConcurrentSounds = 5;
  static const Duration soundCacheTimeout = Duration(minutes: 10);

  // ==================== POWERUP CONSTANTS ====================

  // Powerup acquisition thresholds
  static const int powerupTileFreezeScoreThreshold = 1000;
  static const int powerupUndoMoveScoreThreshold = 2500;
  static const int powerupShuffleBoardScoreThreshold = 5000;
  static const int powerupTileDestroyerScoreThreshold = 7500;
  static const int powerupValueUpgradeScoreThreshold = 10000;
  static const int powerupRowClearScoreThreshold = 12000;
  static const int powerupColumnClearScoreThreshold = 15000;

  // Legacy threshold (kept for backward compatibility)
  @Deprecated(
    'Use powerupRowClearScoreThreshold or powerupColumnClearScoreThreshold instead',
  )
  static const int powerupRowColumnClearScoreThreshold = 15000;

  // Powerup durations (in moves)
  static const int powerupTileFreezeDuration = 5;
  static const int powerupBlockerShieldDuration = 3;
  static const int powerupLockTileDuration = 5;

  // Powerup limits
  static const int maxPowerupsInInventory = 3;
  static const int maxPowerupUsesPerGame =
      1; // Each powerup type can only be used once per game

  // Powerup visual effect durations (in milliseconds)
  static const int powerupActivationAnimationDuration = 500;
  static const int powerupGlowEffectDuration = 300;
  static const int powerupFeedbackAnimationDuration = 200;

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

  // ==================== GESTURE CONSTANTS ====================

  // Optimized swipe detection thresholds for reliable 4-directional gestures
  static const double swipeVelocityThreshold =
      30.0; // pixels/second - optimized for better sensitivity
  static const double swipeDistanceThreshold =
      15.0; // minimum distance in pixels - optimized for sensitivity while preventing accidental touches
  static const Duration swipeDebounceDelay = Duration(
    milliseconds: 100,
  ); // optimized for responsiveness without double-triggers

  // Strict cardinal direction enforcement
  static const double minimumSwipeRatio =
      1.5; // enforces clear cardinal directions only
  static const double maxSwipeVelocity =
      5000.0; // allows fast gestures while preventing false positives

  // Animation conflict prevention
  static const Duration gestureBlockDuration = Duration(milliseconds: 200);
  static const double animationBlockThreshold =
      0.1; // block gestures during animations

  // ==================== KEYBOARD INPUT CONSTANTS ====================

  // Keyboard input debouncing
  static const Duration keyboardDebounceDelay = Duration(
    milliseconds: 150,
  ); // Slightly longer than swipe for key repeat prevention

  // ==================== ADVERTISEMENT CONSTANTS ====================

  // Production ad unit IDs
  static final String bannerAdUnitId = isAndroid
      ? 'ca-app-pub-2404185391574038/2009745305'
      : 'ca-app-pub-2404185391574038/8809372197';
  static String interstitialAdUnitId = isAndroid
      ? 'ca-app-pub-2404185391574038/7085385116'
      : 'ca-app-pub-2404185391574038/9167932015';

  // Test ad unit IDs (for development/testing)
  static const String testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  // Ad configuration
  static const int interstitialAdTriggerGameCount =
      3; // Show interstitial after every 3 completed games
  static const Duration adLoadTimeout = Duration(seconds: 10);
  static const Duration adDisplayDelay = Duration(
    milliseconds: 500,
  ); // Delay before showing ad after game over
  static const int maxAdRetryAttempts = 3;
  static const Duration adRetryDelay = Duration(seconds: 2);

  // Banner ad settings
  static const double bannerAdHeight = 50.0;
  static const double bannerAdMargin = 8.0;
  static const Duration bannerAdRefreshInterval = Duration(minutes: 1);

  // Ad storage keys
  static const String adCompletedGamesCountKey =
      '${AppConfig.bundleId}_ad_completed_games_count';
  static const String adLastInterstitialShownKey =
      '${AppConfig.bundleId}_ad_last_interstitial_shown';

  // ==================== LEADERBOARD CONSTANTS ====================

  // Leaderboard configuration
  static const int maxLeaderboardEntries = 50;
  static const int minScoreThreshold =
      0; // Allow all scores for 50 most recent games
  static const String leaderboardStorageKey =
      '${AppConfig.bundleId}_leaderboard_data';

  // Game mode identifiers for leaderboard
  static const String gameModeClassic = 'Classic';
  static const String gameModeTimeAttack = 'Time Attack';
  static const String gameModeScenicMode = 'Scenic';

  // ==================== PAYMENT CONSTANTS ====================

  // Razorpay configuration
  static const String razorpayKeyId = 'rzp_test_mEks3BWASlWTsr';
  static const String razorpayKeySecret = 'ZzfS0XCfdy9PJCtuXsmJxBpD';

  // Payment settings
  static const int removeAdsPrice = 100; // ₹100 in paise (10000 paise = ₹100)
  static const int removeAdsPriceInPaise = 10000; // Razorpay uses paise
  static const String paymentCurrency = 'INR';
  static const String paymentCompanyName = 'Ultra 2048';
  static const String removeAdsProductName = 'Remove Ads';
  static const String removeAdsDescription =
      'Remove all advertisements permanently';

  // Payment storage keys
  static const String adRemovalPurchaseKey =
      '${AppConfig.bundleId}_ad_removal_purchased';
  static const String paymentTransactionKey =
      '${AppConfig.bundleId}_payment_transaction';
  static const String lastPaymentAttemptKey =
      '${AppConfig.bundleId}_last_payment_attempt';

  // Payment status
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusSuccess = 'success';
  static const String paymentStatusFailed = 'failed';
  static const String paymentStatusCancelled = 'cancelled';

  // Payment timeout and retry settings
  static const Duration paymentTimeout = Duration(minutes: 5);
  static const int maxPaymentRetries = 3;
  static const Duration paymentRetryDelay = Duration(seconds: 3);

  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
}

/// Route constants for navigation
class AppRoutes {
  AppRoutes._();

  // Main routes
  static const String home = '/';
  static const String gameModeSelection = '/game-mode-selection';
  static const String game = '/game';
  static const String leaderboard = '/leaderboard';
  static const String about = '/about';
  static const String help = '/help';
  static const String feedback = '/feedback';
  static const String privacyPolicy = '/privacy-policy';

  // Settings routes
  static const String settings = '/settings';
  static const String themeSettings = '/settings/theme';
  static const String fontSettings = '/settings/font';
  static const String soundSettings = '/settings/sound';
  static const String languageSettings = '/settings/language';

  // User routes
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String profile = '/profile';

  // Route names for analytics/logging
  static const String homeRouteName = 'home';
  static const String gameModeSelectionRouteName = 'game_mode_selection';
  static const String gameRouteName = 'game';
  static const String leaderboardRouteName = 'leaderboard';
  static const String aboutRouteName = 'about';
  static const String helpRouteName = 'help';
  static const String feedbackRouteName = 'feedback';
  static const String privacyPolicyRouteName = 'privacy_policy';
  static const String settingsRouteName = 'settings';
  static const String themeSettingsRouteName = 'theme_settings';
  static const String fontSettingsRouteName = 'font_settings';
  static const String soundSettingsRouteName = 'sound_settings';
  static const String languageSettingsRouteName = 'language_settings';
  static const String loginRouteName = 'login';
  static const String forgotPasswordRouteName = 'forgot_password';
  static const String profileRouteName = 'profile';

  // Default route from configuration
  static const String defaultRoute = AppConfig.defaultRoute;

  // Feature-based route availability
  static bool get isGameScreenEnabled =>
      AppConfig.isFeatureEnabled('game_screen');
  static bool get isAboutScreenEnabled =>
      AppConfig.isFeatureEnabled('about_screen');
  static bool get isHelpScreenEnabled =>
      AppConfig.isFeatureEnabled('help_screen');
  static bool get isFeedbackScreenEnabled =>
      AppConfig.isFeatureEnabled('feedback_screen');
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

/// Sound file paths constants
class SoundAssets {
  SoundAssets._();

  // Base path
  static const String _basePath = AppConstants.soundAssetPath;
  static const String _ext = AppConstants.soundFileExtension;

  // UI Navigation Sounds
  static const String buttonTap = '${_basePath}ui_button_tap$_ext';
  static const String navigationTransition = '${_basePath}ui_navigation$_ext';
  static const String menuOpen = '${_basePath}ui_menu_open$_ext';
  static const String menuClose = '${_basePath}ui_menu_close$_ext';
  static const String backButton = '${_basePath}ui_back$_ext';

  // Game Sounds
  static const String tileMove = '${_basePath}game_tile_move$_ext';
  static const String tileMerge = '${_basePath}game_tile_merge$_ext';
  static const String tileAppear = '${_basePath}game_tile_appear$_ext';
  static const String blockerCreate = '${_basePath}game_blocker_create$_ext';
  static const String blockerMerge = '${_basePath}game_blocker_merge$_ext';

  // Powerup Sounds
  static const String powerupUnlock = '${_basePath}powerup_unlock$_ext';
  static const String powerupTileFreeze =
      '${_basePath}powerup_tile_freeze$_ext';
  static const String powerupTileDestroyer =
      '${_basePath}powerup_tile_destroyer$_ext';
  static const String powerupRowClear = '${_basePath}powerup_row_clear$_ext';
  static const String powerupColumnClear =
      '${_basePath}powerup_column_clear$_ext';

  // Time Attack Sounds
  static const String timerTick = '${_basePath}timer_tick$_ext';
  static const String timerWarning = '${_basePath}timer_warning$_ext';
  static const String timeUp = '${_basePath}timer_time_up$_ext';

  // Game State Sounds
  static const String gameOver = '${_basePath}game_over$_ext';
  static const String gameWin = '${_basePath}game_win$_ext';
  static const String newGame = '${_basePath}game_new$_ext';
  static const String pauseGame = '${_basePath}game_pause$_ext';
  static const String resumeGame = '${_basePath}game_resume$_ext';

  // All sound files for preloading
  static const List<String> allSounds = [
    // UI Sounds
    buttonTap,
    navigationTransition,
    menuOpen,
    menuClose,
    backButton,
    // Game Sounds
    tileMove,
    tileMerge,
    tileAppear,
    blockerCreate,
    blockerMerge,
    // Powerup Sounds
    powerupUnlock,
    powerupTileFreeze,
    powerupTileDestroyer,
    powerupRowClear,
    powerupColumnClear,
    // Time Attack Sounds
    timerTick,
    timerWarning,
    timeUp,
    // Game State Sounds
    gameOver,
    gameWin,
    newGame,
    pauseGame,
    resumeGame,
  ];
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
