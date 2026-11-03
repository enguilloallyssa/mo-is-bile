import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/sari_api.dart';
import '../services/sari_live_data.dart';
import 'models/rider_profile_model.dart';
import 'widgets/rider_ui.dart';

class RiderProfilePage extends StatefulWidget {
  const RiderProfilePage({
    super.key,
    required this.profile,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  final RiderProfile profile;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<RiderProfilePage> createState() =>
      _RiderProfilePageState();
}

class _RiderProfilePageState
    extends State<RiderProfilePage> {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey =
      'sari_access_token';

  static const String _roleKey =
      'sari_account_role';

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _contact;
  late final TextEditingController _address;
  late final TextEditingController _vehicleType;
  late final TextEditingController _vehicleModel;
  late final TextEditingController _plate;
  late final TextEditingController _license;

  final TextEditingController _currentPassword =
      TextEditingController();

  final TextEditingController _newPassword =
      TextEditingController();

  final TextEditingController _confirmPassword =
      TextEditingController();

  final Map<String, dynamic> _serverProfile = {};

  bool _loading = false;
  bool _editing = false;
  bool _saving = false;
  bool _updatingPassword = false;
  bool _updatingAvailability = false;
  bool _loggingOut = false;

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  late String _availability;

  String _province = '';
  String _municipality = '';
  String _barangay = '';
  String _licenseExpiry = '';
  String _profileImageUrl = '';

  double _rating = 5;
  int _completedDeliveries = 0;

  @override
  void initState() {
    super.initState();

    final profile = widget.profile;

    _firstName =
        TextEditingController(
      text: profile.firstName,
    );

    _lastName =
        TextEditingController(
      text: profile.lastName,
    );

    _email =
        TextEditingController(
      text: profile.email,
    );

    _contact =
        TextEditingController(
      text: profile.contactNo,
    );

    _address =
        TextEditingController(
      text: profile.streetAddress,
    );

    _vehicleType =
        TextEditingController(
      text: profile.vehicleType,
    );

    _vehicleModel =
        TextEditingController(
      text: profile.vehicleModel,
    );

    _plate =
        TextEditingController(
      text: profile.plateNumber,
    );

    _license =
        TextEditingController(
      text: profile.licenseNumber,
    );

    _availability =
        profile.availabilityStatus;

    _rating =
        profile.rating;

    _completedDeliveries =
        profile.completedDeliveries;

    _loadProfile();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _contact.dispose();
    _address.dispose();
    _vehicleType.dispose();
    _vehicleModel.dispose();
    _plate.dispose();
    _license.dispose();

    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();

    super.dispose();
  }

  Map<String, dynamic> _map(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return {};
  }

  String _text(
    dynamic value, [
    String fallback = '',
  ]) {
    final result =
        value?.toString().trim() ?? '';

    return result.isEmpty
        ? fallback
        : result;
  }

  int _int(
    dynamic value,
  ) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          '$value',
        ) ??
        0;
  }

