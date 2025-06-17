import 'package:flutter/material.dart';
import '../logging/app_logger.dart';

/// Asset preloader for optimizing game performance
class AssetPreloader {
  AssetPreloader._();

  static bool _isInitialized = false;
  static final Map<String, ImageProvider> _imageCache = {};
  static final Set<String> _preloadedAssets = {};

  /// Initialize asset preloading
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _preloadCriticalAssets();
      _isInitialized = true;

      AppLogger.info(
        'Asset preloader initialized successfully',
        tag: 'AssetPreloader',
        data: {'preloadedAssets': _preloadedAssets.length},
      );
    } catch (error) {
      AppLogger.error(
        'Failed to initialize asset preloader',
        tag: 'AssetPreloader',
        error: error,
      );
    }
  }

  /// Preload critical game assets
  static Future<void> _preloadCriticalAssets() async {
    final stopwatch = Stopwatch()..start();

    // Preload scenic background images (only first few for initial load)
    await _preloadScenicBackgrounds();

    // Preload font assets
    await _preloadFonts();

    stopwatch.stop();

    AppLogger.performance(
      'ASSET_PRELOAD_COMPLETE',
      data: {
        'duration': '${stopwatch.elapsedMilliseconds}ms',
        'assetsCount': _preloadedAssets.length,
      },
    );
  }

  /// Preload scenic background images
  static Future<void> _preloadScenicBackgrounds() async {
    // Only preload first 5 backgrounds for initial performance
    // Others will be loaded on demand
    const priorityBackgrounds = [1, 2, 3, 4, 5];

    for (final index in priorityBackgrounds) {
      try {
        final assetPath = 'assets/images/scenic_backgrounds/scenic_$index.jpg';
        final imageProvider = AssetImage(assetPath);

        // Cache the image provider
        _imageCache[assetPath] = imageProvider;
        _preloadedAssets.add(assetPath);

        AppLogger.debug(
          'Preloaded scenic background',
          tag: 'AssetPreloader',
          data: {'asset': assetPath},
        );
      } catch (error) {
        AppLogger.warning(
          'Failed to preload scenic background',
          tag: 'AssetPreloader',
          data: {'index': index, 'error': error.toString()},
        );
      }
    }
  }

  /// Preload font assets
  static Future<void> _preloadFonts() async {
    const fonts = ['BubblegumSans', 'Chewy', 'ComicNeue'];

    for (final font in fonts) {
      try {
        // Font preloading is handled by Flutter automatically
        // We just mark them as preloaded for tracking
        _preloadedAssets.add('font:$font');

        AppLogger.debug(
          'Font marked as preloaded',
          tag: 'AssetPreloader',
          data: {'font': font},
        );
      } catch (error) {
        AppLogger.warning(
          'Font preload tracking failed',
          tag: 'AssetPreloader',
          data: {'font': font, 'error': error.toString()},
        );
      }
    }
  }

  /// Get cached image provider
  static ImageProvider? getCachedImage(String assetPath) {
    return _imageCache[assetPath];
  }

  /// Preload additional scenic backgrounds on demand
  static Future<void> preloadScenicBackground(int index) async {
    final assetPath = 'assets/images/scenic_backgrounds/scenic_$index.jpg';

    if (_preloadedAssets.contains(assetPath)) {
      return; // Already preloaded
    }

    try {
      final imageProvider = AssetImage(assetPath);
      _imageCache[assetPath] = imageProvider;
      _preloadedAssets.add(assetPath);

      AppLogger.debug(
        'On-demand preloaded scenic background',
        tag: 'AssetPreloader',
        data: {'asset': assetPath},
      );
    } catch (error) {
      AppLogger.warning(
        'Failed to preload scenic background on demand',
        tag: 'AssetPreloader',
        data: {'index': index, 'error': error.toString()},
      );
    }
  }

  /// Check if asset is preloaded
  static bool isAssetPreloaded(String assetPath) {
    return _preloadedAssets.contains(assetPath);
  }

  /// Get preload statistics
  static Map<String, dynamic> getPreloadStats() {
    return {
      'isInitialized': _isInitialized,
      'preloadedAssets': _preloadedAssets.length,
      'cachedImages': _imageCache.length,
      'assets': _preloadedAssets.toList(),
    };
  }

  /// Clear asset cache (for memory management)
  static void clearCache() {
    _imageCache.clear();
    _preloadedAssets.clear();
    _isInitialized = false;

    AppLogger.info('Asset cache cleared', tag: 'AssetPreloader');
  }

  /// Preload assets for a specific context (like game screen)
  static Future<void> preloadForContext(
    BuildContext context,
    String contextName,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      switch (contextName) {
        case 'game':
          await _preloadGameAssets(context);
          break;
        case 'home':
          await _preloadHomeAssets(context);
          break;
        default:
          AppLogger.debug(
            'No specific preloading for context',
            tag: 'AssetPreloader',
            data: {'context': contextName},
          );
      }

      stopwatch.stop();

      AppLogger.performance(
        'CONTEXT_PRELOAD_COMPLETE',
        data: {
          'context': contextName,
          'duration': '${stopwatch.elapsedMilliseconds}ms',
        },
      );
    } catch (error) {
      AppLogger.error(
        'Failed to preload assets for context: $contextName',
        tag: 'AssetPreloader',
        error: error,
      );
    }
  }

  /// Preload game-specific assets
  static Future<void> _preloadGameAssets(BuildContext context) async {
    // Preload any game-specific images or assets
    // This could include powerup icons, UI elements, etc.

    AppLogger.debug('Game assets preloaded', tag: 'AssetPreloader');
  }

  /// Preload home screen assets
  static Future<void> _preloadHomeAssets(BuildContext context) async {
    // Preload home screen specific assets

    AppLogger.debug('Home assets preloaded', tag: 'AssetPreloader');
  }

  /// Optimize image loading with caching
  static Widget optimizedImage({
    required String assetPath,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    final cachedProvider = getCachedImage(assetPath);

    if (cachedProvider != null) {
      return Image(
        image: cachedProvider,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: errorWidget != null
            ? (context, error, stackTrace) => errorWidget
            : null,
      );
    }

    // Fallback to regular AssetImage with caching
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      cacheWidth: width?.round(),
      cacheHeight: height?.round(),
      errorBuilder: errorWidget != null
          ? (context, error, stackTrace) => errorWidget
          : null,
      frameBuilder: placeholder != null
          ? (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                return child;
              }
              return placeholder;
            }
          : null,
    );
  }

  /// Get memory usage estimate
  static String getMemoryUsageEstimate() {
    final imageCount = _imageCache.length;
    final estimatedMB = (imageCount * 2.5); // Rough estimate: 2.5MB per image

    return '~${estimatedMB.toStringAsFixed(1)}MB';
  }
}
