import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─── COLOR TOKENS ────────────────────────────────────────────────────────────
class AppColors {
  // Brand
  static const brandRed = Color(0xFFC0392B);
  static const brandRedLight = Color(0xFFE74C3C);
  static const brandRedDark = Color(0xFF96281B);
  static const brandRedBg = Color(0xFFFFF5F5);
  static const brandRedBg2 = Color(0xFFFDF3F1);

  // Neutral
  static const white = Color(0xFFFFFFFF);
  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);
  static const gray900 = Color(0xFF111827);

  // Semantic
  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFDCFCE7);
  static const warning = Color(0xFFD97706);
  static const warningLight = Color(0xFFFEF3C7);
  static const info = Color(0xFF0EA5E9);
  static const infoLight = Color(0xFFE0F2FE);
  static const error = Color(0xFFDC2626);
  static const errorLight = Color(0xFFFEE2E2);

  // Tag colors
  static const tagNatural = Color(0xFF065F46);
  static const tagNaturalBg = Color(0xFFD1FAE5);
  static const tagFreerange = Color(0xFF92400E);
  static const tagFreerangeBg = Color(0xFFFDE68A);
  static const tagAntibiotic = Color(0xFF1E40AF);
  static const tagAntibioticBg = Color(0xFFDBEAFE);
  static const tagOrganic = Color(0xFF166534);
  static const tagOrganicBg = Color(0xFFBBF7D0);
  static const tagNutritious = Color(0xFF7C3AED);
  static const tagNutritiousBg = Color(0xFFEDE9FE);
}

/// ─── GRADIENTS ───────────────────────────────────────────────────────────────
class AppGradients {
  static const brandRed = LinearGradient(
    colors: [AppColors.brandRed, AppColors.brandRedDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const brandRedVertical = LinearGradient(
    colors: [AppColors.brandRedLight, AppColors.brandRedDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const heroOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const cardOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xDD000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// ─── RADIUS ──────────────────────────────────────────────────────────────────
class AppRadius {
  static const sm = 6.0;
  static const base = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const full = 999.0;
}

/// ─── SHADOWS ─────────────────────────────────────────────────────────────────
class AppShadows {
  static const card = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const elevated = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
  static const subtle = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
  ];
}

/// ─── THEME ───────────────────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  final textTheme = GoogleFonts.interTextTheme();
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brandRed,
      primary: AppColors.brandRed,
      surface: AppColors.white,
    ),
    textTheme: textTheme,
    fontFamily: GoogleFonts.inter().fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.gray900,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.base),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brandRed,
        side: const BorderSide(color: AppColors.brandRed, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.base),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.base),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.base),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.base),
        borderSide: const BorderSide(color: AppColors.brandRed, width: 1.5),
      ),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.brandRed,
      unselectedItemColor: AppColors.gray400,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.gray100,
      selectedColor: AppColors.brandRedBg,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.gray100, thickness: 1),
  );
}

/// ─── TAG BADGE ───────────────────────────────────────────────────────────────
class TagBadge extends StatelessWidget {
  final String label;
  const TagBadge({super.key, required this.label});

  static const Map<String, List<Color>> _map = {
    'Naturally-Hatched': [AppColors.tagNatural, AppColors.tagNaturalBg],
    'Free-Range': [AppColors.tagFreerange, AppColors.tagFreerangeBg],
    'Antibiotic-Free': [AppColors.tagAntibiotic, AppColors.tagAntibioticBg],
    'Organic': [AppColors.tagOrganic, AppColors.tagOrganicBg],
    'Rare Breed': [AppColors.tagNutritious, AppColors.tagNutritiousBg],
    'Wild Caught': [AppColors.tagOrganic, AppColors.tagOrganicBg],
    'Natural': [AppColors.tagNatural, AppColors.tagNaturalBg],
    'Tender': [AppColors.tagFreerange, AppColors.tagFreerangeBg],
  };

  @override
  Widget build(BuildContext context) {
    final colors = _map[label] ?? [AppColors.tagNatural, AppColors.tagNaturalBg];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      decoration: BoxDecoration(
        color: colors[1],
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors[0],
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// ─── TOAST ───────────────────────────────────────────────────────────────────
void showAppToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.gray900,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 2000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    ),
  );
}

/// ─── RESPONSIVE BREAKPOINTS ───────────────────────────────────────────────────
class AppBreakpoints {
  static const double mobileMax = 767.0;
  static const double tabletMin = 768.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;
  static const double maxContentWidth = 1320.0;
  static const double maxTabletContentWidth = 880.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tabletMin;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= tabletMin && w < desktopMin;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopMin;
}

