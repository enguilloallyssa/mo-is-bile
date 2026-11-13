import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'widgets/rider_ui.dart';

class RiderRemittances extends StatefulWidget {
  const RiderRemittances({super.key});

  @override
  State<RiderRemittances> createState() =>
      _RiderRemittancesState();
}

class _RiderRemittancesState extends State<RiderRemittances> {
  final List<Map<String, dynamic>> _eligible = [];
  final List<Map<String, dynamic>> _batches = [];
  final List<Map<String, dynamic>> _hubs = [];

  final Set<int> _selected = {};

  bool _loading = true;
  bool _hubsLoading = true;
  bool _submitting = false;

  String? _error;
  String? _hubsError;

  @override
  void initState() {
    super.initState();
    _load();
    _loadHubs();
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  int _int(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  double _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  String _text(dynamic value, [String fallback = '']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _money(double value) {
    return '₱${value.toStringAsFixed(2)}';
  }

  double get _totalEligibleCash {
    return _eligible.fold<double>(
      0,
      (sum, item) => sum + _double(item['total']),
    );
  }

  double get _selectedCash {
    return _eligible
        .where((item) => _selected.contains(_int(item['id'])))
        .fold<double>(
          0,
          (sum, item) => sum + _double(item['total']),
        );
  }

  // --------------------------------------------------
  // LOAD DATA
  // --------------------------------------------------

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        SariLiveData.instance.riderEligibleRemittances(),
        SariLiveData.instance.riderRemittances(),
      ]);

      final eligible = results[0]['data'] is List
          ? (results[0]['data'] as List).map(_map).toList()
          : <Map<String, dynamic>>[];

      final batches = results[1]['data'] is List
          ? (results[1]['data'] as List).map(_map).toList()
          : <Map<String, dynamic>>[];

      if (!mounted) return;

      setState(() {
        _eligible
          ..clear()
          ..addAll(eligible);

        _batches
          ..clear()
          ..addAll(batches);

        final validIds = _eligible
            .map((item) => _int(item['id']))
            .where((id) => id > 0)
            .toSet();

        _selected.removeWhere(
          (id) => !validIds.contains(id),
        );

        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _loadHubs() async {
    if (!mounted) return;

    setState(() {
      _hubsLoading = true;
      _hubsError = null;
    });

    try {
      final response =
          await SariLiveData.instance.riderRemittanceHubs();

      final data = response['data'];

      if (data is! List) {
        throw const FormatException(
          'Invalid Logistics hub directory.',
        );
      }

      if (!mounted) return;

      setState(() {
        _hubs
          ..clear()
          ..addAll(
            data
                .map(_map)
                .where((hub) => _int(hub['id']) > 0),
          );

        _hubsLoading = false;
        _hubsError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _hubsLoading = false;
        _hubsError = error.toString();
      });
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _load(),
      _loadHubs(),
    ]);
  }

  // --------------------------------------------------
  // SELECT / DESELECT COD ORDERS
  // --------------------------------------------------

  void _toggleOrder(int id, bool selected) {
    if (id <= 0) return;

    setState(() {
      if (selected) {
        _selected.add(id);
      } else {
        _selected.remove(id);
      }
    });
  }

  void _selectAll() {
    final eligibleIds = _eligible
        .map((item) => _int(item['id']))
        .where((id) => id > 0)
        .toSet();

    if (eligibleIds.isEmpty) return;

    final allSelected = eligibleIds.every(
      (id) => _selected.contains(id),
    );

    setState(() {
      if (allSelected) {
        _selected.removeAll(eligibleIds);
      } else {
        _selected.addAll(eligibleIds);
      }
    });
  }

  // --------------------------------------------------
  // SUBMIT REMITTANCE
  // --------------------------------------------------

  Future<void> _submit() async {
    if (_selected.isEmpty || _submitting) return;

    if (_hubsLoading) {
      _message(
        'Loading available Logistics hubs. Please try again.',
      );
      return;
    }

    if (_hubsError != null) {
      _message(
        'Unable to load Logistics hubs. Please retry.',
      );
      await _loadHubs();
      return;
    }

    if (_hubs.isEmpty) {
      _message(
        'No active Logistics hub is available for cash turnover.',
      );
      return;
    }

    final noteController = TextEditingController();

    int? selectedHubId = _hubs.length == 1
        ? _int(_hubs.first['id'])
        : null;

    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, updateDialog) {
            return AlertDialog(
              title: const Text(
                'Prepare COD Remittance',
              ),
              scrollable: true,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selected.length} parcels selected',
                    style: TextStyle(
                      color: RiderColors.muted,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _money(_selectedCash),
                    style: TextStyle(
                      color: RiderColors.goldDark,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<int>(
                    key: ValueKey(
                      'hub-${selectedHubId ?? 0}',
                    ),
                    initialValue: selectedHubId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Physical Turnover Hub *',
                      border: OutlineInputBorder(),
                      helperText:
                          'Choose where you will hand over the cash.',
                    ),
                    items: _hubs.map((hub) {
                      return DropdownMenuItem<int>(
                        value: _int(hub['id']),
                        child: Text(
                          _text(
                            hub['name'],
                            'Logistics Hub',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      updateDialog(() {
                        selectedHubId = value;
                      });
                    },
                  ),

                  if (selectedHubId != null) ...[
                    const SizedBox(height: 10),

                    Text(
                      _text(
                        _hubs.firstWhere(
                          (hub) =>
                              _int(hub['id']) ==
                              selectedHubId,
                        )['address'],
                      ),
                      style: TextStyle(
                        color: RiderColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  TextField(
                    controller: noteController,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                      labelText: 'Rider Note (optional)',
                      hintText:
                          'Details about the cash turnover',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'This prepares a physical cash remittance batch. '
                    'The selected Logistics hub must still verify '
                    'the cash before the remittance is completed.',
                    style: TextStyle(
                      color: RiderColors.muted,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),

                FilledButton(
                  onPressed: selectedHubId == null
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(
                            selectedHubId,
                          );
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: RiderColors.gold,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Prepare Batch',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    final note = noteController.text.trim();
    noteController.dispose();

    if (selected == null || !mounted) return;

    setState(() {
      _submitting = true;
    });

    try {
      final response =
          await SariLiveData.instance.riderSubmitRemittance(
        _selected.toList(),
        facilityId: selected,
        note: note.isEmpty ? null : note,
      );

      if (!mounted) return;

      _message(
        _text(
          response['message'],
          'COD remittance batch prepared.',
        ),
      );

      setState(() {
        _selected.clear();
      });

      await _refreshAll();
    } catch (error) {
      _message(
        'Unable to submit COD remittance: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  // --------------------------------------------------
  // HELPERS
  // --------------------------------------------------

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _statusLabel(String status) {
    final cleaned = status
        .replaceAll('_', ' ')
        .trim();

    if (cleaned.isEmpty) return 'Unknown';

    return cleaned
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}'
              '${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'verified':
      case 'completed':
      case 'received':
        return RiderColors.green;

      case 'cancelled':
      case 'rejected':
        return RiderColors.red;

      default:
        return RiderColors.goldDark;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'verified':
      case 'completed':
      case 'received':
        return RiderColors.greenSoft;

      case 'cancelled':
      case 'rejected':
        return RiderColors.redSoft;

      default:
        return RiderColors.goldSoft;
    }
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: RiderColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: RiderColors.border,
      ),
    );
  }

  // --------------------------------------------------
  // MAIN SCREEN
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        backgroundColor: RiderColors.surface,
        foregroundColor: RiderColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const RiderHeaderTitle(
          title: 'COD Cash Remittance',
          subtitle: 'Cash Collection Management',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _refreshAll,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading && _eligible.isEmpty && _batches.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: RiderColors.gold,
              ),
            )
          : _error != null &&
                  _eligible.isEmpty &&
                  _batches.isEmpty
              ? _errorState()
              : RefreshIndicator(
                  color: RiderColors.gold,
                  onRefresh: _refreshAll,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      36,
                    ),
                    children: [
                      _hero(),

                      const SizedBox(height: 18),

                      _summary(),

                      const SizedBox(height: 24),

                      _sectionHeader(
                        'Eligible COD Parcels',
                        'Delivered COD orders awaiting physical cash remittance.',
                      ),

                      const SizedBox(height: 12),

                      _eligibleSection(),

                      if (_selected.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _selectedSummary(),
                      ],

                      const SizedBox(height: 26),

                      _sectionHeader(
                        'Recent Cash Batches',
                        'Remittance batches prepared for physical turnover.',
                      ),

                      const SizedBox(height: 12),

                      if (_batches.isEmpty)
                        _emptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'No remittance batches yet',
                          message:
                              'Batches you prepare will appear here.',
                        )
                      else
                        ..._batches.take(20).map(
                              (batch) => Padding(
                                padding:
                                    const EdgeInsets.only(
                                  bottom: 10,
                                ),
                                child: _batchCard(batch),
                              ),
                            ),

                      const SizedBox(height: 18),

                      _notice(),
                    ],
                  ),
                ),
    );
  }

  // --------------------------------------------------
  // HERO
  // --------------------------------------------------

  Widget _hero() {
    return RiderEditorialHero(
      eyebrow: 'CASH COLLECTION OPERATIONS',
      title: 'COD Remittance',
      description: 'Prepare collected COD cash for physical handover to SARI Logistics.',
      icon: Icons.account_balance_wallet_outlined,
      footer: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: RiderColors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Physical cash turnover only',
              style: TextStyle(
                color: RiderColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
              ),
            ),
          ),
          if (_eligible.isNotEmpty)
            RiderStatusPill(
              label: '${_eligible.length} eligible',
              color: RiderColors.goldDark,
              background: RiderColors.goldSoft,
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SUMMARY
  // --------------------------------------------------

  Widget _summary() {
    return Row(
      children: [
        Expanded(
          child: _metric(
            label: 'Eligible COD Cash',
            value: _money(_totalEligibleCash),
            icon: Icons.payments_outlined,
            accent: RiderColors.goldDark,
            soft: RiderColors.goldSoft,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _metric(
            label: 'Cash Batches',
            value: '${_batches.length}',
            icon: Icons.inventory_2_outlined,
            accent: RiderColors.blue,
            soft: RiderColors.blueSoft,
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
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RiderIconBadge(
            icon: icon,
            color: accent,
            background: soft,
            size: 39,
            iconSize: 20,
            radius: 12,
          ),

          const SizedBox(height: 12),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            label,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: RiderColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: TextStyle(
            color: RiderColors.muted,
            fontSize: 10,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // ELIGIBLE COD ORDERS
  // --------------------------------------------------

  Widget _eligibleSection() {
    if (_eligible.isEmpty) {
      return _emptyState(
        icon: Icons.payments_outlined,
        title: 'No eligible COD orders',
        message:
            'Delivered COD parcels will appear here '
            'when cash is ready for remittance.',
      );
    }

    final eligibleIds = _eligible
        .map((item) => _int(item['id']))
        .where((id) => id > 0)
        .toSet();

    final allSelected = eligibleIds.isNotEmpty &&
        eligibleIds.every(
          (id) => _selected.contains(id),
        );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: RiderColors.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: RiderColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_eligible.length} eligible '
                  '${_eligible.length == 1 ? 'order' : 'orders'}',
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              TextButton(
                onPressed: _selectAll,
                child: Text(
                  allSelected
                      ? 'Clear All'
                      : 'Select All',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 9),

        ..._eligible.map((item) {
          final id = _int(item['id']);

          final selected = _selected.contains(id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Container(
              decoration: _cardDecoration(),
              child: CheckboxListTile(
                value: selected,
                onChanged: id <= 0
                    ? null
                    : (value) {
                        _toggleOrder(
                          id,
                          value == true,
                        );
                      },
                controlAffinity:
                    ListTileControlAffinity.leading,
                activeColor: RiderColors.gold,
                title: Text(
                  _text(
                    item['order_number'],
                    'Order #$id',
                  ),
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      if (_text(item['buyer_name']).isNotEmpty)
                        Text(
                          _text(item['buyer_name']),
                          style: TextStyle(
                            color: RiderColors.muted,
                            fontSize: 9,
                          ),
                        ),

                      if (_text(item['delivered_at']).isNotEmpty) ...[
                        const SizedBox(height: 3),

                        Text(
                          'Delivered: '
                          '${_text(item['delivered_at'])}',
                          style: TextStyle(
                            color: RiderColors.muted,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                secondary: Text(
                  _money(
                    _double(item['total']),
                  ),
                  style: TextStyle(
                    color: RiderColors.goldDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // --------------------------------------------------
  // SELECTED CASH SUMMARY
  // --------------------------------------------------

  Widget _selectedSummary() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: RiderColors.goldSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RiderColors.gold.withValues(
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
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: RiderColors.surface,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: RiderColors.goldDark,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selected.length} selected',
                      style: TextStyle(
                        color: RiderColors.text,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Cash to remit',
                      style: TextStyle(
                        color: RiderColors.muted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                _money(_selectedCash),
                style: TextStyle(
                  color: RiderColors.goldDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.account_balance_outlined,
                    ),
              label: Text(
                _submitting
                    ? 'Submitting...'
                    : 'Prepare Cash Batch',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: RiderColors.gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // REMITTANCE BATCH CARD
  // --------------------------------------------------

  Widget _batchCard(Map<String, dynamic> batch) {
    final id = _int(batch['id']);

    final code = _text(
      batch['batch_code'],
      'Batch #$id',
    );

    final status = _text(
      batch['status'],
      'pending',
    );

    final total = _double(
      batch['total_amount'] ?? batch['amount'],
    );

    final statusColor = _statusColor(status);
    final statusBackground = _statusBackground(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: statusColor,
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            _money(total),
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // EMPTY STATE
  // --------------------------------------------------

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(27),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(
            icon,
            color: RiderColors.muted,
            size: 40,
          ),

          const SizedBox(height: 11),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // IMPORTANT NOTICE
  // --------------------------------------------------

  Widget _notice() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RiderColors.goldSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: RiderColors.goldDark,
            size: 18,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              'Preparing a remittance batch does not transfer '
              'cash digitally. The collected COD cash must be '
              'physically handed over and verified by SARI Logistics '
              'before related Rider earnings become available '
              'for payout.',
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 9.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // ERROR STATE
  // --------------------------------------------------

  Widget _errorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              color: RiderColors.muted,
              size: 48,
            ),

            const SizedBox(height: 12),

            Text(
              'Unable to load COD remittances',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _error ?? 'Unknown error.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: RiderColors.muted,
                fontSize: 10,
              ),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: _refreshAll,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: RiderColors.gold,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}