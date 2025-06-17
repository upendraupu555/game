import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/navigation/navigation_service.dart';

import '../providers/user_providers.dart';
import '../providers/theme_providers.dart';
// TODO: Statistics section removed - game providers no longer needed
// import '../providers/game_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final themeState = ref.watch(themeProvider);
    // TODO: Statistics section removed from profile screen
    // final gameStatsState = ref.watch(gameStatisticsProvider);

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
          data: (user) =>
              _buildProfileContent(context, ref, user, primaryColor),
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

          // TODO: Statistics section removed from profile screen
          // _buildStatisticsPlaceholder(context, ref, primaryColor),
          // const SizedBox(height: AppConstants.paddingLarge),

          // Action Buttons
          if (!user.isAuthenticated)
            _buildGuestActions(context, ref, primaryColor),

          // Account Deletion Section (for authenticated users only)
          if (user.isAuthenticated) ...[
            const SizedBox(height: AppConstants.paddingLarge),
            _buildDangerZone(context, ref, user, primaryColor),
          ],
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

  Widget _buildDangerZone(
    BuildContext context,
    WidgetRef ref,
    user,
    Color primaryColor,
  ) {
    return Card(
      elevation: 2,
      color: Colors.red.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 20),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Danger Zone',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Once you delete your account, there is no going back. This action cannot be undone.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.red.shade700),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showDeleteAccountDialog(context, ref, user),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete Account'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TODO: Statistics section removed from profile screen
  // Uncomment these methods to restore statistics functionality
  /*
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
  */

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

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref, user) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            const SizedBox(width: AppConstants.paddingSmall),
            const Text('Delete Account'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            const Text('This action will:'),
            const SizedBox(height: AppConstants.paddingSmall),
            const Text('• Permanently delete your account'),
            const Text('• Remove all your game data'),
            const Text('• Clear your statistics and achievements'),
            const Text('• Cannot be undone'),
            const SizedBox(height: AppConstants.paddingMedium),
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'This action is irreversible!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _confirmDeleteAccount(context, ref, user),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref, user) {
    Navigator.of(context).pop(); // Close first dialog

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Type "DELETE" to confirm account deletion:'),
            const SizedBox(height: AppConstants.paddingMedium),
            TextField(
              onChanged: (value) {
                // Store the value for validation
              },
              decoration: const InputDecoration(
                hintText: 'Type DELETE here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _performAccountDeletion(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }

  void _performAccountDeletion(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop(); // Close confirmation dialog

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppConstants.paddingMedium),
            Text('Deleting account...'),
          ],
        ),
      ),
    );

    try {
      await ref.read(userProvider.notifier).deleteUserAccount();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show success message and navigate to home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home screen and clear stack
        NavigationService.pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (error) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
