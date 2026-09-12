import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'widgets/product_cards.dart';

// ─── CATEGORY MODEL HELPER ───────────────────────────────────────────────────
class _CategoryData {
  final String id;
  final String title;
  final String desc;
  final String img;
  final String itemCount;
  final String priceStart;
  final String badge;
  final List<String> popularCuts;
  final Color themeColor;

  const _CategoryData({
    required this.id,
    required this.title,
    required this.desc,
    required this.img,
    required this.itemCount,
    required this.priceStart,
    required this.badge,
    required this.popularCuts,
    required this.themeColor,
  });
}

// ─── CATEGORIES SCREEN ────────────────────────────────────────────────────────
class CustCategoriesScreen extends StatefulWidget {
  final void Function(String screen, {String? param}) nav;
  const CustCategoriesScreen({super.key, required this.nav});

  @override
  State<CustCategoriesScreen> createState() => _CustCategoriesScreenState();
}

class _CustCategoriesScreenState extends State<CustCategoriesScreen> {
  String _selectedTab = 'All';

  static const List<_CategoryData> _allCategories = [
    _CategoryData(
      id: 'chicken',
      title: 'Country Chicken',
      desc: 'Organically raised in open village farms. 100% natural & chemical-free.',
      img: 'assets/images/cat_chicken.jpg',
      itemCount: '12 Cuts Available',
      priceStart: '₹190',
      badge: '100% FREE-RANGE',
      popularCuts: ['Curry Cut', 'Boneless', 'Drumsticks', 'Rooster', 'Hen'],
      themeColor: AppColors.brandRed,
    ),
    _CategoryData(
      id: 'mutton',
      title: 'Country Mutton',
      desc: 'Fresh, tender goat meat cut directly from pasture-fed livestock.',
      img: 'assets/images/cat_mutton.jpg',
      itemCount: '6 Cuts Available',
      priceStart: '₹490',
      badge: 'PASTURE-FED',
      popularCuts: ['Curry Cut', 'Biryani Cut', 'Mutton Chops', 'Ribs'],
      themeColor: Color(0xFF8B4513),
    ),
    _CategoryData(
      id: 'eggs',
      title: 'Country & Organic Eggs',
      desc: 'Nutrient-rich desi & Kadaknath eggs collected daily from free-roaming hens.',
      img: 'assets/images/country_eggs_real.jpg',
      itemCount: '4 Packs Available',
      priceStart: '₹95',
      badge: 'ZERO ANTIBIOTICS',
      popularCuts: ['Desi Eggs', 'Kadaknath Eggs', 'Pack of 6', 'Pack of 30'],
      themeColor: Color(0xFFD97706),
    ),
    _CategoryData(
      id: 'seafood',
      title: 'Sea & Freshwater Catch',
      desc: 'Sustainably caught fresh fish & prawns cleaned & ready for kitchen.',
      img: 'assets/images/freshwater_fish.jpg',
      itemCount: '8 Catch Available',
      priceStart: '₹260',
      badge: 'DAWN FRESH',
      popularCuts: ['Fish Steaks', 'Jumbo Prawns', 'River Catch', 'Seer Fish'],
      themeColor: Color(0xFF0284C7),
    ),
  ];

