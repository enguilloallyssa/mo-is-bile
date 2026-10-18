import 'package:flutter/material.dart';

import 'models/buyer_notification_model.dart';

class BuyerNotifications extends StatefulWidget {
  final List<BuyerNotificationItem>? initialNotifications;

  const BuyerNotifications({
    super.key,
    this.initialNotifications,
  });

  @override
  State<BuyerNotifications> createState() => _BuyerNotificationsState();
}

class _BuyerNotificationsState extends State<BuyerNotifications> {
  late List<BuyerNotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = widget.initialNotifications ?? _demoNotifications();
  }

  int get _unreadCount => _notifications.where((item) => !item.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF302A24),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Color(0xFF9C6815),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'BUYER UPDATES',
              style: TextStyle(
                color: Color(0xFFB47B1E),
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Notifications',
              style: TextStyle(
                color: Color(0xFF201B17),
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _unreadCount > 0
                  ? '$_unreadCount unread order or delivery update${_unreadCount == 1 ? '' : 's'}.'
                  : 'You are all caught up.',
              style: const TextStyle(
                color: Color(0xFF8D8377),
                fontSize: 8.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEBE3D8)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A342A1C),
                    blurRadius: 28,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _notifications.isEmpty
                  ? _emptyState()
                  : Column(
                      children: List.generate(_notifications.length, (index) {
                        final item = _notifications[index];
                        return _notificationTile(item, index);
                      }),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationTile(BuyerNotificationItem item, int index) {
    return InkWell(
      onTap: () => _markRead(index),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFFFF9EB),
          border: index == _notifications.length - 1
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFF0E9DF)),
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.isRead
                    ? const Color(0xFFF5F2ED)
                    : const Color(0xFFFFF0CA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.isCourierUpdate
                    ? Icons.local_shipping_outlined
                    : Icons.shopping_bag_outlined,
                color: item.isRead
                    ? const Color(0xFF81786E)
                    : const Color(0xFFB7770C),
                size: 19,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF302A24),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!item.isRead) ...[
                        const SizedBox(width: 7),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD9930A),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: const TextStyle(
                      color: Color(0xFF746B61),
                      fontSize: 8,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    [
                      item.sellerName,
                      if (item.orderNumber.isNotEmpty) item.orderNumber,
                      item.createdAt,
                    ].join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFA0978B),
                      fontSize: 6.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(
                Icons.arrow_forward,
                size: 15,
                color: Color(0xFFB7770C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 56),
      child: Column(
        children: [
          Icon(Icons.notifications_none, color: Color(0xFF9B9185), size: 42),
          SizedBox(height: 12),
          Text(
            'No notifications yet',
            style: TextStyle(
              color: Color(0xFF38312A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Order and shipping updates will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF8C8378), fontSize: 8),
          ),
        ],
      ),
    );
  }

  void _markRead(int index) {
    setState(() {
      _notifications[index].isRead = true;
    });
  }

  void _markAllRead() {
    setState(() {
      for (final item in _notifications) {
        item.isRead = true;
      }
    });
  }

  List<BuyerNotificationItem> _demoNotifications() => [
        BuyerNotificationItem(
          id: 1,
          title: 'Courier assigned',
          message: 'A courier accepted your delivery and is preparing for pickup.',
          status: 'courier_accepted',
          sellerName: 'SARI Tech Corner',
          orderNumber: 'SARI-2026-0001',
          createdAt: '5 minutes ago',
        ),
        BuyerNotificationItem(
          id: 2,
          title: 'Seller is preparing your order',
          message: 'Your items are being packed before the courier pickup stage.',
          status: 'preparing',
          sellerName: 'Glow & Go',
          orderNumber: 'SARI-2026-0002',
          createdAt: '2 hours ago',
        ),
        BuyerNotificationItem(
          id: 3,
          title: 'Order delivered',
          message: 'Your package was delivered successfully. Thank you for shopping with SARI.',
          status: 'delivered',
          sellerName: 'Daily Finds',
          orderNumber: 'SARI-2026-0003',
          createdAt: 'Yesterday',
          isRead: true,
        ),
      ];
}
