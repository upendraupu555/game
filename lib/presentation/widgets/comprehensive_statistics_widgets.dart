import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

import '../../domain/repositories/game_repository.dart';
import '../providers/theme_providers.dart';
import '../providers/font_providers.dart';

/// Comprehensive statistics overview card
class StatisticsOverviewCard extends ConsumerWidget {
  final GameStatistics statistics;

  const StatisticsOverviewCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFont = ref.watch(currentFontProvider);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: currentPrimaryColor,
                fontFamily: currentFont?.fontFamily,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Games Played',
                    statistics.gamesPlayed.toString(),
                    Icons.games,
                    Colors.blue,
                    currentFont?.fontFamily,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Win Rate',
                    '${statistics.winRate.toStringAsFixed(1)}%',
                    Icons.emoji_events,
                    Colors.orange,
                    currentFont?.fontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Best Score',
                    _formatScore(statistics.bestScore),
                    Icons.star,
                    Colors.purple,
                    currentFont?.fontFamily,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg Score',
                    _formatScore(statistics.averageScore.round()),
                    Icons.trending_up,
                    Colors.green,
                    currentFont?.fontFamily,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    String? fontFamily,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: fontFamily,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}k';
    }
    return score.toString();
  }
}

/// Game mode performance breakdown widget
class GameModePerformanceCard extends ConsumerWidget {
  final GameStatistics statistics;

  const GameModePerformanceCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFont = ref.watch(currentFontProvider);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game Mode Performance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: currentPrimaryColor,
                fontFamily: currentFont?.fontFamily,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            if (statistics.gameModeStats.isEmpty)
              Text(
                'No game mode data available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: currentFont?.fontFamily,
                ),
              )
            else
              ...statistics.gameModeStats.entries.map((entry) {
                final gameMode = entry.key;
                final gamesPlayed = entry.value;
                final gamesWon = statistics.gameModeWins[gameMode] ?? 0;
                final bestScore = statistics.gameModeBestScores[gameMode] ?? 0;
                final winRate = gamesPlayed > 0
                    ? (gamesWon / gamesPlayed) * 100
                    : 0.0;

                return _buildGameModeItem(
                  gameMode,
                  gamesPlayed,
                  winRate,
                  bestScore,
                  currentFont?.fontFamily,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameModeItem(
    String gameMode,
    int gamesPlayed,
    double winRate,
    int bestScore,
    String? fontFamily,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gameMode,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Games: $gamesPlayed',
                style: TextStyle(fontFamily: fontFamily),
              ),
              Text(
                'Win Rate: ${winRate.toStringAsFixed(1)}%',
                style: TextStyle(fontFamily: fontFamily),
              ),
              Text(
                'Best: ${_formatScore(bestScore)}',
                style: TextStyle(fontFamily: fontFamily),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}k';
    }
    return score.toString();
  }
}

/// Powerup usage statistics widget
class PowerupStatisticsCard extends ConsumerWidget {
  final GameStatistics statistics;

  const PowerupStatisticsCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFont = ref.watch(currentFontProvider);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Powerup Usage',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: currentPrimaryColor,
                fontFamily: currentFont?.fontFamily,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            if (statistics.powerupUsageCount.isEmpty)
              Text(
                'No powerup usage data',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: currentFont?.fontFamily,
                ),
              )
            else
              ...statistics.powerupUsageCount.entries.map((entry) {
                final powerupType = entry.key;
                final usageCount = entry.value;
                final successCount =
                    statistics.powerupSuccessCount[powerupType] ?? 0;
                final successRate = usageCount > 0
                    ? (successCount / usageCount) * 100
                    : 0.0;

                return _buildPowerupItem(
                  powerupType,
                  usageCount,
                  successRate,
                  currentFont?.fontFamily,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerupItem(
    String powerupType,
    int usageCount,
    double successRate,
    String? fontFamily,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _formatPowerupName(powerupType),
              style: TextStyle(fontSize: 14, fontFamily: fontFamily),
            ),
          ),
          Text(
            'Used: $usageCount',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Success: ${successRate.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPowerupName(String powerupType) {
    // Convert camelCase to readable format
    return powerupType
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

/// Tile achievements widget
class TileAchievementsCard extends ConsumerWidget {
  final GameStatistics statistics;

  const TileAchievementsCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFont = ref.watch(currentFontProvider);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tile Achievements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: currentPrimaryColor,
                fontFamily: currentFont?.fontFamily,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildAchievementItem(
                    'Highest Tile',
                    statistics.highestTileValue.toString(),
                    Icons.emoji_events,
                    const Color(0xFFFFD700), // Gold color
                    currentFont?.fontFamily,
                  ),
                ),
                Expanded(
                  child: _buildAchievementItem(
                    '2048 Reached',
                    '${statistics.total2048Achievements}x',
                    Icons.star,
                    Colors.purple,
                    currentFont?.fontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Milestone Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: currentFont?.fontFamily,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildTileProgressGrid(currentFont?.fontFamily),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(
    String label,
    String value,
    IconData icon,
    Color color,
    String? fontFamily,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: fontFamily,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTileProgressGrid(String? fontFamily) {
    final milestones = [32, 64, 128, 256, 512, 1024, 2048, 4096];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: milestones.map((milestone) {
        final count = statistics.tileValueAchievements[milestone] ?? 0;
        final achieved = count > 0;

        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: achieved
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            border: Border.all(
              color: achieved ? Colors.green : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                milestone.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: achieved ? Colors.green : Colors.grey,
                  fontFamily: fontFamily,
                ),
              ),
              if (achieved)
                Text(
                  '${count}x',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontFamily: fontFamily,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
