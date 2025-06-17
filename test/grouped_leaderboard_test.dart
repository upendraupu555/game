import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game/core/constants/app_constants.dart';
import 'package:game/data/datasources/leaderboard_local_datasource.dart';
import 'package:game/data/repositories/leaderboard_repository_impl.dart';
import 'package:game/domain/entities/leaderboard_entity.dart';

void main() {
  group('Grouped Leaderboard Tests', () {
    late SharedPreferences sharedPreferences;
    late LeaderboardLocalDataSourceImpl dataSource;
    late LeaderboardRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
      dataSource = LeaderboardLocalDataSourceImpl(sharedPreferences);
      repository = LeaderboardRepositoryImpl(dataSource);
    });

    test('should group leaderboard entries by game mode', () async {
      // Add entries for different game modes
      final classicEntry = LeaderboardEntry.fromGame(
        score: 1000,
        gameMode: AppConstants.gameModeClassic,
        gameDuration: const Duration(minutes: 5),
        gameBoard: List.generate(5, (row) => List.generate(5, (col) => null)),
      );

      final timeAttackEntry = LeaderboardEntry.fromGame(
        score: 800,
        gameMode: AppConstants.gameModeTimeAttack,
        gameDuration: const Duration(minutes: 3),
        gameBoard: List.generate(5, (row) => List.generate(5, (col) => null)),
      );

      final scenicEntry = LeaderboardEntry.fromGame(
        score: 1200,
        gameMode: AppConstants.gameModeScenicMode,
        gameDuration: const Duration(minutes: 7),
        gameBoard: List.generate(5, (row) => List.generate(5, (col) => null)),
      );

      await repository.addLeaderboardEntry(classicEntry);
      await repository.addLeaderboardEntry(timeAttackEntry);
      await repository.addLeaderboardEntry(scenicEntry);

      final groupedEntries = await repository.getGroupedLeaderboard();

      // Should have 3 game modes
      expect(groupedEntries.keys.length, 3);
      expect(groupedEntries.containsKey(AppConstants.gameModeClassic), true);
      expect(groupedEntries.containsKey(AppConstants.gameModeTimeAttack), true);
      expect(groupedEntries.containsKey(AppConstants.gameModeScenicMode), true);

      // Each group should have 1 entry
      expect(groupedEntries[AppConstants.gameModeClassic]!.length, 1);
      expect(groupedEntries[AppConstants.gameModeTimeAttack]!.length, 1);
      expect(groupedEntries[AppConstants.gameModeScenicMode]!.length, 1);

      // Verify scores
      expect(groupedEntries[AppConstants.gameModeClassic]!.first.score, 1000);
      expect(groupedEntries[AppConstants.gameModeTimeAttack]!.first.score, 800);
      expect(groupedEntries[AppConstants.gameModeScenicMode]!.first.score, 1200);
    });

    test('should maintain 50 most recent entries across all game modes', () async {
      // Add 60 entries across different game modes
      for (int i = 1; i <= 60; i++) {
        final gameMode = i % 2 == 0 
            ? AppConstants.gameModeClassic 
            : AppConstants.gameModeTimeAttack;
        
        final entry = LeaderboardEntry.fromGame(
          score: i * 100,
          gameMode: gameMode,
          gameDuration: const Duration(minutes: 1),
          gameBoard: List.generate(5, (row) => List.generate(5, (col) => null)),
        );
        
        await repository.addLeaderboardEntry(entry);
        // Small delay to ensure different timestamps
        await Future.delayed(const Duration(milliseconds: 1));
      }

      final groupedEntries = await repository.getGroupedLeaderboard();
      final totalEntries = groupedEntries.values
          .fold<int>(0, (sum, entries) => sum + entries.length);

      // Should have exactly 50 entries total
      expect(totalEntries, AppConstants.maxLeaderboardEntries);

      // Should contain the most recent 50 entries (entries 11-60)
      final allEntries = await repository.getLeaderboard();
      expect(allEntries.length, 50);
      
      // Highest score should be 6000 (60 * 100)
      expect(allEntries.first.score, 6000);
    });

    test('should sort entries within each group by score', () async {
      // Add multiple entries for the same game mode with different scores
      final scores = [500, 1500, 1000, 2000, 800];
      
      for (final score in scores) {
        final entry = LeaderboardEntry.fromGame(
          score: score,
          gameMode: AppConstants.gameModeClassic,
          gameDuration: const Duration(minutes: 1),
          gameBoard: List.generate(5, (row) => List.generate(5, (col) => null)),
        );
        await repository.addLeaderboardEntry(entry);
      }

      final groupedEntries = await repository.getGroupedLeaderboard();
      final classicEntries = groupedEntries[AppConstants.gameModeClassic]!;

      // Should be sorted by score (highest first)
      expect(classicEntries[0].score, 2000);
      expect(classicEntries[1].score, 1500);
      expect(classicEntries[2].score, 1000);
      expect(classicEntries[3].score, 800);
      expect(classicEntries[4].score, 500);
    });

    test('should handle empty leaderboard gracefully', () async {
      final groupedEntries = await repository.getGroupedLeaderboard();
      expect(groupedEntries.isEmpty, true);
    });
  });
}
