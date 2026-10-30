
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import '../services/sari_api.dart';
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
  State<RiderProfilePage> createState() => _RiderProfilePageState();
}

class _RiderProfilePageState extends State<RiderProfilePage> {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'sari_access_token';
  static const _roleKey = 'sari_account_role';

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _contact;
  late final TextEditingController _address;
  late final TextEditingController _vehicleType;
  late final TextEditingController _vehicleModel;
  late final TextEditingController _plate;
  late final TextEditingController _license;

  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _editing = false;
  bool _loggingOut = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  late String _availability;

  @override
  void initState() {
    super.initState();

    final profile = widget.profile;

    _firstName = TextEditingController(text: profile.firstName);
    _lastName = TextEditingController(text: profile.lastName);
    _email = TextEditingController(text: profile.email);
    _contact = TextEditingController(text: profile.contactNo);
    _address = TextEditingController(text: profile.streetAddress);
    _vehicleType = TextEditingController(text: profile.vehicleType);
    _vehicleModel = TextEditingController(text: profile.vehicleModel);
    _plate = TextEditingController(text: profile.plateNumber);
    _license = TextEditingController(text: profile.licenseNumber);

    _availability = profile.availabilityStatus;
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _email,
      _contact,
      _address,
      _vehicleType,
      _vehicleModel,
      _plate,
      _license,
      _currentPassword,
      _newPassword,
      _confirmPassword,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _resetFields() {
    final profile = widget.profile;

    _firstName.text = profile.firstName;
    _lastName.text = profile.lastName;
    _email.text = profile.email;
    _contact.text = profile.contactNo;
    _address.text = profile.streetAddress;
    _vehicleType.text = profile.vehicleType;
    _vehicleModel.text = profile.vehicleModel;
    _plate.text = profile.plateNumber;
    _license.text = profile.licenseNumber;

    setState(() => _editing = false);
  }

  void _saveProfile() {
    _message(
      'Profile changes cannot be saved yet. '
      'The Laravel Rider profile API must be connected.',
    );
  }

  void _changeAvailability(bool value) {
    _message(
      'Rider availability must be updated through '
      'the Laravel Rider API.',
    );
  }

  Future<void> _logout() async {
    if (_loggingOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text(
            'Are you sure you want to sign out '
            'of your SARI Rider account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                false,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                true,
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loggingOut = true);

    final api = SariApi(
      baseUrl: ApiConfig.apiBaseUrl,
      tokenProvider: () => _storage.read(key: _tokenKey),
    );

    try {
      // Revoke the token on the Laravel server.
      await api.logout();

      // Clear local credentials only after success.
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _roleKey);

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } on SariApiException catch (error) {
      _message(
        'Logout failed: ${error.message}. '
        'Your local session was retained.',
      );
    } catch (error) {
      _message(
        'Unable to complete logout. '
        'Please check your connection and try again.',
      );
    } finally {
      api.dispose();

      if (mounted) {
        setState(() => _loggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: RiderColors.surface,
        foregroundColor: RiderColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: const RiderHeaderTitle(
          title: 'Account Management',
          subtitle: 'Rider Profile & Settings',
        ),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () {
              if (_editing) {
                _resetFields();
              } else {
                setState(() => _editing = true);
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16, 18, 16, 36,
        ),
        children: [
          _hero(),
          const SizedBox(height: 18),

          _availabilityCard(),
          const SizedBox(height: 12),

          _appearanceCard(),
          const SizedBox(height: 24),

          _sectionTitle(
            'Personal Information',
            'Your registered rider account details.',
          ),
          const SizedBox(height: 12),

          _sectionCard(
            icon: Icons.person_outline_rounded,
            title: 'Personal Details',
            children: [
              _field('First Name', _firstName),
              _field('Last Name', _lastName),
              _field(
                'Email Address',
                _email,
                keyboardType: TextInputType.emailAddress,
              ),
              _field(
                'Contact Number',
                _contact,
                keyboardType: TextInputType.phone,
              ),
              _field('Home Address', _address),
            ],
          ),

          const SizedBox(height: 22),

          _sectionTitle(
            'Vehicle Information',
            'Registered delivery vehicle details.',
          ),
          const SizedBox(height: 12),

          _sectionCard(
            icon: Icons.two_wheeler_rounded,
            title: 'Vehicle & License',
            children: [
              _field('Vehicle Type', _vehicleType),
              _field('Vehicle Model', _vehicleModel),
              _field('Plate Number', _plate),
              _field('License Number', _license),
            ],
          ),

          if (_editing) ...[
            const SizedBox(height: 14),

            _notice(
              'Profile editing is a preview only. '
              'Changes will not update your Laravel account.',
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFields,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(
                      Icons.save_outlined,
                      size: 18,
                    ),
                    label: const Text('Save'),
                    style: FilledButton.styleFrom(
                      backgroundColor: RiderColors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 25),

          _sectionTitle(
            'Change Password',
            'Manage the security of your rider account.',
          ),
          const SizedBox(height: 12),

          _passwordCard(),

          const SizedBox(height: 25),

          _sectionTitle(
            'Account & Session',
            'Manage your SARI Rider access.',
          ),
          const SizedBox(height: 12),

          _sessionCard(),

          const SizedBox(height: 20),

          _notice(
            'The profile details currently come from '
            'the Flutter Rider model. Live account '
            'updates, availability changes, and password '
            'changes require authenticated Laravel API support.',
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: RiderColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RIDER ACCOUNT',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white38,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.profile.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.profile.email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      '${widget.profile.vehicleType} • '
                      '${widget.profile.plateNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              _heroStat(
                Icons.star_rounded,
                widget.profile.rating.toStringAsFixed(1),
                'Rating',
              ),
              const SizedBox(width: 10),
              _heroStat(
                Icons.check_circle_outline_rounded,
                '${widget.profile.completedDeliveries}',
                'Completed',
              ),
            ],
          ),
        ],
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
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 21),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
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
    final online = _availability == 'online';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: online
                  ? RiderColors.greenSoft
                  : RiderColors.redSoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              online
                  ? Icons.wifi_rounded
                  : Icons.wifi_off_rounded,
              color: online
                  ? RiderColors.green
                  : RiderColors.red,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rider Availability',
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  online ? 'Currently Online' : 'Currently Offline',
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value: online,
            activeTrackColor: RiderColors.green,
            onChanged: _changeAvailability,
          ),
        ],
      ),
    );
  }

