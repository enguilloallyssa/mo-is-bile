
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/sari_live_data.dart';
import 'models/buyer_order_model.dart';
import 'widgets/buyer_header.dart';
import 'buyer_order_details.dart';

class BuyerOrders extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;

  const BuyerOrders({
    super.key,
    this.onTabChanged,
  });

  @override
  State<BuyerOrders> createState() => _BuyerOrdersState();
}

class _BuyerOrdersState extends State<BuyerOrders> {
  static const Color gold = Color(0xFFD9950B);
  static const Color dark = Color(0xFF292929);
  static const Color canvas = Color(0xFFF4F5F7);
  static const Color border = Color(0xFFE6E8EC);
  static const Color muted = Color(0xFF818A97);

  final TextEditingController _searchController =
      TextEditingController();

  final List<BuyerOrder> _orders = [];

  String _filter = 'all';
  String? _error;

  bool _loading = true;
  bool _loadingMore = false;

  int _page = 1;
  int _totalOrders = 0;
  bool _hasMore = true;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _requestVersion++;
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  List<dynamic> _list(dynamic value) {
    return value is List ? value : [];
  }

  String _text(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    return value.toString();
  }

  int _number(dynamic value) {
    return int.tryParse(_text(value)) ?? 0;
  }

  double _amount(dynamic value) {
    return double.tryParse(_text(value)) ?? 0;
  }

  String _money(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  String _date(String value) {
    final date = DateTime.tryParse(value)?.toLocal();

    if (date == null) {
      return value.isEmpty ? 'Not available' : value;
    }

    final month = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'May', 'Jun', 'Jul', 'Aug',
      'Sep', 'Oct', 'Nov', 'Dec',
    ][date.month - 1];

    return '$month ${date.day}, ${date.year}';
  }

  BuyerOrder _parseOrder(dynamic raw) {
    final data = _map(raw);
    final rawItems = _list(data['items']);

    final items = rawItems.map((raw) {
      final item = _map(raw);

      return BuyerOrderItem(
        name: _text(
          item['name'] ?? item['product_name'],
          'Product',
        ),
        variantLabel: _text(
          item['variant_label'],
          'Standard',
        ),
        quantity: _number(item['quantity']),
        lineTotal: _amount(
          item['line_total'] ?? item['total'],
        ),
        image: _text(item['image_url']).isEmpty
            ? null
            : _text(item['image_url']),
      );
    }).toList();

    return BuyerOrder(
      id: _number(data['id']),
      orderNumber: _text(data['order_number']),
      status: _text(data['status'], 'unknown'),
      paymentMethod: _text(
        data['payment_method'],
        'Not specified',
      ),
      paymentStatus: _text(
        data['payment_status'],
        'unknown',
      ),
      subtotal: _amount(data['subtotal']),
      deliveryFee: _amount(data['delivery_fee']),
      totalAmount: data['total'] == null
          ? null
          : _amount(data['total']),
      createdAt: _text(data['created_at']),
      expectedDelivery: '',
      latestUpdateTime: _text(data['created_at']),
      latestUpdateMessage: _text(
        data['status_label'],
        _text(data['status']),
      ),
      courierName: 'Not available via mobile API',
      courierRating: 0,
      courierDeliveries: 0,
      deliveryAddress: _text(data['buyer_address']),
      buyerName: _text(data['buyer_name'], 'Buyer'),
      buyerPhone: _text(data['buyer_phone']),
      sellerName: _text(
        data['store_name'],
        'Store',
      ),
      sellerAccountId: _number(data['seller_id']),
      productNames: items.map((e) => e.name).toList(),
      items: items,
      deliveredAt: _text(data['delivered_at']),
    );
  }

