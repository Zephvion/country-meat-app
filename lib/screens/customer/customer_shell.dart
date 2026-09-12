import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'home_screen.dart';
import 'categories_listing_screens.dart';
import 'detail_screen.dart';
import 'cart_payment_screens.dart';
import 'order_screens.dart';
import 'rewards_screen.dart';
import 'tier_progress_screen.dart';
import 'referral_screen.dart';
import 'birthday_screen.dart';
import 'profile_addcard_screens.dart';
import 'wallet_screen.dart';
import 'splash_otp_location_screens.dart';
import 'search_screen.dart';
import 'widgets/desktop_header.dart';
import 'notification_permission_screen.dart';
import '../../services/notification_permission_service.dart';

enum CustomerAuthStep { splash, onboarding, login, otp, location, done }

class _NavHistoryItem {
  final CustomerAuthStep authStep;
  final String screen;
  final String? param;
  final int navIndex;

  const _NavHistoryItem({
    required this.authStep,
    required this.screen,
    this.param,
    required this.navIndex,
  });
}

class CustomerShell extends StatefulWidget {
  final CustomerAuthStep initialAuthStep;
  const CustomerShell({super.key, this.initialAuthStep = CustomerAuthStep.splash});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  // ── Auth Flow ────────────────────────────────────────────────────────────
  late CustomerAuthStep _authStep;
  String _userPhone = '9876543210';
  String? _pendingAuthTargetScreen;
  String? _pendingAuthTargetParam;

  // ── In-app navigation ────────────────────────────────────────────────────
  int _navIndex = 0;
  String _screen = 'home';
  String? _param;

  // ── History Stack ────────────────────────────────────────────────────────
  final List<_NavHistoryItem> _history = [];

  bool _hasTriggeredStartupPermissionCheck = false;
  String _screenBeforePermission = 'home';

