class BuyerOrderItem {
  final int productId;
  final int? variantId;

  final String name;
  final String variantLabel;

  final int quantity;
  final double lineTotal;

  final String? image;

  const BuyerOrderItem({
    this.productId = 0,
    this.variantId,
    required this.name,
    this.variantLabel = 'Standard',
    this.quantity = 1,
    required this.lineTotal,
    this.image,
  });
}

class BuyerOrder {
  final int id;

  final String orderNumber;

  final String status;

  /// Exact status label returned by Laravel.
  final String apiStatusLabel;

  final String paymentMethod;
  final String paymentStatus;

  final double? totalAmount;
  final double subtotal;
  final double deliveryFee;

  final String createdAt;
  final String deliveredAt;

  final String deliveryAddress;
  final String buyerName;
  final String buyerPhone;

  final String sellerName;
  final int sellerAccountId;

  final List<String> productNames;
  final List<BuyerOrderItem> items;

  // Kept for compatibility with older Buyer UI files.
  final String expectedDelivery;
  final String latestUpdateTime;
  final String latestUpdateMessage;

  final String courierName;
  final String courierEmail;

  final double courierRating;
  final int courierDeliveries;

  final String readyAt;
  final String acceptedAt;
  final String pickedUpAt;
  final String arrivedBuyerAt;

  final String? cancellationReason;
  final String? cancelledAt;

  final String? returnRequestStatus;
  final String? returnSellerResponse;

  const BuyerOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.apiStatusLabel = '',
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    this.totalAmount,
    this.subtotal = 0,
    this.deliveryFee = 0,
    required this.createdAt,
    this.deliveredAt = '',
    this.deliveryAddress = '',
    this.buyerName = 'SARI Buyer',
    this.buyerPhone = '',
    this.sellerName = 'SARI Seller',
    this.sellerAccountId = 0,
    this.productNames = const [],
    this.items = const [],
    this.expectedDelivery = '',
    this.latestUpdateTime = '',
    this.latestUpdateMessage = '',
    this.courierName = '',
    this.courierEmail = '',
    this.courierRating = 0,
    this.courierDeliveries = 0,
    this.readyAt = '',
    this.acceptedAt = '',
    this.pickedUpAt = '',
    this.arrivedBuyerAt = '',
    this.cancellationReason,
    this.cancelledAt,
    this.returnRequestStatus,
    this.returnSellerResponse,
  });

  String get statusLabel {
    if (apiStatusLabel
        .trim()
        .isNotEmpty) {
      return apiStatusLabel.trim();
    }

    switch (status) {
      case 'new':
        return 'Order Placed';

      case 'preparing':
        return 'Preparing';

      case 'ready_for_pickup':
        return 'Ready for Pickup';

      case 'courier_accepted':
        return 'Courier Accepted';

      case 'heading_pickup':
        return 'Heading to Pickup';

      case 'arrived_pickup':
        return 'Courier at Seller';

      case 'in_transit':
        return 'In Transit';

      case 'arrived_buyer':
        return 'Courier at Buyer';

      case 'delivered':
        return 'Delivered';

      case 'cancelled':
        return 'Cancelled';

      default:
        return status
            .replaceAll('_', ' ')
            .split(' ')
            .where(
              (word) => word.isNotEmpty,
            )
            .map(
              (word) =>
                  '${word[0].toUpperCase()}'
                  '${word.substring(1).toLowerCase()}',
            )
            .join(' ');
    }
  }

  String get filterGroup {
    if (status == 'delivered') {
      return 'delivered';
    }

    if (status == 'cancelled') {
      return 'cancelled';
    }

    if (const <String>{
      'courier_accepted',
      'heading_pickup',
      'arrived_pickup',
      'in_transit',
      'arrived_buyer',
    }.contains(status)) {
      return 'in-transit';
    }

    return 'to-ship';
  }

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

  bool get canCancel =>
      status == 'new';

  bool get canReview =>
      status == 'delivered';

  bool get isDelivered =>
      status == 'delivered';

  bool get isCancelled =>
      status == 'cancelled';

  double get resolvedSubtotal {
    if (subtotal > 0) {
      return subtotal;
    }

    if (items.isNotEmpty) {
      return items.fold<double>(
        0,
        (sum, item) =>
            sum + item.lineTotal,
      );
    }

    final double total =
        totalAmount ?? 0;

    if (total > deliveryFee) {
      return total - deliveryFee;
    }

    return total;
  }

  double get resolvedTotal {
    return totalAmount ??
        resolvedSubtotal +
            deliveryFee;
  }
}