
import 'package:flutter/material.dart';

import 'models/rider_history_model.dart';
import 'widgets/rider_ui.dart';

class RiderHistory extends StatefulWidget {
  final List<RiderHistoryRecord> history;

  const RiderHistory({
    super.key,
    required this.history,
  });

  @override
  State<RiderHistory> createState() => _RiderHistoryState();
}

class _RiderHistoryState extends State<RiderHistory> {
  final TextEditingController _searchController =
      TextEditingController();

  String _period = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RiderHistoryRecord> get _filteredRecords {
    final query = _searchController.text.trim().toLowerCase();

    return widget.history.where((record) {
      final matchesSearch =
          query.isEmpty ||
          record.searchable.contains(query) ||
          record.status.toLowerCase().contains(query);

      final matchesPeriod = switch (_period) {
        'today' => record.isToday,
        'previous' => !record.isToday,
        _ => true,
      };

      return matchesSearch && matchesPeriod;
    }).toList();
  }

  int get _completedToday {
    return widget.history.where((record) {
      return record.isToday &&
          _isCompleted(record.status);
    }).length;
  }

  int get _completedCount {
    return widget.history.where((record) {
      return _isCompleted(record.status);
    }).length;
  }

  double get _recordedFees {
    return widget.history
        .where((record) => _isCompleted(record.status))
        .fold<double>(
          0,
          (sum, record) => sum + record.fee,
        );
  }

  double get _averageFee {
    if (_completedCount == 0) return 0;
    return _recordedFees / _completedCount;
  }

  bool _isCompleted(String status) {
    final normalized = status.toLowerCase().trim();

    return normalized.contains('complete') ||
        normalized.contains('deliver') ||
        normalized.contains('success');
  }

  bool _isFailed(String status) {
    final normalized = status.toLowerCase();

    return normalized.contains('fail') ||
        normalized.contains('cancel') ||
        normalized.contains('return');
  }

  void _resetFilters() {
    _searchController.clear();

    setState(() {
      _period = 'all';
    });
  }

  String _money(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        backgroundColor: RiderColors.surface,
        foregroundColor: RiderColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: const RiderHeaderTitle(
          title: 'Delivery History',
          subtitle: 'Completed Deliveries',
        ),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
        children: [
          _hero(),
          const SizedBox(height: 20),

          _summaryCards(),

          const SizedBox(height: 25),

          _sectionTitle(
            'Search & Filters',
            'Find records from your recent delivery history.',
          ),

          const SizedBox(height: 13),

          _filterPanel(),

          const SizedBox(height: 25),

          Row(
            children: [
              Expanded(
                child: _sectionTitle(
                  'Completed Trips',
                  'Recent direct and last-mile deliveries.',
                ),
              ),
              const SizedBox(width: 8),
              _badge('${records.length} records'),
            ],
          ),

          const SizedBox(height: 14),

          if (records.isEmpty)
            RiderEmptyState(
              icon: Icons.history_rounded,
              title: 'No matching history',
              message: widget.history.isEmpty
                  ? 'Your delivery history will appear here.'
                  : 'Try changing your search or delivery period.',
            )
          else
            ...records.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _historyCard(record),
              ),
            ),

          const SizedBox(height: 15),

          _notice(
            'History records are currently supplied by '
            'Flutter. The summary uses the loaded completed '
            'records. A full CSV export requires access to '
            'the Laravel Rider history export API.',
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: RiderColors.heroGradient,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: Colors.white70,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'RIDER WORKSPACE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Delivery History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Review your completed trips, routes, '
            'and recorded delivery fees.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 19),
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(
              Icons.file_download_outlined,
              size: 18,
            ),
            label: const Text('Export History'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white54,
              side: const BorderSide(
                color: Colors.white38,
              ),
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Export available after API integration.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metric(
                'Completed Today',
                '$_completedToday',
                'Within recent records',
                Icons.event_available_outlined,
                RiderColors.goldDark,
                RiderColors.goldSoft,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metric(
                'Recent Completed',
                '$_completedCount',
                'Loaded history',
                Icons.inventory_2_outlined,
                RiderColors.blue,
                RiderColors.blueSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metric(
                'Recorded Fees',
                _money(_recordedFees),
                'Completed trip fees',
                Icons.payments_outlined,
                RiderColors.green,
                RiderColors.greenSoft,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metric(
                'Average Fee',
                _money(_averageFee),
                'Per completed trip',
                Icons.bar_chart_rounded,
                RiderColors.purple,
                RiderColors.purpleSoft,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metric(
    String label,
    String value,
    String subtitle,
    IconData icon,
    Color accent,
    Color soft,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: RiderColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 19,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 2,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 10,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
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
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: RiderColors.muted,
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _filterPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Search Records'),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 13,
            ),
            decoration: _inputDecoration(
              'Search order, customer, or route',
              Icons.search_rounded,
              suffix: _searchController.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 17),

          _fieldLabel('Delivery Period'),
          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: _period,
            isExpanded: true,
            dropdownColor: RiderColors.surface,
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 13,
            ),
            decoration: _inputDecoration(
              'Select period',
              Icons.calendar_month_outlined,
            ),
            items: const [
              DropdownMenuItem(
                value: 'all',
                child: Text('All deliveries'),
              ),
              DropdownMenuItem(
                value: 'today',
                child: Text('Today'),
              ),
              DropdownMenuItem(
                value: 'previous',
                child: Text('Previous days'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _period = value);
            },
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: RiderColors.blue,
                side: BorderSide(
                  color: RiderColors.border,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Filters affect the displayed records only. '
            'Summary cards are based on all loaded completed trips.',
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 10,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: RiderColors.text,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: RiderColors.muted,
        fontSize: 12,
      ),
      prefixIcon: Icon(
        icon,
        color: RiderColors.muted,
        size: 20,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: RiderColors.field,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: RiderColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: RiderColors.blue,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _historyCard(RiderHistoryRecord record) {
    final failed = _isFailed(record.status);
    final accent =
        failed ? RiderColors.red : RiderColors.green;
    final soft =
        failed ? RiderColors.redSoft : RiderColors.greenSoft;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  failed
                      ? Icons.error_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  color: accent,
                  size: 23,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.order,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: RiderColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.customer,
                      maxLines: 2,
                      style: TextStyle(
                        color: RiderColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              _badge(
                record.status,
                color: accent,
                background: soft,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Divider(
            height: 1,
            color: RiderColors.border,
          ),

          const SizedBox(height: 15),

          _detailRow(
            Icons.route_outlined,
            'Route',
            record.route,
          ),

          const SizedBox(height: 13),

          _detailRow(
            Icons.schedule_outlined,
            'Date & Time',
            '${record.date} • ${record.time}',
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: RiderColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: RiderColors.green,
                  size: 20,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Recorded Delivery Fee',
                    style: TextStyle(
                      color: RiderColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _money(record.fee),
                  style: TextStyle(
                    color: RiderColors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: RiderColors.blue,
          size: 19,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: RiderColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: RiderColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badge(
    String label, {
    Color? color,
    Color? background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: background ?? RiderColors.blueSoft,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color ?? RiderColors.blue,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _notice(String message) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RiderColors.goldSoft,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: RiderColors.goldDark,
            size: 19,
          ),
          const SizedBox(width: 10),
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: RiderColors.surface,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(
        color: RiderColors.border,
      ),
    );
  }
}
