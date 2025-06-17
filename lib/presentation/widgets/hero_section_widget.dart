import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';

/// Reusable hero section widget with app logo and title
/// Used consistently across home screen and about screen
class HeroSectionWidget extends ConsumerWidget {
  final Color primaryColor;
  final String fontFamily;
  final bool showTagline;
  final double? logoSize;
  final double? titleFontSize;

  const HeroSectionWidget({
    super.key,
    required this.primaryColor,
    required this.fontFamily,
    this.showTagline = true,
    this.logoSize,
    this.titleFontSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.08),
            primaryColor.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Geometric puzzle icon
          _buildLogo(context, ref),

          const SizedBox(height: AppConstants.paddingMedium),

          // App title with modern styling
          _buildTitle(context, ref),

          if (showTagline) ...[
            const SizedBox(height: AppConstants.paddingSmall),
            _buildTagline(context, ref),
          ],
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context, WidgetRef ref) {
    final size = logoSize ?? 80.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grid pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: GridPatternPainter(
                primaryColor: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Center number
          Center(
            child: Text(
              '2048',
              style: TextStyle(
                fontSize: size * 0.225, // Proportional to logo size
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, WidgetRef ref) {
    return Text(
      LocalizationManager.appTitle(ref),
      style: TextStyle(
        fontSize: titleFontSize ?? 28,
        fontWeight: FontWeight.w900,
        color: _getTextColor(context, primaryColor),
        fontFamily: fontFamily,
        letterSpacing: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTagline(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Text(
        LocalizationManager.appTagline(ref),
        style: TextStyle(
          fontSize: 12,
          color: _getTextColor(context, primaryColor),
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getTextColor(BuildContext context, Color primaryColor) {
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      return primaryColor.computeLuminance() > 0.5
          ? primaryColor
          : primaryColor.withValues(alpha: 0.9);
    } else {
      return primaryColor.computeLuminance() > 0.5
          ? primaryColor.withValues(alpha: 0.8)
          : primaryColor;
    }
  }
}

/// Custom painter for grid pattern used in the logo
class GridPatternPainter extends CustomPainter {
  final Color primaryColor;

  GridPatternPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const gridSize = 4;
    final cellWidth = size.width / gridSize;
    final cellHeight = size.height / gridSize;

    // Draw vertical lines
    for (int i = 1; i < gridSize; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 1; i < gridSize; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
