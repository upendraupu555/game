import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';

/// Widget that displays scenic backgrounds with proper theming and readability
class ScenicBackgroundWidget extends ConsumerWidget {
  final int backgroundIndex;
  final Widget child;
  final double opacity;
  final double blur;
  final bool isScenicMode;

  const ScenicBackgroundWidget({
    super.key,
    required this.backgroundIndex,
    required this.child,
    this.opacity = AppConstants.scenicBackgroundOpacity,
    this.blur = AppConstants.scenicBackgroundBlur,
    this.isScenicMode = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Scenic background image
        _buildBackgroundImage(context),

        // Overlay for readability
        _buildReadabilityOverlay(context, isDarkMode),

        // Main content
        child,
      ],
    );
  }

  Widget _buildBackgroundImage(BuildContext context) {
    final paddedIndex = backgroundIndex.toString().padLeft(2, '0');
    final assetPath =
        '${AppConstants.scenicBackgroundBasePath}'
        '${AppConstants.scenicBackgroundPrefix}$paddedIndex'
        '${AppConstants.scenicBackgroundFileExtension}';

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
            opacity: isScenicMode
                ? AppConstants.scenicBackgroundOpacity
                : opacity,
            onError: (error, stackTrace) {
              AppLogger.error(
                'Failed to load scenic background: $assetPath',
                error: error,
                stackTrace: stackTrace,
              );
            },
          ),
        ),
        // Remove blur effects for scenic mode to show crisp images
        child: (!isScenicMode && blur > 0)
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(color: Colors.transparent),
              )
            : null,
      ),
    );
  }

  Widget _buildReadabilityOverlay(BuildContext context, bool isDarkMode) {
    // Use different overlay colors and opacity based on theme and scenic mode
    final overlayColor = isDarkMode
        ? Color(AppConstants.scenicOverlayColorLightValue)
        : Color(AppConstants.scenicOverlayColorDarkValue);

    // Use reduced opacity for scenic mode to enhance background visibility
    final overlayOpacity = isScenicMode
        ? AppConstants.scenicOverlayOpacity
        : AppConstants.scenicOverlayOpacityRegular;

    return Positioned.fill(
      child: Container(color: overlayColor.withValues(alpha: overlayOpacity)),
    );
  }
}

/// Optimized scenic background widget for game screen
class GameScenicBackgroundWidget extends ConsumerWidget {
  final int backgroundIndex;
  final Widget child;

  const GameScenicBackgroundWidget({
    super.key,
    required this.backgroundIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use optimized settings for maximum scenic visibility and game performance
    return ScenicBackgroundWidget(
      backgroundIndex: backgroundIndex,
      opacity: AppConstants.scenicBackgroundOpacity, // Full opacity (1.0)
      blur: AppConstants.scenicBackgroundBlur, // No blur (0.0)
      isScenicMode: true, // Always true for this widget
      child: child,
    );
  }
}

/// Scenic background preview widget for settings
class ScenicBackgroundPreviewWidget extends ConsumerWidget {
  final int backgroundIndex;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const ScenicBackgroundPreviewWidget({
    super.key,
    required this.backgroundIndex,
    this.width = 120,
    this.height = 80,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddedIndex = backgroundIndex.toString().padLeft(2, '0');
    final assetPath =
        '${AppConstants.scenicBackgroundBasePath}'
        '${AppConstants.scenicBackgroundPrefix}$paddedIndex'
        '${AppConstants.scenicBackgroundFileExtension}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
            onError: (error, stackTrace) {
              AppLogger.error(
                'Failed to load scenic background preview: $assetPath',
                error: error,
                stackTrace: stackTrace,
              );
            },
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            color: Colors.black.withValues(alpha: 0.1),
          ),
          child: Center(
            child: Text(
              'BG $backgroundIndex',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.7),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Error fallback widget for scenic backgrounds
class ScenicBackgroundErrorWidget extends StatelessWidget {
  final Widget child;
  final String? errorMessage;

  const ScenicBackgroundErrorWidget({
    super.key,
    required this.child,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: child,
    );
  }
}
