import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class CustSearchScreen extends StatefulWidget {
  final void Function(String screen, {String? param}) nav;
  final String? initialQuery;

  const CustSearchScreen({
    super.key,
    required this.nav,
    this.initialQuery,
  });

  @override
  State<CustSearchScreen> createState() => _CustSearchScreenState();
}

class _CustSearchScreenState extends State<CustSearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _query = '';
  String _selectedCategory = 'All';

  final List<String> _recentSearches = const [
    'Kadaknath',
    'Country Chicken',
    'Mutton Curry Cut',
    'Eggs',
    'Prawns',
    'Drumsticks',
  ];

  final List<String> _categories = const [
    'All',
    'Chicken',
    'Mutton',
    'Eggs',
    'Seafood',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _query = widget.initialQuery!;
      _searchCtrl.text = _query;
    }
    // Auto-focus search input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_query.isEmpty) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    return kAllProducts.where((p) {
      // Category match
      final matchCat = _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();

      if (!matchCat) return false;

      // Text query match
      if (_query.trim().isEmpty) return true;

      final q = _query.toLowerCase().trim();
      final matchName = p.name.toLowerCase().contains(q);
      final matchDesc = p.desc.toLowerCase().contains(q);
      final matchCategory = p.category.toLowerCase().contains(q);
      final matchSub = p.sub.toLowerCase().contains(q);

      return matchName || matchDesc || matchCategory || matchSub;
    }).toList();
  }

  void _onChipTap(String term) {
    setState(() {
      _query = term;
      _searchCtrl.text = term;
      _searchCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: term.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final results = _filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Search Header Bar ─────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: AppShadows.subtle,
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => widget.nav('back'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: AppColors.gray800),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                            color: _focusNode.hasFocus
                                ? AppColors.brandRed
                                : Colors.transparent,
                            width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              size: 20, color: AppColors.brandRed),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              focusNode: _focusNode,
                              onChanged: (val) => setState(() => _query = val),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray900),
                              decoration: const InputDecoration(
                                hintText: 'Search fresh chicken, mutton, eggs...',
                                hintStyle: TextStyle(
                                    color: AppColors.gray400,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w400),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _query = '';
                                  _searchCtrl.clear();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.gray300,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Category Filter Pills ─────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brandRed
                              : AppColors.gray100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.gray700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.gray200),

            // ── Main Search Content Body ─────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Show Popular / Recent Search Chips when query is empty
                  if (_query.isEmpty) ...[
                    Row(
                      children: const [
                        Icon(Icons.local_fire_department_rounded,
                            color: AppColors.brandRed, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Popular Searches',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _recentSearches.map((term) {
                        return ActionChip(
                          avatar: const Text('🔍', style: TextStyle(fontSize: 12)),
                          label: Text(term),
                          labelStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray800,
                          ),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.gray200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onPressed: () => _onChipTap(term),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Search Results Header Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _query.isEmpty
                            ? 'All Fresh Products (${results.length})'
                            : 'Results for "$_query" (${results.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gray800,
                        ),
                      ),
                      if (_query.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _query = '';
                              _searchCtrl.clear();
                              _selectedCategory = 'All';
                            });
                          },
                          child: const Text(
                            'Clear All',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandRed,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Results Grid or Empty State
                  if (results.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              color: AppColors.brandRedBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppColors.brandRed,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items matching "$_query"',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gray900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try searching for chicken, mutton, eggs, or prawns',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.gray500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _query = '';
                                _searchCtrl.clear();
                                _selectedCategory = 'All';
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('View All Fresh Products'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Products List
                    ...results.map((p) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.gray200),
                            boxShadow: AppShadows.subtle,
                          ),
                          child: InkWell(
                            onTap: () => widget.nav('detail', param: p.id),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      p.img,
                                      width: 75,
                                      height: 75,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 75,
                                        height: 75,
                                        color: AppColors.gray100,
                                        child: const Icon(Icons.kebab_dining,
                                            color: AppColors.gray400),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.brandRedBg,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                p.category.toUpperCase(),
                                                style: const TextStyle(
                                                  color: AppColors.brandRed,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              p.weight,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.gray500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          p.name,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.gray900,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          p.desc,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: AppColors.gray500,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Text(
                                              '₹${p.price}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.brandRed,
                                              ),
                                            ),
                                            if (p.mrp > p.price) ...[
                                              const SizedBox(width: 6),
                                              Text(
                                                '₹${p.mrp}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  decoration: TextDecoration.lineThrough,
                                                  color: AppColors.gray400,
                                                ),
                                              ),
                                            ],
                                            const Spacer(),
                                            appState.getProductQuantity(p.id) > 0
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
                                                          '${appState.getProductQuantity(p.id)}',
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
                                                    onPressed: () {
                                                      appState.addToCart(p);
                                                      showAppToast(context,
                                                          '${p.name} added to cart! 🛒');
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          AppColors.brandRed,
                                                      foregroundColor: Colors.white,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                              horizontal: 14,
                                                              vertical: 6),
                                                      minimumSize: Size.zero,
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(8),
                                                      ),
                                                      elevation: 0,
                                                    ),
                                                    child: const Text(
                                                      '+ ADD',
                                                      style: TextStyle(
                                                        fontSize: 11.5,
                                                        fontWeight: FontWeight.w800,
                                                      ),
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
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
