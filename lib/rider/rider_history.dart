import 'package:flutter/material.dart';

import 'models/rider_history_model.dart';

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
  static const Color _gold = Color(0xFFD9930A);
  static const Color _border = Color(0xFFEEE4D3);

  final TextEditingController _searchController = TextEditingController();
  String _filter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RiderHistoryRecord> get _filtered {
    final query = _searchController.text.trim().toLowerCase();

    return widget.history.where((row) {
      final searchMatch = query.isEmpty || row.searchable.contains(query);
      final dayMatch = _filter == 'all' ||
          (_filter == 'today' && row.isToday) ||
          (_filter == 'previous' && !row.isToday);
      return searchMatch && dayMatch;
    }).toList();
  }

  int get _todayCount =>
      widget.history.where((row) => row.isToday).length;

  int get _totalCount => widget.history.length;

  double get _successRate => widget.history.isEmpty ? 0 : 100;

  double get _averageFee {
    if (widget.history.isEmpty) return 0;
    final total = widget.history.fold<double>(
      0,
      (sum, row) => sum + row.fee,
    );
    return total / widget.history.length;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF8),
        surfaceTintColor: Colors.transparent,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery History',
              style: TextStyle(
                color: Color(0xFF211D17),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Completed Deliveries',
              style: TextStyle(
                color: Color(0xFF918677),
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
        children: [
          _heading(),
          const SizedBox(height: 14),
          _stats(),
          const SizedBox(height: 14),
          _controls(),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            _empty()
          else
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _historyCard(row),
              ),
            ),
        ],
      ),
    );
  }

  Widget _heading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery History',
          style: TextStyle(
            color: Color(0xFF211D17),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Review completed deliveries, routes, completion time, and earned courier fees.',
          style: TextStyle(
            color: Color(0xFF817769),
            fontSize: 8.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _toast('History export preview complete.'),
          icon: const Icon(Icons.download_outlined, size: 16),
          label: const Text(
            'Export',
            style: TextStyle(fontSize: 8),
          ),
        ),
      ],
    );
  }

  Widget _stats() {
    final stats = [
      ('Completed Today', '$_todayCount', 'Successful trips'),
      ('Total Completed', '$_totalCount', 'Since joining'),
      ('Success Rate', '${_successRate.toStringAsFixed(1)}%', 'Completion rate'),
      ('Average Fee', _peso(_averageFee), 'Per completed delivery'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.$1,
                style: const TextStyle(
                  color: Color(0xFF887E70),
                  fontSize: 7.5,
                ),
              ),
              const Spacer(),
              Text(
                stat.$2,
                style: const TextStyle(
                  color: Color(0xFF211D17),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                stat.$3,
                style: const TextStyle(
                  color: Color(0xFF9B9183),
                  fontSize: 6.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _controls() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _filter,
            decoration: const InputDecoration(
              labelText: 'Filter',
              border: OutlineInputBorder(),
              isDense: true,
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
              setState(() {
                _filter = value;
              });
            },
          ),
          const SizedBox(height: 9),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 9),
            decoration: InputDecoration(
              hintText: 'Search order, customer, route...',
              prefixIcon: const Icon(Icons.search, size: 18),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _gold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(RiderHistoryRecord row) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.order,
                  style: const TextStyle(
                    color: Color(0xFF302A23),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECF7F0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC5E4D0)),
                ),
                child: Text(
                  row.status,
                  style: const TextStyle(
                    color: Color(0xFF3F7B55),
                    fontSize: 6.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _line('Customer', row.customer),
          _line('Route', row.route),
          _line('Date', row.date),
          _line('Time', row.time),
          const Divider(height: 16),
          Row(
            children: [
              const Text(
                'Courier Fee',
                style: TextStyle(
                  color: Color(0xFF81776A),
                  fontSize: 7.5,
                ),
              ),
              const Spacer(),
              Text(
                _peso(row.fee),
                style: const TextStyle(
                  color: Color(0xFF302A23),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9A9187),
                fontSize: 7,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF746A5E),
                fontSize: 7.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return const Padding(
      padding: EdgeInsets.all(30),
      child: Text(
        'No matching completed deliveries.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF918677),
          fontSize: 9,
        ),
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _peso(double value) => '₱${value.toStringAsFixed(2)}';
}
