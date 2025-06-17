import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/navigation/navigation_service.dart';
import '../providers/theme_providers.dart';
import '../providers/font_providers.dart';

/// Pause menu overlay that appears when the pause button is clicked
/// Shows options for Resume, New Game, Settings, Main Menu, and Statistics
class PauseMenuOverlay extends ConsumerWidget {
  final VoidCallback onResume;
  final VoidCallback onNewGame;

  const PauseMenuOverlay({
    super.key,
    required this.onResume,
    required this.onNewGame,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFontFamily = ref.watch(currentFontFamilyProvider);

    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppConstants.paddingLarge),
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                LocalizationManager.pauseMenu(ref),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: currentPrimaryColor,
                  fontFamily: currentFontFamily,
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Menu options
              _PauseMenuButton(
                icon: Icons.play_arrow,
                label: LocalizationManager.resumeGame(ref),
                color: Colors.green,
                fontFamily: currentFontFamily,
                onPressed: onResume,
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              _PauseMenuButton(
                icon: Icons.refresh,
                label: LocalizationManager.newGame(ref),
                color: currentPrimaryColor,
                fontFamily: currentFontFamily,
                onPressed: onNewGame,
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              _PauseMenuButton(
                icon: Icons.help_outline,
                label: LocalizationManager.howToPlay(ref),
                color: Colors.purple,
                fontFamily: currentFontFamily,
                onPressed: () {
                  Navigator.of(context).pop(); // Close pause menu
                  NavigationService.pushNamed(AppRoutes.help);
                },
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              _PauseMenuButton(
                icon: Icons.settings,
                label: LocalizationManager.navSettings(ref),
                color: Colors.grey.shade600,
                fontFamily: currentFontFamily,
                onPressed: () {
                  Navigator.of(context).pop(); // Close pause menu
                  NavigationService.pushNamed(AppRoutes.settings);
                },
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              _PauseMenuButton(
                icon: Icons.bar_chart,
                label: LocalizationManager.statistics(ref),
                color: Colors.blue,
                fontFamily: currentFontFamily,
                onPressed: () {
                  Navigator.of(context).pop(); // Close pause menu
                  NavigationService.pushNamed(
                    AppRoutes.leaderboard,
                    arguments: {'initialTab': 1}, // Statistics tab index
                  );
                },
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              _PauseMenuButton(
                icon: Icons.home,
                label: LocalizationManager.mainMenu(ref),
                color: Colors.orange,
                fontFamily: currentFontFamily,
                onPressed: () {
                  Navigator.of(context).pop(); // Close pause menu
                  NavigationService.pushNamedAndRemoveUntil(
                    AppRoutes.home,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual pause menu button widget
class _PauseMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String fontFamily;
  final VoidCallback onPressed;

  const _PauseMenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.fontFamily,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
