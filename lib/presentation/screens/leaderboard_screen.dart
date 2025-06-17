import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../domain/entities/font_entity.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../providers/theme_providers.dart';
import '../providers/font_providers.dart';
import '../providers/leaderboard_providers.dart';
import '../providers/comprehensive_statistics_providers.dart';
import '../widgets/leaderboard_entry_widget.dart';
import '../widgets/comprehensive_statistics_widgets.dart';

/// Screen displaying the local leaderboard
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check for initial tab argument
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final initialTab = args?['initialTab'] as int?;

    if (initialTab != null && initialTab >= 0 && initialTab < 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabController.index != initialTab) {
          _tabController.animateTo(initialTab);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFont = ref.watch(currentFontProvider);
    final groupedLeaderboard = ref.watch(groupedLeaderboardProvider);
    final ungroupedLeaderboard = ref.watch(leaderboardProvider);
    final isGroupingEnabled = ref.watch(leaderboardGroupingEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationManager.leaderboard(ref),
          style: TextStyle(fontFamily: currentFont?.fontFamily),
        ),
        elevation: 0,
        actions: [
          // Grouping toggle button
          IconButton(
            icon: Icon(
              isGroupingEnabled ? Icons.view_list : Icons.view_module,
              color: currentPrimaryColor,
            ),
            tooltip: isGroupingEnabled
                ? 'Show ungrouped view'
                : 'Group by game mode',
            onPressed: () {
              ref.read(leaderboardGroupingEnabledProvider.notifier).state =
                  !isGroupingEnabled;
            },
          ),
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: currentPrimaryColor),
            onPressed: () {
              if (isGroupingEnabled) {
                ref.read(groupedLeaderboardProvider.notifier).refresh();
              } else {
                ref.read(leaderboardProvider.notifier).refresh();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: currentPrimaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: currentPrimaryColor,
          tabs: [
            Tab(
              text: LocalizationManager.leaderboard(ref),
              icon: const Icon(Icons.leaderboard),
            ),
            Tab(
              text: LocalizationManager.statistics(ref),
              icon: const Icon(Icons.bar_chart),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          isGroupingEnabled
              ? _buildGroupedLeaderboardTab(groupedLeaderboard, currentFont)
              : _buildUngroupedLeaderboardTab(
                  ungroupedLeaderboard,
                  currentFont,
                ),
          _buildStatisticsTab(currentFont, currentPrimaryColor),
        ],
      ),
    );
  }

  Widget _buildGroupedLeaderboardTab(
    AsyncValue<Map<String, List<LeaderboardEntry>>> groupedLeaderboard,
    FontEntity? currentFont,
  ) {
    return groupedLeaderboard.when(
      data: (groupedEntries) {
        if (groupedEntries.isEmpty) {
          return _buildEmptyState(currentFont);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(groupedLeaderboardProvider.notifier).refresh();
          },
          child: _buildGroupedLeaderboardList(groupedEntries, currentFont),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildErrorState(error, currentFont),
    );
  }

  Widget _buildUngroupedLeaderboardTab(
    AsyncValue<List<LeaderboardEntry>> ungroupedLeaderboard,
    FontEntity? currentFont,
  ) {
    return ungroupedLeaderboard.when(
      data: (entries) {
        if (entries.isEmpty) {
          return _buildEmptyState(currentFont);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(leaderboardProvider.notifier).refresh();
          },
          child: _buildUngroupedLeaderboardList(entries, currentFont),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildErrorState(error, currentFont),
    );
  }

  Widget _buildGroupedLeaderboardList(
    Map<String, List<LeaderboardEntry>> groupedEntries,
    FontEntity? currentFont,
  ) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);

    // Create a flat list with section headers and entries
    final List<Widget> widgets = [];
    int globalRank = 1;

    // Sort game modes alphabetically for consistent display
    final sortedGameModes = groupedEntries.keys.toList()..sort();

    for (final gameMode in sortedGameModes) {
      final entries = groupedEntries[gameMode]!;
      if (entries.isEmpty) continue;

      // Add section header
      widgets.add(
        _buildGameModeHeader(
          gameMode,
          entries.length,
          currentFont,
          currentPrimaryColor,
        ),
      );

      // Add entries for this game mode
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        widgets.add(
          LeaderboardEntryWidget(
            entry: entry,
            rank: globalRank,
            isHighlighted: globalRank <= 3,
            onTap: () => _showEntryDetails(entry, globalRank),
          ),
        );
        globalRank++;
      }

      // Add spacing between sections
      if (gameMode != sortedGameModes.last) {
        widgets.add(const SizedBox(height: AppConstants.paddingMedium));
      }
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
      children: widgets,
    );
  }

  Widget _buildUngroupedLeaderboardList(
    List<LeaderboardEntry> entries,
    FontEntity? currentFont,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final rank = index + 1;

        return LeaderboardEntryWidget(
          entry: entry,
          rank: rank,
          isHighlighted: rank <= 3,
          onTap: () => _showEntryDetails(entry, rank),
        );
      },
    );
  }

  Widget _buildGameModeHeader(
    String gameMode,
    int entryCount,
    FontEntity? currentFont,
    Color primaryColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(_getGameModeIcon(gameMode), color: primaryColor, size: 24),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Text(
              gameMode,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: currentFont?.fontFamily,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$entryCount ${entryCount == 1 ? 'game' : 'games'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor,
                fontFamily: currentFont?.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGameModeIcon(String gameMode) {
    switch (gameMode) {
      case AppConstants.gameModeClassic:
        return Icons.grid_4x4;
      case AppConstants.gameModeTimeAttack:
        return Icons.timer;
      case AppConstants.gameModeScenicMode:
        return Icons.landscape;
      default:
        return Icons.gamepad;
    }
  }

  Widget _buildStatisticsTab(FontEntity? currentFont, Color primaryColor) {
    final comprehensiveStats = ref.watch(
      comprehensiveStatisticsNotifierProvider,
    );

    return comprehensiveStats.when(
      data: (statistics) => RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(comprehensiveStatisticsNotifierProvider.notifier)
              .refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Card
              StatisticsOverviewCard(statistics: statistics),

              // Tile Achievements
              TileAchievementsCard(statistics: statistics),

              // Play Time Analytics
              _buildPlayTimeCard(statistics, currentFont, primaryColor),

              const SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
        ),
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingLarge),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                'Failed to load statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: currentFont?.fontFamily,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                error.toString(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: currentFont?.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(comprehensiveStatisticsNotifierProvider.notifier)
                      .refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(FontEntity? currentFont) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard, size: 64, color: Colors.grey[400]),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            LocalizationManager.noLeaderboardEntries(ref),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontFamily: currentFont?.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            LocalizationManager.playGamesToSeeLeaderboard(ref),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: currentFont?.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, FontEntity? currentFont) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            LocalizationManager.errorLoadingLeaderboard(ref),
            style: TextStyle(
              fontSize: 18,
              color: Colors.red[600],
              fontFamily: currentFont?.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ElevatedButton(
            onPressed: () {
              final isGroupingEnabled = ref.read(
                leaderboardGroupingEnabledProvider,
              );
              if (isGroupingEnabled) {
                ref.read(groupedLeaderboardProvider.notifier).refresh();
              } else {
                ref.read(leaderboardProvider.notifier).refresh();
              }
            },
            child: Text(
              LocalizationManager.retry(ref),
              style: TextStyle(fontFamily: currentFont?.fontFamily),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayTimeCard(
    GameStatistics statistics,
    FontEntity? currentFont,
    Color primaryColor,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Play Time Analytics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: currentFont?.fontFamily,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildPlayTimeItem(
                    'Total Play Time',
                    _formatDuration(statistics.totalPlayTime),
                    Icons.access_time,
                    Colors.blue,
                    currentFont?.fontFamily,
                  ),
                ),
                Expanded(
                  child: _buildPlayTimeItem(
                    'Average Game',
                    _formatDuration(statistics.averageGameDuration),
                    Icons.timer,
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

  Widget _buildPlayTimeItem(
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
            fontSize: 16,
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

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  void _showEntryDetails(entry, int rank) {
    // TODO: Implement detailed entry view
    // This could show a larger board snapshot, detailed stats, etc.
  }
}
