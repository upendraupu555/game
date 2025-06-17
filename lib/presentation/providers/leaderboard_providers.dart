import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../domain/usecases/leaderboard_usecases.dart';
import '../../data/datasources/leaderboard_local_datasource.dart';
import '../../data/repositories/leaderboard_repository_impl.dart';
import '../../core/logging/app_logger.dart';
import 'theme_providers.dart';

// Data source providers
final leaderboardLocalDataSourceProvider = Provider<LeaderboardLocalDataSource>(
  (ref) {
    final sharedPreferences = ref.watch(sharedPreferencesProvider);
    return LeaderboardLocalDataSourceImpl(sharedPreferences);
  },
);

// Repository providers
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final localDataSource = ref.watch(leaderboardLocalDataSourceProvider);
  return LeaderboardRepositoryImpl(localDataSource);
});

// Use case providers
final getLeaderboardUseCaseProvider = Provider<GetLeaderboardUseCase>((ref) {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return GetLeaderboardUseCase(repository);
});

final getGroupedLeaderboardUseCaseProvider =
    Provider<GetGroupedLeaderboardUseCase>((ref) {
      final repository = ref.watch(leaderboardRepositoryProvider);
      return GetGroupedLeaderboardUseCase(repository);
    });

final addGameToLeaderboardUseCaseProvider =
    Provider<AddGameToLeaderboardUseCase>((ref) {
      final repository = ref.watch(leaderboardRepositoryProvider);
      return AddGameToLeaderboardUseCase(repository);
    });

final checkLeaderboardEligibilityUseCaseProvider =
    Provider<CheckLeaderboardEligibilityUseCase>((ref) {
      final repository = ref.watch(leaderboardRepositoryProvider);
      return CheckLeaderboardEligibilityUseCase(repository);
    });

final getLeaderboardByGameModeUseCaseProvider =
    Provider<GetLeaderboardByGameModeUseCase>((ref) {
      final repository = ref.watch(leaderboardRepositoryProvider);
      return GetLeaderboardByGameModeUseCase(repository);
    });

final clearLeaderboardUseCaseProvider = Provider<ClearLeaderboardUseCase>((
  ref,
) {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return ClearLeaderboardUseCase(repository);
});

final getScoreRankUseCaseProvider = Provider<GetScoreRankUseCase>((ref) {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return GetScoreRankUseCase(repository);
});

// State providers
final leaderboardProvider =
    StateNotifierProvider<
      LeaderboardNotifier,
      AsyncValue<List<LeaderboardEntry>>
    >((ref) {
      return LeaderboardNotifier(ref);
    });

final groupedLeaderboardProvider =
    StateNotifierProvider<
      GroupedLeaderboardNotifier,
      AsyncValue<Map<String, List<LeaderboardEntry>>>
    >((ref) {
      return GroupedLeaderboardNotifier(ref);
    });

final selectedGameModeFilterProvider = StateProvider<String?>((ref) => null);

// Provider for toggling between grouped and ungrouped leaderboard view
final leaderboardGroupingEnabledProvider = StateProvider<bool>((ref) => false);

