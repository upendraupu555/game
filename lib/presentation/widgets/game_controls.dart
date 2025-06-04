import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../domain/entities/powerup_entity.dart';
import '../providers/game_providers.dart';
import '../providers/theme_providers.dart';

/// Widget that displays game controls and instructions
class GameControls extends ConsumerWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final gameIsOver = ref.watch(gameIsOverProvider);
    final gameHasWon = ref.watch(gameHasWonProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          _ControlButton(
            icon: Icons.refresh,
            label: LocalizationManager.newGame(ref),
            color: currentPrimaryColor,
            onPressed: () {
              ref.read(gameProvider.notifier).restart();
            },
          ),
          if (gameIsOver || gameHasWon)
            _ControlButton(
              icon: gameHasWon ? Icons.celebration : Icons.replay,
              label: gameHasWon
                  ? LocalizationManager.playAgain(ref)
                  : LocalizationManager.tryAgain(ref),
              color: gameHasWon ? Colors.green : Colors.orange,
              onPressed: () {
                ref.read(gameProvider.notifier).restart();
              },
            ),
          // Debug button to test powerup system
          _ControlButton(
            icon: Icons.auto_awesome,
            label: 'Test 🧊',
            color: const Color(0xFF2196F3),
            onPressed: () {
              ref.read(gameProvider.notifier).debugAddPowerup(PowerupType.tileFreeze);
            },
          ),
          // Debug button to test tile destroyer
          _ControlButton(
            icon: Icons.auto_awesome,
            label: 'Test 💥',
            color: const Color(0xFFF44336),
            onPressed: () {
              ref.read(gameProvider.notifier).debugAddPowerup(PowerupType.tileDestroyer);
            },
          ),
          // Debug button to test row clear
          _ControlButton(
            icon: Icons.auto_awesome,
            label: 'Test ↔️',
            color: const Color(0xFFFF9800),
            onPressed: () {
              ref.read(gameProvider.notifier).debugAddPowerup(PowerupType.rowClear);
            },
          ),
          // Debug button to test column clear
          _ControlButton(
            icon: Icons.auto_awesome,
            label: 'Test ↕️',
            color: const Color(0xFFFF5722),
            onPressed: () {
              ref.read(gameProvider.notifier).debugAddPowerup(PowerupType.columnClear);
            },
          ),
        ],
        ),
      ),
    );
  }

}

/// Individual control button widget
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }
}
