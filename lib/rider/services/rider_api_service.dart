class RiderApiService {
  const RiderApiService();

  // Placeholder for the later Laravel API integration.
  // The current Rider module uses local demo state only.
  Future<void> refreshAssignments() async {}

  Future<void> updateDeliveryStatus({
    required int orderId,
    required String status,
  }) async {}

  Future<void> sendLogisticsMessage(String body) async {}

  Future<void> updateAvailability(String status) async {}

  Future<void> requestPayout(double amount) async {}
}
