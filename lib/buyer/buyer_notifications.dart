import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'buyer_order_details.dart';
import 'buyer_theme.dart';
import 'models/buyer_notification_model.dart';
import 'models/buyer_order_model.dart';
import 'widgets/buyer_header.dart';

class BuyerNotifications
    extends StatefulWidget {
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
  final List<BuyerNotificationItem>
      _items =
      <BuyerNotificationItem>[];

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

  // ============================================================
  // HELPERS
  // ============================================================

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

  int _integer(
    dynamic value,
  ) {
    return value is num
        ? value.toInt()
        : int.tryParse(
              '$value',
            ) ??
            0;
  }

  double _decimal(
    dynamic value,
  ) {
    return value is num
        ? value.toDouble()
        : double.tryParse(
              '$value',
            ) ??
            0;
  }

  String _dateTime(
    String raw,
  ) {
    final DateTime? date =
        DateTime.tryParse(
      raw,
    )?.toLocal();

    if (date == null) {
      return raw;
    }

    const List<String> months =
        <String>[
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

    final int hour =
        date.hour == 0
            ? 12
            : date.hour > 12
                ? date.hour - 12
                : date.hour;

    final String minute =
        date.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String period =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year} • '
        '$hour:$minute $period';
  }

  // ============================================================
  // PARSERS
  // ============================================================

  BuyerNotificationItem
      _parseNotification(
    dynamic raw,
  ) {
    final Map<String, dynamic> data =
        _map(raw);

    return BuyerNotificationItem(
      id:
          _integer(
        data['id'],
      ),
      orderId:
          _integer(
        data['order_id'],
      ),
      type:
          _text(
        data['type'],
      ),
      title:
          _text(
        data['title'],
        'SARI Update',
      ),
      message:
          _text(
        data['message'],
      ),
      status:
          _text(
        data['status'],
      ),
      sellerName:
          _text(
        data['store_name'],
        'SARI Seller',
      ),
      orderNumber:
          _text(
        data['order_number'],
      ),
      createdAt:
          _text(
        data['created_at'],
      ),
      isRead:
          data['is_read'] == true ||
              data['is_read'] == 1 ||
              data['is_read'] == '1',
    );
  }

  BuyerOrderItem _parseOrderItem(
    dynamic raw,
  ) {
    final Map<String, dynamic> data =
        _map(raw);

    return BuyerOrderItem(
      productId:
          _integer(
        data['product_id'],
      ),
      variantId:
          data['variant_id'] == null
              ? null
              : _integer(
                  data['variant_id'],
                ),
      name:
          _text(
        data['name'],
        'Product',
      ),
      variantLabel:
          _text(
        data['variant_label'],
        'Standard',
      ),
      quantity:
          _integer(
        data['qty'] ??
            data['quantity'],
      ),
      lineTotal:
          _decimal(
        data['line_total'],
      ),
      image: _text(
                data['image_url'] ??
                    data['image'],
              )
              .isEmpty
          ? null
          : _text(
              data['image_url'] ??
                  data['image'],
            ),
    );
  }

  BuyerOrder _parseOrder(
    dynamic raw,
  ) {
    final Map<String, dynamic> data =
        _map(raw);

    final List<dynamic> rawItems =
        data['items'] is List
            ? data['items'] as List
            : const <dynamic>[];

    final List<BuyerOrderItem> items =
        rawItems
            .map(
              _parseOrderItem,
            )
            .toList();

    return BuyerOrder(
      id:
          _integer(
        data['id'],
      ),
      orderNumber:
          _text(
        data['order_number'],
      ),
      status:
          _text(
        data['status'],
      ),
      apiStatusLabel:
          _text(
        data['status_label'],
      ),
      paymentMethod:
          _text(
        data['payment_method'],
        'Not specified',
      ),
      paymentStatus:
          _text(
        data['payment_status'],
        'pending',
      ),
      subtotal:
          _decimal(
        data['subtotal'],
      ),
      deliveryFee:
          _decimal(
        data['delivery_fee'],
      ),
      totalAmount:
          _decimal(
        data['total'],
      ),
      createdAt:
          _text(
        data['created_at'],
      ),
      deliveredAt:
          _text(
        data['delivered_at'],
      ),
      buyerName:
          _text(
        data['buyer_name'],
        'SARI Buyer',
      ),
      buyerPhone:
          _text(
        data['buyer_phone'],
      ),
      deliveryAddress:
          _text(
        data['buyer_address'],
      ),
      sellerName:
          _text(
        data['store_name'],
        'SARI Seller',
      ),
      sellerAccountId:
          _integer(
        data['seller_id'],
      ),
      items: items,
      productNames: items
          .map(
            (
              BuyerOrderItem item,
            ) =>
                item.name,
          )
          .toList(),
    );
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _load({
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (_loading ||
          _loadingMore ||
          _page >= _lastPage) {
        return;
      }
    }

    final int requestedPage =
        loadMore
            ? _page + 1
            : 1;

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
      final Map<String, dynamic> response =
          await SariLiveData.instance
              .buyerNotifications(
        page: requestedPage,
        perPage: 20,
        archived: _archived,
      );

      final dynamic raw =
          response['data'];

      if (raw is! List) {
        throw const FormatException(
          'Invalid notifications response.',
        );
      }

      final Map<String, dynamic> meta =
          _map(
        response['meta'],
      );

      final List<BuyerNotificationItem>
          loaded =
          raw
              .map(
                _parseNotification,
              )
              .where(
                (
                  BuyerNotificationItem
                      item,
                ) =>
                    item.id > 0,
              )
              .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        final Set<int> existing =
            _items
                .map(
                  (
                    BuyerNotificationItem
                        item,
                  ) =>
                      item.id,
                )
                .toSet();

        for (final BuyerNotificationItem item
            in loaded) {
          if (existing.add(
            item.id,
          )) {
            _items.add(item);
          }
        }

        _page =
            _integer(
          meta['current_page'],
        );

        if (_page <= 0) {
          _page =
              requestedPage;
        }

        _lastPage =
            _integer(
          meta['last_page'],
        );

        if (_lastPage <= 0) {
          _lastPage = 1;
        }

        _total =
            _integer(
          meta['total'],
        );

        _loading = false;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = error.toString();
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

  // ============================================================
  // READ STATUS
  // ============================================================

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

      if (!mounted) {
        return;
      }

      setState(() {
        item.isRead = true;
      });
    } catch (error) {
      _show(
        error.toString(),
      );
    }
  }

  Future<void> _markAllRead() async {
    if (_archived ||
        _markingAll ||
        !_items.any(
          (
            BuyerNotificationItem item,
          ) =>
              !item.isRead,
        )) {
      return;
    }

    setState(() {
      _markingAll = true;
    });

    try {
      final Map<String, dynamic> response =
          await SariLiveData.instance
              .buyerReadAllNotifications();

      if (!mounted) {
        return;
      }

      setState(() {
        for (final BuyerNotificationItem item
            in _items) {
          item.isRead = true;
        }
      });

      _show(
        _text(
          response['message'],
          'Notifications marked as read.',
        ),
      );
    } catch (error) {
      _show(
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

  Future<void> _manageNotification(BuyerNotificationItem item, String action) async {
    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Remove notification?'),
          content: const Text('Delete this notification from your account?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    try {
      switch (action) {
        case 'archive': await SariLiveData.instance.buyerArchiveNotification(item.id); break;
        case 'restore': await SariLiveData.instance.buyerRestoreNotification(item.id); break;
        case 'delete': await SariLiveData.instance.buyerDeleteNotification(item.id); break;
      }
      if (mounted) await _load();
    } catch (error) {
      _show(error.toString());
    }
  }

  // ============================================================
  // OPEN NOTIFICATION
  // ============================================================

  Future<void> _openNotification(
    BuyerNotificationItem item,
  ) async {
    await _markRead(item);

    if (!item.hasOrder ||
        !mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (
            BuildContext context,
          ) =>
              const Center(
        child:
            CircularProgressIndicator(),
      ),
    );

    try {
      final Map<String, dynamic> response =
          await SariLiveData.instance
              .buyerOrderDetails(
        item.orderId,
      );

      final Map<String, dynamic> data =
          _map(
        response['data'],
      );

      if (data.isEmpty) {
        throw const FormatException(
          'Order details unavailable.',
        );
      }

      final BuyerOrder order =
          _parseOrder(data);

      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder:
              (
                BuildContext context,
              ) =>
                  BuyerOrderDetails(
            order: order,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();

      _show(
        'Unable to open order: $error',
      );
    }
  }

  // ============================================================
  // DESIGN
  // ============================================================

  IconData _iconFor(
    BuyerNotificationItem item,
  ) {
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

    if (item.isCourierUpdate) {
      return Icons
          .local_shipping_outlined;
    }

    switch (item.type) {
      case 'message':
        return Icons
            .chat_bubble_outline_rounded;

      case 'payment':
        return Icons
            .payments_outlined;

      default:
        return Icons
            .notifications_none_rounded;
    }
  }

  Color _colorFor(
    BuyerNotificationItem item,
  ) {
    if (item.status ==
        'delivered') {
      return BuyerTheme.success;
    }

    if (item.status ==
        'cancelled') {
      return BuyerTheme.danger;
    }

    if (item.isCourierUpdate) {
      return BuyerTheme.blue;
    }

    return BuyerTheme.goldDark;
  }

  Color _backgroundFor(
    BuyerNotificationItem item,
  ) {
    if (item.status ==
        'delivered') {
      return BuyerTheme.successSoft;
    }

    if (item.status ==
        'cancelled') {
      return const Color(
        0xFFFFECEB,
      );
    }

    if (item.isCourierUpdate) {
      return BuyerTheme.blueSoft;
    }

    return BuyerTheme.goldPale;
  }

  Widget _hero() {
    final int unread =
        _items.where(
      (
        BuyerNotificationItem item,
      ) =>
          !item.isRead,
    ).length;

    return Container(
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors:
              BuyerTheme.heroGradient,
        ),
        borderRadius:
            BorderRadius.circular(
          23,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'BUYER UPDATES',
                  style: TextStyle(
                    color:
                        Color(
                      0xFFFFD98A,
                    ),
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing:
                        1.2,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  _archived
                      ? 'Your archived\nupdates.'
                      : 'Stay on top of\nevery order.',
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
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
                  _archived
                      ? '$_total archived notification${_total == 1 ? '' : 's'}'
                      : '$unread unread notification${unread == 1 ? '' : 's'}',
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons
                .notifications_active_outlined,
            color:
                Colors.white,
            size: 44,
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Container(
      padding:
          const EdgeInsets.all(
        4,
      ),
      decoration:
          BoxDecoration(
        color:
            BuyerTheme.surface,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color:
              BuyerTheme.border,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _folderButton(
              label: 'Recent',
              selected:
                  !_archived,
              onTap: () {
                _switchFolder(
                  false,
                );
              },
            ),
          ),
          Expanded(
            child: _folderButton(
              label: 'Archived',
              selected:
                  _archived,
              onTap: () {
                _switchFolder(
                  true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _folderButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
        11,
      ),
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 170,
        ),
        padding:
            const EdgeInsets.symmetric(
          vertical: 10,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? BuyerTheme.goldPale
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(
            11,
          ),
        ),
        child: Text(
          label,
          textAlign:
              TextAlign.center,
          style: TextStyle(
            color: selected
                ? BuyerTheme.goldDark
                : BuyerTheme.muted,
            fontSize: 10,
            fontWeight: selected
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _notificationCard(
    BuyerNotificationItem item,
  ) {
    final Color color =
        _colorFor(item);

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      decoration:
          BuyerTheme.card(
        radius: 18,
      ),
      child: Material(
        color:
            Colors.transparent,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        child: InkWell(
          onTap: () {
            _openNotification(
              item,
            );
          },
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          child: Padding(
            padding:
                const EdgeInsets.all(
              14,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  alignment:
                      Alignment.center,
                  decoration:
                      BoxDecoration(
                    color:
                        _backgroundFor(
                      item,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: Icon(
                    _iconFor(item),
                    color: color,
                    size: 22,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item.title,
                              style:
                                  TextStyle(
                                color:
                                    BuyerTheme.ink,
                                fontSize: 12,
                                fontWeight:
                                    item.isRead
                                        ? FontWeight.w700
                                        : FontWeight.w900,
                              ),
                            ),
                          ),

                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration:
                                  const BoxDecoration(
                                color:
                                    BuyerTheme.gold,
                                shape:
                                    BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      if (item.message
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          item.message,
                          maxLines: 3,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                BuyerTheme.muted,
                            fontSize: 9.5,
                            height: 1.45,
                          ),
                        ),
                      ],

                      const SizedBox(
                        height: 7,
                      ),

                      Row(
                        children: <Widget>[
                          if (item.orderNumber
                              .isNotEmpty) ...[
                            Flexible(
                              child: Text(
                                item.orderNumber,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    TextStyle(
                                  color:
                                      color,
                                  fontSize: 8.5,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                          ],

                          Expanded(
                            child: Text(
                              _dateTime(
                                item.createdAt,
                              ),
                              textAlign:
                                  TextAlign.right,
                              style:
                                  const TextStyle(
                                color:
                                    BuyerTheme
                                        .muted,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 4,
                ),

                PopupMenuButton<String>(
                  tooltip: 'Notification actions',
                  onSelected: (action) => _manageNotification(item, action),
                  itemBuilder: (_) => [
                    PopupMenuItem<String>(
                      value: _archived ? 'restore' : 'archive',
                      child: Text(_archived ? 'Restore' : 'Archive'),
                    ),
                    const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _empty() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 48,
      ),
      decoration:
          BuyerTheme.card(),
      child:
          const Column(
        children: <Widget>[
          Icon(
            Icons
                .notifications_none_rounded,
            size: 52,
            color:
                BuyerTheme.muted,
          ),

          SizedBox(
            height: 14,
          ),

          Text(
            'No notifications here',
            style: TextStyle(
              color:
                  BuyerTheme.ink,
              fontSize: 16,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          SizedBox(
            height: 6,
          ),

          Text(
            'Updates about your SARI orders will appear here.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  BuyerTheme.muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _show(
    String message,
  ) {
    if (!mounted) {
      return;
    }

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final int unread =
        _items.where(
      (
        BuyerNotificationItem item,
      ) =>
          !item.isRead,
    ).length;

    return Scaffold(
      backgroundColor:
          BuyerTheme.canvas,
      body: Column(
        children: <Widget>[
          BuyerHeader(
            pageTitle:
                'Notifications',
            cartCount: 0,
            notificationCount:
                unread,
            onSearchTap: () {
              widget.onTabChanged
                  ?.call(1);
            },
            onCartTap: () {
              widget.onTabChanged
                  ?.call(2);
            },
            onNotificationTap:
                () {},
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
                : RefreshIndicator(
                    color:
                        BuyerTheme.gold,
                    onRefresh: () {
                      return _load();
                    },
                    child:
                        ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.fromLTRB(
                        14,
                        14,
                        14,
                        30,
                      ),
                      children: <Widget>[
                        _hero(),

                        const SizedBox(
                          height: 15,
                        ),

                        _tabs(),

                        const SizedBox(
                          height: 16,
                        ),

                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                _archived
                                    ? 'Archived Updates'
                                    : 'Recent Updates',
                                style:
                                    const TextStyle(
                                  color:
                                      BuyerTheme.ink,
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                            ),

                            if (!_archived &&
                                unread >
                                    0)
                              TextButton(
                                onPressed:
                                    _markingAll
                                        ? null
                                        : _markAllRead,
                                child: Text(
                                  _markingAll
                                      ? 'Marking...'
                                      : 'Read all',
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        if (_error !=
                                null &&
                            _items.isEmpty)
                          Container(
                            padding:
                                const EdgeInsets.all(
                              24,
                            ),
                            decoration:
                                BuyerTheme.card(),
                            child: Column(
                              children: <Widget>[
                                const Icon(
                                  Icons
                                      .cloud_off_outlined,
                                  size: 44,
                                  color:
                                      BuyerTheme.muted,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  _error!,
                                  textAlign:
                                      TextAlign.center,
                                  style:
                                      const TextStyle(
                                    color:
                                        BuyerTheme.muted,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _load();
                                  },
                                  icon:
                                      const Icon(
                                    Icons
                                        .refresh_rounded,
                                  ),
                                  label:
                                      const Text(
                                    'Retry',
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_items
                            .isEmpty)
                          _empty()
                        else
                          ..._items.map(
                            _notificationCard,
                          ),

                        if (_page <
                            _lastPage) ...[
                          const SizedBox(
                            height: 8,
                          ),
                          OutlinedButton.icon(
                            onPressed:
                                _loadingMore
                                    ? null
                                    : () {
                                        _load(
                                          loadMore:
                                              true,
                                        );
                                      },
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
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}