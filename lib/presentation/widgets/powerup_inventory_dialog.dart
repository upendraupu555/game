import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../domain/entities/powerup_entity.dart';
import '../providers/theme_providers.dart';
import '../providers/font_providers.dart';

/// Dialog that appears when powerup inventory is full and user earns a new powerup
class PowerupInventoryDialog extends ConsumerWidget {
  final PowerupType newPowerupType;
  final List<PowerupEntity> currentPowerups;
  final Function(PowerupType) onReplacePowerup;
  final VoidCallback onDiscardNewPowerup;

  const PowerupInventoryDialog({
    super.key,
    required this.newPowerupType,
    required this.currentPowerups,
    required this.onReplacePowerup,
    required this.onDiscardNewPowerup,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFont = ref.watch(currentFontProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogTheme.backgroundColor ??
              Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with warning icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory,
                  size: 48,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Title
              Text(
                LocalizationManager.powerupInventoryFull(ref),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontFamily: currentFont?.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              // Message
              Text(
                LocalizationManager.powerupInventoryFullMessage(ref),
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: currentFont?.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // New powerup display
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: _getPowerupColor(newPowerupType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  border: Border.all(
                    color: _getPowerupColor(newPowerupType).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      newPowerupType.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocalizationManager.newPowerupEarned(ref),
                            style: TextStyle(
                              fontSize: 14,
                              color: _getPowerupColor(newPowerupType),
                              fontWeight: FontWeight.w600,
                              fontFamily: currentFont?.fontFamily,
                            ),
                          ),
                          Text(
                            newPowerupType.displayName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontFamily: currentFont?.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Action buttons
              Column(
                children: [
                  // Replace powerup button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showReplacementDialog(context, ref);
                      },
                      icon: const Icon(Icons.swap_horiz, color: Colors.white),
                      label: Text(
                        LocalizationManager.replacePowerup(ref),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: currentFont?.fontFamily,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusSmall,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingMedium),

                  // Discard new powerup button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDiscardNewPowerup();
                        _showDiscardMessage(context, ref);
                      },
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade600),
                      label: Text(
                        LocalizationManager.discardNewPowerup(ref),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w600,
                          fontFamily: currentFont?.fontFamily,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade600),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusSmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReplacementDialog(BuildContext context, WidgetRef ref) {
    final currentFont = ref.read(currentFontProvider);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocalizationManager.selectPowerupToReplace(ref),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: currentFont?.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // List of current powerups
              ...currentPowerups.map((powerup) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onReplacePowerup(powerup.type);
                      _showReplacementMessage(context, ref);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusSmall,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          powerup.type.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Expanded(
                          child: Text(
                            powerup.type.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: currentFont?.fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),

              const SizedBox(height: AppConstants.paddingMedium),

              // Cancel button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  LocalizationManager.cancel(ref),
                  style: TextStyle(
                    fontFamily: currentFont?.fontFamily,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReplacementMessage(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: AppConstants.paddingSmall),
            Text(LocalizationManager.powerupReplaced(ref)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDiscardMessage(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: AppConstants.paddingSmall),
            Text(LocalizationManager.powerupDiscarded(ref)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getPowerupColor(PowerupType powerupType) {
    switch (powerupType) {
      case PowerupType.tileDestroyer:
        return const Color(0xFFF44336); // Red
      case PowerupType.rowClear:
        return const Color(0xFFFF9800); // Orange
      case PowerupType.columnClear:
        return const Color(0xFFFF5722); // Deep Orange
      case PowerupType.valueUpgrade:
        return const Color(0xFF4CAF50); // Green
      case PowerupType.tileFreeze:
        return const Color(0xFF2196F3); // Blue
      case PowerupType.undoMove:
        return const Color(0xFF9C27B0); // Purple
      case PowerupType.shuffleBoard:
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }
}
