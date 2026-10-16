import 'package:flutter/material.dart';

import 'models/rider_profile_model.dart';

class RiderProfilePage extends StatefulWidget {
  final RiderProfile profile;

  const RiderProfilePage({
    super.key,
    required this.profile,
  });

  @override
  State<RiderProfilePage> createState() => _RiderProfilePageState();
}

class _RiderProfilePageState extends State<RiderProfilePage> {
  static const Color _blue = Color(0xFF3C6E91);
  static const Color _border = Color(0xFFEADFC9);

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
  final TextEditingController _passwordConfirmation =
      TextEditingController();
  final TextEditingController _complaint = TextEditingController();

  late String _availability;

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
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _contact.dispose();
    _street.dispose();
    _vehicleType.dispose();
    _vehicleModel.dispose();
    _plate.dispose();
    _license.dispose();
    _currentPassword.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
    _complaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFFFDF8),
        surfaceTintColor: Colors.transparent,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Management',
              style: TextStyle(
                color: Color(0xFF211D17),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Rider Profile & Vehicle',
              style: TextStyle(
                color: Color(0xFF918677),
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
        children: [
          _profileSummary(),
          const SizedBox(height: 12),
          _profileForm(),
          const SizedBox(height: 12),
          _complaintForm(),
        ],
      ),
    );
  }

  Widget _profileSummary() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: _blue,
                  size: 27,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_firstName.text} ${_lastName.text}'.trim(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${widget.profile.completedDeliveries} completed deliveries · ★ ${widget.profile.rating.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Color(0xFF918677),
                        fontSize: 7.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _availability,
                  decoration: const InputDecoration(
                    labelText: 'Availability',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'online',
                      child: Text('Online'),
                    ),
                    DropdownMenuItem(
                      value: 'offline',
                      child: Text('Offline'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _availability = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _updateAvailability,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(88, 48),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileForm() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Rider Profile & Vehicle',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _toast(
              'Profile photo picker will connect with the account API later.',
            ),
            icon: const Icon(Icons.photo_camera_outlined, size: 16),
            label: const Text(
              'Change Profile Photo',
              style: TextStyle(fontSize: 8),
            ),
          ),
          const SizedBox(height: 12),
          _field('First name', _firstName),
          _field('Last name', _lastName),
          _field(
            'Email',
            _email,
            keyboardType: TextInputType.emailAddress,
          ),
          _field(
            'Contact',
            _contact,
            keyboardType: TextInputType.phone,
          ),
          _field('Street address', _street),
          _field('Vehicle type', _vehicleType),
          _field('Vehicle model', _vehicleModel),
          _field('Plate number', _plate),
          _field('License number', _license),
          _field(
            'Current password',
            _currentPassword,
            obscureText: true,
          ),
          _field(
            'New password',
            _password,
            obscureText: true,
          ),
          _field(
            'Confirm password',
            _passwordConfirmation,
            obscureText: true,
          ),
          const SizedBox(height: 4),
          ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(46),
            ),
            child: const Text(
              'Save Rider Profile',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _complaintForm() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Support / Complaint',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _complaint,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Describe your concern...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 9),
          OutlinedButton(
            onPressed: () {
              if (_complaint.text.trim().isEmpty) {
                _toast('Enter your concern first.');
                return;
              }
              _complaint.clear();
              _toast('Complaint preview submitted.');
            },
            child: const Text(
              'Submit Complaint',
              style: TextStyle(fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 8.5),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
    );
  }

  void _updateAvailability() {
    widget.profile.availabilityStatus = _availability;
    _toast('Availability updated to $_availability.');
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
      ..licenseNumber = _license.text.trim();

    setState(() {});

    _currentPassword.clear();
    _password.clear();
    _passwordConfirmation.clear();

    _toast('Rider profile saved locally.');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
