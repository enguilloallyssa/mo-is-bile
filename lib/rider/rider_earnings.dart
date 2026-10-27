import 'package:flutter/material.dart';

import 'models/rider_earning_model.dart';
import 'widgets/rider_ui.dart';

class RiderEarnings extends StatefulWidget {
  final List<RiderDailyEarning> daily;
  final List<RiderEarningTransaction> transactions;
  final VoidCallback onOpenHistory;

  RiderEarnings({super.key, required this.daily, required this.transactions, required this.onOpenHistory});

  @override
  State<RiderEarnings> createState() => _RiderEarningsState();
}

class _RiderEarningsState extends State<RiderEarnings> {
  double _pendingPayout = 0;
  double get _weeklyTotal => widget.daily.fold(0.0, (sum, item) => sum + item.amount);
  double get _walletBalance => widget.transactions.fold(0.0, (sum, item) => sum + item.amount) - _pendingPayout;

  @override
  Widget build(BuildContext context) {
    final maxAmount = widget.daily.isEmpty ? 1.0 : widget.daily.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 74,
        titleSpacing: 16,
        title: RiderHeaderTitle(title: 'Rider Wallet', subtitle: 'Earnings, payouts and delivery fees'),
        actions: [IconButton(onPressed: widget.onOpenHistory, icon: Icon(Icons.receipt_long_outlined)), SizedBox(width: 8)],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(14, 14, 14, 26),
        children: [
          _walletHero(),
          SizedBox(height: 14),
          Row(children: [
            Expanded(child: RiderMetricTile(value: '₱${_weeklyTotal.toStringAsFixed(0)}', label: 'This week', icon: Icons.calendar_view_week_outlined, accent: RiderColors.blue, softColor: RiderColors.blueSoft)),
            SizedBox(width: 10),
            Expanded(child: RiderMetricTile(value: '${widget.transactions.length}', label: 'Transactions', icon: Icons.receipt_outlined, accent: RiderColors.purple, softColor: RiderColors.purpleSoft)),
          ]),
          SizedBox(height: 20),
          RiderSectionHeader(title: 'Weekly performance', subtitle: 'Delivery fees credited per day'),
          SizedBox(height: 10),
          RiderSurface(
            padding: EdgeInsets.fromLTRB(14, 18, 14, 12),
            child: SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: widget.daily.map((item) {
                  final ratio = maxAmount <= 0 ? 0.0 : item.amount / maxAmount;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text('₱${item.amount.toStringAsFixed(0)}', style: TextStyle(color: RiderColors.muted, fontSize: 8.5, fontWeight: FontWeight.w700)),
                        SizedBox(height: 5),
                        Flexible(child: FractionallySizedBox(heightFactor: ratio.clamp(.08, 1.0).toDouble(), alignment: Alignment.bottomCenter, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [RiderColors.gold, Color(0xFFF0B84C)]))))),
                        SizedBox(height: 7),
                        Text(item.day, style: TextStyle(color: RiderColors.text, fontSize: 9.5, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 20),
          RiderSectionHeader(title: 'Recent earnings', subtitle: 'Latest credited rider fees'),
          SizedBox(height: 10),
          ...widget.transactions.map((item) => Padding(padding: EdgeInsets.only(bottom: 9), child: _transaction(item))),
        ],
      ),
    );
  }

  Widget _walletHero() {
    return Container(
      padding: EdgeInsets.all(19),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3E755B), RiderColors.green, Color(0xFF608F73)]), boxShadow: const [BoxShadow(color: Color(0x254F7D63), blurRadius: 24, offset: Offset(0, 10))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('AVAILABLE BALANCE', style: TextStyle(color: Colors.white.withValues(alpha: .78), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .8)),
        SizedBox(height: 6),
        Text('₱${_walletBalance.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -.8)),
        SizedBox(height: 5),
        Text(_pendingPayout > 0 ? '₱${_pendingPayout.toStringAsFixed(0)} payout pending' : 'Ready for payout request', style: TextStyle(color: Colors.white.withValues(alpha: .82), fontSize: 11)),
        SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _walletBalance <= 0 ? null : _requestPayout, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: RiderColors.green, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))), icon: Icon(Icons.payments_outlined, size: 18), label: Text('Request Payout', style: TextStyle(fontWeight: FontWeight.w900))),
      ]),
    );
  }

  Widget _transaction(RiderEarningTransaction item) {
    return RiderSurface(
      padding: EdgeInsets.all(14),
      child: Row(children: [
        CircleAvatar(radius: 21, backgroundColor: RiderColors.greenSoft, child: Icon(Icons.add_rounded, color: RiderColors.green)),
        SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.order, style: TextStyle(color: RiderColors.text, fontSize: 12.5, fontWeight: FontWeight.w900)),
          SizedBox(height: 2),
          Text('${item.type} • ${item.date}', style: TextStyle(color: RiderColors.muted, fontSize: 10)),
        ])),
        Text('+₱${item.amount.toStringAsFixed(0)}', style: TextStyle(color: RiderColors.green, fontSize: 14, fontWeight: FontWeight.w900)),
      ]),
    );
  }

  void _requestPayout() {
    final controller = TextEditingController(text: _walletBalance.toStringAsFixed(0));
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Request payout'),
        content: TextField(controller: controller, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(prefixText: '₱ ', labelText: 'Amount', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('Cancel')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.trim()) ?? 0;
              if (amount <= 0 || amount > _walletBalance) return;
              setState(() => _pendingPayout += amount);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Demo payout request created. API connection comes later.')));
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
