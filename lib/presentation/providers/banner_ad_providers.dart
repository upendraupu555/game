import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import 'theme_providers.dart';
import 'payment_providers.dart';

/// Banner ad state model
class BannerAdState {
  final bool isLoaded;
  final bool isLoading;
  final String? error;
  final BannerAd? bannerAd;

  const BannerAdState({
    this.isLoaded = false,
    this.isLoading = false,
    this.error,
    this.bannerAd,
  });

  BannerAdState copyWith({
    bool? isLoaded,
    bool? isLoading,
    String? error,
    BannerAd? bannerAd,
  }) {
    return BannerAdState(
      isLoaded: isLoaded ?? this.isLoaded,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      bannerAd: bannerAd ?? this.bannerAd,
    );
  }
}

/// Banner ad notifier following clean architecture principles
class BannerAdNotifier extends StateNotifier<BannerAdState> {
  final Ref _ref;

  BannerAdNotifier(this._ref) : super(const BannerAdState()) {
    _loadBannerAd();
  }

  /// Load banner ad following the official documentation
  void _loadBannerAd() {
    if (state.isLoading) return;

    // Check if ads are removed before loading
    final areAdsRemoved = _ref.read(areAdsRemovedProvider);
    if (areAdsRemoved) {
      AppLogger.debug(
        'Ads are removed, skipping banner ad load',
        tag: 'BannerAdProvider',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          AppLogger.debug(
            'Banner ad loaded successfully',
            tag: 'BannerAdProvider',
          );
          state = state.copyWith(
            isLoaded: true,
            isLoading: false,
            bannerAd: ad as BannerAd,
          );
        },
        onAdFailedToLoad: (ad, error) {
          AppLogger.error(
            'Banner ad failed to load',
            tag: 'BannerAdProvider',
            error: error,
          );
          ad.dispose();
          state = state.copyWith(
            isLoaded: false,
            isLoading: false,
            error: error.message,
          );
        },
        onAdOpened: (ad) {
          AppLogger.debug('Banner ad opened', tag: 'BannerAdProvider');
        },
        onAdClosed: (ad) {
          AppLogger.debug('Banner ad closed', tag: 'BannerAdProvider');
        },
        onAdImpression: (ad) {
          AppLogger.debug('Banner ad impression', tag: 'BannerAdProvider');
        },
        onAdClicked: (ad) {
          AppLogger.debug('Banner ad clicked', tag: 'BannerAdProvider');
        },
      ),
    );

    bannerAd.load();
  }

  /// Reload the banner ad
  void reloadAd() {
    // Dispose current ad if exists
    state.bannerAd?.dispose();

    // Reset state and load new ad
    state = const BannerAdState();
    _loadBannerAd();
  }

  /// Dispose of the banner ad
  @override
  void dispose() {
    state.bannerAd?.dispose();
    super.dispose();
  }
}

/// Banner ad provider
final bannerAdProvider = StateNotifierProvider<BannerAdNotifier, BannerAdState>(
  (ref) {
    return BannerAdNotifier(ref);
  },
);

/// Computed providers for UI convenience
final bannerAdLoadedProvider = Provider<bool>((ref) {
  final adState = ref.watch(bannerAdProvider);
  return adState.isLoaded;
});

final bannerAdLoadingProvider = Provider<bool>((ref) {
  final adState = ref.watch(bannerAdProvider);
  return adState.isLoading;
});

final bannerAdErrorProvider = Provider<String?>((ref) {
  final adState = ref.watch(bannerAdProvider);
  return adState.error;
});

final bannerAdWidgetProvider = Provider<BannerAd?>((ref) {
  final adState = ref.watch(bannerAdProvider);
  final areAdsRemoved = ref.watch(areAdsRemovedProvider);

  // Return null if ads are removed
  if (areAdsRemoved) {
    return null;
  }

  return adState.bannerAd;
});

/// Provider to check if banner ads should be shown
final shouldShowBannerAdProvider = Provider<bool>((ref) {
  final areAdsRemoved = ref.watch(areAdsRemovedProvider);
  final adState = ref.watch(bannerAdProvider);

  return !areAdsRemoved && adState.isLoaded;
});

// ==================== INTERSTITIAL AD PROVIDERS ====================

/// Interstitial ad state model
class InterstitialAdState {
  final bool isLoaded;
  final bool isLoading;
  final bool isShowing;
  final String? error;
  final InterstitialAd? interstitialAd;
  final int completedGamesCount;
  final DateTime? lastInterstitialShown;

