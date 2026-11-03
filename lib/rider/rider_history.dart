import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'models/rider_history_model.dart';
import 'widgets/rider_ui.dart';

class RiderHistory extends StatefulWidget {
  /// Existing shell history is retained as fallback data.
  final List<RiderHistoryRecord> history;

  const RiderHistory({
    super.key,
    required this.history,
  });

  @override
  State<RiderHistory> createState() =>
      _RiderHistoryState();
}

class _RiderHistoryState
    extends State<RiderHistory> {
  final TextEditingController _searchController =
      TextEditingController();

  final List<RiderHistoryRecord> _records = [];

  String _period = 'all';

  bool _loading = true;
  bool _loadingMore = false;
  bool _usingFallback = false;

  String? _error;

  int _page = 1;
  int _lastPage = 1;
  int _total = 0;

  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();

    _records.addAll(
      widget.history,
    );

    _load(
      reset: true,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
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
    final valueText =
        value?.toString().trim() ?? '';

    return valueText.isEmpty
        ? fallback
        : valueText;
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

  String _money(
    double value,
  ) {
    return '₱${value.toStringAsFixed(2)}';
  }

  String _dateForApi(
    DateTime date,
  ) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _dateLabel(
    DateTime date,
  ) {
    const months = [
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

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year}';
  }

  RiderHistoryRecord _parseRecord(
    dynamic raw,
  ) {
    final data = _map(raw);

    final earnedAt =
        DateTime.tryParse(
          _text(
            data['earned_at'],
          ),
        )?.toLocal();

    final now = DateTime.now();

    final isToday =
        earnedAt != null &&
        earnedAt.year == now.year &&
        earnedAt.month == now.month &&
        earnedAt.day == now.day;

    String date = '';

    String time = '';

    if (earnedAt != null) {
      date = _dateLabel(
        earnedAt,
      );

      final hour =
          earnedAt.hour == 0
              ? 12
              : earnedAt.hour > 12
                  ? earnedAt.hour - 12
                  : earnedAt.hour;

      final minute = earnedAt.minute
          .toString()
          .padLeft(
            2,
            '0',
          );

      final period =
          earnedAt.hour >= 12
              ? 'PM'
              : 'AM';

      time =
          '$hour:$minute $period';
    }

    return RiderHistoryRecord(
      order: _text(
        data['order_number'],
        'Order',
      ),
      customer: _text(
        data['customer'],
        'Buyer',
      ),
      route: _text(
        data['route'],
        'Route unavailable',
      ),
      date: date,
      time: time,
      fee: _double(
        data['fee'],
      ),
      status: _statusLabel(
        _text(
          data['status'],
          'recorded',
        ),
      ),
      isToday: isToday,
    );
  }

  String _statusLabel(
    String value,
  ) {
    final cleaned = value
        .trim()
        .replaceAll(
          '_',
          ' ',
        );

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

  String? get _dateFrom {
    final now = DateTime.now();

    switch (_period) {
      case 'today':
        return _dateForApi(
          now,
        );

      case 'custom':
        if (_customRange != null) {
          return _dateForApi(
            _customRange!.start,
          );
        }

        return null;

      default:
        return null;
    }
  }

  String? get _dateTo {
    final now = DateTime.now();

    switch (_period) {
      case 'today':
        return _dateForApi(
          now,
        );

      case 'previous':
        final yesterday =
            now.subtract(
          const Duration(
            days: 1,
          ),
        );

        return _dateForApi(
          yesterday,
        );

      case 'custom':
        if (_customRange != null) {
          return _dateForApi(
            _customRange!.end,
          );
        }

        return null;

      default:
        return null;
    }
  }

  Future<void> _load({
    required bool reset,
  }) async {
    if (reset) {
      setState(() {
        _loading = true;
        _loadingMore = false;
        _error = null;

        _page = 1;
        _lastPage = 1;
      });
    } else {
      if (_loadingMore ||
          _page >= _lastPage) {
        return;
      }

      setState(() {
        _loadingMore = true;
      });
    }

    final requestedPage =
        reset ? 1 : _page + 1;

    try {
      final response =
          await SariLiveData.instance
              .riderHistory(
        query:
            _searchController.text
                    .trim()
                    .isEmpty
                ? null
                : _searchController.text
                    .trim(),
        from: _dateFrom,
        to: _dateTo,
        page: requestedPage,
      );

      final raw =
          response['data'];

      if (raw is! List) {
        throw const FormatException(
          'Invalid Rider history response.',
        );
      }

      final loaded = raw
          .map(
            _parseRecord,
          )
          .toList();

      final meta =
          _map(
        response['meta'],
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (reset) {
          _records
            ..clear()
            ..addAll(
              loaded,
            );
        } else {
          _records.addAll(
            loaded,
          );
        }

        _page = _int(
          meta['current_page'],
        );

        if (_page <= 0) {
          _page =
              requestedPage;
        }

        _lastPage = _int(
          meta['last_page'],
        );

        if (_lastPage <= 0) {
          _lastPage = 1;
        }

        _total = _int(
          meta['total'],
        );

        if (_total <= 0) {
          _total =
              _records.length;
        }

        _loading = false;
        _loadingMore = false;
        _usingFallback = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _loadingMore = false;

        _error =
            error.toString();

        if (reset &&
            widget.history.isNotEmpty) {
          _records
            ..clear()
            ..addAll(
              widget.history,
            );

          _total =
              widget.history.length;

          _usingFallback = true;
        }
      });
    }
  }

  Future<void> _selectPeriod(
    String period,
  ) async {
    if (period == 'custom') {
      final now =
          DateTime.now();

      final range =
          await showDateRangePicker(
        context: context,
        firstDate:
            DateTime(
          2020,
          1,
          1,
        ),
        lastDate: now,
        initialDateRange:
            _customRange,
      );

      if (range == null ||
          !mounted) {
        return;
      }

      setState(() {
        _period = 'custom';
        _customRange = range;
      });
    } else {
      setState(() {
        _period = period;

        if (period !=
            'custom') {
          _customRange = null;
        }
      });
    }

    await _load(
      reset: true,
    );
  }

  Future<void> _resetFilters()
      async {
    _searchController.clear();

    setState(() {
      _period = 'all';
      _customRange = null;
    });

    await _load(
      reset: true,
    );
  }

  List<RiderHistoryRecord>
      get _visibleRecords {
    if (!_usingFallback) {
      return _records;
    }

    final query =
        _searchController.text
            .trim()
            .toLowerCase();

    return _records.where(
      (record) {
        final matchesSearch =
            query.isEmpty ||
            record.searchable.contains(
              query,
            ) ||
            record.status
                .toLowerCase()
                .contains(
                  query,
                );

        final matchesPeriod =
            switch (_period) {
          'today' =>
            record.isToday,

          'previous' =>
            !record.isToday,

          _ => true,
        };

        return matchesSearch &&
            matchesPeriod;
      },
    ).toList();
  }

  int get _todayCount {
    return _visibleRecords
        .where(
          (record) =>
              record.isToday,
        )
        .length;
  }

  double get _recordedFees {
    return _visibleRecords.fold<
        double>(
      0,
      (
        total,
        record,
      ) =>
          total + record.fee,
    );
  }

  double get _averageFee {
    if (_visibleRecords.isEmpty) {
      return 0;
    }

    return _recordedFees /
        _visibleRecords.length;
  }

  Color _statusColor(
    String status,
  ) {
    final value =
        status.toLowerCase();

    if (value.contains(
          'paid',
        ) ||
        value.contains(
          'available',
        ) ||
        value.contains(
          'completed',
        )) {
      return RiderColors.green;
    }

    if (value.contains(
          'awaiting',
        ) ||
        value.contains(
          'pending',
        ) ||
        value.contains(
          'reserved',
        )) {
      return RiderColors.goldDark;
    }

    return RiderColors.blue;
  }

  Color _statusSoft(
    String status,
  ) {
    final color =
        _statusColor(
      status,
    );

    if (color ==
        RiderColors.green) {
      return RiderColors.greenSoft;
    }

    if (color ==
        RiderColors.goldDark) {
      return RiderColors.goldSoft;
    }

    return RiderColors.blueSoft;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final records =
        _visibleRecords;

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
        titleSpacing: 16,
        title:
            const RiderHeaderTitle(
          title:
              'Delivery History',
          subtitle:
              'Completed Rider Trips',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _loading
                    ? null
                    : () =>
                        _load(
                          reset: true,
                        ),
            icon:
                const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color:
            RiderColors.gold,
        onRefresh: () =>
            _load(
          reset: true,
        ),
        child: ListView(
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
              height: 20,
            ),

            if (_usingFallback)
              Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 14,
                ),
                child:
                    _fallbackNotice(),
              ),

            _summaryCards(),

            const SizedBox(
              height: 24,
            ),

            _sectionTitle(
              'Search & Filters',
              'Search completed trips by order or Buyer and filter by date.',
            ),

            const SizedBox(
              height: 13,
            ),

            _filterPanel(),

            const SizedBox(
              height: 24,
            ),

            Row(
              children: [
                Expanded(
                  child:
                      _sectionTitle(
                    'Completed Trips',
                    'Direct and last-mile Rider delivery records.',
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                _badge(
                  '${_usingFallback ? records.length : _total} records',
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            if (_loading)
              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  vertical: 60,
                ),
                child: Center(
                  child:
                      CircularProgressIndicator(),
                ),
              )
            else if (_error != null &&
                records.isEmpty)
              _errorState()
            else if (records.isEmpty)
              const RiderEmptyState(
                icon:
                    Icons.history_rounded,
                title:
                    'No matching history',
                message:
                    'Completed Rider delivery records matching the current filters will appear here.',
              )
            else ...[
              ...records.map(
                (
                  record,
                ) =>
                    Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 11,
                  ),
                  child:
                      _historyCard(
                    record,
                  ),
                ),
              ),

              if (!_usingFallback &&
                  _page <
                      _lastPage)
                Padding(
                  padding:
                      const EdgeInsets.only(
                    top: 4,
                  ),
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        _loadingMore
                            ? null
                            : () =>
                                _load(
                                  reset:
                                      false,
                                ),
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
                ),
            ],

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
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors:
              RiderColors
                  .heroGradient,
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
                    .history_rounded,
                color:
                    Colors.white70,
                size: 18,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'RIDER WORKSPACE',
                style:
                    TextStyle(
                  color:
                      Colors.white70,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing:
                      1.3,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          const Text(
            'Delivery History',
            style: TextStyle(
              color:
                  Colors.white,
              fontSize: 27,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'Review your completed direct and last-mile delivery trips and recorded Rider fees.',
            style: TextStyle(
              color:
                  Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Row(
            children: [
              const Icon(
                Icons
                    .cloud_done_outlined,
                color:
                    Colors.white,
                size: 18,
              ),

              const SizedBox(
                width: 7,
              ),

              Text(
                _usingFallback
                    ? 'Local fallback data'
                    : 'Synced with SARI',
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
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
                label:
                    'Today',
                value:
                    '$_todayCount',
                subtitle:
                    'Completed trips',
                icon: Icons
                    .event_available_outlined,
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
                    'Loaded Trips',
                value:
                    '${_visibleRecords.length}',
                subtitle:
                    _usingFallback
                        ? 'Fallback records'
                        : 'Current results',
                icon: Icons
                    .inventory_2_outlined,
                accent:
                    RiderColors.blue,
                soft:
                    RiderColors.blueSoft,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 10,
        ),

        Row(
          children: [
            Expanded(
              child: _metric(
                label:
                    'Recorded Fees',
                value:
                    _money(
                  _recordedFees,
                ),
                subtitle:
                    'Loaded records',
                icon: Icons
                    .payments_outlined,
                accent:
                    RiderColors.green,
                soft:
                    RiderColors.greenSoft,
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: _metric(
                label:
                    'Average Fee',
                value:
                    _money(
                  _averageFee,
                ),
                subtitle:
                    'Per loaded trip',
                icon: Icons
                    .bar_chart_rounded,
                accent:
                    RiderColors.purple,
                soft:
                    RiderColors.purpleSoft,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metric({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required Color soft,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
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
            height: 11,
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
                  RiderColors.text,
              fontSize: 10,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            subtitle,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 8,
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              TextStyle(
            color:
                RiderColors.text,
            fontSize: 16,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          subtitle,
          style:
              TextStyle(
            color:
                RiderColors.muted,
            fontSize: 9.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _filterPanel() {
    return Container(
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        children: [
          TextField(
            controller:
                _searchController,
            textInputAction:
                TextInputAction.search,
            onSubmitted: (_) =>
                _load(
              reset: true,
            ),
            decoration:
                InputDecoration(
              hintText:
                  'Search order or Buyer...',
              prefixIcon:
                  const Icon(
                Icons.search_rounded,
              ),
              suffixIcon:
                  _searchController
                          .text
                          .isEmpty
                      ? null
                      : IconButton(
                          onPressed: () async {
                            _searchController
                                .clear();

                            await _load(
                              reset: true,
                            );
                          },
                          icon:
                              const Icon(
                            Icons
                                .close_rounded,
                          ),
                        ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,
            child: Row(
              children: [
                _filterChip(
                  value: 'all',
                  label: 'All',
                ),
                _filterChip(
                  value: 'today',
                  label: 'Today',
                ),
                _filterChip(
                  value: 'previous',
                  label: 'Previous',
                ),
                _filterChip(
                  value: 'custom',
                  label:
                      _customRange == null
                          ? 'Date Range'
                          : '${_dateLabel(_customRange!.start)} - ${_dateLabel(_customRange!.end)}',
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 11,
          ),

          Row(
            children: [
              Expanded(
                child:
                    FilledButton.icon(
                  onPressed: () =>
                      _load(
                    reset: true,
                  ),
                  icon:
                      const Icon(
                    Icons
                        .search_rounded,
                    size: 17,
                  ),
                  label:
                      const Text(
                    'Apply Filters',
                  ),
                  style:
                      FilledButton
                          .styleFrom(
                    backgroundColor:
                        RiderColors.blue,
                    foregroundColor:
                        Colors.white,
                  ),
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              OutlinedButton(
                onPressed:
                    _resetFilters,
                child:
                    const Text(
                  'Reset',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String value,
    required String label,
  }) {
    final selected =
        _period == value;

    return Padding(
      padding:
          const EdgeInsets.only(
        right: 7,
      ),
      child: ChoiceChip(
        label:
            Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) =>
            _selectPeriod(
          value,
        ),
        selectedColor:
            RiderColors.blueSoft,
        backgroundColor:
            RiderColors.surface,
        side: BorderSide(
          color: selected
              ? RiderColors.blue
              : RiderColors.border,
        ),
        labelStyle:
            TextStyle(
          color: selected
              ? RiderColors.blue
              : RiderColors.muted,
          fontSize: 9,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  Widget _historyCard(
    RiderHistoryRecord record,
  ) {
    final statusColor =
        _statusColor(
      record.status,
    );

    final statusSoft =
        _statusSoft(
      record.status,
    );

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
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      RiderColors.greenSoft,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  Icons
                      .local_shipping_outlined,
                  color:
                      RiderColors.green,
                  size: 21,
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
                      record.order,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          TextStyle(
                        color:
                            RiderColors.text,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      record.customer,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          TextStyle(
                        color:
                            RiderColors.muted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                _money(
                  record.fee,
                ),
                style:
                    TextStyle(
                  color:
                      RiderColors.green,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 13,
          ),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                Icons
                    .route_outlined,
                color:
                    RiderColors.blue,
                size: 17,
              ),

              const SizedBox(
                width: 7,
              ),

              Expanded(
                child: Text(
                  record.route,
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 9,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
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
                  record.status,
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

              const Spacer(),

              Text(
                [
                  record.date,
                  record.time,
                ]
                    .where(
                      (value) =>
                          value
                              .trim()
                              .isNotEmpty,
                    )
                    .join(
                      ' · ',
                    ),
                style:
                    TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(
    String value,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.blueSoft,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        value,
        style:
            TextStyle(
          color:
              RiderColors.blue,
          fontSize: 8,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  Widget _fallbackNotice() {
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
                .cloud_off_outlined,
            color:
                RiderColors.goldDark,
            size: 18,
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Text(
              'The live Rider history API could not be refreshed, so the app is temporarily showing the history already loaded by the Rider shell.',
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
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        28,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        children: [
          Icon(
            Icons
                .cloud_off_outlined,
            color:
                RiderColors.muted,
            size: 44,
          ),

          const SizedBox(
            height: 11,
          ),

          Text(
            'Unable to load Rider history',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  RiderColors.text,
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            _error ??
                'Please try again.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 9.5,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          FilledButton.icon(
            onPressed: () =>
                _load(
              reset: true,
            ),
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
              'This history contains recognized direct-delivery and last-mile Rider records. The fee shown is the Rider fee recorded for that completed trip.',
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color:
          RiderColors.surface,
      borderRadius:
          BorderRadius.circular(
        17,
      ),
      border:
          Border.all(
        color:
            RiderColors.border,
      ),
    );
  }
}