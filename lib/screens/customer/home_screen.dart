import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../data/mock_data.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'widgets/product_cards.dart';

class CustHomeScreen extends StatefulWidget {
  final void Function(String screen, {String? param}) nav;
  const CustHomeScreen({super.key, required this.nav});

  @override
  State<CustHomeScreen> createState() => _CustHomeScreenState();
}

class _CustHomeScreenState extends State<CustHomeScreen> {
  final _bannerCtrl = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  static const _banners = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  static const _bannerCaptions = [
    'From Open Farms to Your Home — The Way Nature Intended',
    'Kadaknath & Rare Breeds — Delivered at Dawn',
    'Order Tonight. Fresh Meat by 6AM.',
  ];

  static const _whyChooseUsImages = [
    'assets/images/whyCooseUs/ogCountry.png',
    'assets/images/whyCooseUs/free-range.png',
    'assets/images/whyCooseUs/natualfeed.png',
    'assets/images/whyCooseUs/antiboitic.png',
    'assets/images/whyCooseUs/naturally.png',
    'assets/images/whyCooseUs/farmers.png',
    'assets/images/whyCooseUs/delivery.png',
  ];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (!_bannerCtrl.hasClients) return;
      final next = (_bannerIndex + 1) % _banners.length;
      _bannerCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final bestSellers = kProducts['chicken']!.take(4).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktopOrTablet = constraints.maxWidth >= 768;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            if (!isDesktopOrTablet) ...[
              // ── Mobile Top Bar ─────────────────────────────────────────────
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showLocationPickerModal(context, appState, widget.nav),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Delivering to',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.gray400,
                                    fontWeight: FontWeight.w500)),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 14, color: AppColors.brandRed),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    appState.defaultAddress.split(',').first,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800, fontSize: 14),
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded,
                                    size: 18, color: AppColors.gray400),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final openSlot = AppState.getCurrentlyOpenSlot();
                        final isOpen = openSlot != null;
                        final now = DateTime.now();
                        final currentMinutes = now.hour * 60 + now.minute;
                        final String slotTimeText;
                        if (isOpen) {
                          slotTimeText = 'Today $openSlot';
                        } else if (currentMinutes < 6 * 60) {
                          slotTimeText = 'Today 6AM–9AM';
                        } else {
                          slotTimeText = 'Tomorrow 6AM–9AM';
                        }

                        final String statusText = isOpen
                            ? 'Slot Open'
                            : (currentMinutes < 6 * 60 ? 'Opens 6 AM' : 'Slots Closed');

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              slotTimeText,
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.gray400),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: isOpen
                                      ? AppColors.success
                                      : AppColors.gray400,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isOpen
                                        ? AppColors.success
                                        : AppColors.gray500,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ── Mobile Search Bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: GestureDetector(
                  onTap: () => widget.nav('search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search_rounded,
                            size: 20, color: AppColors.brandRed),
                        SizedBox(width: 10),
                        Text('Search for meats and products...',
                            style: TextStyle(
                                color: AppColors.gray500,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
            ],

            // ── Banner & Category Layout ─────────────────────────────────────────
            LayoutBuilder(
              builder: (context, innerConstraints) {
            final isDesktopOrTablet = constraints.maxWidth >= 768;

            final categories = [
              _CatCard(
                  img: 'assets/images/cat_chicken.jpg',
                  label: 'Country Chicken',
                  itemCount: '12 Items',
                  tag: 'Fresh',
                  onTap: () => widget.nav('listing', param: 'chicken')),
              _CatCard(
                  img: 'assets/images/cat_mutton.jpg',
                  label: 'Country Mutton',
                  itemCount: '6 Items',
                  tag: 'Tender',
                  onTap: () => widget.nav('listing', param: 'mutton')),
              _CatCard(
                  img: 'assets/images/country_eggs_real.jpg',
                  label: 'Country Eggs',
                  itemCount: '4 Items',
                  tag: 'Organic',
                  onTap: () => widget.nav('listing', param: 'eggs')),
              _CatCard(
                  img: 'assets/images/sea_food_real.jpg',
                  label: 'Sea Food',
                  itemCount: '8 Items',
                  tag: 'Catch',
                  onTap: () => widget.nav('listing', param: 'seafood')),
              _CatCard(
                  img: 'assets/images/k1.jpg',
                  label: 'Kadaknath',
                  itemCount: '3 Items',
                  tag: 'Rare',
                  onTap: () => widget.nav('search', param: 'Kadaknath')),
            ];

            Widget bannerWidget(double horizontalPadding) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.card,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    clipBehavior: Clip.antiAlias,
                    child: AspectRatio(
                      aspectRatio: 3.1,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _bannerCtrl,
                            itemCount: _banners.length,
                            onPageChanged: (i) => setState(() => _bannerIndex = i),
                            itemBuilder: (_, i) => Image.asset(
                              _banners[i],
                              fit: BoxFit.fill,
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: AnimatedSmoothIndicator(
                                activeIndex: _bannerIndex,
                                count: _banners.length,
                                effect: const WormEffect(
                                  dotHeight: 5,
                                  dotWidth: 5,
                                  activeDotColor: Colors.white,
                                  dotColor: Colors.white38,
                                ),
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

            if (isDesktopOrTablet) {
              return Column(
                children: [
                  // ── 1. Independent Hero Banner ──────────────────────────────────
                  bannerWidget(24),

                  const SizedBox(height: 24),

                  // ── 2. Shop By Category Heading (ABOVE category circles) ────────
                  _SectionHeader(
                    title: 'Shop By Category',
                    onSeeAll: () => widget.nav('categories'),
                  ),

                  const SizedBox(height: 12),

                  // ── 3. Centered Category Row (underneath heading row) ────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: categories,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              );
            }

            return Column(
              children: [
                bannerWidget(16),
                _SectionHeader(
                  title: 'Shop By Category',
                  onSeeAll: () => widget.nav('categories'),
                ),
                SizedBox(
                  height: 125,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: categories,
                  ),
                ),
              ],
            );
          },
        ),

        // ── Special Offer Strip ───────────────────────────────────────────────
        GestureDetector(
          onTap: () => widget.nav('listing', param: 'chicken'),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1F2937), Color(0xFF374151)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.brandRed,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Text('LIMITED OFFER',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1)),
                      ),
                      const SizedBox(height: 6),
                      const Text('First Order: 10% OFF',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                      const Text('Use code: FARM10',
                          style:
                              TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                const Text('🎉', style: TextStyle(fontSize: 36)),
              ],
            ),
          ),
        ),

        // ── Best Sellers & Kadaknath Highlight ────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktopOrTablet = constraints.maxWidth >= 768;
            final double width = constraints.maxWidth;

            final Widget kadaknathBanner = GestureDetector(
              onTap: () => widget.nav('detail', param: 'kadaknath'),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.card,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/images/kadaknath.jpg', fit: BoxFit.cover),
                      Container(
                        decoration:
                            const BoxDecoration(gradient: AppGradients.heroOverlay),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.tagNutritious,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: const Text('RARE BREED',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(height: 6),
                            const Text('Kadaknath\nCountry Chicken',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17,
                                    height: 1.2)),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.brandRed,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Text('Order →',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            if (isDesktopOrTablet) {
              final int cols = width >= 1800 ? 6 : (width >= 1400 ? 5 : (width >= 1000 ? 4 : 3));
              final double ratio = width >= 1400 ? 0.78 : (width >= 1000 ? 0.74 : 0.71);

              return Column(
                children: [
                  _SectionHeader(
                    title: 'Best Sellers',
                    onSeeAll: () => widget.nav('listing', param: 'chicken'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        childAspectRatio: ratio,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: bestSellers.length,
                      itemBuilder: (ctx, i) => ProductCardGrid(
                        p: bestSellers[i],
                        onTap: () => widget.nav('detail', param: bestSellers[i].id),
                        onAdd: () {
                          appState.addToCart(bestSellers[i]);
                          showAppToast(context, '${bestSellers[i].name} added to cart! 🛒');
                        },
                      ),
                    ),
                  ),
                  // Kadaknath section is omitted on Web/Desktop so lower content moves up cleanly
                ],
              );
            }

            return Column(
              children: [
                _SectionHeader(
                  title: 'Best Sellers',
                  onSeeAll: () => widget.nav('listing', param: 'chicken'),
                ),
                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: bestSellers
                        .map((p) => ProductCardHorizontal(
                              p: p,
                              onTap: () => widget.nav('detail', param: p.id),
                              onAdd: () {
                                appState.addToCart(p);
                                showAppToast(context, '${p.name} added to cart! 🛒');
                              },
                            ))
                        .toList(),
                  ),
                ),
                kadaknathBanner,
              ],
            );
          },
        ),

        // ── Why Choose Us? ───────────────────────────────────────────────────
        const _SectionHeader(title: 'Why Choose Us?'),
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 768;
            final double horizontalPadding = isDesktop ? 24.0 : 16.0;
            final double cardWidth = isDesktop ? 250.0 : 275.0;
            final double gap = isDesktop ? 16.0 : 12.0;

            return SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                itemCount: _whyChooseUsImages.length,
                itemBuilder: (context, index) {
                  final imgPath = _whyChooseUsImages[index];
                  return Container(
                    width: cardWidth,
                    margin: EdgeInsets.only(right: index == _whyChooseUsImages.length - 1 ? 0 : gap),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.gray200, width: 1),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.asset(
                        imgPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.gray100,
                          child: const Center(
                            child: Icon(Icons.verified_user_rounded,
                                color: AppColors.brandRed, size: 32),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),



        // ── Testimonials ────────────────────────────────────────────────────
        _SectionHeader(title: 'What Customers Say'),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              _Testimonial(
                q: '"Best country chicken I\'ve had in years! The taste takes me back to my village."',
                name: 'Arjun Kumar',
                stars: 5,
              ),
              _Testimonial(
                q: '"Delivery was on time and the freshness is unmatched. Kadaknath was incredible!"',
                name: 'Priya Shetty',
                stars: 5,
              ),
              _Testimonial(
                q: '"Finally a trustworthy source for desi chicken. Will order every week!"',
                name: 'Ramesh Naik',
                stars: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  },
);
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5)),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text('See All',
                  style: TextStyle(
                      color: AppColors.brandRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

// ─── Category Card ────────────────────────────────────────────────────────────
class _CatCard extends StatelessWidget {
  final String img, label;
  final String? itemCount;
  final String? tag;
  final VoidCallback onTap;

  const _CatCard({
    required this.img,
    required this.label,
    this.itemCount,
    this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 86,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.brandRed, Color(0xFFFF8A8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandRed.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        img,
                        height: 64,
                        width: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 64,
                          height: 64,
                          color: AppColors.gray100,
                          child: const Icon(Icons.kebab_dining,
                              color: AppColors.brandRed),
                        ),
                      ),
                    ),
                  ),
                ),
                if (tag != null)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brandRed,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        tag!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppColors.gray900,
              ),
            ),
            if (itemCount != null)
              Text(
                itemCount!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Testimonial extends StatelessWidget {
  final String q, name;
  final int stars;
  const _Testimonial(
      {required this.q, required this.name, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.subtle,
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: AppColors.warning,
                size: 14,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(q,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.gray700, height: 1.4)),
          ),
          const SizedBox(height: 6),
          Text(name,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─── LOCATION PICKER MODAL ───────────────────────────────────────────────────
void _showLocationPickerModal(
    BuildContext context, AppState appState, void Function(String screen, {String? param}) nav) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (context, setModalState) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.location_on_rounded,
                        color: AppColors.brandRed, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Select Delivery Location',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gray900),
                    ),
                  ],
                ),
                IconButton(
                  icon:
                      const Icon(Icons.close_rounded, color: AppColors.gray500),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose your address for morning farm-fresh meat delivery:',
              style: TextStyle(color: AppColors.gray600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...appState.addresses.map((a) {
              final isSelected = a.isDefault;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFEF2F2) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.brandRed
                        : const Color(0xFFE5E7EB),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Text(
                    a.label == 'Home'
                        ? '🏠'
                        : (a.label == 'Work' ? '🏢' : '📍'),
                    style: const TextStyle(fontSize: 22),
                  ),
                  title: Row(
                    children: [
                      Text(
                        a.label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.brandRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'DEFAULT',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    a.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.gray600),
                  ),
                  trailing: Radio<bool>(
                    value: true,
                    groupValue: isSelected,
                    activeColor: AppColors.brandRed,
                    onChanged: (_) {
                      appState.setDefaultAddress(a);
                      Navigator.pop(ctx);
                      showAppToast(context,
                          'Delivery location updated to ${a.label}! 📍');
                    },
                  ),
                  onTap: () {
                    appState.setDefaultAddress(a);
                    Navigator.pop(ctx);
                    showAppToast(
                        context, 'Delivery location updated to ${a.label}! 📍');
                  },
                ),
              );
            }),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE5E7EB)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  nav('location', param: 'newAddress');
                },
                icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                label: const Text('Add New Address'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
