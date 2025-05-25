import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../providers/theme_providers.dart';

/// Example of a custom widget that uses the theme system
class ThemedButton extends ConsumerWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const ThemedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);

    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: currentPrimaryColor,
          foregroundColor: _getContrastColor(currentPrimaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.buttonPaddingHorizontal,
            vertical: AppConstants.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
        ),
        child: Text(text),
      );
    } else {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: currentPrimaryColor,
          side: BorderSide(color: currentPrimaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.buttonPaddingHorizontal,
            vertical: AppConstants.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
        ),
        child: Text(text),
      );
    }
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we should use black or white text
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Example of a themed card widget
class ThemedCard extends ConsumerWidget {
  final Widget child;
  final bool useAccentColor;

  const ThemedCard({
    super.key,
    required this.child,
    this.useAccentColor = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);

    return Card(
      color: useAccentColor
          ? currentPrimaryColor.withValues(alpha: AppConstants.opacityLow)
          : theme.cardColor,
      child: child,
    );
  }
}
