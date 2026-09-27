class BuyerOrder {
  final int id;
  final String orderNumber;
  final String status;
  final String paymentMethod;
  final double? totalAmount;
  final String createdAt;
  final String expectedDelivery;
  final String latestUpdateTime;
  final String latestUpdateMessage;
  final String courierName;
  final double courierRating;
  final int courierDeliveries;
  final String deliveryAddress;
  final int sellerAccountId;
  final List<String> productNames;
  final String? returnRequestStatus;
  final String? returnSellerResponse;

  const BuyerOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentMethod,
    this.totalAmount,
    required this.createdAt,
    required this.expectedDelivery,
    required this.latestUpdateTime,
    required this.latestUpdateMessage,
    required this.courierName,
    required this.courierRating,
    required this.courierDeliveries,
    required this.deliveryAddress,
    required this.sellerAccountId,
    this.productNames = const [],
    this.returnRequestStatus,
    this.returnSellerResponse,
  });

  int get statusStep {
    switch (status) {
      case 'new':
        return 0;
      case 'preparing':
      case 'ready_for_pickup':
        return 1;
      case 'courier_accepted':
      case 'heading_pickup':
      case 'arrived_pickup':
        return 2;
      case 'in_transit':
      case 'arrived_buyer':
        return 3;
      case 'delivered':
        return 4;
      default:
        return 0;
    }
  }

  String get filterGroup {
    if (status == 'delivered') return 'delivered';
    if (status == 'cancelled') return 'cancelled';

    if ([
      'courier_accepted',
      'heading_pickup',
      'arrived_pickup',
      'in_transit',
      'arrived_buyer',
    ].contains(status)) {
      return 'in-transit';
    }

    return 'to-ship';
  }

  String get statusLabel {
    switch (status) {
      case 'new':
        return 'Order Placed';
      case 'preparing':
      case 'ready_for_pickup':
        return 'Preparing';
      case 'courier_accepted':
      case 'heading_pickup':
      case 'arrived_pickup':
        return 'Courier Assigned';
      case 'in_transit':
      case 'arrived_buyer':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status
            .replaceAll('_', ' ')
            .split(' ')
            .where((word) => word.isNotEmpty)
            .map(
              (word) =>
                  '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
            )
            .join(' ');
    }
  }

  bool get isDelivered => status == 'delivered';
  bool get isLiveDelivery => statusStep >= 2 && statusStep < 4;
}