final filteredLeaderboardProvider =
    Provider<AsyncValue<List<LeaderboardEntry>>>((ref) {
      final leaderboard = ref.watch(leaderboardProvider);
      final selectedGameMode = ref.watch(selectedGameModeFilterProvider);

      return leaderboard.when(
        data: (entries) {
          if (selectedGameMode == null || selectedGameMode.isEmpty) {
            return AsyncValue.data(entries);
          }
          final filtered = entries
              .where((entry) => entry.gameMode == selectedGameMode)
              .toList();
          return AsyncValue.data(filtered);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      );
    });

/// Notifier for managing leaderboard state
class LeaderboardNotifier
    extends StateNotifier<AsyncValue<List<LeaderboardEntry>>> {
  final Ref _ref;

  LeaderboardNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadLeaderboard();
  }

  /// Load leaderboard from storage
  Future<void> loadLeaderboard() async {
    try {
      state = const AsyncValue.loading();
      final useCase = _ref.read(getLeaderboardUseCaseProvider);
      final entries = await useCase.execute();
      state = AsyncValue.data(entries);

      AppLogger.debug(
        '📊 Loaded leaderboard with ${entries.length} entries',
        tag: 'LeaderboardNotifier',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        '❌ Failed to load leaderboard: $error',
        tag: 'LeaderboardNotifier',
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh leaderboard data
  Future<void> refresh() async {
    await loadLeaderboard();
  }

  /// Clear all leaderboard entries
  Future<void> clearLeaderboard() async {
    try {
      final useCase = _ref.read(clearLeaderboardUseCaseProvider);
      await useCase.execute();
      state = const AsyncValue.data([]);

      AppLogger.info(
        '🗑️ Leaderboard cleared successfully',
        tag: 'LeaderboardNotifier',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        '❌ Failed to clear leaderboard: $error',
        tag: 'LeaderboardNotifier',
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Check if a score is eligible for the leaderboard
  Future<bool> isScoreEligible(int score) async {
    try {
      final useCase = _ref.read(checkLeaderboardEligibilityUseCaseProvider);
      return await useCase.execute(score);
    } catch (error) {
      AppLogger.error(
        '❌ Failed to check score eligibility: $error',
        tag: 'LeaderboardNotifier',
      );
      return false;
    }
  }

  /// Get the rank of a specific score
  Future<int?> getScoreRank(int score) async {
    try {
      final useCase = _ref.read(getScoreRankUseCaseProvider);
      return await useCase.execute(score);
    } catch (error) {
      AppLogger.error(
        '❌ Failed to get score rank: $error',
        tag: 'LeaderboardNotifier',
      );
      return null;
    }
  }

  /// Get available game modes from current leaderboard
  List<String> getAvailableGameModes() {
    return state.when(
      data: (entries) {
        final gameModes = entries
            .map((entry) => entry.gameMode)
            .toSet()
            .toList();
        gameModes.sort();
        return gameModes;
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Get leaderboard statistics
  Map<String, dynamic> getLeaderboardStats() {
    return state.when(
      data: (entries) {
        if (entries.isEmpty) {
          return {
            'totalEntries': 0,
            'highestScore': 0,
            'averageScore': 0,
            'totalGames': 0,
          };
        }

        final totalEntries = entries.length;
        final highestScore = entries.first.score;
        final totalScore = entries.fold<int>(
          0,
          (sum, entry) => sum + entry.score,
        );
        final averageScore = (totalScore / totalEntries).round();

        return {
          'totalEntries': totalEntries,
          'highestScore': highestScore,
          'averageScore': averageScore,
          'totalGames': totalEntries,
        };
      },
      loading: () => {
        'totalEntries': 0,
        'highestScore': 0,
        'averageScore': 0,
        'totalGames': 0,
      },
      error: (_, __) => {
        'totalEntries': 0,
        'highestScore': 0,
        'averageScore': 0,
        'totalGames': 0,
      },
    );
  }
}

/// Notifier for managing grouped leaderboard state
class GroupedLeaderboardNotifier
    extends StateNotifier<AsyncValue<Map<String, List<LeaderboardEntry>>>> {
  final Ref _ref;

  GroupedLeaderboardNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadGroupedLeaderboard();
  }

  /// Load grouped leaderboard from storage
  Future<void> loadGroupedLeaderboard() async {
    try {
      state = const AsyncValue.loading();
      final useCase = _ref.read(getGroupedLeaderboardUseCaseProvider);
      final groupedEntries = await useCase.execute();
      state = AsyncValue.data(groupedEntries);

      final totalEntries = groupedEntries.values.fold<int>(
        0,
        (sum, entries) => sum + entries.length,
      );

      AppLogger.debug(
        '📊 Loaded grouped leaderboard with ${groupedEntries.keys.length} game modes, $totalEntries total entries',
        tag: 'GroupedLeaderboardNotifier',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        '❌ Failed to load grouped leaderboard: $error',
        tag: 'GroupedLeaderboardNotifier',
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh grouped leaderboard data
  Future<void> refresh() async {
    await loadGroupedLeaderboard();
  }

  /// Get available game modes from current grouped leaderboard
  List<String> getAvailableGameModes() {
    return state.when(
      data: (groupedEntries) {
        final gameModes = groupedEntries.keys.toList();
        gameModes.sort();
        return gameModes;
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Get total entry count across all game modes
  int getTotalEntryCount() {
    return state.when(
      data: (groupedEntries) {
        return groupedEntries.values.fold<int>(
          0,
          (sum, entries) => sum + entries.length,
        );
      },
      loading: () => 0,
      error: (_, __) => 0,
    );
  }
}
