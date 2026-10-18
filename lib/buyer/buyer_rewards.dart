import 'package:flutter/material.dart';

import 'models/buyer_reward_model.dart';

class BuyerRewards extends StatelessWidget {
  final int points;
  final double spent;
  final List<BuyerRewardActivity> activities;

  const BuyerRewards({
    super.key,
    this.points = 315,
    this.spent = 3149,
    this.activities = const [
      BuyerRewardActivity(
        orderNumber: 'SARI-2026-0003',
        orderTotal: 349,
        earnedPoints: 34,
        deliveredDate: 'Sep 23, 2026',
      ),
      BuyerRewardActivity(
        orderNumber: 'SARI-2026-0008',
        orderTotal: 1299,
        earnedPoints: 129,
        deliveredDate: 'Sep 18, 2026',
      ),
      BuyerRewardActivity(
        orderNumber: 'SARI-2026-0011',
        orderTotal: 1501,
        earnedPoints: 150,
        deliveredDate: 'Sep 10, 2026',
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Rewards',
          style: TextStyle(
            color: Color(0xFF302A24),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SARI MARKETPLACE',
              style: TextStyle(
                color: Color(0xFFA76F13),
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Rewards',
              style: TextStyle(
                color: Color(0xFF202834),
                fontSize: 27,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Earn points from successful purchases and track your rewards activity in one place.',
              style: TextStyle(
                color: Color(0xFF7F8A98),
                fontSize: 8.3,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            _overview(),
            const SizedBox(height: 12),
            _activityCard(context),
          ],
        ),
      ),
    );
  }

  Widget _overview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E7EC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1F2937),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth >= 540;
          final pointCard = _rewardStat(
            icon: Icons.star_outline,
            label: 'Your Reward Points',
            value: '$points',
            unit: 'points',
            copy: 'Automatically earned from successfully delivered purchases.',
          );
          final spendCard = _rewardStat(
            icon: Icons.credit_card_outlined,
            label: 'Delivered Spend',
            value: _peso(spent),
            copy: 'Total amount from successfully delivered orders.',
          );

          if (!horizontal) {
            return Column(
              children: [
                pointCard,
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFE7EBEF), height: 1),
                const SizedBox(height: 12),
                spendCard,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: pointCard),
              const SizedBox(width: 16),
              Container(width: 1, height: 88, color: const Color(0xFFE7EBEF)),
              const SizedBox(width: 16),
              Expanded(child: spendCard),
            ],
          );
        },
      ),
    );
  }

  Widget _rewardStat({
    required IconData icon,
    required String label,
    required String value,
    String? unit,
    required String copy,
  }) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9ED),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFF0E1C1)),
          ),
          child: Icon(icon, color: const Color(0xFFC3830E), size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF657080),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFFBF7D08),
                        fontSize: 26,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    if (unit != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        unit,
                        style: const TextStyle(
                          color: Color(0xFF202834),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                copy,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF8993A0),
                  fontSize: 6.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _activityCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E7EC)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9ED),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: const Color(0xFFF0E2C5)),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: Color(0xFFC18412),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reward Activity',
                        style: TextStyle(
                          color: Color(0xFF28313B),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Recent points earned from delivered purchases.',
                        style: TextStyle(color: Color(0xFF8993A0), fontSize: 7),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE1E6EB)),
                  ),
                  child: Text(
                    '${activities.length} ${activities.length == 1 ? 'activity' : 'activities'}',
                    style: const TextStyle(
                      color: Color(0xFF66717D),
                      fontSize: 6.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEDF0F3)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: activities.isEmpty
                ? _emptyActivity(context)
                : Column(
                    children: activities.map(_activityRow).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _activityRow(BuyerRewardActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE7EBEF)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFAF1),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFEADFC9)),
            ),
            child: const Icon(Icons.savings_outlined, color: Color(0xFFA97010), size: 16),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.orderNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF343C45),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Delivered ${activity.deliveredDate}',
                  style: const TextStyle(color: Color(0xFF89929C), fontSize: 6.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FAF7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD6E7DC)),
                ),
                child: Text(
                  '+${activity.earnedPoints} pts',
                  style: const TextStyle(
                    color: Color(0xFF4D765D),
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${_peso(activity.orderTotal)} delivered',
                style: const TextStyle(
                  color: Color(0xFF89929C),
                  fontSize: 6.5,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyActivity(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 16),
      child: Column(
        children: [
          const Icon(Icons.card_giftcard_outlined, color: Color(0xFFBE7D0D), size: 40),
          const SizedBox(height: 10),
          const Text(
            'No reward activity yet',
            style: TextStyle(
              color: Color(0xFF303740),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Complete your first successful delivery to start earning SARI reward points.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF8A949F), fontSize: 7.2, height: 1.45),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.shopping_bag_outlined, size: 14),
            label: const Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC88912),
              foregroundColor: Colors.white,
              elevation: 0,
              textStyle: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  String _peso(double value) => '₱${value.toStringAsFixed(2)}';
}
