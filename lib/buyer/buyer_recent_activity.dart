import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'models/buyer_activity_model.dart';
import 'buyer_theme.dart';
import 'buyer_notifications.dart';

/// Server-backed Buyer activity feed. No demo/synthetic order records.
class BuyerRecentActivity extends StatefulWidget {
  const BuyerRecentActivity({
    super.key,
    this.activities = const <BuyerActivity>[],
    this.onBrowseProducts,
  });

  // Kept for source compatibility; activity is loaded from Laravel.
  final List<BuyerActivity> activities;
  final VoidCallback? onBrowseProducts;

  @override
  State<BuyerRecentActivity> createState() => _BuyerRecentActivityState();
}

class _BuyerRecentActivityState extends State<BuyerRecentActivity> {
  final List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  bool _moreLoading = false;
  bool _archived = false;
  bool _mutating = false;
  int _page = 1;
  int _lastPage = 1;
  int _unread = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Map<String, dynamic> _asMap(Object? raw) => raw is Map
      ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      if (mounted) setState(() { _loading = true; _error = null; });
    } else {
      if (_moreLoading || _page >= _lastPage) return;
      setState(() => _moreLoading = true);
    }
    final requestedPage = reset ? 1 : _page + 1;
    try {
      final response = await SariLiveData.instance.buyerRecentActivity(
        page: requestedPage, archived: _archived,
      );
      if (!mounted) return;
      final items = response['data'];
      final meta = _asMap(response['meta']);
      setState(() {
        if (reset) _items.clear();
        if (items is List) _items.addAll(items.map(_asMap));
        _page = requestedPage;
        _lastPage = (meta['last_page'] as num?)?.toInt() ?? requestedPage;
        _unread = (response['unread_count'] as num?)?.toInt() ?? 0;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Unable to load activity: $error');
    } finally {
      if (mounted) setState(() { _loading = false; _moreLoading = false; });
    }
  }

  Future<void> _readAll() async {
    if (_mutating) return;
    setState(() => _mutating = true);
    try {
      await SariLiveData.instance.buyerActivityReadAll();
      await _load(reset: true);
    } catch (error) { _show(error.toString()); }
    finally { if (mounted) setState(() => _mutating = false); }
  }

  Future<void> _action(Map<String, dynamic> item, String action) async {
    if (_mutating) return;
    final id = (item['id'] as num?)?.toInt();
    if (id == null || id <= 0) return;
    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete activity?'),
          content: const Text('This removes the activity from your view.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    setState(() => _mutating = true);
    try {
      switch (action) {
        case 'read': await SariLiveData.instance.buyerActivityRead(id); break;
        case 'archive': await SariLiveData.instance.buyerActivityArchive(id); break;
        case 'restore': await SariLiveData.instance.buyerActivityRestore(id); break;
        case 'delete': await SariLiveData.instance.buyerActivityDelete(id); break;
      }
      await _load(reset: true);
    } catch (error) { _show(error.toString()); }
    finally { if (mounted) setState(() => _mutating = false); }
  }

  void _show(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _date(String raw) {
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return raw;
    return '${date.month}/${date.day}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _activityRow(Map<String, dynamic> item) {
    final title = item['title']?.toString() ?? 'SARI update';
    final body = item['message']?.toString() ?? '';
    final read = item['is_read'] == true || item['is_read'] == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 11, 6, 12),
      decoration: BuyerTheme.card(radius: 17),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: BuyerTheme.goldPale,
              borderRadius: BorderRadius.circular(13)),
          child: const Icon(Icons.history_rounded, color: BuyerTheme.goldDark),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title, style: TextStyle(
                fontSize: 12.5, fontWeight: read ? FontWeight.w700 : FontWeight.w900))),
            if (!read) const Icon(Icons.circle, color: BuyerTheme.gold, size: 8),
          ]),
          const SizedBox(height: 4),
          if (body.isNotEmpty) Text(body,
            style: const TextStyle(color: BuyerTheme.muted, fontSize: 11, height: 1.4)),
          const SizedBox(height: 7),
          Text(_date(item['created_at']?.toString() ?? ''),
            style: const TextStyle(color: BuyerTheme.muted, fontSize: 10)),
        ])),
        PopupMenuButton<String>(
          tooltip: 'Activity actions',
          enabled: !_mutating,
          onSelected: (action) => _action(item, action),
          itemBuilder: (_) => [
            if (!read) const PopupMenuItem(value: 'read', child: Text('Mark as read')),
            PopupMenuItem(value: _archived ? 'restore' : 'archive',
                child: Text(_archived ? 'Restore' : 'Archive')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BuyerTheme.canvas,
      appBar: AppBar(
        title: const Text('Recent Activity'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none_rounded), tooltip: 'Notifications',
            onPressed: () => Navigator.push<void>(context,
              MaterialPageRoute(builder: (_) => const BuyerNotifications()))),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => _load(reset: true)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(reset: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFF9EC), Color(0xFFFFEDCC)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('YOUR SARI UPDATES', style: TextStyle(color: BuyerTheme.goldDark,
                  letterSpacing: 1.8, fontWeight: FontWeight.w800, fontSize: 10)),
                const SizedBox(height: 6),
                const Text('Activity that matters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('$_unread unread update${_unread == 1 ? '' : 's'}',
                    style: const TextStyle(color: BuyerTheme.muted)),
              ]),
            ),
            const SizedBox(height: 15),
            Row(children: [
              ChoiceChip(label: const Text('Latest'), selected: !_archived,
                onSelected: (_) { setState(() => _archived = false); _load(reset: true); }),
              const SizedBox(width: 8),
              ChoiceChip(label: const Text('Archived'), selected: _archived,
                onSelected: (_) { setState(() => _archived = true); _load(reset: true); }),
              const Spacer(),
              if (!_archived) TextButton(onPressed: _mutating ? null : _readAll,
                child: const Text('Read all')),
            ]),
            if (_loading) const Padding(padding: EdgeInsets.all(25),
                child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Padding(padding: const EdgeInsets.all(18), child: Text(_error!,
                  style: const TextStyle(color: Colors.red)))
            else if (_items.isEmpty)
              const Padding(padding: EdgeInsets.all(35), child: Center(
                  child: Text('No activity yet.', style: TextStyle(color: BuyerTheme.muted))))
            else ..._items.map(_activityRow),
            if (!_loading && _page < _lastPage)
              Center(child: OutlinedButton.icon(onPressed: _moreLoading ? null : () => _load(),
                icon: const Icon(Icons.expand_more_rounded),
                label: Text(_moreLoading ? 'Loading...' : 'Load more'))),
          ],
        ),
      ),
    );
  }
}
