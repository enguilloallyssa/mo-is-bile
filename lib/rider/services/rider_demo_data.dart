import '../models/rider_delivery_model.dart';
import '../models/rider_earning_model.dart';
import '../models/rider_history_model.dart';
import '../models/rider_message_model.dart';
import '../models/rider_profile_model.dart';

class RiderDemoData {
  // Local/demo only. API/database connection is not enabled yet.
  static const RiderDelivery currentDelivery = RiderDelivery(
    id: 101,
    orderNumber: 'SARI-2026-0051',
    packageCode: 'PKG-0051-LCN',
    pickupName: 'SARI Tech Corner',
    pickupAddress: 'Quezon Avenue, Lucena City',
    pickupLatitude: 13.9409,
    pickupLongitude: 121.6129,
    sortingCenterName: 'SARI Lucena Sorting Center',
    sortingCenterAddress: 'Diversion Road, Lucena City',
    sortingCenterLatitude: 13.9448,
    sortingCenterLongitude: 121.6208,
    buyerName: 'Juan Dela Cruz',
    buyerAddress: 'Brgy. Ibabang Dupay, Lucena City',
    buyerLatitude: 13.9522,
    buyerLongitude: 121.6258,
    riderLatitude: 13.9444,
    riderLongitude: 121.6187,
    sellerName: 'SARI Tech Corner',
    deliveryFee: 80,
    status: 'pickup_assigned',
  );

  static const List<RiderDelivery> assignments = [currentDelivery];

  static const List<RiderHistoryRecord> history = [
    RiderHistoryRecord(order: 'SARI-2026-0048', customer: 'Ana Cruz', route: 'Daily Finds → SARI Hub → Brgy. 5', date: 'Oct 20, 2026', time: '02:40 PM', fee: 85, status: 'Completed', isToday: true),
    RiderHistoryRecord(order: 'SARI-2026-0047', customer: 'Paolo Reyes', route: 'Local Essentials → SARI Hub → Brgy. Cotta', date: 'Oct 20, 2026', time: '11:15 AM', fee: 95, status: 'Completed', isToday: true),
    RiderHistoryRecord(order: 'SARI-2026-0044', customer: 'Mika Santos', route: 'SARI Tech Corner → SARI Hub → Brgy. Dalahican', date: 'Oct 19, 2026', time: '04:25 PM', fee: 80, status: 'Completed', isToday: false),
    RiderHistoryRecord(order: 'SARI-2026-0040', customer: 'John Lim', route: 'Downtown Seller → SARI Hub → Brgy. Bocohan', date: 'Oct 18, 2026', time: '06:10 PM', fee: 85, status: 'Failed', isToday: false),
  ];

  static const List<RiderDailyEarning> dailyEarnings = [
    RiderDailyEarning(day: 'Mon', amount: 240),
    RiderDailyEarning(day: 'Tue', amount: 320),
    RiderDailyEarning(day: 'Wed', amount: 160),
    RiderDailyEarning(day: 'Thu', amount: 400),
    RiderDailyEarning(day: 'Fri', amount: 280),
    RiderDailyEarning(day: 'Sat', amount: 360),
    RiderDailyEarning(day: 'Sun', amount: 175),
  ];

  static const List<RiderEarningTransaction> transactions = [
    RiderEarningTransaction(order: 'SARI-2026-0048', date: 'Oct 20, 2026', type: 'Delivery Fee', amount: 85, status: 'Credited'),
    RiderEarningTransaction(order: 'SARI-2026-0047', date: 'Oct 20, 2026', type: 'Delivery Fee', amount: 95, status: 'Credited'),
    RiderEarningTransaction(order: 'SARI-2026-0044', date: 'Oct 19, 2026', type: 'Delivery Fee', amount: 80, status: 'Credited'),
  ];

  static const List<RiderMessage> messages = [
    RiderMessage(id: 1, senderRole: 'logistics', body: 'Pickup SARI-2026-0051 is ready. Please review the seller route.', createdAt: 'Oct 20, 05:40 PM'),
    RiderMessage(id: 2, senderRole: 'rider', body: 'Received. I will review the assignment now.', createdAt: 'Oct 20, 05:42 PM'),
  ];

  static RiderProfile profile = RiderProfile(
    firstName: 'Juan',
    lastName: 'Rider',
    email: 'rider@example.com',
    contactNo: '09171234567',
    streetAddress: 'Lucena City, Quezon',
    vehicleType: 'Motorcycle',
    vehicleModel: 'Honda Click 125',
    plateNumber: 'ABC 1234',
    licenseNumber: 'N01-23-456789',
    availabilityStatus: 'online',
    completedDeliveries: 124,
    rating: 4.9,
  );
}