  Future<void> _loadOrders({
    bool loadMore = false,
  }) async {
    if (loadMore &&
        (_loading || _loadingMore || !_hasMore)) {
      return;
    }

    final version = loadMore
        ? _requestVersion
        : ++_requestVersion;

    final requestedPage = loadMore ? _page + 1 : 1;

    setState(() {
      _error = null;

      if (loadMore) {
        _loadingMore = true;
      } else {
        _loading = true;
        _orders.clear();
        _page = 1;
        _totalOrders = 0;
        _hasMore = true;
      }
    });

    try {
      final response =
          await SariLiveData.instance.buyerOrders(
        page: requestedPage,
        perPage: 15,
      );

      final records = _list(response['data']);
      final meta = _map(response['meta']);

      final loaded = records
          .map(_parseOrder)
          .where((order) => order.id > 0)
          .toList();

      if (!mounted || version != _requestVersion) return;

      setState(() {
        final existingIds =
            _orders.map((order) => order.id).toSet();

        for (final order in loaded) {
          if (existingIds.add(order.id)) {
            _orders.add(order);
          }
        }

        _page = requestedPage;

        _totalOrders = _number(meta['total']);

        final lastPage = _number(meta['last_page']);

        _hasMore = lastPage > 0
            ? requestedPage < lastPage
            : records.length == 15;

        _loading = false;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted || version != _requestVersion) return;

      setState(() {
        _error = error.toString();
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  List<BuyerOrder> get _filteredOrders {
    final search =
        _searchController.text.trim().toLowerCase();

    return _orders.where((order) {
      final matchesFilter =
          _filter == 'all' ||
          order.filterGroup == _filter;

      final matchesSearch = search.isEmpty ||
          order.orderNumber.toLowerCase().contains(search) ||
          order.sellerName.toLowerCase().contains(search) ||
          order.statusLabel.toLowerCase().contains(search);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  Future<void> _openDetails(BuyerOrder order) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: gold),
      ),
    );

    try {
      final response =
          await SariLiveData.instance.buyerOrderDetails(
        order.id,
      );

      final raw = _map(response['data']);

      if (_number(raw['id']) != order.id) {
        throw const FormatException(
          'Invalid order details received.',
        );
      }

      final details = _parseOrder(raw);

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BuyerOrderDetails(
            order: details,
            onContactSupport: () {
              _message(
                'Mobile support API is not yet available.',
              );
            },
            onMessageSeller: () {
              _message(
                'Mobile messaging API is not yet available.',
              );
            },
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      _message('Unable to load order details: $error');
    }
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _copyOrderNumber(
    BuyerOrder order,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: order.orderNumber),
    );

    _message('Order number copied');
  }

  Widget _panel(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MY PURCHASES',
                style: TextStyle(
                  color: gold,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'My Orders',
                style: TextStyle(
                  color: dark,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'View your purchases and order updates.',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2D5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            color: gold,
            size: 27,
          ),
        ),
      ],
    );
  }

  Widget _summary() {
    final active = _orders
        .where((order) =>
            order.filterGroup == 'to-ship' ||
            order.filterGroup == 'in-transit')
        .length;

    final delivered = _orders
        .where((order) =>
            order.status == 'delivered')
        .length;

    return Row(
      children: [
        _summaryItem(
          'Total',
          _totalOrders,
          Icons.shopping_bag_outlined,
        ),
        const SizedBox(width: 8),
        _summaryItem(
          'Active',
          active,
          Icons.local_shipping_outlined,
        ),
        const SizedBox(width: 8),
        _summaryItem(
          'Delivered',
          delivered,
          Icons.check_circle_outline,
        ),
      ],
    );
  }

  Widget _summaryItem(
    String label,
    int count,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Icon(icon, color: gold, size: 21),
            const SizedBox(height: 9),
            Text(
              '$count',
              style: const TextStyle(
                color: dark,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filters() {
    const filters = <String, String>{
      'all': 'All Orders',
      'to-ship': 'To Ship',
      'in-transit': 'In Transit',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
    };

    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search order number or store...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 13,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: border),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: filters.entries.map((entry) {
              final selected = _filter == entry.key;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(entry.value),
                  selected: selected,
                  selectedColor: const Color(0xFFFFF0CF),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: selected ? gold : border,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? gold : dark,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _filter = entry.key;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    if (status == 'delivered') {
      return const Color(0xFF16834B);
    }

    if (status == 'cancelled') {
      return const Color(0xFFC0392B);
    }

    return const Color(0xFFBA800F);
  }

  Widget _orderCard(BuyerOrder order) {
    final statusColor = _statusColor(order.status);

    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 21,
                color: gold,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.sellerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Divider(color: border),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderNumber,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy order number',
                onPressed: () => _copyOrderNumber(order),
                icon: const Icon(
                  Icons.copy_outlined,
                  size: 18,
                  color: muted,
                ),
              ),
            ],
          ),
          Text(
            'Placed on ${_date(order.createdAt)}',
            style: const TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
          _detailRow(
            'Payment',
            order.paymentMethod,
          ),
          const SizedBox(height: 8),
          _detailRow(
            'Payment Status',
            order.paymentStatus,
          ),
          const SizedBox(height: 8),
          _detailRow(
            'Delivery Fee',
            _money(order.deliveryFee),
          ),
          const SizedBox(height: 13),
          const Divider(color: border),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Order Total',
                  style: TextStyle(
                    color: dark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                order.totalAmount == null
                    ? 'Not available'
                    : _money(order.totalAmount!),
                style: const TextStyle(
                  color: gold,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openDetails(order),
              icon: const Icon(
                Icons.visibility_outlined,
                size: 18,
              ),
              label: const Text(
                'View Order Details',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: dark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: muted,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              color: dark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return _panel(
      Column(
        children: [
          const SizedBox(height: 22),
          const Icon(
            Icons.inventory_2_outlined,
            color: muted,
            size: 48,
          ),
          const SizedBox(height: 13),
          const Text(
            'No orders found',
            style: TextStyle(
              color: dark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No matching orders are currently loaded.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () =>
                widget.onTabChanged?.call(1),
            icon: const Icon(
              Icons.shopping_bag_outlined,
            ),
            label: const Text('Browse Products'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _errorState() {
    return _panel(
      Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 45,
            color: muted,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load orders',
            style: TextStyle(
              color: dark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => _loadOrders(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      body: Column(
        children: [
          BuyerHeader(
            pageTitle: 'My Orders',
            cartCount: 0,
            onSearchTap: () {},
            onCartTap: () =>
                widget.onTabChanged?.call(2),
            onProfileTap: () =>
                widget.onTabChanged?.call(4),
          ),
          Expanded(
            child: RefreshIndicator(
              color: gold,
              onRefresh: () => _loadOrders(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  14, 18, 14, 30,
                ),
                children: [
                  _header(),
                  const SizedBox(height: 18),
                  _summary(),
                  const SizedBox(height: 18),
                  _filters(),
                  const SizedBox(height: 18),

                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(45),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: gold,
                        ),
                      ),
                    )
                  else if (_error != null &&
                      _orders.isEmpty)
                    _errorState()
                  else if (_filteredOrders.isEmpty)
                    _emptyState()
                  else
                    ..._filteredOrders.map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: _orderCard(order),
                      ),
                    ),

                  if (_error != null &&
                      _orders.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: Text(
                        'Unable to load more: $_error',
                        textAlign: TextAlign.center,
                      ),
                    ),

                  if (!_loading && _hasMore)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 12,
                      ),
                      child: OutlinedButton.icon(
                        onPressed: _loadingMore
                            ? null
                            : () => _loadOrders(
                                  loadMore: true,
                                ),
                        icon: _loadingMore
                            ? const SizedBox(
                                height: 17,
                                width: 17,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.expand_more,
                              ),
                        label: Text(
                          _loadingMore
                              ? 'Loading...'
                              : 'Load More Orders',
                        ),
                      ),
                    ),

                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'Orders are retrieved from your '
                      'Laravel Buyer account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
  