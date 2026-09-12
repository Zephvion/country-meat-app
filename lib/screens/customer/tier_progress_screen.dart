import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

// ─── MINIMAL VISUAL REWARDS TIER PROGRESS SCREEN ──────────────────────────────
class CustTierProgressScreen extends StatelessWidget {
  final void Function(String screen, {String? param}) nav;

  const CustTierProgressScreen({super.key, required this.nav});

  // 5 Tiers in strict order
  static const List<Map<String, dynamic>> _tiers = [
    {'name': 'Bronze', 'pts': 0, 'color': Color(0xFFB45309), 'eggEmoji': '🥚'},
    {'name': 'Silver', 'pts': 250, 'color': Color(0xFF6B7280), 'eggEmoji': '🥚'},
    {'name': 'Gold', 'pts': 500, 'color': Color(0xFFD97706), 'eggEmoji': '🥚'},
    {'name': 'Diamond', 'pts': 750, 'color': Color(0xFF2563EB), 'eggEmoji': '🥚'},
    {'name': 'Platinum', 'pts': 1000, 'color': Color(0xFF7C3AED), 'eggEmoji': '🥚'},
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pts = appState.rewardPoints;
    final currentTierName = appState.rewardTier;
    final nextPts = appState.nextTierPoints;

    // Calculate exact continuous progress ratio (0.0 to 1.0) for 0..1000 points
    final double targetRatio = (pts / 1000.0).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Header Bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => nav('back'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Rewards',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gray900,
                    ),
                  ),
                  const Spacer(),
                  // Subtle Points Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.brandRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: AppColors.brandRed, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '$pts Pts',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── 2. Minimal Status Summary ───────────────────────────────────
            Text(
              currentTierName.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: AppColors.brandRed,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              nextPts > 0
                  ? '$nextPts points to next tier'
                  : '🎉 Maximum Platinum Tier Unlocked!',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
              ),
            ),

            const SizedBox(height: 48),

            // ── 3. Chicken & 5 Eggs Horizontal Progression Journey ──────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  const eggDiameter = 40.0;
                  final availableTrackLength = totalWidth - eggDiameter;

                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: targetRatio),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, progressRatio, child) {
                      final chickenLeft = progressRatio * availableTrackLength;

                      return Column(
                        children: [
                          // Top Area: Chicken Mascot & Speech Bubble
                          SizedBox(
                            height: 65,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: chickenLeft.clamp(0.0, availableTrackLength),
                                  child: SizedBox(
                                    width: eggDiameter,
                                    child: Column(
                                      children: [
                                        // Points Tooltip Bubble
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.brandRed,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: AppShadows.subtle,
                                          ),
                                          child: Text(
                                            '$pts pts',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        // Chicken Icon
                                        const Text('🐔', style: TextStyle(fontSize: 28)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Track Line & 5 Eggs Layer
                          SizedBox(
                            height: eggDiameter,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background Track Bar
                                Container(
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(horizontal: eggDiameter / 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.gray200,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),

                                // Active Fill Track Bar
                                Positioned(
                                  left: eggDiameter / 2,
                                  child: Container(
                                    height: 6,
                                    width: (progressRatio * availableTrackLength).clamp(0.0, availableTrackLength),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.brandRed, Color(0xFFF59E0B)],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),

                                // 5 Milestone Eggs
                                ...List.generate(_tiers.length, (idx) {
                                  final tier = _tiers[idx];
                                  final tierPts = tier['pts'] as int;
                                  final isReached = pts >= tierPts;
                                  final isCurrent = currentTierName == tier['name'];

                                  // Fraction along track (0.0, 0.25, 0.50, 0.75, 1.0)
                                  final fraction = idx / (_tiers.length - 1);
                                  final eggLeft = fraction * availableTrackLength;

                                  return Positioned(
                                    left: eggLeft,
                                    child: AnimatedScale(
                                      duration: const Duration(milliseconds: 300),
                                      scale: isCurrent ? 1.15 : 1.0,
                                      child: Container(
                                        width: eggDiameter,
                                        height: eggDiameter,
                                        decoration: BoxDecoration(
                                          color: isReached ? Colors.amber.shade50 : AppColors.gray100,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isCurrent
                                                ? AppColors.brandRed
                                                : (isReached ? Colors.amber.shade600 : AppColors.gray300),
                                            width: isCurrent ? 2.5 : 1.5,
                                          ),
                                          boxShadow: isReached ? AppShadows.subtle : null,
                                        ),
                                        child: Center(
                                          child: Opacity(
                                            opacity: isReached ? 1.0 : 0.4,
                                            child: const Text('🥚', style: TextStyle(fontSize: 20)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Tier Labels Below Eggs
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _tiers.map((tier) {
                              final isCurrent = currentTierName == tier['name'];
                              final isReached = pts >= (tier['pts'] as int);

                              return SizedBox(
                                width: eggDiameter + 12,
                                child: Column(
                                  children: [
                                    Text(
                                      tier['name'] as String,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isCurrent ? FontWeight.w900 : (isReached ? FontWeight.w700 : FontWeight.w500),
                                        color: isCurrent
                                            ? AppColors.brandRed
                                            : (isReached ? AppColors.gray900 : AppColors.gray400),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${tier['pts']} pts',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w500,
                                        color: isReached ? AppColors.gray600 : AppColors.gray400,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            const Spacer(),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
