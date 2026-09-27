class BuyerOrderItem {
  final String name;
  final String variantLabel;
  final int quantity;
  final double lineTotal;
  final String? image;

  const BuyerOrderItem({
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
  final String paymentMethod;
  final String paymentStatus;
  final double? totalAmount;
  final double subtotal;
  final double deliveryFee;
  final String createdAt;
  final String expectedDelivery;
  final String latestUpdateTime;
  final String latestUpdateMessage;
  final String courierName;
  final String courierEmail;
  final double courierRating;
  final int courierDeliveries;
  final String deliveryAddress;
  final String buyerName;
  final String buyerPhone;
  final String sellerName;
  final int sellerAccountId;
  final List<String> productNames;
  final List<BuyerOrderItem> items;

  final String readyAt;
  final String acceptedAt;
  final String pickedUpAt;
  final String arrivedBuyerAt;
  final String deliveredAt;

  final String? cancellationReason;
  final String? cancelledAt;

  final String? returnRequestStatus;
  final String? returnSellerResponse;

  const BuyerOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    this.totalAmount,
    this.subtotal = 0,
    this.deliveryFee = 0,
    required this.createdAt,
    required this.expectedDelivery,
    required this.latestUpdateTime,
    required this.latestUpdateMessage,
    required this.courierName,
    this.courierEmail = '',
    required this.courierRating,
    required this.courierDeliveries,
    required this.deliveryAddress,
    this.buyerName = 'SARI Buyer',
    this.buyerPhone = '',
    this.sellerName = 'SARI Seller',
    required this.sellerAccountId,
    this.productNames = const [],
    this.items = const [],
    this.readyAt = '',
    this.acceptedAt = '',
    this.pickedUpAt = '',
    this.arrivedBuyerAt = '',
    this.deliveredAt = '',
    this.cancellationReason,
    this.cancelledAt,
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

  int get trackingStatusIndex {
    switch (status) {
      case 'new':
        return 1;
      case 'preparing':
        return 2;
      case 'ready_for_pickup':
        return 3;
      case 'courier_accepted':
      case 'heading_pickup':
      case 'arrived_pickup':
        return 4;
      case 'in_transit':
        return 5;
      case 'arrived_buyer':
        return 6;
      case 'delivered':
        return 7;
      default:
        return 0;
    }
  }

  int get progress {
    if (status == 'cancelled') return 0;

    switch (status) {
      case 'new':
        return 10;
      case 'preparing':
        return 25;
      case 'ready_for_pickup':
        return 40;
      case 'courier_accepted':
        return 52;
      case 'heading_pickup':
        return 58;
      case 'arrived_pickup':
        return 66;
      case 'in_transit':
        return 78;
      case 'arrived_buyer':
        return 92;
      case 'delivered':
        return 100;
      default:
        return 0;
    }
  }

  int get routeProgress {
    if (status == 'cancelled') return 0;

    switch (status) {
      case 'new':
      case 'preparing':
        return 0;
      case 'ready_for_pickup':
        return 8;
      case 'courier_accepted':
        return 18;
      case 'heading_pickup':
        return 28;
      case 'arrived_pickup':
        return 38;
      case 'in_transit':
        return 68;
      case 'arrived_buyer':
        return 92;
      case 'delivered':
        return 100;
      default:
        return 0;
    }
  }

  int get activeSummaryStep {
    final index = trackingStatusIndex;

    if (index >= 7) return 5;
    if (index >= 6) return 4;
    if (index >= 5) return 3;
    if (index >= 2) return 2;
    if (index >= 1) return 1;
    return 0;
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

  String get deliveryHeadline {
    switch (status) {
      case 'new':
        return 'Your order has been placed.';
      case 'preparing':
        return 'The seller is preparing your order.';
      case 'ready_for_pickup':
        return 'Your parcel is ready for pickup.';
      case 'courier_accepted':
      case 'heading_pickup':
      case 'arrived_pickup':
        return 'A courier is handling your parcel.';
      case 'in_transit':
        return 'Your order is on the way.';
      case 'arrived_buyer':
        return 'Your courier has arrived.';
      case 'delivered':
        return 'Your order has been delivered.';
      default:
        return 'Track your order progress here.';
    }
  }

  String get deliverySubtext {
    switch (status) {
      case 'new':
        return 'The seller will start preparing your items shortly.';
      case 'preparing':
        return 'Your items are being packed and prepared for dispatch.';
      case 'ready_for_pickup':
        return 'Your parcel is waiting for courier pickup.';
      case 'courier_accepted':
      case 'heading_pickup':
      case 'arrived_pickup':
        return 'The courier is preparing to move your parcel to the next stage.';
      case 'in_transit':
        return 'The courier is currently moving your parcel toward your delivery area.';
      case 'arrived_buyer':
        return 'Please be ready to receive your order.';
      case 'delivered':
        return 'Thank you for shopping with SARI.';
      default:
        return 'Delivery updates will appear as your order moves through fulfillment.';
    }
  }

  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isLiveDelivery => statusStep >= 2 && statusStep < 4;

  double get resolvedSubtotal {
    if (subtotal > 0) return subtotal;

    if (items.isNotEmpty) {
      return items.fold(
        0,
        (sum, item) => sum + item.lineTotal,
      );
    }

    final double total = totalAmount ?? 0.0;
    return total > deliveryFee ? total - deliveryFee : total;
  }

  double get resolvedTotal {
    if (totalAmount != null) return totalAmount!;
    return resolvedSubtotal + deliveryFee;
  }

  List<BuyerOrderItem> get resolvedItems {
    if (items.isNotEmpty) return items;

    if (productNames.isEmpty) return const [];

    final double each = resolvedSubtotal / productNames.length;

    return productNames
        .map(
          (name) => BuyerOrderItem(
            name: name,
            lineTotal: each,
          ),
        )
        .toList();
  }
}
