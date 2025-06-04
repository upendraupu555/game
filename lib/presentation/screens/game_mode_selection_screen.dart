import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/navigation/navigation_service.dart';
import '../providers/theme_providers.dart';
import '../providers/font_providers.dart';
import '../providers/game_providers.dart';

class GameModeSelectionScreen extends ConsumerWidget {
  const GameModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFontFamily = ref.watch(currentFontFamilyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.selectGameMode(ref)),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header section
                  _buildHeader(
                    context,
                    ref,
                    currentPrimaryColor,
                    currentFontFamily,
                  ),

                  const SizedBox(height: AppConstants.paddingExtraLarge),

                  // Game mode cards
                  Column(
                    children: [
                      // Regular Game Mode
                      _buildGameModeCard(
                        context: context,
                        ref: ref,
                        title: LocalizationManager.regularGame(ref),
                        subtitle: LocalizationManager.regularGameDescription(
                          ref,
                        ),
                        icon: Icons.grid_3x3,
                        difficulty: LocalizationManager.classic(ref),
                        primaryColor: currentPrimaryColor,
                        fontFamily: currentFontFamily,
                        onTap: () => _startRegularGame(ref),
                        isRecommended: true,
                      ),

                      const SizedBox(height: AppConstants.paddingLarge),

                      // Time Attack Mode
                      _buildGameModeCard(
                        context: context,
                        ref: ref,
                        title: LocalizationManager.timeAttack(ref),
                        subtitle: LocalizationManager.timeAttackDescription(
                          ref,
                        ),
                        icon: Icons.timer,
                        difficulty: LocalizationManager.challenging(ref),
                        primaryColor: Colors.orange,
                        fontFamily: currentFontFamily,
                        onTap: () => _showTimeAttackOptions(context, ref),
                        isRecommended: false,
                      ),

                      const SizedBox(height: AppConstants.paddingLarge),

                      // Scenic Mode
                      _buildGameModeCard(
                        context: context,
                        ref: ref,
                        title: LocalizationManager.scenicMode(ref),
                        subtitle: LocalizationManager.scenicModeDescription(
                          ref,
                        ),
                        icon: Icons.landscape,
                        difficulty: LocalizationManager.relaxing(ref),
                        primaryColor: Colors.green,
                        fontFamily: currentFontFamily,
                        onTap: () => _startScenicGame(ref),
                        isRecommended: false,
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      // Quick start button
                      _buildQuickStartButton(
                        context,
                        ref,
                        currentPrimaryColor,
                        currentFontFamily,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
    String fontFamily,
  ) {
    return Column(
      children: [
        Icon(Icons.sports_esports, size: 64, color: primaryColor),
        const SizedBox(height: AppConstants.paddingMedium),
        Text(
          LocalizationManager.chooseYourChallenge(ref),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            fontFamily: fontFamily,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          LocalizationManager.selectGameModeDescription(ref),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            fontFamily: fontFamily,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGameModeCard({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required String difficulty,
    required Color primaryColor,
    required String fontFamily,
    required VoidCallback onTap,
    required bool isRecommended,
  }) {
    return Stack(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusLarge,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withValues(alpha: 0.1),
                    primaryColor.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor,
                          primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),

                  const SizedBox(width: AppConstants.paddingMedium),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            fontFamily: fontFamily,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.8),
                            fontFamily: fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusSmall,
                            ),
                          ),
                          child: Text(
                            difficulty,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(Icons.arrow_forward_ios, color: primaryColor, size: 18),
                ],
              ),
            ),
          ),
        ),

        // Recommended badge
        if (isRecommended)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingSmall,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
              ),
              child: Text(
                LocalizationManager.recommended(ref),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: fontFamily,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickStartButton(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
    String fontFamily,
  ) {
    return OutlinedButton.icon(
      onPressed: () => _startRegularGame(ref),
      icon: const Icon(Icons.flash_on),
      label: Text(
        LocalizationManager.quickStart(ref),
        style: TextStyle(fontFamily: fontFamily),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingMedium,
          horizontal: AppConstants.paddingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }

  void _startRegularGame(WidgetRef ref) {
    ref.read(gameProvider.notifier).restart();
    NavigationService.pushNamed(AppRoutes.game);
  }

  void _showTimeAttackOptions(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationManager.selectTimeLimit(ref)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimeOption(
              context,
              ref,
              '3 ${LocalizationManager.minutes(ref)}',
              180,
            ),
            _buildTimeOption(
              context,
              ref,
              '5 ${LocalizationManager.minutes(ref)}',
              300,
            ),
            _buildTimeOption(
              context,
              ref,
              '10 ${LocalizationManager.minutes(ref)}',
              600,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationManager.cancel(ref)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    int seconds,
  ) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.of(context).pop();
        _startTimeAttackGame(ref, seconds);
      },
    );
  }

  void _startTimeAttackGame(WidgetRef ref, int timeLimit) {
    ref.read(gameProvider.notifier).startTimeAttack(timeLimit);
    NavigationService.pushNamed(AppRoutes.game);
  }

  void _startScenicGame(WidgetRef ref) {
    ref.read(gameProvider.notifier).startScenicMode();
    NavigationService.pushNamed(AppRoutes.game);
  }
}
