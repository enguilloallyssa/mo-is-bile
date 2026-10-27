import 'package:flutter/material.dart';

import 'models/rider_history_model.dart';
import 'widgets/rider_ui.dart';

class RiderHistory extends StatefulWidget {
  final List<RiderHistoryRecord> history;
  RiderHistory({super.key, required this.history});

  @override
  State<RiderHistory> createState() => _RiderHistoryState();
}

class _RiderHistoryState extends State<RiderHistory> {
  final TextEditingController _search = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final records = widget.history.where((item) {
      final matchesSearch = query.isEmpty || item.searchable.contains(query);
      final matchesFilter = _filter == 'All' || (_filter == 'Today' && item.isToday) || (_filter == 'Failed' && item.status.toLowerCase().contains('fail'));
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(toolbarHeight: 70, title: RiderHeaderTitle(title: 'Delivery History', subtitle: 'Completed and failed rider jobs')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(14, 14, 14, 26),
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search order, customer or route',
              prefixIcon: Icon(Icons.search_rounded),
              filled: true,
              fillColor: RiderColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: RiderColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: RiderColors.border)),
            ),
          ),
          SizedBox(height: 12),
          Row(children: [
            for (final filter in const ['All','Today','Failed'])
              Expanded(child: Padding(
                padding: EdgeInsets.only(right: filter == 'Failed' ? 0 : 8),
                child: ChoiceChip(label: SizedBox(width: double.infinity, child: Text(filter, textAlign: TextAlign.center)), selected: _filter == filter, onSelected: (_) => setState(() => _filter = filter), selectedColor: RiderColors.goldSoft, backgroundColor: RiderColors.surface, side: BorderSide(color: RiderColors.border)),
              )),
          ]),
          SizedBox(height: 14),
          if (records.isEmpty)
            RiderEmptyState(icon: Icons.history_rounded, title: 'No matching history', message: 'Try another search or filter.')
          else
            ...records.map((item) => Padding(padding: EdgeInsets.only(bottom: 10), child: _historyCard(item))),
        ],
      ),
    );
  }

  Widget _historyCard(RiderHistoryRecord item) {
    final failed = item.status.toLowerCase().contains('fail');
    final color = failed ? RiderColors.red : RiderColors.green;
    final soft = failed ? RiderColors.redSoft : RiderColors.greenSoft;
    return RiderSurface(
      padding: EdgeInsets.all(15),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(14)), child: Icon(failed ? Icons.close_rounded : Icons.check_rounded, color: color)),
        SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(item.order, style: TextStyle(color: RiderColors.text, fontSize: 13, fontWeight: FontWeight.w900))),
            Text('₱${item.fee.toStringAsFixed(0)}', style: TextStyle(color: RiderColors.green, fontSize: 13, fontWeight: FontWeight.w900)),
          ]),
          SizedBox(height: 3),
          Text(item.customer, style: TextStyle(color: RiderColors.text, fontSize: 11, fontWeight: FontWeight.w700)),
          SizedBox(height: 3),
          Text(item.route, style: TextStyle(color: RiderColors.muted, fontSize: 10, height: 1.35)),
          SizedBox(height: 7),
          Row(children: [
            RiderStatusPill(label: item.status, color: color, background: soft),
            Spacer(),
            Text('${item.date} • ${item.time}', style: TextStyle(color: RiderColors.muted, fontSize: 9)),
          ]),
        ])),
      ]),
    );
  }
}
