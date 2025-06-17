import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/entities/font_entity.dart';
import '../../core/constants/app_constants.dart';
import '../providers/theme_providers.dart';
import '../providers/font_providers.dart';
import 'board_snapshot_widget.dart';

/// Expandable widget for displaying a single leaderboard entry using Material Design ListTile
class LeaderboardEntryWidget extends ConsumerStatefulWidget {
  final LeaderboardEntry entry;
  final int rank;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const LeaderboardEntryWidget({
    super.key,
    required this.entry,
    required this.rank,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  ConsumerState<LeaderboardEntryWidget> createState() =>
      _LeaderboardEntryWidgetState();
}

class _LeaderboardEntryWidgetState
    extends ConsumerState<LeaderboardEntryWidget> {
  @override
  Widget build(BuildContext context) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFont = ref.watch(currentFontProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Material(
        elevation: widget.isHighlighted ? 4 : 2,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: ExpansionTile(
          key: PageStorageKey('leaderboard_entry_${widget.entry.id}'),
          initiallyExpanded: false,
          onExpansionChanged: (expanded) {
            setState(() {});
            if (widget.onTap != null && expanded) {
              widget.onTap!();
            }
          },
          leading: _buildRankBadge(
            widget.rank,
            currentPrimaryColor,
            currentFont,
            isDarkMode,
          ),
          title: _buildTitle(currentFont, currentPrimaryColor, isDarkMode),
          subtitle: _buildSubtitle(currentFont, isDarkMode),
          trailing: _buildTrailing(currentPrimaryColor),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
          childrenPadding: const EdgeInsets.all(AppConstants.paddingMedium),
          backgroundColor: widget.isHighlighted
              ? currentPrimaryColor.withValues(alpha: 0.05)
              : null,
          collapsedBackgroundColor: widget.isHighlighted
              ? currentPrimaryColor.withValues(alpha: 0.03)
              : null,
          iconColor: currentPrimaryColor,
          collapsedIconColor: currentPrimaryColor,
          children: [
            _buildExpandedContent(currentFont, currentPrimaryColor, isDarkMode),
          ],
        ),
      ),
    );
  }

  /// Build the title for the ListTile (main game information)
  Widget _buildTitle(
    FontEntity? currentFont,
    Color primaryColor,
    bool isDarkMode,
  ) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Row(
      children: [
        // Score badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            widget.entry.formattedScore,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              fontFamily: currentFont?.fontFamily,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Game mode
        Expanded(
          child: Text(
            widget.entry.gameMode,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
              fontFamily: currentFont?.fontFamily,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Build the subtitle for the ListTile (additional metadata)
  Widget _buildSubtitle(FontEntity? currentFont, bool isDarkMode) {
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.access_time, size: 14, color: subtitleColor),
            const SizedBox(width: 4),
            Text(
              widget.entry.formattedDuration,
              style: TextStyle(
                fontSize: 12,
                color: subtitleColor,
                fontFamily: currentFont?.fontFamily,
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.calendar_today, size: 14, color: subtitleColor),
            const SizedBox(width: 4),
            Text(
              widget.entry.relativeDateString,
              style: TextStyle(
                fontSize: 12,
                color: subtitleColor,
                fontFamily: currentFont?.fontFamily,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build the trailing widget for the ListTile (expand/collapse indicator)
  Widget _buildTrailing(Color primaryColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Small board preview with error handling
        _buildSafeBoardPreview(32),
        const SizedBox(width: 8),
        // Expand/collapse icon is automatically handled by ExpansionTile
      ],
    );
  }

  /// Build a safe board preview with error handling
  Widget _buildSafeBoardPreview(double size) {
    try {
      // Validate board snapshot data
      if (widget.entry.boardSnapshot.isEmpty ||
          widget.entry.boardSnapshot.length != 5 ||
          widget.entry.boardSnapshot.any((row) => row.length != 5)) {
        return _buildErrorPreview(size);
      }

      return CompactBoardSnapshotWidget(
        boardSnapshot: widget.entry.boardSnapshot,
        size: size,
      );
    } catch (e) {
      return _buildErrorPreview(size);
    }
  }

  /// Build an error preview when board data is corrupted
  Widget _buildErrorPreview(double size) {
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

  /// Build a safe expanded board with error handling
  Widget _buildSafeExpandedBoard(
    FontEntity? currentFont,
    Color primaryColor,
    bool isDarkMode,
  ) {
    try {
      // Validate board snapshot data
      if (widget.entry.boardSnapshot.isEmpty ||
          widget.entry.boardSnapshot.length != 5 ||
          widget.entry.boardSnapshot.any((row) => row.length != 5)) {
        return _buildExpandedErrorBoard(currentFont, primaryColor, isDarkMode);
      }

      return BoardSnapshotWidget(
        boardSnapshot: widget.entry.boardSnapshot,
        size: 200, // Larger size for expanded view
        showBorder: true,
      );
    } catch (e) {
      return _buildExpandedErrorBoard(currentFont, primaryColor, isDarkMode);
    }
  }

  /// Build an error board for the expanded view
  Widget _buildExpandedErrorBoard(
    FontEntity? currentFont,
    Color primaryColor,
    bool isDarkMode,
  ) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(
            'Board data corrupted',
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontFamily: currentFont?.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build the expanded content showing the full game board
  Widget _buildExpandedContent(
    FontEntity? currentFont,
    Color primaryColor,
    bool isDarkMode,
  ) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          'Final Game Board',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
            fontFamily: currentFont?.fontFamily,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),

        // Full-size board snapshot with error handling
        Center(
          child: _buildSafeExpandedBoard(currentFont, primaryColor, isDarkMode),
        ),

        const SizedBox(height: AppConstants.paddingMedium),

        // Additional game details
        _buildGameMetadata(currentFont, primaryColor, isDarkMode),
      ],
    );
  }

  /// Build additional game metadata for the expanded view
  Widget _buildGameMetadata(
    FontEntity? currentFont,
    Color primaryColor,
    bool isDarkMode,
  ) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[800]?.withValues(alpha: 0.3)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Column(
        children: [
          _buildMetadataRow(
            'Game Mode',
            widget.entry.gameMode,
            Icons.gamepad,
            currentFont,
            textColor,
            subtitleColor,
          ),
          const SizedBox(height: 8),
          _buildMetadataRow(
            'Duration',
            widget.entry.formattedDuration,
            Icons.timer,
            currentFont,
            textColor,
            subtitleColor,
          ),
          const SizedBox(height: 8),
          _buildMetadataRow(
            'Date Played',
            widget.entry.absoluteDateString,
            Icons.calendar_today,
            currentFont,
            textColor,
            subtitleColor,
          ),
          if (widget.entry.customBaseNumber != null) ...[
            const SizedBox(height: 8),
            _buildMetadataRow(
              'Base Number',
              widget.entry.customBaseNumber.toString(),
              Icons.numbers,
              currentFont,
              textColor,
              subtitleColor,
            ),
          ],
          if (widget.entry.timeLimit != null) ...[
            const SizedBox(height: 8),
            _buildMetadataRow(
              'Time Limit',
              '${widget.entry.timeLimit}s',
              Icons.hourglass_bottom,
              currentFont,
              textColor,
              subtitleColor,
            ),
          ],
        ],
      ),
    );
  }

  /// Build a metadata row with icon, label, and value
  Widget _buildMetadataRow(
    String label,
    String value,
    IconData icon,
    FontEntity? currentFont,
    Color textColor,
    Color subtitleColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: subtitleColor),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: subtitleColor,
            fontFamily: currentFont?.fontFamily,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
              fontFamily: currentFont?.fontFamily,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankBadge(
    int rank,
    Color primaryColor,
    FontEntity? currentFont,
    bool isDarkMode,
  ) {
    Color badgeColor;
    Color textColor;
    IconData? icon;

    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFFD700); // Gold
        textColor = Colors.black;
        icon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = const Color(0xFFC0C0C0); // Silver
        textColor = Colors.black;
        icon = Icons.emoji_events;
        break;
      case 3:
        badgeColor = const Color(0xFFCD7F32); // Bronze
        textColor = Colors.white;
        icon = Icons.emoji_events;
        break;
      default:
        badgeColor = primaryColor;
        textColor = Colors.white;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: textColor, size: 20)
            : Text(
                rank.toString(),
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: currentFont?.fontFamily,
                ),
              ),
      ),
    );
  }
}

