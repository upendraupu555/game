import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/performance_optimizer.dart';
import '../../core/constants/app_constants.dart';

/// Performance monitoring widget for development builds
class PerformanceMonitorWidget extends ConsumerStatefulWidget {
  final Widget child;
  final bool showOverlay;

  const PerformanceMonitorWidget({
    super.key,
    required this.child,
    this.showOverlay = false,
  });

  @override
  ConsumerState<PerformanceMonitorWidget> createState() =>
      _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState
    extends ConsumerState<PerformanceMonitorWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
      if (_isVisible) {
        _fadeController.forward();
      } else {
        _fadeController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode and when performance logging is enabled
    if (!kDebugMode || !AppConstants.enablePerformanceLogging) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,

        // Performance overlay
        if (widget.showOverlay)
          Positioned(
            top: 50,
            right: 16,
            child: RepaintBoundary(
              child: FadeTransition(
                opacity: _fadeController,
                child: _isVisible ? _buildPerformanceOverlay() : null,
              ),
            ),
          ),

        // Toggle button
        if (widget.showOverlay)
          Positioned(
            top: 50,
            right: 16,
            child: RepaintBoundary(
              child: FloatingActionButton.small(
                onPressed: _toggleVisibility,
                backgroundColor: Colors.black.withValues(alpha: 0.7),
                child: Icon(
                  _isVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPerformanceOverlay() {
    final fps = PerformanceOptimizer.getCurrentFPS();
    final isPerformant = PerformanceOptimizer.isPerformanceAcceptable();
    final activeAnimations = AnimationOptimizer.activeAnimationCount;
    final recommendations =
        PerformanceOptimizer.getPerformanceRecommendations();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPerformant ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.speed,
                color: isPerformant ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
                'Performance',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // FPS Display
          _buildMetricRow(
            'FPS',
            fps.toStringAsFixed(1),
            isPerformant ? Colors.green : Colors.red,
          ),

          // Active Animations
          _buildMetricRow(
            'Animations',
            '$activeAnimations/${AppConstants.maxConcurrentAnimations}',
            activeAnimations > AppConstants.maxConcurrentAnimations * 0.8
                ? Colors.orange
                : Colors.green,
          ),

          // Memory Usage (simplified)
          _buildMetricRow('Memory', 'OK', Colors.green),

          // Recommendations
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Recommendations:',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            ...recommendations
                .take(3)
                .map(
                  (rec) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '• $rec',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Performance statistics provider
final performanceStatsProvider = StateProvider<PerformanceStats>((ref) {
  return const PerformanceStats();
});

/// Performance statistics data class
class PerformanceStats {
  final double fps;
  final int activeAnimations;
  final bool isPerformant;
  final List<String> recommendations;

  const PerformanceStats({
    this.fps = 0.0,
    this.activeAnimations = 0,
    this.isPerformant = true,
    this.recommendations = const [],
  });

  PerformanceStats copyWith({
    double? fps,
    int? activeAnimations,
    bool? isPerformant,
    List<String>? recommendations,
  }) {
    return PerformanceStats(
      fps: fps ?? this.fps,
      activeAnimations: activeAnimations ?? this.activeAnimations,
      isPerformant: isPerformant ?? this.isPerformant,
      recommendations: recommendations ?? this.recommendations,
    );
  }
}

/// Performance monitoring service
class PerformanceMonitoringService {
  static Timer? _monitoringTimer;

  /// Start performance monitoring
  static void startMonitoring(WidgetRef ref) {
    if (!kDebugMode || !AppConstants.enablePerformanceLogging) return;

    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => _updatePerformanceStats(ref),
    );
  }

  /// Stop performance monitoring
  static void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  /// Update performance statistics
  static void _updatePerformanceStats(WidgetRef ref) {
    final fps = PerformanceOptimizer.getCurrentFPS();
    final isPerformant = PerformanceOptimizer.isPerformanceAcceptable();
    final activeAnimations = AnimationOptimizer.activeAnimationCount;
    final recommendations =
        PerformanceOptimizer.getPerformanceRecommendations();

    final stats = PerformanceStats(
      fps: fps,
      activeAnimations: activeAnimations,
      isPerformant: isPerformant,
      recommendations: recommendations,
    );

    ref.read(performanceStatsProvider.notifier).state = stats;
  }
}
