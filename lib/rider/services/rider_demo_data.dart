import '../models/rider_delivery_model.dart';
import '../models/rider_earning_model.dart';
import '../models/rider_history_model.dart';
import '../models/rider_message_model.dart';
import '../models/rider_profile_model.dart';

class RiderDemoData {
  static const RiderDelivery currentDelivery = RiderDelivery(
    id: 101,
    orderNumber: 'SARI-2026-0048',
    pickupName: 'SARI Tech Corner',
    pickupAddress: 'Diversion Road, Lucena City',
    buyerName: 'Juan Dela Cruz',
    buyerAddress: 'Brgy. Ibabang Dupay, Lucena City',
    sellerName: 'SARI Tech Corner',
    deliveryFee: 80,
    status: 'courier_accepted',
  );

  static const List<RiderDelivery> assignments = [
    currentDelivery,
    RiderDelivery(
      id: 102,
      orderNumber: 'SARI-2026-0049',
      pickupName: 'Daily Finds',
      pickupAddress: 'Quezon Avenue, Lucena City',
      buyerName: 'Maria Santos',
      buyerAddress: 'Brgy. Gulang-Gulang, Lucena City',
      sellerName: 'Daily Finds',
      deliveryFee: 80,
      status: 'courier_accepted',
    ),
    RiderDelivery(
      id: 103,
      orderNumber: 'SARI-2026-0050',
      pickupName: 'Local Essentials',
      pickupAddress: 'Maharlika Highway, Lucena City',
      buyerName: 'Ken Reyes',
      buyerAddress: 'Brgy. Isabang, Lucena City',
      sellerName: 'Local Essentials',
      deliveryFee: 95,
      status: 'courier_accepted',
    ),
  ];

  static const List<RiderHistoryRecord> history = [
    RiderHistoryRecord(
      order: 'SARI-2026-0042',
      customer: 'Ana Cruz',
      route: 'Downtown Seller → Brgy. 5',
      date: 'Oct 07, 2026',
      time: '11:40 AM',
      fee: 80,
      status: 'Completed',
      isToday: true,
    ),
    RiderHistoryRecord(
      order: 'SARI-2026-0041',
      customer: 'Paolo Reyes',
      route: 'Local Essentials → Brgy. Cotta',
      date: 'Oct 07, 2026',
      time: '09:15 AM',
      fee: 95,
      status: 'Completed',
      isToday: true,
    ),
    RiderHistoryRecord(
      order: 'SARI-2026-0037',
      customer: 'Mika Santos',
      route: 'SARI Tech Corner → Brgy. Dalahican',
      date: 'Oct 06, 2026',
      time: '04:25 PM',
      fee: 80,
      status: 'Completed',
      isToday: false,
    ),
    RiderHistoryRecord(
      order: 'SARI-2026-0033',
      customer: 'John Lim',
      route: 'Daily Finds → Brgy. Bocohan',
      date: 'Oct 05, 2026',
      time: '02:10 PM',
      fee: 85,
      status: 'Completed',
      isToday: false,
    ),
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
    RiderEarningTransaction(
      order: 'SARI-2026-0042',
      date: 'Oct 07, 2026',
      type: 'Delivery Fee',
      amount: 80,
      status: 'Credited',
    ),
    RiderEarningTransaction(
      order: 'SARI-2026-0041',
      date: 'Oct 07, 2026',
      type: 'Delivery Fee',
      amount: 95,
      status: 'Credited',
    ),
    RiderEarningTransaction(
      order: 'SARI-2026-0037',
      date: 'Oct 06, 2026',
      type: 'Delivery Fee',
      amount: 80,
      status: 'Credited',
    ),
  ];

  static const List<RiderMessage> messages = [
    RiderMessage(
      id: 1,
      senderRole: 'logistics',
      body: 'You have a new delivery assignment. Please check the pickup details.',
      createdAt: 'Oct 07, 02:10 PM',
    ),
    RiderMessage(
      id: 2,
      senderRole: 'rider',
      body: 'Received. I will proceed to the seller pickup point.',
      createdAt: 'Oct 07, 02:12 PM',
    ),
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
