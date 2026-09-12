import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product.dart';
import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';

// ─── HORIZONTAL CARD (used in Home carousels) ─────────────────────────────────
class ProductCardHorizontal extends StatelessWidget {
  final Product p;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  const ProductCardHorizontal({
    super.key,
    required this.p,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final int qty = appState.getProductQuantity(p.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
              child: Stack(
                children: [
                  Image.asset(p.img, height: 115, width: 155, fit: BoxFit.cover),
                  if (p.discount > 0)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text('${p.discount}% OFF',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  Text(p.weight,
                      style: const TextStyle(color: AppColors.gray400, fontSize: 11)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('₹${p.price}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text('₹${p.mrp}',
                            style: const TextStyle(
                                color: AppColors.gray400,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 10)),
                      ]),
                      qty > 0
                          ? Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                border: Border.all(color: AppColors.brandRed, width: 1.2),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () => appState.decrementProductQuantity(p.id),
                                    borderRadius: BorderRadius.circular(AppRadius.full),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.remove, size: 14, color: AppColors.brandRed),
                                    ),
                                  ),
                                  Text(
                                    '$qty',
                                    style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.brandRed),
                                  ),
                                  InkWell(
                                    onTap: () => appState.incrementProductQuantity(p),
                                    borderRadius: BorderRadius.circular(AppRadius.full),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.add, size: 14, color: AppColors.brandRed),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: onAdd,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                    color: AppColors.brandRed, shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
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
    );
  }
}

// ─── GRID / DESKTOP CARD (used in Desktop Best Sellers & Grid views) ─────────
class ProductCardGrid extends StatelessWidget {
  final Product p;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const ProductCardGrid({
    super.key,
    required this.p,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final int qty = appState.getProductQuantity(p.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.gray200, width: 1),
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
              child: AspectRatio(
                aspectRatio: 1.35,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        p.img,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (p.discount > 0)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${p.discount}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Card Body Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p.weight,
                          style: const TextStyle(
                            color: AppColors.gray500,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Price + Add Control Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
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
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: AppColors.gray900,
                                  ),
                                ),
                                if (p.mrp > p.price) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '₹${p.mrp}',
                                    style: const TextStyle(
                                      color: AppColors.gray400,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        qty > 0
                            ? Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  border: Border.all(color: AppColors.brandRed, width: 1.5),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () => appState.decrementProductQuantity(p.id),
                                      borderRadius: BorderRadius.circular(AppRadius.full),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                        child: Icon(Icons.remove, size: 14, color: AppColors.brandRed),
                                      ),
                                    ),
                                    Text(
                                      '$qty',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.brandRed,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => appState.incrementProductQuantity(p),
                                      borderRadius: BorderRadius.circular(AppRadius.full),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                        child: Icon(Icons.add, size: 14, color: AppColors.brandRed),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ElevatedButton(
                                onPressed: onAdd,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandRed,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  '+ ADD',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
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
    );
  }
}

// ─── VERTICAL CARD (used in Listing screen) ───────────────────────────────────
class ProductCardVertical extends StatelessWidget {
  final Product p;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  const ProductCardVertical({
    super.key,
    required this.p,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final int qty = appState.getProductQuantity(p.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.subtle,
          border: Border.all(color: AppColors.gray100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.base),
              child: Stack(
                children: [
                  Image.asset(p.img, height: 90, width: 90, fit: BoxFit.cover),
                  if (p.discount > 0)
                    Positioned(
                      top: 5, left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text('${p.discount}%',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(p.sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.gray400, fontSize: 11)),
                  const SizedBox(height: 4),
                  Wrap(
                    children: p.tags.take(2).map((t) => TagBadge(label: t)).toList(),
                  ),
                  const SizedBox(height: 4),
                  Text('⏱ ${p.age} · 👥 ${p.serves} · ⚖ ${p.weight}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5, color: AppColors.gray400)),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Flexible(
                      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('₹${p.price}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text('₹${p.mrp}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.gray400,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 11)),
                        ),
                      ]),
                    ),
                    const SizedBox(width: 4),
                    qty > 0
                        ? Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              border: Border.all(color: AppColors.brandRed, width: 1.2),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => appState.decrementProductQuantity(p.id),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Icon(Icons.remove, size: 14, color: AppColors.brandRed),
                                  ),
                                ),
                                Text(
                                  '$qty',
                                  style: const TextStyle(
                                      fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.brandRed),
                                ),
                                InkWell(
                                  onTap: () => appState.incrementProductQuantity(p),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Icon(Icons.add, size: 14, color: AppColors.brandRed),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            onPressed: onAdd,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            child: const Text('+ Add'),
                          ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


