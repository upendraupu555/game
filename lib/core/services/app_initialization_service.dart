import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/app_logger.dart';
import '../../presentation/providers/user_providers.dart';
import '../../presentation/providers/payment_providers.dart';

/// Service for handling app initialization tasks
/// Manages startup synchronization and data loading
class AppInitializationService {
  final Ref _ref;

  AppInitializationService(this._ref);

  /// Initialize app on startup
  /// Handles user authentication check and data synchronization
  Future<void> initializeApp() async {
    try {
      AppLogger.info(
        'Starting app initialization',
        tag: 'AppInitializationService',
      );

      // Initialize user first
      await _initializeUser();

      // Sync ad removal status for authenticated users
      await _syncAdRemovalStatus();

      AppLogger.info(
        'App initialization completed successfully',
        tag: 'AppInitializationService',
      );
    } catch (e) {
      AppLogger.error(
        'App initialization failed',
        tag: 'AppInitializationService',
        error: e,
      );
      // Don't rethrow - app should still start even if initialization fails
    }
  }

  /// Initialize user authentication state
  Future<void> _initializeUser() async {
    try {
      AppLogger.debug(
        'Initializing user authentication state',
        tag: 'AppInitializationService',
      );

      // The user provider will automatically initialize the user
      // We just need to trigger it by reading the provider
      final userNotifier = _ref.read(userProvider.notifier);
      await userNotifier.refreshUser();

      AppLogger.debug(
        'User authentication state initialized',
        tag: 'AppInitializationService',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to initialize user authentication state',
        tag: 'AppInitializationService',
        error: e,
      );
    }
  }

  /// Sync ad removal status from Supabase
  Future<void> _syncAdRemovalStatus() async {
    try {
      AppLogger.debug(
        'Syncing ad removal status from Supabase',
        tag: 'AppInitializationService',
      );

      // Get current user state
      final userState = _ref.read(userProvider);
      final user = userState.when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );

      // Only sync for authenticated users
      if (user != null && !user.isGuest && user.supabaseUserId != null) {
        final paymentNotifier = _ref.read(paymentProvider.notifier);
        await paymentNotifier.syncAdRemovalStatusFromSupabase();

        AppLogger.info(
          'Ad removal status synced from Supabase',
          tag: 'AppInitializationService',
          data: {'userId': user.supabaseUserId},
        );
      } else {
        AppLogger.debug(
          'Skipping ad removal status sync for guest user',
          tag: 'AppInitializationService',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Failed to sync ad removal status from Supabase',
        tag: 'AppInitializationService',
        error: e,
      );
    }
  }

  /// Handle user authentication change
  /// Called when user signs in or out
  Future<void> onUserAuthenticationChanged() async {
    try {
      AppLogger.info(
        'User authentication changed, syncing data',
        tag: 'AppInitializationService',
      );

      // Sync ad removal status for the new user state
      await _syncAdRemovalStatus();

      AppLogger.info(
        'User authentication change handling completed',
        tag: 'AppInitializationService',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to handle user authentication change',
        tag: 'AppInitializationService',
        error: e,
      );
    }
  }

  /// Retry failed initialization tasks
  Future<void> retryInitialization() async {
    try {
      AppLogger.info(
        'Retrying app initialization',
        tag: 'AppInitializationService',
      );

      await initializeApp();
    } catch (e) {
      AppLogger.error(
        'Retry initialization failed',
        tag: 'AppInitializationService',
        error: e,
      );
    }
  }

  /// Check if app is properly initialized
  bool isAppInitialized() {
    try {
      final userState = _ref.read(userProvider);
      final paymentState = _ref.read(paymentProvider);

      final userInitialized = userState.when(
        data: (_) => true,
        loading: () => false,
        error: (_, __) => false,
      );

      final paymentInitialized = !paymentState.isProcessing;

      return userInitialized && paymentInitialized;
    } catch (e) {
      AppLogger.error(
        'Failed to check app initialization status',
        tag: 'AppInitializationService',
        error: e,
      );
      return false;
    }
  }

  /// Get initialization status details
  Map<String, bool> getInitializationStatus() {
    try {
      final userState = _ref.read(userProvider);
      final paymentState = _ref.read(paymentProvider);

      return {
        'userInitialized': userState.when(
          data: (_) => true,
          loading: () => false,
          error: (_, __) => false,
        ),
        'paymentInitialized': !paymentState.isProcessing,
        'overallInitialized': isAppInitialized(),
      };
    } catch (e) {
      AppLogger.error(
        'Failed to get initialization status',
        tag: 'AppInitializationService',
        error: e,
      );
      return {
        'userInitialized': false,
        'paymentInitialized': false,
        'overallInitialized': false,
      };
    }
  }
}

/// Provider for app initialization service
final appInitializationServiceProvider = Provider<AppInitializationService>((
  ref,
) {
  return AppInitializationService(ref);
});

/// Provider for app initialization status
final appInitializationStatusProvider = Provider<bool>((ref) {
  final service = ref.watch(appInitializationServiceProvider);
  return service.isAppInitialized();
});

/// Provider for detailed initialization status
final detailedInitializationStatusProvider = Provider<Map<String, bool>>((ref) {
  final service = ref.watch(appInitializationServiceProvider);
  return service.getInitializationStatus();
});
