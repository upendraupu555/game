import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../domain/entities/powerup_entity.dart';

/// Comprehensive help screen documenting all game features and mechanics
class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.helpTitle(ref)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, ref),

            const SizedBox(height: AppConstants.paddingLarge),

            // Game Mechanics
            _buildGameMechanicsSection(context, ref),

            const SizedBox(height: AppConstants.paddingMedium),

            // Special Tiles
            _buildSpecialTilesSection(context, ref),

            const SizedBox(height: AppConstants.paddingMedium),

            // Powerup System
            _buildPowerupSystemSection(context, ref),

            const SizedBox(height: AppConstants.paddingMedium),

            // Game Modes
            _buildGameModesSection(context, ref),

            const SizedBox(height: AppConstants.paddingMedium),

            // Controls
            _buildControlsSection(context, ref),

            const SizedBox(height: AppConstants.paddingMedium),

            // Scoring
            _buildScoringSection(context, ref),

            const SizedBox(height: AppConstants.paddingMedium),

            // Tips & Strategies
            _buildTipsStrategiesSection(context, ref),

            const SizedBox(height: AppConstants.paddingMedium),

            // FAQ
            _buildFAQSection(context, ref),

            const SizedBox(height: AppConstants.paddingLarge),

            // Contact Support
            // _buildContactSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        children: [
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
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.help_outline,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            LocalizationManager.helpTitle(ref),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            LocalizationManager.helpDescription(ref),
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGameMechanicsSection(BuildContext context, WidgetRef ref) {
    return _buildHelpSection(
      context,
      ref,
      title: LocalizationManager.helpGameMechanics(ref),
      icon: Icons.grid_view,
      items: [
        '${LocalizationManager.helpBoardLayout(ref)}: ${LocalizationManager.helpBoardLayoutDesc(ref)}',
        '${LocalizationManager.helpBasicGameplay(ref)}: ${LocalizationManager.helpBasicGameplayDesc(ref)}',
        '${LocalizationManager.helpKeyboardControls(ref)}: ${LocalizationManager.helpKeyboardControlsDesc(ref)}',
        '${LocalizationManager.helpTileMovement(ref)}: ${LocalizationManager.helpTileMovementDesc(ref)}',
        '${LocalizationManager.helpMergingRules(ref)}: ${LocalizationManager.helpMergingRulesDesc(ref)}',
        '${LocalizationManager.helpWinCondition(ref)}: ${LocalizationManager.helpWinConditionDesc(ref)}',
        '${LocalizationManager.helpGameOver(ref)}: ${LocalizationManager.helpGameOverDesc(ref)}',
      ],
    );
  }

  Widget _buildSpecialTilesSection(BuildContext context, WidgetRef ref) {
    return _buildHelpSection(
      context,
      ref,
      title: LocalizationManager.helpSpecialTiles(ref),
      icon: Icons.block,
      items: [
        '${LocalizationManager.helpBlockerTiles(ref)}: ${LocalizationManager.helpBlockerTilesDesc(ref)}',
        LocalizationManager.helpBlockerRules(ref),
        '• ${LocalizationManager.helpBlockerRule1(ref)}',
        '• ${LocalizationManager.helpBlockerRule2(ref)}',
        '• ${LocalizationManager.helpBlockerRule3(ref)}',
      ],
    );
  }

  Widget _buildPowerupSystemSection(BuildContext context, WidgetRef ref) {
    return _buildPowerupHelpSection(
      context,
      ref,
      title: LocalizationManager.helpPowerupSystem(ref),
      icon: Icons.flash_on,
      unlockDescription:
          '${LocalizationManager.helpPowerupUnlock(ref)}: ${LocalizationManager.helpPowerupUnlockDesc(ref)}',
      availablePowerupsTitle: LocalizationManager.helpAvailablePowerups(ref),
      powerups: [
        _PowerupInfo(
          type: PowerupType.tileDestroyer,
          name: LocalizationManager.helpTileDestroyer(ref),
          description: LocalizationManager.helpTileDestroyerDesc(ref),
        ),
        _PowerupInfo(
          type: PowerupType.rowClear,
          name: LocalizationManager.helpRowClear(ref),
          description: LocalizationManager.helpRowClearDesc(ref),
        ),
        _PowerupInfo(
          type: PowerupType.columnClear,
          name: LocalizationManager.helpColumnClear(ref),
          description: LocalizationManager.helpColumnClearDesc(ref),
        ),
        _PowerupInfo(
          type: PowerupType.valueUpgrade,
          name: LocalizationManager.helpValueUpgrade(ref),
          description: LocalizationManager.helpValueUpgradeDesc(ref),
        ),
        _PowerupInfo(
          type: PowerupType.tileFreeze,
          name: LocalizationManager.helpTileFreeze(ref),
          description: LocalizationManager.helpTileFreezeDesc(ref),
        ),
      ],
      usageDescription:
          '${LocalizationManager.helpPowerupUsage(ref)}: ${LocalizationManager.helpPowerupUsageDesc(ref)}',
    );
  }

  Widget _buildGameModesSection(BuildContext context, WidgetRef ref) {
    return _buildHelpSection(
      context,
      ref,
      title: LocalizationManager.helpGameModes(ref),
      icon: Icons.gamepad,
      items: [
        '${LocalizationManager.helpClassicMode(ref)}: ${LocalizationManager.helpClassicModeDesc(ref)}',
        '${LocalizationManager.helpTimeAttackMode(ref)}: ${LocalizationManager.helpTimeAttackModeDesc(ref)}',
        '${LocalizationManager.helpScenicMode(ref)}: ${LocalizationManager.helpScenicModeDesc(ref)}',
      ],
    );
  }

  Widget _buildControlsSection(BuildContext context, WidgetRef ref) {
    return _buildHelpSection(
      context,
      ref,
      title: LocalizationManager.helpControls(ref),
      icon: Icons.touch_app,
      items: [
        '${LocalizationManager.helpTouchControls(ref)}: ${LocalizationManager.helpTouchControlsDesc(ref)}',
        '${LocalizationManager.helpKeyboardSupport(ref)}: ${LocalizationManager.helpKeyboardSupportDesc(ref)}',
        '${LocalizationManager.helpPauseControls(ref)}: ${LocalizationManager.helpPauseControlsDesc(ref)}',
      ],
    );
  }

  Widget _buildScoringSection(BuildContext context, WidgetRef ref) {
    return _buildHelpSection(
      context,
      ref,
      title: LocalizationManager.helpScoring(ref),
      icon: Icons.score,
      items: [
        '${LocalizationManager.helpScoreDisplay(ref)}: ${LocalizationManager.helpScoreDisplayDesc(ref)}',
        '${LocalizationManager.helpBestScore(ref)}: ${LocalizationManager.helpBestScoreDesc(ref)}',
        '${LocalizationManager.helpStatistics(ref)}: ${LocalizationManager.helpStatisticsDesc(ref)}',
      ],
    );
  }

  Widget _buildTipsStrategiesSection(BuildContext context, WidgetRef ref) {
    return _buildHelpSection(
      context,
      ref,
      title: LocalizationManager.helpTipsStrategies(ref),
      icon: Icons.lightbulb_outline,
      items: [
        '${LocalizationManager.helpCornerStrategy(ref)}: ${LocalizationManager.helpCornerStrategyDesc(ref)}',
        '${LocalizationManager.helpDirectionConsistency(ref)}: ${LocalizationManager.helpDirectionConsistencyDesc(ref)}',
        '${LocalizationManager.helpPowerupTiming(ref)}: ${LocalizationManager.helpPowerupTimingDesc(ref)}',
        '${LocalizationManager.helpBlockerManagement(ref)}: ${LocalizationManager.helpBlockerManagementDesc(ref)}',
      ],
    );
  }

  Widget _buildHelpSection(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: AppConstants.iconSizeMedium,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppConstants.paddingSmall,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context, WidgetRef ref) {
    final faqs = [
      {
        'question': LocalizationManager.helpFaqHowToPlay(ref),
        'answer': LocalizationManager.helpFaqHowToPlayAnswer(ref),
      },
      {
        'question': LocalizationManager.helpFaqWinCondition(ref),
        'answer': LocalizationManager.helpFaqWinConditionAnswer(ref),
      },
      {
        'question': LocalizationManager.helpFaqPowerups(ref),
        'answer': LocalizationManager.helpFaqPowerupsAnswer(ref),
      },
      {
        'question': LocalizationManager.helpFaqBlockers(ref),
        'answer': LocalizationManager.helpFaqBlockersAnswer(ref),
      },
      {
        'question': LocalizationManager.helpFaqGameModes(ref),
        'answer': LocalizationManager.helpFaqGameModesAnswer(ref),
      },
      {
        'question': LocalizationManager.helpFaqControls(ref),
        'answer': LocalizationManager.helpFaqControlsAnswer(ref),
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.quiz,
                  size: AppConstants.iconSizeMedium,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  LocalizationManager.helpFaq(ref),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ...faqs.map(
              (faq) => ExpansionTile(
                title: Text(
                  faq['question']!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Text(
                      faq['answer']!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(
              Icons.support_agent,
              size: AppConstants.iconSizeLarge,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              LocalizationManager.helpNeedMoreHelp(ref),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              LocalizationManager.helpContactSupport(ref),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement contact support
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(LocalizationManager.comingSoon(ref))),
                );
              },
              icon: const Icon(Icons.email),
              label: Text(LocalizationManager.contactUs(ref)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerupHelpSection(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required IconData icon,
    required String unlockDescription,
    required String availablePowerupsTitle,
    required List<_PowerupInfo> powerups,
    required String usageDescription,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: AppConstants.iconSizeMedium,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),

            // Unlock description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Text(
                    unlockDescription,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),

            // Available powerups title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Text(
                    availablePowerupsTitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),

            // Powerup list with icons
            ...powerups.map(
              (powerup) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppConstants.paddingSmall,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: AppConstants.paddingMedium + 6,
                    ), // Indent for sub-items
                    // Powerup icon
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getPowerupColor(
                          powerup.type,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusSmall,
                        ),
                        border: Border.all(
                          color: _getPowerupColor(
                            powerup.type,
                          ).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          powerup.type.icon,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            powerup.name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _getPowerupColor(powerup.type),
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            powerup.description,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingSmall),

            // Usage description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Text(
                    usageDescription,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPowerupColor(PowerupType type) {
    switch (type) {
      case PowerupType.tileFreeze:
        return const Color(0xFF2196F3); // Blue
      case PowerupType.tileDestroyer:
        return const Color(0xFFF44336); // Red
      case PowerupType.valueUpgrade:
        return const Color(0xFF4CAF50); // Green
      case PowerupType.rowClear:
        return const Color(0xFFFF9800); // Orange
      case PowerupType.columnClear:
        return const Color(0xFFFF5722); // Deep Orange
      default:
        return const Color(0xFF9C27B0); // Purple
    }
  }
}

/// Helper class to hold powerup information for the help screen
class _PowerupInfo {
  final PowerupType type;
  final String name;
  final String description;

  const _PowerupInfo({
    required this.type,
    required this.name,
    required this.description,
  });
}
