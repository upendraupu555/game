import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<void> deleteUser();

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
  Future<void> deleteUser() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user to delete');
      }

      AppLogger.info(
        'Attempting complete user account deletion: ${currentUser.id}',
        tag: 'SupabaseAuth',
      );

      // Try complete deletion first (includes auth user deletion)
      try {
        final response = await _supabase.rpc('delete_user_account_complete');

        AppLogger.info(
          'Complete user deletion response: $response',
          tag: 'SupabaseAuth',
        );

        if (response != null && response['success'] == true) {
          AppLogger.info(
            'User account completely deleted including auth record',
            tag: 'SupabaseAuth',
          );
          return;
        } else {
          AppLogger.warning(
            'Complete deletion failed: ${response?['message']}',
            tag: 'SupabaseAuth',
          );

          // Fall back to marking for deletion + admin API
          await _deleteUserWithAdminAPI(currentUser);
        }
      } catch (e) {
        AppLogger.warning(
          'Complete deletion function failed: $e',
          tag: 'SupabaseAuth',
        );

        // Fall back to marking for deletion + admin API
        await _deleteUserWithAdminAPI(currentUser);
      }
    } catch (error) {
      AppLogger.error(
        'User account deletion failed completely',
        tag: 'SupabaseAuth',
        error: error,
      );
      rethrow;
    }
  }

  /// Delete user using admin API approach
  Future<void> _deleteUserWithAdminAPI(User currentUser) async {
    AppLogger.info(
      'Attempting user deletion with admin API approach',
      tag: 'SupabaseAuth',
    );

    try {
      // Step 1: Mark user for deletion (deletes app data)
      final markResponse = await _supabase.rpc('mark_user_for_deletion');

      if (markResponse == null || markResponse['success'] != true) {
        throw Exception(
          'Failed to mark user for deletion: ${markResponse?['message']}',
        );
      }

      AppLogger.info(
        'User marked for deletion, app data removed',
        tag: 'SupabaseAuth',
      );

      // Step 2: Use Supabase Admin API to delete auth user
      try {
        await _deleteAuthUserViaAPI(currentUser.id);

        AppLogger.info(
          'Auth user deleted successfully via admin API',
          tag: 'SupabaseAuth',
        );
      } catch (adminError) {
        AppLogger.error(
          'Admin API deletion failed, user data deleted but auth record remains',
          tag: 'SupabaseAuth',
          error: adminError,
        );

        // Even if admin API fails, app data is deleted
        // The user will need manual cleanup of auth record
        throw Exception(
          'Account data deleted but authentication record could not be removed. '
          'Please contact support for complete account deletion.',
        );
      }
    } catch (error) {
      AppLogger.error(
        'Admin API deletion approach failed',
        tag: 'SupabaseAuth',
        error: error,
      );
      rethrow;
    }
  }

  /// Delete auth user via Supabase Admin API
  Future<void> _deleteAuthUserViaAPI(String userId) async {
    try {
      // Note: This requires a server-side endpoint or admin privileges
      // For now, we'll use the client library's admin methods if available

      // Option 1: If you have admin privileges configured
      await _supabase.auth.admin.deleteUser(userId);

      AppLogger.info(
        'Successfully deleted auth user via admin API',
        tag: 'SupabaseAuth',
      );
    } catch (error) {
      AppLogger.error(
        'Failed to delete auth user via admin API',
        tag: 'SupabaseAuth',
        error: error,
      );

      // If admin API is not available, we need to handle this differently
      if (error.toString().contains('admin') ||
          error.toString().contains('permission')) {
        throw Exception(
          'Admin privileges required for complete account deletion. '
          'App data has been deleted but authentication record remains.',
        );
      }

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
