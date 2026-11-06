import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'widgets/logistics_hub_picker.dart';
import 'widgets/logistics_ui.dart';

class LogisticsRemittances extends StatefulWidget {
  const LogisticsRemittances({super.key});

  @override
  State<LogisticsRemittances> createState() => _LogisticsRemittancesState();
}

class _LogisticsRemittancesState extends State<LogisticsRemittances> {
  int? _hubId;
  bool _busy = false;
  String? _error;
  List<Map<String, dynamic>> _items = <Map<String, dynamic>>[];
  Map<String, dynamic> _stats = <String, dynamic>{};

  Future<void> _load({bool force = false}) async {
    if (_hubId == null || (!force && _busy)) return;
    setState(() { _busy = true; _error = null; });
    try {
      final response = await SariLiveData.instance.logisticsRemittances(_hubId!);
      final data = response['data'];
      final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      final raw = map['items'];
      if (!mounted) return;
      setState(() {
        _items = raw is List
            ? raw.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList()
            : <Map<String, dynamic>>[];
        _stats = map['stats'] is Map ? Map<String, dynamic>.from(map['stats']) : <String, dynamic>{};
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _hubChanged(int? id) {
    _hubId = id;
    _items = <Map<String, dynamic>>[];
    _stats = <String, dynamic>{};
    if (id != null) _load();
  }

  String _money(dynamic value) {
    final number = value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    return '₱${number.toStringAsFixed(2)}';
  }

  Future<void> _verify(Map<String, dynamic> item) async {
    final id = (item['id'] as num?)?.toInt();
    if (id == null || _hubId == null) return;

    final expected = item['expected_amount'] is num
        ? (item['expected_amount'] as num).toDouble()
        : double.tryParse('${item['expected_amount']}') ?? 0;
    final amount = TextEditingController(text: expected.toStringAsFixed(2));
    final reference = TextEditingController();
    final note = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Verify ${item['batch_code'] ?? 'COD remittance'}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Expected physical cash: ${_money(expected)}'),
              const SizedBox(height: 12),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Counted cash amount', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reference,
                decoration: const InputDecoration(labelText: 'Reference (optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: note,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Verification note (optional)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Verify Cash')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final counted = double.tryParse(amount.text.trim());
    if (counted == null || counted < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid cash amount.')));
      return;
    }

    setState(() => _busy = true);
    try {
      final response = await SariLiveData.instance.logisticsVerifyRemittance(
        id: id,
        facilityId: _hubId!,
        confirmedAmount: counted,
        reference: reference.text,
        note: note.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${response['message'] ?? 'COD remittance verified.'}')),
        );
      }
      await _load(force: true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      amount.dispose(); reference.dispose(); note.dispose();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: LogisticsPalette.canvas,
    appBar: AppBar(
      title: const Text('COD Cash Intake'),
      actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded))],
    ),
    body: RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const LogisticsSectionTitle(
            title: 'Physical COD remittance',
            subtitle: 'Verify Rider cash handover at the selected Logistics hub.',
          ),
          const SizedBox(height: 12),
          LogisticsHubPicker(onChanged: _hubChanged),
          const SizedBox(height: 14),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null) Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(_error!, style: const TextStyle(color: LogisticsPalette.danger)),
          ),
          if (_stats.isNotEmpty) ...[
            Row(children: [
              Expanded(child: _stat('Pending', '${_stats['pending_count'] ?? 0}')),
              const SizedBox(width: 8),
              Expanded(child: _stat('Submitted', _money(_stats['submitted']))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _stat('Verified', _money(_stats['verified']))),
              const SizedBox(width: 8),
              Expanded(child: _stat('Discrepancy', _money(_stats['discrepancy']))),
            ]),
            const SizedBox(height: 14),
          ],
          if (_items.isEmpty && !_busy && _error == null)
            const LogisticsEmptyCard(
              icon: Icons.payments_outlined,
              title: 'No COD batches',
              message: 'Rider cash batches submitted to this hub will appear here.',
            ),
          ..._items.map((item) {
            final status = '${item['status'] ?? ''}';
            final pending = status == 'submitted' || status == 'discrepancy';
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: LogisticsSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text('${item['batch_code'] ?? 'COD Batch'}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900))),
                      LogisticsTag(label: status.isEmpty ? 'unknown' : status),
                    ]),
                    const SizedBox(height: 6),
                    Text('Rider: ${item['rider_name'] ?? ''}'),
                    Text('Expected: ${_money(item['expected_amount'])}'),
                    if (item['difference_amount'] != null)
                      Text('Difference: ${_money(item['difference_amount'])}'),
                    if (pending) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _busy ? null : () => _verify(item),
                          icon: const Icon(Icons.verified_outlined),
                          label: const Text('Count & Verify Cash'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    ),
  );

  Widget _stat(String label, String value) => LogisticsSurface(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: LogisticsPalette.muted)),
        const SizedBox(height: 4),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
      ],
    ),
  );
}