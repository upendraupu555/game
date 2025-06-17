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
  static String developerName(WidgetRef ref) =>
      translate(ref, 'developer_name');
  static String madeWithLove(WidgetRef ref) => translate(ref, 'made_with_love');
  static String builtWithFlutter(WidgetRef ref) =>
      translate(ref, 'built_with_flutter');
  static String contactSupport(WidgetRef ref) =>
      translate(ref, 'contact_support');
  static String sendFeedback(WidgetRef ref) => translate(ref, 'send_feedback');
  static String getHelp(WidgetRef ref) => translate(ref, 'get_help');
  static String privacyPolicySubtitle(WidgetRef ref) =>
      translate(ref, 'privacy_policy_subtitle');

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

  // Leaderboard related
  static String leaderboard(WidgetRef ref) => translate(ref, 'leaderboard');
  static String leaderboardStatistics(WidgetRef ref) =>
      translate(ref, 'leaderboard_statistics');
  static String totalEntries(WidgetRef ref) => translate(ref, 'total_entries');
  static String highestScore(WidgetRef ref) => translate(ref, 'highest_score');
  static String noLeaderboardEntries(WidgetRef ref) =>
      translate(ref, 'no_leaderboard_entries');
  static String playGamesToSeeLeaderboard(WidgetRef ref) =>
      translate(ref, 'play_games_to_see_leaderboard');
  static String errorLoadingLeaderboard(WidgetRef ref) =>
      translate(ref, 'error_loading_leaderboard');
  static String allGameModes(WidgetRef ref) => translate(ref, 'all_game_modes');
  static String filtering(WidgetRef ref) => translate(ref, 'filtering');
  static String clearFilter(WidgetRef ref) => translate(ref, 'clear_filter');
  static String clearLeaderboard(WidgetRef ref) =>
      translate(ref, 'clear_leaderboard');
  static String clearLeaderboardConfirmation(WidgetRef ref) =>
      translate(ref, 'clear_leaderboard_confirmation');
  static String clearLeaderboardMessage(WidgetRef ref) =>
      translate(ref, 'clear_leaderboard_message');
  static String leaderboardCleared(WidgetRef ref) =>
      translate(ref, 'leaderboard_cleared');

  // Game won related
  static String congratulations(WidgetRef ref) =>
      translate(ref, 'congratulations');
  static String youWon(WidgetRef ref) => translate(ref, 'you_won');
  static String finalScore(WidgetRef ref) => translate(ref, 'final_score');
  static String continueForHigherScore(WidgetRef ref) =>
      translate(ref, 'continue_for_higher_score');
  static String continuePlaying(WidgetRef ref) =>
      translate(ref, 'continue_playing');
  static String returnToHome(WidgetRef ref) => translate(ref, 'return_to_home');
  static String gameModeSelection(WidgetRef ref) =>
      translate(ref, 'game_mode_selection');

  // Language settings
  static String languageSettings(WidgetRef ref) =>
      translate(ref, 'language_settings');
  static String selectLanguage(WidgetRef ref) =>
      translate(ref, 'select_language');
  static String languageChanged(WidgetRef ref) =>
      translate(ref, 'language_changed');
  static String restartRequired(WidgetRef ref) =>
      translate(ref, 'restart_required');
  static String languageChangeMessage(WidgetRef ref) =>
      translate(ref, 'language_change_message');

  // Home screen specific
  static String continueGame(WidgetRef ref) => translate(ref, 'continue_game');
  static String startPlaying(WidgetRef ref) => translate(ref, 'start_playing');
  static String startFreshAdventure(WidgetRef ref) =>
      translate(ref, 'start_fresh_adventure');
  static String beginPuzzleJourney(WidgetRef ref) =>
      translate(ref, 'begin_puzzle_journey');
  static String scoreLabel(WidgetRef ref) => translate(ref, 'score_label');

  // Dialog and navigation specific
  static String comingSoonFeature(WidgetRef ref) =>
      translate(ref, 'coming_soon_feature');
  static String navigationError(WidgetRef ref) =>
      translate(ref, 'navigation_error');
  static String navigationFailed(WidgetRef ref) =>
      translate(ref, 'navigation_failed');
  static String navigating(WidgetRef ref) => translate(ref, 'navigating');
  static String confirm(WidgetRef ref) => translate(ref, 'confirm');
  static String ok(WidgetRef ref) => translate(ref, 'ok');

  // Help screen specific
  static String helpGameMechanics(WidgetRef ref) =>
      translate(ref, 'help_game_mechanics');
  static String helpBoardLayout(WidgetRef ref) =>
      translate(ref, 'help_board_layout');
  static String helpBoardLayoutDesc(WidgetRef ref) =>
      translate(ref, 'help_board_layout_desc');
  static String helpBasicGameplay(WidgetRef ref) =>
      translate(ref, 'help_basic_gameplay');
  static String helpBasicGameplayDesc(WidgetRef ref) =>
      translate(ref, 'help_basic_gameplay_desc');
  static String helpKeyboardControls(WidgetRef ref) =>
      translate(ref, 'help_keyboard_controls');
  static String helpKeyboardControlsDesc(WidgetRef ref) =>
      translate(ref, 'help_keyboard_controls_desc');
  static String helpTileMovement(WidgetRef ref) =>
      translate(ref, 'help_tile_movement');
  static String helpTileMovementDesc(WidgetRef ref) =>
      translate(ref, 'help_tile_movement_desc');
  static String helpMergingRules(WidgetRef ref) =>
      translate(ref, 'help_merging_rules');
  static String helpMergingRulesDesc(WidgetRef ref) =>
      translate(ref, 'help_merging_rules_desc');
  static String helpWinCondition(WidgetRef ref) =>
      translate(ref, 'help_win_condition');
  static String helpWinConditionDesc(WidgetRef ref) =>
      translate(ref, 'help_win_condition_desc');
  static String helpGameOver(WidgetRef ref) => translate(ref, 'help_game_over');
  static String helpGameOverDesc(WidgetRef ref) =>
      translate(ref, 'help_game_over_desc');
  static String helpSpecialTiles(WidgetRef ref) =>
      translate(ref, 'help_special_tiles');
  static String helpBlockerTiles(WidgetRef ref) =>
      translate(ref, 'help_blocker_tiles');
  static String helpBlockerTilesDesc(WidgetRef ref) =>
      translate(ref, 'help_blocker_tiles_desc');
  static String helpBlockerRules(WidgetRef ref) =>
      translate(ref, 'help_blocker_rules');
  static String helpBlockerRule1(WidgetRef ref) =>
      translate(ref, 'help_blocker_rule_1');
  static String helpBlockerRule2(WidgetRef ref) =>
      translate(ref, 'help_blocker_rule_2');
  static String helpBlockerRule3(WidgetRef ref) =>
      translate(ref, 'help_blocker_rule_3');
  static String helpPowerupSystem(WidgetRef ref) =>
      translate(ref, 'help_powerup_system');
  static String helpPowerupUnlock(WidgetRef ref) =>
      translate(ref, 'help_powerup_unlock');
  static String helpPowerupUnlockDesc(WidgetRef ref) =>
      translate(ref, 'help_powerup_unlock_desc');
  static String helpAvailablePowerups(WidgetRef ref) =>
      translate(ref, 'help_available_powerups');
  static String helpTileDestroyer(WidgetRef ref) =>
      translate(ref, 'help_tile_destroyer');
  static String helpTileDestroyerDesc(WidgetRef ref) =>
      translate(ref, 'help_tile_destroyer_desc');
  static String helpRowClear(WidgetRef ref) => translate(ref, 'help_row_clear');
  static String helpRowClearDesc(WidgetRef ref) =>
      translate(ref, 'help_row_clear_desc');
  static String helpColumnClear(WidgetRef ref) =>
      translate(ref, 'help_column_clear');
  static String helpColumnClearDesc(WidgetRef ref) =>
      translate(ref, 'help_column_clear_desc');
  static String helpValueUpgrade(WidgetRef ref) =>
      translate(ref, 'help_value_upgrade');
  static String helpValueUpgradeDesc(WidgetRef ref) =>
      translate(ref, 'help_value_upgrade_desc');
  static String helpTileFreeze(WidgetRef ref) =>
      translate(ref, 'help_tile_freeze');
  static String helpTileFreezeDesc(WidgetRef ref) =>
      translate(ref, 'help_tile_freeze_desc');
  static String helpPowerupUsage(WidgetRef ref) =>
      translate(ref, 'help_powerup_usage');
  static String helpPowerupUsageDesc(WidgetRef ref) =>
      translate(ref, 'help_powerup_usage_desc');
  static String helpGameModes(WidgetRef ref) =>
      translate(ref, 'help_game_modes');
  static String helpClassicMode(WidgetRef ref) =>
      translate(ref, 'help_classic_mode');
  static String helpClassicModeDesc(WidgetRef ref) =>
      translate(ref, 'help_classic_mode_desc');
  static String helpTimeAttackMode(WidgetRef ref) =>
      translate(ref, 'help_time_attack_mode');
  static String helpTimeAttackModeDesc(WidgetRef ref) =>
      translate(ref, 'help_time_attack_mode_desc');
  static String helpScenicMode(WidgetRef ref) =>
      translate(ref, 'help_scenic_mode');
  static String helpScenicModeDesc(WidgetRef ref) =>
      translate(ref, 'help_scenic_mode_desc');
  static String helpControls(WidgetRef ref) => translate(ref, 'help_controls');
  static String helpTouchControls(WidgetRef ref) =>
      translate(ref, 'help_touch_controls');
  static String helpTouchControlsDesc(WidgetRef ref) =>
      translate(ref, 'help_touch_controls_desc');
  static String helpKeyboardSupport(WidgetRef ref) =>
      translate(ref, 'help_keyboard_support');
  static String helpKeyboardSupportDesc(WidgetRef ref) =>
      translate(ref, 'help_keyboard_support_desc');
  static String helpPauseControls(WidgetRef ref) =>
      translate(ref, 'help_pause_controls');
  static String helpPauseControlsDesc(WidgetRef ref) =>
      translate(ref, 'help_pause_controls_desc');
  static String helpScoring(WidgetRef ref) => translate(ref, 'help_scoring');
  static String helpScoreDisplay(WidgetRef ref) =>
      translate(ref, 'help_score_display');
  static String helpScoreDisplayDesc(WidgetRef ref) =>
      translate(ref, 'help_score_display_desc');
  static String helpBestScore(WidgetRef ref) =>
      translate(ref, 'help_best_score');
  static String helpBestScoreDesc(WidgetRef ref) =>
      translate(ref, 'help_best_score_desc');
  static String helpStatistics(WidgetRef ref) =>
      translate(ref, 'help_statistics');
  static String helpStatisticsDesc(WidgetRef ref) =>
      translate(ref, 'help_statistics_desc');
  static String helpTipsStrategies(WidgetRef ref) =>
      translate(ref, 'help_tips_strategies');
  static String helpCornerStrategy(WidgetRef ref) =>
      translate(ref, 'help_corner_strategy');
  static String helpCornerStrategyDesc(WidgetRef ref) =>
      translate(ref, 'help_corner_strategy_desc');
  static String helpDirectionConsistency(WidgetRef ref) =>
      translate(ref, 'help_direction_consistency');
  static String helpDirectionConsistencyDesc(WidgetRef ref) =>
      translate(ref, 'help_direction_consistency_desc');
  static String helpPowerupTiming(WidgetRef ref) =>
      translate(ref, 'help_powerup_timing');
  static String helpPowerupTimingDesc(WidgetRef ref) =>
      translate(ref, 'help_powerup_timing_desc');
  static String helpBlockerManagement(WidgetRef ref) =>
      translate(ref, 'help_blocker_management');
  static String helpBlockerManagementDesc(WidgetRef ref) =>
      translate(ref, 'help_blocker_management_desc');
  static String helpFaq(WidgetRef ref) => translate(ref, 'help_faq');
  static String helpFaqHowToPlay(WidgetRef ref) =>
      translate(ref, 'help_faq_how_to_play');
  static String helpFaqHowToPlayAnswer(WidgetRef ref) =>
      translate(ref, 'help_faq_how_to_play_answer');
  static String helpFaqWinCondition(WidgetRef ref) =>
      translate(ref, 'help_faq_win_condition');
  static String helpFaqWinConditionAnswer(WidgetRef ref) =>
      translate(ref, 'help_faq_win_condition_answer');
  static String helpFaqPowerups(WidgetRef ref) =>
      translate(ref, 'help_faq_powerups');
  static String helpFaqPowerupsAnswer(WidgetRef ref) =>
      translate(ref, 'help_faq_powerups_answer');
  static String helpFaqBlockers(WidgetRef ref) =>
      translate(ref, 'help_faq_blockers');
  static String helpFaqBlockersAnswer(WidgetRef ref) =>
      translate(ref, 'help_faq_blockers_answer');
  static String helpFaqGameModes(WidgetRef ref) =>
      translate(ref, 'help_faq_game_modes');
  static String helpFaqGameModesAnswer(WidgetRef ref) =>
      translate(ref, 'help_faq_game_modes_answer');
  static String helpFaqControls(WidgetRef ref) =>
      translate(ref, 'help_faq_controls');
  static String helpFaqControlsAnswer(WidgetRef ref) =>
      translate(ref, 'help_faq_controls_answer');
  static String helpNeedMoreHelp(WidgetRef ref) =>
      translate(ref, 'help_need_more_help');
  static String helpContactSupport(WidgetRef ref) =>
      translate(ref, 'help_contact_support');

  // Context-based convenience methods (for widgets without WidgetRef)
  static String appTitleWithContext(BuildContext context) =>
      translateWithContext(context, 'app_title');
  static String loadingWithContext(BuildContext context) =>
      translateWithContext(context, 'loading');
  static String errorWithContext(BuildContext context) =>
      translateWithContext(context, 'error');
  static String retryWithContext(BuildContext context) =>
      translateWithContext(context, 'retry');

  // Powerup inventory management
  static String powerupInventoryFull(WidgetRef ref) =>
      translate(ref, 'powerup_inventory_full');
  static String powerupInventoryFullMessage(WidgetRef ref) =>
      translate(ref, 'powerup_inventory_full_message');
  static String replacePowerup(WidgetRef ref) =>
      translate(ref, 'replace_powerup');
  static String discardNewPowerup(WidgetRef ref) =>
      translate(ref, 'discard_new_powerup');
  static String selectPowerupToReplace(WidgetRef ref) =>
      translate(ref, 'select_powerup_to_replace');
  static String newPowerupEarned(WidgetRef ref) =>
      translate(ref, 'new_powerup_earned');
  static String powerupReplaced(WidgetRef ref) =>
      translate(ref, 'powerup_replaced');
  static String powerupDiscarded(WidgetRef ref) =>
      translate(ref, 'powerup_discarded');
}
