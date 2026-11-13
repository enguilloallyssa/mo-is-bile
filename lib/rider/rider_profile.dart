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
    this.section = 'overview',
    this.onTabChanged,
    this.onHistory,
    this.onPickups,
  });

  final RiderProfile profile;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final String section;
  final ValueChanged<int>? onTabChanged;
  final VoidCallback? onHistory;
  final VoidCallback? onPickups;

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
  late bool _appearanceDarkMode;

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
    _appearanceDarkMode = widget.isDarkMode;

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

  // Responsive Rider shortcuts. All callbacks are routed through RiderShell.
  Widget _accountQuickActions() {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(23),
          child: InkWell(
            onTap: () => widget.onTabChanged?.call(1),
            borderRadius: BorderRadius.circular(23),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: RiderColors.isDark
                      ? [const Color(0xFF42321B), const Color(0xFF332A21)]
                      : [const Color(0xFFFFEBC5), const Color(0xFFFFF7EA)],
                ),
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: RiderColors.gold.withValues(alpha: .23)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 15, 18),
                child: Row(
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        color: RiderColors.isDark
                            ? RiderColors.gold.withValues(alpha: .20)
                            : const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(Icons.assignment_turned_in_outlined,
                          size: 27, color: RiderColors.goldDark),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MY WORKSPACE', style: TextStyle(
                            color: RiderColors.goldDark, fontSize: 9,
                            fontWeight: FontWeight.w900, letterSpacing: 1.5,
                          )),
                          const SizedBox(height: 5),
                          Text('My assigned jobs', style: TextStyle(
                            color: RiderColors.text, fontSize: 17,
                            fontWeight: FontWeight.w900, letterSpacing: -.35,
                          )),
                          const SizedBox(height: 3),
                          Text('Check tasks and your next stop',
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: RiderColors.muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded,
                        size: 20, color: RiderColors.goldDark),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _quickActionTile(
                icon: Icons.inventory_2_outlined,
                title: 'Pickups', subtitle: 'Seller collections',
                accent: RiderColors.goldDark,
                soft: RiderColors.goldSoft,
                onTap: widget.onPickups,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionTile(
                icon: Icons.local_shipping_outlined,
                title: 'Deliveries', subtitle: 'On the road',
                accent: RiderColors.blue,
                soft: RiderColors.blueSoft,
                onTap: () => widget.onTabChanged?.call(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required Color soft,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: RiderColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: RiderColors.border),
            boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: .035),
              blurRadius: 18, offset: const Offset(0, 6),
            )],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 45, width: 45,
                    decoration: BoxDecoration(
                      color: soft, borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icon, color: accent, size: 24),
                  ),
                  Icon(Icons.north_east_rounded, color: RiderColors.muted, size: 17),
                ],
              ),
              const SizedBox(height: 17),
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: RiderColors.text,
                  fontSize: 15, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: RiderColors.muted,
                  fontSize: 10.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountOverviewCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(children: [
        _accountInfoRow(
          icon: Icons.location_on_outlined,
          title: 'Registered address',
          value: _locationLabel.isNotEmpty
              ? _locationLabel
              : _address.text.trim().isNotEmpty
                  ? _address.text.trim() : 'Add your location details',
          accent: RiderColors.purple,
          soft: RiderColors.purpleSoft,
          onTap: () => _openAccountSection('personal'),
        ),
        Divider(height: 1, indent: 67, color: RiderColors.border),
        _accountInfoRow(
          icon: Icons.two_wheeler_rounded,
          title: 'Registered vehicle',
          value: [_vehicleType.text.trim(), _vehicleModel.text.trim()]
              .where((part) => part.isNotEmpty).join(' · ').isNotEmpty
              ? [_vehicleType.text.trim(), _vehicleModel.text.trim()]
                  .where((part) => part.isNotEmpty).join(' · ')
              : 'Add your vehicle details',
          accent: RiderColors.goldDark,
          soft: RiderColors.goldSoft,
          onTap: () => _openAccountSection('vehicle'),
        ),
        Divider(height: 1, indent: 67, color: RiderColors.border),
        _accountInfoRow(
          icon: Icons.tune_rounded,
          title: 'Account & preferences',
          value: 'Security, appearance and session',
          accent: RiderColors.blue,
          soft: RiderColors.blueSoft,
          onTap: () => _openAccountSection('settings'),
        ),
      ]),
    );
  }

  Widget _accountInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color accent,
    required Color soft,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          child: Row(children: [
            Container(
              height: 41, width: 41,
              decoration: BoxDecoration(
                  color: soft, borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, color: accent, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: RiderColors.text,
                  fontWeight: FontWeight.w800, fontSize: 12.5)),
                const SizedBox(height: 4),
                Text(value, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: RiderColors.muted,
                    fontSize: 10.5, height: 1.2)),
              ],
            )),
            Icon(Icons.chevron_right_rounded, color: RiderColors.muted, size: 21),
          ]),
        ),
      ),
    );
  }

  Future<void> _openAccountSection(String section) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RiderProfilePage(
          profile: widget.profile,
          isDarkMode: widget.isDarkMode,
          onDarkModeChanged: widget.onDarkModeChanged,
          section: section,
          onHistory: widget.onHistory,
          onPickups: widget.onPickups,
          onTabChanged: widget.onTabChanged,
        ),
      ),
    );
    if (mounted) await _loadProfile();
  }

  Widget _settingsItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final accent = isDestructive ? RiderColors.red : RiderColors.goldDark;
    return Material(
      color: RiderColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(children: [
            Container(
              width: 43, height: 43,
              decoration: BoxDecoration(
                color: isDestructive ? RiderColors.redSoft : RiderColors.goldSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent, size: 21),
            ),
            const SizedBox(width: 13),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDestructive ? RiderColors.red : RiderColors.text,
                    fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: RiderColors.muted, fontSize: 11.5)),
              ],
            )),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: RiderColors.muted, size: 20),
          ]),
        ),
      ),
    );
  }


  Widget _settingsOverview() {
    Widget sectionLabel(String label) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 0, 11),
      child: Text(label, style: TextStyle(
        color: RiderColors.muted, fontSize: 11, letterSpacing: 1.1,
        fontWeight: FontWeight.w800,
      )),
    );
    Widget section(List<Widget> children) => Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: RiderColors.border),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: .03),
          blurRadius: 16, offset: const Offset(0, 5),
        )],
      ),
      child: Column(children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) Divider(height: 1, thickness: 1, indent: 72,
              endIndent: 14, color: RiderColors.border),
          children[i],
        ],
      ]),
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: RiderColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: RiderColors.border),
        ),
        child: Row(children: [
          Container(width: 52, height: 52,
            decoration: BoxDecoration(color: RiderColors.goldSoft,
              borderRadius: BorderRadius.circular(15)),
            alignment: Alignment.center,
            child: Text('S', style: TextStyle(color: RiderColors.goldDark,
              fontSize: 29, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SARI Settings', style: TextStyle(color: RiderColors.text,
                fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Your account, your preferences.', style: TextStyle(
                color: RiderColors.muted, fontSize: 12)),
          ])),
        ]),
      ),
      sectionLabel('ACCOUNT INFORMATION'),
      section([
        _settingsItem(title: 'Personal Information',
          subtitle: 'Name, email, address and contact',
          icon: Icons.person_outline_rounded,
          onTap: () => _openAccountSection('personal')),
        _settingsItem(title: 'Vehicle Information',
          subtitle: 'Vehicle and license details',
          icon: Icons.two_wheeler_rounded,
          onTap: () => _openAccountSection('vehicle')),
      ]),
      sectionLabel('PREFERENCES & SECURITY'),
      section([
        _settingsItem(title: 'Appearance',
          subtitle: _appearanceDarkMode ? 'Dark mode' : 'Light mode',
          icon: _appearanceDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          onTap: () => _openAccountSection('appearance')),
        _settingsItem(title: 'Security',
          subtitle: 'Change your password',
          icon: Icons.shield_outlined,
          onTap: () => _openAccountSection('security')),
      ]),
      sectionLabel('SESSION'),
      section([
        _settingsItem(title: _loggingOut ? 'Signing out...' : 'Log Out',
          subtitle: 'End your SARI Rider session',
          icon: Icons.logout_rounded, isDestructive: true,
          onTap: _loggingOut ? () {} : _logout),
      ]),
    ]);
  }


  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          RiderColors.bg,
      appBar: widget.section == 'overview' ? null : AppBar(
        automaticallyImplyLeading: false,
        leading: widget.section == 'overview' ? null : IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: RiderColors.surface,
        foregroundColor: RiderColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: RiderHeaderTitle(
          title: widget.section == 'overview' ? 'Rider Profile'
              : widget.section == 'settings' ? 'Settings'
              : widget.section == 'personal' ? 'Personal Information'
              : widget.section == 'vehicle' ? 'Vehicle Information'
              : widget.section == 'appearance' ? 'Appearance' : 'Security',
          subtitle: widget.section == 'overview' ? 'Your SARI Rider Account' : 'SARI Rider Account',
        ),
        actions: [
          if ((widget.section == 'personal' || widget.section == 'vehicle'))
            IconButton(
              tooltip: _editing ? 'Cancel editing' : 'Edit profile',
              onPressed: _saving ? null : () {
                if (_editing) { _resetFields(); }
                else { setState(() { _editing = true; }); }
              },
              icon: Icon(_editing ? Icons.close_rounded : Icons.edit_outlined),
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
          padding: widget.section == 'overview'
              ? const EdgeInsets.only(bottom: 36)
              : const EdgeInsets.fromLTRB(16, 18, 16, 36),
          children: [
            if (widget.section == 'overview') ...[
              _hero(),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Quick Actions',
                        'Everything you need for your next delivery.'),
                    const SizedBox(height: 13),
                    _accountQuickActions(),
                    const SizedBox(height: 26),
                    _sectionTitle('Account essentials',
                        'Keep your Rider details up to date.'),
                    const SizedBox(height: 12),
                    _accountOverviewCard(),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ],
            if (widget.section == 'settings') _settingsOverview(),
            if (widget.section == 'appearance') _appearanceCard(),
            if (widget.section == 'personal') ...[
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

            ],
            if (widget.section == 'vehicle') ...[
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

            ],
            if (widget.section == 'personal' || widget.section == 'vehicle') ...[
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

            ],
            if (widget.section == 'security') ...[
            _sectionTitle(
              'Security',
              'Change your Rider account password.',
            ),

            const SizedBox(
              height: 12,
            ),

            _passwordCard(),

            ],
          ],
        ),
      ),
    );
  }

  // SARI Rider account overview. Uses existing profile fields, actions and APIs.
  // Badges with server-specific claims are displayed only when provided by API.
  Widget _hero() {
    final online = <String>{'online', 'available', 'active'}
        .contains(_availability.trim().toLowerCase());
    final dark = RiderColors.isDark;
    final ink = RiderColors.text;
    final muted = RiderColors.muted;
    const gold = Color(0xFFBF8318);
    const darkCard = Color(0xFF131713);

    final rawCode = _text(_serverProfile['rider_code'],
        _text(_serverProfile['rider_number']));
    final accountId = _int(_serverProfile['id']);
    final riderCode = rawCode.isNotEmpty
        ? rawCode
        : accountId > 0
            ? 'SR-${accountId.toString().padLeft(4, '0')}'
            : '';
    final verification = _text(_serverProfile['verification_status'])
        .toLowerCase();
    final isVerified = _serverProfile['is_verified'] == true ||
        _serverProfile['verified'] == true ||
        verification == 'verified';
    final tier = _text(_serverProfile['tier_name'],
        _text(_serverProfile['rider_tier']));
    final hub = _text(_serverProfile['hub_name'],
        _text(_serverProfile['facility_name'],
            _text(_serverProfile['logistics_hub_name'])));
    final location = _locationLabel;
    final vehicle = <String>[
      _vehicleType.text.trim(),
      _plate.text.trim(),
    ].where((value) => value.isNotEmpty).join(' · ');

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 9, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Keep account actions outside the identity card.
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('SARI',
                            style: TextStyle(
                              color: gold,
                              fontSize: 19,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.6,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 4),
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(0xFF4B3A22)
                                  : const Color(0xFFF6EAD4),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text('RIDER DISPATCH',
                              style: TextStyle(
                                fontSize: 8,
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w800,
                                color: gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Rider Profile',
                        style: TextStyle(
                          color: ink,
                          fontSize: 21,
                          height: 1.07,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.6,
                        ),
                      ),
                    ],
                  ),
                ),
                _accountIcon(Icons.history_rounded,
                    'Delivery history', widget.onHistory),
                const SizedBox(width: 6),
                _accountIcon(Icons.settings_outlined,
                    'Settings', () => _openAccountSection('settings')),
                const SizedBox(width: 6),
                _accountIcon(Icons.menu_rounded,
                    'Rider menu', RiderMenuController.open),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark
                      ? const [Color(0xFF2C2A25), Color(0xFF23221F)]
                      : const [Color(0xFFFFFEFA), Color(0xFFF7F0DE)],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: dark
                      ? const Color(0xFF494236)
                      : const Color(0xFFE5DAC4),
                ),
                boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? .16 : .06),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                )],
              ),
              child: Stack(
                children: [
                  // Warm gold arcs/dots, decorative only.
                  Positioned(
                    right: -58,
                    top: -76,
                    child: IgnorePointer(
                      child: Container(
                        height: 186,
                        width: 186,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: gold.withValues(alpha: .13),
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 14,
                    top: 50,
                    child: IgnorePointer(
                      child: Icon(Icons.blur_on_rounded,
                        color: gold.withValues(alpha: .08),
                        size: 91,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _dispatchBadge(
                              icon: Icons.two_wheeler_rounded,
                              label: riderCode.isNotEmpty
                                  ? riderCode : 'SARI RIDER',
                              foreground: ink,
                              background: RiderColors.surface
                                  .withValues(alpha: .74),
                            ),
                            if (isVerified)
                              _dispatchBadge(
                                icon: Icons.verified_outlined,
                                label: 'VERIFIED',
                                foreground: const Color(0xFF087C62),
                                background: const Color(0xFFDDF8EB),
                              ),
                            if (tier.isNotEmpty)
                              _dispatchBadge(
                                icon: Icons.workspace_premium_outlined,
                                label: tier.toUpperCase(),
                                foreground: gold,
                                background: gold.withValues(alpha: .10),
                              ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Divider(height: 1,
                          color: RiderColors.border.withValues(alpha: .65)),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _openAccountSection('personal'),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _avatar(),
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: Container(
                                      height: 12,
                                      width: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: online
                                            ? const Color(0xFF18B978)
                                            : const Color(0xFFB7B4AC),
                                        border: Border.all(
                                          color: RiderColors.surface, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_fullName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: ink,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18.5,
                                      height: 1.1,
                                      letterSpacing: -.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _email.text.trim().isNotEmpty
                                        ? _email.text.trim()
                                        : 'SARI Rider account',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: muted, fontSize: 10.5),
                                  ),
                                  if (hub.isNotEmpty || location.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Row(children: [
                                      const Icon(Icons.location_on_outlined,
                                          color: gold, size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(
                                        hub.isNotEmpty ? hub : location,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: gold,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      )),
                                    ]),
                                  ],
                                  if (vehicle.isNotEmpty) ...[
                                    const SizedBox(height: 5),
                                    Row(children: [
                                      Icon(Icons.two_wheeler_outlined,
                                          size: 14, color: muted),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(vehicle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: muted, fontSize: 10),
                                      )),
                                    ]),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 13, horizontal: 4),
                          decoration: BoxDecoration(
                            color: dark
                                ? RiderColors.surface.withValues(alpha: .67)
                                : Colors.white.withValues(alpha: .72),
                            border: Border.all(
                              color: RiderColors.border.withValues(alpha: .67),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _dispatchMetric(
                                label: 'Status',
                                value: online ? 'Online' : 'Offline',
                                detail: online ? 'Available' : 'Not available',
                                valueColor: online
                                    ? const Color(0xFF139565) : muted,
                                icon: online
                                    ? Icons.signal_cellular_alt_rounded
                                    : Icons.signal_cellular_off_rounded,
                              )),
                              Container(width: 1, height: 43,
                                color: RiderColors.border),
                              Expanded(child: _dispatchMetric(
                                label: 'Completed',
                                value: '$_completedDeliveries',
                                detail: 'Total trips',
                                valueColor: ink,
                              )),
                              Container(width: 1, height: 43,
                                color: RiderColors.border),
                              Expanded(child: _dispatchMetric(
                                label: 'Rating',
                                value: _rating.toStringAsFixed(1),
                                detail: 'Rider rating',
                                valueColor: ink,
                                icon: Icons.star_rounded,
                              )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
                          decoration: BoxDecoration(
                            color: darkCard,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: online
                                      ? const Color(0xFF11C78D)
                                      : const Color(0xFF89908C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Available for assignments',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      online
                                          ? 'You are online · Ready for jobs'
                                          : 'You are offline · Enable when ready',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: online
                                            ? const Color(0xFF8DE9BC)
                                            : const Color(0xFFD8D8D1),
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_updatingAvailability)
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    height: 20, width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF12C689),
                                    ),
                                  ),
                                )
                              else
                                Transform.scale(
                                  scale: .89,
                                  child: Switch.adaptive(
                                    value: online,
                                    onChanged: _changeAvailability,
                                    activeTrackColor: const Color(0xFF09A96F),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _dispatchBadge({
    required IconData icon,
    required String label,
    required Color foreground,
    required Color background,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 145),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: foreground.withValues(alpha: .11)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11.5, color: foreground),
        const SizedBox(width: 4),
        Flexible(child: Text(label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foreground,
            fontSize: 8.8,
            fontWeight: FontWeight.w900,
            letterSpacing: .3,
          ),
        )),
      ]),
    );
  }

  Widget _dispatchMetric({
    required String label,
    required String value,
    required String detail,
    required Color valueColor,
    IconData? icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: RiderColors.muted,
            fontWeight: FontWeight.w700,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: valueColor),
              const SizedBox(width: 3),
            ],
            Flexible(child: Text(value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                height: 1,
              ),
            )),
          ],
        ),
        const SizedBox(height: 4),
        Text(detail,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: RiderColors.muted,
            fontSize: 8.5,
          ),
        ),
      ],
    );
  }

  Widget _accountIcon(IconData icon, String tooltip, VoidCallback? onTap) {
    return Container(
      height: 38, width: 38,
      decoration: BoxDecoration(
        color: RiderColors.surface.withValues(alpha: .82),
        shape: BoxShape.circle,
        border: Border.all(color: RiderColors.border.withValues(alpha: .8)),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: RiderColors.text, size: 18),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
      ),
    );
  }

  Widget _avatar() {
    String initials() {
      final first = _firstName.text.trim();
      final last = _lastName.text.trim();
      final result = '${first.isEmpty ? '' : first[0]}'
          '${last.isEmpty ? '' : last[0]}'.toUpperCase();
      return result.isEmpty ? 'SR' : result;
    }

    final fallback = Center(child: Text(initials(), style: TextStyle(
      color: RiderColors.goldDark, fontSize: 26,
      fontWeight: FontWeight.w900, letterSpacing: .5,
    )));
    return Container(
      height: 82, width: 82,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: RiderColors.surface,
        boxShadow: [BoxShadow(
          color: RiderColors.gold.withValues(alpha: .20),
          blurRadius: 14, offset: const Offset(0, 5),
        )],
      ),
      child: ClipOval(child: Container(
        color: RiderColors.goldSoft,
        child: _profileImageUrl.trim().isNotEmpty
          ? Image.network(_profileImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback)
          : fallback,
      )),
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
              _appearanceDarkMode
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
                  _appearanceDarkMode
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
                _appearanceDarkMode,
            activeTrackColor:
                RiderColors.blue,
            onChanged: (value) {
                setState(() => _appearanceDarkMode = value);
                widget.onDarkModeChanged(value);
              },
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
                    fontSize: 11,
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
                    fontSize: 10,
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
              fontSize: 11,
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
                fontSize: 10,
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