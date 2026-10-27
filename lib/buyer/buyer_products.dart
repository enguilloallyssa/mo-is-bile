import 'package:flutter/material.dart';
import 'models/buyer_product_model.dart';
import 'models/buyer_cart_model.dart';
import 'widgets/buyer_header.dart';
import 'widgets/buyer_product_card.dart';
import 'buyer_product_details.dart';
import 'buyer_shop.dart';
import 'buyer_messages.dart';
import 'buyer_checkout.dart';
import 'models/buyer_shop_model.dart';

class BuyerProducts extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;
  final String initialSearch;

  const BuyerProducts({
    super.key,
    this.onTabChanged,
    this.initialSearch = '',
  });

  @override
  State<BuyerProducts> createState() => _BuyerProductsState();
}

class _BuyerProductsState extends State<BuyerProducts> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _selectedCategory = '';
  String _sort = 'featured';
  bool _inStockOnly = false;
  double? _minPrice;
  double? _maxPrice;
  final Set<String> _selectedVariations = {};
  int _cartCount = 0;

  final List<BuyerProduct> _products = const [
    BuyerProduct(
      id: 1,
      name: 'Everyday Wireless Earbuds',
      category: 'Electronics',
      brand: 'SARI Mall',
      image: 'assets/images/sample-earbuds.jpg',
      rating: 4.8,
      sold: 426,
      stock: 34,
      price: 899,
      oldPrice: 1299,
      freeShipping: true,
      description:
          'Compact wireless earbuds for everyday listening and calls.',
      sku: 'SARI-EAR-001',
      ratingCount: 126,
      shopName: 'SARI Tech Corner',
      shopSlug: 'sari-tech-corner',
      sellerAccountId: 101,
      condition: 'brand_new',
      preparationDays: 1,
      packageInfo: BuyerPackageInfo(
        weightKg: 0.3,
        lengthCm: 12,
        widthCm: 9,
        heightCm: 5,
      ),
      variants: [
        BuyerProductVariant(
          id: 11,
          label: 'Black',
          price: 899,
          oldPrice: 1299,
          stock: 18,
        ),
        BuyerProductVariant(
          id: 12,
          label: 'White',
          price: 899,
          oldPrice: 1299,
          stock: 16,
        ),
      ],
      reviews: [
        BuyerProductReview(
          rating: 5,
          comment: 'Good sound quality and easy to pair.',
          createdAt: 'Recent purchase',
        ),
        BuyerProductReview(
          rating: 4,
          comment: 'Compact case and comfortable for daily use.',
          createdAt: 'Verified buyer',
        ),
      ],
      variations: ['Black', 'White'],
    ),
    BuyerProduct(
      id: 2,
      name: 'Minimal Everyday Tote',
      category: 'Fashion',
      brand: 'SARI Mall',
      image: 'assets/images/sample-tote.jpg',
      rating: 4.7,
      sold: 238,
      stock: 18,
      price: 349,
      oldPrice: 499,
      freeShipping: true,
      description:
          'A spacious everyday tote for school, errands, and casual use.',
      variations: ['Natural', 'Black'],
    ),
    BuyerProduct(
      id: 3,
      name: 'Soft Glow Desk Lamp',
      category: 'Home & Living',
      brand: 'SARI Mall',
      image: 'assets/images/sample-lamp.jpg',
      rating: 4.9,
      sold: 312,
      stock: 22,
      price: 549,
      oldPrice: 699,
      description:
          'Warm and compact desk lighting with a clean modern profile.',
      variations: ['Warm White', 'Neutral White'],
    ),
    BuyerProduct(
      id: 4,
      name: 'Daily Skin Essentials Set',
      category: 'Beauty',
      brand: 'SARI Mall',
      image: 'assets/images/sample-beauty.jpg',
      rating: 4.6,
      sold: 177,
      stock: 12,
      price: 699,
      oldPrice: 999,
      freeShipping: true,
      description:
          'A practical daily skincare set made for simple everyday routines.',
      variations: ['Starter Set', 'Complete Set'],
    ),
    BuyerProduct(
      id: 5,
      name: 'Classic Everyday Sneakers',
      category: 'Fashion',
      brand: 'Daily Finds',
      image: 'assets/images/sample-shoes.jpg',
      rating: 4.7,
      sold: 188,
      stock: 25,
      price: 799,
      oldPrice: 999,
      freeShipping: true,
      description:
          'Comfortable neutral sneakers designed for campus and city wear.',
      variations: ['40', '41', '42', '43'],
    ),
    BuyerProduct(
      id: 6,
      name: 'Daily Hydration Bottle 1L',
      category: 'Home & Living',
      brand: 'Daily Finds',
      image: 'assets/images/sample-bottle.jpg',
      rating: 4.8,
      sold: 803,
      stock: 90,
      price: 249,
      oldPrice: 299,
      description:
          'Reusable one-liter bottle with measurement marks and a secure lid.',
      variations: ['Smoke', 'Cream', 'Green'],
    ),
    BuyerProduct(
      id: 7,
      name: 'Compact Wireless Mouse',
      category: 'Electronics',
      brand: 'Tech Corner',
      image: 'assets/images/sample-mouse.jpg',
      rating: 4.8,
      sold: 932,
      stock: 77,
      price: 329,
      oldPrice: 399,
      description:
          'Quiet wireless mouse with compact body and precise tracking.',
      variations: ['Black', 'White'],
    ),
    BuyerProduct(
      id: 8,
      name: 'Travel Makeup Organizer',
      category: 'Beauty',
      brand: 'Daily Finds',
      image: 'assets/images/sample-organizer.jpg',
      rating: 0,
      sold: 0,
      stock: 8,
      price: 279,
      description:
          'Portable organizer with multiple sections for beauty essentials.',
      variations: ['Cream', 'Pink'],
    ),
    BuyerProduct(
      id: 9,
      name: 'Minimal Cable Organizer',
      category: 'Electronics',
      brand: 'Tech Corner',
      image: 'assets/images/sample-cable-organizer.jpg',
      rating: 4.5,
      sold: 104,
      stock: 0,
      price: 149,
      oldPrice: 199,
      description:
          'Simple cable management solution for desks and charging stations.',
      variations: ['Black'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialSearch;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<String> get _categories {
    final values = _products.map((product) => product.category).toSet().toList();
    values.sort();
    return values;
  }

  List<String> get _variations {
    final values = _products.expand((product) => product.variations).toSet().toList();
    values.sort();
    return values;
  }

  List<BuyerProduct> get _filteredProducts {
    final query = _normalize(_searchController.text);

    final filtered = _products.where((product) {
      final searchable = [
        product.name,
        product.brand,
        product.category,
      ].map(_normalize).join(' ');

      final matchesSearch = query.isEmpty || searchable.contains(query);
      final matchesCategory =
          _selectedCategory.isEmpty || product.category == _selectedCategory;
      final matchesStock = !_inStockOnly || product.stock > 0;
      final matchesMin = _minPrice == null || product.price >= _minPrice!;
      final matchesMax = _maxPrice == null || product.price <= _maxPrice!;
      final matchesVariation = _selectedVariations.isEmpty ||
          product.variations.any(_selectedVariations.contains);

      return matchesSearch &&
          matchesCategory &&
          matchesStock &&
          matchesMin &&
          matchesMax &&
          matchesVariation;
    }).toList();

    switch (_sort) {
      case 'latest':
        return filtered.reversed.toList();
      case 'price-low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        return filtered;
      case 'price-high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        return filtered;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        return filtered;
      case 'sold':
        filtered.sort((a, b) => b.sold.compareTo(a.sold));
        return filtered;
      default:
        return filtered;
    }
  }

  List<BuyerProduct> get _searchSuggestions {
    final query = _normalize(_searchController.text);
    if (query.isEmpty) return [];

    int score(BuyerProduct product) {
      final name = _normalize(product.name);
      final brand = _normalize(product.brand);
      final category = _normalize(product.category);

      var value = 0;
      if (name == query) value += 100;
      if (name.startsWith(query)) value += 70;
      if (name.contains(query)) value += 50;
      if (brand.startsWith(query)) value += 30;
      if (brand.contains(query)) value += 20;
      if (category.startsWith(query)) value += 18;
      if (category.contains(query)) value += 12;
      return value;
    }

    final matches = _products
        .map((product) => (product: product, score: score(product)))
        .where((item) => item.score > 0)
        .toList()
      ..sort((a, b) {
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) return scoreCompare;
        return a.product.name.compareTo(b.product.name);
      });

    return matches.take(6).map((item) => item.product).toList();
  }

  int get _activeFilterCount {
    var count = 0;
    if (_selectedCategory.isNotEmpty) count++;
    if (_inStockOnly) count++;
    if (_minPrice != null || _maxPrice != null) count++;
    if (_selectedVariations.isNotEmpty) count++;
    if (_sort != 'featured') count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      body: Column(
        children: [
          BuyerHeader(
            pageTitle: 'Shop Products',
            cartCount: _cartCount,
            onSearchTap: () {
              _searchFocusNode.requestFocus();
            },
            onCartTap: () => widget.onTabChanged?.call(2),
            onProfileTap: () => widget.onTabChanged?.call(4),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _pageIntro(),
                  const SizedBox(height: 10),
                  _saleBanner(),
                  if (_searchController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _searchNotice(),
                  ],
                  const SizedBox(height: 10),
                  _mobileFilterBar(),
                  const SizedBox(height: 10),
                  _searchField(),
                  if (_searchFocusNode.hasFocus &&
                      _searchController.text.trim().isNotEmpty)
                    _suggestionsPanel(),
                  const SizedBox(height: 9),
                  _categoryChips(),
                  const SizedBox(height: 10),
                  _resultsHeading(products.length),
                  const SizedBox(height: 9),
                  if (products.isEmpty)
                    _emptyState()
                  else ...[
                    BuyerProductCard(
                      product: products.first,
                      featured: true,
                      showPromotions: true,
                      showStock: true,
                      showQuickAdd: true,
                      onTap: () => _openProductDetails(products.first),
                      onAddToCart: () => _addToCart(products.first),
                      onBuyNow: () => _openProductModal(
                        products.first,
                        buyNow: true,
                      ),
                    ),
                    if (products.length > 1) ...[
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length - 1,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 9,
                          mainAxisSpacing: 9,
                          mainAxisExtent: 312,
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index + 1];

                          return BuyerProductCard(
                            product: product,
                            showPromotions: true,
                            showStock: true,
                            showQuickAdd: true,
                            onTap: () => _openProductDetails(product),
                            onAddToCart: () => _addToCart(product),
                            onBuyNow: () => _openProductModal(
                              product,
                              buyNow: true,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                  const SizedBox(height: 12),
                  _buyerProtection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageIntro() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SARI MARKETPLACE',
          style: TextStyle(
            color: Color(0xFFA87316),
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        SizedBox(height: 6),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Shop '),
              TextSpan(
                text: 'Products',
                style: TextStyle(color: Color(0xFFC2810D)),
              ),
            ],
          ),
          style: TextStyle(
            color: Color(0xFF17130F),
            fontSize: 27,
            height: 1.03,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.3,
          ),
        ),
        SizedBox(height: 7),
        Text(
          'Discover approved products from trusted SARI sellers. Search, compare, and find the right item for you.',
          style: TextStyle(
            color: Color(0xFF746C63),
            fontSize: 9,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  Widget _saleBanner() {
    return InkWell(
      onTap: () {
        setState(() {
          _sort = 'featured';
        });
      },
      borderRadius: BorderRadius.circular(11),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: AspectRatio(
          aspectRatio: 4.35 / 1,
          child: Image.asset(
            'assets/images/12-12-mega-sale-banner.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, .08),
            errorBuilder: (_, __, ___) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF8B1B12),
                      Color(0xFFB52A1B),
                    ],
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        '12.12 MEGA SALE\nUp to 50% OFF',
                        style: TextStyle(
                          color: Color(0xFFFFF0C7),
                          fontSize: 17,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.card_giftcard,
                      color: Color(0xFFEAC365),
                      size: 48,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _searchNotice() {
    final query = _searchController.text.trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF1),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFEADFC9)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.search,
              size: 17,
              color: Color(0xFFA8731F),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SEARCH RESULTS',
                  style: TextStyle(
                    color: Color(0xFFA8731F),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .7,
                  ),
                ),
                Text(
                  'Results for "$query"',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF3F3830),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {});
            },
            child: const Text(
              'Clear',
              style: TextStyle(fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileFilterBar() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFEBE4DA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BROWSE',
                  style: TextStyle(
                    color: Color(0xFFA8731F),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .7,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Narrow product results',
                  style: TextStyle(
                    color: Color(0xFF403930),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _openFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC9870E),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(104, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            icon: const Icon(Icons.tune, size: 16),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_activeFilterCount > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    height: 18,
                    constraints: const BoxConstraints(minWidth: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_activeFilterCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: (_) => setState(() {}),
      onTap: () => setState(() {}),
      style: const TextStyle(
        color: Color(0xFF50483F),
        fontSize: 9,
      ),
      decoration: InputDecoration(
        labelText: 'Search products',
        labelStyle: const TextStyle(
          color: Color(0xFF665D54),
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
        hintText: 'Search products, brands, or category...',
        hintStyle: const TextStyle(
          color: Color(0xFF9A9188),
          fontSize: 8,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 18,
          color: Color(0xFF9A9188),
        ),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close, size: 17),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: Color(0xFFDDD7D0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: Color(0xFFDDD7D0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: Color(0xFFCA8B17),
          ),
        ),
      ),
    );
  }

  Widget _suggestionsPanel() {
    final suggestions = _searchSuggestions;

    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4DED7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 9,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'POPULAR PRODUCTS',
                    style: TextStyle(
                      color: Color(0xFF514940),
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .7,
                    ),
                  ),
                ),
                Text(
                  '${suggestions.length} matches',
                  style: const TextStyle(
                    color: Color(0xFF9B9288),
                    fontSize: 6.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (suggestions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    'No product found',
                    style: TextStyle(
                      color: Color(0xFF5F574F),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Try another name, brand, or category.',
                    style: TextStyle(
                      color: Color(0xFF9B9288),
                      fontSize: 7,
                    ),
                  ),
                ],
              ),
            )
          else
            ...suggestions.map(_suggestionTile),
        ],
      ),
    );
  }

  Widget _suggestionTile(BuyerProduct product) {
    return InkWell(
      onTap: () {
        _searchController.text = product.name;
        _searchFocusNode.unfocus();
        setState(() {});
        _openProductDetails(product);
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3EE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE7E1D9)),
              ),
              child: const Icon(
                Icons.image_outlined,
                color: Color(0xFFAAA198),
                size: 20,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF302A24),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${product.category} • ${product.brand.isEmpty ? 'SARI Marketplace' : product.brand}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF948B82),
                      fontSize: 6.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.stock > 0
                        ? '${product.stock} in stock'
                        : 'Out of stock',
                    style: TextStyle(
                      color: product.stock > 0
                          ? const Color(0xFF4F8065)
                          : const Color(0xFFBD5555),
                      fontSize: 6.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '₱${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFFBF7B08),
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChips() {
    final categories = ['', ..._categories];

    return SizedBox(
      height: 33,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          if (index == categories.length) {
            return TextButton(
              onPressed: _resetFilters,
              child: const Text(
                'View all →',
                style: TextStyle(
                  color: Color(0xFFB5740C),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          final category = categories[index];
          final active = category == _selectedCategory;

          return ChoiceChip(
            label: Text(category.isEmpty ? 'All' : category),
            selected: active,
            onSelected: (_) {
              setState(() {
                _selectedCategory = category;
              });
            },
            selectedColor: const Color(0xFFCF8B0E),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: active
                  ? const Color(0xFFCF8B0E)
                  : const Color(0xFFDDD6CE),
            ),
            labelStyle: TextStyle(
              color: active
                  ? Colors.white
                  : const Color(0xFF413A33),
              fontSize: 7.5,
              fontWeight: FontWeight.w600,
            ),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  Widget _resultsHeading(int count) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURATED MARKETPLACE',
                style: TextStyle(
                  color: Color(0xFFA87316),
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .8,
                ),
              ),
              SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Recommended '),
                    TextSpan(
                      text: 'Products',
                      style: TextStyle(color: Color(0xFFC3830D)),
                    ),
                  ],
                ),
                style: TextStyle(
                  color: Color(0xFF201B17),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4DF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFF0DFBD)),
          ),
          child: Text(
            '$count products',
            style: const TextStyle(
              color: Color(0xFFA66B0B),
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE4DA)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFBF5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.search_off_outlined,
              color: Color(0xFFA8731F),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No products match your filters',
            style: TextStyle(
              color: Color(0xFF4F473E),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try another category, price range, availability, or product option.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF958C80),
              fontSize: 8,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _resetFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC9870E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text(
              'Clear Filters',
              style: TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buyerProtection() {
    const benefits = [
      (
        Icons.local_shipping_outlined,
        'Free Shipping',
        'On eligible orders',
      ),
      (
        Icons.shield_outlined,
        'Secure Payments',
        'Safe and encrypted',
      ),
      (
        Icons.restart_alt,
        'Easy Returns',
        'Hassle-free returns',
      ),
      (
        Icons.storefront_outlined,
        'Verified Sellers',
        'Trusted SARI partners',
      ),
      (
        Icons.favorite_border,
        'Shop with Purpose',
        'Support local. Build a brighter tomorrow.',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE8E1D8)),
      ),
      child: Column(
        children: List.generate(benefits.length, (index) {
          final benefit = benefits[index];

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: index == benefits.length - 1
                  ? const Color(0xFFFFF8E9)
                  : null,
              border: index == benefits.length - 1
                  ? null
                  : const Border(
                      bottom: BorderSide(color: Color(0xFFEEE8E1)),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFF5DF),
                  ),
                  child: Icon(
                    benefit.$1,
                    color: const Color(0xFFBD7B0F),
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit.$2,
                        style: TextStyle(
                          color: index == benefits.length - 1
                              ? const Color(0xFFA76C0C)
                              : const Color(0xFF36302A),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        benefit.$3,
                        style: const TextStyle(
                          color: Color(0xFF968D84),
                          fontSize: 6.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _openFilters() async {
    String tempCategory = _selectedCategory;
    String tempSort = _sort;
    bool tempInStock = _inStockOnly;
    double? tempMin = _minPrice;
    double? tempMax = _maxPrice;
    final tempVariations = Set<String>.from(_selectedVariations);

    final minController = TextEditingController(
      text: tempMin?.toStringAsFixed(0) ?? '',
    );
    final maxController = TextEditingController(
      text: tempMax?.toStringAsFixed(0) ?? '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PRODUCT FILTERS',
                                  style: TextStyle(
                                    color: Color(0xFFA8731F),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: .8,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Narrow Results',
                                  style: TextStyle(
                                    color: Color(0xFF28221B),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _sheetLabel('Category'),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          '',
                          ..._categories,
                        ].map((category) {
                          final selected = tempCategory == category;

                          return ChoiceChip(
                            label: Text(
                              category.isEmpty
                                  ? 'All Categories'
                                  : category,
                            ),
                            selected: selected,
                            onSelected: (_) {
                              setSheetState(() {
                                tempCategory = category;
                              });
                            },
                            selectedColor: const Color(0xFFFFF5DF),
                            labelStyle: const TextStyle(fontSize: 8),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      _sheetLabel('Price Range'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: minController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 9),
                              decoration: _sheetInput('Min'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: maxController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 9),
                              decoration: _sheetInput('Max'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _sheetLabel('Availability'),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: tempInStock,
                        activeColor: const Color(0xFFC99128),
                        title: const Text(
                          'In Stock Only',
                          style: TextStyle(fontSize: 9),
                        ),
                        onChanged: (value) {
                          setSheetState(() {
                            tempInStock = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _sheetLabel('Size / Variation'),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _variations.map((variation) {
                          final selected =
                              tempVariations.contains(variation);

                          return FilterChip(
                            label: Text(variation),
                            selected: selected,
                            onSelected: (value) {
                              setSheetState(() {
                                if (value) {
                                  tempVariations.add(variation);
                                } else {
                                  tempVariations.remove(variation);
                                }
                              });
                            },
                            selectedColor: const Color(0xFFFFF5DF),
                            labelStyle: const TextStyle(fontSize: 8),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      _sheetLabel('Sort By'),
                      DropdownButtonFormField<String>(
                        value: tempSort,
                        decoration: _sheetInput('Sort'),
                        style: const TextStyle(
                          color: Color(0xFF514940),
                          fontSize: 9,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'featured',
                            child: Text('Featured'),
                          ),
                          DropdownMenuItem(
                            value: 'latest',
                            child: Text('Newest'),
                          ),
                          DropdownMenuItem(
                            value: 'price-low',
                            child: Text('Price: Low to High'),
                          ),
                          DropdownMenuItem(
                            value: 'price-high',
                            child: Text('Price: High to Low'),
                          ),
                          DropdownMenuItem(
                            value: 'rating',
                            child: Text('Highest Rated'),
                          ),
                          DropdownMenuItem(
                            value: 'sold',
                            child: Text('Most Sold'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setSheetState(() {
                              tempSort = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setSheetState(() {
                                  tempCategory = '';
                                  tempSort = 'featured';
                                  tempInStock = false;
                                  tempMin = null;
                                  tempMax = null;
                                  tempVariations.clear();
                                  minController.clear();
                                  maxController.clear();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                              ),
                              child: const Text(
                                'Clear',
                                style: TextStyle(fontSize: 9),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                tempMin =
                                    double.tryParse(minController.text.trim());
                                tempMax =
                                    double.tryParse(maxController.text.trim());

                                setState(() {
                                  _selectedCategory = tempCategory;
                                  _sort = tempSort;
                                  _inStockOnly = tempInStock;
                                  _minPrice = tempMin;
                                  _maxPrice = tempMax;
                                  _selectedVariations
                                    ..clear()
                                    ..addAll(tempVariations);
                                });

                                Navigator.pop(sheetContext);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                                backgroundColor: const Color(0xFFC9870E),
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: const Text(
                                'Apply Filters',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    minController.dispose();
    maxController.dispose();
  }

  Widget _sheetLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF403930),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  InputDecoration _sheetInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 8),
      prefixText: hint == 'Min' || hint == 'Max' ? '₱ ' : null,
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE6DFD5),
        ),
      ),
    );
  }

  Future<void> _openProductDetails(
    BuyerProduct product, {
    bool buyNow = false,
  }) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => BuyerProductDetails(
          product: product,
          relatedProducts: _products,
          initialCartCount: _cartCount,
          buyNowMode: buyNow,
          onCartCountChanged: (count) {
            if (!mounted) return;
            setState(() {
              _cartCount = count;
            });
          },
          onViewCart: () {
            Navigator.pop(context);
            widget.onTabChanged?.call(2);
          },
          onVisitShop: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => BuyerShop(
                  shop: _shopForProduct(product),
                ),
              ),
            );
          },
          onMessageSeller: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => BuyerMessages(
                  initialSellerId: product.sellerAccountId,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openProductModal(
    BuyerProduct product, {
    bool buyNow = false,
  }) async {
    var quantity = 1;
    String? variation =
        product.variations.isEmpty ? null : product.variations.first;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 18,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CUSTOMIZE PRODUCT',
                        style: TextStyle(
                          color: Color(0xFFA8731F),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .8,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: Color(0xFF28221B),
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        product.category,
                        style: const TextStyle(
                          color: Color(0xFF91887D),
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 210,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F1E8),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Color(0xFFAAA197),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₱${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFFB97308),
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if ((product.oldPrice ?? 0) > product.price) ...[
                            const SizedBox(width: 7),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '₱${product.oldPrice!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFAAA197),
                                  fontSize: 10,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _modalPill(
                            '★ ${product.rating.toStringAsFixed(1)}',
                            const Color(0xFFFFF5DF),
                            const Color(0xFFA8731F),
                          ),
                          _modalPill(
                            product.stock > 0
                                ? '${product.stock} in stock'
                                : 'Out of stock',
                            product.stock > 0
                                ? const Color(0xFFEEF6F1)
                                : const Color(0xFFFFF1F1),
                            product.stock > 0
                                ? const Color(0xFF56816A)
                                : const Color(0xFFB65151),
                          ),
                          if (product.freeShipping)
                            _modalPill(
                              'Free Shipping',
                              const Color(0xFFEEF6F1),
                              const Color(0xFF56816A),
                            ),
                        ],
                      ),
                      if ((product.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 13),
                        Text(
                          product.description!,
                          style: const TextStyle(
                            color: Color(0xFF766D62),
                            fontSize: 9,
                            height: 1.55,
                          ),
                        ),
                      ],
                      if (product.variations.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        const Text(
                          'Variation / Size',
                          style: TextStyle(
                            color: Color(0xFF514A41),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: product.variations.map((item) {
                            return ChoiceChip(
                              label: Text(item),
                              selected: variation == item,
                              onSelected: (_) {
                                setSheetState(() {
                                  variation = item;
                                });
                              },
                              selectedColor: const Color(0xFFFFF5DF),
                              labelStyle: const TextStyle(fontSize: 8),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 15),
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          color: Color(0xFF514A41),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _quantityButton(
                            Icons.remove,
                            quantity > 1
                                ? () {
                                    setSheetState(() {
                                      quantity--;
                                    });
                                  }
                                : null,
                          ),
                          Container(
                            width: 48,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              border: Border.symmetric(
                                horizontal: BorderSide(
                                  color: Color(0xFFE6DFD5),
                                ),
                              ),
                            ),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _quantityButton(
                            Icons.add,
                            quantity < product.stock
                                ? () {
                                    setSheetState(() {
                                      quantity++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: product.stock <= 0
                                  ? null
                                  : () {
                                      setState(() {
                                        _cartCount += quantity;
                                      });
                                      Navigator.pop(sheetContext);
                                      _toast(
                                        '$quantity × ${product.name} added to cart'
                                        '${variation == null ? '' : ' • $variation'}',
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(45),
                                backgroundColor: const Color(0xFFC9870E),
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              icon: const Icon(
                                Icons.add_shopping_cart_outlined,
                                size: 17,
                              ),
                              label: const Text(
                                'Add to Cart',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: product.stock <= 0
                                  ? null
                                  : () {
                                      Navigator.pop(sheetContext);
                                      Navigator.push<void>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BuyerCheckout(
                                            items: [
                                              BuyerCartItem(
                                                id: product.id,
                                                productId: product.id,
                                                sellerId: product.sellerAccountId,
                                                storeName: product.shopName,
                                                productName: product.name,
                                                variantLabel: variation ?? '',
                                                image: product.image,
                                                unitPrice: product.price,
                                                quantity: quantity,
                                                maxStock: product.stock,
                                                freeShipping: product.freeShipping,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(45),
                              ),
                              child: Text(
                                buyNow ? 'Continue Buy Now' : 'Buy Now',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _modalPill(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback? onPressed) {
    return SizedBox(
      width: 40,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(),
          side: const BorderSide(color: Color(0xFFE6DFD5)),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  void _addToCart(BuyerProduct product) {
    if (product.stock <= 0) return;

    setState(() {
      _cartCount++;
    });

    _toast('${product.name} added to cart');
  }

  BuyerShopData _shopForProduct(BuyerProduct product) {
    final sellerProducts = _products
        .where((item) => item.sellerAccountId == product.sellerAccountId)
        .toList();

    return BuyerShopData(
      sellerAccountId: product.sellerAccountId,
      storeName: product.shopName,
      description:
          'Approved SARI marketplace seller with active listings for mobile buyers.',
      publicPhone: '09123456789',
      publicEmail: 'seller@sari.test',
      rating: sellerProducts.isEmpty
          ? product.rating
          : sellerProducts.fold<double>(0, (sum, item) => sum + item.rating) /
              sellerProducts.length,
      ratingCount: sellerProducts.fold<int>(
        0,
        (sum, item) => sum + item.ratingCount,
      ),
      vouchers: const [
        BuyerShopVoucher(
          code: 'SARI10',
          name: 'Seller welcome voucher',
          value: '10% OFF',
          minimum: 500,
        ),
      ],
      products: sellerProducts,
    );
  }

  void _resetFilters() {
    _searchController.clear();

    setState(() {
      _selectedCategory = '';
      _sort = 'featured';
      _inStockOnly = false;
      _minPrice = null;
      _maxPrice = null;
      _selectedVariations.clear();
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}
