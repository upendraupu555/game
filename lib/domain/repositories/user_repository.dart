import '../entities/user_entity.dart';

/// Abstract repository interface for user data operations
/// Following clean architecture principles - domain layer defines the contract
abstract class UserRepository {
  /// Get current user
  Future<UserEntity?> getCurrentUser();

  /// Save user data
  Future<void> saveUser(UserEntity user);

  /// Create a new guest user
  Future<UserEntity> createGuestUser();

  /// Authenticate user with credentials
  Future<UserEntity?> authenticateUser({
    required String email,
    required String password,
  });

  /// Register new user
  Future<UserEntity?> registerUser({
    required String username,
    required String email,
    required String password,
  });

  /// Logout current user (convert to guest)
  Future<UserEntity> logoutUser();

  /// Update user profile
  Future<void> updateUserProfile(UserEntity user);

  /// Check if user exists
  Future<bool> userExists(String gameId);

  /// Delete user data
  Future<void> deleteUser(String gameId);

  /// Generate unique game ID
  String generateGameId();

  /// Validate game ID format
  bool isValidGameId(String gameId);

  /// Get user by game ID
  Future<UserEntity?> getUserByGameId(String gameId);

  /// Update last login time
  Future<void> updateLastLogin(String gameId);

  /// Resend email confirmation
  Future<void> resendEmailConfirmation(String email);

  /// Clear all user data
  Future<void> clearAllUserData();
}
