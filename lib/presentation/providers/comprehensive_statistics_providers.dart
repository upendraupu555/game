import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/usecases/comprehensive_statistics_usecases.dart';

import 'game_providers.dart';

/// Provider for comprehensive statistics use case
final updateComprehensiveStatisticsUseCaseProvider =
    Provider<UpdateComprehensiveStatisticsUseCase>((ref) {
      final repository = ref.read(gameRepositoryProvider);
      return UpdateComprehensiveStatisticsUseCase(repository);
    });

/// Provider for getting comprehensive statistics
final getComprehensiveStatisticsUseCaseProvider =
    Provider<GetComprehensiveStatisticsUseCase>((ref) {
      final repository = ref.read(gameRepositoryProvider);
      return GetComprehensiveStatisticsUseCase(repository);
    });

/// Provider for comprehensive statistics data
final comprehensiveStatisticsProvider = FutureProvider<GameStatistics>((
  ref,
) async {
  final useCase = ref.read(getComprehensiveStatisticsUseCaseProvider);
  return await useCase.execute();
});

/// Provider for statistics analytics
final statisticsAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final useCase = ref.read(getComprehensiveStatisticsUseCaseProvider);
  return await useCase.getStatisticsAnalytics();
});

/// Notifier for managing comprehensive statistics state
class ComprehensiveStatisticsNotifier
    extends StateNotifier<AsyncValue<GameStatistics>> {
  final Ref _ref;

  ComprehensiveStatisticsNotifier(this._ref)
    : super(const AsyncValue.loading()) {
    loadStatistics();
  }

  /// Load comprehensive statistics
  Future<void> loadStatistics() async {
    try {
      state = const AsyncValue.loading();
      final useCase = _ref.read(getComprehensiveStatisticsUseCaseProvider);
      final statistics = await useCase.execute();
      state = AsyncValue.data(statistics);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh statistics data
  Future<void> refresh() async {
    await loadStatistics();
  }

  /// Get current statistics synchronously (if available)
  GameStatistics? get currentStatistics {
    return state.value;
  }

  /// Get statistics analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final useCase = _ref.read(getComprehensiveStatisticsUseCaseProvider);
      return await useCase.getStatisticsAnalytics();
    } catch (error) {
      return {};
    }
  }

  /// Check if statistics are loading
  bool get isLoading => state.isLoading;

  /// Check if there's an error
  bool get hasError => state.hasError;

  /// Get error message if any
  String? get errorMessage => state.hasError ? state.error.toString() : null;
}

/// Provider for comprehensive statistics notifier
final comprehensiveStatisticsNotifierProvider =
    StateNotifierProvider<
      ComprehensiveStatisticsNotifier,
      AsyncValue<GameStatistics>
    >((ref) {
      return ComprehensiveStatisticsNotifier(ref);
    });

/// Computed providers for specific statistics metrics
final totalGamesPlayedProvider = Provider<int>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return stats.value?.gamesPlayed ?? 0;
});

final overallWinRateProvider = Provider<double>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return stats.value?.winRate ?? 0.0;
});

final bestScoreProvider = Provider<int>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return stats.value?.bestScore ?? 0;
});

final averageScoreProvider = Provider<double>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return stats.value?.averageScore ?? 0.0;
});

final totalPlayTimeProvider = Provider<Duration>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return stats.value?.totalPlayTime ?? Duration.zero;
});

final averageGameDurationProvider = Provider<Duration>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return stats.value?.averageGameDuration ?? Duration.zero;
});

final highestTileAchievedProvider = Provider<int>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return stats.value?.highestTileValue ?? 0;
});

final total2048AchievementsProvider = Provider<int>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return stats.value?.total2048Achievements ?? 0;
});

final mostUsedPowerupProvider = Provider<String?>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return stats.value?.mostUsedPowerup;
});

final recentPerformanceTrendProvider = Provider<double>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return stats.value?.recentPerformanceTrend ?? 0.0;
});

/// Provider for game mode performance data
final gameModePerformanceProvider = Provider<Map<String, Map<String, dynamic>>>(
  (ref) {
    final stats = ref.watch(comprehensiveStatisticsNotifierProvider).value;
    if (stats == null) return {};

    final performance = <String, Map<String, dynamic>>{};

    for (final mode in stats.gameModeStats.keys) {
      final played = stats.gameModeStats[mode] ?? 0;
      final won = stats.gameModeWins[mode] ?? 0;
      final bestScore = stats.gameModeBestScores[mode] ?? 0;

      performance[mode] = {
        'gamesPlayed': played,
        'gamesWon': won,
        'winRate': played > 0 ? (won / played) * 100 : 0.0,
        'bestScore': bestScore,
      };
    }

    return performance;
  },
);

/// Provider for powerup analytics data
final powerupAnalyticsProvider = Provider<Map<String, Map<String, dynamic>>>((
  ref,
) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider).value;
  if (stats == null) return {};

  final totalUsage = stats.powerupUsageCount.values.fold(0, (a, b) => a + b);
  final analytics = <String, Map<String, dynamic>>{};

  for (final powerup in stats.powerupUsageCount.keys) {
    final used = stats.powerupUsageCount[powerup] ?? 0;
    final successful = stats.powerupSuccessCount[powerup] ?? 0;

    analytics[powerup] = {
      'timesUsed': used,
      'successfulUses': successful,
      'successRate': used > 0 ? (successful / used) * 100 : 0.0,
      'usagePercentage': totalUsage > 0 ? (used / totalUsage) * 100 : 0.0,
    };
  }

  return analytics;
});

/// Provider for recent games performance
final recentGamesProvider = Provider<List<GamePerformance>>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return stats.value?.recentGames ?? [];
});

/// Provider for tile achievements data
final tileAchievementsProvider = Provider<Map<int, int>>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return stats.value?.tileValueAchievements ?? {};
});

/// Helper provider to format play time as human readable string
final formattedTotalPlayTimeProvider = Provider<String>((ref) {
  final duration = ref.watch(totalPlayTimeProvider);

  if (duration.inDays > 0) {
    return '${duration.inDays}d ${duration.inHours % 24}h';
  } else if (duration.inHours > 0) {
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  } else if (duration.inMinutes > 0) {
    return '${duration.inMinutes}m';
  } else {
    return '${duration.inSeconds}s';
  }
});

/// Helper provider to format average game duration
final formattedAverageGameDurationProvider = Provider<String>((ref) {
  final duration = ref.watch(averageGameDurationProvider);

  if (duration.inHours > 0) {
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  } else if (duration.inMinutes > 0) {
    return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
  } else {
    return '${duration.inSeconds}s';
  }
});

/// Provider to check if user has any statistics data
final hasStatisticsDataProvider = Provider<bool>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return (stats.value?.gamesPlayed ?? 0) > 0;
});

/// Provider for performance trend description
final performanceTrendDescriptionProvider = Provider<String>((ref) {
  final trend = ref.watch(recentPerformanceTrendProvider);

  if (trend > 10) {
    return 'Improving Significantly';
  } else if (trend > 0) {
    return 'Improving Slightly';
  } else if (trend > -10) {
    return 'Declining Slightly';
  } else {
    return 'Declining Significantly';
  }
});

/// Provider for statistics loading state
final statisticsLoadingProvider = Provider<bool>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return stats.isLoading;
});

/// Provider for statistics error state
final statisticsErrorProvider = Provider<String?>((ref) {
  final stats = ref.watch(comprehensiveStatisticsNotifierProvider);
  return stats.hasError ? stats.error.toString() : null;
});
