import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../providers/banner_ad_providers.dart';

/// Service for managing interstitial advertisements
/// Handles the timing and display of full-screen ads after game completion
class InterstitialAdService {
  static final InterstitialAdService _instance = InterstitialAdService._internal();
  factory InterstitialAdService() => _instance;
  InterstitialAdService._internal();

  WidgetRef? _ref;
  bool _isShowingAd = false;

  /// Initialize the service with a WidgetRef
  void initialize(WidgetRef ref) {
    _ref = ref;
  }

  /// Handle game completion and potentially show an interstitial ad
  Future<void> handleGameCompletion({
    required BuildContext context,
    VoidCallback? onAdCompleted,
  }) async {
    if (_ref == null) {
      AppLogger.warning('⚠️ InterstitialAdService not initialized', tag: 'InterstitialAdService');
      onAdCompleted?.call();
      return;
    }

    if (_isShowingAd) {
      AppLogger.debug('🚫 Interstitial ad already showing', tag: 'InterstitialAdService');
      onAdCompleted?.call();
      return;
    }

    try {
      // Increment game completion count
      await _ref!.read(interstitialAdProvider.notifier).incrementCompletedGamesCount();
      
      // Check if ad should be shown
      final shouldShowAd = _ref!.read(shouldShowInterstitialProvider);
      
      if (shouldShowAd) {
        await _showInterstitialAdWithDelay(context, onAdCompleted);
      } else {
        AppLogger.debug('🎮 Game completed - no ad to show', tag: 'InterstitialAdService');
        onAdCompleted?.call();
      }
    } catch (error) {
      AppLogger.error('❌ Error handling game completion', tag: 'InterstitialAdService', error: error);
      onAdCompleted?.call();
    }
  }

  /// Show interstitial ad with a delay for better UX
  Future<void> _showInterstitialAdWithDelay(
    BuildContext context,
    VoidCallback? onAdCompleted,
  ) async {
    if (_ref == null) return;

    try {
      _isShowingAd = true;
      
      // Add a small delay before showing the ad for better UX
      await Future.delayed(AppConstants.adDisplayDelay);
      
      // Check if the context is still valid
      if (!context.mounted) {
        _isShowingAd = false;
        onAdCompleted?.call();
        return;
      }

      AppLogger.info('📺 Showing interstitial ad after game completion', tag: 'InterstitialAdService');
      
      // Show the interstitial ad
      final success = await _ref!.read(interstitialAdProvider.notifier).showInterstitialAd();
      
      if (success) {
        // Wait a bit for the ad to be dismissed
        await Future.delayed(const Duration(seconds: 1));
      } else {
        AppLogger.warning('⚠️ Failed to show interstitial ad', tag: 'InterstitialAdService');
      }
      
    } catch (error) {
      AppLogger.error('❌ Error showing interstitial ad', tag: 'InterstitialAdService', error: error);
    } finally {
      _isShowingAd = false;
      onAdCompleted?.call();
    }
  }

  /// Manually trigger an interstitial ad (for testing or special cases)
  Future<bool> showInterstitialAd(BuildContext context) async {
    if (_ref == null) {
      AppLogger.warning('⚠️ InterstitialAdService not initialized', tag: 'InterstitialAdService');
      return false;
    }

    if (_isShowingAd) {
      AppLogger.debug('🚫 Interstitial ad already showing', tag: 'InterstitialAdService');
      return false;
    }

    try {
      _isShowingAd = true;
      
      AppLogger.info('📺 Manually showing interstitial ad', tag: 'InterstitialAdService');
      
      final success = await _ref!.read(interstitialAdProvider.notifier).showInterstitialAd();
      
      return success;
    } catch (error) {
      AppLogger.error('❌ Error manually showing interstitial ad', tag: 'InterstitialAdService', error: error);
      return false;
    } finally {
      _isShowingAd = false;
    }
  }

  /// Check if an interstitial ad is currently being shown
  bool get isShowingAd => _isShowingAd;

  /// Get the current completed games count
  int getCompletedGamesCount() {
    if (_ref == null) return 0;
    return _ref!.read(completedGamesCountProvider);
  }

  /// Check if the next game completion will trigger an ad
  bool willNextGameTriggerAd() {
    final currentCount = getCompletedGamesCount();
    final nextCount = currentCount + 1;
    return nextCount % AppConstants.interstitialAdTriggerGameCount == 0;
  }

  /// Get how many more games until the next ad
  int gamesUntilNextAd() {
    final currentCount = getCompletedGamesCount();
    final remainder = currentCount % AppConstants.interstitialAdTriggerGameCount;
    return AppConstants.interstitialAdTriggerGameCount - remainder;
  }

  /// Check if ads are currently enabled
  bool isAdEnabled() {
    if (_ref == null) return true;
    return _ref!.read(interstitialAdLoadedProvider) || _ref!.read(interstitialAdLoadingProvider);
  }

  /// Dispose of the service
  void dispose() {
    _ref = null;
    _isShowingAd = false;
  }
}

/// Widget that provides interstitial ad service to its children
class InterstitialAdServiceProvider extends ConsumerWidget {
  final Widget child;

  const InterstitialAdServiceProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize the service with the current ref
    InterstitialAdService().initialize(ref);
    
    return child;
  }
}

/// Mixin for widgets that need to handle game completion with ads
mixin GameCompletionAdMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  
  /// Handle game completion with potential ad display
  Future<void> handleGameCompletionWithAd({
    VoidCallback? onCompleted,
  }) async {
    await InterstitialAdService().handleGameCompletion(
      context: context,
      onAdCompleted: onCompleted,
    );
  }

  /// Check if the next game will trigger an ad
  bool get willNextGameTriggerAd => InterstitialAdService().willNextGameTriggerAd();

  /// Get games remaining until next ad
  int get gamesUntilNextAd => InterstitialAdService().gamesUntilNextAd();
}
