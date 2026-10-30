
import 'package:flutter/material.dart';

import 'widgets/rider_ui.dart';

/// Last-mile data is separate from direct-delivery records.
/// Populate this model from the Laravel Rider API when available.
class RiderLastMileBatch {
  final int id;
  final String assignmentCode;
  final String status;
  final String facilityName;
  final String facilityAddress;
  final String deliveryArea;
  final List<RiderLastMileParcel> parcels;

  const RiderLastMileBatch({
    required this.id,
    required this.assignmentCode,
    required this.status,
    required this.facilityName,
    required this.facilityAddress,
    required this.deliveryArea,
    required this.parcels,
  });

  bool get isActive =>
      status == 'assigned' || status == 'out_for_delivery';

  bool get isCompleted => status == 'completed';

  String get statusLabel => _lastMileLabel(status);
}

class RiderLastMileParcel {
  final int id;
  final String orderNumber;
  final String parcelCode;
  final String buyerName;
  final String buyerAddress;
  final String? buyerPhone;
  final String status;

  const RiderLastMileParcel({
    required this.id,
    required this.orderNumber,
    required this.parcelCode,
    required this.buyerName,
    required this.buyerAddress,
    this.buyerPhone,
    required this.status,
  });

  bool get isDelivered =>
      status == 'delivered' || status == 'completed';

  String get statusLabel => _lastMileLabel(status);
}