/// Compact version of leaderboard entry for smaller displays
class CompactLeaderboardEntryWidget extends ConsumerWidget {
  final LeaderboardEntry entry;
  final int rank;
  final VoidCallback? onTap;

  const CompactLeaderboardEntryWidget({
    super.key,
    required this.entry,
    required this.rank,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrimaryColor = ref.watch(currentPrimaryColorProvider);
    final currentFont = ref.watch(currentFontProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: 4,
      ),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            child: Row(
              children: [
                // Rank
                SizedBox(
                  width: 30,
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: currentPrimaryColor,
                      fontFamily: currentFont?.fontFamily,
                    ),
                  ),
                ),

                // Compact board snapshot
                CompactBoardSnapshotWidget(
                  boardSnapshot: entry.boardSnapshot,
                  size: 40,
                ),

                const SizedBox(width: AppConstants.paddingSmall),

                // Game info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.gameMode,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          fontFamily: currentFont?.fontFamily,
                        ),
                      ),
                      Text(
                        entry.relativeDateString,
                        style: TextStyle(
                          fontSize: 10,
                          color: textColor.withValues(alpha: 0.6),
                          fontFamily: currentFont?.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),

                // Score
                Text(
                  entry.formattedScore,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: currentPrimaryColor,
                    fontFamily: currentFont?.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
