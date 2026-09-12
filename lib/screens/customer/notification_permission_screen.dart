import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// In-app notification permission explanation screen.
///
/// Displayed before requesting the native OS notification permission dialog.
/// Follows Country Meat design language and explains the user benefits.
class CustNotificationPermissionScreen extends StatefulWidget {
  final Future<void> Function() onAllow;
  final Future<void> Function() onNotNow;

  const CustNotificationPermissionScreen({
    super.key,
    required this.onAllow,
    required this.onNotNow,
  });

  @override
  State<CustNotificationPermissionScreen> createState() =>
      _CustNotificationPermissionScreenState();
}

class _CustNotificationPermissionScreenState
    extends State<CustNotificationPermissionScreen> {
  bool _isRequesting = false;

  Future<void> _handleAllow() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);
    try {
      await widget.onAllow();
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  Future<void> _handleNotNow() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);
    try {
      await widget.onNotNow();
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppRadius.base),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandRedBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.brandRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray600,
                    height: 1.35,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // Top close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.gray500,
                          size: 24,
                        ),
                        tooltip: 'Not Now',
                        onPressed: _isRequesting ? null : _handleNotNow,
                      ),
                    ],
                  ),
                ),

                // Main explanation content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Hero Notification Badge
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.brandRedBg,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFEE2E2),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                gradient: AppGradients.brandRed,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x33C0392B),
                                    blurRadius: 16,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.notifications_active_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Stay Updated',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gray900,
                            fontFamily: 'Inter',
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Allow notifications to get updates about your orders, delivery status, offers and more.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gray600,
                            height: 1.5,
                            fontFamily: 'Inter',
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Benefit cards
                        _buildFeatureItem(
                          icon: Icons.local_shipping_outlined,
                          title: 'Live Order Tracking',
                          subtitle:
                              'Real-time alerts as soon as your fresh meat is out for delivery.',
                        ),

                        const SizedBox(height: 12),

                        _buildFeatureItem(
                          icon: Icons.access_time_rounded,
                          title: 'Morning Slot Reminders',
                          subtitle:
                              'Get notified when daily 6 AM – 9 AM delivery slots open.',
                        ),

                        const SizedBox(height: 12),

                        _buildFeatureItem(
                          icon: Icons.local_offer_outlined,
                          title: 'Exclusive Offers & Rewards',
                          subtitle:
                              'Early access to fresh batches, discounts and bonus rewards.',
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isRequesting ? null : _handleAllow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.base),
                            ),
                            elevation: 0,
                          ),
                          child: _isRequesting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Allow Notifications',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: TextButton(
                          onPressed: _isRequesting ? null : _handleNotNow,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.gray500,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.base),
                            ),
                          ),
                          child: const Text(
                            'Not Now',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ],
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
