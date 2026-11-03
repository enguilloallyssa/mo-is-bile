import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'widgets/rider_ui.dart';

class RiderRemittances extends StatefulWidget {
  const RiderRemittances({
    super.key,
  });

  @override
  State<RiderRemittances> createState() =>
      _RiderRemittancesState();
}

class _RiderRemittancesState
    extends State<RiderRemittances> {
  final List<Map<String, dynamic>> _eligible = [];

  final List<Map<String, dynamic>> _batches = [];

  final Set<int> _selected = {};

  bool _loading = true;
  bool _submitting = false;

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

  int _int(
    dynamic value,
  ) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          '$value',
        ) ??
        0;
  }

  double _double(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          '$value',
        ) ??
        0;
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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results =
          await Future.wait([
        SariLiveData.instance
            .riderEligibleRemittances(),
        SariLiveData.instance
            .riderRemittances(),
      ]);

      final eligible =
          results[0]['data'] is List
              ? (results[0]['data'] as List)
                  .map(_map)
                  .toList()
              : <Map<String, dynamic>>[];

      final batches =
          results[1]['data'] is List
              ? (results[1]['data'] as List)
                  .map(_map)
                  .toList()
              : <Map<String, dynamic>>[];

      if (!mounted) {
        return;
      }

      setState(() {
        _eligible
          ..clear()
          ..addAll(
            eligible,
          );

        _batches
          ..clear()
          ..addAll(
            batches,
          );

        _selected.removeWhere(
          (id) => !_eligible.any(
            (entry) =>
                _int(
                  entry['id'],
                ) ==
                id,
          ),
        );

        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            error.toString();

        _loading = false;
      });
    }
  }

  double get _selectedCash {
    return _eligible
        .where(
          (entry) =>
              _selected.contains(
            _int(
              entry['id'],
            ),
          ),
        )
        .fold<double>(
          0,
          (
            sum,
            entry,
          ) =>
              sum +
              _double(
                entry['total'],
              ),
        );
  }

  double get _totalEligibleCash {
    return _eligible.fold<double>(
      0,
      (
        sum,
        entry,
      ) =>
          sum +
          _double(
            entry['total'],
          ),
    );
  }

  Future<void> _submit() async {
    if (_selected.isEmpty ||
        _submitting) {
      return;
    }

    final noteController =
        TextEditingController();

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title:
              const Text(
            'Prepare COD Remittance',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                '${_selected.length} '
                '${_selected.length == 1 ? 'order' : 'orders'} selected',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Text(
                'Cash to remit: '
                '₱${_selectedCash.toStringAsFixed(2)}',
                style:
                    TextStyle(
                  color:
                      RiderColors.goldDark,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              TextField(
                controller:
                    noteController,
                minLines: 2,
                maxLines: 4,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Note (optional)',
                  hintText:
                      'Add notes about this cash batch.',
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                'Submitting creates a COD remittance batch. '
                'Physical cash still needs to be handed over '
                'and verified by SARI Logistics.',
                style:
                    TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 9,
                  height: 1.45,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(
                false,
              ),
              child:
                  const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(
                true,
              ),
              child:
                  const Text(
                'Submit',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      noteController.dispose();

      return;
    }

    final note =
        noteController.text.trim();

    noteController.dispose();

    setState(() {
      _submitting = true;
    });

    try {
      final response =
          await SariLiveData.instance
              .riderSubmitRemittance(
        _selected.toList(),
        note:
            note.isEmpty
                ? null
                : note,
      );

      if (!mounted) {
        return;
      }

      _message(
        response['message']
                ?.toString() ??
            'Remittance batch prepared.',
      );

      _selected.clear();

      await _load();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _message(
        error.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _toggleOrder(
    int id,
    bool selected,
  ) {
    setState(() {
      if (selected) {
        _selected.add(
          id,
        );
      } else {
        _selected.remove(
          id,
        );
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selected.length ==
          _eligible.length) {
        _selected.clear();

        return;
      }

      _selected
        ..clear()
        ..addAll(
          _eligible.map(
            (entry) =>
                _int(
              entry['id'],
            ),
          ),
        );
    });
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
              Text(
            message,
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  String _statusLabel(
    String value,
  ) {
    final cleaned =
        value
            .replaceAll(
              '_',
              ' ',
            )
            .trim();

    if (cleaned.isEmpty) {
      return 'Unknown';
    }

    return cleaned
        .split(' ')
        .where(
          (part) =>
              part.isNotEmpty,
        )
        .map(
          (part) =>
              '${part[0].toUpperCase()}'
              '${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Color _statusColor(
    String status,
  ) {
    switch (status) {
      case 'verified':
      case 'completed':
      case 'received':
        return RiderColors.green;

      case 'cancelled':
      case 'rejected':
        return RiderColors.red;

      case 'pending':
      case 'submitted':
      default:
        return RiderColors.goldDark;
    }
  }

  Color _statusSoft(
    String status,
  ) {
    switch (status) {
      case 'verified':
      case 'completed':
      case 'received':
        return RiderColors.greenSoft;

      case 'cancelled':
      case 'rejected':
        return RiderColors.redSoft;

      case 'pending':
      case 'submitted':
      default:
        return RiderColors.goldSoft;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          RiderColors.bg,
      appBar: AppBar(
        backgroundColor:
            RiderColors.surface,
        foregroundColor:
            RiderColors.text,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        title:
            const RiderHeaderTitle(
          title:
              'COD Cash Remittance',
          subtitle:
              'Cash Collection Management',
        ),
        actions: [
          IconButton(
            tooltip:
                'Refresh',
            onPressed:
                _loading
                    ? null
                    : _load,
            icon:
                const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _error != null
              ? _errorState()
              : RefreshIndicator(
                  color:
                      RiderColors.gold,
                  onRefresh:
                      _load,
                  child:
                      ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      36,
                    ),
                    children: [
                      _hero(),

                      const SizedBox(
                        height: 18,
                      ),

                      _summary(),

                      const SizedBox(
                        height: 24,
                      ),

                      _section(
                        'Eligible COD Parcels',
                        'Delivered COD orders whose cash has not yet been included in a remittance batch.',
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _eligibleSection(),

                      if (_selected
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 14,
                        ),

                        _selectedSummary(),
                      ],

                      const SizedBox(
                        height: 26,
                      ),

                      _section(
                        'Recent Cash Batches',
                        'COD remittance batches prepared for physical turnover.',
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      if (_batches.isEmpty)
                        _empty(
                          icon: Icons
                              .receipt_long_outlined,
                          title:
                              'No remittance batches yet',
                          message:
                              'Batches you prepare will appear here.',
                        )
                      else
                        ..._batches
                            .take(20)
                            .map(
                          (batch) =>
                              Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child:
                                _batchCard(
                              batch,
                            ),
                          ),
                        ),

                      const SizedBox(
                        height: 17,
                      ),

                      _notice(),
                    ],
                  ),
                ),
    );
  }

  Widget _hero() {
    return Container(
      padding:
          const EdgeInsets.all(
        21,
      ),
      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          colors:
              RiderColors.heroGradient,
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(
          22,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons
                    .account_balance_wallet_outlined,
                color:
                    Colors.white70,
                size: 18,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'CASH COLLECTION OPERATIONS',
                style:
                    TextStyle(
                  color:
                      Colors.white70,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing:
                      1.2,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          const Text(
            'COD Remittance',
            style:
                TextStyle(
              color:
                  Colors.white,
              fontSize: 26,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          const Text(
            'Prepare collected COD cash for physical handover to SARI Logistics.',
            style:
                TextStyle(
              color:
                  Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(
            height: 19,
          ),

          Row(
            children: [
              const Icon(
                Icons
                    .verified_user_outlined,
                color:
                    Colors.white,
                size: 18,
              ),

              const SizedBox(
                width: 8,
              ),

              const Expanded(
                child: Text(
                  'Physical cash turnover only',
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              if (_eligible
                  .isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white
                            .withValues(
                      alpha: .12,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    '${_eligible.length} eligible',
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summary() {
    return Row(
      children: [
        Expanded(
          child: _metric(
            label:
                'Eligible COD Cash',
            value:
                '₱${_totalEligibleCash.toStringAsFixed(2)}',
            icon:
                Icons.payments_outlined,
            accent:
                RiderColors.goldDark,
            soft:
                RiderColors.goldSoft,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: _metric(
            label:
                'Cash Batches',
            value:
                '${_batches.length}',
            icon:
                Icons.inventory_2_outlined,
            accent:
                RiderColors.blue,
            soft:
                RiderColors.blueSoft,
          ),
        ),
      ],
    );
  }

  Widget _metric({
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
    required Color soft,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 37,
            height: 37,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color: soft,
              borderRadius:
                  BorderRadius.circular(
                11,
              ),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 20,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          FittedBox(
            fit:
                BoxFit.scaleDown,
            alignment:
                Alignment.centerLeft,
            child: Text(
              value,
              style:
                  TextStyle(
                color:
                    RiderColors.text,
                fontSize: 20,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            label,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 9,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              TextStyle(
            color:
                RiderColors.text,
            fontSize: 17,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          subtitle,
          style:
              TextStyle(
            color:
                RiderColors.muted,
            fontSize: 10,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _eligibleSection() {
    if (_eligible.isEmpty) {
      return _empty(
        icon:
            Icons.payments_outlined,
        title:
            'No eligible COD orders',
        message:
            'Delivered COD parcels will appear here when cash is ready for remittance.',
      );
    }

    final allSelected =
        _selected.length ==
            _eligible.length;

    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration:
              BoxDecoration(
            color:
                RiderColors.surface,
            borderRadius:
                BorderRadius.circular(
              13,
            ),
            border:
                Border.all(
              color:
                  RiderColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_eligible.length} eligible '
                  '${_eligible.length == 1 ? 'order' : 'orders'}',
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              TextButton(
                onPressed:
                    _selectAll,
                child: Text(
                  allSelected
                      ? 'Clear All'
                      : 'Select All',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 9,
        ),

        ..._eligible.map(
          (entry) {
            final id =
                _int(
              entry['id'],
            );

            final selected =
                _selected.contains(
              id,
            );

            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 9,
              ),
              child: Container(
                decoration:
                    _cardDecoration(),
                child:
                    CheckboxListTile(
                  value:
                      selected,
                  onChanged:
                      (value) =>
                          _toggleOrder(
                    id,
                    value == true,
                  ),
                  controlAffinity:
                      ListTileControlAffinity
                          .leading,
                  activeColor:
                      RiderColors.gold,
                  title:
                      Text(
                    _text(
                      entry[
                          'order_number'],
                      'Order #$id',
                    ),
                    style:
                        TextStyle(
                      color:
                          RiderColors.text,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  subtitle:
                      Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 5,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        if (_text(
                          entry[
                              'buyer_name'],
                        ).isNotEmpty)
                          Text(
                            _text(
                              entry[
                                  'buyer_name'],
                            ),
                            style:
                                TextStyle(
                              color:
                                  RiderColors
                                      .muted,
                              fontSize:
                                  9,
                            ),
                          ),

                        if (_text(
                          entry[
                              'delivered_at'],
                        ).isNotEmpty) ...[
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            'Delivered: '
                            '${_text(entry['delivered_at'])}',
                            style:
                                TextStyle(
                              color:
                                  RiderColors
                                      .muted,
                              fontSize:
                                  8,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  secondary:
                      Text(
                    '₱${_double(entry['total']).toStringAsFixed(2)}',
                    style:
                        TextStyle(
                      color:
                          RiderColors
                              .goldDark,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _selectedSummary() {
    return Container(
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.goldSoft,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              RiderColors.gold
                  .withValues(
            alpha: .30,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      RiderColors.surface,
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
                child: Icon(
                  Icons
                      .account_balance_wallet_outlined,
                  color:
                      RiderColors.goldDark,
                  size: 20,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selected.length} selected',
                      style:
                          TextStyle(
                        color:
                            RiderColors.text,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      'Cash to remit',
                      style:
                          TextStyle(
                        color:
                            RiderColors.muted,
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '₱${_selectedCash.toStringAsFixed(2)}',
                style:
                    TextStyle(
                  color:
                      RiderColors.goldDark,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 13,
          ),

          SizedBox(
            width:
                double.infinity,
            child:
                FilledButton.icon(
              onPressed:
                  _submitting
                      ? null
                      : _submit,
              icon:
                  const Icon(
                Icons
                    .account_balance_outlined,
              ),
              label:
                  Text(
                _submitting
                    ? 'Submitting...'
                    : 'Prepare Cash Batch',
              ),
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    RiderColors.gold,
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _batchCard(
    Map<String, dynamic> batch,
  ) {
    final id =
        _int(
      batch['id'],
    );

    final code =
        _text(
      batch['batch_code'],
      'Batch #$id',
    );

    final status =
        _text(
      batch['status'],
      'pending',
    );

    final total =
        _double(
      batch[
              'total_amount'] ??
          batch['amount'],
    );

    final statusColor =
        _statusColor(
      status,
    );

    final statusSoft =
        _statusSoft(
      status,
    );

    return Container(
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color:
                  statusSoft,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              Icons
                  .receipt_long_outlined,
              color:
                  statusColor,
              size: 21,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        statusSoft,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    _statusLabel(
                      status,
                    ),
                    style:
                        TextStyle(
                      color:
                          statusColor,
                      fontSize: 7.5,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Text(
            '₱${total.toStringAsFixed(2)}',
            style:
                TextStyle(
              color:
                  RiderColors.text,
              fontSize: 12,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        27,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        children: [
          Icon(
            icon,
            color:
                RiderColors.muted,
            size: 40,
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            title,
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  RiderColors.text,
              fontSize: 13,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 9.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notice() {
    return Container(
      padding:
          const EdgeInsets.all(
        12,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.goldSoft,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .info_outline_rounded,
            color:
                RiderColors.goldDark,
            size: 18,
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Text(
              'Creating a remittance batch does not transfer money digitally. '
              'The collected COD cash must still be physically handed over '
              'and verified by SARI Logistics before the related Rider earnings '
              'can become available for payout.',
              style:
                  TextStyle(
                color:
                    RiderColors.text,
                fontSize: 9.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .cloud_off_outlined,
              color:
                  RiderColors.muted,
              size: 48,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              'Unable to load COD remittances',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    RiderColors.text,
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
                  'Unknown error.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    RiderColors.muted,
                fontSize: 10,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            FilledButton.icon(
              onPressed:
                  _load,
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
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color:
          RiderColors.surface,
      borderRadius:
          BorderRadius.circular(
        16,
      ),
      border:
          Border.all(
        color:
            RiderColors.border,
      ),
    );
  }
}