import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../providers/game_providers.dart';
import '../providers/theme_providers.dart';
import '../providers/font_providers.dart';

/// Statistics dialog that shows game statistics
class StatisticsDialog extends ConsumerWidget {
  const StatisticsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFontFamily = ref.watch(currentFontFamilyProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          color: Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              LocalizationManager.statistics(ref),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: currentPrimaryColor,
                fontFamily: currentFontFamily,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingLarge),

            // Statistics content
            Consumer(
              builder: (context, ref, child) {
                final statsAsync = ref.watch(gameStatisticsProvider);

                return statsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppConstants.paddingLarge),
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Text(
                      'Error: $error',
                      style: TextStyle(
                        color: Colors.red,
                        fontFamily: currentFontFamily,
                      ),
                    ),
                  ),
                  data: (stats) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatisticRow(
                        label: LocalizationManager.gamesPlayed(ref),
                        value: stats.gamesPlayed.toString(),
                        fontFamily: currentFontFamily,
                      ),
                      _StatisticRow(
                        label: LocalizationManager.gamesWon(ref),
                        value: stats.gamesWon.toString(),
                        fontFamily: currentFontFamily,
                      ),
                      _StatisticRow(
                        label: LocalizationManager.winRate(ref),
                        value: '${stats.winRate.toStringAsFixed(1)}%',
                        fontFamily: currentFontFamily,
                      ),
                      _StatisticRow(
                        label: LocalizationManager.bestScore(ref),
                        value: stats.bestScore.toString(),
                        fontFamily: currentFontFamily,
                      ),
                      _StatisticRow(
                        label: LocalizationManager.averageScore(ref),
                        value: stats.averageScore.toStringAsFixed(0),
                        fontFamily: currentFontFamily,
                      ),
                      _StatisticRow(
                        label: LocalizationManager.totalPlayTime(ref),
                        value: stats.formattedPlayTime,
                        fontFamily: currentFontFamily,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.paddingMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                ),
                child: Text(
                  LocalizationManager.close(ref),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: currentFontFamily,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual statistic row widget
class _StatisticRow extends StatelessWidget {
  final String label;
  final String value;
  final String fontFamily;

  const _StatisticRow({
    required this.label,
    required this.value,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              fontFamily: fontFamily,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
