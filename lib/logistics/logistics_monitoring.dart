import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'widgets/logistics_ui.dart';

class LogisticsMonitoring
    extends StatefulWidget {
  const LogisticsMonitoring({
    super.key,
  });

  @override
  State<LogisticsMonitoring>
      createState() =>
          _LogisticsMonitoringState();
}

class _LogisticsMonitoringState
    extends State<LogisticsMonitoring> {
  final _query =
      TextEditingController();

  bool _busy = false;

  String? _error;

  List<Map<String, dynamic>>
      _items = [];

  @override
  void dispose() {
    _query.dispose();

    super.dispose();
  }

  Future<void> _search() async {
    final q =
        _query.text.trim();

    if (q.length < 2) {
      return;
    }

    setState(
      () =>
          _busy =
              true,
    );

    try {
      final response =
          await SariLiveData
              .instance
              .logisticsMonitoring(
        q,
      );

      final data =
          response['data'];

      final raw =
          data is Map
              ? data['items']
              : null;

      if (mounted) {
        setState(() {
          _error = null;

          _items =
              raw is List
                  ? raw
                      .whereType<Map>()
                      .map(
                        (m) =>
                            Map<String,
                                    dynamic>.from(
                              m,
                            ),
                      )
                      .toList()
                  : [];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(
          () =>
              _error =
                  e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(
          () =>
              _busy =
                  false,
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      Scaffold(
        backgroundColor:
            LogisticsPalette.canvas,
        appBar:
            AppBar(
          title:
              const Text(
            'Delivery Monitoring',
          ),
        ),
        body:
            ListView(
          padding:
              const EdgeInsets.all(
            16,
          ),
          children: [
            const LogisticsSectionTitle(
              title:
                  'Track parcel/order',
              subtitle:
                  'Search shared Laravel orders',
            ),
            const SizedBox(
              height: 13,
            ),
            TextField(
              controller:
                  _query,
              onSubmitted:
                  (_) =>
                      _search(),
              decoration:
                  InputDecoration(
                labelText:
                    'Order number or Buyer name',
                border:
                    const OutlineInputBorder(),
                suffixIcon:
                    IconButton(
                  onPressed:
                      _search,
                  icon:
                      const Icon(
                    Icons.search,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (_busy)
              const LinearProgressIndicator(),
            if (_error !=
                null)
              Text(
                _error!,
                style:
                    const TextStyle(
                  color:
                      Colors.red,
                ),
              ),
            ..._items.map(
              (m) =>
                  Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 9,
                ),
                child:
                    LogisticsSurface(
                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        '${m['order_number'] ?? ''}',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                      Text(
                        'Status: ${m['status'] ?? ''}',
                      ),
                      Text(
                        'Buyer: ${m['buyer_name'] ?? ''}',
                      ),
                      Text(
                        'Rider: ${m['courier_name'] ?? ''}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_items.isEmpty &&
                !_busy &&
                _error == null)
              const Text(
                'Search for an order to see live records.',
              ),
          ],
        ),
      );
}