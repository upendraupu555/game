import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

/// Use case for getting current user
class GetCurrentUserUseCase {
  final UserRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<UserEntity> execute() async {
    final user = await _repository.getCurrentUser();
    if (user != null) {
      return user;
    }

    // If no user exists, create a guest user
    return await _repository.createGuestUser();
  }
}

/// Use case for initializing user system
class InitializeUserSystemUseCase {
  final UserRepository _repository;

  InitializeUserSystemUseCase(this._repository);

  Future<UserEntity> execute() async {
    final existingUser = await _repository.getCurrentUser();
    if (existingUser != null) {
      // Update last login time for existing user
      await _repository.updateLastLogin(existingUser.gameId);
      return existingUser.updateLastLogin();
    }

    // Create new guest user if none exists
    final guestUser = await _repository.createGuestUser();
    await _repository.saveUser(guestUser);
    return guestUser;
  }
}

/// Use case for user authentication
class AuthenticateUserUseCase {
  final UserRepository _repository;

  AuthenticateUserUseCase(this._repository);

  Future<UserEntity?> execute({
    required String email,
    required String password,
  }) async {
    final authenticatedUser = await _repository.authenticateUser(
      email: email,
      password: password,
    );

    if (authenticatedUser != null) {
      await _repository.saveUser(authenticatedUser);
      await _repository.updateLastLogin(authenticatedUser.gameId);
    }

    return authenticatedUser;
  }
}

/// Use case for user registration
class RegisterUserUseCase {
  final UserRepository _repository;

  RegisterUserUseCase(this._repository);

  Future<UserEntity?> execute({
    required String username,
    required String email,
    required String password,
  }) async {
    final newUser = await _repository.registerUser(
      username: username,
      email: email,
      password: password,
    );

    if (newUser != null) {
      await _repository.saveUser(newUser);
    }

    return newUser;
  }
}

/// Use case for user logout
class LogoutUserUseCase {
  final UserRepository _repository;

  LogoutUserUseCase(this._repository);

  Future<UserEntity> execute() async {
    final guestUser = await _repository.logoutUser();
    await _repository.saveUser(guestUser);
    return guestUser;
  }
}

/// Use case for updating user profile
class UpdateUserProfileUseCase {
  final UserRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  Future<void> execute(UserEntity user) async {
    await _repository.updateUserProfile(user);
  }
}

/// Use case for checking if user is authenticated
class IsUserAuthenticatedUseCase {
  final UserRepository _repository;

  IsUserAuthenticatedUseCase(this._repository);

  Future<bool> execute() async {
    final user = await _repository.getCurrentUser();
    return user?.isAuthenticated ?? false;
  }
}

/// Use case for getting user display information
class GetUserDisplayInfoUseCase {
  final UserRepository _repository;

  GetUserDisplayInfoUseCase(this._repository);

  Future<Map<String, String>> execute() async {
    final user = await _repository.getCurrentUser();
    if (user == null) {
      return {
        'displayName': 'Guest User',
        'accountType': 'Guest',
        'gameId': 'Unknown',
      };
    }

    return {
      'displayName': user.displayName,
      'accountType': user.accountType,
      'gameId': user.gameId,
      'memberSince': user.formattedMemberSince,
      'lastLogin': user.formattedLastLogin,
      if (user.email != null) 'email': user.email!,
    };
  }
}

/// Use case for validating user session
class ValidateUserSessionUseCase {
  final UserRepository _repository;

  ValidateUserSessionUseCase(this._repository);

  Future<bool> execute() async {
    final user = await _repository.getCurrentUser();
    if (user == null) return false;

    // For now, all sessions are valid
    // In the future, this could check token expiration, etc.
    return true;
  }
}

/// Use case for converting guest to authenticated user
class ConvertGuestToAuthenticatedUseCase {
  final UserRepository _repository;

  ConvertGuestToAuthenticatedUseCase(this._repository);

  Future<UserEntity?> execute({
    required String username,
    required String email,
    required String password,
  }) async {
    final currentUser = await _repository.getCurrentUser();
    if (currentUser == null) return null;

    // Register the user with existing game ID
    final authenticatedUser = await _repository.registerUser(
      username: username,
      email: email,
      password: password,
    );

    if (authenticatedUser != null) {
      // Preserve the existing game ID
      final updatedUser = authenticatedUser.copyWith(
        gameId: currentUser.gameId,
      );
      await _repository.saveUser(updatedUser);
      return updatedUser;
    }

    return null;
  }
}

/// Use case for resending email confirmation
class ResendEmailConfirmationUseCase {
  final UserRepository _repository;

  ResendEmailConfirmationUseCase(this._repository);

  Future<void> execute(String email) async {
    await _repository.resendEmailConfirmation(email);
  }
}
