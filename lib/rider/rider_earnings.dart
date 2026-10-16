import 'package:flutter/material.dart';

import 'models/rider_earning_model.dart';

class RiderEarnings extends StatefulWidget {
  final List<RiderDailyEarning> daily;
  final List<RiderEarningTransaction> transactions;
  final VoidCallback onOpenHistory;

  const RiderEarnings({
    super.key,
    required this.daily,
    required this.transactions,
    required this.onOpenHistory,
  });

  @override
  State<RiderEarnings> createState() => _RiderEarningsState();
}

class _RiderEarningsState extends State<RiderEarnings> {
  static const Color _gold = Color(0xFFD9930A);
  static const Color _blue = Color(0xFF3C6E91);
  static const Color _border = Color(0xFFEEE4D3);

  final List<RiderPayoutRequest> _payoutRequests = [
    const RiderPayoutRequest(
      amount: 500,
      status: 'Pending',
    ),
  ];

  double get _today => widget.daily.isEmpty ? 0 : widget.daily.last.amount;

  double get _week => widget.daily.fold<double>(
        0,
        (sum, day) => sum + day.amount,
      );

  double get _month => _week * 3.2;

  double get _pending => _payoutRequests
      .where((item) => item.status.toLowerCase() == 'pending')
      .fold<double>(0, (sum, item) => sum + item.amount);

  double get _available {
    final value = _week - _pending;
    return value < 0 ? 0 : value;
  }

  double get _maxDaily {
    if (widget.daily.isEmpty) return 1;
    double max = 1;
    for (final day in widget.daily) {
      if (day.amount > max) max = day.amount;
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFFFDF8),
        surfaceTintColor: Colors.transparent,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profit Dashboard',
              style: TextStyle(
                color: Color(0xFF211D17),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Courier Earnings',
              style: TextStyle(
                color: Color(0xFF918677),
                fontSize: 8,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: widget.onOpenHistory,
            icon: const Icon(Icons.history),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
        children: [
          _heading(),
          const SizedBox(height: 14),
          _summaryCards(),
          const SizedBox(height: 14),
          _weeklyPerformance(),
          const SizedBox(height: 14),
          _payoutSummary(),
          const SizedBox(height: 14),
          _recentEarnings(),
        ],
      ),
    );
  }

  Widget _heading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Courier Earnings',
          style: TextStyle(
            color: Color(0xFF211D17),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Track credited delivery fees, pending earnings, and weekly performance.',
          style: TextStyle(
            color: Color(0xFF817769),
            fontSize: 8.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _toast('Statement download preview ready.'),
          icon: const Icon(Icons.download_outlined, size: 16),
          label: const Text(
            'Download Statement',
            style: TextStyle(fontSize: 8),
          ),
        ),
      ],
    );
  }

  Widget _summaryCards() {
    final cards = [
      ('Today', _peso(_today), const Color(0xFFFFF2D8),
          const Color(0xFFB77900)),
      ('This Week', _peso(_week), const Color(0xFFEAF2F7), _blue),
      ('This Month', _peso(_month), const Color(0xFFEAF3ED),
          const Color(0xFF4F7D63)),
      ('Pending', _peso(_pending), const Color(0xFFF0ECF6),
          const Color(0xFF715A86)),
      ('Available', _peso(_available), const Color(0xFFECF5EE),
          const Color(0xFF437356)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final item = cards[index];

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
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: item.$4,
                  shape: BoxShape.circle,
                ),
              ),
              const Spacer(),
              Text(
                item.$1,
                style: const TextStyle(
                  color: Color(0xFF887E70),
                  fontSize: 7.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.$2,
                style: const TextStyle(
                  color: Color(0xFF211D17),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _weeklyPerformance() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Weekly Performance',
            style: TextStyle(
              color: Color(0xFF211D17),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Delivery earnings for the current week.',
            style: TextStyle(
              color: Color(0xFF918677),
              fontSize: 7.5,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.daily.map((day) {
                final ratio = day.amount / _maxDaily;
                final height = 30 + (150 * ratio);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '₱${day.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Color(0xFF645B4F),
                            fontSize: 6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: _blue,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          day.day,
                          style: const TextStyle(
                            color: Color(0xFF857B6D),
                            fontSize: 7,
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
        ],
      ),
    );
  }

  Widget _payoutSummary() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Payout Summary',
            style: TextStyle(
              color: Color(0xFF211D17),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Current courier balance',
            style: TextStyle(
              color: Color(0xFF918677),
              fontSize: 7.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AVAILABLE BALANCE',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _peso(_available),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Next scheduled payout: Friday',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 7.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          ElevatedButton(
            onPressed: _available <= 0 ? null : _requestPayout,
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text(
              'Request Payout',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (_payoutRequests.isNotEmpty) ...[
            const SizedBox(height: 10),
            ..._payoutRequests.map(
              (payout) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Text(
                      _peso(payout.amount),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      payout.status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 6.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _recentEarnings() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Recent Earnings',
            style: TextStyle(
              color: Color(0xFF211D17),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Latest delivery fee credits.',
            style: TextStyle(
              color: Color(0xFF918677),
              fontSize: 7.5,
            ),
          ),
          const SizedBox(height: 12),
          if (widget.transactions.isEmpty)
            const Text(
              'No earnings yet.',
              textAlign: TextAlign.center,
            )
          else
            ...widget.transactions.map(
              (transaction) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF0E8DB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction.order,
                            style: const TextStyle(
                              color: Color(0xFF302A23),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '+${_peso(transaction.amount)}',
                          style: const TextStyle(
                            color: Color(0xFF302A23),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${transaction.date} · ${transaction.type}',
                      style: const TextStyle(
                        color: Color(0xFF81776A),
                        fontSize: 7,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECF7F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          transaction.status,
                          style: const TextStyle(
                            color: Color(0xFF3F7B55),
                            fontSize: 6.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _requestPayout() {
    final amount = _available;

    setState(() {
      _payoutRequests.insert(
        0,
        RiderPayoutRequest(
          amount: amount,
          status: 'Pending',
        ),
      );
    });

    _toast('Payout request preview submitted.');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _peso(double value) => '₱${value.toStringAsFixed(2)}';
}
