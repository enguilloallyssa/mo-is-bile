import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'buyer_checkout.dart';
import 'models/buyer_cart_model.dart';
import 'widgets/buyer_header.dart';

class BuyerCart extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;

  const BuyerCart({
    super.key,
    this.onTabChanged,
  });

  @override
  State<BuyerCart> createState() =>
      _BuyerCartState();
}

class _BuyerCartState extends State<BuyerCart> {
  static const Color gold =
      Color(0xFFCC8A0B);

  static const Color goldDark =
      Color(0xFFA96D07);

  static const Color dark =
      Color(0xFF24201C);

  static const Color muted =
      Color(0xFF7F776E);

  static const Color canvas =
      Color(0xFFFBFAF8);

  static const Color border =
      Color(0xFFE9E3DB);

  final List<BuyerCartItem> _items = [];

  final Set<int> _selectedItemIds =
      <int>{};

  bool _loading = true;
  bool _previewLoading = false;

  String? _error;
  String? _previewError;

  double _selectedSubtotal = 0;
  double _originalDeliveryFee = 0;
  double _shippingDiscount = 0;
  double _selectedDeliveryFee = 0;
  double _selectedTotal = 0;

  int _previewVersion = 0;

  @override
  void initState() {
    super.initState();

    _loadCart();
  }

  Map<String, dynamic> _map(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return {};
  }

  String _text(
    dynamic value, [
    String fallback = '',
  ]) {
    final text =
        value?.toString().trim() ?? '';

    return text.isEmpty
        ? fallback
        : text;
  }

  int _integer(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse('$value') ?? 0;
  }

  double _decimal(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse('$value') ?? 0;
  }

  BuyerCartItem _parseItem(
    dynamic raw,
  ) {
    final data = _map(raw);

    return BuyerCartItem(
      id: _integer(
        data['id'],
      ),
      productId: _integer(
        data['product_id'],
      ),
      variantId:
          data['variant_id'] == null
              ? null
              : _integer(
                  data['variant_id'],
                ),
      storeName: _text(
        data['store_name'],
        'SARI Seller Store',
      ),
      productName: _text(
        data['name'],
        'Product',
      ),
      variantLabel: _text(
        data['variant_label'],
        'Standard',
      ),
      image:
          _text(
            data['image_url'],
          ).isEmpty
              ? null
              : _text(
                  data['image_url'],
                ),
      unitPrice: _decimal(
        data['unit_price'],
      ),
      serverLineTotal: _decimal(
        data['line_total'],
      ),
      quantity: _integer(
        data['quantity'],
      ),
      maxStock: _integer(
        data['max_stock'],
      ),
      selectable:
          data['selectable'] == true,
      availabilityReason: _text(
        data['availability_reason'],
      ),
    );
  }

  Map<String, List<BuyerCartItem>>
      get _sellerGroups {
    final groups =
        <String, List<BuyerCartItem>>{};

    for (final item in _items) {
      groups
          .putIfAbsent(
            item.storeName,
            () => <BuyerCartItem>[],
          )
          .add(item);
    }

    return groups;
  }

  List<BuyerCartItem>
      get _selectedItems {
    return _items
        .where(
          (item) =>
              _selectedItemIds.contains(
                item.id,
              ) &&
              item.selectable,
        )
        .toList();
  }

  bool get _allSelectableSelected {
    final selectable = _items
        .where(
          (item) => item.selectable,
        )
        .map(
          (item) => item.id,
        )
        .toSet();

    return selectable.isNotEmpty &&
        _selectedItemIds.length ==
            selectable.length &&
        _selectedItemIds.containsAll(
          selectable,
        );
  }

  bool get _partiallySelected {
    return _selectedItemIds.isNotEmpty &&
        !_allSelectableSelected;
  }

  Future<void> _loadCart({
    bool showLoader = true,
  }) async {
    if (showLoader) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final response =
          await SariLiveData.instance
              .buyerCart();

      final data =
          _map(response['data']);

      final rawItems =
          data['items'] is List
              ? data['items'] as List
              : const [];

      final items = rawItems
          .map(_parseItem)
          .where(
            (item) => item.id > 0,
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _items
          ..clear()
          ..addAll(items);

        _selectedItemIds.removeWhere(
          (id) {
          BuyerCartItem? found;

        for (final item in _items) {
          if (item.id == id) {
        found = item;
      break;
    }
    }

return found == null ||
    !found.selectable;
          },
        );

        _loading = false;
        _error = null;
      });

