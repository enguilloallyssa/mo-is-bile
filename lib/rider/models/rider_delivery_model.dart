class RiderDelivery {
  final int id;
  final String orderNumber;
  final String pickupName;
  final String pickupAddress;
  final String buyerName;
  final String buyerAddress;
  final String sellerName;
  final double deliveryFee;
  final String status;

  const RiderDelivery({
    required this.id,
    required this.orderNumber,
    required this.pickupName,
    this.pickupAddress = '',
    required this.buyerName,
    this.buyerAddress = '',
    this.sellerName = 'SARI Seller',
    required this.deliveryFee,
    required this.status,
  });

  RiderDelivery copyWith({
    String? status,
  }) {
    return RiderDelivery(
      id: id,
      orderNumber: orderNumber,
      pickupName: pickupName,
      pickupAddress: pickupAddress,
      buyerName: buyerName,
      buyerAddress: buyerAddress,
      sellerName: sellerName,
      deliveryFee: deliveryFee,
      status: status ?? this.status,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'courier_accepted':
        return 'Courier Assigned';
      case 'heading_pickup':
        return 'Heading to Pickup';
      case 'arrived_pickup':
        return 'Arrived at Pickup';
      case 'in_transit':
        return 'In Transit';
      case 'arrived_buyer':
        return 'Arrived at Buyer';
      case 'delivered':
        return 'Delivered';
      default:
        return status
            .replaceAll('_', ' ')
            .split(' ')
            .where((part) => part.isNotEmpty)
            .map((part) =>
                '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
            .join(' ');
    }
  }

  bool get pickupDone =>
      const ['in_transit', 'arrived_buyer', 'delivered'].contains(status);

  bool get transitDone =>
      const ['arrived_buyer', 'delivered'].contains(status);

  bool get deliveredDone => status == 'delivered';

  bool get isPickupStage => const [
        'courier_accepted',
        'heading_pickup',
        'arrived_pickup',
      ].contains(status);

  bool get isActiveDelivery =>
      const ['in_transit', 'arrived_buyer'].contains(status);

  String get actionMessage {
    switch (status) {
      case 'courier_accepted':
        return 'SARI Logistics assigned this delivery to you.';
      case 'heading_pickup':
        return 'You are heading to the Seller pickup point.';
      case 'arrived_pickup':
        return 'Check the package, then confirm the Seller handoff.';
      case 'in_transit':
        return 'Package is in transit. Confirm only when you reach the Buyer.';
      case 'arrived_buyer':
        return 'Buyer location reached. Complete the handoff.';
      default:
        return '';
    }
  }

  String get actionLabel {
    switch (status) {
      case 'courier_accepted':
        return 'Proceed to Pickup →';
      case 'heading_pickup':
        return 'I Arrived at Pickup ✓';
      case 'arrived_pickup':
        return 'Confirm Item Pickup →';
      case 'in_transit':
        return 'Confirm Arrived at Buyer →';
      case 'arrived_buyer':
        return 'Confirm Delivery Complete ✓';
      default:
        return '';
    }
  }

  String? get nextStatus {
    switch (status) {
      case 'courier_accepted':
        return 'heading_pickup';
      case 'heading_pickup':
        return 'arrived_pickup';
      case 'arrived_pickup':
        return 'in_transit';
      case 'in_transit':
        return 'arrived_buyer';
      case 'arrived_buyer':
        return 'delivered';
      default:
        return null;
    }
  }
}