  Widget _appearanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(
            widget.isDarkMode
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            color: RiderColors.blue,
            size: 27,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isDarkMode
                      ? 'Dark Mode'
                      : 'Light Mode',
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value: widget.isDarkMode,
            activeTrackColor: RiderColors.blue,
            onChanged: widget.onDarkModeChanged,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: RiderColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: RiderColors.muted,
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
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: RiderColors.blue,
                size: 23,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: RiderColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 19),
          ...children,
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextField(
        controller: controller,
        enabled: _editing,
        keyboardType: keyboardType,
        style: TextStyle(
          color: RiderColors.text,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: RiderColors.muted,
            fontSize: 12,
          ),
          filled: true,
          fillColor: _editing
              ? RiderColors.field
              : RiderColors.surfaceSoft,
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(
              color: RiderColors.border,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(
              color: RiderColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(
              color: RiderColors.blue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _passwordField(
            'Current Password',
            _currentPassword,
            _showCurrentPassword,
            () {
              setState(() {
                _showCurrentPassword = !_showCurrentPassword;
              });
            },
          ),

          _passwordField(
            'New Password',
            _newPassword,
            _showNewPassword,
            () {
              setState(() {
                _showNewPassword = !_showNewPassword;
              });
            },
          ),

          _passwordField(
            'Confirm New Password',
            _confirmPassword,
            _showConfirmPassword,
            () {
              setState(() {
                _showConfirmPassword = !_showConfirmPassword;
              });
            },
          ),

          const SizedBox(height: 9),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.lock_outline_rounded),
              label: const Text('Update Password'),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Password changes are disabled until '
            'the authenticated Laravel Rider account API '
            'is connected.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 10,
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
    VoidCallback toggle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextField(
        controller: controller,
        obscureText: !visible,
        enableSuggestions: false,
        autocorrect: false,
        style: TextStyle(
          color: RiderColors.text,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            onPressed: toggle,
            icon: Icon(
              visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
          filled: true,
          fillColor: RiderColors.field,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  Widget _sessionCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: RiderColors.green,
                size: 23,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Signed In',
                      style: TextStyle(
                        color: RiderColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'SARI Rider mobile session',
                      style: TextStyle(
                        color: RiderColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _loggingOut ? null : _logout,
              icon: _loggingOut
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.logout_rounded),
              label: Text(
                _loggingOut ? 'Signing Out...' : 'Log Out',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: RiderColors.red,
                side: BorderSide(
                  color: RiderColors.red.withValues(alpha: .5),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notice(String message) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RiderColors.goldSoft,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: RiderColors.goldDark,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 11,
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
      color: RiderColors.surface,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(
        color: RiderColors.border,
      ),
    );
  }
}