  const InterstitialAdState({
    this.isLoaded = false,
    this.isLoading = false,
    this.isShowing = false,
    this.error,
    this.interstitialAd,
    this.completedGamesCount = 0,
    this.lastInterstitialShown,
  });

  InterstitialAdState copyWith({
    bool? isLoaded,
    bool? isLoading,
    bool? isShowing,
    String? error,
    InterstitialAd? interstitialAd,
    int? completedGamesCount,
    DateTime? lastInterstitialShown,
  }) {
    return InterstitialAdState(
      isLoaded: isLoaded ?? this.isLoaded,
      isLoading: isLoading ?? this.isLoading,
      isShowing: isShowing ?? this.isShowing,
      error: error ?? this.error,
      interstitialAd: interstitialAd ?? this.interstitialAd,
      completedGamesCount: completedGamesCount ?? this.completedGamesCount,
      lastInterstitialShown:
          lastInterstitialShown ?? this.lastInterstitialShown,
    );
  }

  /// Check if interstitial ad should be shown based on completed games count
  bool shouldShowInterstitial(bool areAdsRemoved) {
    return !areAdsRemoved &&
        isLoaded &&
        completedGamesCount > 0 &&
        completedGamesCount % AppConstants.interstitialAdTriggerGameCount == 0;
  }
}

/// Interstitial ad notifier following clean architecture principles
class InterstitialAdNotifier extends StateNotifier<InterstitialAdState> {
  final Ref _ref;

  InterstitialAdNotifier(this._ref) : super(const InterstitialAdState()) {
    _loadCompletedGamesCount();
    _loadInterstitialAd();
  }