  void _triggerStartupPermissionCheckIfNeeded() {
    if (_hasTriggeredStartupPermissionCheck) return;
    _hasTriggeredStartupPermissionCheck = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final shouldShow =
          await NotificationPermissionService().shouldShowInitialPermissionScreen();
      if (shouldShow && mounted) {
        setState(() {
          _screenBeforePermission = _screen;
          _screen = 'notification_permission';
        });
      }
    });
  }

  Future<void> _handleNotificationPermissionAllow() async {
    await NotificationPermissionService().requestPermission();
    if (!mounted) return;
    setState(() {
      _screen = _screenBeforePermission;
    });
  }

  Future<void> _handleNotificationPermissionDismiss() async {
    await NotificationPermissionService().markInitialPromptAttempted();
    if (!mounted) return;
    setState(() {
      _screen = _screenBeforePermission;
    });
  }

  @override
  void initState() {
    super.initState();
    _authStep = widget.initialAuthStep;
    if (_authStep == CustomerAuthStep.done) {
      _triggerStartupPermissionCheckIfNeeded();
    }
  }

  bool _requiresAuth(String screen) {
    return screen == 'profile' ||
        screen == 'orders' ||
        screen == 'rewards' ||
        screen == 'tier_progress' ||
        screen == 'referral' ||
        screen == 'birthday' ||
        screen == 'addcard' ||
        screen == 'wallet' ||
        screen == 'payment';
  }

  void _pushHistory() {
    if (_history.isNotEmpty) {
      final top = _history.last;
      if (top.authStep == _authStep &&
          top.screen == _screen &&
          top.param == _param &&
          top.navIndex == _navIndex) {
        return;
      }
    }
    _history.add(_NavHistoryItem(
      authStep: _authStep,
      screen: _screen,
      param: _param,
      navIndex: _navIndex,
    ));
  }

  bool _isRootSection(String screen) {
    return screen == 'home' ||
        screen == 'categories' ||
        screen == 'listing' ||
        screen == 'orders' ||
        screen == 'cart' ||
        screen == 'profile';
  }

  void _handleBack({String? param}) {
    if (_screen == 'notification_permission') {
      _handleNotificationPermissionDismiss();
      return;
    }
    if (_history.isNotEmpty) {
      _pop(param: param);
      return;
    }
    if (_isRootSection(_screen) && _screen != 'home') {
      setState(() {
        _navIndex = 0;
        _screen = 'home';
        _param = param;
      });
      return;
    }
    _pop(param: param);
  }

  void _pop({String? param}) {
    if (_history.isNotEmpty) {
      final previous = _history.removeLast();
      setState(() {
        _authStep = previous.authStep;
        _screen = previous.screen;
        _param = param ?? previous.param;
        _navIndex = previous.navIndex;
      });
    } else {
      setState(() {
        _screen = 'home';
        _param = param;
        _navIndex = 0;
      });
    }
  }

  void _nav(String screen, {String? param}) {
    if (screen == 'back' || screen == 'pop') {
      _handleBack(param: param);
      return;
    }

    if (_authStep == CustomerAuthStep.done && _screen == screen && _param == param) {
      return;
    }

    final appState = context.read<AppState>();
    if (_requiresAuth(screen) && !appState.isLoggedIn) {
      _pendingAuthTargetScreen = screen;
      _pendingAuthTargetParam = param;
      _pushHistory();
      setState(() {
        _authStep = CustomerAuthStep.login;
      });
      return;
    }

    // Handle checkout & post-rating completion: purge completed flow screens from back history
    if (screen == 'confirmation' || screen == 'tracking') {
      _history.removeWhere((item) => item.screen == 'payment' || item.screen == 'cart');
    } else if (screen == 'home') {
      _history.removeWhere((item) =>
          item.screen == 'tracking' ||
          item.screen == 'confirmation' ||
          item.screen == 'payment' ||
          item.screen == 'cart');
    }

    _pushHistory();

    setState(() {
      _screen = screen;
      _param = param;
      // Sync bottom tab if navigating to root screens
      switch (screen) {
        case 'home': _navIndex = 0; break;
        case 'categories':
        case 'listing': _navIndex = 1; break;
        case 'orders':
        case 'tracking':
        case 'confirmation': _navIndex = 2; break;
        case 'rewards':
        case 'tier_progress':
        case 'referral':
        case 'birthday':
        case 'profile':
        case 'addcard':
        case 'wallet': _navIndex = 3; break;
      }
    });
  }

  void _onNavTap(int idx) {
    String targetScreen = 'home';
    switch (idx) {
      case 0: targetScreen = 'home'; break;
      case 1: targetScreen = 'categories'; break;
      case 2: targetScreen = 'orders'; break;
      case 3: targetScreen = 'profile'; break;
    }

    if (_navIndex == idx && _screen == targetScreen && _param == null) {
      return;
    }

    final appState = context.read<AppState>();
    if (_requiresAuth(targetScreen) && !appState.isLoggedIn) {
      _pendingAuthTargetScreen = targetScreen;
      _pendingAuthTargetParam = null;
      _pushHistory();
      setState(() {
        _authStep = CustomerAuthStep.login;
      });
      return;
    }

    // Entering a primary root tab: clear sub-screen history to prevent back loops
    _history.clear();

    setState(() {
      _navIndex = idx;
      _screen = targetScreen;
      _param = null;
    });
  }

  Widget _buildScreenBody() {
    switch (_screen) {
      case 'home':
        return CustHomeScreen(nav: _nav);
      case 'categories':
        return CustCategoriesScreen(nav: _nav);
      case 'listing':
        return CustListingScreen(category: _param ?? 'chicken', nav: _nav);
      case 'detail':
        return CustDetailScreen(
          productId: _param ?? kAllProducts.first.id,
          nav: _nav,
        );
      case 'cart':
        return CustCartScreen(nav: _nav);
      case 'orders':
        return CustOrdersScreen(nav: _nav);
      case 'rewards':
        return CustRewardsScreen(nav: _nav);
      case 'tier_progress':
        return CustTierProgressScreen(nav: _nav);
      case 'referral':
        return CustReferralScreen(nav: _nav);
      case 'birthday':
        return CustBirthdayScreen(nav: _nav);
      case 'profile':
        return CustProfileScreen(nav: _nav, param: _param);
      case 'addcard':
        return CustAddCardScreen(nav: _nav);
      case 'wallet':
        return CustWalletScreen(nav: _nav);
      case 'search':
        return CustSearchScreen(nav: _nav, initialQuery: _param);
      default:
        return CustHomeScreen(nav: _nav);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    // ── Auth Flow ────────────────────────────────────────────────────────
    if (_authStep == CustomerAuthStep.splash) {
      content = CustSplashScreen(
        onDone: () {
          final isLoggedIn = context.read<AppState>().isLoggedIn;
          _history.clear();
          setState(() {
            if (isLoggedIn || kIsWeb) {
              _authStep = CustomerAuthStep.done;
              _screen = 'home';
            } else {
              _authStep = CustomerAuthStep.onboarding;
            }
          });
        },
      );
    } else if (_authStep == CustomerAuthStep.onboarding) {
      content = CustOnboardingScreen(
        onDone: () {
          _pushHistory();
          setState(() => _authStep = CustomerAuthStep.login);
        },
      );
    } else if (_authStep == CustomerAuthStep.login) {
      content = CustLoginScreen(
        onContinue: (phone) {
          _pushHistory();
          setState(() {
            _userPhone = phone;
            _authStep = CustomerAuthStep.otp;
          });
        },
      );
    } else if (_authStep == CustomerAuthStep.otp) {
      content = CustOtpScreen(
        phone: _userPhone,
        onContinue: () {
          _pushHistory();
          final appState = context.read<AppState>();
          appState.updateUser('Arjun Kumar', _userPhone);
          appState.setLoggedIn(true);

          if (_pendingAuthTargetScreen != null) {
            final targetScreen = _pendingAuthTargetScreen!;
            final targetParam = _pendingAuthTargetParam;
            _pendingAuthTargetScreen = null;
            _pendingAuthTargetParam = null;
            setState(() {
              _authStep = CustomerAuthStep.done;
              _screen = targetScreen;
              _param = targetParam;
              switch (targetScreen) {
                case 'home': _navIndex = 0; break;
                case 'categories':
                case 'listing': _navIndex = 1; break;
                case 'orders':
                case 'tracking':
                case 'confirmation': _navIndex = 2; break;
                case 'rewards':
                case 'tier_progress':
                case 'referral':
                case 'birthday':
                case 'profile':
                case 'addcard':
                case 'wallet': _navIndex = 3; break;
              }
            });
          } else {
            setState(() => _authStep = CustomerAuthStep.location);
          }
        },
      );
    } else if (_authStep == CustomerAuthStep.location) {
      content = CustLocationScreen(
        onContinue: () {
          _history.clear();
          final targetScreen = _pendingAuthTargetScreen ?? 'home';
          final targetParam = _pendingAuthTargetParam;
          _pendingAuthTargetScreen = null;
          _pendingAuthTargetParam = null;
          setState(() {
            _authStep = CustomerAuthStep.done;
            _screen = targetScreen;
            _param = targetParam;
          });
        },
        onBack: () {
          if (_history.isNotEmpty) {
            _pop();
          } else {
            setState(() => _authStep = CustomerAuthStep.otp);
          }
        },
      );
    } else {
      // ── Main App ─────────────────────────────────────────────────────────
      _triggerStartupPermissionCheckIfNeeded();
      final appState = context.watch<AppState>();

      // Full-screen overlays (no bottom nav)
      if (_screen == 'confirmation') {
        content = CustConfirmationScreen(nav: _nav);
      } else if (_screen == 'tracking') {
        content = CustTrackingScreen(
          orderId: _param ?? (appState.orders.isNotEmpty ? appState.orders.first.id : ''),
          nav: _nav,
        );
      } else if (_screen == 'payment') {
        content = Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(child: CustPaymentScreen(nav: _nav)),
        );
      } else if (_screen == 'location') {
        final isProfileAddress = _param == 'profileAddress' || _param == 'profile';
        final isHomeAddress = _param == 'homeAddress' || _param == 'home' || _param == 'newAddress';
        final isFromCart = _param == 'cart' || _param == 'fromCart';
        final isNewAddress = _param == 'newAddress' || _param == 'new' || _param == 'add' || isProfileAddress;

        final LocationOrigin origin;
        if (isProfileAddress) {
          origin = LocationOrigin.profileAddress;
        } else if (isHomeAddress) {
          origin = LocationOrigin.homeAddress;
        } else if (isFromCart) {
          origin = LocationOrigin.cart;
        } else {
          origin = LocationOrigin.onboarding;
        }

        content = CustLocationScreen(
          origin: origin,
          fromCart: isFromCart,
          startWithNewAddress: isNewAddress,
          onContinue: () {
            _nav('back', param: isProfileAddress ? 'addresses' : null);
          },
          onBack: () => _nav('back', param: isProfileAddress ? 'addresses' : null),
        );
      } else if (_screen == 'notification_permission') {
        content = CustNotificationPermissionScreen(
          onAllow: _handleNotificationPermissionAllow,
          onNotNow: _handleNotificationPermissionDismiss,
        );
      } else {
        content = Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(child: _buildScreenBody()),
          bottomNavigationBar: _BottomNav(
            currentIndex: _navIndex,
            cartCount: appState.cartCount,
            onTap: (i) {
              _onNavTap(i);
            },
            onCartTap: () => _nav('cart'),
          ),
        );
      }
    }

    final bool canPopApp =
        _authStep == CustomerAuthStep.done && _screen == 'home' && _history.isEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isDesktop = width >= AppBreakpoints.desktopMin;
        final bool isTablet = width >= AppBreakpoints.tabletMin && width < AppBreakpoints.desktopMin;

        Widget responsiveContent;

        if (_authStep != CustomerAuthStep.done) {
          // ── Auth Flow Shell ─────────────────────────────────────────────
          if (isDesktop || isTablet) {
            if (_authStep == CustomerAuthStep.splash || _authStep == CustomerAuthStep.location) {
              responsiveContent = content;
            } else {
              responsiveContent = Scaffold(
                backgroundColor: AppColors.gray50,
                body: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      child: content,
                    ),
                  ),
                ),
              );
            }
          } else {
            responsiveContent = content;
          }
        } else {
          // ── Main App Shell (Auth Step is DONE) ──────────────────────────
          final appState = context.watch<AppState>();

          if (isDesktop) {
            // Desktop Layout: Desktop Header at top, Centered Max-Width Body (1200px), NO Bottom Nav
            Widget desktopBody;

            if (_screen == 'confirmation') {
              desktopBody = CustConfirmationScreen(nav: _nav);
            } else if (_screen == 'tracking') {
              desktopBody = CustTrackingScreen(
                orderId: _param ?? (appState.orders.isNotEmpty ? appState.orders.first.id : ''),
                nav: _nav,
              );
            } else if (_screen == 'payment') {
              desktopBody = CustPaymentScreen(nav: _nav);
            } else if (_screen == 'location') {
              final isProfileAddress = _param == 'profileAddress' || _param == 'profile';
              final isHomeAddress = _param == 'homeAddress' || _param == 'home' || _param == 'newAddress';
              final isFromCart = _param == 'cart' || _param == 'fromCart';
              final isNewAddress = _param == 'newAddress' || _param == 'new' || _param == 'add' || isProfileAddress;

              final LocationOrigin origin;
              if (isProfileAddress) {
                origin = LocationOrigin.profileAddress;
              } else if (isHomeAddress) {
                origin = LocationOrigin.homeAddress;
              } else if (isFromCart) {
                origin = LocationOrigin.cart;
              } else {
                origin = LocationOrigin.onboarding;
              }

              desktopBody = CustLocationScreen(
                origin: origin,
                fromCart: isFromCart,
                startWithNewAddress: isNewAddress,
                onContinue: () => _nav('back', param: isProfileAddress ? 'addresses' : null),
                onBack: () => _nav('back', param: isProfileAddress ? 'addresses' : null),
              );
            } else if (_screen == 'notification_permission') {
              desktopBody = CustNotificationPermissionScreen(
                onAllow: _handleNotificationPermissionAllow,
                onNotNow: _handleNotificationPermissionDismiss,
              );
            } else {
              desktopBody = _buildScreenBody();
            }

            responsiveContent = Scaffold(
              backgroundColor: AppColors.white,
              body: Column(
                children: [
                  DesktopHeader(
                    navIndex: _navIndex,
                    currentScreen: _screen,
                    cartCount: appState.cartCount,
                    defaultAddress: appState.defaultAddress,
                    onNavTap: _onNavTap,
                    onNav: _nav,
                  ),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: desktopBody,
                    ),
                  ),
                ],
              ),
            );
          } else if (isTablet) {
            // Tablet Layout: Centered Max-Width Body (840px), Bottom Nav constrained
            Widget tabletBody;

            if (_screen == 'confirmation') {
              tabletBody = CustConfirmationScreen(nav: _nav);
            } else if (_screen == 'tracking') {
              tabletBody = CustTrackingScreen(
                orderId: _param ?? (appState.orders.isNotEmpty ? appState.orders.first.id : ''),
                nav: _nav,
              );
            } else if (_screen == 'payment') {
              tabletBody = CustPaymentScreen(nav: _nav);
            } else if (_screen == 'location') {
              final isProfileAddress = _param == 'profileAddress' || _param == 'profile';
              final isHomeAddress = _param == 'homeAddress' || _param == 'home' || _param == 'newAddress';
              final isFromCart = _param == 'cart' || _param == 'fromCart';
              final isNewAddress = _param == 'newAddress' || _param == 'new' || _param == 'add' || isProfileAddress;

              final LocationOrigin origin;
              if (isProfileAddress) {
                origin = LocationOrigin.profileAddress;
              } else if (isHomeAddress) {
                origin = LocationOrigin.homeAddress;
              } else if (isFromCart) {
                origin = LocationOrigin.cart;
              } else {
                origin = LocationOrigin.onboarding;
              }

              tabletBody = CustLocationScreen(
                origin: origin,
                fromCart: isFromCart,
                startWithNewAddress: isNewAddress,
                onContinue: () => _nav('back', param: isProfileAddress ? 'addresses' : null),
                onBack: () => _nav('back', param: isProfileAddress ? 'addresses' : null),
              );
            } else if (_screen == 'notification_permission') {
              tabletBody = CustNotificationPermissionScreen(
                onAllow: _handleNotificationPermissionAllow,
                onNotNow: _handleNotificationPermissionDismiss,
              );
            } else {
              tabletBody = _buildScreenBody();
            }

            final bool isOverlayScreen = _screen == 'confirmation' ||
                _screen == 'tracking' ||
                _screen == 'payment' ||
                _screen == 'location' ||
                _screen == 'notification_permission';

            responsiveContent = Scaffold(
              backgroundColor: AppColors.white,
              body: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppBreakpoints.maxTabletContentWidth),
                    child: SizedBox.expand(
                      child: tabletBody,
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: isOverlayScreen
                  ? null
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: AppBreakpoints.maxTabletContentWidth),
                        child: _BottomNav(
                          currentIndex: _navIndex,
                          cartCount: appState.cartCount,
                          onTap: _onNavTap,
                          onCartTap: () => _nav('cart'),
                        ),
                      ),
                    ),
            );
          } else {
            // Mobile Layout (< 768px): Exact existing mobile implementation!
            responsiveContent = content;
          }
        }

        return PopScope(
          canPop: canPopApp,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _handleBack();
          },
          child: responsiveContent,
        );
      },
    );
  }
}

// ─── BOTTOM NAV ──────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final int cartCount;
  final ValueChanged<int> onTap;
  final VoidCallback onCartTap;
  const _BottomNav({
    required this.currentIndex,
    required this.cartCount,
    required this.onTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.gray100)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                iconOutline: Icons.home_outlined,
                label: 'Home',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.storefront_rounded,
                iconOutline: Icons.storefront_outlined,
                label: 'Shop',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              // Center cart button
              Expanded(
                child: GestureDetector(
                  onTap: onCartTap,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: const BoxDecoration(
                          gradient: AppGradients.brandRed,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.card,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 22),
                            if (cartCount > 0)
                              Positioned(
                                right: 6, top: 6,
                                child: Container(
                                  width: 16, height: 16,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('$cartCount',
                                      style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.brandRed)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.receipt_long_rounded,
                iconOutline: Icons.receipt_long_outlined,
                label: 'Orders',
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                iconOutline: Icons.person_outline_rounded,
                label: 'Profile',
                selected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, iconOutline;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.iconOutline,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              selected ? icon : iconOutline,
              key: ValueKey(selected),
              color: selected ? AppColors.brandRed : AppColors.gray400,
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.brandRed : AppColors.gray400)),
        ],
      ),
    ),
  );
}
