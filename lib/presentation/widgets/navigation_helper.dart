import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/navigation_entity.dart';
import '../providers/navigation_providers.dart';

/// Navigation helper widget that provides easy navigation methods
/// This widget encapsulates navigation logic and provides a clean API
class NavigationHelper extends ConsumerWidget {
  final Widget child;

  const NavigationHelper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child;
  }

  /// Navigate to home screen
  static Future<void> toHome(WidgetRef ref) async {
    final navigation = NavigationEntity(
      path: AppRoutes.home,
      name: AppRoutes.homeRouteName,
      clearStack: true,
    );
    await ref.read(navigationProvider.notifier).navigateAndClearStack(navigation);
  }

  /// Navigate to theme settings
  static Future<void> toThemeSettings(WidgetRef ref) async {
    final navigation = NavigationEntity(
      path: AppRoutes.themeSettings,
      name: AppRoutes.themeSettingsRouteName,
    );
    await ref.read(navigationProvider.notifier).navigateTo(navigation);
  }

  /// Navigate to font settings
  static Future<void> toFontSettings(WidgetRef ref) async {
    final navigation = NavigationEntity(
      path: AppRoutes.fontSettings,
      name: AppRoutes.fontSettingsRouteName,
    );
    await ref.read(navigationProvider.notifier).navigateTo(navigation);
  }

  /// Navigate to language settings
  static Future<void> toLanguageSettings(WidgetRef ref) async {
    final navigation = NavigationEntity(
      path: AppRoutes.languageSettings,
      name: AppRoutes.languageSettingsRouteName,
    );
    await ref.read(navigationProvider.notifier).navigateTo(navigation);
  }

  /// Navigate to game screen
  static Future<void> toGame(WidgetRef ref, {Map<String, dynamic>? arguments}) async {
    final navigation = NavigationEntity(
      path: AppRoutes.game,
      name: AppRoutes.gameRouteName,
      arguments: arguments,
    );
    await ref.read(navigationProvider.notifier).navigateTo(navigation);
  }

  /// Navigate back
  static Future<void> back(WidgetRef ref, {dynamic result}) async {
    await ref.read(navigationProvider.notifier).navigateBack(result: result);
  }

  /// Check if can navigate back
  static bool canGoBack(WidgetRef ref) {
    return ref.read(canNavigateBackProvider);
  }

  /// Show confirmation dialog before navigation
  static Future<bool> showNavigationConfirmation(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText ?? 'Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show loading dialog during navigation
  static Future<T?> showNavigationLoading<T>(
    BuildContext context,
    Future<T> navigationFuture, {
    String? loadingText,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(loadingText ?? 'Navigating...'),
          ],
        ),
      ),
    );

    try {
      // Wait for navigation to complete
      final result = await navigationFuture;
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      return result;
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      rethrow;
    }
  }

  /// Navigate with error handling
  static Future<bool> navigateWithErrorHandling(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() navigationFunction, {
    String? errorTitle,
    String? errorMessage,
  }) async {
    try {
      await navigationFunction();
      return true;
    } catch (e) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(errorTitle ?? 'Navigation Error'),
            content: Text(errorMessage ?? 'Failed to navigate: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return false;
    }
  }
}

/// Extension on WidgetRef for easy navigation access
extension NavigationExtension on WidgetRef {
  /// Quick access to navigation helper methods
  NavigationHelper get nav => NavigationHelper(child: const SizedBox.shrink());

  /// Navigate to home
  Future<void> toHome() => NavigationHelper.toHome(this);

  /// Navigate to theme settings
  Future<void> toThemeSettings() => NavigationHelper.toThemeSettings(this);

  /// Navigate to font settings
  Future<void> toFontSettings() => NavigationHelper.toFontSettings(this);

  /// Navigate to language settings
  Future<void> toLanguageSettings() => NavigationHelper.toLanguageSettings(this);

  /// Navigate to game
  Future<void> toGame({Map<String, dynamic>? arguments}) => 
      NavigationHelper.toGame(this, arguments: arguments);

  /// Navigate back
  Future<void> goBack({dynamic result}) => NavigationHelper.back(this, result: result);

  /// Check if can navigate back
  bool get canGoBack => NavigationHelper.canGoBack(this);
}

/// Mixin for widgets that need navigation functionality
mixin NavigationMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Navigate to home
  Future<void> toHome() => ref.toHome();

  /// Navigate to theme settings
  Future<void> toThemeSettings() => ref.toThemeSettings();

  /// Navigate to font settings
  Future<void> toFontSettings() => ref.toFontSettings();

  /// Navigate to language settings
  Future<void> toLanguageSettings() => ref.toLanguageSettings();

  /// Navigate to game
  Future<void> toGame({Map<String, dynamic>? arguments}) => 
      ref.toGame(arguments: arguments);

  /// Navigate back
  Future<void> goBack({dynamic result}) => ref.goBack(result: result);

  /// Check if can navigate back
  bool get canGoBack => ref.canGoBack;

  /// Show navigation confirmation
  Future<bool> showNavigationConfirmation({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) => NavigationHelper.showNavigationConfirmation(
        context,
        ref,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
      );
}