  /// Load completed games count from SharedPreferences
  Future<void> _loadCompletedGamesCount() async {
    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      final count = prefs.getInt(AppConstants.adCompletedGamesCountKey) ?? 0;
      final lastShownTimestamp = prefs.getInt(
        AppConstants.adLastInterstitialShownKey,
      );
      final lastShown = lastShownTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(lastShownTimestamp)
          : null;

      state = state.copyWith(
        completedGamesCount: count,
        lastInterstitialShown: lastShown,
      );

      AppLogger.debug(
        'Loaded completed games count: $count',
        tag: 'InterstitialAdProvider',
      );
    } catch (error) {
      AppLogger.error(
        'Failed to load completed games count',
        tag: 'InterstitialAdProvider',
        error: error,
      );
    }
  }

  /// Load interstitial ad following the official documentation
  Future<void> _loadInterstitialAd() async {
    if (state.isLoading) return;

    // Check if ads are removed before loading
    final areAdsRemoved = _ref.read(areAdsRemovedProvider);
    if (areAdsRemoved) {
      AppLogger.debug(
        'Ads are removed, skipping interstitial ad load',
        tag: 'InterstitialAdProvider',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    AppLogger.debug(
      'Loading interstitial ad...',
      tag: 'InterstitialAdProvider',
    );

    try {
      await InterstitialAd.load(
        adUnitId: AppConstants.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            AppLogger.debug(
              'Interstitial ad loaded successfully',
              tag: 'InterstitialAdProvider',
            );

            // Set up full screen content callback
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                AppLogger.debug(
                  'Interstitial ad showed full screen',
                  tag: 'InterstitialAdProvider',
                );
                state = state.copyWith(isShowing: true);
              },
              onAdDismissedFullScreenContent: (ad) {
                AppLogger.debug(
                  'Interstitial ad dismissed',
                  tag: 'InterstitialAdProvider',
                );
                ad.dispose();
                state = state.copyWith(
                  isLoaded: false,
                  isShowing: false,
                  interstitialAd: null,
                );
                // Preload next interstitial ad
                _loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                AppLogger.error(
                  'Interstitial ad failed to show',
                  tag: 'InterstitialAdProvider',
                  error: error,
                );
                ad.dispose();
                state = state.copyWith(
                  isLoaded: false,
                  isShowing: false,
                  interstitialAd: null,
                  error: error.message,
                );
                // Retry loading
                Future.delayed(AppConstants.adRetryDelay, _loadInterstitialAd);
              },
              onAdClicked: (ad) {
                AppLogger.debug(
                  'Interstitial ad clicked',
                  tag: 'InterstitialAdProvider',
                );
              },
            );

            state = state.copyWith(
              isLoaded: true,
              isLoading: false,
              interstitialAd: ad,
            );
          },
          onAdFailedToLoad: (error) {
            AppLogger.error(
              'Interstitial ad failed to load',
              tag: 'InterstitialAdProvider',
              error: error,
            );
            state = state.copyWith(
              isLoaded: false,
              isLoading: false,
              error: error.message,
            );
            // Retry loading after delay
            Future.delayed(AppConstants.adRetryDelay, _loadInterstitialAd);
          },
        ),
      );
    } catch (error) {
      AppLogger.error(
        'Interstitial ad loading error',
        tag: 'InterstitialAdProvider',
        error: error,
      );
      state = state.copyWith(
        isLoaded: false,
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  /// Increment completed games count and save to SharedPreferences
  Future<void> incrementCompletedGamesCount() async {
    try {
      final newCount = state.completedGamesCount + 1;
      final prefs = _ref.read(sharedPreferencesProvider);
      await prefs.setInt(AppConstants.adCompletedGamesCountKey, newCount);

      state = state.copyWith(completedGamesCount: newCount);

      final areAdsRemoved = _ref.read(areAdsRemovedProvider);
      AppLogger.info(
        'Game completed! Total: $newCount',
        tag: 'InterstitialAdProvider',
        data: {
          'completedGamesCount': newCount,
          'shouldShowAd': state.shouldShowInterstitial(areAdsRemoved),
          'areAdsRemoved': areAdsRemoved,
        },
      );
    } catch (error) {
      AppLogger.error(
        'Failed to increment completed games count',
        tag: 'InterstitialAdProvider',
        error: error,
      );
    }
  }

  /// Show interstitial ad if ready and conditions are met
  Future<bool> showInterstitialAd() async {
    final areAdsRemoved = _ref.read(areAdsRemovedProvider);
    final shouldShow = state.shouldShowInterstitial(areAdsRemoved);

    if (!shouldShow || state.interstitialAd == null || state.isShowing) {
      AppLogger.debug(
        'Interstitial ad not ready to show',
        tag: 'InterstitialAdProvider',
        data: {
          'shouldShow': shouldShow,
          'areAdsRemoved': areAdsRemoved,
          'hasAd': state.interstitialAd != null,
          'isShowing': state.isShowing,
        },
      );
      return false;
    }

    try {
      AppLogger.info(
        'Showing interstitial ad after ${state.completedGamesCount} completed games',
        tag: 'InterstitialAdProvider',
      );

      // Record when interstitial was shown
      final prefs = _ref.read(sharedPreferencesProvider);
      final now = DateTime.now();
      await prefs.setInt(
        AppConstants.adLastInterstitialShownKey,
        now.millisecondsSinceEpoch,
      );

      state = state.copyWith(lastInterstitialShown: now);

      await state.interstitialAd!.show();
      return true;
    } catch (error) {
      AppLogger.error(
        'Failed to show interstitial ad',
        tag: 'InterstitialAdProvider',
        error: error,
      );
      return false;
    }
  }

  /// Check if interstitial ad should be shown
  bool get shouldShowInterstitial {
    final areAdsRemoved = _ref.read(areAdsRemovedProvider);
    return state.shouldShowInterstitial(areAdsRemoved);
  }

  /// Reload the interstitial ad
  void reloadAd() {
    // Dispose current ad if exists
    state.interstitialAd?.dispose();

    // Reset state and load new ad
    state = state.copyWith(
      isLoaded: false,
      isLoading: false,
      isShowing: false,
      interstitialAd: null,
      error: null,
    );
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    state.interstitialAd?.dispose();
    super.dispose();
  }
}

/// Interstitial ad provider
final interstitialAdProvider =
    StateNotifierProvider<InterstitialAdNotifier, InterstitialAdState>((ref) {
      return InterstitialAdNotifier(ref);
    });

/// Computed providers for UI convenience
final interstitialAdLoadedProvider = Provider<bool>((ref) {
  final adState = ref.watch(interstitialAdProvider);
  return adState.isLoaded;
});

final interstitialAdLoadingProvider = Provider<bool>((ref) {
  final adState = ref.watch(interstitialAdProvider);
  return adState.isLoading;
});

final interstitialAdShowingProvider = Provider<bool>((ref) {
  final adState = ref.watch(interstitialAdProvider);
  return adState.isShowing;
});

final shouldShowInterstitialProvider = Provider<bool>((ref) {
  final adState = ref.watch(interstitialAdProvider);
  final areAdsRemoved = ref.watch(areAdsRemovedProvider);
  return adState.shouldShowInterstitial(areAdsRemoved);
});

final completedGamesCountProvider = Provider<int>((ref) {
  final adState = ref.watch(interstitialAdProvider);
  return adState.completedGamesCount;
});

final interstitialAdErrorProvider = Provider<String?>((ref) {
  final adState = ref.watch(interstitialAdProvider);
  return adState.error;
});
