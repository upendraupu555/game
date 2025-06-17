import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/navigation/navigation_service.dart';
import '../providers/theme_providers.dart';
import '../providers/font_providers.dart';
import '../providers/game_providers.dart';
import '../providers/payment_providers.dart';
import '../providers/user_providers.dart';
import '../../domain/entities/game_entity.dart';

import '../widgets/payment_dialog.dart';
import '../widgets/hero_section_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Helper method to get appropriate text color based on theme brightness
  Color _getTextColor(
    BuildContext context,
    Color primaryColor, {
    bool isSecondary = false,
  }) {
    final brightness = Theme.of(context).brightness;

    if (brightness == Brightness.dark) {
      // Dark mode: use white text for better contrast
      return isSecondary ? Colors.white.withValues(alpha: 0.7) : Colors.white;
    } else {
      // Light mode: use theme colors for better contrast
      return isSecondary ? primaryColor.withValues(alpha: 0.7) : primaryColor;
    }
  }

  /// Helper method to get theme text color for stats
  Color _getThemeTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    if (brightness == Brightness.dark) {
      // Dark mode: use white text
      return Colors.white.withValues(alpha: 0.7);
    } else {
      // Light mode: use theme text color
      return Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
          Colors.black.withValues(alpha: 0.7);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFontFamily = ref.watch(currentFontFamilyProvider);
    final hasResumableGame = ref.watch(hasResumableGameProvider);
    final resumableGameInfo = ref.watch(resumableGameInfoProvider);
    final bestScore = ref.watch(gameBestScoreProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(
          children: [
            // Subtle geometric background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: GeometricPatternPainter(
                  primaryColor: currentPrimaryColor.withValues(alpha: 0.03),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            // Main content
            _buildMainContent(
              context,
              ref,
              currentPrimaryColor,
              currentFontFamily,
              hasResumableGame,
              resumableGameInfo,
              bestScore,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    Color currentPrimaryColor,
    String currentFontFamily,
    bool hasResumableGame,
    GameEntity? resumableGameInfo,
    int bestScore,
  ) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppConstants.paddingSmall),

                    // Hero section with logo and title
                    HeroSectionWidget(
                      primaryColor: currentPrimaryColor,
                      fontFamily: currentFontFamily,
                      showTagline: true,
                    ),

                    const SizedBox(height: AppConstants.paddingLarge),

                    // Stats card
                    if (bestScore > 0) ...[
                      _buildStatsCard(
                        context,
                        ref,
                        bestScore,
                        currentPrimaryColor,
                        currentFontFamily,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                    ],

                    // Action cards grid
                    _buildActionCardsGrid(
                      context,
                      ref,
                      hasResumableGame,
                      resumableGameInfo,
                      currentPrimaryColor,
                      currentFontFamily,
                    ),

                    const SizedBox(height: AppConstants.paddingMedium),

                    // Quick actions row
                    _buildQuickActionsRow(
                      context,
                      ref,
                      currentPrimaryColor,
                      currentFontFamily,
                    ),

                    const SizedBox(height: AppConstants.paddingLarge),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingHeader(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
    String fontFamily,
  ) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Floating settings button
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusLarge,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                NavigationService.pushNamed(AppRoutes.settings);
              },
              icon: Icon(Icons.settings, color: primaryColor, size: 24),
              tooltip: LocalizationManager.navSettings(ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
    String fontFamily,
  ) {
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
          // Geometric puzzle icon - reduced size
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // App title with modern styling - reduced size
          Text(
            LocalizationManager.appTitle(ref),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _getTextColor(context, primaryColor),
              fontFamily: fontFamily,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // Tagline with accent
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusLarge,
              ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    WidgetRef ref,
    int bestScore,
    Color primaryColor,
    String fontFamily,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Trophy icon with gradient background - reduced size
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.amber, Colors.amber.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: AppConstants.paddingMedium),

          // Stats content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationManager.bestScore(ref),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getThemeTextColor(context),
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppConstants.formatScore(bestScore),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context, primaryColor),
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
          ),

          // Achievement badge - reduced size
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingSmall,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
            ),
            child: Text(
              'BEST',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getTextColor(context, primaryColor),
                fontFamily: fontFamily,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCardsGrid(
    BuildContext context,
    WidgetRef ref,
    bool hasResumableGame,
    GameEntity? resumableGameInfo,
    Color primaryColor,
    String fontFamily,
  ) {
    return Column(
      children: [
        // Resume Game Card (if available)
        if (hasResumableGame && resumableGameInfo != null) ...[
          _buildActionCard(
            context: context,
            title: LocalizationManager.continueGame(ref),
            subtitle:
                '${LocalizationManager.scoreLabel(ref)}: ${AppConstants.formatScore(resumableGameInfo.score)}',
            icon: Icons.play_arrow,
            color: Colors.green,
            onTap: () {
              NavigationService.pushNamed(AppRoutes.game);
            },
            isPrimary: true,
            fontFamily: fontFamily,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
        ],

        // New Game Card
        _buildActionCard(
          context: context,
          title: hasResumableGame
              ? LocalizationManager.newGame(ref)
              : LocalizationManager.startPlaying(ref),
          subtitle: hasResumableGame
              ? LocalizationManager.startFreshAdventure(ref)
              : LocalizationManager.beginPuzzleJourney(ref),
          icon: hasResumableGame ? Icons.refresh : Icons.play_circle_filled,
          color: primaryColor,
          onTap: () async {
            if (hasResumableGame) {
              // Show confirmation dialog
              final confirmed = await _showNewGameConfirmation(context, ref);
              if (confirmed) {
                NavigationService.pushNamed(AppRoutes.gameModeSelection);
              }
            } else {
              NavigationService.pushNamed(AppRoutes.gameModeSelection);
            }
          },
          isPrimary: !hasResumableGame,
          fontFamily: fontFamily,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isPrimary,
    required String fontFamily,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: isPrimary ? 12 : 8,
                  offset: Offset(0, isPrimary ? 6 : 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon container - reduced size
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall,
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),

                const SizedBox(width: AppConstants.paddingMedium),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isPrimary ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow indicator - reduced size
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
    String fontFamily,
  ) {
    // final areAdsRemoved = ref.watch(areAdsRemovedProvider); // Temporarily unused

    return Column(
      children: [
        // First row: How to Play and Statistics
        Row(
          children: [
            // How to Play Button
            Expanded(
              child: _buildQuickActionButton(
                context: context,
                ref: ref,
                icon: Icons.help_outline,
                label: LocalizationManager.howToPlay(ref),
                onTap: () {
                  NavigationService.pushNamed(AppRoutes.help);
                },
                primaryColor: primaryColor,
                fontFamily: fontFamily,
              ),
            ),

            const SizedBox(width: AppConstants.paddingMedium),

            // Statistics Button
            Expanded(
              child: _buildQuickActionButton(
                context: context,
                ref: ref,
                icon: Icons.bar_chart,
                label: LocalizationManager.statistics(ref),
                onTap: () {
                  // Navigate to leaderboard screen with statistics tab selected
                  NavigationService.pushNamed(
                    AppRoutes.leaderboard,
                    arguments: {'initialTab': 1}, // Statistics tab index
                  );
                },
                primaryColor: primaryColor,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.paddingMedium),

        // Third row: Leaderboard and Settings
        Row(
          children: [
            // Leaderboard Button
            Expanded(
              child: _buildQuickActionButton(
                context: context,
                ref: ref,
                icon: Icons.leaderboard,
                label: LocalizationManager.leaderboard(ref),
                onTap: () {
                  NavigationService.pushNamed(AppRoutes.leaderboard);
                },
                primaryColor: primaryColor,
                fontFamily: fontFamily,
              ),
            ),

            const SizedBox(width: AppConstants.paddingMedium),

            // Settings Button
            Expanded(
              child: _buildQuickActionButton(
                context: context,
                ref: ref,
                icon: Icons.settings,
                label: LocalizationManager.navSettings(ref),
                onTap: () {
                  NavigationService.pushNamed(AppRoutes.settings);
                },
                primaryColor: primaryColor,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),

        // Remove Ads button temporarily hidden
        // TODO: Re-enable when needed
        // if (!areAdsRemoved) ...[
        //   const SizedBox(height: AppConstants.paddingMedium),
        //   _buildRemoveAdsButton(context, ref, primaryColor, fontFamily),
        // ],
      ],
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color primaryColor,
    required String fontFamily,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(context, primaryColor),
                  fontFamily: fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveAdsButton(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
    String fontFamily,
  ) {
    final isPaymentProcessing = ref.watch(isPaymentProcessingProvider);

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isPaymentProcessing
              ? null
              : () => _showPaymentDialog(context, ref),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange, Colors.orange.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall,
                    ),
                  ),
                  child: const Icon(Icons.block, color: Colors.white, size: 20),
                ),

                const SizedBox(width: AppConstants.paddingMedium),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Remove Ads',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${AppConstants.removeAdsPrice} - One-time purchase',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),

                // Processing indicator or arrow
                if (isPaymentProcessing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 14,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPaymentDialog(BuildContext context, WidgetRef ref) async {
    // Check user authentication status first
    final userState = ref.read(userProvider);
    final user = userState.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );

    // Validate authentication before showing payment dialog
    if (user == null || user.isGuest || !user.isAuthenticated) {
      await _showAuthenticationRequiredDialog(context, ref);
      return;
    }

    // User is authenticated, proceed with payment
    final result = await showPaymentDialog(context);
    if (result == true) {
      // Payment was successful, refresh the UI
      ref.read(paymentProvider.notifier).refreshPurchaseStatus();
    }
  }

  /// Show dialog prompting user to sign in for payment
  Future<void> _showAuthenticationRequiredDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final currentPrimaryColor = ref.read(currentPrimaryColorProvider);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        title: Row(
          children: [
            Icon(
              Icons.login,
              color: currentPrimaryColor,
              size: AppConstants.iconSizeMedium,
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            Text(
              'Sign In Required',
              style: TextStyle(
                color: _getTextColor(context, currentPrimaryColor),
              ),
            ),
          ],
        ),
        content: Text(
          'You need to sign in with your account to purchase ad removal. Guest users cannot make purchases.',
          style: TextStyle(color: _getThemeTextColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: _getTextColor(context, currentPrimaryColor),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login screen
              NavigationService.pushNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: currentPrimaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showNewGameConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          LocalizationManager.newGameConfirmation(ref),
          style: TextStyle(
            color: _getTextColor(
              context,
              ref.read(currentPrimaryColorProvider),
            ),
          ),
        ),
        content: Text(
          LocalizationManager.newGameConfirmationMessage(ref),
          style: TextStyle(color: _getThemeTextColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              LocalizationManager.cancel(ref),
              style: TextStyle(
                color: _getTextColor(
                  context,
                  ref.read(currentPrimaryColorProvider),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
            child: Text(LocalizationManager.continueText(ref)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// Custom painter for grid pattern
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

// Custom painter for subtle geometric background pattern
class GeometricPatternPainter extends CustomPainter {
  final Color primaryColor;
  final Color backgroundColor;

  GeometricPatternPainter({
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Create a subtle tile pattern
    const tileSize = 60.0;
    const spacing = 20.0;

    for (
      double x = -tileSize;
      x < size.width + tileSize;
      x += tileSize + spacing
    ) {
      for (
        double y = -tileSize;
        y < size.height + tileSize;
        y += tileSize + spacing
      ) {
        // Draw subtle rounded rectangles
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, tileSize * 0.6, tileSize * 0.6),
          const Radius.circular(8),
        );
        canvas.drawRRect(rect, strokePaint);

        // Add small dots at corners
        final dotPaint = Paint()
          ..color = primaryColor.withValues(alpha: 0.015)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), 2, dotPaint);
        canvas.drawCircle(Offset(x + tileSize * 0.6, y), 2, dotPaint);
        canvas.drawCircle(Offset(x, y + tileSize * 0.6), 2, dotPaint);
        canvas.drawCircle(
          Offset(x + tileSize * 0.6, y + tileSize * 0.6),
          2,
          dotPaint,
        );
      }
    }

    // Add diagonal accent lines
    final accentPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.01)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (double i = -size.width; i < size.width * 2; i += 120) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
