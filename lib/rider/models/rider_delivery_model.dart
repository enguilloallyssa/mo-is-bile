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

  /// True when this assignment is a
  /// Seller -> Origin Hub logistics pickup.
  final bool isLogisticsPickup;

  /// Exact actions currently allowed by Laravel.
  ///
  /// Examples:
  /// proceed_pickup
  /// arrived_pickup
  /// confirm_pickup
  /// arrived_buyer
  /// complete
  final List<String> allowedActions;

  const RiderDelivery({
    required this.id,
    required this.orderNumber,
    this.packageCode = '',

    required this.pickupName,
    this.pickupAddress = '',
    required this.pickupLatitude,
    required this.pickupLongitude,

    this.sortingCenterName = 'SARI Hub',
    this.sortingCenterAddress = '',
    this.sortingCenterLatitude = 0,
    this.sortingCenterLongitude = 0,

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

    this.isLogisticsPickup = false,

    this.allowedActions = const [],
  });

  // ============================================================
  // COPY
  // ============================================================

  RiderDelivery copyWith({
    String? status,
    double? riderLatitude,
    double? riderLongitude,
    String? failureReason,
  }) {
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
      sortingCenterLatitude:
          sortingCenterLatitude,
      sortingCenterLongitude:
          sortingCenterLongitude,

      buyerName: buyerName,
      buyerAddress: buyerAddress,
      buyerLatitude: buyerLatitude,
      buyerLongitude: buyerLongitude,

      riderLatitude:
          riderLatitude ??
              this.riderLatitude,

      riderLongitude:
          riderLongitude ??
              this.riderLongitude,

      sellerName: sellerName,

      deliveryFee: deliveryFee,

      status:
          status ??
              this.status,

      failureReason:
          failureReason ??
              this.failureReason,

      isLogisticsPickup:
          isLogisticsPickup,

      allowedActions:
          allowedActions,
    );
  }

  // ============================================================
  // STATUS LABEL
  // ============================================================

  String get statusLabel {
    switch (status) {
      // Legacy/local pickup workflow.
      case 'pickup_assigned':
        return 'Pickup Assigned';

      case 'pickup_accepted':
        return 'Pickup Accepted';

      case 'heading_seller':
        return 'Heading to Seller';

      case 'arrived_seller':
        return 'At Seller';

      case 'parcel_collected':
        return 'Parcel Collected';

      case 'heading_sorting':
        return 'Going to Sorting Center';

      case 'arrived_sorting':
        return 'At Sorting Center';

      case 'sorting_received':
        return 'Sorting Center Received';

      // Legacy/local delivery workflow.
      case 'delivery_assigned':
        return 'Delivery Assigned';

      case 'delivery_accepted':
        return 'Delivery Accepted';

      case 'parcel_released':
        return 'Parcel Picked Up';

      case 'out_for_delivery':
        return 'Out for Delivery';

      case 'arrived_buyer':
        return 'At Customer';

      case 'delivered':
        return 'Delivered';

      case 'completed':
        return 'Completed';

      case 'delivery_failed':
        return 'Delivery Failed';

      case 'returning_to_sorting':
        return 'Returning to Sorting Center';

      // Current Laravel mobile API statuses.
      case 'courier_accepted':
        return 'Pickup Accepted';

      case 'heading_pickup':
        return 'Heading to Seller';

      case 'arrived_pickup':
        return 'At Seller';

      case 'in_transit':
        return isLogisticsPickup
            ? 'Heading to Hub'
            : 'Out for Delivery';

      default:
        return _titleCase(status);
    }
  }

  // ============================================================
  // WORKFLOW GROUPS
  // ============================================================

  bool get isPickupFlow {
    return const <String>{
      'pickup_assigned',
      'pickup_accepted',
      'heading_seller',
      'arrived_seller',
      'parcel_collected',
      'heading_sorting',
      'arrived_sorting',
      'sorting_received',
      'courier_accepted',
      'heading_pickup',
      'arrived_pickup',
    }.contains(status);
  }

  bool get isDeliveryFlow {
    return const <String>{
      'delivery_assigned',
      'delivery_accepted',
      'parcel_released',
      'out_for_delivery',
      'arrived_buyer',
      'delivered',
      'completed',
      'delivery_failed',
      'returning_to_sorting',
      'in_transit',
    }.contains(status);
  }

  bool get isPickupStage {
    return isPickupFlow &&
        status != 'sorting_received';
  }

  bool get isActiveDelivery {
    return const <String>{
      'delivery_assigned',
      'delivery_accepted',
      'parcel_released',
      'out_for_delivery',
      'arrived_buyer',
      'delivered',
      'delivery_failed',
      'returning_to_sorting',
      'in_transit',
    }.contains(status);
  }

  bool get isComplete {
    return status == 'completed' ||
        status == 'delivered';
  }

  bool get isFailed {
    return status == 'delivery_failed';
  }

  bool get isAtCustomer {
    return status == 'arrived_buyer';
  }

  bool get waitingForBuyerConfirmation {
    return status == 'delivered';
  }

  // ============================================================
  // MAP / DESTINATION HELPERS
  // ============================================================

  bool get isHeadingToBuyer {
    if (isLogisticsPickup) {
      return false;
    }

    return const <String>{
      'out_for_delivery',
      'arrived_buyer',
      'in_transit',
    }.contains(status);
  }

  bool get isHeadingToSortingCenter {
    if (isLogisticsPickup &&
        status == 'in_transit') {
      return true;
    }

    return const <String>{
      'heading_sorting',
      'arrived_sorting',
      'delivery_assigned',
      'delivery_accepted',
      'parcel_released',
      'returning_to_sorting',
    }.contains(status);
  }

  bool get showDeliveryMap {
    if (const <String>{
      'sorting_received',
      'delivered',
      'completed',
      'delivery_failed',
    }.contains(status)) {
      return false;
    }

    return destinationLatitude != 0 &&
        destinationLongitude != 0;
  }

  String get destinationRoleLabel {
    if (isHeadingToBuyer) {
      return 'Customer';
    }

    if (isHeadingToSortingCenter) {
      return isLogisticsPickup
          ? 'Origin Hub'
          : 'Sorting Center';
    }

    return 'Seller';
  }

  String get mapStageLabel {
    return destinationRoleLabel
        .toUpperCase();
  }

  String get destinationName {
    if (isHeadingToBuyer) {
      return buyerName;
    }

    if (isHeadingToSortingCenter) {
      return sortingCenterName;
    }

    return pickupName;
  }

  String get destinationAddress {
    if (isHeadingToBuyer) {
      return buyerAddress;
    }

    if (isHeadingToSortingCenter) {
      return sortingCenterAddress;
    }

    return pickupAddress;
  }

  double get destinationLatitude {
    if (isHeadingToBuyer) {
      return buyerLatitude;
    }

    if (isHeadingToSortingCenter) {
      return sortingCenterLatitude;
    }

    return pickupLatitude;
  }

  double get destinationLongitude {
    if (isHeadingToBuyer) {
      return buyerLongitude;
    }

    if (isHeadingToSortingCenter) {
      return sortingCenterLongitude;
    }

    return pickupLongitude;
  }

  String get legLabel {
    if (isLogisticsPickup) {
      return 'Seller pickup';
    }

    return isDeliveryFlow
        ? 'Last-mile delivery'
        : 'Seller pickup';
  }

  // ============================================================
  // ACTION MESSAGE
  // ============================================================

  String get actionMessage {
    switch (status) {
      case 'pickup_assigned':
        return 'A seller pickup was assigned to you. '
            'Review the route and accept when ready.';

      case 'pickup_accepted':
        return 'Pickup accepted. '
            'Start your trip to the seller.';

      case 'heading_seller':
        return 'Follow the route and confirm when '
            'you reach the seller.';

      case 'arrived_seller':
        return 'Verify the parcel with the seller '
            'before taking custody.';

      case 'parcel_collected':
        return 'Scan or confirm the parcel code '
            'before leaving the seller.';

      case 'heading_sorting':
        return 'Bring the confirmed parcel '
            'to the sorting center.';

      case 'arrived_sorting':
        return 'Hand the parcel to sorting staff '
            'and confirm the transfer.';

      case 'sorting_received':
        return 'Parcel is now with the sorting center. '
            'Wait for another assignment.';

      case 'delivery_assigned':
        return 'A sorted parcel is ready for delivery. '
            'Review the customer address.';

      case 'delivery_accepted':
        return 'Pick up the parcel '
            'from the sorting center.';

      case 'parcel_released':
        return 'Parcel released to you. '
            'Mark it out for delivery before leaving.';

      case 'out_for_delivery':
        return 'Travel to the customer and '
            'confirm when you arrive.';

      case 'arrived_buyer':
        return 'Complete the handoff and '
            'required delivery verification.';

      case 'delivered':
        return 'Delivery handoff has been recorded.';

      case 'completed':
        return 'Order flow is complete.';

      case 'delivery_failed':
        return failureReason?.trim().isNotEmpty == true
            ? failureReason!
            : 'Delivery was not completed.';

      case 'returning_to_sorting':
        return 'Return the parcel safely '
            'to the sorting center.';

      // Current Laravel API.
      case 'courier_accepted':
        return 'Start travelling to the '
            'Seller pickup location.';

      case 'heading_pickup':
        return 'Confirm when you have '
            'arrived at the Seller.';

      case 'arrived_pickup':
        return 'Confirm parcel pickup '
            'after verification.';

      case 'in_transit':
        if (isLogisticsPickup) {
          return 'Bring the collected parcel '
              'to the assigned origin hub.';
        }

        return 'Travel to the Buyer '
            'and confirm arrival.';

      default:
        return 'Continue the assigned '
            'rider workflow.';
    }
  }

  // ============================================================
  // ACTION LABEL
  // ============================================================

  String get actionLabel {
    if (allowedActions.isNotEmpty) {
      switch (allowedActions.first) {
        case 'proceed_pickup':
          return 'Proceed to Pickup';

        case 'arrived_pickup':
          return 'I Arrived at Seller';

        case 'confirm_pickup':
          return 'Confirm Pickup';

        case 'arrived_buyer':
          return 'I Arrived at Customer';

        case 'complete':
          return 'Complete Delivery';
      }
    }

    // Logistics pickup ends at the origin hub.
    // Do not show a Buyer-delivery action.
    if (allowedActions.isEmpty &&
        isLogisticsPickup &&
        status == 'in_transit') {
      return '';
    }

    switch (status) {
      case 'pickup_assigned':
        return 'Accept Pickup';

      case 'pickup_accepted':
        return 'Go to Seller';

      case 'heading_seller':
        return 'I Arrived at Seller';

      case 'arrived_seller':
        return 'Pick Up Parcel';

      case 'parcel_collected':
        return 'Scan / Confirm Parcel';

      case 'heading_sorting':
        return 'I Arrived at Sorting Center';

      case 'arrived_sorting':
        return 'Hand Over Parcel';

      case 'sorting_received':
        return '';

      case 'delivery_assigned':
        return 'Accept Delivery';

      case 'delivery_accepted':
        return 'Pick Up From Sorting Center';

      case 'parcel_released':
        return 'Mark Out for Delivery';

      case 'out_for_delivery':
        return 'I Arrived at Customer';

      case 'delivered':
        return '';

      case 'returning_to_sorting':
        return 'Returned to Sorting Center';

      // Current Laravel mobile API.
      case 'courier_accepted':
        return 'Proceed to Pickup';

      case 'heading_pickup':
        return 'I Arrived at Seller';

      case 'arrived_pickup':
        return 'Confirm Pickup';

      case 'in_transit':
        return isLogisticsPickup
            ? ''
            : 'I Arrived at Customer';

      case 'arrived_buyer':
        return 'Complete Delivery';

      default:
        return '';
    }
  }

  // ============================================================
  // NEXT STATUS
  // ============================================================

  String? get nextStatus {
    switch (status) {
      case 'pickup_assigned':
        return 'pickup_accepted';

      case 'pickup_accepted':
        return 'heading_seller';

      case 'heading_seller':
        return 'arrived_seller';

      case 'arrived_seller':
        return 'parcel_collected';

      case 'parcel_collected':
        return 'heading_sorting';

      case 'heading_sorting':
        return 'arrived_sorting';

      case 'arrived_sorting':
        return 'sorting_received';

      case 'sorting_received':
        return 'delivery_assigned';

      case 'delivery_assigned':
        return 'delivery_accepted';

      case 'delivery_accepted':
        return 'parcel_released';

      case 'parcel_released':
        return 'out_for_delivery';

      case 'out_for_delivery':
        return 'arrived_buyer';

      case 'delivered':
        return 'completed';

      case 'returning_to_sorting':
        return 'sorting_received';

      // Current Laravel API.
      case 'courier_accepted':
        return 'heading_seller';

      case 'heading_pickup':
        return 'arrived_seller';

      case 'arrived_pickup':
        return 'parcel_collected';

      case 'in_transit':
        return isLogisticsPickup
            ? null
            : 'arrived_buyer';

      default:
        return null;
    }
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  double get workflowProgress {
    const sequence = <String>[
      'pickup_assigned',
      'pickup_accepted',
      'heading_seller',
      'arrived_seller',
      'parcel_collected',
      'heading_sorting',
      'arrived_sorting',
      'sorting_received',
      'delivery_assigned',
      'delivery_accepted',
      'parcel_released',
      'out_for_delivery',
      'arrived_buyer',
      'delivered',
      'completed',
    ];

    if (status == 'delivery_failed') {
      return 12 /
          (sequence.length - 1);
    }

    if (status ==
        'returning_to_sorting') {
      return 7 /
          (sequence.length - 1);
    }

    // Current API statuses mapped to roughly
    // the same visual workflow.
    switch (status) {
      case 'courier_accepted':
        return .15;

      case 'heading_pickup':
        return .22;

      case 'arrived_pickup':
        return .30;

      case 'in_transit':
        return isLogisticsPickup
            ? .48
            : .78;
    }

    final index =
        sequence.indexOf(status);

    if (index < 0) {
      return 0;
    }

    return index /
        (sequence.length - 1);
  }

  static String _titleCase(
    String value,
  ) {
    final cleaned = value
        .replaceAll('_', ' ')
        .trim();

    if (cleaned.isEmpty) {
      return 'Unknown';
    }

    return cleaned
        .split(' ')
        .where(
          (part) =>
              part.isNotEmpty,
        )
        .map(
          (part) =>
              '${part[0].toUpperCase()}'
              '${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
} 