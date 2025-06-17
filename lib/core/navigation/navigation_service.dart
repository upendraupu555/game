import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/game_mode_selection_screen.dart';
import '../../presentation/screens/theme_settings_screen.dart';
import '../../presentation/screens/font_settings_screen.dart';
import '../../presentation/screens/sound_settings_screen.dart';
import '../../presentation/screens/about_screen.dart';
import '../../presentation/screens/help_screen.dart';
import '../../presentation/screens/feedback_screen.dart';
import '../../presentation/screens/game_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/forgot_password_screen.dart';
import '../../presentation/screens/leaderboard_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/language_settings_screen.dart';
import '../../presentation/screens/privacy_policy_screen.dart';

/// Navigation service that handles route mapping and navigation logic
/// This is the core service that maps routes to widgets
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Get the current navigator state
  static NavigatorState? get navigator => navigatorKey.currentState;

  /// Get the current context
  static BuildContext? get context => navigatorKey.currentContext;

  /// Route generator for named routes
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '/';
    final Map<String, dynamic>? arguments =
        settings.arguments as Map<String, dynamic>?;

    Widget? page;

    switch (routeName) {
      case AppRoutes.home:
        page = const HomeScreen();
        break;

      case AppRoutes.settings:
        page = const SettingsScreen();
        break;

      case AppRoutes.gameModeSelection:
        page = const GameModeSelectionScreen();
        break;

      case AppRoutes.themeSettings:
        page = const ThemeSettingsScreen();
        break;

      case AppRoutes.fontSettings:
        page = const FontSettingsScreen();
        break;

      case AppRoutes.soundSettings:
        page = const SoundSettingsScreen();
        break;

      case AppRoutes.about:
        if (AppConfig.isFeatureEnabled('about_screen')) {
          page = const AboutScreen();
        }
        break;

      case AppRoutes.help:
        if (AppConfig.isFeatureEnabled('help_screen')) {
          page = const HelpScreen();
        }
        break;

      case AppRoutes.feedback:
        if (AppConfig.isFeatureEnabled('feedback_screen')) {
          page = const FeedbackScreen();
        }
        break;

      case AppRoutes.game:
        if (AppConfig.isFeatureEnabled('game_screen')) {
          page = const GameScreen();
        } else {
          page = _buildFeatureDisabledScreen('Game');
        }
        break;

      case AppRoutes.leaderboard:
        page = const LeaderboardScreen();
        break;

      case AppRoutes.languageSettings:
        if (AppConfig.isFeatureEnabled('language_selection')) {
          page = const LanguageSettingsScreen();
        } else {
          page = _buildFeatureDisabledScreen('Language Settings');
        }
        break;

      case AppRoutes.login:
        page = const LoginScreen();
        break;

      case AppRoutes.forgotPassword:
        page = const ForgotPasswordScreen();
        break;

      case AppRoutes.profile:
        page = const ProfileScreen();
        break;

      case AppRoutes.privacyPolicy:
        page = const PrivacyPolicyScreen();
        break;

      default:
        page = _buildNotFoundScreen(routeName);
        break;
    }

    return MaterialPageRoute(builder: (context) => page!, settings: settings);
  }

  /// Build feature disabled screen
  static Widget _buildFeatureDisabledScreen(String featureName) {
    return Scaffold(
      appBar: AppBar(title: Text('$featureName Disabled')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text('$featureName feature is disabled'),
            const SizedBox(height: 8),
            const Text('This feature can be enabled in the app configuration.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                navigator?.pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build not found screen
  static Widget _buildNotFoundScreen(String routeName) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Route "$routeName" not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                navigator?.pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                );
              },
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigation helper methods
  static Future<T?> pushNamed<T>(
    String routeName, {
    Map<String, dynamic>? arguments,
  }) {
    return navigator?.pushNamed<T>(routeName, arguments: arguments) ??
        Future.value(null);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Map<String, dynamic>? arguments,
    TO? result,
  }) {
    return navigator?.pushReplacementNamed<T, TO>(
          routeName,
          arguments: arguments,
          result: result,
        ) ??
        Future.value(null);
  }

  static Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Map<String, dynamic>? arguments,
  }) {
    return navigator?.pushNamedAndRemoveUntil<T>(
          routeName,
          predicate,
          arguments: arguments,
        ) ??
        Future.value(null);
  }

  static void pop<T>([T? result]) {
    navigator?.pop<T>(result);
  }

  static void popUntil(bool Function(Route<dynamic>) predicate) {
    navigator?.popUntil(predicate);
  }

  static bool canPop() {
    return navigator?.canPop() ?? false;
  }

  /// Show dialog helper
  static Future<T?> showAppDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    final currentContext = context;
    if (currentContext == null) return Future.value(null);

    return showDialog<T>(
      context: currentContext,
      barrierDismissible: barrierDismissible,
      builder: (context) => child,
    );
  }

  /// Show bottom sheet helper
  static Future<T?> showAppBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = false,
  }) {
    final currentContext = context;
    if (currentContext == null) return Future.value(null);

    return showModalBottomSheet<T>(
      context: currentContext,
      isScrollControlled: isScrollControlled,
      builder: (context) => child,
    );
  }

  /// Show snackbar helper
  static void showSnackBar(String message, {Duration? duration}) {
    final currentContext = context;
    if (currentContext == null) return;

    ScaffoldMessenger.of(currentContext).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
}
