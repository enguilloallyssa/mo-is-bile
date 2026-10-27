class RiderDelivery {
  final int id;
  final String orderNumber;
  final String packageCode;
  final String pickupName;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String sortingCenterName;
  final String sortingCenterAddress;
  final double sortingCenterLatitude;
  final double sortingCenterLongitude;
  final String buyerName;
  final String buyerAddress;
  final double buyerLatitude;
  final double buyerLongitude;
  final double riderLatitude;
  final double riderLongitude;
  final String sellerName;
  final double deliveryFee;
  final String status;
  final String? failureReason;

  const RiderDelivery({
    required this.id,
    required this.orderNumber,
    this.packageCode = 'PKG-DEMO-001',
    required this.pickupName,
    this.pickupAddress = '',
    required this.pickupLatitude,
    required this.pickupLongitude,
    this.sortingCenterName = 'SARI Sorting Center',
    this.sortingCenterAddress = 'Lucena City, Quezon',
    this.sortingCenterLatitude = 13.9416,
    this.sortingCenterLongitude = 121.6235,
    required this.buyerName,
    this.buyerAddress = '',
    required this.buyerLatitude,
    required this.buyerLongitude,
    required this.riderLatitude,
    required this.riderLongitude,
    this.sellerName = 'SARI Seller',
    required this.deliveryFee,
    required this.status,
    this.failureReason,
  });

  RiderDelivery copyWith({String? status, double? riderLatitude, double? riderLongitude, String? failureReason}) {
    return RiderDelivery(
      id: id,
      orderNumber: orderNumber,
      packageCode: packageCode,
      pickupName: pickupName,
      pickupAddress: pickupAddress,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      sortingCenterName: sortingCenterName,
      sortingCenterAddress: sortingCenterAddress,
      sortingCenterLatitude: sortingCenterLatitude,
      sortingCenterLongitude: sortingCenterLongitude,
      buyerName: buyerName,
      buyerAddress: buyerAddress,
      buyerLatitude: buyerLatitude,
      buyerLongitude: buyerLongitude,
      riderLatitude: riderLatitude ?? this.riderLatitude,
      riderLongitude: riderLongitude ?? this.riderLongitude,
      sellerName: sellerName,
      deliveryFee: deliveryFee,
      status: status ?? this.status,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pickup_assigned': return 'Pickup Assigned';
      case 'pickup_accepted': return 'Pickup Accepted';
      case 'heading_seller': return 'Heading to Seller';
      case 'arrived_seller': return 'At Seller';
      case 'parcel_collected': return 'Parcel Collected';
      case 'heading_sorting': return 'Going to Sorting Center';
      case 'arrived_sorting': return 'At Sorting Center';
      case 'sorting_received': return 'Sorting Center Received';
      case 'delivery_assigned': return 'Delivery Assigned';
      case 'delivery_accepted': return 'Delivery Accepted';
      case 'parcel_released': return 'Parcel Picked Up';
      case 'out_for_delivery': return 'Out for Delivery';
      case 'arrived_buyer': return 'At Customer';
      case 'delivered': return 'Delivered';
      case 'completed': return 'Completed';
      case 'delivery_failed': return 'Delivery Failed';
      case 'returning_to_sorting': return 'Returning to Sorting Center';
      case 'courier_accepted': return 'Pickup Accepted';
      case 'heading_pickup': return 'Heading to Seller';
      case 'arrived_pickup': return 'At Seller';
      case 'in_transit': return 'Out for Delivery';
      default:
        return status.replaceAll('_', ' ').split(' ').where((part) => part.isNotEmpty).map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}').join(' ');
    }
  }

  bool get isPickupFlow => const <String>[
    'pickup_assigned','pickup_accepted','heading_seller','arrived_seller','parcel_collected','heading_sorting','arrived_sorting','sorting_received','courier_accepted','heading_pickup','arrived_pickup'
  ].contains(status);

  bool get isDeliveryFlow => const <String>[
    'delivery_assigned','delivery_accepted','parcel_released','out_for_delivery','arrived_buyer','delivered','completed','delivery_failed','returning_to_sorting','in_transit'
  ].contains(status);

  bool get isPickupStage => isPickupFlow && status != 'sorting_received';
  bool get isActiveDelivery => const <String>['delivery_assigned','delivery_accepted','parcel_released','out_for_delivery','arrived_buyer','delivered','delivery_failed','returning_to_sorting','in_transit'].contains(status);
  bool get isComplete => status == 'completed';
  bool get isFailed => status == 'delivery_failed';
  bool get isAtCustomer => status == 'arrived_buyer';
  bool get waitingForBuyerConfirmation => status == 'delivered';
  bool get showDeliveryMap => !const <String>['sorting_received','delivered','completed','delivery_failed'].contains(status);
  bool get isHeadingToBuyer => const <String>['out_for_delivery','arrived_buyer','in_transit'].contains(status);
  bool get isHeadingToSortingCenter => const <String>['heading_sorting','arrived_sorting','delivery_assigned','delivery_accepted','parcel_released','returning_to_sorting'].contains(status);

  String get destinationRoleLabel {
    if (isHeadingToBuyer) return 'Customer';
    if (isHeadingToSortingCenter) return 'Sorting Center';
    return 'Seller';
  }

  String get mapStageLabel => destinationRoleLabel.toUpperCase();
  String get destinationName => isHeadingToBuyer ? buyerName : (isHeadingToSortingCenter ? sortingCenterName : pickupName);
  String get destinationAddress => isHeadingToBuyer ? buyerAddress : (isHeadingToSortingCenter ? sortingCenterAddress : pickupAddress);
  double get destinationLatitude => isHeadingToBuyer ? buyerLatitude : (isHeadingToSortingCenter ? sortingCenterLatitude : pickupLatitude);
  double get destinationLongitude => isHeadingToBuyer ? buyerLongitude : (isHeadingToSortingCenter ? sortingCenterLongitude : pickupLongitude);
  String get legLabel => isDeliveryFlow ? 'Last-mile delivery' : 'Seller pickup';

  String get actionMessage {
    switch (status) {
      case 'pickup_assigned': return 'A seller pickup was assigned to you. Review the route and accept when ready.';
      case 'pickup_accepted': return 'Pickup accepted. Start your trip to the seller.';
      case 'heading_seller': return 'Follow the route and confirm when you reach the seller.';
      case 'arrived_seller': return 'Verify the parcel with the seller before taking custody.';
      case 'parcel_collected': return 'Scan or confirm the parcel code before leaving the seller.';
      case 'heading_sorting': return 'Bring the confirmed parcel to the sorting center.';
      case 'arrived_sorting': return 'Hand the parcel to sorting staff and confirm the transfer.';
      case 'sorting_received': return 'Parcel is now with the sorting center. Wait for a last-mile assignment.';
      case 'delivery_assigned': return 'A sorted parcel is ready for delivery. Review the customer address.';
      case 'delivery_accepted': return 'Pick up the parcel from the sorting center.';
      case 'parcel_released': return 'Parcel released to you. Mark it out for delivery before leaving.';
      case 'out_for_delivery': return 'Travel to the customer and confirm when you arrive.';
      case 'arrived_buyer': return 'Complete the handoff, then record whether delivery was successful.';
      case 'delivered': return 'Rider handoff recorded. Waiting for buyer receipt confirmation.';
      case 'completed': return 'Order flow is complete.';
      case 'delivery_failed': return 'Delivery was not completed. Record the next action.';
      case 'returning_to_sorting': return 'Return the parcel safely to the sorting center.';
      default: return 'Continue the assigned rider workflow.';
    }
  }

  String get actionLabel {
    switch (status) {
      case 'pickup_assigned': return 'Accept Pickup';
      case 'pickup_accepted': return 'Go to Seller';
      case 'heading_seller': return 'I Arrived at Seller';
      case 'arrived_seller': return 'Pick Up Parcel';
      case 'parcel_collected': return 'Scan / Confirm Parcel';
      case 'heading_sorting': return 'I Arrived at Sorting Center';
      case 'arrived_sorting': return 'Hand Over Parcel';
      case 'sorting_received': return 'Demo: Assign for Delivery';
      case 'delivery_assigned': return 'Accept Delivery';
      case 'delivery_accepted': return 'Pick Up From Sorting Center';
      case 'parcel_released': return 'Mark Out for Delivery';
      case 'out_for_delivery': return 'I Arrived at Customer';
      case 'delivered': return 'Demo: Buyer Confirmed Receipt';
      case 'returning_to_sorting': return 'Returned to Sorting Center';
      default: return '';
    }
  }

  String? get nextStatus {
    switch (status) {
      case 'pickup_assigned': return 'pickup_accepted';
      case 'pickup_accepted': return 'heading_seller';
      case 'heading_seller': return 'arrived_seller';
      case 'arrived_seller': return 'parcel_collected';
      case 'parcel_collected': return 'heading_sorting';
      case 'heading_sorting': return 'arrived_sorting';
      case 'arrived_sorting': return 'sorting_received';
      case 'sorting_received': return 'delivery_assigned';
      case 'delivery_assigned': return 'delivery_accepted';
      case 'delivery_accepted': return 'parcel_released';
      case 'parcel_released': return 'out_for_delivery';
      case 'out_for_delivery': return 'arrived_buyer';
      case 'delivered': return 'completed';
      case 'returning_to_sorting': return 'sorting_received';
      case 'courier_accepted': return 'heading_seller';
      case 'heading_pickup': return 'arrived_seller';
      case 'arrived_pickup': return 'parcel_collected';
      case 'in_transit': return 'arrived_buyer';
      default: return null;
    }
  }

  double get workflowProgress {
    const sequence = <String>['pickup_assigned','pickup_accepted','heading_seller','arrived_seller','parcel_collected','heading_sorting','arrived_sorting','sorting_received','delivery_assigned','delivery_accepted','parcel_released','out_for_delivery','arrived_buyer','delivered','completed'];
    if (status == 'delivery_failed') return 12 / (sequence.length - 1);
    if (status == 'returning_to_sorting') return 7 / (sequence.length - 1);
    final index = sequence.indexOf(status);
    if (index < 0) return 0;
    return index / (sequence.length - 1);
  }
}