  double _double(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          '$value',
        ) ??
        0;
  }

  void _message(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  void _applyProfile(
    Map<String, dynamic> data,
  ) {
    _serverProfile
      ..clear()
      ..addAll(
        data,
      );

    _firstName.text =
        _text(
      data['first_name'],
      _firstName.text,
    );

    _lastName.text =
        _text(
      data['last_name'],
      _lastName.text,
    );

    _email.text =
        _text(
      data['email'],
      _email.text,
    );

    _contact.text =
        _text(
      data['contact_no'],
      _contact.text,
    );

    _address.text =
        _text(
      data['street_address'],
      _address.text,
    );

    _vehicleType.text =
        _text(
      data['vehicle_type'],
      _vehicleType.text,
    );

    _vehicleModel.text =
        _text(
      data['vehicle_model'],
      _vehicleModel.text,
    );

    _plate.text =
        _text(
      data['plate_number'],
      _plate.text,
    );

    _license.text =
        _text(
      data['license_number'],
      _license.text,
    );

    _province =
        _text(
      data['province_name'],
      _province,
    );

    _municipality =
        _text(
      data['municipality_name'],
      _municipality,
    );

    _barangay =
        _text(
      data['barangay_name'],
      _barangay,
    );

    _licenseExpiry =
        _text(
      data['license_expiry_date'],
      _licenseExpiry,
    );

    _profileImageUrl =
        _text(
      data['profile_image_url'],
      _profileImageUrl,
    );

    _availability =
        _text(
      data['availability_status'],
      _availability,
    );

    final rating =
        _double(
      data['rating'],
    );

    if (rating > 0) {
      _rating = rating;
    }

    _completedDeliveries =
        _int(
      data['completed_deliveries'],
    );
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final response =
          await SariLiveData.instance
              .riderProfile();

      final data =
          _map(
        response['data'],
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _applyProfile(
          data,
        );

        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });

      // Existing shell profile remains usable
      // if refresh temporarily fails.
    }
  }

  void _resetFields() {
    if (_serverProfile.isNotEmpty) {
      setState(() {
        _applyProfile(
          _serverProfile,
        );

        _editing = false;
      });

      return;
    }

    final profile =
        widget.profile;

    _firstName.text =
        profile.firstName;

    _lastName.text =
        profile.lastName;

    _email.text =
        profile.email;

    _contact.text =
        profile.contactNo;

    _address.text =
        profile.streetAddress;

    _vehicleType.text =
        profile.vehicleType;

    _vehicleModel.text =
        profile.vehicleModel;

    _plate.text =
        profile.plateNumber;

    _license.text =
        profile.licenseNumber;

    setState(() {
      _editing = false;
    });
  }

  bool _validateProfile() {
    if (_firstName.text
            .trim()
            .isEmpty ||
        _lastName.text
            .trim()
            .isEmpty) {
      _message(
        'First name and last name are required.',
      );

      return false;
    }

    final email =
        _email.text.trim();

    if (!email.contains('@') ||
        !email.contains('.')) {
      _message(
        'Enter a valid email address.',
      );

      return false;
    }

    if (_contact.text
        .trim()
        .isEmpty) {
      _message(
        'Contact number is required.',
      );

      return false;
    }

    if (_address.text
        .trim()
        .isEmpty) {
      _message(
        'Street address is required.',
      );

      return false;
    }

    if (_vehicleType.text
        .trim()
        .isEmpty) {
      _message(
        'Vehicle type is required.',
      );

      return false;
    }

    if (_plate.text
        .trim()
        .isEmpty) {
      _message(
        'Plate number is required.',
      );

      return false;
    }

    return true;
  }

  Future<void> _saveProfile() async {
    if (_saving ||
        !_validateProfile()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final response =
          await SariLiveData.instance
              .riderUpdateProfile(
        {
          'first_name':
              _firstName.text
                  .trim(),
          'last_name':
              _lastName.text
                  .trim(),
          'email':
              _email.text
                  .trim()
                  .toLowerCase(),
          'contact_no':
              _contact.text
                  .trim(),
          'street_address':
              _address.text
                  .trim(),
          'vehicle_type':
              _vehicleType.text
                  .trim(),
          'vehicle_model':
              _vehicleModel.text
                  .trim(),
          'plate_number':
              _plate.text
                  .trim()
                  .toUpperCase(),
          'license_number':
              _license.text
                  .trim()
                  .toUpperCase(),
        },
      );

      final data =
          _map(
        response['data'],
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (data.isNotEmpty) {
          _applyProfile(
            data,
          );
        }

        _editing = false;
      });

      _message(
        _text(
          response['message'],
          'Rider profile updated.',
        ),
      );
    } on SariApiException catch (
      error
    ) {
      _message(
        error.message,
      );
    } catch (error) {
      _message(
        'Unable to update profile: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _changeAvailability(
    bool value,
  ) async {
    if (_updatingAvailability) {
      return;
    }

    final next =
        value
            ? 'online'
            : 'offline';

    final previous =
        _availability;

    setState(() {
      _availability = next;
      _updatingAvailability = true;
    });

    try {
      final response =
          await SariLiveData.instance
              .riderAvailability(
        next,
      );

      final data =
          _map(
        response['data'],
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _availability =
            _text(
          data['availability_status'],
          next,
        );
      });

      _message(
        _text(
          response['message'],
          'Rider availability updated.',
        ),
      );
    } on SariApiException catch (
      error
    ) {
      if (mounted) {
        setState(() {
          _availability =
              previous;
        });
      }

      _message(
        error.message,
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _availability =
              previous;
        });
      }

      _message(
        'Unable to update availability.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingAvailability =
              false;
        });
      }
    }
  }

  bool _passwordHasUppercase(
    String value,
  ) {
    return RegExp(
      r'[A-Z]',
    ).hasMatch(
      value,
    );
  }

  bool _passwordHasLowercase(
    String value,
  ) {
    return RegExp(
      r'[a-z]',
    ).hasMatch(
      value,
    );
  }

  bool _passwordHasNumber(
    String value,
  ) {
    return RegExp(
      r'[0-9]',
    ).hasMatch(
      value,
    );
  }

  bool _passwordHasSymbol(
    String value,
  ) {
    return RegExp(
      r'[^A-Za-z0-9]',
    ).hasMatch(
      value,
    );
  }

  bool _validatePassword() {
    final current =
        _currentPassword.text;

    final password =
        _newPassword.text;

    final confirmation =
        _confirmPassword.text;

    if (current.isEmpty ||
        password.isEmpty ||
        confirmation.isEmpty) {
      _message(
        'Complete all password fields.',
      );

      return false;
    }

    if (password.length < 8) {
      _message(
        'New password must contain at least 8 characters.',
      );

      return false;
    }

    if (!_passwordHasUppercase(
          password,
        ) ||
        !_passwordHasLowercase(
          password,
        )) {
      _message(
        'New password must contain uppercase and lowercase letters.',
      );

      return false;
    }

    if (!_passwordHasNumber(
      password,
    )) {
      _message(
        'New password must contain at least one number.',
      );

      return false;
    }

    if (!_passwordHasSymbol(
      password,
    )) {
      _message(
        'New password must contain at least one symbol.',
      );

      return false;
    }

    if (password !=
        confirmation) {
      _message(
        'New password and confirmation do not match.',
      );

      return false;
    }

    return true;
  }

  Future<void> _updatePassword()
      async {
    if (_updatingPassword ||
        !_validatePassword()) {
      return;
    }

    setState(() {
      _updatingPassword = true;
    });

    try {
      final response =
          await SariLiveData.instance
              .riderUpdatePassword(
        currentPassword:
            _currentPassword.text,
        password:
            _newPassword.text,
        confirmation:
            _confirmPassword.text,
      );

      _currentPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();

      if (!mounted) {
        return;
      }

      _message(
        _text(
          response['message'],
          'Password updated successfully.',
        ),
      );
    } on SariApiException catch (
      error
    ) {
      _message(
        error.message,
      );
    } catch (_) {
      _message(
        'Unable to update password.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingPassword = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    if (_loggingOut) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title:
              const Text(
            'Log Out',
          ),
          content:
              const Text(
            'Are you sure you want to sign out of your SARI Rider account?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(
                false,
              ),
              child:
                  const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(
                true,
              ),
              child:
                  const Text(
                'Log Out',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    setState(() {
      _loggingOut = true;
    });

    try {
      await SariLiveData.instance
          .logout();

      await _storage.delete(
        key: _tokenKey,
      );

      await _storage.delete(
        key: _roleKey,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context)
          .pushNamedAndRemoveUntil(
        '/login',
        (
          route,
        ) =>
            false,
      );
    } on SariApiException catch (
      error
    ) {
      _message(
        'Logout failed: ${error.message}. '
        'Your local session was retained.',
      );
    } catch (_) {
      _message(
        'Unable to complete logout. '
        'Please check your connection and try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loggingOut = false;
        });
      }
    }
  }

  String get _fullName {
    final name =
        '${_firstName.text.trim()} '
        '${_lastName.text.trim()}'
            .trim();

    return name.isEmpty
        ? widget.profile.fullName
        : name;
  }

  String get _locationLabel {
    return [
      _barangay,
      _municipality,
      _province,
    ]
        .where(
          (value) =>
              value.trim().isNotEmpty,
        )
        .join(
          ', ',
        );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading:
            false,
        backgroundColor:
            RiderColors.surface,
        foregroundColor:
            RiderColors.text,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title:
            const RiderHeaderTitle(
          title:
              'Account Management',
          subtitle:
              'Rider Profile & Settings',
        ),
        actions: [
          if (_loading)
            const Padding(
              padding:
                  EdgeInsets.only(
                right: 7,
              ),
              child: Center(
                child: SizedBox(
                  width: 19,
                  height: 19,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            IconButton(
              tooltip:
                  'Refresh profile',
              onPressed:
                  _loadProfile,
              icon:
                  const Icon(
                Icons.refresh_rounded,
              ),
            ),

          IconButton(
            tooltip:
                _editing
                    ? 'Cancel editing'
                    : 'Edit profile',
            onPressed:
                _saving
                    ? null
                    : () {
                        if (_editing) {
                          _resetFields();
                        } else {
                          setState(() {
                            _editing = true;
                          });
                        }
                      },
            icon: Icon(
              _editing
                  ? Icons.close_rounded
                  : Icons.edit_outlined,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color:
            RiderColors.gold,
        onRefresh:
            _loadProfile,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            36,
          ),
          children: [
            _hero(),

            const SizedBox(
              height: 18,
            ),

            _availabilityCard(),

            const SizedBox(
              height: 12,
            ),

            _appearanceCard(),

            const SizedBox(
              height: 24,
            ),

            _sectionTitle(
              'Personal Information',
              'Your registered SARI Rider account details.',
            ),

            const SizedBox(
              height: 12,
            ),

            _sectionCard(
              icon: Icons
                  .person_outline_rounded,
              title:
                  'Personal Details',
              children: [
                _field(
                  'First Name',
                  _firstName,
                ),
                _field(
                  'Last Name',
                  _lastName,
                ),
                _field(
                  'Email Address',
                  _email,
                  keyboardType:
                      TextInputType
                          .emailAddress,
                ),
                _field(
                  'Contact Number',
                  _contact,
                  keyboardType:
                      TextInputType.phone,
                ),
                _field(
                  'Street Address',
                  _address,
                  maxLines: 2,
                ),
              ],
            ),

            if (_locationLabel
                .isNotEmpty) ...[
              const SizedBox(
                height: 12,
              ),

              _registeredLocation(),
            ],

            const SizedBox(
              height: 22,
            ),

            _sectionTitle(
              'Vehicle Information',
              'Registered delivery vehicle and license details.',
            ),

            const SizedBox(
              height: 12,
            ),

            _sectionCard(
              icon: Icons
                  .two_wheeler_rounded,
              title:
                  'Vehicle & License',
              children: [
                _field(
                  'Vehicle Type',
                  _vehicleType,
                ),
                _field(
                  'Vehicle Model',
                  _vehicleModel,
                ),
                _field(
                  'Plate Number',
                  _plate,
                ),
                _field(
                  'License Number',
                  _license,
                ),

                if (_licenseExpiry
                    .isNotEmpty)
                  _readOnlyInfo(
                    icon: Icons
                        .event_outlined,
                    label:
                        'License Expiry',
                    value:
                        _licenseExpiry,
                  ),
              ],
            ),

            if (_editing) ...[
              const SizedBox(
                height: 13,
              ),

              _notice(
                'Saving updates your authenticated Laravel Rider account.',
              ),

              const SizedBox(
                height: 12,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton(
                      onPressed:
                          _saving
                              ? null
                              : _resetFields,
                      child:
                          const Text(
                        'Cancel',
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child:
                        FilledButton.icon(
                      onPressed:
                          _saving
                              ? null
                              : _saveProfile,
                      icon:
                          _saving
                              ? const SizedBox(
                                  width:
                                      17,
                                  height:
                                      17,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .save_outlined,
                                  size:
                                      18,
                                ),
                      label:
                          Text(
                        _saving
                            ? 'Saving...'
                            : 'Save Changes',
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(
              height: 26,
            ),

            _sectionTitle(
              'Security',
              'Change your Rider account password.',
            ),

            const SizedBox(
              height: 12,
            ),

            _passwordCard(),

            const SizedBox(
              height: 26,
            ),

            _sectionTitle(
              'Account Session',
              'Manage your authenticated mobile session.',
            ),

            const SizedBox(
              height: 12,
            ),

            _sessionCard(),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding:
          const EdgeInsets.all(
        21,
      ),
      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          colors:
              RiderColors.heroGradient,
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(
          23,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'RIDER ACCOUNT',
            style: TextStyle(
              color:
                  Colors.white70,
              fontSize: 10,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          Row(
            children: [
              _avatar(),

              const SizedBox(
                width: 15,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fullName,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      _email.text
                              .trim()
                              .isEmpty
                          ? 'SARI Rider'
                          : _email.text
                              .trim(),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color:
                            Colors.white70,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(
                      height: 9,
                    ),

                    Text(
                      [
                        _vehicleType.text
                            .trim(),
                        _plate.text
                            .trim(),
                      ]
                          .where(
                            (value) =>
                                value
                                    .isNotEmpty,
                          )
                          .join(
                            ' • ',
                          ),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 22,
          ),

          Row(
            children: [
              _heroStat(
                Icons.star_rounded,
                _rating.toStringAsFixed(
                  1,
                ),
                'Rating',
              ),

              const SizedBox(
                width: 10,
              ),

              _heroStat(
                Icons
                    .check_circle_outline_rounded,
                '$_completedDeliveries',
                'Completed',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    return Container(
      height: 72,
      width: 72,
      clipBehavior:
          Clip.antiAlias,
      decoration:
          BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: .15,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color:
              Colors.white38,
          width: 2,
        ),
      ),
      child:
          _profileImageUrl
                  .isNotEmpty
              ? Image.network(
                  _profileImageUrl,
                  fit:
                      BoxFit.cover,
                  errorBuilder:
                      (
                    context,
                    error,
                    stackTrace,
                  ) =>
                          const Icon(
                    Icons.person_rounded,
                    color:
                        Colors.white,
                    size: 40,
                  ),
                )
              : const Icon(
                  Icons.person_rounded,
                  color:
                      Colors.white,
                  size: 40,
                ),
    );
  }

  Widget _heroStat(
    IconData icon,
    String value,
    String label,
  ) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.all(
          13,
        ),
        decoration:
            BoxDecoration(
          color:
              Colors.white.withValues(
            alpha: .12,
          ),
          borderRadius:
              BorderRadius.circular(
            13,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  Colors.white,
              size: 21,
            ),

            const SizedBox(
              width: 9,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  Text(
                    label,
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _availabilityCard() {
    final online =
        _availability == 'online';

    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration:
                BoxDecoration(
              color: online
                  ? RiderColors
                      .greenSoft
                  : RiderColors
                      .redSoft,
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              online
                  ? Icons.wifi_rounded
                  : Icons
                      .wifi_off_rounded,
              color: online
                  ? RiderColors.green
                  : RiderColors.red,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Rider Availability',
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  online
                      ? 'Currently Online'
                      : 'Currently Offline',
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          if (_updatingAvailability)
            const SizedBox(
              width: 25,
              height: 25,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          else
            Switch.adaptive(
              value: online,
              activeTrackColor:
                  RiderColors.green,
              onChanged:
                  _changeAvailability,
            ),
        ],
      ),
    );
  }

  Widget _appearanceCard() {
    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color:
                  RiderColors.blueSoft,
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              widget.isDarkMode
                  ? Icons
                      .dark_mode_rounded
                  : Icons
                      .light_mode_rounded,
              color:
                  RiderColors.blue,
              size: 25,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  widget.isDarkMode
                      ? 'Dark Mode'
                      : 'Light Mode',
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value:
                widget.isDarkMode,
            activeTrackColor:
                RiderColors.blue,
            onChanged:
                widget
                    .onDarkModeChanged,
          ),
        ],
      ),
    );
  }

  Widget _registeredLocation() {
    return Container(
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          _cardDecoration(),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color:
                  RiderColors.blueSoft,
              borderRadius:
                  BorderRadius.circular(
                11,
              ),
            ),
            child: Icon(
              Icons
                  .location_on_outlined,
              color:
                  RiderColors.blue,
              size: 20,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Registered Service Area',
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  _locationLabel,
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 9.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              TextStyle(
            color:
                RiderColors.text,
            fontSize: 17,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        Text(
          subtitle,
          style:
              TextStyle(
            color:
                RiderColors.muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        17,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color:
                    RiderColors.blue,
                size: 23,
              ),

              const SizedBox(
                width: 10,
              ),

              Text(
                title,
                style:
                    TextStyle(
                  color:
                      RiderColors.text,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 19,
          ),

          ...children,
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 13,
      ),
      child: TextField(
        controller:
            controller,
        enabled:
            _editing,
        keyboardType:
            keyboardType,
        maxLines:
            maxLines,
        style:
            TextStyle(
          color:
              RiderColors.text,
          fontSize: 13,
        ),
        decoration:
            InputDecoration(
          labelText:
              label,
          labelStyle:
              TextStyle(
            color:
                RiderColors.muted,
            fontSize: 12,
          ),
          filled: true,
          fillColor:
              _editing
                  ? RiderColors.field
                  : RiderColors
                      .surfaceSoft,
          disabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              13,
            ),
            borderSide:
                BorderSide(
              color:
                  RiderColors.border,
            ),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              13,
            ),
            borderSide:
                BorderSide(
              color:
                  RiderColors.border,
            ),
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              13,
            ),
            borderSide:
                BorderSide(
              color:
                  RiderColors.blue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _readOnlyInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 4,
      ),
      padding:
          const EdgeInsets.all(
        12,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.surfaceSoft,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                RiderColors.blue,
            size: 19,
          ),

          const SizedBox(
            width: 9,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 8,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  value,
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordCard() {
    final password =
        _newPassword.text;

    return Container(
      padding:
          const EdgeInsets.all(
        17,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _passwordField(
            'Current Password',
            _currentPassword,
            _showCurrentPassword,
            () {
              setState(() {
                _showCurrentPassword =
                    !_showCurrentPassword;
              });
            },
          ),

          _passwordField(
            'New Password',
            _newPassword,
            _showNewPassword,
            () {
              setState(() {
                _showNewPassword =
                    !_showNewPassword;
              });
            },
            onChanged: (_) {
              setState(() {});
            },
          ),

          _passwordField(
            'Confirm New Password',
            _confirmPassword,
            _showConfirmPassword,
            () {
              setState(() {
                _showConfirmPassword =
                    !_showConfirmPassword;
              });
            },
          ),

          const SizedBox(
            height: 3,
          ),

          _passwordRule(
            'At least 8 characters',
            password.length >= 8,
          ),

          _passwordRule(
            'Uppercase and lowercase letters',
            _passwordHasUppercase(
                  password,
                ) &&
                _passwordHasLowercase(
                  password,
                ),
          ),

          _passwordRule(
            'At least one number',
            _passwordHasNumber(
              password,
            ),
          ),

          _passwordRule(
            'At least one symbol',
            _passwordHasSymbol(
              password,
            ),
          ),

          _passwordRule(
            'Passwords match',
            password.isNotEmpty &&
                password ==
                    _confirmPassword
                        .text,
          ),

          const SizedBox(
            height: 14,
          ),

          SizedBox(
            width:
                double.infinity,
            child:
                FilledButton.icon(
              onPressed:
                  _updatingPassword
                      ? null
                      : _updatePassword,
              icon:
                  _updatingPassword
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )
                      : const Icon(
                          Icons
                              .lock_outline_rounded,
                        ),
              label:
                  Text(
                _updatingPassword
                    ? 'Updating...'
                    : 'Update Password',
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            'Password changes are saved through the authenticated Laravel Rider API.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 9.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController controller,
    bool visible,
    VoidCallback toggle, {
    ValueChanged<String>?
        onChanged,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 13,
      ),
      child: TextField(
        controller:
            controller,
        obscureText:
            !visible,
        enableSuggestions:
            false,
        autocorrect:
            false,
        onChanged:
            onChanged,
        style:
            TextStyle(
          color:
              RiderColors.text,
          fontSize: 13,
        ),
        decoration:
            InputDecoration(
          labelText:
              label,
          prefixIcon:
              const Icon(
            Icons.lock_outline,
          ),
          suffixIcon:
              IconButton(
            onPressed:
                toggle,
            icon: Icon(
              visible
                  ? Icons
                      .visibility_off_outlined
                  : Icons
                      .visibility_outlined,
            ),
          ),
          filled: true,
          fillColor:
              RiderColors.field,
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordRule(
    String label,
    bool valid,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 5,
      ),
      child: Row(
        children: [
          Icon(
            valid
                ? Icons
                    .check_circle_rounded
                : Icons
                    .radio_button_unchecked_rounded,
            color: valid
                ? RiderColors.green
                : RiderColors.muted,
            size: 15,
          ),

          const SizedBox(
            width: 7,
          ),

          Expanded(
            child: Text(
              label,
              style:
                  TextStyle(
                color: valid
                    ? RiderColors.green
                    : RiderColors.muted,
                fontSize: 8.5,
                fontWeight: valid
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionCard() {
    return Container(
      padding:
          const EdgeInsets.all(
        17,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 41,
                height: 41,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      RiderColors.greenSoft,
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
                child: Icon(
                  Icons
                      .verified_user_outlined,
                  color:
                      RiderColors.green,
                  size: 22,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Signed In',
                      style:
                          TextStyle(
                        color:
                            RiderColors.text,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      'Authenticated SARI Rider mobile session',
                      style:
                          TextStyle(
                        color:
                            RiderColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 17,
          ),

          SizedBox(
            width:
                double.infinity,
            child:
                OutlinedButton.icon(
              onPressed:
                  _loggingOut
                      ? null
                      : _logout,
              icon:
                  _loggingOut
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )
                      : const Icon(
                          Icons
                              .logout_rounded,
                        ),
              label:
                  Text(
                _loggingOut
                    ? 'Signing Out...'
                    : 'Log Out',
              ),
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    RiderColors.red,
                side:
                    BorderSide(
                  color:
                      RiderColors.red
                          .withValues(
                    alpha: .5,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notice(
    String message,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        13,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.goldSoft,
        borderRadius:
            BorderRadius.circular(
          13,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .info_outline_rounded,
            color:
                RiderColors.goldDark,
            size: 19,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              message,
              style:
                  TextStyle(
                color:
                    RiderColors.text,
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color:
          RiderColors.surface,
      borderRadius:
          BorderRadius.circular(
        19,
      ),
      border:
          Border.all(
        color:
            RiderColors.border,
      ),
    );
  }
}