  List<_CategoryData> get _filteredCats {
    if (_selectedTab == 'All') return _allCategories;
    if (_selectedTab == 'Poultry') {
      return _allCategories.where((c) => c.id == 'chicken' || c.id == 'eggs').toList();
    }
    if (_selectedTab == 'Red Meat') {
      return _allCategories.where((c) => c.id == 'mutton').toList();
    }
    if (_selectedTab == 'Seafood') {
      return _allCategories.where((c) => c.id == 'seafood').toList();
    }
    return _allCategories;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 768;

            return Column(
              children: [
                // ── Top Bar Header ──────────────────────────────────────────────
                Container(
                  padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 16, 12, isDesktop ? 24 : 16, 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: AppShadows.subtle,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: AppColors.gray100,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => widget.nav('back'),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 16, color: AppColors.gray800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Explore Categories',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.gray900,
                              ),
                            ),
                            Text(
                              'Farm-fresh meats & organic eggs',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.gray500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => widget.nav('search'),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.brandRedBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.search_rounded,
                              size: 18, color: AppColors.brandRed),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Interactive Category Quick Tabs ───────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
                      children: [
                        'All',
                        'Poultry',
                        'Red Meat',
                        'Seafood',
                      ].map((tab) {
                        final isSelected = _selectedTab == tab;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTab = tab),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.brandRed
                                  : AppColors.gray100,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color:
                                            AppColors.brandRed.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight:
                                    isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.gray700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.gray200),

                // ── Main Category Content (Desktop 2-Column Grid vs Mobile List) ──
                Expanded(
                  child: isDesktop
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.45,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: _filteredCats.length,
                          itemBuilder: (ctx, i) {
                            final cat = _filteredCats[i];
                            return _CategoryDesktopCard(
                              data: cat,
                              onTap: () => widget.nav('listing', param: cat.id),
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                          itemCount: _filteredCats.length,
                          itemBuilder: (ctx, i) {
                            final cat = _filteredCats[i];
                            return _CategoryHeroCard(
                              data: cat,
                              onTap: () => widget.nav('listing', param: cat.id),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── E-COMMERCE DESKTOP CATEGORY CARD ─────────────────────────────────────────
class _CategoryDesktopCard extends StatelessWidget {
  final _CategoryData data;
  final VoidCallback onTap;

  const _CategoryDesktopCard({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200, width: 1),
        boxShadow: AppShadows.subtle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Image Area
                Expanded(
                  flex: 55,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        data.img,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.gray200,
                          child: const Icon(Icons.kebab_dining,
                              size: 48, color: AppColors.gray400),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: data.themeColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            data.badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            data.itemCount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Content Area
                Expanded(
                  flex: 45,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.gray900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.desc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.gray600,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Starts from ',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.gray500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: data.priceStart,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.brandRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.brandRed,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brandRed.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: const [
                                  Text(
                                    'Explore Category',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

// ─── RICH CATEGORY HERO CARD WIDGET ──────────────────────────────────────────
class _CategoryHeroCard extends StatelessWidget {
  final _CategoryData data;
  final VoidCallback onTap;

  const _CategoryHeroCard({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Background Image
                SizedBox(
                  height: 210,
                  width: double.infinity,
                  child: Image.asset(
                    data.img,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.gray200,
                      child: const Icon(Icons.kebab_dining,
                          size: 48, color: AppColors.gray400),
                    ),
                  ),
                ),

                // Multi-stop Gradient Overlay for Crystal Clear Contrast
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.65),
                          Colors.black.withValues(alpha: 0.92),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Top Badge Tag & Item Count
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: data.themeColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          data.badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          data.itemCount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Content Details
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Popular Cuts Chips Wrap
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: data.popularCuts.take(4).map((cut) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            child: Text(
                              cut,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      // Action Row: Price Tag & Explore Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Starting ',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                data.priceStart,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.brandRed,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.brandRed.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  'Explore Category',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded,
                                    size: 14, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
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

// ─── LISTING SCREEN ───────────────────────────────────────────────────────────
class CustListingScreen extends StatefulWidget {
  final String category;
  final void Function(String screen, {String? param}) nav;
  const CustListingScreen(
      {super.key, required this.category, required this.nav});

  @override
  State<CustListingScreen> createState() => _CustListingScreenState();
}

class _CustListingScreenState extends State<CustListingScreen> {
  String _sortBy = 'popular';
  String? _genderFilter;

  @override
  Widget build(BuildContext context) {
    final items = kProducts[widget.category] ?? kProducts['chicken']!;
    final catNames = {
      'chicken': 'Country Chicken',
      'mutton': 'Country Mutton',
      'eggs': 'Country Eggs',
      'seafood': 'Sea & Freshwater Catch',
    };
    final catName = catNames[widget.category] ?? 'Products';
    final appState = context.watch<AppState>();

    // Apply sort
    final sorted = List.of(items);
    if (_sortBy == 'price_asc') {
      sorted.sort((a, b) => a.price.compareTo(b.price));
    }
    if (_sortBy == 'price_desc') {
      sorted.sort((a, b) => b.price.compareTo(a.price));
    }

    // Apply gender filter
    final filtered = _genderFilter == null
        ? sorted
        : sorted
            .where((p) => p.gender == _genderFilter || p.gender == 'Both')
            .toList();

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 768;
            final double width = constraints.maxWidth;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Navigation Header ─────────────────────────────────────────────
                Container(
                  padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 12, 10, isDesktop ? 24 : 16, 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: AppShadows.subtle,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => widget.nav('back'),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: AppColors.gray800),
                      ),
                      Expanded(
                        child: Text(
                          catName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => widget.nav('search'),
                        icon: const Icon(Icons.search_rounded,
                            size: 22, color: AppColors.gray700),
                      ),
                    ],
                  ),
                ),

                // ── Sort & Filter Pills Bar ───────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
                      children: [
                        _FilterChip(
                          label: 'Popular',
                          selected: _sortBy == 'popular',
                          onTap: () => setState(() => _sortBy = 'popular'),
                        ),
                        _FilterChip(
                          label: 'Price: Low to High',
                          selected: _sortBy == 'price_asc',
                          onTap: () => setState(() => _sortBy = 'price_asc'),
                        ),
                        _FilterChip(
                          label: 'Price: High to Low',
                          selected: _sortBy == 'price_desc',
                          onTap: () => setState(() => _sortBy = 'price_desc'),
                        ),
                        if (widget.category == 'chicken') ...[
                          _FilterChip(
                            label: 'Rooster Cut',
                            selected: _genderFilter == 'Rooster',
                            onTap: () => setState(() => _genderFilter =
                                _genderFilter == 'Rooster' ? null : 'Rooster'),
                          ),
                          _FilterChip(
                            label: 'Hen Cut',
                            selected: _genderFilter == 'Hen',
                            onTap: () => setState(() => _genderFilter =
                                _genderFilter == 'Hen' ? null : 'Hen'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.gray200),

                // ── Product Count & List/Grid ────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 16, 12, isDesktop ? 24 : 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${filtered.length} Fresh Cuts Available',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: isDesktop
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: width >= 1600 ? 5 : (width >= 1100 ? 4 : 3),
                            childAspectRatio: width >= 1400 ? 0.78 : (width >= 1100 ? 0.74 : 0.71),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => ProductCardGrid(
                            p: filtered[i],
                            onTap: () => widget.nav('detail', param: filtered[i].id),
                            onAdd: () {
                              appState.addToCart(filtered[i]);
                              showAppToast(
                                  context, '${filtered[i].name} added to cart! 🛒');
                            },
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => ProductCardVertical(
                            p: filtered[i],
                            onTap: () => widget.nav('detail', param: filtered[i].id),
                            onAdd: () {
                              appState.addToCart(filtered[i]);
                              showAppToast(
                                  context, '${filtered[i].name} added to cart! 🛒');
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── FILTER CHIP ─────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandRed : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? Colors.white : AppColors.gray700,
          ),
        ),
      ),
    );
  }
}
