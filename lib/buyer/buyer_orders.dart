import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/sari_live_data.dart';
import 'buyer_order_details.dart';
import 'models/buyer_order_model.dart';
import 'widgets/buyer_header.dart';

class BuyerOrders extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;

  const BuyerOrders({
    super.key,
    this.onTabChanged,
  });

  @override
  State<BuyerOrders> createState() =>
      _BuyerOrdersState();
}

class _BuyerOrdersState
    extends State<BuyerOrders> {
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

  final TextEditingController
      _searchController =
      TextEditingController();

  final List<BuyerOrder> _orders = [];

  bool _loading = true;

  String? _error;

  String _filter = 'all';

  @override
  void initState() {
    super.initState();

    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
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

  int _integer(
    dynamic value,
  ) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse('$value') ?? 0;
  }

  double _decimal(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse('$value') ?? 0;
  }

  BuyerOrder _parseOrder(
    dynamic raw,
  ) {
    final data = _map(raw);

    return BuyerOrder(
      id: _integer(
        data['id'],
      ),
      orderNumber: _text(
        data['order_number'],
      ),
      status: _text(
        data['status'],
      ),
      apiStatusLabel: _text(
        data['status_label'],
      ),
      paymentMethod: _text(
        data['payment_method'],
        'Not specified',
      ),
      paymentStatus: _text(
        data['payment_status'],
        'pending',
      ),
      subtotal: _decimal(
        data['subtotal'],
      ),
      deliveryFee: _decimal(
        data['delivery_fee'],
      ),
      totalAmount: _decimal(
        data['total'],
      ),
      createdAt: _text(
        data['created_at'],
      ),
      deliveredAt: _text(
        data['delivered_at'],
      ),
      sellerName: _text(
        data['store_name'],
        'SARI Seller',
      ),
      sellerAccountId:
          _integer(
        data['seller_id'],
      ),
      latestUpdateTime: _text(
        data['created_at'],
      ),
      latestUpdateMessage: _text(
        data['status_label'],
      ),
    );
  }

  Future<void> _loadOrders()
      async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final firstResponse =
          await SariLiveData.instance
              .buyerOrders(
        page: 1,
        perPage: 30,
      );

      final allRows =
          <dynamic>[];

      if (firstResponse['data']
          is List) {
        allRows.addAll(
          firstResponse['data']
              as List,
        );
      }

      final meta =
          _map(
        firstResponse['meta'],
      );

      final lastPage =
          _integer(
        meta['last_page'],
      );

      if (lastPage > 1) {
        for (var page = 2;
            page <= lastPage;
            page++) {
          final response =
              await SariLiveData.instance
                  .buyerOrders(
            page: page,
            perPage: 30,
          );

          if (response['data']
              is List) {
            allRows.addAll(
              response['data']
                  as List,
            );
          }
        }
      }

      final orders = allRows
          .map(_parseOrder)
          .where(
            (order) =>
                order.id > 0,
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _orders
          ..clear()
          ..addAll(orders);

        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            error.toString();
      });
    }
  }

  List<BuyerOrder>
      get _filteredOrders {
    final search =
        _searchController.text
            .trim()
            .toLowerCase();

    return _orders.where(
      (order) {
        final filterMatch =
            _filter == 'all' ||
                order.filterGroup ==
                    _filter;

        final searchMatch =
            search.isEmpty ||
                order.orderNumber
                    .toLowerCase()
                    .contains(
                      search,
                    ) ||
                order.statusLabel
                    .toLowerCase()
                    .contains(
                      search,
                    ) ||
                order.sellerName
                    .toLowerCase()
                    .contains(
                      search,
                    );

        return filterMatch &&
            searchMatch;
      },
    ).toList();
  }

  int get _toShipCount {
    return _orders
        .where(
          (order) =>
              order.filterGroup ==
              'to-ship',
        )
        .length;
  }

  int get _inTransitCount {
    return _orders
        .where(
          (order) =>
              order.filterGroup ==
              'in-transit',
        )
        .length;
  }

  int get _deliveredCount {
    return _orders
        .where(
          (order) =>
              order.status ==
              'delivered',
        )
        .length;
  }

  Future<void> _openOrder(
    BuyerOrder order,
  ) async {
    final changed =
        await Navigator.of(context)
            .push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            BuyerOrderDetails(
          order: order,
        ),
      ),
    );

    if (changed == true &&
        mounted) {
      await _loadOrders();
    }
  }

  Future<void> _copyOrderNumber(
    BuyerOrder order,
  ) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            order.orderNumber,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Order number copied.',
          ),
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

  String _date(
    String raw,
  ) {
    final value =
        DateTime.tryParse(raw)
            ?.toLocal();

    if (value == null) {
      return raw.isEmpty
          ? 'Not available'
          : raw;
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[value.month - 1]} '
        '${value.day}, '
        '${value.year}';
  }

  Color _statusColor(
    String status,
  ) {
    if (status == 'delivered') {
      return const Color(
        0xFF4F8065,
      );
    }

    if (status == 'cancelled') {
      return const Color(
        0xFFCC4D4D,
      );
    }

    return goldDark;
  }

  Widget _pageHeading() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'SARI MARKETPLACE',
                style: TextStyle(
                  color: goldDark,
                  fontSize: 8,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'My ',
                    ),
                    TextSpan(
                      text: 'Orders',
                      style: TextStyle(
                        color: gold,
                      ),
                    ),
                  ],
                ),
                style: TextStyle(
                  color: dark,
                  fontSize: 27,
                  height: 1.08,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () =>
              widget.onTabChanged
                  ?.call(1),
          child: const Text(
            'Continue Shopping >',
          ),
        ),
      ],
    );
  }

  Widget _summary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: border,
        ),
      ),
      clipBehavior:
          Clip.antiAlias,
      child: Row(
        children: [
          _summaryCell(
            'Total Orders',
            _orders.length,
          ),
          _summaryDivider(),
          _summaryCell(
            'To Ship',
            _toShipCount,
          ),
          _summaryDivider(),
          _summaryCell(
            'In Transit',
            _inTransitCount,
          ),
          _summaryDivider(),
          _summaryCell(
            'Delivered',
            _deliveredCount,
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Container(
      width: 1,
      height: 50,
      color: border,
    );
  }

  Widget _summaryCell(
    String label,
    int value,
  ) {
    return Expanded(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 4,
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style:
                  const TextStyle(
                color: dark,
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              label,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: muted,
                fontSize: 7.5,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filters() {
    const filters =
        <String, String>{
      'all': 'All',
      'to-ship': 'To Ship',
      'in-transit':
          'In Transit',
      'delivered':
          'Delivered',
      'cancelled':
          'Cancelled',
    };

    return Column(
      children: [
        TextField(
          controller:
              _searchController,
          onChanged: (_) {
            setState(() {});
          },
          decoration:
              const InputDecoration(
            hintText:
                'Search order number or status...',
            prefixIcon: Icon(
              Icons.search_rounded,
            ),
          ),
        ),
        const SizedBox(
          height: 11,
        ),
        SizedBox(
          height: 36,
          child:
              ListView.separated(
            scrollDirection:
                Axis.horizontal,
            itemCount:
                filters.length,
            separatorBuilder:
                (_, __) =>
                    const SizedBox(
              width: 7,
            ),
            itemBuilder:
                (_, index) {
              final entry =
                  filters.entries
                      .elementAt(
                index,
              );

              final selected =
                  _filter ==
                      entry.key;

              return ChoiceChip(
                label:
                    Text(
                  entry.value,
                ),
                selected:
                    selected,
                selectedColor:
                    const Color(
                  0xFFFFF1D3,
                ),
                backgroundColor:
                    Colors.white,
                side:
                    BorderSide(
                  color: selected
                      ? gold
                      : border,
                ),
                labelStyle:
                    TextStyle(
                  color: selected
                      ? goldDark
                      : dark,
                  fontSize: 9,
                  fontWeight:
                      selected
                          ? FontWeight
                              .w700
                          : FontWeight
                              .w500,
                ),
                onSelected: (_) {
                  setState(() {
                    _filter =
                        entry.key;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _orderCard(
    BuyerOrder order,
  ) {
    final statusColor =
        _statusColor(
      order.status,
    );

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: border,
        ),
      ),
      clipBehavior:
          Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.all(
              13,
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
                const Icon(
                  Icons
                      .storefront_outlined,
                  color: goldDark,
                  size: 18,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    order.sellerName,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      color: dark,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color: statusColor
                        .withOpacity(
                      .10,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child: Text(
                    order.statusLabel,
                    style:
                        TextStyle(
                      color:
                          statusColor,
                      fontSize: 8,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.all(
              14,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            order
                                .orderNumber,
                            style:
                                const TextStyle(
                              color:
                                  dark,
                              fontSize:
                                  13,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                          const SizedBox(
                            height:
                                3,
                          ),
                          Text(
                            'Placed on ${_date(order.createdAt)}',
                            style:
                                const TextStyle(
                              color:
                                  muted,
                              fontSize:
                                  8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip:
                          'Copy order number',
                      onPressed: () =>
                          _copyOrderNumber(
                        order,
                      ),
                      icon:
                          const Icon(
                        Icons
                            .copy_outlined,
                        color:
                            muted,
                        size:
                            18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                _detailRow(
                  'Payment',
                  order.paymentMethod,
                ),
                const SizedBox(
                  height: 7,
                ),
                _detailRow(
                  'Payment Status',
                  order.paymentStatus,
                ),
                const SizedBox(
                  height: 7,
                ),
                _detailRow(
                  'Delivery Fee',
                  _money(
                    order.deliveryFee,
                  ),
                ),
                const SizedBox(
                  height: 13,
                ),
                const Divider(
                  color: border,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Order Total',
                        style:
                            TextStyle(
                          color:
                              dark,
                          fontSize:
                              10,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                    ),
                    Text(
                      _money(
                        order
                            .resolvedTotal,
                      ),
                      style:
                          const TextStyle(
                        color:
                            goldDark,
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 14,
                ),
                SizedBox(
                  width:
                      double.infinity,
                  child:
                      ElevatedButton.icon(
                    onPressed: () =>
                        _openOrder(
                      order,
                    ),
                    icon:
                        const Icon(
                      Icons
                          .visibility_outlined,
                      size: 17,
                    ),
                    label:
                        const Text(
                      'View Order Details',
                    ),
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          dark,
                      foregroundColor:
                          Colors.white,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 13,
                      ),
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

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style:
                const TextStyle(
              color: muted,
              fontSize: 9,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign:
                TextAlign.right,
            style:
                const TextStyle(
              color: dark,
              fontSize: 9,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        28,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border:
            Border.all(
          color: border,
        ),
      ),
      child:
          const Column(
        children: [
          Icon(
            Icons
                .receipt_long_outlined,
            size: 46,
            color: muted,
          ),
          SizedBox(height: 12),
          Text(
            'No orders found',
            style: TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'No orders match your current search or filter.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        26,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border:
            Border.all(
          color: border,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: muted,
            size: 44,
          ),
          const SizedBox(
            height: 11,
          ),
          const Text(
            'Unable to load orders',
            style: TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            _error ??
                'Please try again.',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: muted,
              fontSize: 9,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          OutlinedButton.icon(
            onPressed:
                _loadOrders,
            icon:
                const Icon(
              Icons.refresh_rounded,
            ),
            label:
                const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final filtered =
        _filteredOrders;

    return Scaffold(
      backgroundColor: canvas,
      body: Column(
        children: [
          BuyerHeader(
            pageTitle: 'My Orders',
            cartCount: 0,
            notificationCount: 0,
            onSearchTap: () {},
            onCartTap: () =>
                widget.onTabChanged
                    ?.call(2),
            onNotificationTap: () =>
                widget.onTabChanged
                    ?.call(5),
            onProfileTap: () =>
                widget.onTabChanged
                    ?.call(4),
          ),
          Expanded(
            child:
                RefreshIndicator(
              color: gold,
              onRefresh:
                  _loadOrders,
              child: ListView(
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
                  _pageHeading(),
                  const SizedBox(
                    height: 16,
                  ),
                  if (!_loading &&
                      _error == null)
                    _summary(),
                  const SizedBox(
                    height: 16,
                  ),
                  _filters(),
                  const SizedBox(
                    height: 16,
                  ),
                  if (_loading)
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        vertical: 60,
                      ),
                      child:
                          Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              gold,
                        ),
                      ),
                    )
                  else if (_error !=
                      null)
                    _errorState()
                  else if (filtered
                      .isEmpty)
                    _emptyState()
                  else
                    ...filtered.map(
                      _orderCard,
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