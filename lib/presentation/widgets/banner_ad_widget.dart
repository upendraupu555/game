import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../providers/theme_providers.dart';

/// Banner advertisement widget following the official Flutter Google Mobile Ads documentation
/// Displays at the bottom of the game screen with theme integration
class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  /// Load the banner ad following the official documentation pattern
  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          AppLogger.debug('Banner ad loaded successfully', tag: 'BannerAd');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          AppLogger.error(
            'Banner ad failed to load',
            tag: 'BannerAd',
            error: err,
          );
          // Dispose the ad here to free resources.
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {
          AppLogger.debug('Banner ad opened', tag: 'BannerAd');
        },
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {
          AppLogger.debug('Banner ad closed', tag: 'BannerAd');
        },
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {
          AppLogger.debug('Banner ad impression', tag: 'BannerAd');
        },
        // Called when a click is recorded for an ad.
        onAdClicked: (Ad ad) {
          AppLogger.debug('Banner ad clicked', tag: 'BannerAd');
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if the ad isn't loaded
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    // Get current theme colors for integration
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: AppConstants.bannerAdHeight + (AppConstants.bannerAdMargin * 2),
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.bannerAdMargin,
        vertical: AppConstants.bannerAdMargin / 2,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[900]?.withValues(alpha: 0.8)
            : Colors.grey[100]?.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(
          color: currentPrimaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        child: Center(child: AdWidget(ad: _bannerAd!)),
      ),
    );
  }
}

/// Compact banner ad widget for smaller spaces
class CompactBannerAdWidget extends ConsumerWidget {
  const CompactBannerAdWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox(
      height: AppConstants.bannerAdHeight + (AppConstants.bannerAdMargin * 2),
      child: BannerAdWidget(),
    );
  }
}

/// Banner ad placeholder widget for loading states
class BannerAdPlaceholder extends ConsumerWidget {
  const BannerAdPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: AppConstants.bannerAdHeight + (AppConstants.bannerAdMargin * 2),
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.bannerAdMargin,
        vertical: AppConstants.bannerAdMargin / 2,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[800]?.withValues(alpha: 0.5)
            : Colors.grey[200]?.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(
          color: currentPrimaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  currentPrimaryColor.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading ad...',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
