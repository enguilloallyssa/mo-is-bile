import 'package:flutter/material.dart';

import 'models/buyer_cart_model.dart';
import 'buyer_checkout.dart';
import 'widgets/buyer_header.dart';

class BuyerCart extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;

  const BuyerCart({
    super.key,
    this.onTabChanged,
  });

  @override
  State<BuyerCart> createState() => _BuyerCartState();
}

class _BuyerCartState extends State<BuyerCart> {
  static const Color _gold = Color(0xFFC98D19);
  static const Color _goldDark = Color(0xFFB77D10);
  static const Color _pageBg = Color(0xFFFBFAF7);
  static const double _deliveryFeePerSeller = 80;

  final Set<int> _selectedItemIds = <int>{};

  final List<BuyerCartItem> _items = [
    BuyerCartItem(
      id: 1,
      productId: 1,
      sellerId: 101,
      storeName: 'SARI Tech Corner',
      productName: 'Everyday Wireless Earbuds',
      variantLabel: 'Black',
      unitPrice: 899,
      quantity: 1,
      maxStock: 18,
      freeShipping: true,
    ),
    BuyerCartItem(
      id: 2,
      productId: 7,
      sellerId: 101,
      storeName: 'SARI Tech Corner',
      productName: 'Compact Wireless Mouse',
      variantLabel: 'White',
      unitPrice: 329,
      quantity: 2,
      maxStock: 77,
      freeShipping: false,
    ),
    BuyerCartItem(
      id: 3,
      productId: 2,
      sellerId: 202,
      storeName: 'Daily Finds',
      productName: 'Minimal Everyday Tote',
      variantLabel: 'Natural',
      unitPrice: 349,
      quantity: 1,
      maxStock: 18,
      freeShipping: true,
    ),
  ];

  Map<int, List<BuyerCartItem>> get _sellerGroups {
    final groups = <int, List<BuyerCartItem>>{};

    for (final item in _items) {
      groups.putIfAbsent(item.sellerId, () => <BuyerCartItem>[]);
      groups[item.sellerId]!.add(item);
    }

    return groups;
  }

  List<BuyerCartItem> get _selectedItems {
    return _items
        .where((item) => _selectedItemIds.contains(item.id))
        .toList();
  }

  double get _selectedSubtotal {
    return _selectedItems.fold(
      0,
      (sum, item) => sum + item.lineTotal,
    );
  }

  double get _selectedDelivery {
    final selected = _selectedItems;
    if (selected.isEmpty) return 0;

    final groups = <int, List<BuyerCartItem>>{};

    for (final item in selected) {
      groups.putIfAbsent(item.sellerId, () => <BuyerCartItem>[]);
      groups[item.sellerId]!.add(item);
    }

    double fee = 0;

    for (final group in groups.values) {
      final allFreeShipping = group.every((item) => item.freeShipping);

      if (!allFreeShipping) {
        fee += _deliveryFeePerSeller;
      }
    }

    return fee;
  }

  double get _selectedTotal => _selectedSubtotal + _selectedDelivery;

  bool get _allSelected =>
      _items.isNotEmpty && _selectedItemIds.length == _items.length;

