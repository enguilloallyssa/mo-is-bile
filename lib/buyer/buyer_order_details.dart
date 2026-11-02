
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/sari_live_data.dart';
import 'models/buyer_order_model.dart';

class BuyerOrderDetails extends StatefulWidget {
  final BuyerOrder order;
  final VoidCallback? onContactSupport;
  final VoidCallback? onMessageSeller;

  const BuyerOrderDetails({
    super.key,
    required this.order,
    this.onContactSupport,
    this.onMessageSeller,
  });

  @override
  State<BuyerOrderDetails> createState() =>
      _BuyerOrderDetailsState();
}

class _BuyerOrderDetailsState
    extends State<BuyerOrderDetails> {
  static const Color gold = Color(0xFFD9950B);
  static const Color dark = Color(0xFF292929);
  static const Color canvas = Color(0xFFF4F5F7);
  static const Color border = Color(0xFFE6E8EC);
  static const Color muted = Color(0xFF818A97);

  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  String _text(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final result = value.toString().trim();
    return result.isEmpty ? fallback : result;
  }

  double? _amount(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  String _peso(dynamic value) {
    final amount = _amount(value);
    if (amount == null) return 'Not available';
    return '₱${amount.toStringAsFixed(2)}';
  }

  String _date(dynamic value) {
    final raw = _text(value);
    if (raw.isEmpty) return 'Not available';

    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return raw;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'May', 'Jun', 'Jul', 'Aug',
      'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year}';
  }

  String _formatStatus(String value) {
    if (value.isEmpty) return 'Unknown';

    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) =>
            '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  Future<void> _loadDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response =
          await SariLiveData.instance.buyerOrderDetails(
        widget.order.id,
      );

      final data = _asMap(response['data']);

      if (data.isEmpty ||
          int.tryParse(_text(data['id'])) != widget.order.id) {
        throw const FormatException(
          'Invalid order details received from Laravel.',
        );
      }

      if (!mounted) return;

      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _copyOrderNumber() async {
    final number = _text(_data?['order_number']);

    if (number.isEmpty) return;

    await Clipboard.setData(
      ClipboardData(text: number),
    );

    if (mounted) {
      _notify('Order number copied');
    }
  }

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(icon, color: gold, size: 21),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    bool emphasize = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: emphasize ? gold : dark,
                fontSize: emphasize ? 16 : 12,
                fontWeight: emphasize
                    ? FontWeight.w800
                    : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderOverview(Map<String, dynamic> data) {
    final status = _text(data['status']);
    final label = _text(
      data['status_label'],
      _formatStatus(status),
    );

    final statusColor = status == 'delivered'
        ? const Color(0xFF208451)
        : status == 'cancelled'
            ? const Color(0xFFC23D3D)
            : gold;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDER SUMMARY',
            style: TextStyle(
              color: gold,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _text(data['order_number']),
                  style: const TextStyle(
                    color: dark,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy order number',
                onPressed: _copyOrderNumber,
                icon: const Icon(
                  Icons.copy_outlined,
                  size: 19,
                  color: muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'Placed on ${_date(data['created_at'])}',
            style: const TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  status == 'delivered'
                      ? Icons.check_circle_outline
                      : status == 'cancelled'
                          ? Icons.cancel_outlined
                          : Icons.local_shipping_outlined,
                  color: statusColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_text(data['delivered_at']).isNotEmpty) ...[
            const SizedBox(height: 14),
            _infoRow(
              'Delivered On',
              _date(data['delivered_at']),
            ),
          ],
        ],
      ),
    );
  }

  Widget _shippingInformation(
    Map<String, dynamic> data,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.location_on_outlined,
            'Delivery Information',
          ),
          const SizedBox(height: 14),
          const Divider(color: border),
          _infoRow(
            'Recipient',
            _text(data['buyer_name'], 'Not available'),
          ),
          _infoRow(
            'Contact',
            _text(data['buyer_phone'], 'Not available'),
          ),
          const SizedBox(height: 9),
          const Text(
            'Delivery Address',
            style: TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _text(
              data['buyer_address'],
              'No delivery address available.',
            ),
            style: const TextStyle(
              color: dark,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sellerInformation(
    Map<String, dynamic> data,
  ) {
    return _card(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2D8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: gold,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SOLD BY',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _text(
                    data['store_name'],
                    'Store information unavailable',
                  ),
                  style: const TextStyle(
                    color: dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productItems(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = rawItems is List ? rawItems : <dynamic>[];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.inventory_2_outlined,
            'Ordered Products',
          ),
          const SizedBox(height: 14),
          const Divider(color: border),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No item details returned by Laravel.',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            )
          else
            ...items.map((raw) {
              final item = _asMap(raw);

              final name = _text(
                item['name'] ?? item['product_name'],
                'Product',
              );

              final quantity =
                  int.tryParse(_text(item['quantity'])) ?? 0;

              final total = item['line_total'] ?? item['total'];
              final variant = _text(item['variant_label']);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: canvas,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: gold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: dark,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (variant.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              variant,
                              style: const TextStyle(
                                color: muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          const SizedBox(height: 5),
                          Text(
                            'Quantity: $quantity',
                            style: const TextStyle(
                              color: muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _peso(total),
                      style: const TextStyle(
                        color: gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _paymentSummary(Map<String, dynamic> data) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.receipt_long_outlined,
            'Payment Summary',
          ),
          const SizedBox(height: 14),
          const Divider(color: border),
          _infoRow(
            'Payment Method',
            _formatStatus(
              _text(data['payment_method']),
            ),
          ),
          _infoRow(
            'Payment Status',
            _formatStatus(
              _text(data['payment_status']),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: border),
          _infoRow('Subtotal', _peso(data['subtotal'])),
          _infoRow('Delivery Fee', _peso(data['delivery_fee'])),
          const Divider(color: border),
          _infoRow(
            'Order Total',
            _peso(data['total']),
            emphasize: true,
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: muted,
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to Load Order',
                style: TextStyle(
                  color: dark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: dark,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: dark,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: gold,
              ),
            )
          : _error != null
              ? _errorState()
              : RefreshIndicator(
                  color: gold,
                  onRefresh: _loadDetails,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      14, 18, 14, 30,
                    ),
                    children: [
                      _orderOverview(_data!),
                      const SizedBox(height: 12),
                      _sellerInformation(_data!),
                      const SizedBox(height: 12),
                      _productItems(_data!),
                      const SizedBox(height: 12),
                      _shippingInformation(_data!),
                      const SizedBox(height: 12),
                      _paymentSummary(_data!),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Order information is retrieved '
                          'from the SARI Laravel API.',
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
    );
  }
}
