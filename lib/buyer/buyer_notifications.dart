import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'buyer_order_details.dart';
import 'models/buyer_notification_model.dart';
import 'models/buyer_order_model.dart';

class BuyerNotifications extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;

  const BuyerNotifications({
    super.key,
    this.onTabChanged,
  });

  @override
  State<BuyerNotifications> createState() =>
      _BuyerNotificationsState();
}

class _BuyerNotificationsState
    extends State<BuyerNotifications> {
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

  final List<BuyerNotificationItem>
      _items = [];

  bool _archived = false;

  bool _loading = true;
  bool _loadingMore = false;
  bool _markingAll = false;

  String? _error;

  int _page = 1;
  int _lastPage = 1;
  int _total = 0;

  @override
  void initState() {
    super.initState();

    _load();
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

  BuyerNotificationItem _parseNotification(
    dynamic raw,
  ) {
    final data = _map(raw);

    return BuyerNotificationItem(
      id: _integer(
        data['id'],
      ),
      orderId: _integer(
        data['order_id'],
      ),
      type: _text(
        data['type'],
      ),
      title: _text(
        data['title'],
        'SARI Update',
      ),
      message: _text(
        data['message'],
      ),
      status: _text(
        data['status'],
      ),
      sellerName: _text(
        data['store_name'],
        'SARI Seller',
      ),
      orderNumber: _text(
        data['order_number'],
      ),
      createdAt: _text(
        data['created_at'],
      ),
      isRead:
          data['is_read'] == true,
    );
  }

  Future<void> _load({
    bool loadMore = false,
  }) async {
    if (loadMore &&
        (_loading ||
            _loadingMore ||
            _page >= _lastPage)) {
      return;
    }

    final requestedPage =
        loadMore ? _page + 1 : 1;

    setState(() {
      if (loadMore) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;

        _items.clear();

        _page = 1;
        _lastPage = 1;
        _total = 0;
      }
    });

    try {
      final response =
          await SariLiveData.instance
              .buyerNotifications(
        page: requestedPage,
        perPage: 20,
        archived: _archived,
      );

      final raw =
          response['data'];

      final meta =
          _map(
        response['meta'],
      );

      if (raw is! List) {
        throw const FormatException(
          'Invalid notifications response from SARI.',
        );
      }

      final loaded = raw
          .map(_parseNotification)
          .where(
            (notification) =>
                notification.id > 0,
          )
          .toList();

      if (!mounted) return;

      setState(() {
        final existingIds =
            _items
                .map(
                  (item) =>
                      item.id,
                )
                .toSet();

        for (final item in loaded) {
          if (existingIds.add(
            item.id,
          )) {
            _items.add(item);
          }
        }

        _page = _integer(
          meta['current_page'],
        );

        if (_page <= 0) {
          _page = requestedPage;
        }

        _lastPage = _integer(
          meta['last_page'],
        );

        if (_lastPage <= 0) {
          _lastPage = 1;
        }

        _total = _integer(
          meta['total'],
        );

        _loading = false;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error =
            error.toString();

        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _switchFolder(
    bool archived,
  ) async {
    if (_archived == archived) {
      return;
    }

    setState(() {
      _archived = archived;
    });

    await _load();
  }

  Future<void> _markRead(
    BuyerNotificationItem item,
  ) async {
    if (item.isRead) {
      return;
    }

    try {
      await SariLiveData.instance
          .buyerReadNotification(
        item.id,
      );

      if (!mounted) return;

      setState(() {
        item.isRead = true;
      });
    } catch (error) {
      _message(
        error.toString(),
      );
    }
  }

  Future<void> _markAllRead()
      async {
    if (_archived ||
        _markingAll ||
        !_items.any(
          (item) => !item.isRead,
        )) {
      return;
    }

    setState(() {
      _markingAll = true;
    });

    try {
      final response =
          await SariLiveData.instance
              .buyerReadAllNotifications();

      if (!mounted) return;

      setState(() {
        for (final item in _items) {
          item.isRead = true;
        }
      });

      _message(
        response['message']
                ?.toString() ??
            'Notifications marked as read.',
      );
    } catch (error) {
      _message(
        error.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _markingAll = false;
        });
      }
    }
  }

  BuyerOrderItem _parseOrderItem(
    dynamic raw,
  ) {
    final data = _map(raw);

    return BuyerOrderItem(
      productId: _integer(
        data['product_id'],
      ),
      variantId:
          data['variant_id'] == null
              ? null
              : _integer(
                  data['variant_id'],
                ),
      name: _text(
        data['name'],
        'Product',
      ),
      variantLabel: _text(
        data['variant_label'],
        'Standard',
      ),
      quantity: _integer(
        data['qty'] ??
            data['quantity'],
      ),
      lineTotal: _decimal(
        data['line_total'],
      ),
    );
  }

  BuyerOrder _parseOrder(
    dynamic raw,
  ) {
    final data = _map(raw);

    final rawItems =
        data['items'] is List
            ? data['items'] as List
            : const [];

    final items = rawItems
        .map(
          _parseOrderItem,
        )
        .toList();

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
      buyerName: _text(
        data['buyer_name'],
        'SARI Buyer',
      ),
      buyerPhone: _text(
        data['buyer_phone'],
      ),
      deliveryAddress: _text(
        data['buyer_address'],
      ),
      sellerName: _text(
        data['store_name'],
        'SARI Seller',
      ),
      sellerAccountId: _integer(
        data['seller_id'],
      ),
      items: items,
      productNames: items
          .map(
            (item) => item.name,
          )
          .toList(),
    );
  }

  Future<void> _openNotification(
    BuyerNotificationItem item,
  ) async {
    await _markRead(item);

    if (!item.hasOrder) {
      return;
    }

    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child:
              CircularProgressIndicator(
            color: gold,
          ),
        );
      },
    );

    try {
      final response =
          await SariLiveData.instance
              .buyerOrderDetails(
        item.orderId,
      );

      final raw =
          response['data'];

      if (raw is! Map) {
        throw const FormatException(
          'Invalid order details from SARI.',
        );
      }

      final order =
          _parseOrder(raw);

      if (!mounted) return;

      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();

      await Navigator.of(context)
          .push(
        MaterialPageRoute<void>(
          builder: (_) =>
              BuyerOrderDetails(
            order: order,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();

      _message(
        'Unable to open order: $error',
      );
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

  String _dateTime(
    String raw,
  ) {
    final date =
        DateTime.tryParse(raw)
            ?.toLocal();

    if (date == null) {
      return raw;
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

    final hour =
        date.hour == 0
            ? 12
            : date.hour > 12
                ? date.hour - 12
                : date.hour;

    final minute =
        date.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final meridiem =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '${months[date.month - 1]} '
        '${date.day}, '
        '${date.year} · '
        '$hour:$minute '
        '$meridiem';
  }

  IconData _iconFor(
    BuyerNotificationItem item,
  ) {
    if (item.isCourierUpdate) {
      return Icons
          .local_shipping_outlined;
    }

    if (item.status ==
        'delivered') {
      return Icons
          .check_circle_outline_rounded;
    }

    if (item.status ==
        'cancelled') {
      return Icons
          .cancel_outlined;
    }

    return Icons
        .notifications_none_rounded;
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'BUYER UPDATES',
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
                text: 'Your ',
              ),
              TextSpan(
                text: 'Notifications',
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
    );
  }

  Widget _folderTabs() {
    return Row(
      children: [
        _folderButton(
          label: 'Recent',
          selected:
              !_archived,
          onTap: () =>
              _switchFolder(false),
        ),
        const SizedBox(
          width: 17,
        ),
        _folderButton(
          label: 'Archived',
          selected:
              _archived,
          onTap: () =>
              _switchFolder(true),
        ),
      ],
    );
  }

  Widget _folderButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: Text(
          label,
          style:
              TextStyle(
            color: selected
                ? goldDark
                : muted,
            fontSize: 10,
            fontWeight:
                selected
                    ? FontWeight.w800
                    : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _toolbar() {
    final unreadCount =
        _items
            .where(
              (item) =>
                  !item.isRead,
            )
            .length;

    return Row(
      children: [
        Expanded(
          child: Text(
            _archived
                ? 'Archived Notifications'
                : 'Notifications',
            style:
                const TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),
        Text(
          '$_total ${_total == 1 ? 'notification' : 'notifications'}',
          style:
              const TextStyle(
            color: muted,
            fontSize: 8,
          ),
        ),
        if (!_archived) ...[
          const SizedBox(
            width: 8,
          ),
          TextButton(
            onPressed:
                unreadCount > 0 &&
                        !_markingAll
                    ? _markAllRead
                    : null,
            child: Text(
              _markingAll
                  ? 'Marking...'
                  : 'Mark all as read',
            ),
          ),
        ],
      ],
    );
  }

  Widget _notificationCard(
    BuyerNotificationItem item,
  ) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(13),
      child: InkWell(
        onTap: () =>
            _openNotification(
          item,
        ),
        borderRadius:
            BorderRadius.circular(13),
        child: Container(
          padding:
              const EdgeInsets.all(13),
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
              13,
            ),
            border:
                Border.all(
              color: border,
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
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
                    11,
                  ),
                ),
                child: Icon(
                  _iconFor(item),
                  color: goldDark,
                  size: 21,
                ),
              ),
              const SizedBox(
                width: 11,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style:
                                TextStyle(
                              color: dark,
                              fontSize:
                                  11,
                              fontWeight:
                                  item.isRead
                                      ? FontWeight.w700
                                      : FontWeight.w800,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 7,
                            height: 7,
                            decoration:
                                const BoxDecoration(
                              color:
                                  gold,
                              shape:
                                  BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      item.message,
                      style:
                          const TextStyle(
                        color: muted,
                        fontSize: 9,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (item
                            .orderNumber
                            .isNotEmpty)
                          _metaText(
                            item.orderNumber,
                          ),
                        _metaText(
                          item.sellerName,
                        ),
                        _metaText(
                          _dateTime(
                            item.createdAt,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.hasOrder)
                const Padding(
                  padding:
                      EdgeInsets.only(
                    left: 5,
                    top: 7,
                  ),
                  child: Icon(
                    Icons
                        .chevron_right_rounded,
                    color: muted,
                    size: 19,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaText(
    String value,
  ) {
    return Text(
      value,
      style:
          const TextStyle(
        color: Color(
          0xFF948C83,
        ),
        fontSize: 7.5,
        fontWeight:
            FontWeight.w500,
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 26,
        vertical: 36,
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
            Icons.history_rounded,
            color: muted,
            size: 48,
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            _archived
                ? 'No archived notifications'
                : 'No notifications yet',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
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
            _archived
                ? 'Archived notifications will appear here.'
                : 'Order and shipping updates will appear here as your purchases move through fulfillment and delivery.',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: muted,
              fontSize: 9,
              height: 1.5,
            ),
          ),
          if (!_archived &&
              widget.onTabChanged !=
                  null) ...[
            const SizedBox(
              height: 16,
            ),
            OutlinedButton(
              onPressed: () =>
                  widget.onTabChanged
                      ?.call(1),
              child:
                  const Text(
                'Browse Products',
              ),
            ),
          ],
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
            height: 12,
          ),
          const Text(
            'Unable to load notifications',
            style:
                TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 7,
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
            onPressed: () =>
                _load(),
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
    return Scaffold(
      backgroundColor: canvas,
      body: RefreshIndicator(
        color: gold,
        onRefresh: () =>
            _load(),
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
            _header(),

            const SizedBox(
              height: 16,
            ),

            _folderTabs(),

            const SizedBox(
              height: 12,
            ),

            if (!_loading &&
                _error == null &&
                _items.isNotEmpty)
              _toolbar(),

            if (!_loading &&
                _error == null &&
                _items.isNotEmpty)
              const SizedBox(
                height: 10,
              ),

            if (_loading)
              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  vertical: 70,
                ),
                child: Center(
                  child:
                      CircularProgressIndicator(
                    color: gold,
                  ),
                ),
              )
            else if (_error != null)
              _errorState()
            else if (_items.isEmpty)
              _emptyState()
            else ...[
              ..._items.map(
                (item) =>
                    Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 9,
                  ),
                  child:
                      _notificationCard(
                    item,
                  ),
                ),
              ),

              if (_page < _lastPage)
                Padding(
                  padding:
                      const EdgeInsets.only(
                    top: 7,
                  ),
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        _loadingMore
                            ? null
                            : () =>
                                _load(
                                  loadMore:
                                      true,
                                ),
                    icon:
                        _loadingMore
                            ? const SizedBox(
                                width:
                                    16,
                                height:
                                    16,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .expand_more_rounded,
                              ),
                    label: Text(
                      _loadingMore
                          ? 'Loading...'
                          : 'Load More',
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}