String _lastMileLabel(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map(
        (part) =>
            '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

class RiderLastMile extends StatefulWidget {
  const RiderLastMile({
    super.key,
    this.batches = const [],
    this.onScanParcel,
    this.onOpenParcel,
    this.onBackToDashboard,
  });

  /// Backend-supplied batches, not mock records.
  final List<RiderLastMileBatch> batches;

  /// Open the dedicated scanner.
  final ValueChanged<RiderLastMileParcel>? onScanParcel;

  /// Open a selected parcel's delivery/POD workflow.
  final ValueChanged<RiderLastMileParcel>? onOpenParcel;

  final VoidCallback? onBackToDashboard;

  @override
  State<RiderLastMile> createState() => _RiderLastMileState();
}

class _RiderLastMileState extends State<RiderLastMile> {
  final TextEditingController _search =
      TextEditingController();

  String _filter = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<RiderLastMileBatch> get _filtered {
    final query = _search.text.trim().toLowerCase();

    return widget.batches.where((batch) {
      if (_filter == 'Active' && !batch.isActive) {
        return false;
      }

      if (_filter == 'Completed' && !batch.isCompleted) {
        return false;
      }

      if (query.isEmpty) return true;

      final values = <String>[
        batch.assignmentCode,
        batch.facilityName,
        batch.deliveryArea,
        batch.status,
        ...batch.parcels.expand(
          (parcel) => [
            parcel.orderNumber,
            parcel.parcelCode,
            parcel.buyerName,
            parcel.buyerAddress,
          ],
        ),
      ];

      return values.any(
        (value) => value.toLowerCase().contains(query),
      );
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
      case 'delivered':
        return RiderColors.green;
      case 'out_for_delivery':
      case 'arrived_buyer':
        return RiderColors.blue;
      default:
        return RiderColors.goldDark;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'completed':
      case 'delivered':
        return RiderColors.greenSoft;
      case 'out_for_delivery':
      case 'arrived_buyer':
        return RiderColors.blueSoft;
      default:
        return RiderColors.goldSoft;
    }
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final active =
        widget.batches.where((b) => b.isActive).toList();

    final completed =
        widget.batches.where((b) => b.isCompleted).length;

    final activeParcels = active.fold<int>(
      0,
      (sum, batch) => sum + batch.parcels.length,
    );

    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: RiderColors.surface,
        foregroundColor: RiderColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Last-Mile Deliveries',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Dashboard',
            onPressed: widget.onBackToDashboard ??
                () => Navigator.maybePop(context),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
        children: [
          _hero(),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _stat(
                  'Active Batches',
                  '${active.length}',
                  Icons.inventory_2_outlined,
                  RiderColors.goldDark,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _stat(
                  'Active Parcels',
                  '$activeParcels',
                  Icons.local_shipping_outlined,
                  RiderColors.blue,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _stat(
                  'Completed',
                  '$completed',
                  Icons.task_alt_rounded,
                  RiderColors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),
          _workflowGuide(),
          const SizedBox(height: 26),

          _heading(
            'Assigned Last-Mile Batches',
            'Parcels grouped by their destination hub '
                'and assigned delivery area.',
          ),
          const SizedBox(height: 14),

          _searchField(),
          const SizedBox(height: 12),
          _filters(),
          const SizedBox(height: 16),

          if (_filtered.isEmpty)
            _emptyState()
          else
            ..._filtered.map(
              (batch) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _batchCard(batch),
              ),
            ),

          const SizedBox(height: 16),
          _integrationNotice(),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: RiderColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.route_rounded,
                color: Colors.white70,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'LAST-MILE OPERATIONS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Text(
            'Last-Mile Deliveries',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Collect hub-assigned parcels and deliver '
            'within your assigned barangay.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => _notice(
              'Choose a parcel below to open its scanner.',
            ),
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
              size: 18,
            ),
            label: const Text('Scan Hub Parcel QR'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(
                color: Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(
    String label,
    String value,
    IconData icon,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 11),
          Text(
            value,
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _workflowGuide() {
    final steps = <(IconData, String, String)>[
      (
        Icons.hub_outlined,
        'Destination Hub',
        'Collect parcels',
      ),
      (
        Icons.route_outlined,
        'Local Delivery',
        'Reach the buyer',
      ),
      (
        Icons.verified_outlined,
        'Buyer Handoff',
        'Scan and capture POD',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Workflow',
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: List.generate(steps.length, (index) {
              final step = steps[index];

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: RiderColors.blueSoft,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        step.$1,
                        color: RiderColors.blue,
                        size: 21,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: RiderColors.text,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.$3,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: RiderColors.muted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _heading(String title, String subtitle) {
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
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: RiderColors.muted,
            fontSize: 11,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _search,
      onChanged: (_) => setState(() {}),
      style: TextStyle(color: RiderColors.text),
      decoration: InputDecoration(
        hintText: 'Search batch, barangay, parcel, buyer...',
        hintStyle: TextStyle(
          color: RiderColors.muted,
          fontSize: 12,
        ),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _search.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _search.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        filled: true,
        fillColor: RiderColors.field,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _filters() {
    const filters = ['All', 'Active', 'Completed'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = filter == _filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) {
                setState(() => _filter = filter);
              },
              showCheckmark: false,
              selectedColor: RiderColors.blueSoft,
              backgroundColor: RiderColors.surface,
              side: BorderSide(
                color: selected
                    ? RiderColors.blue
                    : RiderColors.border,
              ),
              labelStyle: TextStyle(
                color: selected
                    ? RiderColors.blue
                    : RiderColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _batchCard(RiderLastMileBatch batch) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        batch.assignmentCode,
                        style: TextStyle(
                          color: RiderColors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _badge(
                      batch.statusLabel,
                      _statusColor(batch.status),
                      _statusBackground(batch.status),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  '${batch.facilityName} → ${batch.deliveryArea}',
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${batch.parcels.length} '
                  '${batch.parcels.length == 1 ? 'parcel' : 'parcels'} '
                  'in this batch',
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 18),

                _detail(
                  Icons.hub_outlined,
                  'DESTINATION HUB',
                  batch.facilityName,
                  batch.facilityAddress,
                ),

                const SizedBox(height: 15),

                _detail(
                  Icons.location_on_outlined,
                  'DELIVERY AREA',
                  batch.deliveryArea,
                  'Assigned barangay for this batch',
                ),

                if (batch.status == 'assigned') ...[
                  const SizedBox(height: 17),
                  _info(
                    'Start the route only after physically '
                    'receiving the parcels from the destination hub.',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.route_outlined),
                      label: const Text('Start Last-Mile Route'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _smallNote(
                    'Route activation requires confirmation from Laravel.',
                  ),
                ],

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Batch Parcels',
                        style: TextStyle(
                          color: RiderColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _badge(
                      '${batch.parcels.length} parcels',
                      RiderColors.blue,
                      RiderColors.blueSoft,
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (batch.parcels.isEmpty)
            Padding(
              padding: const EdgeInsets.all(18),
              child: _smallNote(
                'No parcels are attached to this batch.',
              ),
            )
          else
            ...batch.parcels.map(
              (parcel) => _parcelCard(
                parcel,
                batch.status,
              ),
            ),
        ],
      ),
    );
  }

  Widget _parcelCard(
    RiderLastMileParcel parcel,
    String batchStatus,
  ) {
    final canScan = batchStatus == 'out_for_delivery' &&
        !parcel.isDelivered;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RiderColors.surfaceSoft,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  parcel.orderNumber,
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _badge(
                parcel.statusLabel,
                _statusColor(parcel.status),
                _statusBackground(parcel.status),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _detail(
            Icons.person_outline_rounded,
            'BUYER',
            parcel.buyerName,
            parcel.buyerAddress,
          ),

          const SizedBox(height: 10),

          Text(
            'Parcel code: ${parcel.parcelCode}',
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 11,
            ),
          ),

          if (parcel.buyerPhone != null &&
              parcel.buyerPhone!.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              'Contact: ${parcel.buyerPhone}',
              style: TextStyle(
                color: RiderColors.muted,
                fontSize: 11,
              ),
            ),
          ],

          if (canScan) ...[
            const SizedBox(height: 16),

            if (parcel.status == 'out_for_delivery')
              _info(
                'Next step: reach the buyer location. '
                'Arrival must be confirmed by the server.',
              ),

            const SizedBox(height: 11),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onScanParcel == null
                    ? null
                    : () => widget.onScanParcel!(parcel),
                icon: const Icon(
                  Icons.qr_code_scanner_rounded,
                ),
                label: const Text('Scan Parcel'),
              ),
            ),

            if (parcel.status == 'arrived_buyer') ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: widget.onOpenParcel == null
                      ? null
                      : () => widget.onOpenParcel!(parcel),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Open Proof of Delivery'),
                  style: FilledButton.styleFrom(
                    backgroundColor: RiderColors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],

            if (widget.onScanParcel == null)
              _smallNote(
                'Scanner navigation is not yet connected.',
              ),
          ],

          if (parcel.isDelivered) ...[
            const SizedBox(height: 12),
            _info(
              'Delivery recorded in the supplied batch data.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _detail(
    IconData icon,
    String label,
    String value,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: RiderColors.blue,
          size: 21,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: RiderColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: RiderColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: RiderColors.muted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badge(
    String label,
    Color foreground,
    Color background,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _info(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RiderColors.blueSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: RiderColors.blue,
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallNote(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Text(
        message,
        style: TextStyle(
          color: RiderColors.muted,
          fontSize: 10,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 44,
            color: RiderColors.muted,
          ),
          const SizedBox(height: 12),
          Text(
            'No Last-Mile Batches',
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Hub-assigned barangay delivery batches '
            'will appear here when loaded.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _integrationNotice() {
    return _info(
      'This is the mobile Last-Mile UI. Batches must '
      'come from the authenticated Laravel Rider API. '
      'Route start, buyer arrival, QR verification, '
      'proof upload, and final delivery confirmation '
      'are not yet connected to Laravel.',
    );
  }
}
