import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

// ─── PROFILE SCREEN ───────────────────────────────────────────────────────────
class CustProfileScreen extends StatefulWidget {
  final void Function(String screen, {String? param}) nav;
  final String? param;
  const CustProfileScreen({super.key, required this.nav, this.param});

  @override
  State<CustProfileScreen> createState() => _CustProfileScreenState();
}

class _CustProfileScreenState extends State<CustProfileScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.param == 'addresses' || widget.param == 'showAddressesSheet') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showAddressesSheet(context, context.read<AppState>());
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant CustProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.param != oldWidget.param &&
        (widget.param == 'addresses' || widget.param == 'showAddressesSheet')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showAddressesSheet(context, context.read<AppState>());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Column(
      children: [
        _CircleNavHeader(title: 'My Profile', onBack: () => widget.nav('back')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // ── User Profile Hero Card ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F2937), Color(0xFF111827)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar Frame
                        Stack(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: AppColors.brandRed, width: 2.5),
                              ),
                              child: const Center(
                                child: Text('🐓', style: TextStyle(fontSize: 34)),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      appState.userName.isNotEmpty ? appState.userName : 'Arjun Kumar',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'VERIFIED',
                                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appState.userPhone,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _showEditProfileModal(context, appState),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandRed,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.edit_rounded, color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        'Edit Profile',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 14),
                    // Loyalty Tier Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('👑', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '${appState.rewardTier} Member',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${appState.rewardPoints} Reward Pts',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFFBBF24),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Quick Metrics Grid ──────────────────────────────────────────
              Row(
                children: [
                  _QuickStatCard(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Orders',
                    value: '${appState.orders.length}',
                    onTap: () => widget.nav('orders'),
                  ),
                  const SizedBox(width: 10),
                  _QuickStatCard(
                    icon: Icons.stars_rounded,
                    label: 'Rewards',
                    value: '${appState.rewardPoints} pts',
                    onTap: () => widget.nav('rewards'),
                  ),
                  const SizedBox(width: 10),
                  _QuickStatCard(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallet',
                    value: '₹${appState.walletBalance.toStringAsFixed(0)}',
                    onTap: () => widget.nav('wallet'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Account Settings Section ───────────────────────────────────
              const _SectionHeaderTitle('MY ACCOUNT'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: AppShadows.subtle,
                ),
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Saved Addresses',
                      sub: appState.defaultAddress,
                      onTap: () => _showAddressesSheet(context, appState),
                    ),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    _ProfileMenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Country Meat Wallet',
                      sub: 'Balance: ₹${appState.walletBalance.toStringAsFixed(2)}',
                      onTap: () => widget.nav('wallet'),
                    ),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    _ProfileMenuItem(
                      icon: Icons.emoji_events_outlined,
                      title: 'Loyalty & Rewards',
                      sub: 'Milestones, badges & coupons',
                      onTap: () => widget.nav('rewards'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Preferences & Referrals Section ─────────────────────────────
              const _SectionHeaderTitle('PREFERENCES & EARN'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: AppShadows.subtle,
                ),
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.campaign_outlined,
                      title: 'Refer & Earn',
                      sub: 'Invite friends & get 10% OFF coupon',
                      onTap: () => widget.nav('referral'),
                    ),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    _ProfileMenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notification Preferences',
                      sub: 'Order tracking SMS & Dawn alerts',
                      onTap: () => _showNotificationSettingsModal(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Support & Legal Section ─────────────────────────────────────
              const _SectionHeaderTitle('SUPPORT & LEGAL'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: AppShadows.subtle,
                ),
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.headset_mic_outlined,
                      title: 'Help & Customer Support 24/7',
                      sub: 'Call, WhatsApp or FAQ',
                      onTap: () => _showContactSupportModal(context),
                    ),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    _ProfileMenuItem(
                      icon: Icons.article_outlined,
                      title: 'Terms & Conditions',
                      onTap: () => _showTermsModal(context),
                    ),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    _ProfileMenuItem(
                      icon: Icons.security_outlined,
                      title: 'Privacy Policy',
                      onTap: () => _showTermsModal(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Logout Button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showSignOutDialog(context),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.brandRed, size: 18),
                  label: const Text('Log Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandRed,
                    side: const BorderSide(color: AppColors.brandRed, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddressesSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Saved Addresses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gray100,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.gray700,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...appState.addresses.map((a) => GestureDetector(
                onTap: () {
                  appState.setDefaultAddress(a);
                  showAppToast(context, 'Set as default delivery address! 🏠');
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: a.isDefault ? AppColors.brandRedBg : AppColors.gray50,
                    borderRadius: BorderRadius.circular(AppRadius.base),
                    border: Border.all(color: a.isDefault ? AppColors.brandRed : AppColors.gray200),
                  ),
                  child: Row(
                    children: [
                      Text(a.isDefault ? '🏠' : '🏢', style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(a.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                if (a.isDefault) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.brandRed,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('DEFAULT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ],
                            ),
                            Text(a.address, style: const TextStyle(color: AppColors.gray500, fontSize: 11.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.nav('location', param: 'profileAddress');
                  },
                  icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                  label: const Text('Add New Address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Modals & Dialogs ────────────────────────────────────────────────────────
  void _showEditProfileModal(BuildContext context, AppState appState) {
    final nameCtrl = TextEditingController(text: appState.userName);
    final phoneCtrl = TextEditingController(text: appState.userPhone);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 20, left: 20, right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Edit Profile',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gray100,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.gray700,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_rounded)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_rounded)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    appState.updateUser(nameCtrl.text, phoneCtrl.text);
                    Navigator.pop(ctx);
                    showAppToast(context, 'Profile updated! ✨');
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _showNotificationSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => const _NotificationSettingsSheet(),
    );
  }


  void _showContactSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 20, left: 20, right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Customer Support',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gray100,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.gray700,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text('We are available 6AM – 9PM every day to help you.',
                  style: TextStyle(color: AppColors.gray500, fontSize: 13)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.phone_rounded, color: AppColors.brandRed),
                title: const Text('Call Support'),
                subtitle: const Text('+91 98765 43210'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final uri = Uri.parse('tel:+919876543210');
                  try {
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        showAppToast(context, 'Could not open phone dialer');
                      }
                    }
                  } catch (_) {
                    if (context.mounted) {
                      showAppToast(context, 'Could not open phone dialer');
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_rounded, color: AppColors.brandRed),
                title: const Text('Email Us'),
                subtitle: const Text('support@countrymeat.in'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final uri = Uri(
                    scheme: 'mailto',
                    path: 'support@countrymeat.in',
                    queryParameters: {'subject': 'Support Request - Country Meat App'},
                  );
                  try {
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        showAppToast(context, 'Could not open email app');
                      }
                    }
                  } catch (_) {
                    if (context.mounted) {
                      showAppToast(context, 'Could not open email app');
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat_rounded, color: AppColors.brandRed),
                title: const Text('WhatsApp Chat'),
                subtitle: const Text('Instant support via WhatsApp'),
                onTap: () {
                  Navigator.pop(ctx);
                  showAppToast(context, 'Opening WhatsApp chat...');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    int rating = 5;
    final textCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: const Text('Rate Country Meat App', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                  icon: Icon(
                    i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.warning,
                    size: 32,
                  ),
                  onPressed: () => setDialogState(() => rating = i + 1),
                )),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Share your feedback (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                showAppToast(context, 'Thank you for your rating! ⭐');
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Terms & Privacy Policy',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gray100,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.gray700,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
            const Divider(),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Terms of Service & Privacy Policy\n\n'
                  '1. Fresh Meat Guarantee: All country meat products are sourced directly from registered open farms and processed daily under strict food safety guidelines.\n\n'
                  '2. Delivery Slots: Morning deliveries take place between 6:00 AM and 9:00 AM. Orders placed after 10:00 PM are scheduled for the subsequent day.\n\n'
                  '3. Returns & Refunds: Due to the perishable nature of fresh meat, returns are accepted only at the time of delivery if the quality does not meet our standards.\n\n'
                  '4. Data Privacy: Your personal data, phone number, and location are encrypted and strictly used for order processing and delivery.',
                  style: TextStyle(color: AppColors.gray600, fontSize: 13, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              showAppToast(context, 'Signed out successfully');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// ─── NOTIFICATION SETTINGS SHEET ─────────────────────────────────────────────
class _NotificationSettingsSheet extends StatefulWidget {
  const _NotificationSettingsSheet();

  @override
  State<_NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<_NotificationSettingsSheet>
    with WidgetsBindingObserver {
  PermissionStatus? _permissionStatus;
  bool _isLoading = true;

  bool _orderUpdates = true;
  bool _promoOffers = true;
  bool _slotReminders = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    try {
      final status = await Permission.notification.status;
      if (mounted) {
        setState(() {
          _permissionStatus = status;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestPermission() async {
    try {
      final status = await Permission.notification.request();
      if (mounted) {
        setState(() {
          _permissionStatus = status;
        });
      }
    } catch (_) {
      // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Notification Preferences',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gray100,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.gray700,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.brandRed,
            ),
          ),
        ),
      );
    }

    final isGranted = _permissionStatus?.isGranted == true ||
        _permissionStatus?.isProvisional == true;

    if (isGranted) {
      return _buildGrantedSettings();
    }

    if (_permissionStatus?.isPermanentlyDenied == true) {
      return _buildPermanentlyDeniedState();
    }

    return _buildPermissionRequiredState();
  }

  Widget _buildGrantedSettings() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Order Status Updates'),
          subtitle: const Text('Get live tracking & delivery updates'),
          value: _orderUpdates,
          activeThumbColor: AppColors.brandRed,
          onChanged: (v) => setState(() => _orderUpdates = v),
        ),
        SwitchListTile(
          title: const Text('Promotions & Discounts'),
          subtitle: const Text('Receive notifications for special sales'),
          value: _promoOffers,
          activeThumbColor: AppColors.brandRed,
          onChanged: (v) => setState(() => _promoOffers = v),
        ),
        SwitchListTile(
          title: const Text('Delivery Slot Reminders'),
          subtitle: const Text('Reminders to place orders for morning slot'),
          value: _slotReminders,
          activeThumbColor: AppColors.brandRed,
          onChanged: (v) => setState(() => _slotReminders = v),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showAppToast(context, 'Notification settings saved! 🔔');
            },
            child: const Text('Save Preferences'),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionRequiredState() {
    final isDenied = _permissionStatus?.isDenied == true;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.brandRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.brandRed,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isDenied
                  ? 'Notifications are Disabled'
                  : 'Notifications are Currently Disabled',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              isDenied
                  ? 'Notifications are currently disabled. Allow notifications to receive live order updates, promotions, and delivery reminders.'
                  : 'Allow notifications to receive live order updates, promotions, and delivery reminders.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.gray500,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _requestPermission,
                child: const Text('Enable Notifications'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermanentlyDeniedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.brandRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: AppColors.brandRed,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Notifications are Blocked',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Notifications are blocked in your device settings. Please open settings to allow updates for orders, promotions, and delivery reminders.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => openAppSettings(),
                child: const Text('Open Device Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;
  const _ProfileOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppRadius.base),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
        const Icon(Icons.chevron_right_rounded, color: AppColors.gray300, size: 20),
      ]),
    ),
  );
}

// ─── ADD CARD SCREEN ─────────────────────────────────────────────────────────
class CustAddCardScreen extends StatelessWidget {
  final void Function(String screen, {String? param}) nav;
  const CustAddCardScreen({super.key, required this.nav});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 16, 6),
          child: Row(children: [
            IconButton(
              onPressed: () => nav('back'),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
            const Text('Saved Cards',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 8),
              // Existing card
              Container(
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.only(bottom: 12),
                height: 155,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F2937), Color(0xFF374151)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.elevated,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('VISA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, fontStyle: FontStyle.italic)),
                      Container(
                        width: 26, height: 26,
                        decoration: const BoxDecoration(color: AppColors.brandRed, shape: BoxShape.circle),
                      ),
                    ]),
                    const Text('•••• •••• •••• 1234',
                        style: TextStyle(color: Colors.white, fontSize: 17, letterSpacing: 2, fontWeight: FontWeight.w500)),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('CARD HOLDER', style: TextStyle(color: Colors.white38, fontSize: 9)),
                        Text('Arjun Kumar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('EXPIRES', style: TextStyle(color: Colors.white38, fontSize: 9)),
                        Text('12/28', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ]),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Add new card form
              const Text('Add New Card',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: 'Card Number', prefixIcon: Icon(Icons.credit_card_rounded))),
              const SizedBox(height: 12),
              const Row(children: [
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Expiry (MM/YY)'))),
                SizedBox(width: 12),
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'CVV'))),
              ]),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: 'Card Holder Name', prefixIcon: Icon(Icons.person_rounded))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showAppToast(context, 'Card saved! 💳');
                  nav('profile');
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Add Card'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── PROFILE DETAIL ITEM ──────────────────────────────────────────────────────
class _ProfileDetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileDetailItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF6B7280)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.gray500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.gray800),
          ],
        ),
      ),
    );
  }
}

class _CircleNavHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _CircleNavHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gray300),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.gray800),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
            ),
          ),
          const SizedBox(width: 38), // Balance for centering title
        ],
      ),
    );
  }
}

// ─── HELPER COMPONENTS FOR NEW PROFILE DASHBOARD ──────────────────────────────
class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.brandRed, size: 22),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeaderTitle extends StatelessWidget {
  final String title;
  const _SectionHeaderTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.gray400,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? sub;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.gray700),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  if (sub != null && sub!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}

