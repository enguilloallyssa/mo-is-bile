import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'models/buyer_order_model.dart';

class BuyerShipping extends StatefulWidget {
  final List<BuyerOrder>? shipments;

  const BuyerShipping({
    super.key,
    this.shipments,
  });

  @override
  State<BuyerShipping> createState() =>
      _BuyerShippingState();
}

class _BuyerShippingState
    extends State<BuyerShipping> {
  static const Color gold =
      Color(0xFFD9950B);
  static const Color dark =
      Color(0xFF24201C);
  static const Color muted =
      Color(0xFF7F776E);
  static const Color bg =
      Color(0xFFF4F5F7);
  static const Color border =
      Color(0xFFE6E8EC);

  final List<Map<String, dynamic>>
      _shipments = [];

  bool _loading = true;

  String? _error;

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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response =
          await SariLiveData.instance
              .buyerShipping();

      final raw =
          response['data'];

      final shipments = raw is List
          ? raw.map(_map).toList()
          : <Map<String, dynamic>>[];

      if (!mounted) return;

      setState(() {
        _shipments
          ..clear()
          ..addAll(shipments);

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

  Future<void> _openTracking(
    Map<String, dynamic> shipment,
  ) async {
    final id =
        _integer(
      shipment['id'],
    );

    if (id <= 0) {
      return;
    }

    try {
      final response =
          await SariLiveData.instance
              .buyerTracking(id);

      final data =
          _map(
        response['data'],
      );

      final rawEvents =
          data['events'];

      final events =
          rawEvents is List
              ? rawEvents
                  .map(_map)
                  .toList()
              : <Map<String, dynamic>>[];

      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: .75,
            maxChildSize: .95,
            builder:
                (context, controller) {
              return ListView(
                controller:
                    controller,
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  4,
                  18,
                  30,
                ),
                children: [
                  Text(
                    _text(
                      data['order_number'],
                      'Order Tracking',
                    ),
                    style:
                        const TextStyle(
                      color: dark,
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    _text(
                      data['status_label'],
                    ),
                    style:
                        const TextStyle(
                      color: gold,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  if (_text(
                    data[
                        'courier_name'],
                  ).isNotEmpty) ...[
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      'Courier: '
                      '${_text(data['courier_name'])}',
                    ),
                  ],
                  const SizedBox(
                    height: 18,
                  ),
                  const Text(
                    'Tracking Events',
                    style: TextStyle(
                      color: dark,
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (events.isEmpty)
                    const Text(
                      'No tracking events yet.',
                      style: TextStyle(
                        color: muted,
                      ),
                    )
                  else
                    ...events.map(
                      (event) =>
                          ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading:
                            const CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              Color(
                            0xFFFFE9BE,
                          ),
                          child: Icon(
                            Icons
                                .check_rounded,
                            color: gold,
                            size: 17,
                          ),
                        ),
                        title: Text(
                          _text(
                            event['title'],
                            _text(
                              event[
                                  'status'],
                              'Order Update',
                            ),
                          ),
                          style:
                              const TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          [
                            _text(
                              event[
                                  'message'],
                            ),
                            _text(
                              event[
                                  'created_at'],
                            ),
                          ]
                              .where(
                                (value) =>
                                    value
                                        .isNotEmpty,
                              )
                              .join('\n'),
                          style:
                              const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content:
                Text('$error'),
            behavior:
                SnackBarBehavior.floating,
          ),
        );
    }
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
        0xFFB25555,
      );
    }

    return gold;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'Shipping',
        ),
        backgroundColor:
            Colors.white,
        foregroundColor: dark,
        surfaceTintColor:
            Colors.white,
      ),
      body: RefreshIndicator(
        color: gold,
        onRefresh: _load,
        child: _loading
            ? ListView(
                children: const [
                  SizedBox(
                    height: 170,
                  ),
                  Center(
                    child:
                        CircularProgressIndicator(
                      color: gold,
                    ),
                  ),
                ],
              )
            : _error != null
                ? ListView(
                    padding:
                        const EdgeInsets.all(
                      24,
                    ),
                    children: [
                      const SizedBox(
                        height: 70,
                      ),
                      const Icon(
                        Icons
                            .wifi_off_rounded,
                        size: 48,
                        color: muted,
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
                          color: muted,
                        ),
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      FilledButton(
                        onPressed:
                            _load,
                        child:
                            const Text(
                          'Try Again',
                        ),
                      ),
                    ],
                  )
                : _shipments.isEmpty
                    ? ListView(
                        padding:
                            const EdgeInsets.all(
                          40,
                        ),
                        children:
                            const [
                          SizedBox(
                            height:
                                60,
                          ),
                          Icon(
                            Icons
                                .local_shipping_outlined,
                            size:
                                60,
                            color:
                                muted,
                          ),
                          SizedBox(
                            height:
                                12,
                          ),
                          Text(
                            'No active shipments',
                            textAlign:
                                TextAlign.center,
                            style:
                                TextStyle(
                              color:
                                  dark,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding:
                            const EdgeInsets.all(
                          14,
                        ),
                        itemCount:
                            _shipments.length,
                        separatorBuilder:
                            (context, index) =>
                                const SizedBox(
                          height: 10,
                        ),
                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          final shipment =
                              _shipments[
                                  index];

                          final status =
                              _text(
                            shipment[
                                'status'],
                          );

                          final color =
                              _statusColor(
                            status,
                          );

                          return Container(
                            padding:
                                const EdgeInsets.all(
                              15,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white,
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                              border:
                                  Border.all(
                                color:
                                    border,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child:
                                          Text(
                                        _text(
                                          shipment[
                                              'store_name'],
                                          'SARI Seller',
                                        ),
                                        style:
                                            const TextStyle(
                                          color:
                                              dark,
                                          fontWeight:
                                              FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal:
                                            8,
                                        vertical:
                                            5,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color: color
                                            .withValues(
                                          alpha:
                                              .10,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      child:
                                          Text(
                                        _text(
                                          shipment[
                                              'status_label'],
                                          status,
                                        ),
                                        style:
                                            TextStyle(
                                          color:
                                              color,
                                          fontSize:
                                              9,
                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height:
                                      10,
                                ),
                                Text(
                                  _text(
                                    shipment[
                                        'order_number'],
                                  ),
                                  style:
                                      const TextStyle(
                                    color:
                                        dark,
                                    fontSize:
                                        16,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                                if (_text(
                                  shipment[
                                      'parcel_status'],
                                ).isNotEmpty) ...[
                                  const SizedBox(
                                    height:
                                        5,
                                  ),
                                  Text(
                                    'Parcel: '
                                    '${_text(shipment['parcel_status'])}',
                                    style:
                                        const TextStyle(
                                      color:
                                          muted,
                                      fontSize:
                                          10,
                                    ),
                                  ),
                                ],
                                if (_text(
                                  shipment[
                                      'courier_name'],
                                ).isNotEmpty) ...[
                                  const SizedBox(
                                    height:
                                        5,
                                  ),
                                  Text(
                                    'Courier: '
                                    '${_text(shipment['courier_name'])}',
                                    style:
                                        const TextStyle(
                                      color:
                                          muted,
                                      fontSize:
                                          10,
                                    ),
                                  ),
                                ],
                                const SizedBox(
                                  height:
                                      12,
                                ),
                                SizedBox(
                                  width:
                                      double.infinity,
                                  child:
                                      OutlinedButton.icon(
                                    onPressed: () =>
                                        _openTracking(
                                      shipment,
                                    ),
                                    icon:
                                        const Icon(
                                      Icons
                                          .route_outlined,
                                    ),
                                    label:
                                        const Text(
                                      'Track Order',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}