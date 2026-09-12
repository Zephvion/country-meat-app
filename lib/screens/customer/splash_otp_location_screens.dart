import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_map_widget.dart';
import '../../data/mock_location_data.dart';
import 'cart_payment_screens.dart';
import 'home_screen.dart';
import 'profile_addcard_screens.dart';

// ─── SPLASH ──────────────────────────────────────────────────────────────────
// Design: Two distinct Figma splash states with a simple cross-fade transition
// State 1: Red background + native white logo
// State 2: White background + red logo (Fades in over State 1)
class CustSplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const CustSplashScreen({super.key, required this.onDone});

  @override
  State<CustSplashScreen> createState() => _CustSplashScreenState();
}

class _CustSplashScreenState extends State<CustSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  Timer? _timer1;
  Timer? _timer2;
  bool _isInitStarted = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    // State 1 logo scale animation on red background (0.96 -> 1.02)
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = Tween<double>(begin: 0.96, end: 1.02).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutCubic),
    );

    // State 2 transition: Cross-fade to white background + red logo
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeInOut,
    );

    _fadeCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // State 2 hold (800ms) -> Route to next screen (Login on Mobile, Home on Web)
        _timer2 = Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            widget.onDone();
          }
        });
      }
    });

    // Start State 1 hold and scale animation ONLY AFTER the first frame is rendered on screen.
    // This ensures State 1 is visible on physical devices for the full 1200ms regardless of startup lag.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scaleCtrl.forward();

      // State 1 hold (1200ms) -> Start cross-fade transition to State 2
      _timer1 = Timer(const Duration(milliseconds: 1200), () {
        if (mounted) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
          _fadeCtrl.forward();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitStarted) {
      _isInitStarted = true;
      try {
        precacheImage(const AssetImage('assets/images/logo_white_cropped.png'), context);
        precacheImage(const AssetImage('assets/images/logo_white.png'), context);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _timer1?.cancel();
    _timer2?.cancel();
    _scaleCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoWidth = screenWidth * 0.7 > 280 ? 280.0 : screenWidth * 0.7;
    final logoHeight = logoWidth / (3734.0 / 1448.0);

    debugPrint('[SPLASH DIAGNOSTIC] build: logoWidth=$logoWidth, logoHeight=$logoHeight, scaleCtrl=${_scaleCtrl.value}, scaleAnim=${_scaleAnim.value}, fadeCtrl=${_fadeCtrl.value}, fadeAnim=${_fadeAnim.value}');

    return Scaffold(
      backgroundColor: AppColors.brandRed,
      body: Stack(
        children: [
          // ── STATE 1: Red background + white logo (Visible on Frame 0) ──────
          Container(
            color: AppColors.brandRed,
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnim,
                child: SizedBox(
                  width: logoWidth,
                  height: logoHeight,
                  child: Image.asset(
                    'assets/images/logo_white_cropped.png',
                    width: logoWidth,
                    height: logoHeight,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/logo_white.png',
                      width: logoWidth,
                      height: logoHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── STATE 2: White background + red logo (Cross-fades over State 1) ─
          FadeTransition(
            opacity: _fadeAnim,
            child: Container(
              color: Colors.white,
              child: Center(
                child: SizedBox(
                  width: logoWidth,
                  height: logoHeight,
                  child: Image.asset(
                    'assets/images/logo_white_cropped.png',
                    width: logoWidth,
                    height: logoHeight,
                    fit: BoxFit.contain,
                    color: AppColors.brandRed,
                    colorBlendMode: BlendMode.srcIn,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/logo_white.png',
                      width: logoWidth,
                      height: logoHeight,
                      fit: BoxFit.contain,
                      color: AppColors.brandRed,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ONBOARDING ──────────────────────────────────────────────────────────────
// Design: Solid red background with white logo at top, six circular value proposition
// illustrations centered in middle, and white bottom card with tagline + Get Started.
// Entrance: Subtle 350ms Fade + Slide transition for complete screen composition.
class CustOnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const CustOnboardingScreen({super.key, required this.onDone});

  @override
  State<CustOnboardingScreen> createState() => _CustOnboardingScreenState();
}

class _CustOnboardingScreenState extends State<CustOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0.0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
    ));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          return _buildDesktopLayout(context);
        }
        return _buildMobileLayout(context);
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Container(
      width: 960,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: Container(
              color: AppColors.brandRed,
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_white_cropped.png',
                    width: 240,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/logo_white.png',
                      width: 240,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 280,
                    child: Image.asset(
                      'assets/images/getStarted.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/ob_icon5.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(44),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.gray500,
                        fontFamily: 'Inter',
                      ),
                      children: [
                        TextSpan(text: 'Welcome to '),
                        TextSpan(
                          text: 'Country Meat',
                          style: TextStyle(
                            color: AppColors.brandRed,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'A company by the meat lovers\nfor the meat lovers',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gray900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Organically raised country chicken, pasture-fed mutton, and farm-fresh eggs delivered at dawn directly from village farms.',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: AppColors.gray600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: const Text('Get Started →'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final logoWidth = mediaQuery.size.width * 0.7;

    return Scaffold(
      backgroundColor: AppColors.brandRed,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo_white_cropped.png',
                          width: logoWidth,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/logo_white.png',
                            width: logoWidth,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              'assets/images/getStarted.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/ob_icon5.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gray500,
                            fontFamily: 'Inter',
                          ),
                          children: [
                            TextSpan(text: 'Welcome to '),
                            TextSpan(
                              text: 'Country Meat',
                              style: TextStyle(
                                color: AppColors.brandRed,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'A company by the meat lovers\nfor the meat lovers',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gray900,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onDone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Get Started'),
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

// ─── PHONE LOGIN ─────────────────────────────────────────────────────────────
class CustLoginScreen extends StatefulWidget {
  final ValueChanged<String> onContinue;
  const CustLoginScreen({super.key, required this.onContinue});

  @override
  State<CustLoginScreen> createState() => _CustLoginScreenState();
}

class _CustLoginScreenState extends State<CustLoginScreen> {
  final _ctrl = TextEditingController();
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isLoading) return;

    final raw = _ctrl.text.trim();
    final digitsOnly = raw.replaceAll(RegExp(r'\D'), '');

    if (raw.isNotEmpty && digitsOnly.length != 10) {
      setState(() {
        _errorMsg = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _errorMsg = null;
    });

    final phoneNum = digitsOnly.isEmpty ? '9876543210' : digitsOnly;
    final fullPhone = phoneNum.startsWith('+91') ? phoneNum : '+91 $phoneNum';
    widget.onContinue(fullPhone);
  }

  Widget _buildIndiaFlag() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: 22,
        height: 15,
        child: Column(
          children: [
            Expanded(child: Container(color: const Color(0xFFFF9933))),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF000080),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: Container(color: const Color(0xFF138808))),
          ],
        ),
      ),
    );
  }

  Widget _buildSendOtpButton({required double verticalPadding, String label = 'Get OTP'}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.brandRed.withOpacity(0.7),
          disabledForegroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 768;

        if (isDesktop) {
          return Center(
            child: Container(
              width: 480,
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Logo small
                  Center(
                    child: Image.asset(
                      'assets/images/logo_white_cropped.png',
                      width: 190,
                      fit: BoxFit.contain,
                      color: AppColors.brandRed,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Login with your mobile number',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Mobile Number',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Phone input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E6E6),
                      border: Border.all(color: const Color(0xFFE2C8C8), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildIndiaFlag(),
                        Container(
                          width: 1,
                          height: 18,
                          color: const Color(0xFFD4BDBD),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        const Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9E8A8A),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 18,
                          color: const Color(0xFFD4BDBD),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray900,
                            ),
                            decoration: const InputDecoration(
                              filled: false,
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: '12345-67890',
                              hintStyle: TextStyle(
                                color: Color(0xFF9E8A8A),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              counterText: '',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMsg!,
                      style: const TextStyle(
                        color: AppColors.brandRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildSendOtpButton(verticalPadding: 16, label: 'Get OTP'),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.chevron_left),
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              style: IconButton.styleFrom(
                                shape: const CircleBorder(),
                                side: const BorderSide(
                                  color: AppColors.gray300,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Logo small
                        Center(
                          child: Image.asset(
                            'assets/images/logo_white_cropped.png',
                            width: 190,
                            fit: BoxFit.contain,
                            color: AppColors.brandRed,
                            colorBlendMode: BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 36),
                        const Text(
                          'Login with your mobile number',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Mobile Number',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Phone input
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E6E6),
                            border: Border.all(color: const Color(0xFFE2C8C8), width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildIndiaFlag(),
                              Container(
                                width: 1,
                                height: 18,
                                color: const Color(0xFFD4BDBD),
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              const Text(
                                '+91',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9E8A8A),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 18,
                                color: const Color(0xFFD4BDBD),
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _ctrl,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.gray900,
                                  ),
                                  decoration: const InputDecoration(
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText: '12345-67890',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF9E8A8A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                    counterText: '',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_errorMsg != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _errorMsg!,
                            style: const TextStyle(
                              color: AppColors.brandRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const Spacer(),
                        const SizedBox(height: 16),
                        _buildSendOtpButton(verticalPadding: 14, label: 'Get OTP'),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── OTP SCREEN ───────────────────────────────────────────────────────────────
class CustOtpScreen extends StatefulWidget {
  final String phone;
  final VoidCallback onContinue;
  const CustOtpScreen({super.key, required this.phone, required this.onContinue});

  @override
  State<CustOtpScreen> createState() => _CustOtpScreenState();
}

class _CustOtpScreenState extends State<CustOtpScreen> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());
  int _secondsLeft = 30;
  Timer? _timer;
  bool _isLoading = false;
  bool _hasSubmitted = false;
  int _resendCount = 0;
  String? _errorMsg;

  bool get _isOtpComplete =>
      _controllers.every((c) => c.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _startTimer(30);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  void _startTimer([int seconds = 30]) {
    _timer?.cancel();
    _secondsLeft = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
      }
    });
  }

  void _handleResend() {
    if (_resendCount >= 2 || _secondsLeft > 0) return;
    setState(() {
      _resendCount++;
      _errorMsg = null;
    });
    _startTimer(59);
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _formattedPhone {
    final raw = widget.phone.trim();
    if (raw.isEmpty) {
      return '+91 9876543210';
    }
    if (raw.startsWith('+91')) {
      final digits = raw.substring(3).trim();
      return '+91 ${digits.isEmpty ? "9876543210" : digits}';
    }
    return '+91 $raw';
  }

  Future<void> _handleLogin() async {
    if (_isLoading || !_isOtpComplete) return;

    final otpCode = _controllers.map((c) => c.text.trim()).join();
    if (otpCode.length < 4) {
      setState(() {
        _errorMsg = 'Please enter all 4 digits of the OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    if (!_hasSubmitted) {
      _hasSubmitted = true;
      widget.onContinue();
    }
  }

  void _handleOtpChanged(int index, String value) {
    if (_errorMsg != null) {
      setState(() => _errorMsg = null);
    }
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Widget _buildLoginButton({required double verticalPadding}) {
    final enabled = _isOtpComplete && !_isLoading;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? _handleLogin : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.brandRed.withOpacity(0.5),
          disabledForegroundColor: Colors.white.withOpacity(0.8),
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text('Login'),
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        return Container(
          width: 56,
          height: 58,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E6E6),
            border: Border.all(
              color: _focusNodes[i].hasFocus
                  ? AppColors.brandRed
                  : const Color(0xFFE2C8C8),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              onChanged: (v) => _handleOtpChanged(i, v),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.brandRed,
              ),
              decoration: const InputDecoration(
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                counterText: '',
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResendSection() {
    // Stage 1: Countdown is active - show ONLY the timer, no Resend button
    if (_secondsLeft > 0) {
      return Center(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: AppColors.gray500, fontSize: 13),
            children: [
              const TextSpan(text: "Resend OTP in "),
              TextSpan(
                text: '${_secondsLeft}s',
                style: const TextStyle(
                  color: AppColors.brandRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Stage 2: Timer reached 0 & user has resends remaining (< 2 resends used)
    if (_resendCount < 2) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Didn't receive any OTP? ",
              style: TextStyle(color: AppColors.gray500, fontSize: 13),
            ),
            GestureDetector(
              onTap: _handleResend,
              child: const Text(
                'Resend OTP',
                style: TextStyle(
                  color: AppColors.brandRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Stage 3: Timer reached 0 & user reached max limit (2 resends completed)
    return Center(
      child: Column(
        children: [
          const Text(
            "Didn't receive OTP after multiple attempts?",
            style: TextStyle(color: AppColors.gray500, fontSize: 13),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: const Text(
              'check phone number',
              style: TextStyle(
                color: AppColors.brandRed,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.brandRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 768;

        if (isDesktop) {
          return Center(
            child: Container(
              width: 480,
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Logo small
                  Center(
                    child: Image.asset(
                      'assets/images/logo_white_cropped.png',
                      width: 190,
                      fit: BoxFit.contain,
                      color: AppColors.brandRed,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: const Text(
                      'Verify with OTP sent to',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      _formattedPhone,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandRed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // 4 OTP Boxes
                  _buildOtpFields(),
                  const SizedBox(height: 16),
                  // Resend text / timer
                  _buildResendSection(),
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _errorMsg!,
                        style: const TextStyle(
                          color: AppColors.brandRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildLoginButton(verticalPadding: 16),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.chevron_left),
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              style: IconButton.styleFrom(
                                shape: const CircleBorder(),
                                side: const BorderSide(
                                  color: AppColors.gray300,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Logo small
                        Center(
                          child: Image.asset(
                            'assets/images/logo_white_cropped.png',
                            width: 190,
                            fit: BoxFit.contain,
                            color: AppColors.brandRed,
                            colorBlendMode: BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Center(
                          child: const Text(
                            'Verify with OTP sent to',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            _formattedPhone,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // 4 OTP Boxes
                        _buildOtpFields(),
                        const SizedBox(height: 16),
                        // Resend text / timer
                        _buildResendSection(),
                        if (_errorMsg != null) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              _errorMsg!,
                              style: const TextStyle(
                                color: AppColors.brandRed,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        const SizedBox(height: 16),
                        _buildLoginButton(verticalPadding: 14),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── LOCATION ─────────────────────────────────────────────────────────────────
enum _LocationStep {
  initial,
  selectLocation,
  search,
  map,
  addressDetails,
}

enum LocationOrigin { onboarding, cart, profileAddress, homeAddress }

class CustLocationScreen extends StatefulWidget {
  final LocationOrigin origin;
  final VoidCallback onContinue;
  final bool fromCart;
  final bool startWithNewAddress;
  final VoidCallback? onBack;

  const CustLocationScreen({
    super.key,
    this.origin = LocationOrigin.onboarding,
    required this.onContinue,
    this.fromCart = false,
    this.startWithNewAddress = false,
    this.onBack,
  });

  @override
  State<CustLocationScreen> createState() => _CustLocationScreenState();
}

class _CustLocationScreenState extends State<CustLocationScreen> {
  late _LocationStep _step;
  _LocationStep? _previousStep;
  _LocationStep? _stepBeforeMapPreview;
  String _selectedTag = 'Home'; // 'Home', 'Friend and Family', 'Others'
  String _currentLocationTitle = 'HSR Layout';
  String _currentSubAddress = 'HSR Layout, Gowtham PG, Bengaluru, Karnataka, India';
  LatLng _selectedLatLng = MockLocationData.customerLocation;

  late final TextEditingController _flatCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _receiverNameCtrl;
  late final TextEditingController _receiverPhoneCtrl;
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    if (widget.startWithNewAddress) {
      _step = _LocationStep.search;
    } else {
      _step = widget.fromCart ? _LocationStep.selectLocation : _LocationStep.initial;
    }
    _flatCtrl = TextEditingController();
    _areaCtrl = TextEditingController();
    _receiverNameCtrl = TextEditingController();
    _receiverPhoneCtrl = TextEditingController();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _flatCtrl.dispose();
    _areaCtrl.dispose();
    _receiverNameCtrl.dispose();
    _receiverPhoneCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _goBack() {
    setState(() {
      if (_step == _LocationStep.addressDetails) {
        _step = _previousStep ?? _LocationStep.map;
      } else if (_step == _LocationStep.map) {
        if (_stepBeforeMapPreview == _LocationStep.addressDetails) {
          _stepBeforeMapPreview = null;
          _step = _LocationStep.addressDetails;
        } else {
          _step = _LocationStep.search;
        }
      } else if (_step == _LocationStep.search) {
        if (_previousStep == _LocationStep.selectLocation) {
          _step = _LocationStep.selectLocation;
        } else if (widget.startWithNewAddress || widget.fromCart || widget.origin != LocationOrigin.onboarding) {
          widget.onBack?.call();
        } else {
          _step = _LocationStep.initial;
        }
      } else if (_step == _LocationStep.selectLocation) {
        if (widget.fromCart || widget.origin != LocationOrigin.onboarding) {
          widget.onBack?.call();
        } else {
          _step = _LocationStep.initial;
        }
      } else if (_step == _LocationStep.initial) {
        widget.onBack?.call();
      }
    });
  }

  void _saveAndProceed(AppState appState) {
    final flat = _flatCtrl.text.trim();
    final area = _areaCtrl.text.trim();
    final effectiveFlat = flat.isNotEmpty ? flat : 'Flat 200';
    final effectiveArea = area.isNotEmpty ? area : 'Lakshmi Residency, Road No. 4';

    final fullAddr = '$effectiveFlat, $effectiveArea, $_currentSubAddress';

    String label = _selectedTag;
    if (_selectedTag == 'Others') {
      final name = _receiverNameCtrl.text.trim();
      label = name.isNotEmpty ? name : 'Others';
    } else if (_selectedTag == 'Friend and Family') {
      final name = _receiverNameCtrl.text.trim();
      label = name.isNotEmpty ? name : 'Friend & Family';
    }

    final newAddr = SavedAddress(
      label: label,
      address: fullAddr,
      isDefault: true,
    );

    appState.addAddress(newAddr);
    appState.setDefaultAddress(newAddr);
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBack();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 768;

          if (_step == _LocationStep.initial || _step == _LocationStep.selectLocation || _step == _LocationStep.search) {
            final Widget dialogContent = _buildStepContent(context, appState);

            final Widget bgScreen = (widget.origin == LocationOrigin.cart || widget.fromCart)
                ? CustCartScreen(nav: (r, {param}) {})
                : (widget.origin == LocationOrigin.profileAddress
                    ? CustProfileScreen(nav: (r, {param}) {})
                    : CustHomeScreen(nav: (r, {param}) {}));

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: AbsorbPointer(
                      absorbing: true,
                      child: Container(
                        color: Colors.white,
                        child: bgScreen,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _goBack,
                      child: ClipRect(
                        clipBehavior: Clip.hardEdge,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                          child: Container(
                            color: Colors.white.withValues(alpha: 0.40),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isDesktop)
                    Center(
                      child: Container(
                        width: 580,
                        constraints: const BoxConstraints(maxHeight: 640),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: AppShadows.card,
                        ),
                        child: dialogContent,
                      ),
                    )
                  else
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.85,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        child: SafeArea(
                          top: false,
                          child: dialogContent,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          if (isDesktop) {
            final Widget stepWidget = _buildStepContent(context, appState);
            final double containerWidth = _step == _LocationStep.map ? 880.0 : 720.0;

            return Scaffold(
              backgroundColor: AppColors.gray50,
              body: SafeArea(
                child: Center(
                  child: Container(
                    width: containerWidth,
                    margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadows.card,
                      border: Border.all(color: AppColors.gray200),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: stepWidget,
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: _buildStepContent(context, appState),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, AppState appState) {
    switch (_step) {
      case _LocationStep.initial:
        return _buildInitialState(context, appState);
      case _LocationStep.selectLocation:
        return _buildSelectLocationState(context, appState);
      case _LocationStep.search:
        return _buildSearchState(context, appState);
      case _LocationStep.map:
        return _buildMapState(context, appState);
      case _LocationStep.addressDetails:
        return _buildAddressDetailsState(context, appState);
    }
  }

  // ── STATE 1: Choose Your Location Modal over dimmed Home background ────────
  Widget _buildInitialState(BuildContext context, AppState appState) {
    final Widget cardBody = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Choose Your Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gray900,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Enable location access to get the freshest meat delivered to your doorstep.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.gray600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppColors.brandRed,
                size: 38,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentLocationTitle = 'HSR Layout';
                _currentSubAddress = 'HSR Layout, Gowtham PG, Bengaluru, Karnataka, India';
                _previousStep = _LocationStep.initial;
                _step = _LocationStep.addressDetails;
              });
            },
            icon: const Icon(Icons.my_location_rounded, size: 18),
            label: const Text('Use Current Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _previousStep = _LocationStep.initial;
                _step = _LocationStep.selectLocation;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandRed,
              side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
              backgroundColor: const Color(0xFFFEF2F2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            child: const Text('Select Your Location'),
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      child: cardBody,
    );
  }

  // ── STATE 2: Saved Address Screen (Figma Aligned) ───────────────────────────
  Widget _buildSelectLocationState(BuildContext context, AppState appState) {
    final savedList = appState.addresses.isEmpty
        ? const [
            SavedAddress(
              label: 'HOME',
              address: 'Basaveshwara Nagar, Hebbal 1st Stage, Mysore',
              isDefault: true,
            ),
            SavedAddress(
              label: 'WORK',
              address: '3rd Floor, Tech Park, Mysore Road, Bangalore',
            ),
            SavedAddress(
              label: 'DILIP',
              address: 'Flat 203, Lakshmi Residency, Road No. 4, Banjara Hills, Bangalore',
            ),
          ]
        : appState.addresses;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
          // Top Header (Figma Aligned)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select Delivery Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gray900,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gray100,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.gray700),
                    onPressed: _goBack,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // Search an area or address input trigger
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _previousStep = _LocationStep.selectLocation;
                      _step = _LocationStep.search;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search_rounded, color: AppColors.brandRed, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Search an area or address',
                          style: TextStyle(color: AppColors.gray400, fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Use Current Location Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentLocationTitle = 'HSR Layout';
                        _currentSubAddress = 'HSR Layout, Gowtham PG, Bengaluru, Karnataka, India';
                        _previousStep = _LocationStep.selectLocation;
                        _step = _LocationStep.addressDetails;
                      });
                    },
                    icon: const Icon(Icons.my_location_rounded, size: 18),
                    label: const Text('Use current location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Saved Address Section Heading
                const Text(
                  'Saved Address',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 12),

                // Address Cards List
                ...savedList.map((addr) {
                  final isSelected = addr.isDefault || (addr.address == appState.defaultAddress);
                  final labelUpper = addr.label.toUpperCase();
                  final IconData cardIcon = labelUpper.contains('HOME')
                      ? Icons.home_rounded
                      : labelUpper.contains('WORK')
                          ? Icons.work_rounded
                          : Icons.location_on_rounded;

                  return GestureDetector(
                    onTap: () {
                      appState.setDefaultAddress(addr);
                      showAppToast(context, 'Delivery address set to ${addr.label}');
                      widget.onContinue();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFEF2F2) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.brandRed : AppColors.gray200,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: AppShadows.subtle,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppColors.gray50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cardIcon,
                              color: isSelected ? AppColors.brandRed : AppColors.gray600,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      labelUpper,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? AppColors.brandRed : AppColors.gray900,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.brandRed,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'DEFAULT',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  addr.address,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.gray600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: AppColors.brandRed, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Pinned Bottom Button: "+ Add new address"
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.gray200)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _previousStep = _LocationStep.selectLocation;
                    _step = _LocationStep.search;
                  });
                },
                icon: const Icon(Icons.add_rounded, size: 20, color: AppColors.brandRed),
                label: const Text('Add new address'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandRed,
                  side: const BorderSide(color: AppColors.brandRed, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      );
  }

  // ── STATE 3: Search Location ────────────────────────────────────────────────
  Widget _buildSearchState(BuildContext context, AppState appState) {
    final suggestions = const [
      {'title': 'HSR Layout', 'subtitle': 'Bengaluru, Karnataka, India'},
      {'title': 'Banjara Hills', 'subtitle': 'Hyderabad, Telangana, India'},
      {'title': 'Indiranagar', 'subtitle': 'Bengaluru, Karnataka, India'},
      {'title': 'Koramangala', 'subtitle': 'Bengaluru, Karnataka, India'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Top Search Bar Header with Close X
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gray300),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search_rounded, color: AppColors.brandRed, size: 20),
                        hintText: 'Search an area or address',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: AppColors.gray400, fontSize: 13.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.gray700),
                  onPressed: _goBack,
                ),
              ],
            ),
          ),

          // Use current location button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentLocationTitle = 'HSR Layout';
                    _currentSubAddress = 'HSR Layout, Gowtham PG, Bengaluru, Karnataka, India';
                    _previousStep = _LocationStep.search;
                    _step = _LocationStep.addressDetails;
                  });
                },
                icon: const Icon(Icons.my_location_rounded, size: 18),
                label: const Text('Use current location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),

          const Divider(height: 24),

          // Suggestions
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final s = suggestions[idx];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: AppColors.brandRed),
                  title: Text(s['title']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Text(s['subtitle']!, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                  onTap: () {
                    setState(() {
                      _currentLocationTitle = s['title']!;
                      _currentSubAddress = '${s['title']!}, ${s['subtitle']!}';
                      _previousStep = _LocationStep.search;
                      _step = _LocationStep.map;
                    });
                  },
                );
              },
            ),
          ),
        ],
      );
  }

  // ── STATE 4: Map Location Selection ─────────────────────────────────────────
  Widget _buildMapState(BuildContext context, AppState appState) {
    return Stack(
      children: [
        // Real interactive map picker taking top area (~50% height)
        Positioned.fill(
          child: AppMapWidget(
            mode: AppMapMode.picker,
            center: _selectedLatLng,
            zoom: 15.5,
            onPositionChanged: (newCenter, hasGesture) {
              if (hasGesture) {
                _selectedLatLng = newCenter;
              }
            },
          ),
        ),

        // Floating "Current location" pill button on map
        Positioned(
          bottom: 210,
          right: 20,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedLatLng = MockLocationData.customerLocation;
                _currentLocationTitle = 'HSR Layout';
                _currentSubAddress = 'HSR Layout, Gowtham PG, Bengaluru, Karnataka, India';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.my_location_rounded, color: AppColors.brandRed, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Current location',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.gray800),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Top Floating Search Bar with Back Button
        Positioned(
          top: 50,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.gray700),
                  onPressed: _goBack,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _searchCtrl.text.isNotEmpty ? _searchCtrl.text : 'Search an area or address',
                    style: const TextStyle(color: AppColors.gray500, fontSize: 13.5),
                  ),
                ),
                const Icon(Icons.search_rounded, color: AppColors.gray400, size: 20),
              ],
            ),
          ),
        ),

        // Bottom Address Confirmation Card
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 12),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle text
                const Text(
                  'Place the pin at exact delivery location',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.gray500),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.brandRed, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentLocationTitle,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.gray900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currentSubAddress,
                            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _stepBeforeMapPreview = null;
                        _previousStep = _LocationStep.map;
                        _step = _LocationStep.addressDetails;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Confirm & proceed'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── STATES 5, 6, 7 & 8: Address Details / Save As Selection (Fixed Header + Scrollable Form) ─
  Widget _buildAddressDetailsState(BuildContext context, AppState appState) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: [
        // Fixed Map Preview Header (160px height) - Tapping opens full Map Selection!
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 160,
          child: Container(
            color: const Color(0xFFE5E7EB),
            child: Stack(
              children: [
                AppMapWidget(
                  mode: AppMapMode.preview,
                  center: _selectedLatLng,
                  zoom: 15.0,
                  onTap: () {
                    setState(() {
                      _stepBeforeMapPreview = _LocationStep.addressDetails;
                      _step = _LocationStep.map;
                    });
                  },
                ),
                Positioned(
                  top: 44,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.gray800),
                      onPressed: _goBack,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Scrollable White Form Card pinned beneath map header (overlapping top map by 24px)
        Positioned.fill(
          top: 136,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4)),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 32 + (bottomInset > 0 ? bottomInset : 0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.brandRed, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentLocationTitle,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.gray900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _currentSubAddress,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray600,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Yellow Informational Notice
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'A detailed address will help your delivery partner reach your doorstep easily.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF92400E),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // HOUSE / FLAT / BLOCK NO.
                    const Text(
                      'HOUSE / FLAT / BLOCK NO.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _flatCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. Flat 200',
                        hintStyle: const TextStyle(color: AppColors.gray400, fontSize: 13.5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.gray300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // APARTMENT / ROAD / AREA (RECOMMENDED)
                    const Text(
                      'APARTMENT / ROAD / AREA (RECOMMENDED)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _areaCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. Lakshmi Residency, Road No. 4',
                        hintStyle: const TextStyle(color: AppColors.gray400, fontSize: 13.5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.gray300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save as options
                    const Text(
                      'Save as',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Horizontal scrolling row for save-as pills without text shrinking
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildSaveAsPill('Home', Icons.home_rounded),
                          const SizedBox(width: 8),
                          _buildSaveAsPill('Friend and Family', Icons.people_alt_rounded),
                          const SizedBox(width: 8),
                          _buildSaveAsPill('Others', Icons.location_on_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Receiver details (Shown when Friend and Family or Others is selected)
                    if (_selectedTag == 'Others' || _selectedTag == 'Friend and Family') ...[
                      const Text(
                        "Receiver's Name",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _receiverNameCtrl,
                        decoration: InputDecoration(
                          hintText: "e.g. Receiver's Name",
                          hintStyle: const TextStyle(color: AppColors.gray400, fontSize: 13.5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.gray300),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Receiver's Phone No.",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _receiverPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "e.g. 9876543210",
                          hintStyle: const TextStyle(color: AppColors.gray400, fontSize: 13.5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.gray300),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Save & proceed button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _saveAndProceed(appState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('Save & proceed'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveAsPill(String tag, IconData icon) {
    final isSelected = _selectedTag == tag;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTag = tag;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandRed : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brandRed : AppColors.gray300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.gray600,
            ),
            const SizedBox(width: 6),
            Text(
              tag,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


