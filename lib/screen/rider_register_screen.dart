import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'registration_pending_screen.dart';
import 'rider_logistics_screen.dart';
class RiderRegisterScreen extends StatefulWidget {
  final LogisticsProvider provider;
  const RiderRegisterScreen({
    super.key,
    required this.provider,
  });
  @override
  State<RiderRegisterScreen> createState() => _RiderRegisterScreenState();
}
class _RiderRegisterScreenState extends State<RiderRegisterScreen> {
  static const Color gold = Color(0xFFD48F08);
  static const Color background = Color(0xFFF7F4EE);
  static const Color ink = Color(0xFF211D17);
  static const Color muted = Color(0xFF81786C);
  final formKey = GlobalKey<FormState>();
  final lastName = TextEditingController();
  final firstName = TextEditingController();
  final middleInitial = TextEditingController();
  final email = TextEditingController();
  final contact = TextEditingController();
  final birthday = TextEditingController();
  final province = TextEditingController();
  final municipality = TextEditingController();
  final barangay = TextEditingController();
  final street = TextEditingController();
  final plateNumber = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  String? sex;
  String? vehicleType;
  bool acceptTerms = false;
  PlatformFile? idDocument;
  PlatformFile? orcrDocument;
  PlatformFile? profileImage;
  @override
  void dispose() {
    for (final controller in [
      lastName,
      firstName,
      middleInitial,
      email,
      contact,
      birthday,
      province,
      municipality,
      barangay,
      street,
      plateNumber,
      password,
      confirmPassword,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }
  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final latest = DateTime(now.year - 18, now.month, now.day);
    final result = await showDatePicker(
      context: context,
      initialDate: DateTime(latest.year - 4),
      firstDate: DateTime(1900),
      lastDate: latest,
    );
    if (result == null) return;
    birthday.text =
        '${result.year.toString().padLeft(4, '0')}-'
        '${result.month.toString().padLeft(2, '0')}-'
        '${result.day.toString().padLeft(2, '0')}';
    setState(() {});
  }
  int? _age() {
    final birth = DateTime.tryParse(birthday.text);
    if (birth == null) return null;
    final now = DateTime.now();
    var age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }
  Future<PlatformFile?> _pickFile({
    required List<String> extensions,
  }) async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.single;
  }
  Future<void> _pickProfile() async {
    final file = await _pickFile(
      extensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (file != null) setState(() => profileImage = file);
  }
  Future<void> _pickId() async {
    final file = await _pickFile(
      extensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    if (file != null) setState(() => idDocument = file);
  }
  Future<void> _pickOrcr() async {
    final file = await _pickFile(
      extensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    if (file != null) setState(() => orcrDocument = file);
  }
  void _submitPreview() {
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (sex == null) {
      _message('Please select your sex.');
      return;
    }
    if ((_age() ?? 0) < 18) {
      _message('You must be 18 years old or older.');
      return;
    }
    if (vehicleType == null) {
      _message('Please choose a vehicle.');
      return;
    }
    if (idDocument == null || orcrDocument == null) {
      _message('Valid ID and OR / CR are required.');
      return;
    }
    if (password.text.length < 8) {
      _message('Password must contain at least 8 characters.');
      return;
    }
    if (password.text != confirmPassword.text) {
      _message('Passwords do not match.');
      return;
    }
    if (!acceptTerms) {
      _message('Please accept the Terms of Service and Privacy Policy.');
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laravel API connection needed'),
        content: const Text(
          'The Rider form and file selection are ready. Real email OTP and '
          'submission to the selected Logistics provider still require the '
          'Laravel mobile API.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                this.context,
                MaterialPageRoute(
                  builder: (_) => RegistrationPendingScreen(
                    role: 'rider',
                    email: email.text.trim(),
                    reviewerName: widget.provider.name,
                    previewMode: true,
                  ),
                ),
              );
            },
            child: const Text('Preview pending page'),
          ),
        ],
      ),
    );
  }
  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Rider Application',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _providerSummary(),
                    const SizedBox(height: 14),
                    _formCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _providerSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5DED4)),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5DF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.warehouse_outlined,
              color: Color(0xFFB67814),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'APPLYING TO',
                  style: TextStyle(
                    color: Color(0xFFA98A60),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.provider.name,
                  style: const TextStyle(
                    color: Color(0xFF2B261F),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.provider.location,
                  style: const TextStyle(
                    color: Color(0xFF8C8378),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '● Active',
            style: TextStyle(
              color: Color(0xFF438461),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE5DED4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.045),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle('01 · PERSONAL', 'Personal information'),
          _field(lastName, 'Last Name *', 'Dela Cruz'),
          _field(firstName, 'First Name *', 'Juan'),
          _field(
            middleInitial,
            'Middle Initial',
            'M',
            required: false,
            maxLength: 1,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
            ],
          ),
          _label('Sex *'),
          DropdownButtonFormField<String>(
            value: sex,
            decoration: _decoration('Select sex'),
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
            ],
            onChanged: (value) => setState(() => sex = value),
          ),
          const SizedBox(height: 14),
          _field(
            email,
            'Email *',
            'name@email.com',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty || !text.contains('@')) {
                return 'Enter a valid email.';
              }
              return null;
            },
          ),
          _field(
            contact,
            'Contact No. *',
            '09XXXXXXXXX',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: (value) {
              if (!RegExp(r'^09\d{9}$').hasMatch(value ?? '')) {
                return 'Use 11 digits beginning with 09.';
              }
              return null;
            },
          ),
          _label('Birthday *'),
          TextFormField(
            controller: birthday,
            readOnly: true,
            onTap: _pickBirthday,
            decoration: _decoration('Select birthday').copyWith(
              suffixIcon: const Icon(Icons.calendar_month_outlined, size: 19),
            ),
            validator: (value) =>
                (value ?? '').isEmpty ? 'Birthday is required.' : null,
          ),
          const SizedBox(height: 6),
          Text(
            _age() == null
                ? 'You must be 18 years old or older.'
                : 'Age: ${_age()}',
            style: const TextStyle(color: muted, fontSize: 10),
          ),
          const SizedBox(height: 13),
          _upload(
            'Profile Photo (Optional)',
            profileImage,
            _pickProfile,
          ),
          const SizedBox(height: 24),
          _sectionTitle('02 · ADDRESS', 'Home address'),
          _field(province, 'Province / Area *', 'Province'),
          _field(municipality, 'City / Municipality *', 'City'),
          _field(barangay, 'Barangay *', 'Barangay'),
          _field(
            street,
            'Street / House No. / Subdivision *',
            'House number, street, subdivision, landmark',
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          _sectionTitle(
            '03 · VEHICLE & VERIFICATION',
            'Delivery requirements',
          ),
          _label('Vehicle *'),
          DropdownButtonFormField<String>(
            value: vehicleType,
            decoration: _decoration('Choose vehicle'),
            items: const [
              DropdownMenuItem(
                value: 'Motorcycle',
                child: Text('Motorcycle'),
              ),
              DropdownMenuItem(value: 'Bicycle', child: Text('Bicycle')),
              DropdownMenuItem(value: 'Car', child: Text('Car')),
              DropdownMenuItem(value: 'Van', child: Text('Van')),
              DropdownMenuItem(value: 'Truck', child: Text('Truck')),
            ],
            onChanged: (value) => setState(() => vehicleType = value),
          ),
          const SizedBox(height: 14),
          _field(
            plateNumber,
            'Plate Number *',
            'ABC 1234',
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[A-Za-z0-9 -]'),
              ),
            ],
          ),
          _upload(
            "Valid ID / Driver's License *",
            idDocument,
            _pickId,
          ),
          const SizedBox(height: 12),
          _upload('OR / CR *', orcrDocument, _pickOrcr),
          const SizedBox(height: 24),
          _sectionTitle('04 · ACCOUNT', 'Create login credentials'),
          _field(
            password,
            'Password *',
            'Minimum 8 characters',
            obscure: true,
          ),
          _field(
            confirmPassword,
            'Confirm Password *',
            'Repeat password',
            obscure: true,
          ),
          InkWell(
            onTap: () => setState(() => acceptTerms = !acceptTerms),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: acceptTerms,
                  activeColor: gold,
                  onChanged: (value) =>
                      setState(() => acceptTerms = value ?? false),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'I agree to the Terms of Service and Privacy Policy.',
                      style: TextStyle(
                        color: Color(0xFF746C62),
                        fontSize: 10.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          SizedBox(
            height: 49,
            child: ElevatedButton(
              onPressed: _submitPreview,
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                'Continue to Email Verification',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _sectionTitle(String eyebrow, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: Color(0xFFB97805),
              fontSize: 8.5,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF29241F),
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    bool required = true,
    bool obscure = false,
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label(label),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            maxLength: maxLength,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: _decoration(hint).copyWith(counterText: ''),
            validator: validator ??
                (value) {
                  if (required && (value?.trim().isEmpty ?? true)) {
                    return 'This field is required.';
                  }
                  return null;
                },
          ),
        ],
      ),
    );
  }
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF514A42),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFA0998F),
        fontSize: 12,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFE2DBD1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: gold),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
  Widget _upload(
    String label,
    PlatformFile? file,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF9),
          border: Border.all(
            color: file == null
                ? const Color(0xFFD7B76F)
                : const Color(0xFF7CA68A),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.upload_file_outlined,
              color: Color(0xFFB97805),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    file?.name ?? 'Tap to browse',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: file == null
                          ? muted
                          : const Color(0xFF4F8060),
                      fontSize: 9.5,
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
}
