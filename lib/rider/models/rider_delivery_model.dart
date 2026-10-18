class RiderDelivery {
  final int id;
  final String orderNumber;
  final String pickupName;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String buyerName;
  final String buyerAddress;
  final double buyerLatitude;
  final double buyerLongitude;
  final double riderLatitude;
  final double riderLongitude;
  final String sellerName;
  final double deliveryFee;
  final String status;

  const RiderDelivery({
    required this.id,
    required this.orderNumber,
    required this.pickupName,
    this.pickupAddress = '',
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.buyerName,
    this.buyerAddress = '',
    required this.buyerLatitude,
    required this.buyerLongitude,
    required this.riderLatitude,
    required this.riderLongitude,
    this.sellerName = 'SARI Seller',
    required this.deliveryFee,
    required this.status,
  });

  RiderDelivery copyWith({
    String? status,
    double? riderLatitude,
    double? riderLongitude,
  }) {
    return RiderDelivery(
      id: id,
      orderNumber: orderNumber,
      pickupName: pickupName,
      pickupAddress: pickupAddress,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      buyerName: buyerName,
      buyerAddress: buyerAddress,
      buyerLatitude: buyerLatitude,
      buyerLongitude: buyerLongitude,
      riderLatitude: riderLatitude ?? this.riderLatitude,
      riderLongitude: riderLongitude ?? this.riderLongitude,
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
            .map(
              (part) =>
                  '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
            )
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

  bool get showDeliveryMap => status != 'delivered';

  bool get isHeadingToBuyer =>
      const ['in_transit', 'arrived_buyer'].contains(status);

  String get mapStageLabel =>
      isHeadingToBuyer ? 'DELIVERY DESTINATION' : 'PICKUP DESTINATION';

  String get destinationName => isHeadingToBuyer ? buyerName : pickupName;

  String get destinationAddress =>
      isHeadingToBuyer ? buyerAddress : pickupAddress;

  double get destinationLatitude =>
      isHeadingToBuyer ? buyerLatitude : pickupLatitude;

  double get destinationLongitude =>
      isHeadingToBuyer ? buyerLongitude : pickupLongitude;

  String get actionMessage {
    switch (status) {
      case 'courier_accepted':
        return 'SARI Logistics assigned this delivery to you.';
      case 'heading_pickup':
        return 'Follow the map to the Seller pickup point.';
      case 'arrived_pickup':
        return 'Check the package, then confirm the Seller handoff.';
      case 'in_transit':
        return 'Package picked up. Follow the map to the Buyer.';
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
