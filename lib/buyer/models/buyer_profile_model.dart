class BuyerProfileData {
  final String firstName;
  final String middleInitial;
  final String lastName;

  final String sex;
  final String birthday;

  final String email;
  final String contactNo;

  final String streetAddress;
  final String barangayName;
  final String municipalityName;
  final String provinceName;

  final String? photo;
  final String accountStatus;

  const BuyerProfileData({
    this.firstName = '',
    this.middleInitial = '',
    this.lastName = '',
    this.sex = '',
    this.birthday = '',
    this.email = '',
    this.contactNo = '',
    this.streetAddress = '',
    this.barangayName = '',
    this.municipalityName = '',
    this.provinceName = '',
    this.photo,
    this.accountStatus = '',
  });

  String get fullName {
    return [
      firstName,
      lastName,
    ].where(
      (value) => value.trim().isNotEmpty,
    ).join(' ');
  }

  String get savedArea {
    return [
      barangayName,
      municipalityName,
      provinceName,
    ].where(
      (value) => value.trim().isNotEmpty,
    ).join(', ');
  }
}