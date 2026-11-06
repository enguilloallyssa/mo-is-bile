import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'models/buyer_reward_model.dart';

class BuyerRewards extends StatefulWidget {
  const BuyerRewards({super.key});

  @override
  State<BuyerRewards> createState() => _BuyerRewardsState();
}

class _BuyerRewardsState extends State<BuyerRewards> {
  bool _loading = true;
  String? _error;
  int _points = 0;
  double _spent = 0;
  List<BuyerRewardActivity> _activities = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final response =
          await SariLiveData.instance.buyerRewards();

      final raw = response['data'];

      final data = raw is Map
          ? Map<String, dynamic>.from(raw)
          : <String, dynamic>{};

      final activities = data['activities'];

      final parsed = <BuyerRewardActivity>[];

      if (activities is List) {
        for (final item
            in activities.whereType<Map>()) {
          final m =
              Map<String, dynamic>.from(item);

          final delivered =
              DateTime.tryParse(
            '${m['delivered_at'] ?? ''}',
          );

          parsed.add(
            BuyerRewardActivity(
              orderNumber:
                  '${m['order_number'] ?? ''}',
              orderTotal:
                  (m['order_total'] as num?)
                          ?.toDouble() ??
                      double.tryParse(
                        '${m['order_total']}',
                      ) ??
                      0,
              earnedPoints:
                  (m['earned_points'] as num?)
                          ?.toInt() ??
                      0,
              deliveredDate:
                  delivered == null
                      ? ''
                      : '${delivered.month}/${delivered.day}/${delivered.year}',
            ),
          );
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _points =
            (data['points'] as num?)
                    ?.toInt() ??
                0;

        _spent =
            (data['spent'] as num?)
                    ?.toDouble() ??
                double.tryParse(
                  '${data['spent']}',
                ) ??
                0;

        _activities = parsed;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF7F5F1,
      ),
      appBar: AppBar(
        title:
            const Text(
          'Rewards',
        ),
        actions: [
          IconButton(
            onPressed:
                _load,
            icon:
                const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body:
          RefreshIndicator(
        onRefresh:
            _load,
        child:
            ListView(
          padding:
              const EdgeInsets.fromLTRB(
            14,
            14,
            14,
            28,
          ),
          children: [
            if (_loading)
              const LinearProgressIndicator(),

            if (_error != null)
              Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                child: Text(
                  _error!,
                  style:
                      const TextStyle(
                    color:
                        Colors.red,
                  ),
                ),
              ),

            Row(
              children: [
                Expanded(
                  child:
                      _stat(
                    'Reward Points',
                    '$_points',
                    Icons
                        .star_outline_rounded,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child:
                      _stat(
                    'Delivered Spend',
                    _peso(
                      _spent,
                    ),
                    Icons
                        .payments_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'Reward Activity',
              style:
                  TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            if (_activities.isEmpty &&
                !_loading)
              const Card(
                child:
                    Padding(
                  padding:
                      EdgeInsets.all(
                    24,
                  ),
                  child:
                      Center(
                    child:
                        Text(
                      'No delivered-order reward activity yet.',
                    ),
                  ),
                ),
              ),

            ..._activities.map(
              (
                activity,
              ) =>
                  Card(
                child:
                    ListTile(
                  leading:
                      const CircleAvatar(
                    child:
                        Icon(
                      Icons
                          .savings_outlined,
                    ),
                  ),
                  title:
                      Text(
                    activity
                        .orderNumber,
                  ),
                  subtitle:
                      Text(
                    'Delivered ${activity.deliveredDate} • ${_peso(activity.orderTotal)}',
                  ),
                  trailing:
                      Text(
                    '+${activity.earnedPoints} pts',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w900,
                      color:
                          Color(
                        0xFF4D765D,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(
    String label,
    String value,
    IconData icon,
  ) =>
      Card(
        child:
            Padding(
          padding:
              const EdgeInsets.all(
            14,
          ),
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Icon(
                icon,
                color:
                    const Color(
                  0xFFC3830E,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                value,
                maxLines: 1,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                label,
                style:
                    const TextStyle(
                  fontSize: 9,
                  color:
                      Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );

  String _peso(
    double value,
  ) =>
      '₱${value.toStringAsFixed(2)}';
}