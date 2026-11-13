import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
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
  final Map<String, dynamic> _finance = {};
  final List<RiderDailyEarning> _daily = [];
  final List<RiderEarningTransaction> _transactions = [];
  final List<Map<String, dynamic>> _payouts = [];
  String _filter = 'All';

  bool _loading = true;
  bool _requestingPayout = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _daily.addAll(widget.daily);
    _transactions.addAll(widget.transactions);
    _load();
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  String _text(dynamic value, [String fallback = '']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  double _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  String _money(double value) => '₱${value.toStringAsFixed(2)}';

  String _statusLabel(String value) {
    final cleaned = value.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) return 'Unknown';
    return cleaned
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _earningTypeLabel(String value) {
    switch (value) {
      case 'direct_delivery':
        return 'Direct Delivery';
      case 'last_mile_leg':
        return 'Last-Mile Delivery';
      case 'pickup_leg':
        return 'Seller Pickup';
      default:
        return _statusLabel(value);
    }
  }

  String _formatDate(String raw) {
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return raw.isEmpty ? 'Not available' : raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateTime(String raw) {
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return raw;
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${_formatDate(raw)} · $hour:$minute $period';
  }

  RiderDailyEarning _parseDaily(dynamic raw) {
    final data = _map(raw);
    return RiderDailyEarning(
      day: _text(data['day'], '-'),
      amount: _double(data['amount']),
    );
  }

  RiderEarningTransaction _parseTransaction(dynamic raw) {
    final data = _map(raw);
    return RiderEarningTransaction(
      order: _text(data['order_number'], 'Order'),
      date: _formatDateTime(_text(data['earned_at'])),
      type: _earningTypeLabel(_text(data['earning_type'], 'earning')),
      amount: _double(data['amount']),
      status: _statusLabel(_text(data['status'], 'pending')),
    );
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    bool financeLoaded = false;

    try {
      final response = await SariLiveData.instance.riderEarnings();
      final data = _map(response['data']);
      final rawDaily = data['daily'];

      if (!mounted) return;
      setState(() {
        _finance..clear()..addAll(data);
        if (rawDaily is List) {
          _daily..clear()..addAll(rawDaily.map(_parseDaily).toList());
        }
      });
      financeLoaded = true;
    } catch (error) {
      _error = error.toString();
    }

    try {
      final response = await SariLiveData.instance.riderTransactions(page: 1, perPage: 50);
      final raw = response['data'];
      if (raw is List && mounted) {
        setState(() {
          _transactions..clear()..addAll(raw.map(_parseTransaction).toList());
        });
      }
    } catch (_) {}

    try {
      final response = await SariLiveData.instance.riderPayouts();
      final raw = response['data'];
      if (raw is List && mounted) {
        setState(() {
          _payouts..clear()..addAll(raw.map(_map).toList());
        });
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (financeLoaded) _error = null;
    });
  }

  List<RiderEarningTransaction> get _filteredTransactions {
    if (_filter == 'All') return _transactions;
    return _transactions.where((t) => t.status.toLowerCase() == _filter.toLowerCase()).toList();
  }

  Future<void> _requestPayout() async {
    if (_requestingPayout) return;
    final available = _double(_finance['available_for_payout']);
    if (available <= 0) {
      _message('No available balance for payout.');
      return;
    }

    final amountController = TextEditingController();
    final accountNameController = TextEditingController();
    final accountReferenceController = TextEditingController();
    String payoutMethod = 'gcash';
    final formKey = GlobalKey<FormState>();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: RiderColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Text('Request Payout', style: TextStyle(color: RiderColors.text, fontWeight: FontWeight.w900)),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: RiderColors.greenSoft,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: RiderColors.green.withValues(alpha: .25)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Available Balance', style: TextStyle(color: RiderColors.muted, fontSize: 11, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(_money(available), style: TextStyle(color: RiderColors.green, fontSize: 22, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Withdrawal Amount',
                          prefixText: '₱ ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) {
                          final amount = double.tryParse((value ?? '').trim());
                          if (amount == null || amount <= 0) return 'Enter a valid amount.';
                          if (amount > available) return 'Amount exceeds available balance.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: payoutMethod,
                        decoration: InputDecoration(
                          labelText: 'Payout Method',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'gcash', child: Text('GCash')),
                          DropdownMenuItem(value: 'maya', child: Text('Maya')),
                          DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                          DropdownMenuItem(value: 'manual_cash', child: Text('Manual Cash Release')),
                        ],
                        onChanged: (val) => setDialogState(() => payoutMethod = val ?? 'gcash'),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: accountNameController,
                        decoration: InputDecoration(
                          labelText: 'Account Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (val) => (val ?? '').trim().length < 2 ? 'Enter account name.' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: accountReferenceController,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number / Bank Account',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (val) => (val ?? '').trim().length < 4 ? 'Enter valid account number.' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text('Cancel', style: TextStyle(color: RiderColors.muted)),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: RiderColors.gold),
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Submit Request'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submitted != true || !mounted) {
      amountController.dispose();
      accountNameController.dispose();
      accountReferenceController.dispose();
      return;
    }

    final amount = double.parse(amountController.text.trim());
    final accountName = accountNameController.text.trim();
    final accountReference = accountReferenceController.text.trim();

    amountController.dispose();
    accountNameController.dispose();
    accountReferenceController.dispose();

    setState(() => _requestingPayout = true);

    try {
      final response = await SariLiveData.instance.riderRequestPayout(
        amount: amount,
        method: payoutMethod,
        accountName: accountName,
        accountReference: accountReference,
      );
      _message(_text(response['message'], 'Payout request submitted.'));
      await _load();
    } catch (error) {
      _message(error.toString());
    } finally {
      if (mounted) setState(() => _requestingPayout = false);
    }
  }

  void _openRemittances() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const RiderRemittances(),
      ),
    );
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Color _statusColor(String status) {
    final value = status.toLowerCase();
    if (value.contains('paid') || value.contains('released') ||
        value.contains('available') || value.contains('completed') ||
        value.contains('approved')) {
      return RiderColors.green;
    }
    if (value.contains('pending') || value.contains('reserved') ||
        value.contains('remittance')) {
      return RiderColors.goldDark;
    }
    if (value.contains('reject') || value.contains('cancel')) {
      return RiderColors.red;
    }
    return RiderColors.blue;
  }

  Color _statusSoft(String status) {
    final color = _statusColor(status);
    if (color == RiderColors.green) return RiderColors.greenSoft;
    if (color == RiderColors.goldDark) return RiderColors.goldSoft;
    if (color == RiderColors.red) return RiderColors.redSoft;
    return RiderColors.blueSoft;
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
        titleSpacing: 16,
        title: const RiderHeaderTitle(
          title: 'Rider Earnings',
          subtitle: 'Earnings and Payout Management',
        ),
        actions: const [RiderHeaderActions()],
      ),
      body: RefreshIndicator(
        color: RiderColors.gold,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
          children: [
            _hero(),
            const SizedBox(height: 18),
            if (_loading && _finance.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _errorNotice(),
                ),
              _summaryCards(),
              const SizedBox(height: 24),
              _section('Weekly Performance', 'Recognized Rider earnings for the latest seven days.'),
              const SizedBox(height: 12),
              _earningsChart(),
              const SizedBox(height: 24),
              _section('Earnings Status', 'Track balances before and after COD remittance and payout.'),
              const SizedBox(height: 12),
              _balanceSummary(),
              const SizedBox(height: 24),
              _section('Recent Earnings', 'Recognized Rider earning transactions.'),
              const SizedBox(height: 12),
              _filters(),
              const SizedBox(height: 14),
              if (_filteredTransactions.isEmpty)
                _empty(
                  icon: Icons.receipt_long_outlined,
                  title: 'No earnings records',
                  message: 'Recognized Rider earnings will appear here after eligible delivery work.',
                )
              else
                ..._filteredTransactions.map(
                  (transaction) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _transactionCard(transaction),
                  ),
                ),
              const SizedBox(height: 24),
              _section('Recent Payout Requests', 'Withdrawal requests submitted from your available Rider balance.'),
              const SizedBox(height: 12),
              if (_payouts.isEmpty)
                _empty(
                  icon: Icons.payments_outlined,
                  title: 'No payout requests yet',
                  message: 'Your payout requests will appear here after submission.',
                )
              else
                ..._payouts.map(
                  (payout) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _payoutCard(payout),
                  ),
                ),
              const SizedBox(height: 18),
              _notice(
                'COD cash is separate from Rider earnings. If an earning is awaiting COD remittance, complete the physical cash turnover before it becomes available for payout.',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return RiderEditorialHero(
      eyebrow: 'RIDER FINANCIAL OVERVIEW',
      title: 'Earnings & Payouts',
      description: 'Your Rider fees, wallet balance, payouts, and COD cash requirements.',
      icon: Icons.account_balance_wallet_outlined,
      footer: Wrap(
        spacing: 9,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            onPressed: _requestingPayout || _double(_finance['available_for_payout']) <= 0
                ? null
                : _requestPayout,
            icon: const Icon(Icons.payments_outlined, size: 17),
            label: Text(_requestingPayout ? 'Submitting...' : 'Request Payout'),
            style: FilledButton.styleFrom(
              backgroundColor: RiderColors.gold,
              foregroundColor: const Color(0xFF20180C),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _openRemittances,
            icon: const Icon(Icons.account_balance_outlined, size: 17),
            label: const Text('COD Remittance'),
            style: OutlinedButton.styleFrom(
              foregroundColor: RiderColors.text,
              backgroundColor: RiderColors.surface,
              side: BorderSide(color: RiderColors.gold.withValues(alpha: .65)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
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
                label: 'Today',
                value: _money(_double(_finance['today'])),
                icon: Icons.today_outlined,
                accent: RiderColors.blue,
                soft: RiderColors.blueSoft,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metric(
                label: 'This Week',
                value: _money(_double(_finance['this_week'])),
                icon: Icons.trending_up_rounded,
                accent: RiderColors.green,
                soft: RiderColors.greenSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metric(
                label: 'This Month',
                value: _money(_double(_finance['this_month'])),
                icon: Icons.calendar_month_outlined,
                accent: RiderColors.purple,
                soft: RiderColors.purpleSoft,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metric(
                label: 'Available',
                value: _money(_double(_finance['available_for_payout'])),
                icon: Icons.account_balance_wallet_outlined,
                accent: RiderColors.goldDark,
                soft: RiderColors.goldSoft,
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
    required IconData icon,
    required Color accent,
    required Color soft,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RiderIconBadge(
            icon: icon,
            color: accent,
            background: soft,
            size: 40,
            iconSize: 21,
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 10.5,
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
        const SizedBox(height: 3),
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
    final maxAmount = _daily.isEmpty
        ? 0.0
        : _daily.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
      decoration: _decoration(),
      child: _daily.isEmpty
          ? SizedBox(
              height: 150,
              child: Center(
                child: Text('No weekly earnings yet.',
                    style: TextStyle(color: RiderColors.muted)),
              ),
            )
          : SizedBox(
              height: 195,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _daily.map((entry) {
                  final ratio = maxAmount <= 0
                      ? 0.0
                      : (entry.amount / maxAmount).clamp(0.0, 1.0);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '₱${entry.amount.toStringAsFixed(0)}',
                            maxLines: 1,
                            style: TextStyle(
                              color: RiderColors.muted,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: ratio,
                                widthFactor: .75,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: RiderColors.gold,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.day,
                            style: TextStyle(
                              color: RiderColors.text,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
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

  Widget _balanceSummary() {
    final awaiting = _double(_finance['awaiting_cod_remittance']);
    final reserved = _double(_finance['reserved_for_payout']);
    final available = _double(_finance['available_for_payout']);
    final paid = _double(_finance['paid']);
    final completed = _finance['completed_delivery_count'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _decoration(),
      child: Column(
        children: [
          _balanceRow(
            label: 'Awaiting COD Remittance',
            value: _money(awaiting),
            icon: Icons.payments_outlined,
            color: RiderColors.goldDark,
          ),
          Divider(height: 25, color: RiderColors.border),
          _balanceRow(
            label: 'Available for Payout',
            value: _money(available),
            icon: Icons.account_balance_wallet_outlined,
            color: RiderColors.green,
          ),
          Divider(height: 25, color: RiderColors.border),
          _balanceRow(
            label: 'Reserved for Payout',
            value: _money(reserved),
            icon: Icons.lock_outline_rounded,
            color: RiderColors.blue,
          ),
          Divider(height: 25, color: RiderColors.border),
          _balanceRow(
            label: 'Lifetime Paid',
            value: _money(paid),
            icon: Icons.task_alt_rounded,
            color: RiderColors.green,
          ),
          if (completed != null) ...[
            Divider(height: 25, color: RiderColors.border),
            _balanceRow(
              label: 'Completed Deliveries',
              value: '$completed',
              icon: Icons.local_shipping_outlined,
              color: RiderColors.purple,
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: available > 0 && !_requestingPayout ? _requestPayout : null,
              icon: const Icon(Icons.payments_outlined),
              label: Text(_requestingPayout ? 'Submitting...' : 'Request Withdrawal'),
              style: FilledButton.styleFrom(
                backgroundColor: RiderColors.gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          if (awaiting > 0) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openRemittances,
                icon: const Icon(Icons.account_balance_outlined),
                label: const Text('Prepare COD Cash Remittance'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _balanceRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: RiderColors.muted, fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: RiderColors.text,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _filters() {
    final statuses = <String>{
      'All',
      ..._transactions.map((t) => t.status),
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((filter) {
          final selected = _filter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => setState(() => _filter = filter),
              selectedColor: RiderColors.blueSoft,
              backgroundColor: RiderColors.surface,
              side: BorderSide(
                color: selected ? RiderColors.blue : RiderColors.border,
              ),
              labelStyle: TextStyle(
                color: selected ? RiderColors.blue : RiderColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _transactionCard(RiderEarningTransaction transaction) {
    final statusColor = _statusColor(transaction.status);
    final statusSoft = _statusSoft(transaction.status);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _decoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RiderColors.greenSoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: RiderColors.green,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.order,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.type,
                  style: TextStyle(color: RiderColors.muted, fontSize: 11),
                ),
                if (transaction.date.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.date,
                    style: TextStyle(color: RiderColors.muted, fontSize: 10),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    transaction.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _money(transaction.amount),
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

  Widget _payoutCard(Map<String, dynamic> payout) {
    final amount = _double(payout['amount']);
    final status = _text(payout['status'], 'pending');
    final statusColor = _statusColor(status);
    final statusSoft = _statusSoft(status);
    final code = _text(payout['request_code'], 'Payout Request');
    final method = _statusLabel(_text(payout['payout_method'], 'unknown'));
    final destination = _text(payout['destination_label']);
    final requested = _formatDateTime(_text(payout['requested_at']));

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _decoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  code,
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _money(amount),
                style: TextStyle(
                  color: RiderColors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  method,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (destination.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    color: RiderColors.muted, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    destination,
                    style: TextStyle(color: RiderColors.muted, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
          if (requested.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              requested,
              style: TextStyle(color: RiderColors.muted, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  Widget _empty({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: _decoration(),
      child: Column(
        children: [
          Icon(icon, color: RiderColors.muted, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RiderColors.redSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: RiderColors.red, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error ?? 'Unable to refresh Rider earnings.',
              style: TextStyle(color: RiderColors.text, fontSize: 11.5, height: 1.4),
            ),
          ),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _notice(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RiderColors.goldSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: RiderColors.goldDark, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: RiderColors.text, fontSize: 11.5, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: RiderColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: RiderColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .03),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}