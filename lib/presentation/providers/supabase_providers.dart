import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:game/data/repositories/supabase_leaderboard_repository.dart';
import 'package:game/data/repositories/supabase_statistics_repository.dart';
import 'package:game/data/repositories/hybrid_leaderboard_repository.dart';
import 'package:game/data/repositories/hybrid_statistics_repository.dart';
import 'package:game/data/services/supabase_sync_service.dart';
import 'package:game/data/models/sync_status_model.dart';
import 'package:game/presentation/providers/theme_providers.dart';
import 'package:game/presentation/providers/leaderboard_providers.dart';

import 'package:game/presentation/providers/game_providers.dart';
import 'package:game/core/logging/app_logger.dart';
import 'package:game/core/constants/app_constants.dart';

/// Provider for Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for current user ID (authenticated user)
final currentUserIdProvider = Provider<String?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.currentUser?.id;
});

/// Provider for guest user ID (16-digit UUID for guest users)
final guestUserIdProvider = FutureProvider<String?>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString(AppConstants.currentUserIdKey);
});

/// Provider for Supabase leaderboard repository
final supabaseLeaderboardRepositoryProvider =
    Provider<SupabaseLeaderboardRepository>((ref) {
      final supabase = ref.watch(supabaseClientProvider);
      final userId = ref.watch(currentUserIdProvider);
      final guestIdAsync = ref.watch(guestUserIdProvider);

      return guestIdAsync.when(
        data: (guestId) => SupabaseLeaderboardRepository(
          supabase: supabase,
          userId: userId,
          guestId: guestId,
        ),
        loading: () => throw Exception('Guest ID not loaded'),
        error: (error, stack) =>
            throw Exception('Failed to load guest ID: $error'),
      );
    });

/// Provider for Supabase statistics repository
final supabaseStatisticsRepositoryProvider =
    Provider<SupabaseStatisticsRepository>((ref) {
      final supabase = ref.watch(supabaseClientProvider);
      final userId = ref.watch(currentUserIdProvider);
      final guestIdAsync = ref.watch(guestUserIdProvider);

      return guestIdAsync.when(
        data: (guestId) => SupabaseStatisticsRepository(
          supabase: supabase,
          userId: userId,
          guestId: guestId,
        ),
        loading: () => throw Exception('Guest ID not loaded'),
        error: (error, stack) =>
            throw Exception('Failed to load guest ID: $error'),
      );
    });

/// Provider for Supabase sync service
final supabaseSyncServiceProvider = Provider<SupabaseSyncService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  final guestIdAsync = ref.watch(guestUserIdProvider);
  final localLeaderboard = ref.watch(leaderboardRepositoryProvider);
  final localStatistics = ref.watch(gameRepositoryProvider);
  final remoteLeaderboard = ref.watch(supabaseLeaderboardRepositoryProvider);
  final remoteStatistics = ref.watch(supabaseStatisticsRepositoryProvider);

  return guestIdAsync.when(
    data: (guestId) => SupabaseSyncService(
      supabase: supabase,
      localLeaderboard: localLeaderboard,
      localStatistics: localStatistics,
      remoteLeaderboard: remoteLeaderboard,
      remoteStatistics: remoteStatistics,
      userId: userId,
      guestId: guestId,
    ),
    loading: () => throw Exception('Guest ID not loaded'),
    error: (error, stack) => throw Exception('Failed to load guest ID: $error'),
  );
});

/// Provider for hybrid leaderboard repository
final hybridLeaderboardRepositoryProvider =
    Provider<HybridLeaderboardRepository>((ref) {
      final localRepository = ref.watch(leaderboardRepositoryProvider);
      final remoteRepository = ref.watch(supabaseLeaderboardRepositoryProvider);
      final syncService = ref.watch(supabaseSyncServiceProvider);

      return HybridLeaderboardRepository(
        localRepository: localRepository,
        remoteRepository: remoteRepository,
        syncService: syncService,
      );
    });

/// Provider for hybrid statistics repository
final hybridStatisticsRepositoryProvider = Provider<HybridStatisticsRepository>(
  (ref) {
    final localRepository = ref.watch(gameRepositoryProvider);
    final remoteRepository = ref.watch(supabaseStatisticsRepositoryProvider);
    final syncService = ref.watch(supabaseSyncServiceProvider);

    return HybridStatisticsRepository(
      localRepository: localRepository,
      remoteRepository: remoteRepository,
      syncService: syncService,
    );
  },
);

