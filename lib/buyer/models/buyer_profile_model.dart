class BuyerProfileData {
  final String firstName;
  final String lastName;
  final String email;
  final String contactNo;
  final String streetAddress;
  final String barangayName;
  final String municipalityName;
  final String provinceName;
  final String? photo;
  final String socialProvider;

  const BuyerProfileData({
    this.firstName = 'Ken',
    this.lastName = 'Buyer',
    this.email = 'buyer@sari.test',
    this.contactNo = '09123456789',
    this.streetAddress = '123 Rizal St.',
    this.barangayName = 'San Isidro',
    this.municipalityName = 'Lucena City',
    this.provinceName = 'Quezon',
    this.photo,
    this.socialProvider = '',
  });

  String get fullName => '$firstName $lastName'.trim();
  String get savedArea => [
        barangayName,
        municipalityName,
        provinceName,
      ].where((e) => e.trim().isNotEmpty).join(', ');
}
