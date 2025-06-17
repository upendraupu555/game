import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_datasource.dart';
import '../datasources/supabase_auth_datasource.dart';
import '../models/user_model.dart';
import '../services/user_deletion_service.dart';
import '../../core/logging/app_logger.dart';

/// Implementation of user repository
/// Following clean architecture - data layer implements domain contracts
class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource _localDataSource;
  final SupabaseAuthDataSource _supabaseAuthDataSource;
  late final UserDeletionService _deletionService;

  UserRepositoryImpl(this._localDataSource, this._supabaseAuthDataSource) {
    // Initialize deletion service with Supabase client
    _deletionService = UserDeletionService(Supabase.instance.client);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await _localDataSource.getCurrentUser();
      return userModel?.toEntity();
    } catch (e) {
      // Log error in production
      return null;
    }
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _localDataSource.saveUser(userModel);
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  @override
  Future<UserEntity> createGuestUser() async {
    try {
      final gameId = generateGameId();
      final guestUser = UserEntity.guest(gameId);
      return guestUser;
    } catch (e) {
      throw Exception('Failed to create guest user: $e');
    }
  }

  @override
  Future<UserEntity?> authenticateUser({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info(
        'Attempting to authenticate user with email: $email',
        tag: 'UserRepository',
      );

      // Authenticate with Supabase
      final authResponse = await _supabaseAuthDataSource.signInWithEmail(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        final supabaseUser = authResponse.user!;
        AppLogger.info(
          'Supabase authentication successful for user: ${supabaseUser.id}',
          tag: 'UserRepository',
        );

        // Get current local user to preserve game data
        final currentLocalUser = await getCurrentUser();
        final gameId = currentLocalUser?.gameId ?? generateGameId();
        final username =
            supabaseUser.userMetadata?['username'] as String? ??
            supabaseUser.email?.split('@').first ??
            'user';

        // Create authenticated user entity
        final authenticatedUser = UserEntity.authenticated(
          username: username,
          gameId: gameId,
          email: supabaseUser.email!,
          supabaseUserId: supabaseUser.id,
        );

        // Save to local storage
        await saveUser(authenticatedUser);
        AppLogger.info(
          'User authenticated and saved locally: ${authenticatedUser.gameId}',
          tag: 'UserRepository',
        );

        return authenticatedUser;
      }

      AppLogger.warning(
        'Supabase authentication failed - no user returned',
        tag: 'UserRepository',
      );
      return null;
    } catch (e) {
      AppLogger.error('Authentication failed', tag: 'UserRepository', error: e);
      throw Exception('Authentication failed: $e');
    }
  }

  @override
  Future<UserEntity?> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info(
        'Attempting to register user with email: $email',
        tag: 'UserRepository',
      );

      // Register with Supabase
      final authResponse = await _supabaseAuthDataSource.signUpWithEmail(
        email: email,
        password: password,
        metadata: {'username': username},
      );

      if (authResponse.user != null) {
        final supabaseUser = authResponse.user!;
        AppLogger.info(
          'Supabase registration successful for user: ${supabaseUser.id}',
          tag: 'UserRepository',
        );

        // Get current local user to preserve game data
        final currentLocalUser = await getCurrentUser();
        final gameId = currentLocalUser?.gameId ?? generateGameId();

        // Create authenticated user entity
        final authenticatedUser = UserEntity.authenticated(
          username: username,
          gameId: gameId,
          email: supabaseUser.email!,
          supabaseUserId: supabaseUser.id,
        );

        // Save to local storage
        await saveUser(authenticatedUser);
        AppLogger.info(
          'User registered and saved locally: ${authenticatedUser.gameId}',
          tag: 'UserRepository',
        );

        return authenticatedUser;
      }

      AppLogger.warning(
        'Supabase registration failed - no user returned',
        tag: 'UserRepository',
      );
      return null;
    } catch (e) {
      AppLogger.error('Registration failed', tag: 'UserRepository', error: e);
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<UserEntity> logoutUser() async {
    try {
      AppLogger.info('Attempting to logout user', tag: 'UserRepository');

      final currentUser = await getCurrentUser();

      // Sign out from Supabase if user is authenticated
      if (currentUser?.isAuthenticated == true &&
          currentUser?.supabaseUserId != null) {
        await _supabaseAuthDataSource.signOut();
        AppLogger.info('User signed out from Supabase', tag: 'UserRepository');
      }

      // Clear all user data to fix persistence bug
      await clearAllUserData();
      AppLogger.info(
        'All user data cleared during logout',
        tag: 'UserRepository',
      );

      // Create new guest user with fresh data
      final guestUser = await createGuestUser();
      await saveUser(guestUser);
      AppLogger.info(
        'New guest user created after logout: ${guestUser.gameId}',
        tag: 'UserRepository',
      );
      return guestUser;
    } catch (e) {
      AppLogger.error('Logout failed', tag: 'UserRepository', error: e);
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    try {
      await saveUser(user);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<bool> userExists(String gameId) async {
    try {
      return await _localDataSource.userExists(gameId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteUser(String gameId) async {
    try {
      await _localDataSource.deleteUser(gameId);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  String generateGameId() {
    return _localDataSource.generateGameId();
  }

  @override
  bool isValidGameId(String gameId) {
    return _localDataSource.isValidGameId(gameId);
  }

  @override
  Future<UserEntity?> getUserByGameId(String gameId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser?.gameId == gameId) {
        return currentUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateLastLogin(String gameId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser?.gameId == gameId) {
        final updatedUser = currentUser!.updateLastLogin();
        await saveUser(updatedUser);
      }
    } catch (e) {
      throw Exception('Failed to update last login: $e');
    }
  }

  @override
  Future<void> resendEmailConfirmation(String email) async {
    try {
      AppLogger.info(
        'Resending email confirmation for: $email',
        tag: 'UserRepository',
      );

      await _supabaseAuthDataSource.resendEmailConfirmation(email);

      AppLogger.info(
        'Email confirmation resent successfully for: $email',
        tag: 'UserRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to resend email confirmation',
        tag: 'UserRepository',
        error: e,
      );
      throw Exception('Failed to resend email confirmation: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      AppLogger.info(
        'Requesting password reset for: $email',
        tag: 'UserRepository',
      );

      await _supabaseAuthDataSource.resetPassword(email);

      AppLogger.info(
        'Password reset email sent successfully for: $email',
        tag: 'UserRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to send password reset email',
        tag: 'UserRepository',
        error: e,
      );
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> clearAllUserData() async {
    try {
      await _localDataSource.clearAllUserData();
    } catch (e) {
      throw Exception('Failed to clear user data: $e');
    }
  }

  @override
  Future<void> deleteUserAccount() async {
    try {
      AppLogger.info(
        'Attempting complete user account deletion',
        tag: 'UserRepository',
      );

      final currentUser = await getCurrentUser();
      if (currentUser == null || !currentUser.isAuthenticated) {
        throw Exception('No authenticated user to delete');
      }

      // Use the enhanced deletion service for complete deletion
      final deletionSuccessful = await _deletionService.deleteUserAccount();

      if (!deletionSuccessful) {
        throw Exception('User deletion service reported failure');
      }

      AppLogger.info(
        'User account deleted successfully from Supabase',
        tag: 'UserRepository',
      );

      // Clear all local user data
      await clearAllUserData();
      AppLogger.info(
        'All local user data cleared after account deletion',
        tag: 'UserRepository',
      );

      AppLogger.info(
        'Complete user account deletion finished: ${currentUser.gameId}',
        tag: 'UserRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Complete account deletion failed',
        tag: 'UserRepository',
        error: e,
      );
      throw Exception('Account deletion failed: $e');
    }
  }
}
