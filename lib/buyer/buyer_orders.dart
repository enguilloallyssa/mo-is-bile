import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/buyer_order_model.dart';
import 'widgets/buyer_header.dart';
import 'widgets/buyer_order_card.dart';

class BuyerOrders extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;

  const BuyerOrders({
    super.key,
    this.onTabChanged,
  });

  @override
  State<BuyerOrders> createState() => _BuyerOrdersState();
}

class _BuyerOrdersState extends State<BuyerOrders> {
  static const Color _gold = Color(0xFFD99A18);

  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'all';

  final List<BuyerOrder> _orders = const [
    BuyerOrder(
      id: 1,
      orderNumber: 'SARI-2026-0001',
      status: 'courier_accepted',
      paymentMethod: 'COD',
      totalAmount: 1308,
      createdAt: 'Sep 26, 2026 • 10:30 AM',
      expectedDelivery: 'Sep 28, 2026',
      latestUpdateTime: 'Sep 27, 2026 • 08:40 AM',
      latestUpdateMessage: 'Your parcel has been accepted by the courier.',
      courierName: 'Juan Dela Cruz',
      courierRating: 4.9,
      courierDeliveries: 120,
      deliveryAddress:
          '123 Rizal St., Brgy. San Isidro, Santa Cruz, Laguna 4000',
      sellerAccountId: 101,
      productNames: [
        'Everyday Wireless Earbuds',
        'Compact Wireless Mouse',
        'Minimal Everyday Tote',
      ],
    ),
    BuyerOrder(
      id: 2,
      orderNumber: 'SARI-2026-0002',
      status: 'preparing',
      paymentMethod: 'COD',
      totalAmount: 699,
      createdAt: 'Sep 25, 2026 • 04:15 PM',
      expectedDelivery: 'Sep 29, 2026',
      latestUpdateTime: 'Sep 27, 2026 • 07:15 AM',
      latestUpdateMessage: 'The seller is preparing your items for pickup.',
      courierName: 'Pending assignment',
      courierRating: 0,
      courierDeliveries: 0,
      deliveryAddress:
          '123 Rizal St., Brgy. San Isidro, Santa Cruz, Laguna 4000',
      sellerAccountId: 202,
      productNames: ['Daily Skin Essentials Set'],
    ),
    BuyerOrder(
      id: 3,
      orderNumber: 'SARI-2026-0003',
      status: 'delivered',
      paymentMethod: 'COD',
      totalAmount: 349,
      createdAt: 'Sep 20, 2026 • 01:10 PM',
      expectedDelivery: 'Sep 23, 2026',
      latestUpdateTime: 'Sep 23, 2026 • 05:20 PM',
      latestUpdateMessage: 'Your order was delivered successfully.',
      courierName: 'Maria Santos',
      courierRating: 4.8,
      courierDeliveries: 215,
      deliveryAddress:
          '123 Rizal St., Brgy. San Isidro, Santa Cruz, Laguna 4000',
      sellerAccountId: 202,
      productNames: ['Minimal Everyday Tote'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _toShipCount => _orders
      .where(
        (order) => ['new', 'preparing', 'ready_for_pickup'].contains(order.status),
      )
      .length;

  int get _inTransitCount => _orders
      .where(
        (order) => [
          'courier_accepted',
          'heading_pickup',
          'arrived_pickup',
          'in_transit',
          'arrived_buyer',
        ].contains(order.status),
      )
      .length;

  int get _deliveredCount =>
      _orders.where((order) => order.status == 'delivered').length;

  List<BuyerOrder> get _filteredOrders {
    final query = _searchController.text.trim().toLowerCase();

    return _orders.where((order) {
      final matchesFilter =
          _activeFilter == 'all' || order.filterGroup == _activeFilter;

      final haystack =
          '${order.orderNumber} ${order.statusLabel}'.toLowerCase();

      final matchesSearch = query.isEmpty || haystack.contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  BuyerOrder? get _featuredOrder => _orders.isEmpty ? null : _orders.first;

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          BuyerHeader(
            pageTitle: 'My Orders',
            cartCount: 0,
            onSearchTap: () {},
            onCartTap: () => widget.onTabChanged?.call(2),
            onProfileTap: () => widget.onTabChanged?.call(4),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 15, 12, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _pageHeading(),
                  const SizedBox(height: 14),
                  _summaryStrip(),
                  const SizedBox(height: 14),
                  _searchAndFilters(),
                  const SizedBox(height: 14),
                  if (orders.isEmpty)
                    _emptyState()
                  else
                    ...orders.map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: BuyerOrderCard(
                          order: order,
                          onCopy: () => _copyOrderNumber(order),
                          onMessageSeller: () => _toast(
                            'Messages page will connect to Seller #${order.sellerAccountId}.',
                          ),
                          onViewDetails: () =>
                              _toast('Order Details page is the next step.'),
                          onTrackOrder: () => _showTracking(order),
                          onReturnRequest: order.isDelivered
                              ? () => _showReturnRequest(order)
                              : null,
                        ),
                      ),
                    ),
                  if (_featuredOrder?.isDelivered == true) ...[
                    const SizedBox(height: 2),
                    _quickFeedback(),
                  ],
                  const SizedBox(height: 14),
                  _buyerProtection(),
                  const SizedBox(height: 14),
                  _trackingSidebarCard(),
                  const SizedBox(height: 14),
                  _helpCard(),
                  const SizedBox(height: 14),
                  _voucherCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 4,
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 7),
            const Text(
              'SARI PURCHASE CENTER',
              style: TextStyle(
                color: Color(0xFFB87908),
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'My Orders',
          style: TextStyle(
            color: Color(0xFF181818),
            fontSize: 30,
            height: 1.05,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Track purchases, deliveries, and order updates in real-time.',
          style: TextStyle(
            color: Color(0xFF77736B),
            fontSize: 10,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => widget.onTabChanged?.call(1),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF191919),
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          icon: const Icon(Icons.shopping_bag_outlined, size: 16),
          label: const Text(
            'Continue Shopping',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _summaryStrip() {
    final items = [
      (
        Icons.receipt_long_outlined,
        'Total Orders',
        _orders.length,
        const Color(0xFFFFF5DC),
        const Color(0xFFC7890B),
      ),
      (
        Icons.inventory_2_outlined,
        'To Ship',
        _toShipCount,
        const Color(0xFFFFF7E8),
        const Color(0xFFC7890B),
      ),
      (
        Icons.local_shipping_outlined,
        'In Transit',
        _inTransitCount,
        const Color(0xFFFFF7E8),
        const Color(0xFFC7890B),
      ),
      (
        Icons.task_alt_outlined,
        'Delivered',
        _deliveredCount,
        const Color(0xFFF1F8EF),
        const Color(0xFF4C9361),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.25,
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFECE7DF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D2C2721),
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: item.$4,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(item.$1, color: item.$5, size: 18),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$2.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFA09B91),
                        fontSize: 6.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .5,
                      ),
                    ),
                    Text(
                      '${item.$3}',
                      style: const TextStyle(
                        color: Color(0xFF272521),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _searchAndFilters() {
    const filters = [
      ('all', 'All'),
      ('to-ship', 'To Ship'),
      ('in-transit', 'In Transit'),
      ('delivered', 'Delivered'),
      ('cancelled', 'Cancelled'),
    ];

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE7DF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D2C2721),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 9,
            ),
            decoration: InputDecoration(
              hintText: 'Search order number or status...',
              hintStyle: const TextStyle(
                color: Color(0xFFAAA49A),
                fontSize: 9,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFFAAA49A),
                size: 18,
              ),
              filled: true,
              fillColor: const Color(0xFFFFFDF9),
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Color(0xFFE9E2D6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Color(0xFFE9E2D6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _gold),
              ),
            ),
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 5),
              itemBuilder: (context, index) {
                final item = filters[index];
                final active = _activeFilter == item.$1;

                return ChoiceChip(
                  label: Text(item.$2),
                  selected: active,
                  onSelected: (_) {
                    setState(() {
                      _activeFilter = item.$1;
                    });
                  },
                  selectedColor: const Color(0xFFE2A52B),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: active
                        ? const Color(0xFFE2A52B)
                        : const Color(0xFFE9E2D6),
                  ),
                  labelStyle: TextStyle(
                    color: active
                        ? Colors.white
                        : const Color(0xFF77736B),
                    fontSize: 7.5,
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w600,
                  ),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECE7DF)),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5DC),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFFC7890B),
              size: 30,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            _orders.isEmpty ? 'No Orders Yet' : 'No matching orders',
            style: const TextStyle(
              color: Color(0xFF33312D),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _orders.isEmpty
                ? 'Your purchased products will appear here.'
                : 'Try another search or order status.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF77736B),
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 14),
          if (_orders.isEmpty)
            ElevatedButton(
              onPressed: () => widget.onTabChanged?.call(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCF8E0D),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Start Shopping',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  Widget _quickFeedback() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EADF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star_outline, color: _gold, size: 25),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER COMPLETE',
                  style: TextStyle(
                    color: Color(0xFF8E967F),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .7,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'How was your experience?',
                  style: TextStyle(
                    color: Color(0xFF34382F),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '★★★★★',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buyerProtection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0DFB7)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_outlined, color: _gold, size: 28),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buyer Protection',
                  style: TextStyle(
                    color: Color(0xFF282622),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your order is protected by SARI Buyer Protection.',
                  style: TextStyle(
                    color: Color(0xFF716D65),
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trackingSidebarCard() {
    final order = _featuredOrder;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECE7DF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D2C2721),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: order == null
            ? const Text(
                'Your tracking updates will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF77736B),
                  fontSize: 9,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Tracking',
                    style: TextStyle(
                      color: Color(0xFF25231F),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Live updates on your delivery',
                    style: TextStyle(
                      color: Color(0xFF89847B),
                      fontSize: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFAF0),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      order.orderNumber,
                      style: const TextStyle(
                        color: Color(0xFF34312C),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(5, (index) {
                    const labels = [
                      'Order Placed',
                      'Preparing',
                      'Courier Assigned',
                      'Out for Delivery',
                      'Delivered',
                    ];

                    final complete = index <= order.statusStep;
                    final current = index == order.statusStep;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: complete ? _gold : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: complete
                                    ? _gold
                                    : const Color(0xFFD6D0C5),
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 11,
                              color: complete
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  labels[index],
                                  style: TextStyle(
                                    color: current
                                        ? const Color(0xFFA96E03)
                                        : complete
                                            ? const Color(0xFF39362F)
                                            : const Color(0xFF8D887F),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  current
                                      ? 'Current status'
                                      : complete
                                          ? 'Completed'
                                          : 'Pending',
                                  style: const TextStyle(
                                    color: Color(0xFF9A958C),
                                    fontSize: 7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (order.isLiveDelivery) ...[
                    const SizedBox(height: 6),
                    _liveDeliveryPanel(order),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _liveDeliveryPanel(BuyerOrder order) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE6DC)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(
                width: 7,
                height: 7,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF42A66B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'LIVE DELIVERY',
                  style: TextStyle(
                    color: Color(0xFF5F5A51),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .7,
                  ),
                ),
              ),
              Text(
                'Updated now',
                style: TextStyle(
                  color: Color(0xFF9B958B),
                  fontSize: 7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6EF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9E3D9)),
            ),
            child: const Stack(
              children: [
                Positioned(
                  left: 42,
                  top: 58,
                  child: Icon(
                    Icons.two_wheeler,
                    color: Color(0xFF191919),
                    size: 26,
                  ),
                ),
                Positioned(
                  right: 35,
                  bottom: 27,
                  child: Icon(
                    Icons.home,
                    color: _gold,
                    size: 28,
                  ),
                ),
                Center(
                  child: Text(
                    'Courier route preview',
                    style: TextStyle(
                      color: Color(0xFFA09A90),
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${order.courierName} is on the way',
              style: const TextStyle(
                color: Color(0xFF34312D),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _helpCard() {
    const items = [
      (Icons.chat_bubble_outline, 'Chat with Support'),
      (Icons.assignment_return_outlined, 'Return & Refund Policy'),
      (Icons.report_problem_outlined, 'Report an Issue'),
    ];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECE7DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.headset_mic_outlined,
                color: Color(0xFFC7890B),
                size: 26,
              ),
              SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Help?',
                    style: TextStyle(
                      color: Color(0xFF292722),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "We're here for you!",
                    style: TextStyle(
                      color: Color(0xFF89847B),
                      fontSize: 7.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(
                item.$1,
                color: const Color(0xFF9A9489),
                size: 17,
              ),
              title: Text(
                item.$2,
                style: const TextStyle(
                  color: Color(0xFF555149),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFFAAA49A),
                size: 17,
              ),
              onTap: () => _toast('${item.$2} will be connected later.'),
            );
          }),
        ],
      ),
    );
  }

  Widget _voucherCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPECIAL OFFER',
                  style: TextStyle(
                    color: Color(0xFFE6B849),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .9,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Get 10% Off',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'on your next order.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.confirmation_number_outlined,
            color: Color(0xFFE6B849),
            size: 34,
          ),
        ],
      ),
    );
  }

  Future<void> _copyOrderNumber(BuyerOrder order) async {
    await Clipboard.setData(ClipboardData(text: order.orderNumber));
    if (!mounted) return;
    _toast('${order.orderNumber} copied.');
  }

  void _showTracking(BuyerOrder order) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                order.orderNumber,
                style: const TextStyle(
                  color: Color(0xFF34312D),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                order.statusLabel,
                style: const TextStyle(
                  color: Color(0xFFB87905),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                order.latestUpdateMessage,
                style: const TextStyle(
                  color: Color(0xFF77736B),
                  fontSize: 9,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Full Order Tracking page will be connected when we build buyer_order_details.dart.',
                style: TextStyle(
                  color: Color(0xFF9A958C),
                  fontSize: 8,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showReturnRequest(BuyerOrder order) async {
    String reason = 'Damaged item';
    final detailsController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Request Return / Refund',
                    style: TextStyle(
                      color: Color(0xFF302A24),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: reason,
                    items: const [
                      DropdownMenuItem(
                        value: 'Damaged item',
                        child: Text('Damaged item'),
                      ),
                      DropdownMenuItem(
                        value: 'Wrong item',
                        child: Text('Wrong item'),
                      ),
                      DropdownMenuItem(
                        value: 'Missing item',
                        child: Text('Missing item'),
                      ),
                      DropdownMenuItem(
                        value: 'Item not as described',
                        child: Text('Item not as described'),
                      ),
                      DropdownMenuItem(
                        value: 'Other',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() {
                        reason = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: detailsController,
                    maxLength: 1200,
                    minLines: 3,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Describe the issue...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _toast('Return request preview submitted: $reason');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF202124),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text(
                      'Submit Request',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    detailsController.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
