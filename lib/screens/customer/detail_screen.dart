import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'widgets/product_cards.dart';

class CustDetailScreen extends StatefulWidget {
  final String productId;
  final void Function(String screen, {String? param}) nav;
  const CustDetailScreen({
    super.key,
    required this.productId,
    required this.nav,
  });

  @override
  State<CustDetailScreen> createState() => _CustDetailScreenState();
}

class _CustDetailScreenState extends State<CustDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _descExpanded = false;

  @override
  void didUpdateWidget(CustDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      setState(() {
        _descExpanded = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToTop();
      });
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = kAllProducts.firstWhere(
      (x) => x.id == widget.productId,
      orElse: () => kProducts['chicken']![0],
    );
    final related = (kProducts[p.category] ?? kProducts['chicken']!)
        .where((x) => x.id != p.id)
        .take(4)
        .toList();
    final appState = context.watch<AppState>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktopOrTablet = constraints.maxWidth >= 768;

        if (isDesktopOrTablet) {
          return _buildDesktopLayout(context, p, related, appState, constraints.maxWidth);
        }

        return _buildMobileLayout(context, p, related, appState);
      },
    );
  }

  // ─── MOBILE LAYOUT (< 768px) ────────────────────────────────────────────────
  Widget _buildMobileLayout(
      BuildContext context, Product p, List<Product> related, AppState appState) {
    return Stack(
      children: [
        ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 0, bottom: 96),
          children: [
            // Hero Image Tile
            _ProductHeroTile(
              product: p,
              onBack: () => widget.nav('back'),
              onWishlist: () => showAppToast(context, 'Added to wishlist! ❤️'),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(children: p.tags.map((t) => TagBadge(label: t)).toList()),
                  const SizedBox(height: 8),
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gray900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p.sub,
                    style: const TextStyle(
                      color: AppColors.gray600,
                      fontSize: 13.5,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _MetaItem(icon: '⏱️', label: 'Age', val: p.age)),
                        _vDivider(),
                        Expanded(child: _MetaItem(icon: '👥', label: 'Serves', val: p.serves)),
                        _vDivider(),
                        Expanded(child: _MetaItem(icon: '⚖️', label: 'Weight', val: p.weight)),
                        _vDivider(),
                        Expanded(child: _MetaItem(icon: '🐓', label: 'Gender', val: p.gender)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${p.price}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gray900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '₹${p.mrp}',
                                style: const TextStyle(
                                  color: AppColors.gray400,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Save ₹${p.mrp - p.price}',
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      appState.getProductQuantity(p.id) > 0
                          ? Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                border: Border.all(color: AppColors.brandRed, width: 1.5),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => appState.decrementProductQuantity(p.id),
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      child: Icon(Icons.remove, size: 18, color: AppColors.brandRed),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '${appState.getProductQuantity(p.id)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.brandRed,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => appState.incrementProductQuantity(p),
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      child: Icon(Icons.add, size: 18, color: AppColors.brandRed),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                appState.addToCart(p);
                                showAppToast(context, '${p.name} added to cart! 🛒');
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              ),
                              child: const Text('Add to Cart +'),
                            ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => setState(() => _descExpanded = !_descExpanded),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About this Product',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedCrossFade(
                          firstChild: Text(
                            p.desc,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.gray700,
                              height: 1.6,
                              fontSize: 14,
                            ),
                          ),
                          secondChild: Text(
                            p.desc,
                            style: const TextStyle(
                              color: AppColors.gray700,
                              height: 1.6,
                              fontSize: 14,
                            ),
                          ),
                          crossFadeState: _descExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 250),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _descExpanded ? 'Show less ↑' : 'Read more ↓',
                          style: const TextStyle(
                            color: AppColors.brandRed,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🌿 Health Benefits',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...p.benefits.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  b,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.gray700,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Row(
                      children: [
                        Text('🚚', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Free Delivery',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              Text('Order before midnight, get by 6AM–9AM tomorrow',
                                  style: TextStyle(color: AppColors.gray600, fontSize: 11.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('You May Also Like',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: related.map((r) => ProductCardHorizontal(
                  p: r,
                  onTap: () => widget.nav('detail', param: r.id),
                  onAdd: () {
                    appState.addToCart(r);
                    showAppToast(context, 'Added to cart! 🛒');
                  },
                )).toList(),
              ),
            ),
          ],
        ),
        if (appState.cartCount > 0)
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: GestureDetector(
              onTap: () => widget.nav('cart'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  gradient: AppGradients.brandRed,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${appState.cartCount} item${appState.cartCount != 1 ? 's' : ''} · ₹${appState.cartTotal}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const Row(children: [
                      Text('View Cart',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                    ]),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ─── DESKTOP & TABLET LAYOUT (>= 768px) ────────────────────────────────────
  Widget _buildDesktopLayout(
      BuildContext context, Product p, List<Product> related, AppState appState, double availableWidth) {
    final bool isWideDesktop = availableWidth >= 1024;
    final double imageSize = isWideDesktop ? 480.0 : 380.0;

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        // ── TOP 2-COLUMN SECTION: Image Panel (Left) + Product Info (Right) ─
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── LEFT: Constrained Image Container ──────────────────────────
            SizedBox(
              width: imageSize,
              height: imageSize,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.card,
                  border: Border.all(color: AppColors.gray200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          p.img,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: _CircleBtn(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => widget.nav('back'),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _CircleBtn(
                          icon: Icons.favorite_border_rounded,
                          onTap: () => showAppToast(context, 'Added to wishlist! ❤️'),
                        ),
                      ),
                      if (p.discount > 0)
                        Positioned(
                          top: 20,
                          left: 64,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                              boxShadow: AppShadows.subtle,
                            ),
                            child: Text(
                              '${p.discount}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 32),

            // ── RIGHT: Product Info & Purchase Panel ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: p.tags.map((t) => TagBadge(label: t)).toList(),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gray900,
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    p.sub,
                    style: const TextStyle(
                      color: AppColors.gray600,
                      fontSize: 15,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Meta Grid (Age, Serves, Weight, Gender)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _MetaItem(icon: '⏱️', label: 'Age', val: p.age)),
                        _vDivider(),
                        Expanded(child: _MetaItem(icon: '👥', label: 'Serves', val: p.serves)),
                        _vDivider(),
                        Expanded(child: _MetaItem(icon: '⚖️', label: 'Weight', val: p.weight)),
                        _vDivider(),
                        Expanded(child: _MetaItem(icon: '🐓', label: 'Gender', val: p.gender)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Price & Add to Cart Block
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.brandRedBg.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '₹${p.price}',
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.brandRed,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '₹${p.mrp}',
                                  style: const TextStyle(
                                    color: AppColors.gray400,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                'Save ₹${p.mrp - p.price} (${p.discount}% discount)',
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        appState.getProductQuantity(p.id) > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  border: Border.all(color: AppColors.brandRed, width: 1.5),
                                  borderRadius: BorderRadius.circular(AppRadius.base),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => appState.decrementProductQuantity(p.id),
                                      borderRadius: BorderRadius.circular(AppRadius.base),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        child: Icon(Icons.remove, size: 20, color: AppColors.brandRed),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        '${appState.getProductQuantity(p.id)} in Cart',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.brandRed,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => appState.incrementProductQuantity(p),
                                      borderRadius: BorderRadius.circular(AppRadius.base),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        child: Icon(Icons.add, size: 20, color: AppColors.brandRed),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () {
                                  appState.addToCart(p);
                                  showAppToast(context, '${p.name} added to cart! 🛒');
                                },
                                icon: const Icon(Icons.shopping_cart_rounded, size: 18),
                                label: const Text('Add to Cart 🛒', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.base),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Row(
                    children: [
                      Icon(Icons.bolt_rounded, size: 18, color: AppColors.warning),
                      SizedBox(width: 6),
                      Text(
                        'Express Dawn Delivery · Fresh Farm-Cut Guaranteed',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 36),
        const Divider(color: AppColors.gray200, height: 1),
        const SizedBox(height: 28),

        // ── BOTTOM SECTIONS: About, Health Benefits, Delivery, Recommended ─
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // About This Product
              GestureDetector(
                onTap: () => setState(() => _descExpanded = !_descExpanded),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About this Product',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedCrossFade(
                      firstChild: Text(
                        p.desc,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.gray700,
                          height: 1.65,
                          fontSize: 14.5,
                        ),
                      ),
                      secondChild: Text(
                        p.desc,
                        style: const TextStyle(
                          color: AppColors.gray700,
                          height: 1.65,
                          fontSize: 14.5,
                        ),
                      ),
                      crossFadeState: _descExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _descExpanded ? 'Show less ↑' : 'Read more ↓',
                      style: const TextStyle(
                        color: AppColors.brandRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Health Benefits Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.successLight.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🌿 Health Benefits',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...p.benefits.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              b,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.gray800,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Free Delivery Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Row(
                  children: [
                    Text('🚚', style: TextStyle(fontSize: 26)),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Free Dawn Delivery Guaranteed',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('Order before 11 PM to get fresh farm cuts delivered by 6AM–9AM tomorrow',
                              style: TextStyle(color: AppColors.gray600, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Recommended Products Section
              const Text(
                'You May Also Like',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.gray900),
              ),
              const SizedBox(height: 14),

              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  children: related.map((r) => ProductCardHorizontal(
                    p: r,
                    onTap: () => widget.nav('detail', param: r.id),
                    onAdd: () {
                      appState.addToCart(r);
                      showAppToast(context, '${r.name} added to cart! 🛒');
                    },
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vDivider() => Container(width: 1, height: 32, color: AppColors.gray200, margin: const EdgeInsets.symmetric(horizontal: 6));
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.subtle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: AppColors.gray700),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String icon, label, val;
  const _MetaItem({required this.icon, required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
          Text(val,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ProductHeroTile extends StatelessWidget {
  final Product product;
  final VoidCallback onBack;
  final VoidCallback onWishlist;

  const _ProductHeroTile({
    required this.product,
    required this.onBack,
    required this.onWishlist,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final overlayTop = topInset > 0 ? topInset + 8 : 16.0;

    return Stack(
      children: [
        // ── Fixed Responsive Hero AspectRatio Viewport ─────────────────────
        AspectRatio(
          aspectRatio: 1.5,
          child: SizedBox(
            width: double.infinity,
            child: ClipRect(
              child: Image.asset(
                product.img,
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        // ── Overlay Controls ────────────────────────────────────────────────
        Positioned(
          top: overlayTop,
          left: 12,
          child: _CircleBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
        ),
        Positioned(
          top: overlayTop,
          right: 12,
          child: _CircleBtn(
            icon: Icons.favorite_border_rounded,
            onTap: onWishlist,
          ),
        ),
        if (product.discount > 0)
          Positioned(
            top: overlayTop + 4,
            left: 56,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '${product.discount}% OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
