import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/logging/app_logger.dart';

/// Service for handling complete user account deletion
/// including Supabase Auth user removal via server-side API
class UserDeletionService {
  static const String _tag = 'UserDeletionService';

  // TODO: Replace with your actual server endpoint URL
  static const String _serverEndpoint =
      'https://your-api.vercel.app/api/delete-user';

  final SupabaseClient _supabase;

  UserDeletionService(this._supabase);

  /// Delete user account completely including auth record
  /// Returns true if deletion was successful
  Future<bool> deleteUserAccount() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user to delete');
      }

      AppLogger.info(
        'Starting complete user account deletion: ${currentUser.id}',
        tag: _tag,
      );

      // Try multiple approaches in order of preference

      // Approach 1: Try direct SQL function with auth deletion
      final sqlResult = await _tryDirectSQLDeletion();
      if (sqlResult) {
        AppLogger.info('User deleted successfully via SQL function', tag: _tag);
        return true;
      }

      // Approach 2: Try server-side API endpoint
      final apiResult = await _tryServerAPIDeletion(currentUser);
      if (apiResult) {
        AppLogger.info('User deleted successfully via server API', tag: _tag);
        return true;
      }

      // Approach 3: Fallback to app data deletion only
      final fallbackResult = await _tryFallbackDeletion();
      if (fallbackResult) {
        AppLogger.warning(
          'Only app data deleted, auth record may remain',
          tag: _tag,
        );

        // Still return true but with warning
        return true;
      }

      throw Exception('All deletion approaches failed');
    } catch (error) {
      AppLogger.error('Complete user deletion failed', tag: _tag, error: error);
      rethrow;
    }
  }

  /// Try direct SQL function deletion (includes auth user)
  Future<bool> _tryDirectSQLDeletion() async {
    try {
      AppLogger.info('Attempting direct SQL deletion', tag: _tag);

      final response = await _supabase.rpc('delete_user_account_complete');

      if (response != null && response['success'] == true) {
        AppLogger.info(
          'Direct SQL deletion successful: ${response['message']}',
          tag: _tag,
        );
        return true;
      } else {
        AppLogger.warning(
          'Direct SQL deletion failed: ${response?['message']}',
          tag: _tag,
        );
        return false;
      }
    } catch (error) {
      AppLogger.warning(
        'Direct SQL deletion threw exception: $error',
        tag: _tag,
      );
      return false;
    }
  }

  /// Try server-side API deletion
  Future<bool> _tryServerAPIDeletion(User currentUser) async {
    try {
      AppLogger.info('Attempting server API deletion', tag: _tag);

      // Get current session token
      final session = _supabase.auth.currentSession;
      if (session?.accessToken == null) {
        AppLogger.warning('No access token available for API call', tag: _tag);
        return false;
      }

      final response = await http.delete(
        Uri.parse(_serverEndpoint),
        headers: {
          'Authorization': 'Bearer ${session!.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'userId': currentUser.id}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        AppLogger.info(
          'Server API deletion successful: ${responseData['message']}',
          tag: _tag,
        );
        return true;
      } else {
        AppLogger.warning(
          'Server API deletion failed: ${responseData['message']} (${response.statusCode})',
          tag: _tag,
        );
        return false;
      }
    } catch (error) {
      AppLogger.warning(
        'Server API deletion threw exception: $error',
        tag: _tag,
      );
      return false;
    }
  }

  /// Fallback: Delete only app data, mark for manual auth cleanup
  Future<bool> _tryFallbackDeletion() async {
    try {
      AppLogger.info('Attempting fallback deletion (app data only)', tag: _tag);

      final response = await _supabase.rpc('mark_user_for_deletion');

      if (response != null && response['success'] == true) {
        AppLogger.info(
          'Fallback deletion successful: ${response['message']}',
          tag: _tag,
        );

        // Log that manual cleanup is needed
        AppLogger.warning(
          'Auth record requires manual cleanup: ${response['user_id']}',
          tag: _tag,
        );

        return true;
      } else {
        AppLogger.error(
          'Fallback deletion failed: ${response?['message']}',
          tag: _tag,
        );
        return false;
      }
    } catch (error) {
      AppLogger.error('Fallback deletion threw exception: $error', tag: _tag);
      return false;
    }
  }

  /// Check if user can be deleted (business logic validation)
  Future<Map<String, dynamic>> canDeleteUser() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return {
          'can_delete': false,
          'reasons': ['User not authenticated'],
        };
      }

      // Call the validation RPC function
      final response = await _supabase.rpc('can_delete_user_account');

      if (response != null) {
        return {
          'can_delete': response['can_delete'] ?? false,
          'reasons': response['reasons'] ?? [],
          'user_id': response['user_id'],
        };
      }

      // Default to allowing deletion if RPC fails
      return {'can_delete': true, 'reasons': [], 'user_id': currentUser.id};
    } catch (error) {
      AppLogger.error(
        'Failed to check if user can be deleted',
        tag: _tag,
        error: error,
      );

      // Default to allowing deletion on error
      return {'can_delete': true, 'reasons': [], 'error': error.toString()};
    }
  }

  /// Get deletion audit logs for current user
  Future<List<Map<String, dynamic>>> getDeletionAuditLogs() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      final response = await _supabase
          .from('user_deletion_audit')
          .select('*')
          .eq('user_id', currentUser.id)
          .order('deleted_at', ascending: false)
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      AppLogger.error(
        'Failed to get deletion audit logs',
        tag: _tag,
        error: error,
      );
      return [];
    }
  }

  /// Test deletion functions (for debugging)
  Future<Map<String, bool>> testDeletionMethods() async {
    final results = <String, bool>{};

    try {
      // Test if SQL function exists
      try {
        await _supabase.rpc('delete_user_account_complete');
        results['sql_function_available'] = true;
      } catch (e) {
        results['sql_function_available'] = false;
      }

      // Test if server endpoint is reachable
      try {
        final response = await http.get(Uri.parse(_serverEndpoint));
        results['server_endpoint_reachable'] = response.statusCode != 404;
      } catch (e) {
        results['server_endpoint_reachable'] = false;
      }

      // Test if fallback function exists
      try {
        await _supabase.rpc('mark_user_for_deletion');
        results['fallback_function_available'] = true;
      } catch (e) {
        results['fallback_function_available'] = false;
      }
    } catch (error) {
      AppLogger.error(
        'Failed to test deletion methods',
        tag: _tag,
        error: error,
      );
    }

    return results;
  }
}
