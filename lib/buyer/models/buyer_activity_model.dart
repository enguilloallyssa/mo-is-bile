class BuyerActivity {
  final int id;
  final String type;
  final String title;
  final String message;
  final String orderNumber;
  final String storeName;
  final String status;
  final String createdAt;
  final int? orderId;

  const BuyerActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.orderNumber,
    required this.storeName,
    required this.status,
    required this.createdAt,
    this.orderId,
  });

  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';

  bool get isShipping => const <String>{
        'courier_accepted',
        'heading_pickup',
        'arrived_pickup',
        'in_transit',
        'arrived_buyer',
      }.contains(status);
}
