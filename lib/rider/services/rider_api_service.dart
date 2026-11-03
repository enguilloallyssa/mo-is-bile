import '../../services/sari_live_data.dart';

class RiderApiService {
  const RiderApiService._();

  static SariLiveData get _live =>
      SariLiveData.instance;

  static Future<Map<String, dynamic>>
      dashboard() =>
          _live.riderDashboard();

  static Future<Map<String, dynamic>>
      assignments() =>
          _live.riderAssignments();

  static Future<Map<String, dynamic>>
      pickups() =>
          _live.riderPickups();

  static Future<Map<String, dynamic>>
      deliveries() =>
          _live.riderDeliveries();

  static Future<Map<String, dynamic>>
      assignment(int orderId) =>
          _live.riderAssignment(orderId);
}