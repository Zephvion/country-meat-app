import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class DesktopHeader extends StatelessWidget {
  final int navIndex;
  final String currentScreen;
  final int cartCount;
  final String defaultAddress;
  final ValueChanged<int> onNavTap;
  final void Function(String screen, {String? param}) onNav;

  const DesktopHeader({
    super.key,
    required this.navIndex,
    required this.currentScreen,
    required this.cartCount,
    required this.defaultAddress,
    required this.onNavTap,
    required this.onNav,
  });

  @override
  Widget build(BuildContext context) {
    final locationLabel = defaultAddress.split(',').first.trim();

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200, width: 1)),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
                // ── Brand Logo ───────────────────────────────────────────────
                InkWell(
                  onTap: () => onNav('home'),
                  borderRadius: BorderRadius.circular(AppRadius.base),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/logo_white_cropped.png',
                          height: 38,
                          fit: BoxFit.contain,
                          color: AppColors.brandRed,
                          colorBlendMode: BlendMode.srcIn,
                          errorBuilder: (_, __, ___) => const Row(
                            children: [
                              Icon(Icons.set_meal_rounded, color: AppColors.brandRed, size: 28),
                              SizedBox(width: 8),
                              Text(
                                'COUNTRY MEAT',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brandRed,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 32),

                // ── Root Navigation Items ────────────────────────────────────
                _HeaderLink(
                  label: 'Home',
                  icon: Icons.home_rounded,
                  isActive: navIndex == 0 && currentScreen == 'home',
                  onTap: () => onNavTap(0),
                ),
                const SizedBox(width: 8),
                _HeaderLink(
                  label: 'Shop',
                  icon: Icons.storefront_rounded,
                  isActive: navIndex == 1 || currentScreen == 'categories' || currentScreen == 'listing',
                  onTap: () => onNavTap(1),
                ),
                const SizedBox(width: 8),
                _HeaderLink(
                  label: 'Orders',
                  icon: Icons.receipt_long_rounded,
                  isActive: navIndex == 2 || currentScreen == 'orders' || currentScreen == 'tracking',
                  onTap: () => onNavTap(2),
                ),

                const Spacer(),

                // ── Search Action ───────────────────────────────────────────
                InkWell(
                  onTap: () => onNav('search'),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: currentScreen == 'search' ? AppColors.brandRedBg : AppColors.gray100,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: currentScreen == 'search' ? AppColors.brandRed : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: currentScreen == 'search' ? AppColors.brandRed : AppColors.gray600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Search meats...',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: currentScreen == 'search' ? AppColors.brandRed : AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ── Delivery Location Selector ───────────────────────────────
                InkWell(
                  onTap: () => onNav('location', param: 'homeAddress'),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 16, color: AppColors.brandRed),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 130),
                          child: Text(
                            locationLabel.isNotEmpty ? locationLabel : 'Deliver to',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray800,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.gray500),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ── Cart Button ──────────────────────────────────────────────
                InkWell(
                  onTap: () => onNav('cart'),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: currentScreen == 'cart' ? AppGradients.brandRed : null,
                      color: currentScreen == 'cart' ? null : AppColors.brandRed,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_cart_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Cart',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (cartCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              '$cartCount',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.brandRed,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ── Profile / Avatar Control ──────────────────────────────────
                InkWell(
                  onTap: () => onNav('profile'),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: (currentScreen == 'profile' || currentScreen == 'rewards' || currentScreen == 'wallet')
                          ? AppColors.brandRedBg
                          : AppColors.gray100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (currentScreen == 'profile' || currentScreen == 'rewards' || currentScreen == 'wallet')
                            ? AppColors.brandRed
                            : AppColors.gray200,
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 20,
                      color: (currentScreen == 'profile' || currentScreen == 'rewards' || currentScreen == 'wallet')
                          ? AppColors.brandRed
                          : AppColors.gray700,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _HeaderLink extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _HeaderLink({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.base),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.brandRedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.base),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.brandRed : AppColors.gray600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? AppColors.brandRed : AppColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
