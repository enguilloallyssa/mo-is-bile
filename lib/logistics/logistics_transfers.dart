import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'widgets/logistics_hub_picker.dart';
import 'widgets/logistics_ui.dart';

class LogisticsTransfers
    extends StatefulWidget {
  const LogisticsTransfers({
    super.key,
    required this.onScan,
  });

  final VoidCallback onScan;

  @override
  State<LogisticsTransfers>
      createState() =>
          _LogisticsTransfersState();
}

class _LogisticsTransfersState
    extends State<LogisticsTransfers> {
  int? _hubId;

  bool _busy = false;

  String? _error;

  List<Map<String, dynamic>>
      _transfers = [];

  Future<void> _load({
    bool force = false,
  }) async {
    if (_hubId == null ||
        (_busy && !force)) {
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final response =
          await SariLiveData
              .instance
              .logisticsTransfers(
        facilityId: _hubId,
      );

      final data =
          response['data'];

      final items =
          data is Map
              ? data['items']
              : null;

      if (!mounted) {
        return;
      }

      setState(
        () => _transfers =
            items is List
                ? items
                    .whereType<Map>()
                    .map(
                      (e) =>
                          Map<String,
                                  dynamic>.from(
                            e,
                          ),
                    )
                    .toList()
                : [],
      );
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

  void _hubChanged(
    int? id,
  ) {
    _hubId = id;

    _transfers = [];

    if (id != null) {
      _load();
    }
  }

  Future<void> _submit(
    int id,
    String action,
  ) async {
    if (_hubId == null ||
        _busy) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (ctx) =>
          AlertDialog(
        title: Text(
          action == 'dispatch'
              ? 'Dispatch transfer?'
              : 'Receive transfer?',
        ),
        content: const Text(
          'This updates the whole manifest and the shared Laravel parcel status. Confirm only after physical verification.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              ctx,
              false,
            ),
            child:
                const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(
              ctx,
              true,
            ),
            child:
                const Text(
              'Confirm',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    setState(
      () =>
          _busy =
              true,
    );

    try {
      await SariLiveData
          .instance
          .logisticsTransferAction(
        id,
        _hubId!,
        action,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text(
            'Transfer updated on server.',
          ),
        ),
      );

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

  @override
  Widget build(
    BuildContext context,
  ) {
    final hubId =
        _hubId;

    return RefreshIndicator(
      onRefresh:
          _load,
      child:
          ListView(
        padding:
            const EdgeInsets.fromLTRB(
          15,
          18,
          15,
          35,
        ),
        children: [
          LogisticsSectionTitle(
            title:
                'Hub Transfers',
            subtitle:
                'Live manifest movement between SARI hubs.',
            trailing:
                IconButton(
              onPressed:
                  _load,
              icon:
                  const Icon(
                Icons.refresh,
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          LogisticsHubPicker(
            onChanged:
                _hubChanged,
          ),
          const SizedBox(
            height: 12,
          ),
          OutlinedButton.icon(
            onPressed:
                widget.onScan,
            icon:
                const Icon(
              Icons
                  .qr_code_scanner,
            ),
            label:
                const Text(
              'Scan parcel QR',
            ),
          ),
          if (_busy)
            const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding:
                  const EdgeInsets.all(
                10,
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
          if (_transfers.isEmpty &&
              !_busy &&
              _error == null)
            const LogisticsEmptyCard(
              icon:
                  Icons.swap_horiz_rounded,
              title:
                  'No active transfers',
              message:
                  'No hub transfers found for the selected facility.',
            ),
          ..._transfers.map(
            (item) {
              final status =
                  '${item['status'] ?? ''}';

              final origin =
                  (item['origin_facility_id']
                          as num?)
                      ?.toInt();

              final destination =
                  (item['destination_facility_id']
                          as num?)
                      ?.toInt();

              final id =
                  (item['id'] as num?)
                          ?.toInt() ??
                      0;

              final canDispatch =
                  status ==
                          'preparing' &&
                      origin ==
                          hubId;

              final canReceive =
                  status ==
                          'in_transit' &&
                      destination ==
                          hubId;

              return Padding(
                padding:
                    const EdgeInsets.only(
                  top: 10,
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
                        '${item['transfer_code'] ?? id}',
                        style:
                            const TextStyle(
                          fontSize:
                              15,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${item['origin_name']} → ${item['destination_name']}',
                      ),
                      Text(
                        'Status: $status',
                        style:
                            const TextStyle(
                          color:
                              LogisticsPalette
                                  .muted,
                        ),
                      ),
                      if (canDispatch ||
                          canReceive) ...[
                        const SizedBox(
                          height: 10,
                        ),
                        FilledButton.icon(
                          onPressed: _busy
                              ? null
                              : () =>
                                  _submit(
                                    id,
                                    canDispatch
                                        ? 'dispatch'
                                        : 'receive',
                                  ),
                          icon:
                              const Icon(
                            Icons
                                .check_circle_outline,
                          ),
                          label:
                              Text(
                            canDispatch
                                ? 'Dispatch manifest'
                                : 'Receive manifest',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            height: 14,
          ),
          const Text(
            'Creation and multi-parcel manifest planning remain on the web. Dispatch and receipt use live shared parcel records.',
          ),
        ],
      ),
    );
  }
}