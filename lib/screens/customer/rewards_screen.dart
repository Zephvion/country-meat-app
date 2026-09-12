import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class CustRewardsScreen extends StatelessWidget {
  final void Function(String screen, {String? param}) nav;
  const CustRewardsScreen({super.key, required this.nav});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.rewardsTermsAccepted) {
      return _buildInitialRewardsState(context, appState);
    }

    return _buildRewardsDashboard(context, appState);
  }

  // ── 1. INITIAL / UNACCEPTED REWARDS STATE ────────────────────────────────────
  Widget _buildInitialRewardsState(BuildContext context, AppState appState) {
    final greetingName = appState.userName.isNotEmpty
        ? appState.userName.split(' ').first
        : 'Customer';

    return Column(
      children: [
        // Top App Bar with Back Button
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
                'Rewards 🎁',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Greeting Section
              Text(
                'Hi $greetingName,',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Welcome to Country Meat Loyalty Rewards Program!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // Welcome Intro Banner Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F2937), Color(0xFF111827)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.elevated,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text('👑', style: TextStyle(fontSize: 32)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Country Meat Rewards',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Earn points on every fresh country meat order and convert them into instant cashback discounts at checkout.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.stars_rounded, color: Color(0xFFFBBF24), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Get 5% cashback points on every order + bonus points on reviews and referrals!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Highlights Grid
              const Text(
                'Program Highlights',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 12),
              const _EarnCard(
                icon: '🛒',
                title: '5% Order Cashback',
                desc: 'Earn 5% of total order value as reward points',
                pts: '+5%',
                onTap: null,
                isLocked: true,
              ),
              const _EarnCard(
                icon: '⭐',
                title: 'Review Rewards',
                desc: 'Rate and review your delivery partner',
                pts: '+25',
                onTap: null,
                isLocked: true,
              ),
              const _EarnCard(
                icon: '👥',
                title: 'Referral Bonus',
                desc: 'Earn when your friends place their first order',
                pts: '+100',
                onTap: null,
                isLocked: true,
              ),
              const SizedBox(height: 24),

              // Terms & Conditions Action Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Column(
                  children: [
                    const Text(
                      'To start earning and redeeming rewards, please review and accept the Rewards Terms & Conditions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.gray600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => _showRewardsTermsModal(context, appState),
                      icon: const Icon(Icons.description_outlined, size: 18),
                      label: const Text('TERMS AND CONDITION'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brandRed,
                        side: const BorderSide(color: AppColors.brandRed, width: 1.4),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.base),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Primary Join/Accept Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showRewardsTermsModal(context, appState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  child: const Text('Join Rewards Program →'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  // ── 2. TERMS & CONDITIONS MODAL SHEET ───────────────────────────────────────
  void _showRewardsTermsModal(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (modalCtx) => SafeArea(
        child: Container(
          height: MediaQuery.of(modalCtx).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rewards Terms & Conditions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(modalCtx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Terms Content
              const Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'Country Meat Loyalty Rewards Program Terms & Conditions\n\n'
                    '1. Program Eligibility: Country Meat Rewards is open to all registered customer account holders.\n\n'
                    '2. Earning Points: Members earn 5% of order subtotal value as reward points on all successful order completions. Bonus points are credited for order ratings (+25 pts), referrals (+100 pts), and birthday milestones (+200 pts).\n\n'
                    '3. Point Redemption: Every 100 Reward Points translates to ₹10 discount at checkout. A minimum balance of 500 points is required to unlock redemption.\n\n'
                    '4. Membership Tiers: Member progression includes Silver (0–499 pts), Gold (500–999 pts), and Platinum (1000+ pts).\n\n'
                    '5. Validity: Reward points remain active for 365 days from the date of issuance and are non-transferable.',
                    style: TextStyle(
                      color: AppColors.gray700,
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Acceptance Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    appState.acceptRewardsTerms();
                    Navigator.pop(modalCtx);
                    showAppToast(context, 'Welcome to Country Meat Rewards! 🎉');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  child: const Text('Accept Terms & Join Rewards'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 3. EXISTING FULL REWARDS DASHBOARD (ACCEPTED STATE) ────────────────────
  Widget _buildRewardsDashboard(BuildContext context, AppState appState) {
    final pts = appState.rewardPoints;
    final tier = appState.rewardTier;
    final next = appState.nextTierPoints;
    final progress = tier == 'Bronze'
        ? pts / 250
        : tier == 'Silver'
            ? (pts - 250) / 250
            : tier == 'Gold'
                ? (pts - 500) / 250
                : tier == 'Diamond'
                    ? (pts - 750) / 250
                    : 1.0;

    final tierColor = switch (tier) {
      'Bronze' => const Color(0xFFB45309),
      'Silver' => const Color(0xFF6B7280),
      'Gold' => const Color(0xFFD97706),
      'Diamond' => const Color(0xFF2563EB),
      'Platinum' => const Color(0xFF7C3AED),
      _ => const Color(0xFFB45309),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top App Bar with Back Button
        Row(
          children: [
            IconButton(
              onPressed: () => nav('back'),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
            const SizedBox(width: 4),
            const Text('Rewards 🎁',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 12),
        // Points card (Tappable to view Rewards Progress Journey)
        GestureDetector(
          onTap: () => nav('tier_progress'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [tierColor, tierColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.elevated,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(_tierEmoji(tier), style: const TextStyle(fontSize: 30)),
                        const SizedBox(width: 8),
                        Text(tier,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('View Journey 🏆',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('$pts',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        height: 1)),
                const Text('Reward Points',
                    style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 16),
                if (next > 0) ...[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Next tier in $next pts',
                        style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    Text('${_nextTier(tier)} →',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11)),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ] else
                  const Text('🏆 Maximum Tier Achieved!',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        // How to earn
        const Text('How to Earn Points',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 12),
        _EarnCard(
          icon: '🛒',
          title: 'Place an Order',
          desc: 'Earn 5% of your order value as points',
          pts: '+5%',
          onTap: () => nav('categories'),
        ),
        _EarnCard(
          icon: '⭐',
          title: 'Rate Your Order',
          desc: 'Rate and review your delivery',
          pts: '+25',
          onTap: () => nav('orders'),
        ),
        _EarnCard(
          icon: '👥',
          title: 'Refer a Friend',
          desc: 'Earn bonus when a friend places first order',
          pts: '+100',
          onTap: () => nav('referral'),
        ),
        _EarnCard(
          icon: '🎂',
          title: 'Birthday Bonus',
          desc: 'Special bonus points on your birthday',
          pts: '+200',
          onTap: () => nav('birthday'),
        ),

        const SizedBox(height: 24),
        const Text('How to Redeem',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.brandRedBg,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Text('💡', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text('Redeem Points',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.brandRedDark)),
              ]),
              const SizedBox(height: 8),
              const Text('Every 100 points = ₹1 discount at checkout.',
                  style: TextStyle(
                      color: AppColors.gray600, fontSize: 13, height: 1.5)),
              const Text('Minimum 500 points required to redeem.',
                  style: TextStyle(color: AppColors.gray500, fontSize: 11)),
              const SizedBox(height: 12),
              if (pts >= 100) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      appState.toggleRewardRedemption(true);
                      showAppToast(
                          context, '🎉 Points applied! Redirecting to cart...');
                      nav('cart');
                    },
                    child: Text(
                        'Redeem $pts pts · Save ₹${(pts / 100).floor() * 10}'),
                  ),
                ),
              ] else
                Text('Earn ${100 - pts} more points to start redeeming.',
                    style: const TextStyle(color: AppColors.gray500, fontSize: 12)),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Text('Reward History',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 10),
        ...context
            .read<AppState>()
            .orders
            .where((o) => o.points > 0)
            .map((o) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gray100),
                    borderRadius: BorderRadius.circular(AppRadius.base),
                  ),
                  child: Row(children: [
                    const Icon(Icons.stars_rounded, color: AppColors.warning),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.id,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(o.date,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.gray400)),
                          ]),
                    ),
                    Text('+${o.points} pts',
                        style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700)),
                  ]),
                )),
        const SizedBox(height: 24),
      ],
    );
  }

  String _tierEmoji(String tier) => switch (tier) {
        'Bronze' => '🥉',
        'Silver' => '🥈',
        'Gold' => '🥇',
        'Diamond' => '💎',
        'Platinum' => '👑',
        _ => '🥉',
      };

  String _nextTier(String tier) => switch (tier) {
        'Bronze' => 'Silver',
        'Silver' => 'Gold',
        'Gold' => 'Diamond',
        'Diamond' => 'Platinum',
        _ => '',
      };
}

class _EarnCard extends StatelessWidget {
  final String icon, title, desc, pts;
  final VoidCallback? onTap;
  final bool isLocked;
  const _EarnCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.pts,
    this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isLocked ? AppColors.gray50 : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.base),
          boxShadow: isLocked ? null : AppShadows.subtle,
          border: Border.all(
            color: isLocked ? AppColors.gray200 : AppColors.gray100,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.base),
          child: InkWell(
            onTap: isLocked ? null : onTap,
            borderRadius: BorderRadius.circular(AppRadius.base),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Opacity(
                  opacity: isLocked ? 0.6 : 1.0,
                  child: Text(icon, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isLocked ? AppColors.gray600 : null,
                          ),
                        ),
                        Text(desc,
                            style: const TextStyle(
                                color: AppColors.gray400, fontSize: 11.5)),
                      ]),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isLocked ? AppColors.gray100 : AppColors.successLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLocked) ...[
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 12,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        pts,
                        style: TextStyle(
                          color:
                              isLocked ? AppColors.gray500 : AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
}
