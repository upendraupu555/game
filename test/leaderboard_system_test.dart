import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:game/domain/entities/leaderboard_entity.dart';
import 'package:game/domain/entities/game_entity.dart';
import 'package:game/domain/entities/tile_entity.dart';
import 'package:game/data/datasources/leaderboard_local_datasource.dart';
import 'package:game/data/repositories/leaderboard_repository_impl.dart';
import 'package:game/domain/usecases/leaderboard_usecases.dart';
import 'package:game/presentation/providers/leaderboard_providers.dart';
import 'package:game/presentation/providers/theme_providers.dart';
import 'package:game/core/constants/app_constants.dart';

void main() {
  group('Leaderboard System Tests', () {
    late SharedPreferences sharedPreferences;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Leaderboard Entity Tests', () {
      test('should create leaderboard entry from game correctly', () {
        // Create a sample game board
        final gameBoard = List.generate(
          5,
          (row) => List.generate(
            5,
            (col) =>
                row == 0 && col == 0 ? TileEntity.withValue(2, row, col) : null,
          ),
        );

        final entry = LeaderboardEntry.fromGame(
          score: 2048,
          gameMode: AppConstants.gameModeClassic,
          gameDuration: const Duration(minutes: 5, seconds: 30),
          gameBoard: gameBoard,
        );

        expect(entry.score, 2048);
        expect(entry.gameMode, AppConstants.gameModeClassic);
        expect(entry.gameDuration, const Duration(minutes: 5, seconds: 30));
        expect(entry.boardSnapshot.length, 5);
        expect(entry.boardSnapshot[0].length, 5);
        expect(entry.boardSnapshot[0][0]?.value, 2);
        expect(entry.boardSnapshot[0][1], null);
      });

      test('should format score correctly', () {
        final entry = LeaderboardEntry.fromGame(
          score: 15000,
          gameMode: AppConstants.gameModeClassic,
          gameDuration: const Duration(minutes: 1),
          gameBoard: List.generate(5, (row) => List.generate(5, (col) => null)),
        );

        expect(entry.formattedScore, '15k');

        final smallScoreEntry = LeaderboardEntry.fromGame(
          score: 5000,
          gameMode: AppConstants.gameModeClassic,
          gameDuration: const Duration(minutes: 1),
          gameBoard: List.generate(5, (row) => List.generate(5, (col) => null)),
        );

        expect(smallScoreEntry.formattedScore, '5000');
      });

      test('should format duration correctly', () {
        final entry = LeaderboardEntry.fromGame(
          score: 1000,
          gameMode: AppConstants.gameModeClassic,
          gameDuration: const Duration(minutes: 3, seconds: 45),
          gameBoard: List.generate(5, (row) => List.generate(5, (col) => null)),
        );

        expect(entry.formattedDuration, '03:45');
      });

      test('should provide detailed game mode for time attack', () {
        final entry = LeaderboardEntry.fromGame(
          score: 1000,
          gameMode: AppConstants.gameModeTimeAttack,
          gameDuration: const Duration(minutes: 2),
          gameBoard: List.generate(5, (row) => List.generate(5, (col) => null)),
          timeLimit: 300, // 5 minutes
        );

        expect(entry.detailedGameMode, 'Time Attack (5 min)');
      });
    });

    group('Leaderboard Repository Tests', () {
      test('should save and retrieve leaderboard entries', () async {
        final dataSource = LeaderboardLocalDataSourceImpl(sharedPreferences);
        final repository = LeaderboardRepositoryImpl(dataSource);

        // Create test entry
        final entry = LeaderboardEntry.fromGame(
          score: 2048,
          gameMode: AppConstants.gameModeClassic,
          gameDuration: const Duration(minutes: 5),
          gameBoard: List.generate(5, (row) => List.generate(5, (col) => null)),
        );

        // Add entry
        await repository.addLeaderboardEntry(entry);

        // Retrieve entries
        final entries = await repository.getLeaderboard();
        expect(entries.length, 1);
        expect(entries.first.score, 2048);
        expect(entries.first.gameMode, AppConstants.gameModeClassic);
      });

      test('should maintain only top 50 most recent entries', () async {
        final dataSource = LeaderboardLocalDataSourceImpl(sharedPreferences);
        final repository = LeaderboardRepositoryImpl(dataSource);

        // Add 60 entries with different scores and dates
        for (int i = 1; i <= 60; i++) {
          final entry = LeaderboardEntry.fromGame(
            score: i * 100,
            gameMode: AppConstants.gameModeClassic,
            gameDuration: const Duration(minutes: 1),
            gameBoard: List.generate(
              5,
              (row) => List.generate(5, (col) => null),
            ),
          );
          await repository.addLeaderboardEntry(entry);
          // Small delay to ensure different timestamps
          await Future.delayed(const Duration(milliseconds: 1));
        }

        final entries = await repository.getLeaderboard();
        expect(entries.length, AppConstants.maxLeaderboardEntries);

        // Should contain the 50 most recent entries (entries 11-60)
        // When sorted by score, the highest should be 6000 (60 * 100)
        expect(entries.first.score, 6000); // Highest score among recent 50
      });

      test('should check score eligibility correctly', () async {
        final dataSource = LeaderboardLocalDataSourceImpl(sharedPreferences);
        final repository = LeaderboardRepositoryImpl(dataSource);

        // All scores should be eligible when leaderboard is empty (threshold is 0)
        expect(await repository.isScoreEligible(500), true);
        expect(await repository.isScoreEligible(1500), true);

        // Fill leaderboard with 50 entries
        for (int i = 1; i <= 50; i++) {
          final entry = LeaderboardEntry.fromGame(
            score: i * 1000,
            gameMode: AppConstants.gameModeClassic,
            gameDuration: const Duration(minutes: 1),
            gameBoard: List.generate(
              5,
              (row) => List.generate(5, (col) => null),
            ),
          );
          await repository.addLeaderboardEntry(entry);
        }

        // Score higher than lowest should be eligible
        expect(await repository.isScoreEligible(51000), true);

        // Score lower than lowest should not be eligible (when leaderboard is full)
        expect(await repository.isScoreEligible(500), false);
      });

      test('should filter by game mode correctly', () async {
        final dataSource = LeaderboardLocalDataSourceImpl(sharedPreferences);
        final repository = LeaderboardRepositoryImpl(dataSource);

        // Add entries for different game modes
        final classicEntry = LeaderboardEntry.fromGame(
          score: 2000,
          gameMode: AppConstants.gameModeClassic,
          gameDuration: const Duration(minutes: 5),
          gameBoard: List.generate(5, (row) => List.generate(5, (col) => null)),
        );

        final timeAttackEntry = LeaderboardEntry.fromGame(
          score: 1500,
          gameMode: AppConstants.gameModeTimeAttack,
          gameDuration: const Duration(minutes: 3),
          gameBoard: List.generate(5, (row) => List.generate(5, (col) => null)),
        );

        await repository.addLeaderboardEntry(classicEntry);
        await repository.addLeaderboardEntry(timeAttackEntry);

        // Filter by classic mode
        final classicEntries = await repository.getLeaderboardByGameMode(
          AppConstants.gameModeClassic,
        );
        expect(classicEntries.length, 1);
        expect(classicEntries.first.gameMode, AppConstants.gameModeClassic);

        // Filter by time attack mode
        final timeAttackEntries = await repository.getLeaderboardByGameMode(
          AppConstants.gameModeTimeAttack,
        );
        expect(timeAttackEntries.length, 1);
        expect(
          timeAttackEntries.first.gameMode,
          AppConstants.gameModeTimeAttack,
        );
      });

      test('should clear leaderboard correctly', () async {
        final dataSource = LeaderboardLocalDataSourceImpl(sharedPreferences);
        final repository = LeaderboardRepositoryImpl(dataSource);

        // Add some entries
        for (int i = 1; i <= 5; i++) {
          final entry = LeaderboardEntry.fromGame(
            score: i * 1000,
            gameMode: AppConstants.gameModeClassic,
            gameDuration: const Duration(minutes: 1),
            gameBoard: List.generate(
              5,
              (row) => List.generate(5, (col) => null),
            ),
          );
          await repository.addLeaderboardEntry(entry);
        }

        // Verify entries exist
        expect((await repository.getLeaderboard()).length, 5);

        // Clear leaderboard
        await repository.clearLeaderboard();

        // Verify leaderboard is empty
        expect((await repository.getLeaderboard()).length, 0);
        expect(await repository.isLeaderboardEmpty(), true);
      });
    });

    group('Leaderboard Use Cases Tests', () {
      test('should add qualifying game to leaderboard', () async {
        final getLeaderboardUseCase = container.read(
          getLeaderboardUseCaseProvider,
        );
        final addGameUseCase = container.read(
          addGameToLeaderboardUseCaseProvider,
        );

        // Create a qualifying game
        final gameState = GameEntity.newGame().copyWith(
          score: 2048,
          isGameOver: true,
        );

        final wasAdded = await addGameUseCase.execute(
          gameState: gameState,
          gameDuration: const Duration(minutes: 5),
        );

        expect(wasAdded, true);

        final entries = await getLeaderboardUseCase.execute();
        expect(entries.length, 1);
        expect(entries.first.score, 2048);
      });

      test(
        'should add all games to leaderboard (no score threshold)',
        () async {
          final getLeaderboardUseCase = container.read(
            getLeaderboardUseCaseProvider,
          );
          final addGameUseCase = container.read(
            addGameToLeaderboardUseCaseProvider,
          );

          // Create a low score game (should now be accepted)
          final gameState = GameEntity.newGame().copyWith(
            score: 500,
            isGameOver: true,
          );

          final wasAdded = await addGameUseCase.execute(
            gameState: gameState,
            gameDuration: const Duration(minutes: 5),
          );

          expect(wasAdded, true);

          final entries = await getLeaderboardUseCase.execute();
          expect(entries.length, 1);
          expect(entries.first.score, 500);
        },
      );

      test('should check eligibility correctly', () async {
        final eligibilityUseCase = container.read(
          checkLeaderboardEligibilityUseCaseProvider,
        );

        // All scores should be eligible (threshold is 0)
        expect(await eligibilityUseCase.execute(500), true);
        expect(await eligibilityUseCase.execute(1500), true);
        expect(await eligibilityUseCase.execute(100), true);
      });
    });

    group('Leaderboard Providers Tests', () {
      test('should load leaderboard through provider', () async {
        // Trigger initial load
        container.read(leaderboardProvider);

        // Wait a bit for async loading
        await Future.delayed(const Duration(milliseconds: 100));

        final state = container.read(leaderboardProvider);
        expect(state.hasValue, true);
        expect(state.value, isA<List<LeaderboardEntry>>());
      });

      test('should provide leaderboard statistics', () async {
        final notifier = container.read(leaderboardProvider.notifier);

        // Add some test data
        final addGameUseCase = container.read(
          addGameToLeaderboardUseCaseProvider,
        );

        for (int i = 1; i <= 3; i++) {
          final gameState = GameEntity.newGame().copyWith(
            score: i * 1000,
            isGameOver: true,
          );

          await addGameUseCase.execute(
            gameState: gameState,
            gameDuration: Duration(minutes: i),
          );
        }

        await notifier.refresh();

        final stats = notifier.getLeaderboardStats();
        expect(stats['totalEntries'], 3);
        expect(stats['highestScore'], 3000);
        expect(stats['averageScore'], 2000);
      });
    });
  });
}