  bool get _partiallySelected =>
      _selectedItemIds.isNotEmpty && !_allSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Column(
        children: [
          BuyerHeader(
            pageTitle: 'Shopping Cart',
            cartCount: _items.length,
            onSearchTap: () => widget.onTabChanged?.call(1),
            onCartTap: () {},
            onProfileTap: () => widget.onTabChanged?.call(4),
          ),
          Expanded(
            child: _items.isEmpty ? _emptyCart() : _cartContent(),
          ),
        ],
      ),
    );
  }

  Widget _cartContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 15, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _pageHeader(),
          const SizedBox(height: 14),
          _selectAllToolbar(),
          const SizedBox(height: 12),
          ..._sellerGroups.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _sellerGroup(
                sellerId: entry.key,
                items: entry.value,
              ),
            );
          }),
          _orderSummary(),
        ],
      ),
    );
  }

  Widget _pageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SARI MARKETPLACE',
          style: TextStyle(
            color: Color(0xFFB57912),
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 3),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Shopping '),
              TextSpan(
                text: 'Cart',
                style: TextStyle(color: _gold),
              ),
            ],
          ),
          style: TextStyle(
            color: Color(0xFF241F1A),
            fontSize: 29,
            height: 1.08,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose the products you want to checkout. Only checked items will continue.',
          style: TextStyle(
            color: Color(0xFF8D8479),
            fontSize: 10,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 11),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _headerPill(
              icon: Icons.shopping_cart_outlined,
              text:
                  '${_items.length} item${_items.length == 1 ? '' : 's'} in your cart',
            ),
            OutlinedButton.icon(
              onPressed: () => widget.onTabChanged?.call(1),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF966719),
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Color(0xFFD9BD80),
                ),
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.arrow_back,
                size: 15,
              ),
              label: const Text(
                'Continue Shopping',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        const Divider(
          color: Color(0xFFEEE8DF),
          height: 1,
        ),
      ],
    );
  }

  Widget _headerPill({
    required IconData icon,
    required String text,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFEADFC9),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFF966719),
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF966719),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectAllToolbar() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFDFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE6DDD1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E3D2F1F),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _selectionCheckbox(
            checked: _allSelected,
            indeterminate: _partiallySelected,
            onTap: _toggleSelectAll,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select all products',
                  style: TextStyle(
                    color: Color(0xFF403930),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_items.length} item${_items.length == 1 ? '' : 's'} in your cart',
                  style: const TextStyle(
                    color: Color(0xFF9A9187),
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          _selectedCountPill(),
        ],
      ),
    );
  }

  Widget _selectedCountPill() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEADFC9),
        ),
      ),
      child: Text(
        '${_selectedItemIds.length} selected',
        style: const TextStyle(
          color: Color(0xFF9A6817),
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _sellerGroup({
    required int sellerId,
    required List<BuyerCartItem> items,
  }) {
    final storeName =
        items.isEmpty ? 'SARI Seller Store' : items.first.storeName;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5DBCE),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F3D2F1F),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),
            color: const Color(0xFFFCFBF8),
            child: Row(
              children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEAD9B8),
                    ),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: Color(0xFFB97913),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        style: const TextStyle(
                          color: Color(0xFF39322B),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F8F4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFCFE3D6),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user_outlined,
                                  size: 10,
                                  color: Color(0xFF4F7D63),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Verified Seller',
                                  style: TextStyle(
                                    color: Color(0xFF4F7D63),
                                    fontSize: 6.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${items.length} product${items.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Color(0xFF9B9287),
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFFFAF9F7),
            padding: const EdgeInsets.all(9),
            child: Column(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _cartItemCard(item),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartItemCard(BuyerCartItem item) {
    final selected = _selectedItemIds.contains(item.id);

    return InkWell(
      onTap: () => _toggleItem(item.id),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFFDF8)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFFD9AA4C)
                : const Color(0xFFE9E1D7),
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0x1AB2740D)
                  : const Color(0x0D3D2F1F),
              blurRadius: selected ? 22 : 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: _selectionCheckbox(
                    checked: selected,
                    onTap: () => _toggleItem(item.id),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F5EF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFEBE3D8),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _cartImage(item.image),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          if (item.freeShipping)
                            _miniPill(
                              icon: Icons.local_shipping_outlined,
                              text: 'Free Shipping',
                              background: const Color(0xFFF1F8F4),
                              foreground: const Color(0xFF4F7D63),
                              border: const Color(0xFFCFE3D6),
                            ),
                          _miniPill(
                            text: '${item.maxStock} in stock',
                            background: const Color(0xFFF6F3EF),
                            foreground: const Color(0xFF756C62),
                            border: const Color(0xFFF0ECE6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        item.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF2F2923),
                          fontSize: 12,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (item.variantLabel.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.variantLabel,
                          style: const TextStyle(
                            color: Color(0xFF8F867A),
                            fontSize: 8,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 7),
                      Text(
                        '${_peso(item.unitPrice)} each',
                        style: const TextStyle(
                          color: Color(0xFFA0968B),
                          fontSize: 7.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(
              height: 1,
              color: Color(0xFFEEE8DF),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _quantityControl(item),
                const SizedBox(width: 7),
                OutlinedButton(
                  onPressed: () => _showUpdated(item),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8F5E09),
                    backgroundColor: const Color(0xFFFFFAF0),
                    side: const BorderSide(
                      color: Color(0xFFD5AE5B),
                    ),
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _peso(item.lineTotal),
                      style: const TextStyle(
                        color: Color(0xFFC17D0C),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.4,
                      ),
                    ),
                    const Text(
                      'Item total',
                      style: TextStyle(
                        color: Color(0xFFA1988E),
                        fontSize: 6.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _confirmRemove(item),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8D641D),
                ),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 15,
                ),
                label: const Text(
                  'Remove',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityControl(BuyerCartItem item) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFDDD3C6),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyButton(
            icon: Icons.remove,
            onPressed: item.quantity > 1
                ? () => _changeQuantity(
                      item,
                      item.quantity - 1,
                    )
                : null,
          ),
          Container(
            width: 42,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(
                  color: Color(0xFFE8E1D8),
                ),
              ),
            ),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                color: Color(0xFF433C35),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _qtyButton(
            icon: Icons.add,
            onPressed: item.quantity < item.maxStock
                ? () => _changeQuantity(
                      item,
                      item.quantity + 1,
                    )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 34,
      height: 38,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 14),
        color: const Color(0xFF73695F),
      ),
    );
  }

  Widget _orderSummary() {
    final selectedCount = _selectedItemIds.length;
    final hasSelection = selectedCount > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE7DFD4),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x123D2F1F),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              15,
              14,
              15,
              12,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Order Summary',
                    style: TextStyle(
                      color: Color(0xFF302A24),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _selectedCountPill(),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFEEE8DF),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _summaryRow(
                  'Selected items',
                  _peso(_selectedSubtotal),
                ),
                const SizedBox(height: 11),
                _summaryRow(
                  'Estimated delivery',
                  _peso(_selectedDelivery),
                ),
                const SizedBox(height: 14),
                const Divider(
                  height: 1,
                  color: Color(0xFFEEE8DF),
                ),
                const SizedBox(height: 13),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: Text(
                        'Estimated Total',
                        style: TextStyle(
                          color: Color(0xFF514A42),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _peso(_selectedTotal),
                      style: const TextStyle(
                        color: Color(0xFFB97805),
                        fontSize: 24,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed:
                        hasSelection ? _continueToCheckout : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFFD9D4CC),
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      hasSelection
                          ? 'Checkout ($selectedCount)'
                          : 'Checkout',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFDBE6F3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFB8D0EA),
                          ),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Color(0xFF55799E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hasSelection
                              ? 'Only these $selectedCount selected product${selectedCount == 1 ? '' : 's'} will continue to checkout.'
                              : 'Only checked products will continue to checkout. Items you do not select stay safely in your cart.',
                          style: const TextStyle(
                            color: Color(0xFF67809A),
                            fontSize: 7.5,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: _trustSummaryItem(
                        Icons.verified_user_outlined,
                        'Buyer Protection',
                        const Color(0xFFF2F8F4),
                        const Color(0xFF4F8065),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _trustSummaryItem(
                        Icons.credit_card_outlined,
                        'Secure Checkout',
                        const Color(0xFFFFF7E8),
                        const Color(0xFFB87912),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _trustSummaryItem(
                        Icons.local_shipping_outlined,
                        'Verified Sellers',
                        const Color(0xFFF3F6FA),
                        const Color(0xFF577899),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8D8479),
              fontSize: 9,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF4C453D),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _trustSummaryItem(
    IconData icon,
    String label,
    Color background,
    Color foreground,
  ) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 17,
            color: foreground,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF756D63),
            fontSize: 6.5,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _selectionCheckbox({
    required bool checked,
    bool indeterminate = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: checked || indeterminate
              ? const Color(0xFFD29115)
              : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: checked || indeterminate
                ? const Color(0xFFD29115)
                : const Color(0xFFD8D0C5),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          indeterminate ? Icons.remove : Icons.check,
          size: 14,
          color: checked || indeterminate
              ? Colors.white
              : Colors.transparent,
        ),
      ),
    );
  }

  Widget _miniPill({
    IconData? icon,
    required String text,
    required Color background,
    required Color foreground,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 10,
              color: foreground,
            ),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontSize: 6.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartImage(String? source) {
    final image = source?.trim() ?? '';

    if (image.isEmpty) {
      return const Center(
        child: Icon(
          Icons.image_outlined,
          color: Color(0xFFACA399),
          size: 27,
        ),
      );
    }

    final network = image.startsWith('http://') ||
        image.startsWith('https://') ||
        image.startsWith('//');

    if (network) {
      return Image.network(
        image.startsWith('//') ? 'https:$image' : image,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(
            Icons.image_outlined,
            color: Color(0xFFACA399),
            size: 27,
          ),
        ),
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(
          Icons.image_outlined,
          color: Color(0xFFACA399),
          size: 27,
        ),
      ),
    );
  }

  Widget _emptyCart() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 24, 14, 30),
      child: Column(
        children: [
          _pageHeader(),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 50,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFDED5C9),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFAF1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEADFC9),
                    ),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Color(0xFFB97812),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Your cart is empty',
                  style: TextStyle(
                    color: Color(0xFF403A33),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Start exploring products from approved SARI sellers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF91887D),
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => widget.onTabChanged?.call(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(132, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text(
                    'Browse Products',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleItem(int itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_allSelected) {
        _selectedItemIds.clear();
      } else {
        _selectedItemIds
          ..clear()
          ..addAll(_items.map((item) => item.id));
      }
    });
  }

  void _changeQuantity(
    BuyerCartItem item,
    int quantity,
  ) {
    final bounded = quantity.clamp(1, item.maxStock).toInt();

    setState(() {
      item.quantity = bounded;
    });
  }

  void _showUpdated(BuyerCartItem item) {
    _toast(
      '${item.productName} updated to quantity ${item.quantity}.',
    );
  }

  Future<void> _confirmRemove(BuyerCartItem item) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove item?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Remove ${item.productName} from your cart?',
            style: const TextStyle(fontSize: 11),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                false,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                true,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _goldDark,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (remove != true) return;

    setState(() {
      _selectedItemIds.remove(item.id);
      _items.removeWhere((cartItem) => cartItem.id == item.id);
    });

    _toast('Item removed from cart.');
  }

  void _continueToCheckout() {
    if (_selectedItems.isEmpty) return;

    final checkoutItems = _selectedItems
        .map((item) => item.copyWith())
        .toList();

    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => BuyerCheckout(
          items: checkoutItems,
          onOrderPlaced: () {
            Navigator.pop(context);
            widget.onTabChanged?.call(3);
          },
        ),
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _peso(double value) {
    return '₱${value.toStringAsFixed(2)}';
  }
}
