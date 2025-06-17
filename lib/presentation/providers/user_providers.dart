import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/user_usecases.dart';
import '../../data/datasources/user_local_datasource.dart';
import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../core/logging/app_logger.dart';
import '../../core/utils/auth_error_handler.dart';
import 'theme_providers.dart';

/// Provider for user local data source
final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserLocalDataSourceImpl(prefs);
});

/// Provider for Supabase auth data source
final supabaseAuthDataSourceProvider = Provider<SupabaseAuthDataSource>((ref) {
  return SupabaseAuthDataSourceImpl();
});

/// Provider for user repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final localDataSource = ref.watch(userLocalDataSourceProvider);
  final supabaseAuthDataSource = ref.watch(supabaseAuthDataSourceProvider);
  return UserRepositoryImpl(localDataSource, supabaseAuthDataSource);
});

/// Provider for Supabase auth state changes
final supabaseAuthStateProvider = StreamProvider((ref) {
  final supabaseAuthDataSource = ref.watch(supabaseAuthDataSourceProvider);
  return supabaseAuthDataSource.authStateChanges;
});

/// Provider for user use cases
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final initializeUserSystemUseCaseProvider =
    Provider<InitializeUserSystemUseCase>((ref) {
      final repository = ref.watch(userRepositoryProvider);
      return InitializeUserSystemUseCase(repository);
    });

final authenticateUserUseCaseProvider = Provider<AuthenticateUserUseCase>((
  ref,
) {
  final repository = ref.watch(userRepositoryProvider);
  return AuthenticateUserUseCase(repository);
});

final registerUserUseCaseProvider = Provider<RegisterUserUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return RegisterUserUseCase(repository);
});

final resendEmailConfirmationUseCaseProvider =
    Provider<ResendEmailConfirmationUseCase>((ref) {
      final repository = ref.watch(userRepositoryProvider);
      return ResendEmailConfirmationUseCase(repository);
    });

final logoutUserUseCaseProvider = Provider<LogoutUserUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return LogoutUserUseCase(repository);
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((
  ref,
) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateUserProfileUseCase(repository);
});

final isUserAuthenticatedUseCaseProvider = Provider<IsUserAuthenticatedUseCase>(
  (ref) {
    final repository = ref.watch(userRepositoryProvider);
    return IsUserAuthenticatedUseCase(repository);
  },
);

final getUserDisplayInfoUseCaseProvider = Provider<GetUserDisplayInfoUseCase>((
  ref,
) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUserDisplayInfoUseCase(repository);
});

/// Provider for delete user account use case
final deleteUserAccountUseCaseProvider = Provider<DeleteUserAccountUseCase>((
  ref,
) {
  final repository = ref.watch(userRepositoryProvider);
  return DeleteUserAccountUseCase(repository);
});

/// State notifier for user management
class UserNotifier extends StateNotifier<AsyncValue<UserEntity>> {
  final Ref _ref;

  UserNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initializeUser();
    _listenToAuthStateChanges();
  }

  Future<void> _initializeUser() async {
    try {
      AppLogger.info('Initializing user system...', tag: 'UserNotifier');

      final initializeUseCase = _ref.read(initializeUserSystemUseCaseProvider);
      final user = await initializeUseCase.execute();

      state = AsyncValue.data(user);
      AppLogger.info(
        'User system initialized: ${user.displayName} (${user.gameId})',
        tag: 'UserNotifier',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to initialize user system',
        tag: 'UserNotifier',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _listenToAuthStateChanges() {
    _ref.listen(supabaseAuthStateProvider, (previous, next) {
      next.when(
        data: (authState) {
          AppLogger.info(
            'Supabase auth state changed: ${authState.event}',
            tag: 'UserNotifier',
          );

          // Handle auth state changes
          switch (authState.event) {
            case AuthChangeEvent.signedIn:
              _handleSignedIn(authState);
              break;
            case AuthChangeEvent.signedOut:
              _handleSignedOut();
              break;
            case AuthChangeEvent.userUpdated:
              _handleUserUpdated(authState);
              break;
            default:
              break;
          }
        },
        loading: () {
          AppLogger.info('Auth state loading...', tag: 'UserNotifier');
        },
        error: (error, stackTrace) {
          AppLogger.error(
            'Auth state error',
            tag: 'UserNotifier',
            error: error,
          );
        },
      );
    });
  }

  Future<void> _handleSignedIn(AuthState authState) async {
    try {
      if (authState.session?.user != null) {
        final supabaseUser = authState.session!.user;
        AppLogger.info(
          'Handling signed in user: ${supabaseUser.id}',
          tag: 'UserNotifier',
        );

        // Get current local user to preserve game data
        final repository = _ref.read(userRepositoryProvider);
        final currentLocalUser = await repository.getCurrentUser();
        final gameId = currentLocalUser?.gameId ?? repository.generateGameId();
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
        await repository.saveUser(authenticatedUser);
        state = AsyncValue.data(authenticatedUser);

        AppLogger.info(
          'User signed in and synced: ${authenticatedUser.gameId}',
          tag: 'UserNotifier',
        );
      }
    } catch (error) {
      AppLogger.error(
        'Failed to handle signed in user',
        tag: 'UserNotifier',
        error: error,
      );
    }
  }

  Future<void> _handleSignedOut() async {
    try {
      AppLogger.info('Handling signed out user', tag: 'UserNotifier');

      final repository = _ref.read(userRepositoryProvider);
      final currentUser = await repository.getCurrentUser();

      if (currentUser != null) {
        // Convert to guest user but keep the same game ID
        final guestUser = currentUser.toGuest();
        await repository.saveUser(guestUser);
        state = AsyncValue.data(guestUser);

        AppLogger.info(
          'User signed out and converted to guest: ${guestUser.gameId}',
          tag: 'UserNotifier',
        );
      }
    } catch (error) {
      AppLogger.error(
        'Failed to handle signed out user',
        tag: 'UserNotifier',
        error: error,
      );
    }
  }

  Future<void> _handleUserUpdated(AuthState authState) async {
    try {
      if (authState.session?.user != null) {
        final supabaseUser = authState.session!.user;
        AppLogger.info(
          'Handling updated user: ${supabaseUser.id}',
          tag: 'UserNotifier',
        );

        // Update current user with new information
        final currentState = state;
        if (currentState is AsyncData<UserEntity>) {
          final currentUser = currentState.value;
          final updatedUser = currentUser.copyWith(
            email: supabaseUser.email,
            username:
                supabaseUser.userMetadata?['username'] as String? ??
                currentUser.username,
          );

          final repository = _ref.read(userRepositoryProvider);
          await repository.saveUser(updatedUser);
          state = AsyncValue.data(updatedUser);

          AppLogger.info(
            'User updated and synced: ${updatedUser.gameId}',
            tag: 'UserNotifier',
          );
        }
      }
    } catch (error) {
      AppLogger.error(
        'Failed to handle updated user',
        tag: 'UserNotifier',
        error: error,
      );
    }
  }

  Future<void> authenticateUser({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();

      final authenticateUseCase = _ref.read(authenticateUserUseCaseProvider);
      final authenticatedUser = await authenticateUseCase.execute(
        email: email,
        password: password,
      );

      if (authenticatedUser != null) {
        state = AsyncValue.data(authenticatedUser);
        AppLogger.info(
          'User authenticated: ${authenticatedUser.displayName}',
          tag: 'UserNotifier',
        );

        // Sync ad removal status from Supabase for authenticated users
        _syncAdRemovalStatusAfterAuth();
      } else {
        throw Exception('Authentication failed');
      }
    } catch (error, stackTrace) {
      // Log the error with context
      AuthErrorHandler.logAuthError(
        error,
        context: 'user_authentication',
        additionalData: {'email': email},
      );

      // Set error state with enhanced error information
      final enhancedError = _createEnhancedAuthError(error, email);
      state = AsyncValue.error(enhancedError, stackTrace);
    }
  }

  /// Create enhanced authentication error with email context
  AuthenticationError _createEnhancedAuthError(
    dynamic originalError,
    String email,
  ) {
    return AuthenticationError(
      originalError: originalError,
      email: email,
      isEmailNotConfirmed: AuthErrorHandler.isEmailNotConfirmedError(
        originalError,
      ),
      userFriendlyMessage: AuthErrorHandler.getUserFriendlyErrorMessage(
        originalError,
      ),
      suggestedAction: AuthErrorHandler.getSuggestedAction(originalError),
      isRecoverable: AuthErrorHandler.isRecoverableError(originalError),
    );
  }

  Future<void> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();

      final registerUseCase = _ref.read(registerUserUseCaseProvider);
      final newUser = await registerUseCase.execute(
        username: username,
        email: email,
        password: password,
      );

      if (newUser != null) {
        state = AsyncValue.data(newUser);
        AppLogger.info(
          'User registered: ${newUser.displayName}',
          tag: 'UserNotifier',
        );
      } else {
        throw Exception('Registration failed');
      }
    } catch (error, stackTrace) {
      // Log the error with context
      AuthErrorHandler.logAuthError(
        error,
        context: 'user_registration',
        additionalData: {'email': email, 'username': username},
      );

      // Set error state with enhanced error information
      final enhancedError = _createEnhancedAuthError(error, email);
      state = AsyncValue.error(enhancedError, stackTrace);
    }
  }

  Future<void> logoutUser() async {
    try {
      final logoutUseCase = _ref.read(logoutUserUseCaseProvider);
      final guestUser = await logoutUseCase.execute();

      state = AsyncValue.data(guestUser);
      AppLogger.info(
        'User logged out, converted to guest',
        tag: 'UserNotifier',
      );
    } catch (error, stackTrace) {
      AppLogger.error('Logout failed', tag: 'UserNotifier', error: error);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteUserAccount() async {
    try {
      final deleteAccountUseCase = _ref.read(deleteUserAccountUseCaseProvider);
      await deleteAccountUseCase.execute();

      // Create new guest user after account deletion
      final repository = _ref.read(userRepositoryProvider);
      final guestUser = await repository.createGuestUser();
      await repository.saveUser(guestUser);

      state = AsyncValue.data(guestUser);
      AppLogger.info(
        'User account deleted, converted to guest',
        tag: 'UserNotifier',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Account deletion failed',
        tag: 'UserNotifier',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProfile(UserEntity updatedUser) async {
    try {
      final updateUseCase = _ref.read(updateUserProfileUseCaseProvider);
      await updateUseCase.execute(updatedUser);

      state = AsyncValue.data(updatedUser);
      AppLogger.info(
        'User profile updated: ${updatedUser.displayName}',
        tag: 'UserNotifier',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Profile update failed',
        tag: 'UserNotifier',
        error: error,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshUser() async {
    await _initializeUser();
  }

  /// Sync ad removal status from Supabase after authentication
  void _syncAdRemovalStatusAfterAuth() {
    // Run sync in background without blocking authentication
    Future.microtask(() async {
      try {
        // We need to access payment providers, but we can't import them directly
        // due to circular dependency. Instead, we'll trigger the sync through
        // a different mechanism or use a callback approach.
        AppLogger.info(
          'Triggering ad removal status sync after authentication',
          tag: 'UserNotifier',
        );

        // For now, we'll just log that sync should happen
        // The actual sync will be triggered by the app initialization logic
      } catch (e) {
        AppLogger.error(
          'Failed to trigger ad removal status sync after authentication',
          tag: 'UserNotifier',
          error: e,
        );
      }
    });
  }

  /// Reset password for user
  Future<void> resetPassword(String email) async {
    try {
      AppLogger.info(
        'Requesting password reset for email: $email',
        tag: 'UserNotifier',
      );

      final userRepository = _ref.read(userRepositoryProvider);
      await userRepository.resetPassword(email);

      AppLogger.info(
        'Password reset email sent successfully',
        tag: 'UserNotifier',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to send password reset email',
        tag: 'UserNotifier',
        error: e,
      );
      rethrow;
    }
  }
}

/// Provider for user state notifier
final userProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<UserEntity>>((ref) {
      return UserNotifier(ref);
    });

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userState = ref.watch(userProvider);
  return userState.when(
    data: (user) => user.isAuthenticated,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for current user display info
final userDisplayInfoProvider = FutureProvider<Map<String, String>>((
  ref,
) async {
  final getUserDisplayInfoUseCase = ref.watch(
    getUserDisplayInfoUseCaseProvider,
  );
  return await getUserDisplayInfoUseCase.execute();
});
