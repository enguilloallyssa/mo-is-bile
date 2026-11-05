import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'buyer_checkout.dart';
import 'buyer_theme.dart';
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
  final List<BuyerCartItem> _items =
      <BuyerCartItem>[];

  final Set<int> _selected =
      <int>{};

  bool _loading = true;
  bool _previewLoading = false;

  String? _error;
  String? _previewError;

  double _subtotal = 0;
  double _deliveryFee = 0;
  double _shippingDiscount = 0;
  double _grandTotal = 0;

  int _previewVersion = 0;

  @override
  void initState() {
    super.initState();

    _loadCart();
  }

  Map<String, dynamic> _map(
    dynamic value,
  ) {
    return value is Map
        ? Map<String, dynamic>.from(
            value,
          )
        : <String, dynamic>{};
  }

  String _text(
    dynamic value, [
    String fallback = '',
  ]) {
    final String text =
        value?.toString().trim() ?? '';

    return text.isEmpty
        ? fallback
        : text;
  }

  int _integer(dynamic value) {
    return value is num
        ? value.toInt()
        : int.tryParse('$value') ?? 0;
  }

  double _decimal(dynamic value) {
    return value is num
        ? value.toDouble()
        : double.tryParse('$value') ?? 0;
  }

  String _money(double value) {
    return '₱${value.toStringAsFixed(2)}';
  }

  BuyerCartItem _parseItem(
    dynamic raw,
  ) {
    final Map<String, dynamic> data =
        _map(raw);

    final String image =
        _text(
      data['image_url'] ??
          data['image'],
    );

    return BuyerCartItem(
      id: _integer(data['id']),
      productId:
          _integer(data['product_id']),
      variantId:
          data['variant_id'] == null
              ? null
              : _integer(
                  data['variant_id'],
                ),
      storeName: _text(
        data['store_name'],
        'SARI Seller',
      ),
      productName: _text(
        data['name'] ??
            data['product_name'],
        'Product',
      ),
      variantLabel: _text(
        data['variant_label'],
      ),
      image:
          image.isEmpty ? null : image,
      unitPrice:
          _decimal(data['unit_price']),
      serverLineTotal:
          _decimal(data['line_total']),
      quantity:
          _integer(data['quantity']),
      maxStock:
          _integer(data['max_stock']),
      selectable:
          data['selectable'] == true ||
              data['selectable'] == 1 ||
              data['selectable'] == '1',
      availabilityReason:
          _text(
        data['availability_reason'],
      ),
    );
  }

  List<BuyerCartItem>
      get _selectedItems {
    return _items
        .where(
          (BuyerCartItem item) =>
              item.selectable &&
              _selected.contains(
                item.id,
              ),
        )
        .toList();
  }

  Map<String, List<BuyerCartItem>>
      get _groups {
    final Map<String,
            List<BuyerCartItem>>
        groups =
        <String,
            List<BuyerCartItem>>{};

    for (final BuyerCartItem item
        in _items) {
      groups
          .putIfAbsent(
            item.storeName,
            () =>
                <BuyerCartItem>[],
          )
          .add(item);
    }

    return groups;
  }

  bool get _allSelected {
    final Set<int> ids =
        _items
            .where(
              (BuyerCartItem item) =>
                  item.selectable,
            )
            .map(
              (BuyerCartItem item) =>
                  item.id,
            )
            .toSet();

    return ids.isNotEmpty &&
        _selected.length ==
            ids.length &&
        _selected.containsAll(ids);
  }

  Future<void> _loadCart({
    bool loader = true,
  }) async {
    if (loader && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final Map<String, dynamic> response =
          await SariLiveData.instance
              .buyerCart();

      final Map<String, dynamic> data =
          _map(response['data']);

      final List<dynamic> raw =
          data['items'] is List
              ? data['items'] as List
              : const <dynamic>[];

      final List<BuyerCartItem> items =
          raw
              .map(_parseItem)
              .where(
                (BuyerCartItem item) =>
                    item.id > 0,
              )
              .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _items
          ..clear()
          ..addAll(items);

        _selected.removeWhere(
          (int id) =>
              !_items.any(
            (BuyerCartItem item) =>
                item.id == id &&
                item.selectable,
          ),
        );

        _loading = false;
        _error = null;
      });

      await _refreshPreview();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _refreshPreview()
      async {
    final int version =
        ++_previewVersion;

    final List<int> ids =
        _selectedItems
            .map(
              (BuyerCartItem item) =>
                  item.id,
            )
            .toList();

    if (ids.isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _subtotal = 0;
        _deliveryFee = 0;
        _shippingDiscount = 0;
        _grandTotal = 0;
        _previewLoading = false;
        _previewError = null;
      });

      return;
    }

    setState(() {
      _previewLoading = true;
      _previewError = null;
    });

    try {
      final Map<String, dynamic> response =
          await SariLiveData.instance
              .buyerCheckoutPreview(
        ids,
      );

      final Map<String, dynamic> data =
          _map(response['data']);

      final Map<String, dynamic> shipping =
          _map(data['shipping']);

      if (!mounted ||
          version != _previewVersion) {
        return;
      }

      setState(() {
        _subtotal =
            _decimal(data['subtotal']);

        _deliveryFee =
            _decimal(
          shipping['delivery_fee'],
        );

        _shippingDiscount =
            _decimal(
          shipping[
              'shipping_discount'],
        );

        _grandTotal =
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
        _previewError = error.toString();
      });
    }
  }

  void _toggle(
    BuyerCartItem item,
  ) {
    if (!item.selectable) {
      return;
    }

    setState(() {
      if (_selected.contains(
        item.id,
      )) {
        _selected.remove(
          item.id,
        );
      } else {
        _selected.add(
          item.id,
        );
      }
    });

    _refreshPreview();
  }

  void _toggleAll() {
    setState(() {
      if (_allSelected) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..addAll(
            _items
                .where(
                  (BuyerCartItem item) =>
                      item.selectable,
                )
                .map(
                  (BuyerCartItem item) =>
                      item.id,
                ),
          );
      }
    });

    _refreshPreview();
  }

  Future<void> _updateQuantity(
    BuyerCartItem item,
    int quantity,
  ) async {
    if (quantity < 1 ||
        quantity > item.maxStock) {
      return;
    }

    try {
      final Map<String, dynamic> response =
          await SariLiveData.instance
              .buyerUpdateCart(
        item.id,
        quantity,
      );

      _show(
        _text(
          response['message'],
          'Cart updated.',
        ),
      );

      await _loadCart(
        loader: false,
      );
    } catch (error) {
      _show(error.toString());
    }
  }

  Future<void> _remove(
    BuyerCartItem item,
  ) async {
    final bool? confirm =
        await showDialog<bool>(
      context: context,
      builder: (
        BuildContext context,
      ) {
        return AlertDialog(
          title:
              const Text(
            'Remove item?',
          ),
          content: Text(
            'Remove ${item.productName} from your cart?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    BuyerTheme.danger,
              ),
              child:
                  const Text(
                'Remove',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      final Map<String, dynamic> response =
          await SariLiveData.instance
              .buyerRemoveCart(
        item.id,
      );

      _selected.remove(
        item.id,
      );

      _show(
        _text(
          response['message'],
          'Item removed.',
        ),
      );

      await _loadCart(
        loader: false,
      );
    } catch (error) {
      _show(error.toString());
    }
  }

  Future<void> _checkout() async {
    if (_selectedItems.isEmpty ||
        _previewLoading ||
        _previewError != null) {
      return;
    }

    final bool? result =
        await Navigator.of(context)
            .push<bool>(
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
      _selected.clear();

      await _loadCart();
    }
  }

  void _show(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  Widget _hero() {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        0,
      ),
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin: Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors:
              BuyerTheme.heroGradient,
        ),
        borderRadius:
            BorderRadius.circular(23),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'YOUR CART',
                  style: TextStyle(
                    color:
                        Color(0xFFFFD98A),
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 7,
                ),
                const Text(
                  'Ready when\nyou are.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.05,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  '${_items.length} item${_items.length == 1 ? '' : 's'} currently synced with SARI.',
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons
                .shopping_cart_checkout_rounded,
            color: Colors.white,
            size: 45,
          ),
        ],
      ),
    );
  }

  Widget _itemImage(
    BuyerCartItem item,
  ) {
    final String image =
        item.image?.trim() ?? '';

    return Container(
      width: 74,
      height: 74,
      clipBehavior:
          Clip.antiAlias,
      decoration: BoxDecoration(
        color: BuyerTheme.canvas,
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: image.isEmpty
          ? const Icon(
              Icons
                  .inventory_2_outlined,
              color:
                  BuyerTheme.muted,
            )
          : Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) =>
                      const Icon(
                Icons
                    .inventory_2_outlined,
                color:
                    BuyerTheme.muted,
              ),
            ),
    );
  }

  Widget _itemTile(
    BuyerCartItem item,
  ) {
    final bool selected =
        _selected.contains(
      item.id,
    );

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(12),
      decoration:
          BuyerTheme.card(
        radius: 17,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Checkbox(
            value: selected,
            onChanged: item.selectable
                ? (_) {
                    _toggle(item);
                  }
                : null,
          ),

          _itemImage(item),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        BuyerTheme.ink,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                if (item.variantLabel
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    item.variantLabel,
                    style:
                        const TextStyle(
                      color:
                          BuyerTheme.muted,
                      fontSize: 9,
                    ),
                  ),
                ],

                const SizedBox(
                  height: 7,
                ),

                Text(
                  _money(
                    item.unitPrice,
                  ),
                  style:
                      const TextStyle(
                    color:
                        BuyerTheme
                            .goldDark,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w900,
                    fontFamilyFallback:
                        <String>[
                      'Roboto',
                      'Arial',
                      'sans-serif',
                    ],
                  ),
                ),

                if (!item.selectable &&
                    item.availabilityReason
                        .isNotEmpty) ...[
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    item
                        .availabilityReason,
                    style:
                        const TextStyle(
                      color:
                          BuyerTheme.danger,
                      fontSize: 8,
                    ),
                  ),
                ],

                const SizedBox(
                  height: 9,
                ),

                Row(
                  children: <Widget>[
                    _qtyButton(
                      icon:
                          Icons.remove,
                      enabled:
                          item.quantity > 1,
                      onTap: () {
                        _updateQuantity(
                          item,
                          item.quantity -
                              1,
                        );
                      },
                    ),

                    Container(
                      width: 37,
                      alignment:
                          Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
                    ),

                    _qtyButton(
                      icon: Icons.add,
                      enabled:
                          item.quantity <
                              item.maxStock,
                      onTap: () {
                        _updateQuantity(
                          item,
                          item.quantity +
                              1,
                        );
                      },
                    ),

                    const Spacer(),

                    IconButton(
                      tooltip:
                          'Remove item',
                      onPressed: () {
                        _remove(item);
                      },
                      icon:
                          const Icon(
                        Icons
                            .delete_outline_rounded,
                        color:
                            BuyerTheme
                                .danger,
                        size: 20,
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

  Widget _qtyButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 31,
      height: 31,
      child: OutlinedButton(
        onPressed:
            enabled ? onTap : null,
        style:
            OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              9,
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

  Widget _summary() {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        14,
        12,
        14,
        14,
      ),
      padding:
          const EdgeInsets.all(17),
      decoration:
          BuyerTheme.card(),
      child: Column(
        children: <Widget>[
          _summaryRow(
            'Subtotal',
            _money(_subtotal),
          ),

          const SizedBox(
            height: 8,
          ),

          _summaryRow(
            'Delivery fee',
            _money(_deliveryFee),
          ),

          if (_shippingDiscount > 0) ...[
            const SizedBox(
              height: 8,
            ),
            _summaryRow(
              'Shipping discount',
              '-${_money(_shippingDiscount)}',
              positive: true,
            ),
          ],

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Divider(
              height: 1,
            ),
          ),

          _summaryRow(
            'Total',
            _money(_grandTotal),
            strong: true,
          ),

          if (_previewLoading) ...[
            const SizedBox(
              height: 12,
            ),
            const LinearProgressIndicator(),
          ],

          if (_previewError != null) ...[
            const SizedBox(
              height: 10,
            ),
            Text(
              _previewError!,
              style:
                  const TextStyle(
                color:
                    BuyerTheme.danger,
                fontSize: 9,
              ),
            ),
          ],

          const SizedBox(
            height: 15,
          ),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed:
                  _selectedItems.isEmpty ||
                          _previewLoading ||
                          _previewError !=
                              null
                      ? null
                      : _checkout,
              icon:
                  const Icon(
                Icons
                    .arrow_forward_rounded,
              ),
              label: Text(
                _selectedItems.isEmpty
                    ? 'Select Items'
                    : 'Checkout (${_selectedItems.length})',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool strong = false,
    bool positive = false,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: strong
                  ? BuyerTheme.ink
                  : BuyerTheme.muted,
              fontSize:
                  strong ? 13 : 10,
              fontWeight: strong
                  ? FontWeight.w800
                  : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: positive
                ? BuyerTheme.success
                : strong
                    ? BuyerTheme
                        .goldDark
                    : BuyerTheme.ink,
            fontSize:
                strong ? 17 : 11,
            fontWeight: strong
                ? FontWeight.w900
                : FontWeight.w700,
            fontFamilyFallback:
                const <String>[
              'Roboto',
              'Arial',
              'sans-serif',
            ],
          ),
        ),
      ],
    );
  }

  Widget _empty() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.all(28),
      children: <Widget>[
        const SizedBox(
          height: 80,
        ),
        const Icon(
          Icons
              .shopping_cart_outlined,
          size: 60,
          color:
              BuyerTheme.muted,
        ),
        const SizedBox(
          height: 16,
        ),
        const Text(
          'Your cart is empty',
          textAlign:
              TextAlign.center,
          style: TextStyle(
            color: BuyerTheme.ink,
            fontSize: 18,
            fontWeight:
                FontWeight.w900,
          ),
        ),
        const SizedBox(
          height: 7,
        ),
        const Text(
          'Browse SARI products and add something you like.',
          textAlign:
              TextAlign.center,
          style: TextStyle(
            color:
                BuyerTheme.muted,
          ),
        ),
        const SizedBox(
          height: 18,
        ),
        FilledButton.icon(
          onPressed: () {
            widget.onTabChanged
                ?.call(1);
          },
          icon:
              const Icon(
            Icons
                .shopping_bag_outlined,
          ),
          label:
              const Text(
            'Browse Products',
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
      backgroundColor:
          BuyerTheme.canvas,
      body: Column(
        children: <Widget>[
          BuyerHeader(
            pageTitle:
                'Shopping Cart',
            cartCount:
                _items.length,
            notificationCount: 0,
            onSearchTap: () {
              widget.onTabChanged
                  ?.call(1);
            },
            onCartTap: () {},
            onNotificationTap: () {
              widget.onTabChanged
                  ?.call(5);
            },
            onProfileTap: () {
              widget.onTabChanged
                  ?.call(4);
            },
          ),

          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : _error != null &&
                        _items.isEmpty
                    ? RefreshIndicator(
                        onRefresh:
                            _loadCart,
                        child: ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.all(
                            30,
                          ),
                          children: <Widget>[
                            const SizedBox(
                              height: 70,
                            ),
                            const Icon(
                              Icons
                                  .cloud_off_outlined,
                              size: 50,
                              color:
                                  BuyerTheme
                                      .muted,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              _error!,
                              textAlign:
                                  TextAlign
                                      .center,
                            ),
                          ],
                        ),
                      )
                    : _items.isEmpty
                        ? RefreshIndicator(
                            onRefresh:
                                _loadCart,
                            child:
                                _empty(),
                          )
                        : RefreshIndicator(
                            onRefresh:
                                _loadCart,
                            child:
                                ListView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.only(
                                bottom:
                                    25,
                              ),
                              children: <Widget>[
                                _hero(),

                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(
                                    14,
                                    16,
                                    14,
                                    8,
                                  ),
                                  child:
                                      Row(
                                    children: <Widget>[
                                      Checkbox(
                                        value:
                                            _allSelected,
                                        onChanged:
                                            (_) {
                                          _toggleAll();
                                        },
                                      ),
                                      const Expanded(
                                        child:
                                            Text(
                                          'Select all available items',
                                          style:
                                              TextStyle(
                                            color:
                                                BuyerTheme.ink,
                                            fontSize:
                                                11,
                                            fontWeight:
                                                FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ..._groups.entries.map(
                                  (
                                    MapEntry<
                                            String,
                                            List<
                                                BuyerCartItem>>
                                        group,
                                  ) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(
                                        14,
                                        0,
                                        14,
                                        15,
                                      ),
                                      child:
                                          Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(
                                              left:
                                                  3,
                                              bottom:
                                                  8,
                                            ),
                                            child:
                                                Row(
                                              children: <Widget>[
                                                const Icon(
                                                  Icons.storefront_outlined,
                                                  size:
                                                      17,
                                                  color:
                                                      BuyerTheme.goldDark,
                                                ),
                                                const SizedBox(
                                                  width:
                                                      6,
                                                ),
                                                Expanded(
                                                  child:
                                                      Text(
                                                    group.key,
                                                    style:
                                                        const TextStyle(
                                                      color:
                                                          BuyerTheme.ink,
                                                      fontSize:
                                                          12,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ...group.value
                                              .map(
                                            _itemTile,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                _summary(),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}