      await _refreshPreview();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            error.toString();
      });
    }
  }

  Future<void> _refreshPreview()
      async {
    final version =
        ++_previewVersion;

    final ids = _selectedItems
        .map(
          (item) => item.id,
        )
        .toList();

    if (ids.isEmpty) {
      if (!mounted) return;

      setState(() {
        _previewLoading = false;
        _previewError = null;

        _selectedSubtotal = 0;
        _originalDeliveryFee = 0;
        _shippingDiscount = 0;
        _selectedDeliveryFee = 0;
        _selectedTotal = 0;
      });

      return;
    }

    setState(() {
      _previewLoading = true;
      _previewError = null;
    });

    try {
      final response =
          await SariLiveData.instance
              .buyerCheckoutPreview(
        ids,
      );

      final data =
          _map(response['data']);

      final shipping =
          _map(data['shipping']);

      if (!mounted ||
          version != _previewVersion) {
        return;
      }

      setState(() {
        _selectedSubtotal =
            _decimal(
          data['subtotal'],
        );

        _originalDeliveryFee =
            _decimal(
          shipping[
              'original_delivery_fee'],
        );

        _shippingDiscount =
            _decimal(
          shipping[
              'shipping_discount'],
        );

        _selectedDeliveryFee =
            _decimal(
          shipping[
              'delivery_fee'],
        );

        _selectedTotal =
            _decimal(
          data['grand_total'],
        );

        _previewLoading = false;
      });
    } catch (error) {
      if (!mounted ||
          version != _previewVersion) {
        return;
      }

      setState(() {
        _previewLoading = false;
        _previewError =
            error.toString();
      });
    }
  }

  void _toggleItem(
    BuyerCartItem item,
  ) {
    if (!item.selectable) {
      return;
    }

    setState(() {
      if (_selectedItemIds
          .contains(item.id)) {
        _selectedItemIds.remove(
          item.id,
        );
      } else {
        _selectedItemIds.add(
          item.id,
        );
      }
    });

    _refreshPreview();
  }

  void _toggleSelectAll() {
    final selectableIds = _items
        .where(
          (item) => item.selectable,
        )
        .map(
          (item) => item.id,
        )
        .toSet();

    setState(() {
      if (_allSelectableSelected) {
        _selectedItemIds.clear();
      } else {
        _selectedItemIds
          ..clear()
          ..addAll(
            selectableIds,
          );
      }
    });

    _refreshPreview();
  }

  Future<void> _updateQuantity(
    BuyerCartItem item,
    int quantity,
  ) async {
    if (!item.quantityEditable ||
        quantity < 1 ||
        quantity > item.maxStock) {
      return;
    }

    try {
      final response =
          await SariLiveData.instance
              .buyerUpdateCart(
        item.id,
        quantity,
      );

      if (!mounted) return;

      _message(
        response['message']
                ?.toString() ??
            'Cart updated.',
      );

      await _loadCart(
        showLoader: false,
      );
    } catch (error) {
      if (!mounted) return;

      _message(
        error.toString(),
      );
    }
  }

  Future<void> _removeItem(
    BuyerCartItem item,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove Item',
          ),
          content: const Text(
            'Remove this item from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(
                    dialogContext,
                  ).pop(false),
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(
                    dialogContext,
                  ).pop(true),
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    Colors.redAccent,
              ),
              child: const Text(
                'Remove',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final response =
          await SariLiveData.instance
              .buyerRemoveCart(
        item.id,
      );

      if (!mounted) return;

      _selectedItemIds.remove(
        item.id,
      );

      _message(
        response['message']
                ?.toString() ??
            'Item removed from cart.',
      );

      await _loadCart(
        showLoader: false,
      );
    } catch (error) {
      if (!mounted) return;

      _message(
        error.toString(),
      );
    }
  }

  Future<void> _checkout() async {
    if (_selectedItems.isEmpty ||
        _previewLoading ||
        _previewError != null) {
      return;
    }

    final result =
        await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            BuyerCheckout(
          items:
              List<BuyerCartItem>.from(
            _selectedItems,
          ),
        ),
      ),
    );

    if (result == true &&
        mounted) {
      _selectedItemIds.clear();

      await _loadCart();
    }
  }

  void _message(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  String _money(
    double amount,
  ) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  Widget _pageHeader() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'SARI MARKETPLACE',
          style: TextStyle(
            color: goldDark,
            fontSize: 8,
            fontWeight:
                FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Shopping ',
              ),
              TextSpan(
                text: 'Cart',
                style: TextStyle(
                  color: gold,
                ),
              ),
            ],
          ),
          style: TextStyle(
            color: dark,
            fontSize: 28,
            height: 1.08,
            fontWeight:
                FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 13),
        TextButton.icon(
          onPressed: () =>
              widget.onTabChanged
                  ?.call(1),
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 16,
          ),
          label: const Text(
            'Continue Shopping',
          ),
        ),
      ],
    );
  }

  Widget _selectAllToolbar() {
    final selectableCount =
        _items
            .where(
              (item) =>
                  item.selectable,
            )
            .length;

    return Container(
      padding:
          const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _allSelectableSelected
                ? true
                : _partiallySelected
                    ? null
                    : false,
            tristate: true,
            activeColor: gold,
            onChanged: selectableCount == 0
                ? null
                : (_) =>
                    _toggleSelectAll(),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select all products',
                  style: TextStyle(
                    color: dark,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_items.length} item${_items.length == 1 ? '' : 's'} in your cart',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(
                0xFFFFFAF1,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              border: Border.all(
                color: const Color(
                  0xFFEADFC9,
                ),
              ),
            ),
            child: Text(
              '${_selectedItemIds.length} selected',
              style:
                  const TextStyle(
                color: goldDark,
                fontSize: 8,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sellerGroup(
    String storeName,
    List<BuyerCartItem> items,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: border,
        ),
      ),
      clipBehavior:
          Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFFCFBF8),
              border: Border(
                bottom: BorderSide(
                  color: border,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment:
                      Alignment.center,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFFFF3DA,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .storefront_outlined,
                    color: goldDark,
                    size: 19,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    storeName,
                    style:
                        const TextStyle(
                      color: dark,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${items.length} product${items.length == 1 ? '' : 's'}',
                  style:
                      const TextStyle(
                    color: muted,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          ...items.map(
            (item) =>
                _cartItem(item),
          ),
        ],
      ),
    );
  }

  Widget _cartItem(
    BuyerCartItem item,
  ) {
    final selected =
        _selectedItemIds.contains(
      item.id,
    );

    final image =
        item.image?.trim() ?? '';

    return InkWell(
      onTap: item.selectable
          ? () =>
              _toggleItem(item)
          : null,
      child: Container(
        padding:
            const EdgeInsets.all(12),
        decoration:
            const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: border,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: selected,
              activeColor: gold,
              onChanged:
                  item.selectable
                      ? (_) =>
                          _toggleItem(
                            item,
                          )
                      : null,
            ),
            const SizedBox(width: 3),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
              child: SizedBox(
                width: 78,
                height: 78,
                child: image.isEmpty
                    ? _imagePlaceholder()
                    : Image.network(
                        image,
                        fit:
                            BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                _imagePlaceholder(),
                      ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color: dark,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    item.variantLabel,
                    style:
                        const TextStyle(
                      color: muted,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${_money(item.unitPrice)} each',
                    style:
                        const TextStyle(
                      color: muted,
                      fontSize: 8,
                    ),
                  ),
                  if (!item.selectable &&
                      item.availabilityReason
                          .isNotEmpty) ...[
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      item.availabilityReason,
                      style:
                          const TextStyle(
                        color:
                            Colors.redAccent,
                        fontSize: 9,
                        height: 1.4,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      _quantityButton(
                        icon:
                            Icons.remove,
                        enabled:
                            item.quantityEditable &&
                                item.quantity >
                                    1,
                        onTap: () =>
                            _updateQuantity(
                          item,
                          item.quantity -
                              1,
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 34,
                        alignment:
                            Alignment.center,
                        decoration:
                            const BoxDecoration(
                          border:
                              Border.symmetric(
                            horizontal:
                                BorderSide(
                              color:
                                  border,
                            ),
                          ),
                        ),
                        child: Text(
                          '${item.quantity}',
                          style:
                              const TextStyle(
                            color: dark,
                            fontSize:
                                11,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                      _quantityButton(
                        icon: Icons.add,
                        enabled:
                            item.quantityEditable &&
                                item.quantity <
                                    item.maxStock,
                        onTap: () =>
                            _updateQuantity(
                          item,
                          item.quantity +
                              1,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Remove',
                        onPressed: () =>
                            _removeItem(
                          item,
                        ),
                        icon:
                            const Icon(
                          Icons
                              .delete_outline_rounded,
                          color:
                              Colors.redAccent,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  _money(
                    item.lineTotal,
                  ),
                  style:
                      const TextStyle(
                    color: goldDark,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                const Text(
                  'Item total',
                  style:
                      TextStyle(
                    color: muted,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 36,
      height: 34,
      child: OutlinedButton(
        onPressed:
            enabled ? onTap : null,
        style:
            OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(
            color: border,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              7,
            ),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
        ),
      ),
    );
  }

  Widget _orderSummary() {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Order Summary',
                  style:
                      TextStyle(
                    color: dark,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${_selectedItemIds.length} selected',
                style:
                    const TextStyle(
                  color: goldDark,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          if (_previewLoading)
            const LinearProgressIndicator(
              color: gold,
              minHeight: 2,
            ),
          if (_previewError !=
              null) ...[
            Text(
              _previewError!,
              style:
                  const TextStyle(
                color:
                    Colors.redAccent,
                fontSize: 9,
                height: 1.4,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
          ],
          _summaryRow(
            'Selected items',
            _selectedSubtotal,
          ),
          const SizedBox(
            height: 10,
          ),
          _summaryRow(
            'Estimated delivery',
            _originalDeliveryFee,
          ),
          if (_shippingDiscount >
              0) ...[
            const SizedBox(
              height: 10,
            ),
            _summaryRow(
              'Free Shipping discount',
              -_shippingDiscount,
              discount: true,
            ),
          ],
          const SizedBox(
            height: 10,
          ),
          _summaryRow(
            'Delivery payable',
            _selectedDeliveryFee,
          ),
          const SizedBox(
            height: 14,
          ),
          const Divider(
            color: border,
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Estimated Total',
                  style:
                      TextStyle(
                    color: dark,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _money(
                  _selectedTotal,
                ),
                style:
                    const TextStyle(
                  color: goldDark,
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            width: double.infinity,
            child:
                ElevatedButton(
              onPressed:
                  _selectedItems
                              .isEmpty ||
                          _previewLoading ||
                          _previewError !=
                              null
                      ? null
                      : _checkout,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    gold,
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 14,
                ),
              ),
              child:
                  const Text(
                'Checkout',
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Only checked products will continue to checkout. Items you do not select stay safely in your cart.',
            style: TextStyle(
              color: Color(
                0xFF67809A,
              ),
              fontSize: 8,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    double amount, {
    bool discount = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: discount
                  ? const Color(
                      0xFF4F8065,
                    )
                  : muted,
              fontSize: 9,
            ),
          ),
        ),
        Text(
          amount < 0
              ? '-${_money(amount.abs())}'
              : _money(amount),
          style: TextStyle(
            color: discount
                ? const Color(
                    0xFF4F8065,
                  )
                : dark,
            fontSize: 9,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return const ColoredBox(
      color: Color(0xFFF4F4F4),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: Color(
            0xFFAAAEB5,
          ),
          size: 30,
        ),
      ),
    );
  }

  Widget _emptyCart() {
    return ListView(
      padding:
          const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 60),
        const Icon(
          Icons.shopping_cart_outlined,
          size: 58,
          color: muted,
        ),
        const SizedBox(height: 14),
        const Text(
          'Your cart is empty',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark,
            fontSize: 17,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Start exploring products from approved SARI sellers.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: muted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton(
          onPressed: () =>
              widget.onTabChanged
                  ?.call(1),
          child: const Text(
            'Browse Products',
          ),
        ),
      ],
    );
  }

  Widget _errorState() {
    return ListView(
      padding:
          const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 60),
        const Icon(
          Icons.wifi_off_rounded,
          size: 48,
          color: muted,
        ),
        const SizedBox(height: 12),
        Text(
          _error ??
              'Unable to load cart.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: muted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: _loadCart,
          child: const Text(
            'Try Again',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: canvas,
      body: Column(
        children: [
          BuyerHeader(
            pageTitle:
                'Shopping Cart',
            cartCount:
                _items.length,
            notificationCount: 0,
            onSearchTap: () =>
                widget.onTabChanged
                    ?.call(1),
            onCartTap: () {},
            onNotificationTap: () =>
                widget.onTabChanged
                    ?.call(5),
            onProfileTap: () =>
                widget.onTabChanged
                    ?.call(4),
          ),
          Expanded(
            child: RefreshIndicator(
              color: gold,
              onRefresh:
                  _loadCart,
              child: _loading
                  ? ListView(
    children: const [
      SizedBox(
        height: 180,
      ),
      Center(
        child: CircularProgressIndicator(
          color: gold,
        ),
      ),
    ],
  )
                  : _error != null
                      ? _errorState()
                      : _items.isEmpty
                          ? _emptyCart()
                          : ListView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.fromLTRB(
                                14,
                                18,
                                14,
                                30,
                              ),
                              children: [
                                _pageHeader(),
                                const SizedBox(
                                  height: 15,
                                ),
                                _selectAllToolbar(),
                                const SizedBox(
                                  height: 12,
                                ),
                                ..._sellerGroups.entries
                                    .map(
                                  (entry) =>
                                      _sellerGroup(
                                    entry.key,
                                    entry.value,
                                  ),
                                ),
                                _orderSummary(),
                              ],
                            ),
            ),
          ),
        ],
      ),
    );
  }
}