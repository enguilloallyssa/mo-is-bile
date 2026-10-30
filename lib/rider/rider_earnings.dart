
import 'package:flutter/material.dart';

import 'models/rider_earning_model.dart';
import 'rider_remittances.dart';
import 'widgets/rider_ui.dart';

class RiderEarnings extends StatefulWidget {
  const RiderEarnings({
    super.key,
    required this.daily,
    required this.transactions,
    required this.onOpenHistory,
  });

  final List<RiderDailyEarning> daily;
  final List<RiderEarningTransaction> transactions;
  final VoidCallback onOpenHistory;

  @override
  State<RiderEarnings> createState() => _RiderEarningsState();
}

class _RiderEarningsState extends State<RiderEarnings> {
  String _filter = 'All';

  double get _weeklyEarnings => widget.daily.fold<double>(
        0,
        (total, day) => total + day.amount,
      );

  double get _loadedEarnings =>
      widget.transactions.fold<double>(
        0,
        (total, transaction) => total + transaction.amount,
      );

  List<RiderEarningTransaction> get _filteredTransactions {
    if (_filter == 'All') return widget.transactions;

    return widget.transactions.where((transaction) {
      return transaction.status.toLowerCase() ==
          _filter.toLowerCase();
    }).toList();
  }

  void _openRemittances() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const RiderRemittances(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: RiderColors.surface,
        foregroundColor: RiderColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const RiderHeaderTitle(
          title: 'Rider Earnings',
          subtitle: 'Earnings and Payout Management',
        ),
        actions: [
          IconButton(
            tooltip: 'Delivery History',
            onPressed: widget.onOpenHistory,
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
        children: [
          _hero(),
          const SizedBox(height: 18),
          _summaryCards(),
          const SizedBox(height: 22),
          _section(
            'Weekly Performance',
            'Earnings from currently loaded records.',
          ),
          const SizedBox(height: 12),
          _earningsChart(),
          const SizedBox(height: 24),
          _section(
            'Payout Summary',
            'Track rider earnings separately from COD cash.',
          ),
          const SizedBox(height: 12),
          _payoutSummary(),
          const SizedBox(height: 24),
          _section(
            'Payout Method',
            'Options available on the Laravel Rider website.',
          ),
          const SizedBox(height: 12),
          _payoutMethods(),
          const SizedBox(height: 24),
          _section(
            'Recent Earnings',
            'Transaction history from loaded data.',
          ),
          const SizedBox(height: 12),
          _filters(),
          const SizedBox(height: 12),
          if (_filteredTransactions.isEmpty)
            _empty(
              'No earnings records',
              'Transactions will appear here when available.',
            )
          else
            ..._filteredTransactions.map(
              (transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _transactionCard(transaction),
              ),
            ),
          const SizedBox(height: 24),
          _section(
            'Recent Payout Requests',
            'Requests must be confirmed by Laravel.',
          ),
          const SizedBox(height: 12),
          _empty(
            'No payout requests loaded',
            'Connect the Rider payout API to view actual requests.',
          ),
          const SizedBox(height: 18),
          _notice(
            'Preview mode: earnings use locally supplied Flutter '
            'data. Balances, payout eligibility, and requests '
            'must come from the authenticated Laravel API.',
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
                Icons.account_balance_wallet_outlined,
                color: Colors.white70,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'RIDER FINANCIAL OVERVIEW',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Earnings & Payouts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Review your rider fees, payout activity, '
            'and cash remittance requirements.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 19),
          OutlinedButton.icon(
            onPressed: _openRemittances,
            icon: const Icon(Icons.payments_outlined),
            label: const Text('COD Cash Remittance'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
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
                'Weekly Earnings',
                _money(_weeklyEarnings),
                Icons.trending_up_rounded,
                RiderColors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metric(
                'Loaded Earnings',
                _money(_loadedEarnings),
                Icons.wallet_outlined,
                RiderColors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metric(
                'Transactions',
                '${widget.transactions.length}',
                Icons.receipt_long_outlined,
                RiderColors.purple,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metric(
                'Payout Requests',
                '—',
                Icons.payments_outlined,
                RiderColors.goldDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _money(double value) =>
      '₱${value.toStringAsFixed(2)}';

  Widget _metric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 13),
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
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String subtitle) {
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

  Widget _earningsChart() {
    final maxAmount = widget.daily.isEmpty
        ? 0.0
        : widget.daily
            .map((entry) => entry.amount)
            .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
      decoration: _decoration(),
      child: widget.daily.isEmpty
          ? SizedBox(
              height: 150,
              child: Center(
                child: Text(
                  'No weekly earnings loaded.',
                  style: TextStyle(color: RiderColors.muted),
                ),
              ),
            )
          : SizedBox(
              height: 190,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: widget.daily.map((entry) {
                  final ratio = maxAmount <= 0
                      ? 0.0
                      : (entry.amount / maxAmount).clamp(0.0, 1.0);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '₱${entry.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: RiderColors.muted,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: ratio,
                                widthFactor: .75,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: RiderColors.blue,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            entry.day,
                            style: TextStyle(
                              color: RiderColors.text,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _payoutSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoration(),
      child: Column(
        children: [
          _summaryRow(
            'Awaiting COD Remittance',
            'Not loaded',
            Icons.inventory_2_outlined,
          ),
          Divider(height: 24, color: RiderColors.border),
          _summaryRow(
            'Reserved for Payout',
            'Not loaded',
            Icons.lock_outline,
          ),
          Divider(height: 24, color: RiderColors.border),
          _summaryRow(
            'Available for Payout',
            'Not loaded',
            Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Request Payout'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Payout requests are disabled until Laravel '
            'provides the actual available balance.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: RiderColors.blue, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: RiderColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _payoutMethods() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoration(),
      child: Column(
        children: [
          _methodTile(
            Icons.phone_android_rounded,
            'GCash',
            'Requires validated account name and number.',
          ),
          Divider(color: RiderColors.border),
          _methodTile(
            Icons.payments_outlined,
            'Manual Cash Release',
            'Processed and recorded by SARI Logistics.',
          ),
          const SizedBox(height: 12),
          _notice(
            'Payout method selection and account details '
            'will be enabled after secure Laravel API integration.',
          ),
        ],
      ),
    );
  }

  Widget _methodTile(
    IconData icon,
    String title,
    String description,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: RiderColors.blue),
      title: Text(
        title,
        style: TextStyle(
          color: RiderColors.text,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          color: RiderColors.muted,
          fontSize: 11,
        ),
      ),
      trailing: Icon(
        Icons.lock_outline,
        color: RiderColors.muted,
        size: 18,
      ),
    );
  }

  Widget _filters() {
    final statuses = <String>{
      'All',
      ...widget.transactions.map(
        (transaction) => transaction.status,
      ),
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((filter) {
          final selected = _filter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => setState(() => _filter = filter),
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
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _transactionCard(RiderEarningTransaction entry) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _decoration(),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: RiderColors.greenSoft,
            child: Icon(
              Icons.receipt_long_outlined,
              color: RiderColors.green,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.order,
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.type} • ${entry.date}',
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  entry.status,
                  style: TextStyle(
                    color: RiderColors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Text(
            _money(entry.amount),
            style: TextStyle(
              color: RiderColors.green,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: _decoration(),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: RiderColors.muted,
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: RiderColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notice(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
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
            size: 19,
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

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: RiderColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: RiderColors.border),
    );
  }
}