/// Provider for sync status stream
final syncStatusStreamProvider = StreamProvider<OverallSyncStatus>((ref) {
  final syncService = ref.watch(supabaseSyncServiceProvider);
  return syncService.syncStatusStream;
});

/// Provider for current sync status
final currentSyncStatusProvider = Provider<AsyncValue<OverallSyncStatus>>((
  ref,
) {
  return ref.watch(syncStatusStreamProvider);
});

/// Provider for online status
final onlineStatusProvider = FutureProvider<bool>((ref) async {
  final syncService = ref.watch(supabaseSyncServiceProvider);
  return await syncService.isOnline;
});

/// Provider for leaderboard sync status
final leaderboardSyncStatusProvider = FutureProvider<bool>((ref) async {
  final hybridRepository = ref.watch(hybridLeaderboardRepositoryProvider);
  return await hybridRepository.isSynced;
});

/// Provider for statistics sync status
final statisticsSyncStatusProvider = FutureProvider<bool>((ref) async {
  final hybridRepository = ref.watch(hybridStatisticsRepositoryProvider);
  return await hybridRepository.isSynced;
});

/// Notifier for managing sync operations
class SyncNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseSyncService _syncService;

  SyncNotifier(this._syncService) : super(const AsyncValue.data(null));

  /// Perform full synchronization
  Future<void> performFullSync() async {
    state = const AsyncValue.loading();

    try {
      AppLogger.info('Starting full sync', tag: 'SyncNotifier');
      final result = await _syncService.performFullSync();

      if (result.state == SyncState.success) {
        state = const AsyncValue.data(null);
        AppLogger.info('Full sync completed successfully', tag: 'SyncNotifier');
      } else {
        state = AsyncValue.error(
          result.message ?? 'Sync failed',
          StackTrace.current,
        );
        AppLogger.error(
          'Full sync failed: ${result.message}',
          tag: 'SyncNotifier',
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      AppLogger.error('Full sync error: $e', tag: 'SyncNotifier');
    }
  }

  /// Force sync for leaderboard
  Future<void> forceSyncLeaderboard() async {
    state = const AsyncValue.loading();

    try {
      AppLogger.info('Starting leaderboard force sync', tag: 'SyncNotifier');
      await _syncService.performFullSync();
      state = const AsyncValue.data(null);
      AppLogger.info('Leaderboard force sync completed', tag: 'SyncNotifier');
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      AppLogger.error('Leaderboard force sync error: $e', tag: 'SyncNotifier');
    }
  }

  /// Force sync for statistics
  Future<void> forceSyncStatistics() async {
    state = const AsyncValue.loading();

    try {
      AppLogger.info('Starting statistics force sync', tag: 'SyncNotifier');
      await _syncService.performFullSync();
      state = const AsyncValue.data(null);
      AppLogger.info('Statistics force sync completed', tag: 'SyncNotifier');
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      AppLogger.error('Statistics force sync error: $e', tag: 'SyncNotifier');
    }
  }

  /// Migrate guest data to authenticated user
  Future<void> migrateGuestData(String guestId, String userId) async {
    state = const AsyncValue.loading();

    try {
      AppLogger.info(
        'Starting guest data migration: $guestId -> $userId',
        tag: 'SyncNotifier',
      );
      await _syncService.migrateGuestDataToUser(guestId, userId);
      state = const AsyncValue.data(null);
      AppLogger.info('Guest data migration completed', tag: 'SyncNotifier');
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      AppLogger.error('Guest data migration error: $e', tag: 'SyncNotifier');
    }
  }
}

/// Provider for sync notifier
final syncNotifierProvider =
    StateNotifierProvider<SyncNotifier, AsyncValue<void>>((ref) {
      final syncService = ref.watch(supabaseSyncServiceProvider);
      return SyncNotifier(syncService);
    });

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId != null;
});

/// Provider for current user identifier (authenticated user ID or guest ID)
final currentUserIdentifierProvider = FutureProvider<String?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId != null) {
    return userId;
  }

  final guestId = await ref.watch(guestUserIdProvider.future);
  return guestId;
});

/// Provider for auto-sync timer
final autoSyncTimerProvider = Provider<void>((ref) {
  final syncService = ref.watch(supabaseSyncServiceProvider);

  // Auto-sync every 5 minutes if online
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    try {
      if (await syncService.isOnline) {
        AppLogger.debug('Performing auto-sync', tag: 'AutoSync');
        await syncService.performFullSync();
      }
    } catch (e) {
      AppLogger.debug('Auto-sync failed (non-critical): $e', tag: 'AutoSync');
    }
  });
});
