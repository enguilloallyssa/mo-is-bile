import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'registration_pending_screen.dart';
class AccountRegistrationScreen extends StatefulWidget {
  final String role;
  const AccountRegistrationScreen({
    super.key,
    required this.role,
  });
  @override
  State<AccountRegistrationScreen> createState() =>
      _AccountRegistrationScreenState();
}
class _AccountRegistrationScreenState
    extends State<AccountRegistrationScreen> {
  static const Color gold = Color(0xFFD48F08);
  static const Color background = Color(0xFFF7F4EE);
  static const Color ink = Color(0xFF211D17);
  static const Color muted = Color(0xFF81786C);
  static const Color line = Color(0xFFE5DED4);
  final _formKey = GlobalKey<FormState>();
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
  final businessName = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  int step = 0;
  String? sex;
  bool acceptTerms = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  PlatformFile? validId;
  PlatformFile? businessPermit;
  final otpControllers =
      List.generate(6, (_) => TextEditingController());
  bool get isLogistics => widget.role == 'logistics';
  String get roleLabel => isLogistics ? 'Logistics' : 'Buyer';
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
      businessName,
      password,
      confirmPassword,
      ...otpControllers,
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
      initialDate: DateTime(latest.year - 5),
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
    if (birthday.text.isEmpty) return null;
    final birth = DateTime.tryParse(birthday.text);
    if (birth == null) return null;
    final today = DateTime.now();
    int age = today.year - birth.year;
    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      age--;
    }
    return age;
  }
  Future<PlatformFile?> _pickDocument() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.single;
  }
  Future<void> _pickValidId() async {
    final file = await _pickDocument();
    if (file != null) {
      setState(() => validId = file);
    }
  }
  Future<void> _pickBusinessPermit() async {
    final file = await _pickDocument();
    if (file != null) {
      setState(() => businessPermit = file);
    }
  }
  bool _validateDetails() {
    final okay = _formKey.currentState?.validate() ?? false;
    if (sex == null) {
      _showMessage('Please select your sex.');
      return false;
    }
    if ((_age() ?? 0) < 18) {
      _showMessage('You must be 18 years old or older.');
      return false;
    }
    return okay;
  }
  void _next() {
    FocusScope.of(context).unfocus();
    if (step == 0 && !_validateDetails()) return;
    if (step == 1) {
      if (validId == null) {
        _showMessage('Please choose a valid ID.');
        return;
      }
      if (isLogistics && businessPermit == null) {
        _showMessage('Please choose your business permit.');
        return;
      }
    }
    if (step == 2) {
      if (password.text.length < 8) {
        _showMessage('Password must contain at least 8 characters.');
        return;
      }
      if (password.text != confirmPassword.text) {
        _showMessage('Passwords do not match.');
        return;
      }
      if (!acceptTerms) {
        _showMessage('Please accept the Terms of Service and Privacy Policy.');
        return;
      }
    }
    if (step < 3) {
      setState(() => step++);
    }
  }
  void _back() {
    if (step == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => step--);
  }
  void _verifyOtpPreview() {
    final code = otpControllers.map((e) => e.text).join();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      _showMessage('Enter the complete 6-digit verification code.');
      return;
    }
    _showBackendNotice();
  }
  void _showBackendNotice() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Laravel API connection needed'),
          content: const Text(
            'The mobile registration UI is ready. Real OTP verification and '
            'database submission still need the Laravel mobile API endpoints. '
            'For now, this button does not create an account.',
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
                      role: widget.role,
                      email: email.text.trim(),
                      reviewerName: 'administrator',
                      previewMode: true,
                    ),
                  ),
                );
              },
              child: const Text('Preview pending page'),
            ),
          ],
        );
      },
    );
  }
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
  @override
  Widget build(BuildContext context) {
    final titles = [
      'Your Information',
      'Verification Documents',
      'Login Credentials',
      'Email Verification',
    ];
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: _back,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          '$roleLabel Registration',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _ProgressHeader(
              currentStep: step,
              totalSteps: 4,
              title: titles[step],
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _buildStep(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStep() {
    switch (step) {
      case 0:
        return _detailsStep();
      case 1:
        return _documentsStep();
      case 2:
        return _credentialsStep();
      default:
        return _otpStep();
    }
  }
  Widget _card({
    required Widget child,
  }) {
    return Container(
      key: ValueKey(step),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.045),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
  Widget _detailsStep() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _heading(
            'Personal & Contact',
            'Use the same details shown on your valid ID.',
            Icons.person_outline,
          ),
          const SizedBox(height: 17),
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
              LengthLimitingTextInputFormatter(1),
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
            'Email Address *',
            'name@email.com',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Email is required.';
              if (!text.contains('@')) return 'Enter a valid email.';
              return null;
            },
          ),
          _field(
            contact,
            'Contact Number *',
            '09XXXXXXXXX',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: (value) {
              final text = value?.trim() ?? '';
              if (!RegExp(r'^09\d{9}$').hasMatch(text)) {
                return 'Use an 11-digit number starting with 09.';
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
            validator: (value) {
              if ((value ?? '').isEmpty) return 'Birthday is required.';
              return null;
            },
          ),
          const SizedBox(height: 7),
          Text(
            _age() == null
                ? 'You must be 18 years old or older.'
                : 'Age: ${_age()}',
            style: const TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 22),
          _heading(
            'Address',
            'Enter your Philippine home or business address.',
            Icons.location_on_outlined,
          ),
          const SizedBox(height: 17),
          _field(province, 'Province / Area *', 'Batangas'),
          _field(municipality, 'City / Municipality *', 'Lipa City'),
          _field(barangay, 'Barangay *', 'Barangay'),
          _field(
            street,
            'Street / House No. / Subdivision *',
            'House number, street, subdivision, landmark',
            maxLines: 3,
          ),
          if (isLogistics) ...[
            const SizedBox(height: 8),
            _heading(
              'Business Information',
              'Enter the registered Logistics business name.',
              Icons.warehouse_outlined,
            ),
            const SizedBox(height: 17),
            _field(
              businessName,
              'Business Name *',
              'Registered business name',
            ),
          ],
          const SizedBox(height: 22),
          _actions(
            backLabel: 'Back',
            nextLabel: 'Continue to Verification',
          ),
        ],
      ),
    );
  }
  Widget _documentsStep() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Verification Documents',
            style: TextStyle(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Choose clear JPG, PNG, or PDF files.',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _uploadTile(
            title: 'Valid ID *',
            file: validId,
            onTap: _pickValidId,
          ),
          if (isLogistics) ...[
            const SizedBox(height: 13),
            _uploadTile(
              title: 'Business Permit *',
              file: businessPermit,
              onTap: _pickBusinessPermit,
            ),
          ],
          const SizedBox(height: 23),
          _actions(
            backLabel: 'Back',
            nextLabel: 'Continue to Login Setup',
          ),
        ],
      ),
    );
  }
  Widget _credentialsStep() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Login Credentials',
            style: TextStyle(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          _label('Password *'),
          TextFormField(
            controller: password,
            obscureText: obscurePassword,
            decoration: _decoration('Minimum 8 characters').copyWith(
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => obscurePassword = !obscurePassword),
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 19,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _label('Confirm Password *'),
          TextFormField(
            controller: confirmPassword,
            obscureText: obscureConfirm,
            decoration: _decoration('Repeat password').copyWith(
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => obscureConfirm = !obscureConfirm),
                icon: Icon(
                  obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 19,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => acceptTerms = !acceptTerms),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE8E1D8)),
                borderRadius: BorderRadius.circular(12),
              ),
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
                          color: Color(0xFF615B53),
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 13),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: Color(0xFFB57908),
                size: 17,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'After email verification, your registration will be submitted for account review.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10.5,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          _actions(
            backLabel: 'Back',
            nextLabel: 'Continue to Email Verification',
          ),
        ],
      ),
    );
  }
  Widget _otpStep() {
    return _card(
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9ED),
              border: Border.all(color: const Color(0xFFEFDFBD)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.mail_outline,
              color: Color(0xFFB97805),
              size: 29,
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'EMAIL VERIFICATION',
            style: TextStyle(
              color: Color(0xFFB97805),
              fontSize: 9,
              letterSpacing: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Enter your verification code',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ink,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'A real 6-digit OTP will be sent to ${email.text.trim()} after the Laravel mobile API is connected.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 23),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: SizedBox(
                  width: 42,
                  height: 52,
                  child: TextField(
                    controller: otpControllers[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFD9D4CD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: gold, width: 1.5),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 21),
          SizedBox(
            width: double.infinity,
            height: 49,
            child: ElevatedButton(
              onPressed: _verifyOtpPreview,
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                'Verify Code',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _back,
            icon: const Icon(Icons.arrow_back, size: 17),
            label: const Text('Back'),
          ),
        ],
      ),
    );
  }
  Widget _heading(String title, String copy, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFBF8F3),
            border: Border.all(color: const Color(0xFFE8DFD1)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFA96E0B), size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF24272C),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                copy,
                style: const TextStyle(
                  color: Color(0xFF7D838A),
                  fontSize: 10.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    bool required = true,
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
        color: Color(0xFFA29B92),
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
        borderSide: const BorderSide(color: Color(0xFFD7DCE2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: gold, width: 1.3),
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
  Widget _uploadTile({
    required String title,
    required PlatformFile? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 145),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: file == null
              ? const Color(0xFFFBFCFC)
              : const Color(0xFFFBFEFC),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: file == null
                ? const Color(0xFFCFD4DA)
                : const Color(0xFF7CA68A),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.upload_file_outlined,
              color: Color(0xFFA96E0B),
              size: 34,
            ),
            const SizedBox(height: 9),
            Text(
              title,
              style: const TextStyle(
                color: ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              file?.name ?? 'Tap to browse',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: file == null
                    ? const Color(0xFF8B9198)
                    : const Color(0xFF4F8060),
                fontSize: 10.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'JPG, PNG or PDF',
              style: TextStyle(
                color: Color(0xFFA29B92),
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _actions({
    required String backLabel,
    required String nextLabel,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _back,
            icon: const Icon(Icons.arrow_back, size: 17),
            label: Text(backLabel),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: const Color(0xFF625A50),
              side: const BorderSide(color: Color(0xFFDFD8CE)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: gold,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: Text(
              nextLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
class _ProgressHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  const _ProgressHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 13),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF34383E),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: const TextStyle(
                  color: Color(0xFF8C9198),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: List.generate(totalSteps, (index) {
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(
                    right: index == totalSteps - 1 ? 0 : 5,
                  ),
                  decoration: BoxDecoration(
                    color: index <= currentStep
                        ? const Color(0xFFD48F08)
                        : const Color(0xFFE8EAED),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
