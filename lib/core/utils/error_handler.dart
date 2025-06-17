import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/app_logger.dart';
import '../constants/app_constants.dart';

import '../localization/localization_manager.dart';

/// Centralized error handling utility for the application
class ErrorHandler {
  /// Map Supabase authentication errors to user-friendly messages
  static String getAuthErrorMessage(String error, WidgetRef ref) {
    final String lowerError = error.toLowerCase();

    // Network connectivity errors
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout') ||
        lowerError.contains('unreachable')) {
      return LocalizationManager.translate(ref, 'error_network_connection');
    }

    // Invalid credentials
    if (lowerError.contains('invalid_credentials') ||
        lowerError.contains('invalid login credentials') ||
        lowerError.contains('email not confirmed') ||
        lowerError.contains('invalid email or password')) {
      return LocalizationManager.translate(ref, 'error_invalid_credentials');
    }

    // Email not verified
    if (lowerError.contains('email not confirmed') ||
        lowerError.contains('confirm your email') ||
        lowerError.contains('verification')) {
      return LocalizationManager.translate(ref, 'error_email_not_verified');
    }

    // Account locked/disabled
    if (lowerError.contains('account locked') ||
        lowerError.contains('account disabled') ||
        lowerError.contains('user disabled')) {
      return LocalizationManager.translate(ref, 'error_account_disabled');
    }

    // Rate limiting
    if (lowerError.contains('rate limit') ||
        lowerError.contains('too many requests') ||
        lowerError.contains('rate_limit_exceeded')) {
      return LocalizationManager.translate(ref, 'error_rate_limit');
    }

    // Server errors
    if (lowerError.contains('server error') ||
        lowerError.contains('internal server error') ||
        lowerError.contains('service unavailable') ||
        lowerError.contains('502') ||
        lowerError.contains('503') ||
        lowerError.contains('500')) {
      return LocalizationManager.translate(ref, 'error_server_unavailable');
    }

    // Email already exists
    if (lowerError.contains('email already registered') ||
        lowerError.contains('user already registered') ||
        lowerError.contains('email already exists')) {
      return LocalizationManager.translate(ref, 'error_email_already_exists');
    }

    // Weak password
    if (lowerError.contains('password') &&
        (lowerError.contains('weak') ||
            lowerError.contains('short') ||
            lowerError.contains('minimum'))) {
      return LocalizationManager.translate(ref, 'error_weak_password');
    }

    // Invalid email format
    if (lowerError.contains('invalid email') ||
        lowerError.contains('email format') ||
        lowerError.contains('malformed email')) {
      return LocalizationManager.translate(ref, 'error_invalid_email_format');
    }

    // Account deletion errors
    if (lowerError.contains('delete') && lowerError.contains('account')) {
      return LocalizationManager.translate(
        ref,
        'error_account_deletion_failed',
      );
    }

    // Default fallback
    AppLogger.warning('Unmapped auth error: $error', tag: 'ErrorHandler');
    return LocalizationManager.translate(ref, 'error_generic_auth');
  }

  /// Map general application errors to user-friendly messages
  static String getGeneralErrorMessage(String error, WidgetRef ref) {
    final String lowerError = error.toLowerCase();

    // Network errors
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('internet')) {
      return LocalizationManager.translate(ref, 'error_network_general');
    }

    // Data loading errors
    if (lowerError.contains('failed to load') ||
        lowerError.contains('data not found') ||
        lowerError.contains('loading failed')) {
      return LocalizationManager.translate(ref, 'error_data_loading');
    }

    // Save/update errors
    if (lowerError.contains('failed to save') ||
        lowerError.contains('update failed') ||
        lowerError.contains('save failed')) {
      return LocalizationManager.translate(ref, 'error_data_saving');
    }

    // Default fallback
    AppLogger.warning('Unmapped general error: $error', tag: 'ErrorHandler');
    return LocalizationManager.translate(ref, 'error_generic');
  }

  /// Show error dialog with user-friendly message
  static void showErrorDialog(
    BuildContext context,
    WidgetRef ref,
    String error, {
    String? title,
    String? actionText,
    VoidCallback? onAction,
    bool isAuthError = false,
  }) {
    final String userFriendlyMessage = isAuthError
        ? getAuthErrorMessage(error, ref)
        : getGeneralErrorMessage(error, ref);

    final String dialogTitle =
        title ?? LocalizationManager.translate(ref, 'error_dialog_title');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(width: AppConstants.paddingSmall),
            Text(dialogTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userFriendlyMessage, style: const TextStyle(fontSize: 16)),
            if (_getErrorSuggestion(error, ref).isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: Text(
                        _getErrorSuggestion(error, ref),
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (onAction != null && actionText != null)
            TextButton(onPressed: onAction, child: Text(actionText)),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationManager.translate(ref, 'ok')),
          ),
        ],
      ),
    );

    // Log the original error for debugging
    AppLogger.error(
      'Error shown to user: $userFriendlyMessage (Original: $error)',
      tag: 'ErrorHandler',
    );
  }

  /// Get helpful suggestions for specific errors
  static String _getErrorSuggestion(String error, WidgetRef ref) {
    final String lowerError = error.toLowerCase();

    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return LocalizationManager.translate(ref, 'suggestion_check_internet');
    }

    if (lowerError.contains('invalid_credentials') ||
        lowerError.contains('invalid login credentials')) {
      return LocalizationManager.translate(ref, 'suggestion_check_credentials');
    }

    if (lowerError.contains('email not confirmed')) {
      return LocalizationManager.translate(ref, 'suggestion_verify_email');
    }

    if (lowerError.contains('rate limit')) {
      return LocalizationManager.translate(ref, 'suggestion_wait_retry');
    }

    if (lowerError.contains('server') ||
        lowerError.contains('503') ||
        lowerError.contains('502')) {
      return LocalizationManager.translate(ref, 'suggestion_try_later');
    }

    return '';
  }

  /// Show success dialog
  static void showSuccessDialog(
    BuildContext context,
    WidgetRef ref,
    String message, {
    String? title,
    VoidCallback? onOk,
  }) {
    final String dialogTitle =
        title ?? LocalizationManager.translate(ref, 'success_dialog_title');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
            const SizedBox(width: AppConstants.paddingSmall),
            Text(dialogTitle),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onOk?.call();
            },
            child: Text(LocalizationManager.translate(ref, 'ok')),
          ),
        ],
      ),
    );
  }
}
