import 'package:flutter/material.dart';

import 'models/rider_profile_model.dart';
import 'widgets/rider_ui.dart';

class RiderProfilePage extends StatefulWidget {
  final RiderProfile profile;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  RiderProfilePage({
    super.key,
    required this.profile,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  @override
  State<RiderProfilePage> createState() => _RiderProfilePageState();
}

class _RiderProfilePageState extends State<RiderProfilePage> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _contact;
  late final TextEditingController _street;
  late final TextEditingController _vehicleType;
  late final TextEditingController _vehicleModel;
  late final TextEditingController _plate;
  late final TextEditingController _license;
  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirmation = TextEditingController();
  final TextEditingController _complaint = TextEditingController();

  late String _availability;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _firstName = TextEditingController(text: profile.firstName);
    _lastName = TextEditingController(text: profile.lastName);
    _email = TextEditingController(text: profile.email);
    _contact = TextEditingController(text: profile.contactNo);
    _street = TextEditingController(text: profile.streetAddress);
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
      _street,
      _vehicleType,
      _vehicleModel,
      _plate,
      _license,
      _currentPassword,
      _password,
      _passwordConfirmation,
      _complaint,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 74,
        titleSpacing: 16,
        title: RiderHeaderTitle(
          title: 'My Rider Profile',
          subtitle: 'Account, vehicle and preferences',
        ),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _editing = !_editing),
            icon: Icon(_editing ? Icons.close_rounded : Icons.edit_outlined),
            label: Text(_editing ? 'Cancel' : 'Edit'),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(14, 10, 14, 26),
        children: [
          _profileHero(),
          SizedBox(height: 12),
          _availabilityCard(),
          SizedBox(height: 12),
          _appearanceCard(),
          SizedBox(height: 18),
          _section(
            title: 'Personal information',
            icon: Icons.badge_outlined,
            children: [
              _field('First name', _firstName),
              _field('Last name', _lastName),
              _field(
                'Email',
                _email,
                keyboardType: TextInputType.emailAddress,
              ),
              _field(
                'Contact number',
                _contact,
                keyboardType: TextInputType.phone,
              ),
              _field('Home address', _street),
            ],
          ),
          SizedBox(height: 12),
          _section(
            title: 'Vehicle & license',
            icon: Icons.two_wheeler_outlined,
            children: [
              _field('Vehicle type', _vehicleType),
              _field('Vehicle model', _vehicleModel),
              _field('Plate number', _plate),
              _field('License number', _license),
            ],
          ),
          SizedBox(height: 12),
          _section(
            title: 'Security',
            icon: Icons.lock_outline_rounded,
            children: [
              _field(
                'Current password',
                _currentPassword,
                obscureText: true,
                alwaysEnabled: true,
              ),
              _field(
                'New password',
                _password,
                obscureText: true,
                alwaysEnabled: true,
              ),
              _field(
                'Confirm new password',
                _passwordConfirmation,
                obscureText: true,
                alwaysEnabled: true,
              ),
            ],
          ),
          if (_editing) ...[
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: RiderColors.blue,
                foregroundColor: RiderColors.isDark
                    ? Color(0xFF172129)
                    : Colors.white,
                minimumSize: Size.fromHeight(49),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: Icon(Icons.save_outlined),
              label: Text(
                'Save Rider Profile',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
          SizedBox(height: 18),
          _supportCard(),
        ],
      ),
    );
  }

  Widget _profileHero() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: RiderColors.isDark
              ? const [
                  Color(0xFF26343D),
                  Color(0xFF354753),
                  Color(0xFF3F5360),
                ]
              : const [
                  Color(0xFF627E90),
                  Color(0xFF758F9F),
                  Color(0xFF8CA2AF),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: RiderColors.isDark ? .22 : .10),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .28),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 39,
                ),
              ),
              Positioned(
                right: 1,
                bottom: 1,
                child: CircleAvatar(
                  radius: 11,
                  backgroundColor: RiderColors.green,
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_firstName.text} ${_lastName.text}'.trim(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '${widget.profile.vehicleType} • ${widget.profile.plateNumber}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .8),
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 11),
                Wrap(
                  spacing: 10,
                  runSpacing: 7,
                  children: [
                    _heroStat(
                      Icons.star_rounded,
                      widget.profile.rating.toStringAsFixed(1),
                    ),
                    _heroStat(
                      Icons.check_circle_outline,
                      '${widget.profile.completedDeliveries} done',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(IconData icon, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _availabilityCard() {
    final online = _availability == 'online';

    return RiderSurface(
      padding: EdgeInsets.all(15),
      elevated: true,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: online ? RiderColors.greenSoft : RiderColors.redSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              online ? Icons.bolt_rounded : Icons.pause_rounded,
              color: online ? RiderColors.green : RiderColors.red,
            ),
          ),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  online ? 'You are online' : 'You are offline',
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  online
                      ? 'Ready to receive rider assignments.'
                      : 'You will not receive new assignments.',
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: online,
            activeColor: RiderColors.green,
            onChanged: (value) {
              setState(() {
                _availability = value ? 'online' : 'offline';
                widget.profile.availabilityStatus = _availability;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _appearanceCard() {
    return RiderSurface(
      padding: EdgeInsets.all(15),
      elevated: true,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? RiderColors.goldSoft
                  : RiderColors.blueSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              widget.isDarkMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              color: widget.isDarkMode
                  ? RiderColors.gold
                  : RiderColors.blue,
            ),
          ),
          SizedBox(width: 11),
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
                SizedBox(height: 2),
                Text(
                  widget.isDarkMode
                      ? 'Dark rider mode is active.'
                      : 'Use a lighter rider interface.',
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: widget.isDarkMode,
            activeColor: RiderColors.gold,
            onChanged: widget.onDarkModeChanged,
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return RiderSurface(
      padding: EdgeInsets.all(15),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: RiderColors.blueSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: RiderColors.blue, size: 19),
              ),
              SizedBox(width: 9),
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
          SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool obscureText = false,
    bool alwaysEnabled = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        enabled: alwaysEnabled || _editing,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(
          fontSize: 12,
          color: RiderColors.text,
        ),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: (alwaysEnabled || _editing)
              ? RiderColors.field
              : RiderColors.surfaceSoft,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: RiderColors.border),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: RiderColors.border),
          ),
        ),
      ),
    );
  }

  Widget _supportCard() {
    return RiderSurface(
      padding: EdgeInsets.all(15),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RiderSectionHeader(
            title: 'Rider Support',
            subtitle: 'Report a parcel, account or delivery concern',
          ),
          SizedBox(height: 12),
          TextField(
            controller: _complaint,
            minLines: 3,
            maxLines: 5,
            style: TextStyle(color: RiderColors.text),
            decoration: InputDecoration(
              hintText: 'Describe your concern...',
              filled: true,
              fillColor: RiderColors.field,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: RiderColors.border),
              ),
            ),
          ),
          SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              if (_complaint.text.trim().isEmpty) {
                _toast('Enter your concern first.');
                return;
              }
              _complaint.clear();
              _toast('Demo support ticket submitted.');
            },
            icon: Icon(Icons.support_agent_rounded),
            label: Text(
              'Submit Support Ticket',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    if (_password.text.isNotEmpty &&
        _password.text != _passwordConfirmation.text) {
      _toast('New password and confirmation do not match.');
      return;
    }

    widget.profile
      ..firstName = _firstName.text.trim()
      ..lastName = _lastName.text.trim()
      ..email = _email.text.trim()
      ..contactNo = _contact.text.trim()
      ..streetAddress = _street.text.trim()
      ..vehicleType = _vehicleType.text.trim()
      ..vehicleModel = _vehicleModel.text.trim()
      ..plateNumber = _plate.text.trim()
      ..licenseNumber = _license.text.trim()
      ..availabilityStatus = _availability;

    setState(() => _editing = false);
    _currentPassword.clear();
    _password.clear();
    _passwordConfirmation.clear();
    _toast('Rider profile updated locally.');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
