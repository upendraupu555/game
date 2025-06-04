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
  static String translateWithContext(
    BuildContext context,
    String key, {
    String? fallback,
  }) {
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
  static String welcomeMessage(WidgetRef ref) =>
      translate(ref, 'welcome_message');
  static String startGame(WidgetRef ref) => translate(ref, 'start_game');
  static String startApp(WidgetRef ref) => translate(ref, 'start_app');
  static String gameComingSoon(WidgetRef ref) => translate(ref, 'coming_soon');
  static String comingSoon(WidgetRef ref) => translate(ref, 'coming_soon');

  // Theme related
  static String themeSettings(WidgetRef ref) =>
      translate(ref, 'theme_settings');
  static String themeMode(WidgetRef ref) => translate(ref, 'theme_mode');
  static String lightThemePrimaryColor(WidgetRef ref) =>
      translate(ref, 'light_primary_color');
  static String darkThemePrimaryColor(WidgetRef ref) =>
      translate(ref, 'dark_primary_color');
  static String themePreviewText(WidgetRef ref) =>
      translate(ref, 'theme_preview_text');
  static String themeResetMessage(WidgetRef ref) =>
      translate(ref, 'theme_reset_message');

  // Font related
  static String fontSettings(WidgetRef ref) => translate(ref, 'font_settings');
  static String fontFamily(WidgetRef ref) => translate(ref, 'font_family');
  static String fontFamilyLabel(WidgetRef ref) =>
      translate(ref, 'font_family_label');
  static String fontPreviewText(WidgetRef ref) =>
      translate(ref, 'font_preview_text');
  static String fontPreviewNumbers(WidgetRef ref) =>
      translate(ref, 'font_preview_numbers');
  static String fontResetMessage(WidgetRef ref) =>
      translate(ref, 'font_reset_message');

  // Sound settings
  static String soundSettings(WidgetRef ref) =>
      translate(ref, 'sound_settings');
  static String soundEnabled(WidgetRef ref) => translate(ref, 'sound_enabled');
  static String soundDisabled(WidgetRef ref) =>
      translate(ref, 'sound_disabled');
  static String masterVolume(WidgetRef ref) => translate(ref, 'master_volume');
  static String uiVolume(WidgetRef ref) => translate(ref, 'ui_volume');
  static String gameVolume(WidgetRef ref) => translate(ref, 'game_volume');
  static String powerupVolume(WidgetRef ref) =>
      translate(ref, 'powerup_volume');
  static String timerVolume(WidgetRef ref) => translate(ref, 'timer_volume');
  static String soundResetMessage(WidgetRef ref) =>
      translate(ref, 'sound_reset_message');

  // Button text
  static String primaryButton(WidgetRef ref) =>
      translate(ref, 'primary_button');
  static String outlinedButton(WidgetRef ref) =>
      translate(ref, 'outlined_button');

  // Theme mode descriptions
  static String lightThemeDescription(WidgetRef ref) =>
      translate(ref, 'light_description');
  static String darkThemeDescription(WidgetRef ref) =>
      translate(ref, 'dark_description');
  static String systemThemeDescription(WidgetRef ref) =>
      translate(ref, 'system_description');

  // Color names
  static String colorNameCrimsonRed(WidgetRef ref) =>
      translate(ref, 'color_crimson_red');
  static String colorNameOceanBlue(WidgetRef ref) =>
      translate(ref, 'color_ocean_blue');
  static String colorNameRosePink(WidgetRef ref) =>
      translate(ref, 'color_rose_pink');
  static String colorNameSunsetOrange(WidgetRef ref) =>
      translate(ref, 'color_sunset_orange');
  static String colorNameSilverGray(WidgetRef ref) =>
      translate(ref, 'color_silver_gray');
  static String colorNameForestGreen(WidgetRef ref) =>
      translate(ref, 'color_forest_green');
  static String colorNameGoldenYellow(WidgetRef ref) =>
      translate(ref, 'color_golden_yellow');
  static String colorNameCustom(WidgetRef ref) =>
      translate(ref, 'color_custom');

  // Font names
  static String fontNameBubblegumSans(WidgetRef ref) =>
      translate(ref, 'font_bubblegum_sans');
  static String fontNameChewy(WidgetRef ref) => translate(ref, 'font_chewy');
  static String fontNameComicNeue(WidgetRef ref) =>
      translate(ref, 'font_comic_neue');

  // Error messages
  static String errorLoadingTheme(WidgetRef ref) =>
      translate(ref, 'error_loading_theme');
  static String errorSavingTheme(WidgetRef ref) =>
      translate(ref, 'error_saving_theme');
  static String errorClearingTheme(WidgetRef ref) =>
      translate(ref, 'error_clearing_theme');
  static String errorResetTheme(WidgetRef ref) =>
      translate(ref, 'error_reset_theme');
  static String errorLoadingFont(WidgetRef ref) =>
      translate(ref, 'error_loading_font');
  static String errorSavingFont(WidgetRef ref) =>
      translate(ref, 'error_saving_font');
  static String errorLoadingLocalization(WidgetRef ref) =>
      translate(ref, 'error_loading_localization');
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
  static String navGameScreen(WidgetRef ref) =>
      translate(ref, 'nav_game_screen');
  static String navLanguageSettings(WidgetRef ref) =>
      translate(ref, 'nav_language_settings');

  // About, Help, and Feedback content
  static String aboutTitle(WidgetRef ref) => translate(ref, 'about_title');
  static String aboutApp(WidgetRef ref) => translate(ref, 'about_app');
  static String aboutDescription(WidgetRef ref) =>
      translate(ref, 'about_description');
  static String helpTitle(WidgetRef ref) => translate(ref, 'help_title');
  static String helpDescription(WidgetRef ref) =>
      translate(ref, 'help_description');
  static String feedbackTitle(WidgetRef ref) =>
      translate(ref, 'feedback_title');
  static String feedbackDescription(WidgetRef ref) =>
      translate(ref, 'feedback_description');
  static String versionInfo(WidgetRef ref) => translate(ref, 'version_info');
  static String companyInfo(WidgetRef ref) => translate(ref, 'company_info');
  static String contactUs(WidgetRef ref) => translate(ref, 'contact_us');
  static String privacyPolicy(WidgetRef ref) =>
      translate(ref, 'privacy_policy');
  static String termsOfService(WidgetRef ref) =>
      translate(ref, 'terms_of_service');

  // Game-specific strings
  static String gameTitle(WidgetRef ref) => translate(ref, 'game_title');
  static String score(WidgetRef ref) => translate(ref, 'score');
  static String bestScore(WidgetRef ref) => translate(ref, 'best_score');
  static String newGame(WidgetRef ref) => translate(ref, 'new_game');
  static String restartGame(WidgetRef ref) => translate(ref, 'restart_game');
  static String playAgain(WidgetRef ref) => translate(ref, 'play_again');
  static String tryAgain(WidgetRef ref) => translate(ref, 'try_again');
  static String youWin(WidgetRef ref) => translate(ref, 'you_win');
  static String gameOver(WidgetRef ref) => translate(ref, 'game_over');
  static String howToPlay(WidgetRef ref) => translate(ref, 'how_to_play');
  static String gameInstructions(WidgetRef ref) =>
      translate(ref, 'game_instructions');
  static String up(WidgetRef ref) => translate(ref, 'up');
  static String down(WidgetRef ref) => translate(ref, 'down');
  static String left(WidgetRef ref) => translate(ref, 'left');
  static String right(WidgetRef ref) => translate(ref, 'right');
  static String statistics(WidgetRef ref) => translate(ref, 'statistics');
  static String gamesPlayed(WidgetRef ref) => translate(ref, 'games_played');
  static String gamesWon(WidgetRef ref) => translate(ref, 'games_won');
  static String winRate(WidgetRef ref) => translate(ref, 'win_rate');
  static String averageScore(WidgetRef ref) => translate(ref, 'average_score');
  static String totalPlayTime(WidgetRef ref) =>
      translate(ref, 'total_play_time');
  static String resetData(WidgetRef ref) => translate(ref, 'reset_data');
  static String resetDataConfirmation(WidgetRef ref) =>
      translate(ref, 'reset_data_confirmation');
  static String loadingGame(WidgetRef ref) => translate(ref, 'loading_game');
  static String errorLoadingGame(WidgetRef ref) =>
      translate(ref, 'error_loading_game');
  static String close(WidgetRef ref) => translate(ref, 'close');
  static String newBestScore(WidgetRef ref) => translate(ref, 'new_best_score');
  static String blockerTileAdded(WidgetRef ref) =>
      translate(ref, 'blocker_tile_added');
  static String blockerTilesInfo(WidgetRef ref) =>
      translate(ref, 'blocker_tiles_info');
  static String blockerTilesMerged(WidgetRef ref) =>
      translate(ref, 'blocker_tiles_merged');
  static String blockerMergeInfo(WidgetRef ref) =>
      translate(ref, 'blocker_merge_info');
  static String pauseMenu(WidgetRef ref) => translate(ref, 'pause_menu');
  static String resumeGame(WidgetRef ref) => translate(ref, 'resume_game');
  static String mainMenu(WidgetRef ref) => translate(ref, 'main_menu');
  static String resumeScore(WidgetRef ref, int score) =>
      translate(ref, 'resume_score').replaceAll('{score}', score.toString());
  static String startNewGame(WidgetRef ref) => translate(ref, 'start_new_game');
  static String newGameConfirmation(WidgetRef ref) =>
      translate(ref, 'new_game_confirmation');
  static String newGameConfirmationMessage(WidgetRef ref) =>
      translate(ref, 'new_game_confirmation_message');
  static String continueText(WidgetRef ref) => translate(ref, 'continue');
  static String cancel(WidgetRef ref) => translate(ref, 'cancel');
  static String appTagline(WidgetRef ref) => translate(ref, 'app_tagline');

  // Game mode selection
  static String selectGameMode(WidgetRef ref) =>
      translate(ref, 'select_game_mode');
  static String chooseYourChallenge(WidgetRef ref) =>
      translate(ref, 'choose_your_challenge');
  static String selectGameModeDescription(WidgetRef ref) =>
      translate(ref, 'select_game_mode_description');
  static String regularGame(WidgetRef ref) => translate(ref, 'regular_game');
  static String regularGameDescription(WidgetRef ref) =>
      translate(ref, 'regular_game_description');
  static String timeAttack(WidgetRef ref) => translate(ref, 'time_attack');
  static String timeAttackDescription(WidgetRef ref) =>
      translate(ref, 'time_attack_description');
  static String scenicMode(WidgetRef ref) => translate(ref, 'scenic_mode');
  static String scenicModeDescription(WidgetRef ref) =>
      translate(ref, 'scenic_mode_description');
  static String classic(WidgetRef ref) => translate(ref, 'classic');
  static String challenging(WidgetRef ref) => translate(ref, 'challenging');
  static String relaxing(WidgetRef ref) => translate(ref, 'relaxing');
  static String recommended(WidgetRef ref) => translate(ref, 'recommended');
  static String quickStart(WidgetRef ref) => translate(ref, 'quick_start');
  static String selectTimeLimit(WidgetRef ref) =>
      translate(ref, 'select_time_limit');
  static String minutes(WidgetRef ref) => translate(ref, 'minutes');

  // Context-based convenience methods (for widgets without WidgetRef)
  static String appTitleWithContext(BuildContext context) =>
      translateWithContext(context, 'app_title');
  static String loadingWithContext(BuildContext context) =>
      translateWithContext(context, 'loading');
  static String errorWithContext(BuildContext context) =>
      translateWithContext(context, 'error');
  static String retryWithContext(BuildContext context) =>
      translateWithContext(context, 'retry');
}
