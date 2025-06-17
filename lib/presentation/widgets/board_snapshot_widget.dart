import 'package:flutter/material.dart';
import '../../domain/entities/leaderboard_entity.dart';

/// Widget for displaying a miniature board snapshot in leaderboard entries
class BoardSnapshotWidget extends StatelessWidget {
  final List<List<TileSnapshot?>> boardSnapshot;
  final double size;
  final bool showBorder;

  const BoardSnapshotWidget({
    super.key,
    required this.boardSnapshot,
    this.size = 80.0,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    // Validate board snapshot data
    if (boardSnapshot.isEmpty ||
        boardSnapshot.length != 5 ||
        boardSnapshot.any((row) => row.length != 5)) {
      return _buildMainErrorWidget();
    }

    // Validate size parameter to prevent type casting issues
    final safeSize = size.isFinite && size > 0 ? size : 80.0;
    final tileSize = (safeSize - 20) / 5; // 5x5 grid with padding

    // Wrap entire widget in try-catch to handle any type casting issues
    try {
      return Container(
        width: safeSize,
        height: safeSize,
        decoration: BoxDecoration(
          color: const Color(0xFFBBADA0),
          borderRadius: BorderRadius.circular(6),
          border: showBorder
              ? Border.all(color: Colors.grey.shade300, width: 1)
              : null,
          boxShadow: showBorder
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: _buildSafeGridView(tileSize),
        ),
      );
    } catch (e) {
      // Complete fallback if any part of the widget fails
      return _buildMainErrorWidget();
    }
  }

  /// Build a safe grid layout without using GridView to avoid scroll position issues
  Widget _buildSafeGridView(double tileSize) {
    try {
      // Use Column and Row layout instead of GridView to avoid scroll position issues
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (row) {
          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (col) {
                try {
                  // Additional bounds checking
                  if (row >= boardSnapshot.length ||
                      col >= boardSnapshot[row].length) {
                    return Expanded(child: _buildMainErrorTile(tileSize));
                  }

                  final tile = boardSnapshot[row][col];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: _buildTile(tile, tileSize),
                    ),
                  );
                } catch (e) {
                  return Expanded(child: _buildMainErrorTile(tileSize));
                }
              }),
            ),
          );
        }),
      );
    } catch (e) {
      // Fallback to a simple error display if grid layout fails
      return Center(
        child: Icon(Icons.error, color: Colors.red, size: tileSize * 2),
      );
    }
  }

  /// Build error widget when board data is invalid
  Widget _buildMainErrorWidget() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(6),
        border: showBorder
            ? Border.all(color: Colors.grey.shade300, width: 1)
            : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(height: 8),
            Text(
              'Board data\ncorrupted',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error tile for individual grid items
  Widget _buildMainErrorTile(double tileSize) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFCDC1B4),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Icon(Icons.error, color: Colors.red, size: tileSize * 0.4),
      ),
    );
  }

  Widget _buildTile(TileSnapshot? tile, double tileSize) {
    if (tile == null) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFCDC1B4),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    // Add defensive programming to handle potential data corruption
    try {
      final backgroundColor = Color(tile.colorValue);
      final textColor = Color(tile.textColorValue);
      final displayValue = _getDisplayValue(tile.value);

      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(
          child: tile.isBlocker
              ? Icon(Icons.block, color: textColor, size: tileSize * 0.4)
              : Text(
                  displayValue,
                  style: TextStyle(
                    color: textColor,
                    fontSize: _getFontSize(tile.value, tileSize),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      );
    } catch (e) {
      // Fallback for corrupted tile data
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFCDC1B4),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(
          child: Icon(Icons.error, color: Colors.red, size: tileSize * 0.4),
        ),
      );
    }
  }

  String _getDisplayValue(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }

  double _getFontSize(int value, double tileSize) {
    // Adjust font size based on tile size and value length
    final baseSize = tileSize * 0.25;

    if (value >= 1000000) {
      return baseSize * 0.7; // Smaller for millions
    } else if (value >= 10000) {
      return baseSize * 0.8; // Smaller for 10k+
    } else if (value >= 1000) {
      return baseSize * 0.9; // Slightly smaller for 1k+
    } else if (value >= 100) {
      return baseSize * 0.95; // Slightly smaller for 100+
    }

    return baseSize;
  }
}

