import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../logging/app_logger.dart';
import '../localization/localization_manager.dart';
import '../../presentation/widgets/email_confirmation_dialog.dart';
import 'error_handler.dart';

/// Utility class for handling authentication errors
/// Provides centralized error handling for Supabase authentication
class AuthErrorHandler {
  AuthErrorHandler._();

  /// Check if error is an email confirmation error
  static bool isEmailNotConfirmedError(dynamic error) {
    if (error is AuthApiException) {
      return error.code == 'email_not_confirmed' ||
          error.message.toLowerCase().contains('email not confirmed');
    }

    if (error is Exception) {
      final errorString = error.toString().toLowerCase();
      return errorString.contains('email not confirmed') ||
          errorString.contains('email_not_confirmed');
    }

    return false;
  }

  /// Extract email from authentication error context
  static String? extractEmailFromError(dynamic error, String? fallbackEmail) {
    // Try to extract email from error message if available
    if (error is AuthApiException && error.message.isNotEmpty) {
      // Log the error for debugging
      AppLogger.debug(
        'Extracting email from auth error',
        tag: 'AuthErrorHandler',
        data: {
          'errorCode': error.code,
          'errorMessage': error.message,
          'fallbackEmail': fallbackEmail,
        },
      );
    }

    // Return fallback email if provided
    return fallbackEmail;
  }

  /// Handle email confirmation error
  /// Returns true if error was handled, false otherwise
  static Future<bool> handleEmailConfirmationError(
    BuildContext context,
    WidgetRef ref,
    dynamic error, {
    String? email,
  }) async {
    if (!isEmailNotConfirmedError(error)) {
      return false;
    }

    AppLogger.warning(
      'Email confirmation error detected',
      tag: 'AuthErrorHandler',
      data: {'error': error.toString(), 'email': email ?? 'unknown'},
    );

    final extractedEmail = extractEmailFromError(error, email);
    if (extractedEmail == null || extractedEmail.isEmpty) {
      AppLogger.error(
        'Cannot handle email confirmation error: no email available',
        tag: 'AuthErrorHandler',
      );
      return false;
    }

    // Show email confirmation dialog
    final result = await showEmailConfirmationDialog(
      context,
      email: extractedEmail,
      errorMessage: _getErrorMessage(error),
    );

    AppLogger.info(
      'Email confirmation dialog result',
      tag: 'AuthErrorHandler',
      data: {'result': result, 'email': extractedEmail},
    );

    return result == true;
  }

  /// Get user-friendly error message from authentication error
  static String _getErrorMessage(dynamic error) {
    if (error is AuthApiException) {
      switch (error.code) {
        case 'email_not_confirmed':
          return 'Your email address needs to be confirmed before you can sign in.';
        case 'invalid_credentials':
          return 'Invalid email or password. Please check your credentials.';
        case 'too_many_requests':
          return 'Too many login attempts. Please wait a moment and try again.';
        case 'user_not_found':
          return 'No account found with this email address.';
        case 'weak_password':
          return 'Password is too weak. Please choose a stronger password.';
        case 'email_address_invalid':
          return 'Please enter a valid email address.';
        default:
          return error.message.isNotEmpty
              ? error.message
              : 'Authentication failed. Please try again.';
      }
    }

    if (error is Exception) {
      final errorString = error.toString();
      if (errorString.contains('email not confirmed')) {
        return 'Your email address needs to be confirmed before you can sign in.';
      }
      return errorString;
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Get user-friendly error message for UI display
  static String getUserFriendlyErrorMessage(dynamic error) {
    return _getErrorMessage(error);
  }

  /// Check if error requires user action (like email confirmation)
  static bool requiresUserAction(dynamic error) {
    return isEmailNotConfirmedError(error);
  }

  /// Log authentication error with appropriate level
  static void logAuthError(
    dynamic error, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final data = <String, dynamic>{
      'context': context ?? 'authentication',
      ...?additionalData,
    };

    if (isEmailNotConfirmedError(error)) {
      AppLogger.warning(
        'Email confirmation required: ${data.toString()}',
        tag: 'AuthErrorHandler',
        data: data,
      );
    } else if (error is AuthApiException) {
      AppLogger.error(
        'Supabase authentication error: ${error.code} - Context: ${data.toString()}',
        tag: 'AuthErrorHandler',
        error: error,
      );
    } else {
      AppLogger.error(
        'Authentication error - Context: ${data.toString()}',
        tag: 'AuthErrorHandler',
        error: error,
      );
    }
  }

  /// Check if error is recoverable (user can retry)
  static bool isRecoverableError(dynamic error) {
    if (error is AuthApiException) {
      switch (error.code) {
        case 'email_not_confirmed':
        case 'too_many_requests':
        case 'network_error':
          return true;
        case 'invalid_credentials':
        case 'user_not_found':
        case 'email_address_invalid':
          return false;
        default:
          return true; // Assume recoverable by default
      }
    }

    return true; // Assume recoverable for unknown errors
  }

  /// Get suggested action for the user based on error type
  static String getSuggestedAction(dynamic error) {
    if (isEmailNotConfirmedError(error)) {
      return 'Please check your email and click the confirmation link, or request a new confirmation email.';
    }

    if (error is AuthApiException) {
      switch (error.code) {
        case 'invalid_credentials':
          return 'Please check your email and password and try again.';
        case 'too_many_requests':
          return 'Please wait a few minutes before trying again.';
        case 'user_not_found':
          return 'Please check your email address or create a new account.';
        case 'weak_password':
          return 'Please choose a stronger password with at least 8 characters.';
        case 'email_address_invalid':
          return 'Please enter a valid email address.';
        default:
          return 'Please try again or contact support if the problem persists.';
      }
    }

    return 'Please try again or contact support if the problem persists.';
  }

  /// Show authentication error dialog with user-friendly message
  static void showAuthErrorDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic error, {
    String? email,
    VoidCallback? onRetry,
  }) {
    // First try to handle email confirmation error
    if (isEmailNotConfirmedError(error)) {
      handleEmailConfirmationError(context, ref, error, email: email);
      return;
    }

    // Use the centralized error handler for other auth errors
    ErrorHandler.showErrorDialog(
      context,
      ref,
      error.toString(),
      title: LocalizationManager.translate(ref, 'error_dialog_title'),
      actionText: onRetry != null
          ? LocalizationManager.translate(ref, 'retry')
          : null,
      onAction: onRetry,
      isAuthError: true,
    );

    // Log the error
    logAuthError(error, context: 'login_screen');
  }
}

/// Enhanced authentication error with additional context
class AuthenticationError implements Exception {
  final dynamic originalError;
  final String email;
  final bool isEmailNotConfirmed;
  final String userFriendlyMessage;
  final String suggestedAction;
  final bool isRecoverable;

  const AuthenticationError({
    required this.originalError,
    required this.email,
    required this.isEmailNotConfirmed,
    required this.userFriendlyMessage,
    required this.suggestedAction,
    required this.isRecoverable,
  });

  @override
  String toString() {
    return 'AuthenticationError: $userFriendlyMessage (Email: $email, EmailNotConfirmed: $isEmailNotConfirmed)';
  }
}
