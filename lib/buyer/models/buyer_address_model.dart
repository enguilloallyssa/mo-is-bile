class BuyerAddress {
  final int id;
  final String label;
  final String recipientName;
  final String contactNo;
  final String streetAddress;
  final String barangayName;
  final String municipalityName;
  final String provinceName;
  final String postalCode;
  final bool isDefault;

  const BuyerAddress({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.contactNo,
    required this.streetAddress,
    required this.barangayName,
    required this.municipalityName,
    required this.provinceName,
    this.postalCode = '',
    this.isDefault = false,
  });

  String get area => <String>[
        barangayName,
        municipalityName,
        provinceName,
        if (postalCode.trim().isNotEmpty) postalCode,
      ].where((part) => part.trim().isNotEmpty).join(', ');

  BuyerAddress copyWith({
    String? label,
    String? recipientName,
    String? contactNo,
    String? streetAddress,
    String? barangayName,
    String? municipalityName,
    String? provinceName,
    String? postalCode,
    bool? isDefault,
  }) {
    return BuyerAddress(
      id: id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      contactNo: contactNo ?? this.contactNo,
      streetAddress: streetAddress ?? this.streetAddress,
      barangayName: barangayName ?? this.barangayName,
      municipalityName: municipalityName ?? this.municipalityName,
      provinceName: provinceName ?? this.provinceName,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
