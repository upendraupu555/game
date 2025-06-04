import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/navigation/navigation_service.dart';

import '../providers/user_providers.dart';
import '../providers/theme_providers.dart';
import '../providers/game_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final themeState = ref.watch(themeProvider);
    final gameStatsState = ref.watch(gameStatisticsProvider);

    final primaryColor = themeState.when(
      data: (theme) {
        final brightness = Theme.of(context).brightness;
        final colorEntity = brightness == Brightness.light
            ? theme.lightPrimaryColor
            : theme.darkPrimaryColor;
        return colorEntity.toFlutterColor();
      },
      loading: () => Theme.of(context).primaryColor,
      error: (_, __) => Theme.of(context).primaryColor,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.translate(ref, 'profile_title')),
        elevation: 0,
        actions: [
          userState.when(
            data: (user) => user.isAuthenticated
                ? IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _showLogoutDialog(context, ref),
                  )
                : IconButton(
                    icon: const Icon(Icons.login),
                    onPressed: () =>
                        NavigationService.pushNamed(AppRoutes.login),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: userState.when(
          data: (user) => _buildProfileContent(
            context,
            ref,
            user,
            primaryColor,
            gameStatsState,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: AppConstants.paddingMedium),
                Text('Error loading profile: $error'),
                const SizedBox(height: AppConstants.paddingMedium),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(userProvider.notifier).refreshUser(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    user,
    Color primaryColor,
    gameStatsState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Header
          _buildProfileHeader(context, ref, user, primaryColor),
          const SizedBox(height: AppConstants.paddingLarge),

          // User Information
          _buildUserInfoSection(context, ref, user, primaryColor),
          const SizedBox(height: AppConstants.paddingLarge),

          // Statistics Section
          _buildStatisticsPlaceholder(context, ref, primaryColor),
          const SizedBox(height: AppConstants.paddingLarge),

          // Action Buttons
          if (!user.isAuthenticated)
            _buildGuestActions(context, ref, primaryColor),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    user,
    Color primaryColor,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              child: Icon(
                user.isAuthenticated ? Icons.person : Icons.person_outline,
                size: 50,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              user.displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: user.isAuthenticated
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
                border: Border.all(
                  color: user.isAuthenticated ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Text(
                user.accountType,
                style: TextStyle(
                  color: user.isAuthenticated ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(
    BuildContext context,
    WidgetRef ref,
    user,
    Color primaryColor,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildInfoRow(
              context,
              LocalizationManager.translate(ref, 'game_id'),
              user.gameId,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildInfoRow(
              context,
              LocalizationManager.translate(ref, 'member_since'),
              user.formattedMemberSince,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildInfoRow(
              context,
              LocalizationManager.translate(ref, 'last_played'),
              user.formattedLastLogin,
            ),
            if (user.email != null) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              _buildInfoRow(
                context,
                LocalizationManager.translate(ref, 'email'),
                user.email!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildStatisticsPlaceholder(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationManager.translate(ref, 'user_statistics'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Column(
              children: [
                _buildStatRow(context, 'Games Played', '0'),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildStatRow(context, 'Games Won', '0'),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildStatRow(context, 'Best Score', '0'),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildStatRow(context, 'Win Rate', '0.0%'),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildStatRow(context, 'Average Score', '0'),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildStatRow(context, 'Total Play Time', '0s'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGuestActions(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
  ) {
    return Card(
      elevation: 2,
      color: primaryColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(Icons.account_circle_outlined, size: 48, color: primaryColor),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              LocalizationManager.translate(ref, 'sign_in_to_save'),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ElevatedButton(
              onPressed: () => NavigationService.pushNamed(AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                ),
              ),
              child: Text(LocalizationManager.translate(ref, 'sign_in')),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationManager.translate(ref, 'logout_confirmation')),
        content: Text(LocalizationManager.translate(ref, 'logout_warning')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationManager.translate(ref, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(userProvider.notifier).logoutUser();
            },
            child: Text(LocalizationManager.translate(ref, 'logout')),
          ),
        ],
      ),
    );
  }
}
