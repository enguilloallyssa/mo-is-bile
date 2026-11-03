class BuyerNotificationItem {
  final int id;
  final int orderId;

  final String type;
  final String title;
  final String message;
  final String status;

  final String sellerName;
  final String orderNumber;
  final String createdAt;

  bool isRead;

  BuyerNotificationItem({
    required this.id,
    this.orderId = 0,
    this.type = '',
    required this.title,
    required this.message,
    this.status = '',
    this.sellerName = 'SARI Seller',
    this.orderNumber = '',
    required this.createdAt,
    this.isRead = false,
  });

  bool get hasOrder =>
      orderId > 0;

  bool get isCourierUpdate {
    return const {
      'courier_accepted',
      'heading_pickup',
      'arrived_pickup',
      'in_transit',
      'arrived_buyer',
    }.contains(status);
  }
}