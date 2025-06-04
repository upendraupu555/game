import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';

/// Supabase authentication data source
/// Handles all Supabase authentication operations
abstract class SupabaseAuthDataSource {
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  });

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();

  User? getCurrentUser();

  Stream<AuthState> get authStateChanges;

  Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  });

  Future<void> resetPassword(String email);

  Future<void> resendEmailConfirmation(String email);

  bool get isAuthenticated;
}

/// Implementation of Supabase authentication data source
class SupabaseAuthDataSourceImpl implements SupabaseAuthDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.info(
        'Attempting to sign up user with email: $email',
        tag: 'SupabaseAuth',
      );

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );

      if (response.user != null) {
        AppLogger.info(
          'User signed up successfully: ${response.user!.id}',
          tag: 'SupabaseAuth',
        );
      } else {
        AppLogger.warning('Sign up response has no user', tag: 'SupabaseAuth');
      }

      return response;
    } catch (error) {
      AppLogger.error('Sign up failed', tag: 'SupabaseAuth', error: error);
      rethrow;
    }
  }

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info(
        'Attempting to sign in user with email: $email',
        tag: 'SupabaseAuth',
      );

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        AppLogger.info(
          'User signed in successfully: ${response.user!.id}',
          tag: 'SupabaseAuth',
        );
      } else {
        AppLogger.warning('Sign in response has no user', tag: 'SupabaseAuth');
      }

      return response;
    } catch (error) {
      AppLogger.error('Sign in failed', tag: 'SupabaseAuth', error: error);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      AppLogger.info('Attempting to sign out user', tag: 'SupabaseAuth');

      await _supabase.auth.signOut();

      AppLogger.info('User signed out successfully', tag: 'SupabaseAuth');
    } catch (error) {
      AppLogger.error('Sign out failed', tag: 'SupabaseAuth', error: error);
      rethrow;
    }
  }

  @override
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  @override
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  @override
  Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      AppLogger.info('Attempting to update user', tag: 'SupabaseAuth');

      final response = await _supabase.auth.updateUser(
        UserAttributes(email: email, password: password, data: data),
      );

      if (response.user != null) {
        AppLogger.info(
          'User updated successfully: ${response.user!.id}',
          tag: 'SupabaseAuth',
        );
      }

      return response;
    } catch (error) {
      AppLogger.error('User update failed', tag: 'SupabaseAuth', error: error);
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      AppLogger.info(
        'Attempting to reset password for email: $email',
        tag: 'SupabaseAuth',
      );

      await _supabase.auth.resetPasswordForEmail(email);

      AppLogger.info(
        'Password reset email sent successfully',
        tag: 'SupabaseAuth',
      );
    } catch (error) {
      AppLogger.error(
        'Password reset failed',
        tag: 'SupabaseAuth',
        error: error,
      );
      rethrow;
    }
  }

  @override
  Future<void> resendEmailConfirmation(String email) async {
    try {
      AppLogger.info(
        'Attempting to resend email confirmation for: $email',
        tag: 'SupabaseAuth',
      );

      await _supabase.auth.resend(type: OtpType.signup, email: email);

      AppLogger.info(
        'Email confirmation resent successfully',
        tag: 'SupabaseAuth',
      );
    } catch (error) {
      AppLogger.error(
        'Failed to resend email confirmation',
        tag: 'SupabaseAuth',
        error: error,
      );
      rethrow;
    }
  }

  @override
  bool get isAuthenticated {
    return _supabase.auth.currentUser != null;
  }
}

/// Exception for Supabase authentication operations
class SupabaseAuthException implements Exception {
  final String message;
  final String? code;

  const SupabaseAuthException(this.message, {this.code});

  @override
  String toString() =>
      'SupabaseAuthException: $message${code != null ? ' (Code: $code)' : ''}';
}
