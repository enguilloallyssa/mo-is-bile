class RiderProfile {
  String firstName;
  String lastName;
  String email;
  String contactNo;
  String streetAddress;
  String vehicleType;
  String vehicleModel;
  String plateNumber;
  String licenseNumber;
  String availabilityStatus;
  int completedDeliveries;
  double rating;

  RiderProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.contactNo,
    required this.streetAddress,
    required this.vehicleType,
    required this.vehicleModel,
    required this.plateNumber,
    required this.licenseNumber,
    required this.availabilityStatus,
    required this.completedDeliveries,
    required this.rating,
  });

  String get fullName => '$firstName $lastName'.trim();
}
