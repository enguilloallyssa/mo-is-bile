import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'logistics_scanner.dart';
import 'widgets/logistics_hub_picker.dart';
import 'widgets/logistics_ui.dart';

class LogisticsQueuePage extends StatefulWidget {
  const LogisticsQueuePage({
    super.key,
    required this.title,
    required this.description,
    required this.endpoint,
    required this.requiresHub,
  });

  final String title;
  final String description;
  final String endpoint;
  final bool requiresHub;

  @override
  State<LogisticsQueuePage> createState() =>
      _LogisticsQueuePageState();
}

class _LogisticsQueuePageState
    extends State<LogisticsQueuePage> {
  int? _hubId;

  bool _busy = false;

  String? _error;

  List<Map<String, dynamic>> _items =
      <Map<String, dynamic>>[];

  List<Map<String, dynamic>> _groups =
      <Map<String, dynamic>>[];

  List<Map<String, dynamic>> _riders =
      <Map<String, dynamic>>[];

  Future<void> _load({
    bool force = false,
  }) async {
    if ((!force && _busy) ||
        (widget.requiresHub &&
            _hubId == null)) {
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final api =
          SariLiveData.instance;

      final Map<String, dynamic>
          result =
          switch (widget.endpoint) {
        'incoming' =>
          await api.logisticsIncoming(
            _hubId!,
          ),
        'sorting' =>
          await api.logisticsSorting(
            _hubId!,
          ),
        'pickups' =>
          await api
              .logisticsPickupRequests(
            _hubId!,
          ),
        'last-mile' =>
          await api.logisticsLastMile(
            _hubId!,
          ),
        _ => throw StateError(
            'Unsupported queue',
          ),
      };

      final data =
          result['data'];

      final map =
          data is Map
              ? Map<String, dynamic>.from(
                  data,
                )
              : <String, dynamic>{};

      final rawItems =
          map['items'];

      final rawGroups =
          map['groups'];

      final rawRiders =
          map['riders'];

      if (!mounted) {
        return;
      }

      setState(() {
        _items =
            rawItems is List
                ? rawItems
                    .whereType<Map>()
                    .map(
                      (m) =>
                          Map<String,
                                  dynamic>.from(
                            m,
                          ),
                    )
                    .toList()
                : <Map<String,
                    dynamic>>[];

        _groups =
            rawGroups is List
                ? rawGroups
                    .whereType<Map>()
                    .map(
                      (m) =>
                          Map<String,
                                  dynamic>.from(
                            m,
                          ),
                    )
                    .toList()
                : <Map<String,
                    dynamic>>[];

        _riders =
            rawRiders is List
                ? rawRiders
                    .whereType<Map>()
                    .map(
                      (m) =>
                          Map<String,
                                  dynamic>.from(
                            m,
                          ),
                    )
                    .toList()
                : <Map<String,
                    dynamic>>[];
      });
    } catch (error) {
      if (mounted) {
        setState(
          () =>
              _error =
                  error.toString(),
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

  void _hubChanged(
    int? id,
  ) {
    _hubId = id;

    _items =
        <Map<String, dynamic>>[];

    _groups =
        <Map<String, dynamic>>[];

    _riders =
        <Map<String, dynamic>>[];

    if (id != null) {
      _load();
    }
  }

  @override
  void initState() {
    super.initState();

    if (!widget.requiresHub) {
      WidgetsBinding.instance
          .addPostFrameCallback(
        (_) => _load(),
      );
    }
  }

  Future<int?> _chooseRider(
    String title,
  ) async {
    final available =
        _riders
            .where(
              (r) =>
                  r['busy'] != true,
            )
            .toList();

    if (available.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content:
                Text(
              'No available online Rider for this operation.',
            ),
          ),
        );
      }

      return null;
    }

    return showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) =>
          SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding:
              const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            20,
          ),
          children: [
            Text(
              title,
              style:
                  const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ...available.map(
              (rider) {
                final id =
                    (rider['id']
                            as num?)
                        ?.toInt();

                return ListTile(
                  leading:
                      const CircleAvatar(
                    child:
                        Icon(
                      Icons
                          .delivery_dining_rounded,
                    ),
                  ),
                  title:
                      Text(
                    '${rider['name'] ?? 'Rider'}',
                  ),
                  subtitle:
                      Text(
                    [
                      if ('${rider['barangay_name'] ?? ''}'
                          .isNotEmpty)
                        rider[
                            'barangay_name'],
                      if ('${rider['municipality_name'] ?? ''}'
                          .isNotEmpty)
                        rider[
                            'municipality_name'],
                      if ('${rider['vehicle_type'] ?? ''}'
                          .isNotEmpty)
                        rider[
                            'vehicle_type'],
                    ].join(
                      ' • ',
                    ),
                  ),
                  onTap: id == null
                      ? null
                      : () =>
                          Navigator.pop(
                            sheetContext,
                            id,
                          ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<int> _ids(
    Map<String, dynamic> group,
  ) {
    final raw =
        group['order_ids'];

    return raw is List
        ? raw
            .whereType<num>()
            .map(
              (n) =>
                  n.toInt(),
            )
            .toList()
        : <int>[];
  }

  Future<void> _verifyPickup(
    Map<String, dynamic> group,
  ) async {
    if (_hubId == null) {
      return;
    }

    final ids =
        _ids(group);

    if (ids.isEmpty) {
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
              .logisticsVerifyPickups(
        _hubId!,
        ids,
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text(
              '${response['message'] ?? 'Pickup verified.'}',
            ),
          ),
        );
      }

      await _load(
        force: true,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text(
              e.toString(),
            ),
          ),
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

  Future<void> _assignPickup(
    Map<String, dynamic> group,
  ) async {
    if (_hubId == null) {
      return;
    }

    final riderId =
        await _chooseRider(
      'Assign pickup Rider',
    );

    if (riderId == null ||
        !mounted) {
      return;
    }

    final ids =
        _ids(group);

    setState(
      () =>
          _busy =
              true,
    );

    try {
      final response =
          await SariLiveData
              .instance
              .logisticsAssignPickup(
        _hubId!,
        riderId,
        ids,
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text(
              '${response['message'] ?? 'Pickup assigned.'}',
            ),
          ),
        );
      }

      await _load(
        force: true,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text(
              e.toString(),
            ),
          ),
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

  Future<void> _assignLastMile(
    Map<String, dynamic> group,
  ) async {
    if (_hubId == null) {
      return;
    }

    final riderId =
        await _chooseRider(
      'Assign last-mile Rider',
    );

    if (riderId == null ||
        !mounted) {
      return;
    }

    final ids =
        _ids(group);

    setState(
      () =>
          _busy =
              true,
    );

    try {
      final response =
          await SariLiveData
              .instance
              .logisticsAssignLastMile(
        _hubId!,
        riderId,
        ids,
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text(
              '${response['message'] ?? 'Last-mile batch assigned.'}',
            ),
          ),
        );
      }

      await _load(
        force: true,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text(
              e.toString(),
            ),
          ),
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

  Widget _simpleItems() {
    if (_items.isEmpty &&
        !_busy &&
        _error == null) {
      return const LogisticsEmptyCard(
        icon:
            Icons.inventory_2_outlined,
        title:
            'No parcels in this queue',
        message:
            'Live Laravel records will appear here when assigned.',
      );
    }

    return Column(
      children:
          _items.map(
        (item) =>
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
                  '${item['order_number'] ?? 'Parcel'}',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize:
                        15,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'Status: ${item['status'] ?? ''}',
                ),
                if (item[
                        'buyer_name'] !=
                    null)
                  Text(
                    'Buyer: ${item['buyer_name']}',
                  ),
                if (item[
                            'sorting_zone'] !=
                        null &&
                    '${item['sorting_zone']}'
                        .isNotEmpty)
                  Text(
                    'Zone: ${item['sorting_zone']}',
                  ),
              ],
            ),
          ),
        ),
      ).toList(),
    );
  }

  Widget _pickupGroups() {
    if (_groups.isEmpty &&
        !_busy &&
        _error == null) {
      return const LogisticsEmptyCard(
        icon:
            Icons.fact_check_outlined,
        title:
            'No pickup requests',
        message:
            'Verified Seller pickup groups will appear here.',
      );
    }

    return Column(
      children:
          _groups.map(
        (group) {
          final ready =
              group[
                      'ready_for_assignment'] ==
                  true;

          final attention =
              (group['attention_count']
                          as num?)
                      ?.toInt() ??
                  0;

          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 10,
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
                    '${group['seller_name'] ?? 'Seller Pickup'}',
                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight
                              .w900,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${group['pickup_address'] ?? ''}',
                    style:
                        const TextStyle(
                      color:
                          LogisticsPalette
                              .muted,
                    ),
                  ),
                  const SizedBox(
                    height: 9,
                  ),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      LogisticsTag(
                        label:
                            '${group['order_count'] ?? 0} parcels',
                      ),
                      LogisticsTag(
                        label:
                            '${group['verified_count'] ?? 0} verified',
                        color:
                            LogisticsPalette
                                .green,
                        background:
                            LogisticsPalette
                                .greenPale,
                      ),
                      if (attention >
                          0)
                        LogisticsTag(
                          label:
                              '$attention attention',
                          color:
                              LogisticsPalette
                                  .danger,
                          background:
                              const Color(
                            0xFFFFEEEE,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child:
                            OutlinedButton.icon(
                          onPressed: _busy ||
                                  ready ||
                                  attention >
                                      0
                              ? null
                              : () =>
                                  _verifyPickup(
                                    group,
                                  ),
                          icon:
                              const Icon(
                            Icons
                                .verified_outlined,
                          ),
                          label:
                              const Text(
                            'Verify Batch',
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child:
                            FilledButton.icon(
                          onPressed: _busy ||
                                  !ready
                              ? null
                              : () =>
                                  _assignPickup(
                                    group,
                                  ),
                          icon:
                              const Icon(
                            Icons
                                .delivery_dining_rounded,
                          ),
                          label:
                              const Text(
                            'Assign Rider',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _lastMileGroups() {
    if (_groups.isEmpty &&
        !_busy &&
        _error == null) {
      return const LogisticsEmptyCard(
        icon:
            Icons.local_shipping_outlined,
        title:
            'No last-mile parcels',
        message:
            'Destination-received parcels will appear here by barangay.',
      );
    }

    return Column(
      children:
          _groups
              .map(
                (group) =>
                    Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 10,
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
                          '${group['delivery_area'] ?? 'Delivery Area'}',
                          style:
                              const TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight
                                    .w900,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          '${group['destination_facility_name'] ?? ''} • ${group['municipality_name'] ?? ''}',
                          style:
                              const TextStyle(
                            color:
                                LogisticsPalette
                                    .muted,
                          ),
                        ),
                        const SizedBox(
                          height: 9,
                        ),
                        LogisticsTag(
                          label:
                              '${group['order_count'] ?? 0} parcels',
                          color:
                              LogisticsPalette
                                  .green,
                          background:
                              LogisticsPalette
                                  .greenPale,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        SizedBox(
                          width:
                              double.infinity,
                          child:
                              FilledButton.icon(
                            onPressed: _busy
                                ? null
                                : () =>
                                    _assignLastMile(
                                      group,
                                    ),
                            icon:
                                const Icon(
                              Icons
                                  .person_add_alt_1_rounded,
                            ),
                            label:
                                const Text(
                              'Assign Local Rider',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      Scaffold(
        backgroundColor:
            LogisticsPalette.canvas,
        appBar: AppBar(
          title:
              Text(
            widget.title,
          ),
          actions: [
            IconButton(
              icon:
                  const Icon(
                Icons.refresh,
              ),
              onPressed:
                  _load,
            ),
          ],
        ),
        body:
            RefreshIndicator(
          onRefresh:
              _load,
          child:
              ListView(
            padding:
                const EdgeInsets.all(
              16,
            ),
            children: [
              LogisticsSectionTitle(
                title:
                    widget.title,
                subtitle:
                    widget.description,
              ),
              const SizedBox(
                height: 12,
              ),
              if (widget
                  .requiresHub) ...[
                LogisticsHubPicker(
                  onChanged:
                      _hubChanged,
                ),
                const SizedBox(
                  height: 14,
                ),
              ],
              if (_busy)
                const LinearProgressIndicator(),
              if (_error != null)
                Padding(
                  padding:
                      const EdgeInsets.all(
                    12,
                  ),
                  child:
                      Text(
                    _error!,
                    style:
                        const TextStyle(
                      color:
                          Colors.red,
                    ),
                  ),
                ),
              if (widget.endpoint ==
                  'pickups')
                _pickupGroups()
              else if (widget.endpoint ==
                  'last-mile')
                _lastMileGroups()
              else
                _simpleItems(),
              const SizedBox(
                height: 12,
              ),
              if (widget.endpoint ==
                      'incoming' ||
                  widget.endpoint ==
                      'sorting')
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(
                    context,
                  )
                          .push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const LogisticsScanner(
                        standalone:
                            true,
                      ),
                    ),
                  )
                          .then(
                    (_) =>
                        _load(),
                  ),
                  icon:
                      const Icon(
                    Icons
                        .qr_code_scanner,
                  ),
                  label:
                      const Text(
                    'Verify QR before processing',
                  ),
                ),
            ],
          ),
        ),
      );
}

class LogisticsIncomingPage
    extends StatelessWidget {
  const LogisticsIncomingPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) =>
      const LogisticsQueuePage(
        title:
            'Incoming Parcels',
        description:
            'Live origin-hub intake queue',
        endpoint:
            'incoming',
        requiresHub:
            true,
      );
}

class LogisticsSortingPage
    extends StatelessWidget {
  const LogisticsSortingPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) =>
      const LogisticsQueuePage(
        title:
            'Parcel Sorting',
        description:
            'Parcels waiting to be sorted',
        endpoint:
            'sorting',
        requiresHub:
            true,
      );
}

class LogisticsPickupRequestsPage
    extends StatelessWidget {
  const LogisticsPickupRequestsPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) =>
      const LogisticsQueuePage(
        title:
            'Pickup Requests',
        description:
            'Verify complete Seller pickup groups and assign one Rider',
        endpoint:
            'pickups',
        requiresHub:
            true,
      );
}

class LogisticsLastMilePage
    extends StatelessWidget {
  const LogisticsLastMilePage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) =>
      const LogisticsQueuePage(
        title:
            'Last-Mile Queue',
        description:
            'Destination parcels grouped by barangay for Rider assignment',
        endpoint:
            'last-mile',
        requiresHub:
            true,
      );
}