/// Compact version of board snapshot for smaller displays
class CompactBoardSnapshotWidget extends StatelessWidget {
  final List<List<TileSnapshot?>> boardSnapshot;
  final double size;

  const CompactBoardSnapshotWidget({
    super.key,
    required this.boardSnapshot,
    this.size = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    // Validate board snapshot data
    if (boardSnapshot.isEmpty ||
        boardSnapshot.length != 5 ||
        boardSnapshot.any((row) => row.length != 5)) {
      return _buildErrorWidget();
    }

    // Validate size parameter to prevent type casting issues
    final safeSize = size.isFinite && size > 0 ? size : 60.0;

    // Wrap entire widget in try-catch to handle any type casting issues
    try {
      return Container(
        width: safeSize,
        height: safeSize,
        decoration: BoxDecoration(
          color: const Color(0xFFBBADA0),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade400, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: _buildSafeCompactGridView(),
        ),
      );
    } catch (e) {
      // Complete fallback if any part of the widget fails
      return _buildErrorWidget();
    }
  }

  /// Build a safe grid layout without using GridView to avoid scroll position issues
  Widget _buildSafeCompactGridView() {
    try {
      // Use Column and Row layout instead of GridView to avoid scroll position issues
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (row) {
          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (col) {
                try {
                  // Additional bounds checking
                  if (row >= boardSnapshot.length ||
                      col >= boardSnapshot[row].length) {
                    return Expanded(child: _buildErrorTile());
                  }

                  final tile = boardSnapshot[row][col];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(0.5),
                      child: _buildCompactTile(tile),
                    ),
                  );
                } catch (e) {
                  return Expanded(child: _buildErrorTile());
                }
              }),
            ),
          );
        }),
      );
    } catch (e) {
      // Fallback to a simple error display if grid layout fails
      return const Center(
        child: Icon(Icons.error, color: Colors.red, size: 12),
      );
    }
  }

  /// Build error widget when board data is invalid
  Widget _buildErrorWidget() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: const Center(
        child: Icon(Icons.error, color: Colors.red, size: 16),
      ),
    );
  }

  /// Build error tile for individual grid items
  Widget _buildErrorTile() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFCDC1B4),
        borderRadius: BorderRadius.circular(1),
      ),
      child: const Center(child: Icon(Icons.error, color: Colors.red, size: 4)),
    );
  }

  Widget _buildCompactTile(TileSnapshot? tile) {
    if (tile == null) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFCDC1B4),
          borderRadius: BorderRadius.circular(1),
        ),
      );
    }

    // Add defensive programming to handle potential data corruption
    try {
      final backgroundColor = Color(tile.colorValue);

      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(1),
        ),
        child: tile.isBlocker
            ? Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(1),
                ),
                child: const Center(
                  child: Icon(Icons.block, color: Colors.white, size: 6),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
      );
    } catch (e) {
      // Fallback for corrupted tile data
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFCDC1B4),
          borderRadius: BorderRadius.circular(1),
        ),
        child: const Center(
          child: Icon(Icons.error, color: Colors.red, size: 4),
        ),
      );
    }
  }
}

/// Preview widget for showing board snapshot with hover effects
class BoardSnapshotPreview extends StatefulWidget {
  final List<List<TileSnapshot?>> boardSnapshot;
  final double size;
  final VoidCallback? onTap;

  const BoardSnapshotPreview({
    super.key,
    required this.boardSnapshot,
    this.size = 80.0,
    this.onTap,
  });

  @override
  State<BoardSnapshotPreview> createState() => _BoardSnapshotPreviewState();
}

class _BoardSnapshotPreviewState extends State<BoardSnapshotPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: BoardSnapshotWidget(
                boardSnapshot: widget.boardSnapshot,
                size: widget.size,
                showBorder: true,
              ),
            );
          },
        ),
      ),
    );
  }

  void _onHover(bool isHovered) {
    if (_isHovered != isHovered) {
      _isHovered = isHovered;
      if (isHovered) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }
}
