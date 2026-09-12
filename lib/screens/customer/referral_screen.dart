import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CustReferralScreen extends StatefulWidget {
  final void Function(String screen, {String? param}) nav;
  const CustReferralScreen({super.key, required this.nav});

  @override
  State<CustReferralScreen> createState() => _CustReferralScreenState();
}

class _CustReferralScreenState extends State<CustReferralScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _invitedContacts = {};

  final List<Map<String, String>> _allContacts = const [
    {'name': 'Jane Cooper', 'phone': '(270) 555-0117', 'initials': 'JC', 'color': '0xFFF59E0B'},
    {'name': 'Devon Lane', 'phone': '(308) 555-0121', 'initials': 'DL', 'color': '0xFF10B981'},
    {'name': 'Darrell Steward', 'phone': '(684) 555-0102', 'initials': 'DS', 'color': '0xFF3B82F6'},
    {'name': 'Devon Lane', 'phone': '(704) 555-0127', 'initials': 'DL', 'color': '0xFF8B5CF6'},
    {'name': 'Courtney Henry', 'phone': '(505) 555-0125', 'initials': 'CH', 'color': '0xFFEC4899'},
    {'name': 'Wade Warren', 'phone': '(225) 555-0118', 'initials': 'WW', 'color': '0xFF6366F1'},
    {'name': 'Bessie Cooper', 'phone': '(406) 555-0120', 'initials': 'BC', 'color': '0xFF14B8A6'},
    {'name': 'Robert Fox', 'phone': '(480) 555-0103', 'initials': 'RF', 'color': '0xFFF97316'},
    {'name': 'Jacob Jones', 'phone': '(702) 555-0122', 'initials': 'JJ', 'color': '0xFFE11D48'},
    {'name': 'Jenny Wilson', 'phone': '(239) 555-0108', 'initials': 'JW', 'color': '0xFF84CC16'},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showHowToReferDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Text('🎁 ', style: TextStyle(fontSize: 22)),
            Text('How Referral Works', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Share your unique invite link with friends & family.', style: TextStyle(fontSize: 13, height: 1.4)),
            SizedBox(height: 8),
            Text('2. When they register & place their first fresh meat order, they get a 10% OFF welcome coupon.', style: TextStyle(fontSize: 13, height: 1.4)),
            SizedBox(height: 8),
            Text('3. You instantly receive a FREE pack of 6 farm-fresh eggs + 100 Reward Points added to your wallet!', style: TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w700, color: AppColors.brandRed)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final filteredContacts = _allContacts.where((c) {
      final name = c['name']!.toLowerCase();
      final phone = c['phone']!.toLowerCase();
      return name.contains(query) || phone.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.brandRed,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── 1. RED HERO / HEADER SECTION ────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  children: [
                    // Top Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.gray800),
                          onPressed: () => widget.nav('back'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Heading Text
                    const Text(
                      'Refer a friend and earn a\npack of 6 fresh eggs',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'Invite your friends & family to Country Meat.\nLet them savor the true taste of real meat!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // "How to refer a friend" Pill Button
                    GestureDetector(
                      onTap: _showHowToReferDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Text(
                          'How to refer a friend',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandRed,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Graphic Row (Rooster + Eggs + Megaphone + Avatars)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Graphic: Rooster & Eggs
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Text('🐓', style: TextStyle(fontSize: 32)),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('🥚 🥚 🥚', style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),

                        // Right Graphic: Megaphone & Avatars
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Text('📢', style: TextStyle(fontSize: 28)),
                            ),
                            const SizedBox(width: 4),
                            const CircleAvatar(radius: 12, backgroundColor: Color(0xFF3B82F6), child: Text('👤', style: TextStyle(fontSize: 12))),
                            const CircleAvatar(radius: 12, backgroundColor: Color(0xFFEC4899), child: Text('👩', style: TextStyle(fontSize: 12))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── 2. DRAGGABLE WHITE CARD / INVITE LIST ───────────────────────
            DraggableScrollableSheet(
              initialChildSize: 0.58,
              minChildSize: 0.58,
              maxChildSize: 0.95,
              snap: true,
              snapSizes: const [0.58, 0.95],
              builder: (context, scrollController) {
                return Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: const ClampingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Handle Bar
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 10, bottom: 12),
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.gray300,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // "Invite" Title
                                    const Text(
                                      'Invite',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.gray900,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Native/Share-style Channels Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _ShareChannelButton(
                                          icon: Icons.chat_bubble_rounded,
                                          label: 'WhatsApp',
                                          bgColor: const Color(0xFF25D366),
                                          iconColor: Colors.white,
                                          onTap: () => showAppToast(context, 'Opening WhatsApp to share referral code CMREF100! 🎁'),
                                        ),
                                        _ShareChannelButton(
                                          icon: Icons.comment_rounded,
                                          label: 'Message',
                                          bgColor: const Color(0xFF6B7280),
                                          iconColor: Colors.white,
                                          onTap: () => showAppToast(context, 'Opening SMS to share referral link! 💬'),
                                        ),
                                        _ShareChannelButton(
                                          icon: Icons.email_rounded,
                                          label: 'Email',
                                          bgColor: const Color(0xFFEA4335),
                                          iconColor: Colors.white,
                                          onTap: () => showAppToast(context, 'Opening Email app... ✉️'),
                                        ),
                                        _ShareChannelButton(
                                          icon: Icons.more_horiz_rounded,
                                          label: 'More',
                                          bgColor: const Color(0xFF4B5563),
                                          iconColor: Colors.white,
                                          onTap: () => showAppToast(context, 'Opening system share sheet... 📲'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                                    const SizedBox(height: 14),

                                    // Contact Search Section Heading
                                    const Text(
                                      'Refer Country Meat to your contacts',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.gray900,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Search Bar
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: TextField(
                                        controller: _searchCtrl,
                                        onChanged: (_) => setState(() {}),
                                        decoration: const InputDecoration(
                                          icon: Icon(Icons.search_rounded, color: AppColors.brandRed, size: 20),
                                          hintText: 'Search',
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(color: AppColors.gray400, fontSize: 13.5),
                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        if (filteredContacts.isEmpty)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text('No contacts found', style: TextStyle(color: AppColors.gray400, fontSize: 13)),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                            sliver: SliverList.separated(
                              itemCount: filteredContacts.length,
                              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                              itemBuilder: (context, idx) {
                                final contact = filteredContacts[idx];
                                final name = contact['name']!;
                                final phone = contact['phone']!;
                                final initials = contact['initials']!;
                                final colorHex = int.parse(contact['color']!);
                                final isInvited = _invitedContacts.contains(phone);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      // Avatar Circle
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Color(colorHex),
                                        child: Text(
                                          initials,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Name & Phone
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.gray900,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              phone,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.gray500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Invite Action Button
                                      OutlinedButton(
                                        onPressed: isInvited
                                            ? null
                                            : () {
                                                setState(() {
                                                  _invitedContacts.add(phone);
                                                });
                                                showAppToast(context, 'Invite sent to $name! 🎁');
                                              },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: isInvited ? AppColors.gray400 : AppColors.brandRed,
                                          side: BorderSide(
                                            color: isInvited ? AppColors.gray300 : const Color(0xFFFCA5A5),
                                            width: 1.2,
                                          ),
                                          backgroundColor: isInvited ? AppColors.gray100 : const Color(0xFFFEF2F2),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        child: Text(isInvited ? 'INVITED' : 'INVITE'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareChannelButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ShareChannelButton({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }
}
