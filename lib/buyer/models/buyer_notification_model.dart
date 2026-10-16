class BuyerNotificationItem {
  final int id;
  final String title;
  final String message;
  final String status;
  final String sellerName;
  final String orderNumber;
  final String createdAt;
  bool isRead;

  BuyerNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.status,
    this.sellerName = 'SARI Seller',
    this.orderNumber = '',
    required this.createdAt,
    this.isRead = false,
  });

  bool get isCourierUpdate => const {
        'courier_accepted',
        'heading_pickup',
        'arrived_pickup',
        'in_transit',
        'arrived_buyer',
      }.contains(status);
}
