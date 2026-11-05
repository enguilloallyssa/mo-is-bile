import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/api_config.dart';
import '../services/sari_live_data.dart';
import 'buyer_order_details.dart';
import 'buyer_theme.dart';
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
  final TextEditingController
      _searchController =
      TextEditingController();

  final List<_OrderView> _orders =
      <_OrderView>[];

  bool _loading = true;

  String? _error;

  String _filter = 'all';

  static const Color _ink =
      Color(0xFF20242B);

  static const Color _muted =
      Color(0xFF818895);

  static const Color _gold =
      Color(0xFFD38D06);

  static const Color _goldDark =
      Color(0xFFAF7200);

static const List<(String, String)> _filterOptions =
    <(String, String)>[
  ('all', 'All'),
  ('to-ship', 'To Ship'),
  ('in-transit', 'In Transit'),
  ('delivered', 'Delivered'),
  ('cancelled', 'Cancelled'),
];

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
    final String result =
        value?.toString().trim() ??
            '';

    return result.isEmpty
        ? fallback
        : result;
  }

  int _integer(
    dynamic value,
  ) {
    return value is num
        ? value.toInt()
        : int.tryParse('$value') ??
            0;
  }

  double _decimal(
    dynamic value,
  ) {
    return value is num
        ? value.toDouble()
        : double.tryParse('$value') ??
            0;
  }

  String _absoluteUrl(
    dynamic raw,
  ) {
    final String value =
        _text(raw);

    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith(
          'http://',
        ) ||
        value.startsWith(
          'https://',
        )) {
      return value;
    }

    final String base =
        ApiConfig.baseUrl.replaceFirst(
      RegExp(r'/+$'),
      '',
    );

    if (value.startsWith('/')) {
      return '$base$value';
    }

    return '$base/$value';
  }

  String _money(
    double value,
  ) {
    return '₱${value.toStringAsFixed(2)}';
  }

  String _dateTime(
    String raw,
  ) {
    final DateTime? date =
        DateTime.tryParse(raw)
            ?.toLocal();

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

  BuyerOrderItem _parseItem(
    dynamic raw,
  ) {
    final Map<String, dynamic> data =
        _map(raw);

    final String image =
        _absoluteUrl(
      data['image_url'] ??
          data['image'],
    );

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
        'Ordered Product',
      ),
      variantLabel:
          _text(
        data['variant_label'],
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
      image:
          image.isEmpty
              ? null
              : image,
    );
  }

  _OrderView _parseOrder(
    dynamic raw,
  ) {
    final Map<String, dynamic> data =
        _map(raw);

    final List<BuyerOrderItem> items =
        data['items'] is List
            ? (data['items'] as List)
                .map(_parseItem)
                .toList()
            : <BuyerOrderItem>[];

    final BuyerOrder order =
        BuyerOrder(
      id:
          _integer(
        data['id'],
      ),
      orderNumber:
          _text(
        data['order_number'],
        'SARI Order',
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
        'COD',
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
      sellerName:
          _text(
        data['store_name'],
        'SARI Seller',
      ),
      sellerAccountId:
          _integer(
        data['seller_id'],
      ),
      items:
          items,
      productNames:
          items
              .map(
                (
                  BuyerOrderItem item,
                ) =>
                    item.name,
              )
              .toList(),
      latestUpdateTime:
          _text(
        data['updated_at'] ??
            data['created_at'],
      ),
      latestUpdateMessage:
          _text(
        data['status_label'],
      ),
    );

    return _OrderView(
      order: order,
      storeLogoUrl:
          _absoluteUrl(
        data['store_logo_url'],
      ),
    );
  }

  Future<void> _loadOrders()
      async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final List<dynamic> rows =
          <dynamic>[];

      int page = 1;
      int lastPage = 1;

      do {
        final Map<String, dynamic>
            response =
            await SariLiveData
                .instance
                .buyerOrders(
          page: page,
          perPage: 30,
        );

        if (response['data']
            is List) {
          rows.addAll(
            response['data'] as List,
          );
        }

        final Map<String, dynamic> meta =
            _map(
          response['meta'],
        );

        lastPage =
            _integer(
          meta['last_page'],
        );

        if (lastPage <= 0) {
          lastPage = 1;
        }

        page++;
      } while (page <= lastPage);

      final List<_OrderView> loaded =
          rows
              .map(_parseOrder)
              .where(
                (
                  _OrderView item,
                ) =>
                    item.order.id > 0,
              )
              .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _orders
          ..clear()
          ..addAll(
            loaded,
          );

        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error =
            error.toString();
      });
    }
  }

  List<_OrderView>
      get _visibleOrders {
    final String query =
        _searchController.text
            .trim()
            .toLowerCase();

    return _orders.where(
      (
        _OrderView view,
      ) {
        final BuyerOrder order =
            view.order;

        if (_filter != 'all' &&
            order.filterGroup !=
                _filter) {
          return false;
        }

        if (query.isEmpty) {
          return true;
        }

        final String haystack =
            <String>[
          order.orderNumber,
          order.sellerName,
          order.statusLabel,
          ...order.productNames,
        ].join(' ').toLowerCase();

        return haystack.contains(
          query,
        );
      },
    ).toList();
  }

  Future<void> _openOrder(
    BuyerOrder order,
  ) async {
    try {
      final Map<String, dynamic>
          response =
          await SariLiveData
              .instance
              .buyerOrderDetails(
        order.id,
      );

      final Map<String, dynamic> data =
          _map(
        response['data'],
      );

      if (data.isEmpty) {
        throw const FormatException(
          'Order unavailable.',
        );
      }

      final BuyerOrder fresh =
          _parseOrder(data).order;

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              BuyerOrderDetails(
            order: fresh,
          ),
        ),
      );

      await _loadOrders();
    } catch (error) {
      _message(
        'Unable to open order: $error',
      );
    }
  }

  Future<void> _copyOrder(
    String orderNumber,
  ) async {
    await Clipboard.setData(
      ClipboardData(
        text: orderNumber,
      ),
    );

    _message(
      'Order number copied.',
    );
  }

  void _message(
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

  Color _statusColor(
    BuyerOrder order,
  ) {
    if (order.isDelivered) {
      return BuyerTheme.success;
    }

    if (order.isCancelled) {
      return BuyerTheme.danger;
    }

    if (order.filterGroup ==
        'in-transit') {
      return BuyerTheme.blue;
    }

    return _goldDark;
  }

  Color _statusBackground(
    BuyerOrder order,
  ) {
    if (order.isDelivered) {
      return BuyerTheme.successSoft;
    }

    if (order.isCancelled) {
      return const Color(
        0xFFFFECE8,
      );
    }

    if (order.filterGroup ==
        'in-transit') {
      return BuyerTheme.blueSoft;
    }

    return const Color(
      0xFFFFF4D9,
    );
  }

  Widget _hero() {
    final int active =
        _orders.where(
      (
        _OrderView item,
      ) {
        return !item.order.isDelivered &&
            !item.order.isCancelled;
      },
    ).length;

    final int delivered =
        _orders.where(
      (
        _OrderView item,
      ) =>
          item.order.isDelivered,
    ).length;

    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        0,
      ),
      padding:
          const EdgeInsets.all(
        17,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: <Color>[
            Color(
              0xFF172334,
            ),
            Color(
              0xFF303D4B,
            ),
            Color(
              0xFF7B632B,
            ),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          19,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'YOUR ORDERS',
            style:
                TextStyle(
              color:
                  Color(
                0xFFFFD98A,
              ),
              fontSize: 8,
              letterSpacing: 1.1,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          const Text(
            'Everything you\nordered, in sync.',
            style:
                TextStyle(
              color: Colors.white,
              fontSize: 20,
              height: 1.04,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          Row(
            children: <Widget>[
              Expanded(
                child: _metric(
                  '$active',
                  'Active',
                ),
              ),
              const SizedBox(
                width: 7,
              ),
              Expanded(
                child: _metric(
                  '$delivered',
                  'Delivered',
                ),
              ),
              const SizedBox(
                width: 7,
              ),
              Expanded(
                child: _metric(
                  '${_orders.length}',
                  'Total',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(
    String value,
    String label,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 9,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white
                .withValues(
          alpha: .09,
        ),
        borderRadius:
            BorderRadius.circular(
          11,
        ),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            label,
            style:
                const TextStyle(
              color:
                  Colors.white60,
              fontSize: 7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        13,
        12,
        11,
      ),
      child: Column(
        children: <Widget>[
          TextField(
            controller:
                _searchController,
            onChanged: (_) {
              setState(() {});
            },
            style:
                const TextStyle(
              fontSize: 10,
            ),
            decoration:
                const InputDecoration(
              isDense: true,
              hintText:
                  'Search orders...',
              prefixIcon:
                  Icon(
                Icons.search_rounded,
                size: 17,
              ),
              contentPadding:
                  EdgeInsets.symmetric(
                vertical: 11,
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          SizedBox(
            height: 34,
            child:
                ListView.separated(
              scrollDirection:
                  Axis.horizontal,
              itemCount: _filterOptions.length,
              separatorBuilder:
                  (
                    _,
                    __,
                  ) =>
                      const SizedBox(
                width: 6,
              ),
              itemBuilder:
                  (
                    BuildContext context,
                    int index,
                  ) {
                final item = _filterOptions[index];

                final bool selected =
                    _filter ==
                        item.$1;

                return ChoiceChip(
                  label:
                      Text(
                    item.$2,
                  ),
                  selected:
                      selected,
                  labelStyle:
                      TextStyle(
                    fontSize: 8,
                    fontWeight:
                        FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : _ink,
                  ),
                  selectedColor:
                      _gold,
                  backgroundColor:
                      Colors.white,
                  side:
                      const BorderSide(
                    color:
                        BuyerTheme.border,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _filter =
                          item.$1;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(
    _OrderView view,
  ) {
    final BuyerOrder order =
        view.order;

    final BuyerOrderItem? firstItem =
        order.items.isEmpty
            ? null
            : order.items.first;

    final int extraItems =
        order.items.length > 1
            ? order.items.length - 1
            : 0;

    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        12,
        0,
        12,
        11,
      ),
      clipBehavior:
          Clip.antiAlias,
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              BuyerTheme.border,
        ),
        boxShadow:
            const <BoxShadow>[
          BoxShadow(
            color:
                Color(
              0x10000000,
            ),
            blurRadius: 15,
            offset:
                Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.all(
              13,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                _storeAvatar(
                  view,
                ),

                const SizedBox(
                  width: 10,
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
                              order
                                  .orderNumber,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    _ink,
                                fontSize:
                                    11,
                                fontWeight:
                                    FontWeight
                                        .w900,
                              ),
                            ),
                          ),

                          IconButton(
                            padding:
                                EdgeInsets.zero,
                            constraints:
                                const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            onPressed: () {
                              _copyOrder(
                                order
                                    .orderNumber,
                              );
                            },
                            icon:
                                const Icon(
                              Icons
                                  .content_copy_outlined,
                              size: 14,
                              color:
                                  _muted,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        order.sellerName,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color:
                              _muted,
                          fontSize: 8.5,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        crossAxisAlignment:
                            WrapCrossAlignment
                                .center,
                        children: <Widget>[
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  _statusBackground(
                                order,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                            ),
                            child:
                                Text(
                              order.statusLabel,
                              style:
                                  TextStyle(
                                color:
                                    _statusColor(
                                  order,
                                ),
                                fontSize: 7,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ),

                          Text(
                            _dateTime(
                              order.createdAt,
                            ),
                            style:
                                const TextStyle(
                              color:
                                  _muted,
                              fontSize: 7,
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

          const Divider(
            height: 1,
          ),

          Padding(
            padding:
                const EdgeInsets.all(
              13,
            ),
            child:
                firstItem == null
                    ? _noItemPreview(
                        order,
                      )
                    : _productPreview(
                        order,
                        firstItem,
                        extraItems,
                      ),
          ),

          Container(
            padding:
                const EdgeInsets.fromLTRB(
              11,
              9,
              11,
              10,
            ),
            decoration:
                const BoxDecoration(
              color:
                  Color(
                0xFFFFFEFB,
              ),
              border: Border(
                top: BorderSide(
                  color:
                      BuyerTheme.border,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      widget.onTabChanged
                          ?.call(6);
                    },
                    icon:
                        const Icon(
                      Icons
                          .chat_bubble_outline_rounded,
                      size: 14,
                    ),
                    label:
                        const Text(
                      'Message',
                      style:
                          TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 7,
                ),

                Expanded(
                  child:
                      FilledButton.tonalIcon(
                    onPressed: () {
                      _openOrder(
                        order,
                      );
                    },
                    icon:
                        const Icon(
                      Icons
                          .receipt_long_outlined,
                      size: 14,
                    ),
                    label:
                        const Text(
                      'View Details',
                      style:
                          TextStyle(
                        fontSize: 8,
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

  Widget _storeAvatar(
    _OrderView view,
  ) {
    final String logo =
        view.storeLogoUrl;

    final List<String> words =
        view.order.sellerName
            .split(' ')
            .where(
              (
                String value,
              ) =>
                  value.trim().isNotEmpty,
            )
            .toList();

    final String initials =
        words
            .take(2)
            .map(
              (
                String value,
              ) =>
                  value[0]
                      .toUpperCase(),
            )
            .join();

    return Container(
      width: 48,
      height: 48,
      clipBehavior:
          Clip.antiAlias,
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        color:
            const Color(
          0xFFF5F3EF,
        ),
        border:
            Border.all(
          color:
              BuyerTheme.border,
        ),
      ),
      child:
          logo.isNotEmpty
              ? Image.network(
                  logo,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (
                        _,
                        __,
                        ___,
                      ) =>
                          _avatarFallback(
                    initials,
                  ),
                )
              : _avatarFallback(
                  initials,
                ),
    );
  }

  Widget _avatarFallback(
    String initials,
  ) {
    return Center(
      child: Text(
        initials.isEmpty
            ? 'S'
            : initials,
        style:
            const TextStyle(
          color: _goldDark,
          fontSize: 14,
          fontWeight:
              FontWeight.w900,
        ),
      ),
    );
  }

  Widget _productPreview(
    BuyerOrder order,
    BuyerOrderItem item,
    int extra,
  ) {
    final String image =
        item.image ?? '';

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 68,
          height: 68,
          clipBehavior:
              Clip.antiAlias,
          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFF4F3F1,
            ),
            borderRadius:
                BorderRadius.circular(
              13,
            ),
          ),
          child:
              image.isEmpty
                  ? const Icon(
                      Icons
                          .inventory_2_outlined,
                      color:
                          BuyerTheme.muted,
                    )
                  : Image.network(
                      image,
                      fit:
                          BoxFit.cover,
                      errorBuilder:
                          (
                            _,
                            __,
                            ___,
                          ) =>
                              const Icon(
                        Icons
                            .inventory_2_outlined,
                        color:
                            BuyerTheme.muted,
                      ),
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
            children: <Widget>[
              const Text(
                'ITEMS IN THIS ORDER',
                style:
                    TextStyle(
                  color:
                      _muted,
                  fontSize: 7,
                  letterSpacing:
                      .8,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Text(
                item.name,
                maxLines: 2,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    const TextStyle(
                  color: _ink,
                  fontSize: 10.5,
                  height: 1.15,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                [
                  'Qty ${item.quantity}',
                  if (item.variantLabel
                      .trim()
                      .isNotEmpty)
                    item.variantLabel,
                  if (extra > 0)
                    '+$extra more',
                ].join(' • '),
                maxLines: 2,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    const TextStyle(
                  color:
                      _muted,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          width: 9,
        ),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: <Widget>[
            const Text(
              'ORDER TOTAL',
              style:
                  TextStyle(
                color:
                    _muted,
                fontSize: 6.5,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              _money(
                order.resolvedTotal,
              ),
              style:
                  const TextStyle(
                color: _ink,
                fontSize: 14,
                fontWeight:
                    FontWeight.w900,
                fontFamilyFallback:
                    <String>[
                  'Roboto',
                  'Arial',
                ],
              ),
            ),

            const SizedBox(
              height: 3,
            ),

            Text(
              order.paymentMethod,
              style:
                  const TextStyle(
                color:
                    _muted,
                fontSize: 7,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _noItemPreview(
    BuyerOrder order,
  ) {
    return Row(
      children: <Widget>[
        const Icon(
          Icons
              .inventory_2_outlined,
          color:
              BuyerTheme.muted,
          size: 34,
        ),

        const SizedBox(
          width: 10,
        ),

        const Expanded(
          child: Text(
            'Order item information is unavailable.',
            style:
                TextStyle(
              color:
                  BuyerTheme.muted,
              fontSize: 9,
            ),
          ),
        ),

        Text(
          _money(
            order.resolvedTotal,
          ),
          style:
              const TextStyle(
            color: _ink,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _empty() {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      padding:
          const EdgeInsets.all(
        30,
      ),
      decoration:
          BuyerTheme.card(),
      child:
          const Column(
        children: <Widget>[
          Icon(
            Icons
                .receipt_long_outlined,
            size: 44,
            color:
                BuyerTheme.muted,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'No matching orders',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.w800,
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
    final List<_OrderView> visible =
        _visibleOrders;

    return Scaffold(
      backgroundColor:
          BuyerTheme.canvas,
      body: Column(
        children: <Widget>[
          BuyerHeader(
            pageTitle:
                'My Orders',
            cartCount: 0,
            notificationCount: 0,
            onSearchTap: () {
              widget.onTabChanged
                  ?.call(1);
            },
            onCartTap: () {
              widget.onTabChanged
                  ?.call(2);
            },
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
                : RefreshIndicator(
                    onRefresh:
                        _loadOrders,
                    child: ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.only(
                        bottom: 28,
                      ),
                      children: <Widget>[
                        _hero(),
                        _filters(),

                        if (_error !=
                                null &&
                            _orders.isEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.all(
                              20,
                            ),
                            child:
                                Text(
                              _error!,
                              textAlign:
                                  TextAlign.center,
                            ),
                          )
                        else if (visible
                            .isEmpty)
                          _empty()
                        else
                          ...visible.map(
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

class _OrderView {
  final BuyerOrder order;
  final String storeLogoUrl;

  const _OrderView({
    required this.order,
    required this.storeLogoUrl,
  });
}