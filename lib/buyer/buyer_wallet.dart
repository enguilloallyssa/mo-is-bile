import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'buyer_theme.dart';

/// The web Buyer wallet is read-only in the current mobile API.
/// Never show a wallet checkout or withdrawal action: the server disables both.
class BuyerWallet extends StatefulWidget {
  const BuyerWallet({super.key});

  @override
  State<BuyerWallet> createState() => _BuyerWalletState();
}

class _BuyerWalletState extends State<BuyerWallet> {
  Map<String, dynamic>? _wallet;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      final response = await SariLiveData.instance.buyerWallet();
      if (!mounted) return;
      final data = response['data'];
      setState(() { _wallet = data is Map ? Map<String, dynamic>.from(data) : {}; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  double _amount(String key) {
    final value = _wallet?[key];
    return value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
  }

  String _money(num value) => '₱${value.toStringAsFixed(2)}';

  Widget _stat(String label, String key, IconData icon, Color accent) =>
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BuyerTheme.card(radius: 17),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 21, color: accent),
          const SizedBox(height: 12),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
            child: Text(_money(_amount(key)), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: BuyerTheme.ink))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: BuyerTheme.body, fontWeight: FontWeight.w700)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final entries = _wallet?['recent_entries'];
    final rows = entries is List ? entries.whereType<Map>().toList() : <Map>[];

    return Scaffold(
      backgroundColor: BuyerTheme.canvas,
      appBar: AppBar(
        title: const Text('My Wallet & COD'),
        backgroundColor: BuyerTheme.surface,
        foregroundColor: BuyerTheme.ink,
        elevation: 0,
        actions: [IconButton(tooltip: 'Refresh wallet', icon: const Icon(Icons.refresh_rounded), onPressed: _loading ? null : _load)],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: BuyerTheme.goldDark,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: BuyerTheme.heroGradient),
                borderRadius: BorderRadius.circular(23),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFFFDD9D), size: 20), SizedBox(width: 8), Text('SARI WALLET', style: TextStyle(color: Color(0xFFFFDD9D), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1))]),
                const SizedBox(height: 16),
                const Text('Available balance', style: TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 6),
                Text(_wallet == null ? '—' : _money(_amount('available_balance')),
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                const Text('Read-only wallet overview · COD purchases are not paid with wallet balance.',
                    style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 11)),
              ]),
            ),
            const SizedBox(height: 16),
            if (_loading && _wallet == null)
              const Center(child: Padding(padding: EdgeInsets.all(22), child: CircularProgressIndicator()))
            else if (_error != null && _wallet == null)
              _notice('Wallet unavailable', _error!, Icons.wifi_off_rounded)
            else if (_wallet != null) ...[
              Row(children: [
                Expanded(child: _stat('COD spending', 'cod_spending', Icons.payments_outlined, BuyerTheme.goldDark)),
                const SizedBox(width: 10),
                Expanded(child: _stat('Reserved', 'reserved_balance', Icons.lock_clock_outlined, BuyerTheme.blue)),
              ]),
              const SizedBox(height: 22),
              const Text('Recent wallet activity', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: BuyerTheme.ink)),
              const SizedBox(height: 5),
              const Text('Transactions recorded by SARI', style: TextStyle(fontSize: 12, color: BuyerTheme.muted)),
              const SizedBox(height: 13),
              if (rows.isEmpty)
                _notice('No wallet activity', 'Your recent wallet entries will appear here when available.', Icons.receipt_long_outlined)
              else
                for (final raw in rows)
                  Padding(padding: const EdgeInsets.only(bottom: 9), child: _entry(Map<String, dynamic>.from(raw))),
              const SizedBox(height: 12),
              _notice('COD-only payment flow', 'Your current account follows the website COD process. Wallet checkout and withdrawals are disabled on the server.', Icons.info_outline_rounded),
            ],
          ],
        ),
      ),
    );
  }

  Widget _notice(String title, String detail, IconData icon) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BuyerTheme.card(radius: 16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: BuyerTheme.goldDark, size: 22),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: BuyerTheme.ink)),
        const SizedBox(height: 5),
        Text(detail, style: const TextStyle(fontSize: 11, color: BuyerTheme.body, height: 1.5)),
      ])),
    ]),
  );

  Widget _entry(Map<String, dynamic> entry) {
    final raw = entry['amount'];
    final amount = raw is num ? raw.toDouble() : double.tryParse('$raw') ?? 0.0;
    final category = (entry['category'] ?? 'Wallet entry').toString().replaceAll('_', ' ');
    final date = DateTime.tryParse('${entry['occurred_at'] ?? ''}');
    final stamp = date == null ? 'Date unavailable' : '${date.month}/${date.day}/${date.year}';
    final positive = amount >= 0;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BuyerTheme.card(radius: 15),
      child: Row(children: [
        Container(width: 40, height: 40, alignment: Alignment.center,
            decoration: BoxDecoration(color: positive ? BuyerTheme.successSoft : BuyerTheme.blueSoft, borderRadius: BorderRadius.circular(12)),
            child: Icon(positive ? Icons.south_west_rounded : Icons.north_east_rounded,
                color: positive ? BuyerTheme.success : BuyerTheme.blue, size: 19)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(category, style: const TextStyle(color: BuyerTheme.ink, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(stamp, style: const TextStyle(color: BuyerTheme.muted, fontSize: 10)),
        ])),
        Text(_money(amount), style: const TextStyle(color: BuyerTheme.ink, fontWeight: FontWeight.w800, fontSize: 12)),
      ]),
    );
  }
}
