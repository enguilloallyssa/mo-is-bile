import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/sari_live_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/sari_address_picker.dart';

class LogisticsRegisterScreen extends StatefulWidget {
  const LogisticsRegisterScreen({super.key});

  @override
  State<LogisticsRegisterScreen> createState() =>
      _LogisticsRegisterScreenState();
}

class _LogisticsRegisterScreenState extends State<LogisticsRegisterScreen> {
  static const Color _background = Color(0xFF0B0B0D);
  static const Color _surface = Color(0xFF18181C);
  static const Color _field = Color(0xFF222226);
  static const Color _border = Color(0xFF37373D);
  static const Color _gold = Color(0xFFD4A62A);
  static const Color _goldDark = Color(0xFFA96F06);
  static const Color _muted = Color(0xFFA7A7AF);
  static const Color _success = Color(0xFF70C68C);

  static const List<String> _serviceAreaOptions = <String>[
    'NCR',
    'CAR',
    'Region I (Ilocos Region)',
    'Region II (Cagayan Valley)',
    'Region III (Central Luzon)',
    'Region IV-A (CALABARZON)',
    'MIMAROPA Region',
    'Region V (Bicol Region)',
    'Region VI (Western Visayas)',
    'Region VII (Central Visayas)',
    'Region VIII (Eastern Visayas)',
    'Region IX (Zamboanga Peninsula)',
    'Region X (Northern Mindanao)',
    'Region XI (Davao Region)',
    'Region XII (SOCCSKSARGEN)',
    'Region XIII (Caraga)',
    'BARMM',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _middleInitial = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _contact = TextEditingController();
  final TextEditingController _birthday = TextEditingController();

  final TextEditingController _region = TextEditingController();
  final TextEditingController _regionCode = TextEditingController();
  final TextEditingController _province = TextEditingController();
  final TextEditingController _provinceCode = TextEditingController();
  final TextEditingController _municipality = TextEditingController();
  final TextEditingController _municipalityCode = TextEditingController();
  final TextEditingController _barangay = TextEditingController();
  final TextEditingController _barangayCode = TextEditingController();
  final TextEditingController _street = TextEditingController();
  final TextEditingController _postalCode = TextEditingController();

  final TextEditingController _businessName = TextEditingController();
  final TextEditingController _tin = TextEditingController();
  final TextEditingController _secRegistrationNo = TextEditingController();
  final TextEditingController _position = TextEditingController();

  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirmation = TextEditingController();

  String? _sex;
  final Set<String> _serviceAreas = <String>{};

  PlatformFile? _profileImage;
  PlatformFile? _idDocument;
  PlatformFile? _businessPermit;
  PlatformFile? _birDocument;
  PlatformFile? _secDocument;

  int _step = 0;
  bool _hidePassword = true;
  bool _hideConfirmation = true;
  bool _terms = false;
  bool _busy = false;

  static const List<String> _stepTitles = <String>[
    'Personal & Address',
    'Business Details',
    'Verification Documents',
    'Login Setup',
  ];

  @override
  void dispose() {
    for (final TextEditingController controller in <TextEditingController>[
      _firstName,
      _lastName,
      _middleInitial,
      _email,
      _contact,
      _birthday,
      _region,
      _regionCode,
      _province,
      _provinceCode,
      _municipality,
      _municipalityCode,
      _barangay,
      _barangayCode,
      _street,
      _postalCode,
      _businessName,
      _tin,
      _secRegistrationNo,
      _position,
      _password,
      _passwordConfirmation,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final DateTime today = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year - 25, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: today,
    );

    if (date == null) {
      return;
    }

    setState(() {
      _birthday.text =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    });
  }

  Future<PlatformFile?> _pickFile({
    required List<String> extensions,
  }) async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final PlatformFile file = result.files.single;

    if (file.size > 5 * 1024 * 1024) {
      _message('File must not be larger than 5 MB.');
      return null;
    }

    return file;
  }

  Future<void> _pickProfileImage() async {
    final PlatformFile? file = await _pickFile(
      extensions: const <String>['jpg', 'jpeg', 'png', 'webp'],
    );

    if (file == null || !mounted) {
      return;
    }

    setState(() {
      _profileImage = file;
    });
  }

  Future<void> _pickDocument(String type) async {
    final PlatformFile? file = await _pickFile(
      extensions: const <String>['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (file == null || !mounted) {
      return;
    }

    setState(() {
      switch (type) {
        case 'id':
          _idDocument = file;
          break;
        case 'permit':
          _businessPermit = file;
          break;
        case 'bir':
          _birDocument = file;
          break;
        case 'sec':
          _secDocument = file;
          break;
      }
    });
  }

  bool _validateCurrentStep() {
    FocusScope.of(context).unfocus();

    final bool valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
      return false;
    }

    if (_step == 0) {
      if (_profileImage == null) {
        _message('Select a profile photo before continuing.');
        return false;
      }

      if (_region.text.trim().isEmpty ||
          _regionCode.text.trim().isEmpty ||
          _province.text.trim().isEmpty ||
          _provinceCode.text.trim().isEmpty ||
          _municipality.text.trim().isEmpty ||
          _municipalityCode.text.trim().isEmpty ||
          _barangay.text.trim().isEmpty ||
          _barangayCode.text.trim().isEmpty) {
        _message('Complete Region, Province, City/Municipality, and Barangay.');
        return false;
      }
    }

    if (_step == 1 && _serviceAreas.isEmpty) {
      _message('Select at least one service area.');
      return false;
    }

    if (_step == 2) {
      final List<PlatformFile?> requiredFiles = <PlatformFile?>[
        _idDocument,
        _businessPermit,
        _birDocument,
        _secDocument,
      ];

      if (requiredFiles.any((PlatformFile? file) => file == null)) {
        _message(
          'Upload Valid ID, Business Permit, BIR Form 2303, and SEC Certificate.',
        );
        return false;
      }
    }

    if (_step == 3 && !_terms) {
      _message('Accept the SARI Terms and Privacy Policy to continue.');
      return false;
    }

    return true;
  }

  void _next() {
    if (_busy || !_validateCurrentStep()) {
      return;
    }

    if (_step < _stepTitles.length - 1) {
      setState(() {
        _step++;
      });
      return;
    }

    _submitPreview();
  }

  void _back() {
    if (_busy) {
      return;
    }

    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _step--;
    });
  }

  Future<void> _submitPreview() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final fields = <String,String>{
        'first_name': _firstName.text.trim(), 'last_name': _lastName.text.trim(),
        'middle_initial':_middleInitial.text.trim(), 'email':_email.text.trim(),
        'contact_no':_contact.text.trim(), 'region_code':_regionCode.text.trim(),
        'region_name':_region.text.trim(), 'province_code':_provinceCode.text.trim(),
        'province_name':_province.text.trim(), 'municipality_code':_municipalityCode.text.trim(),
        'municipality_name':_municipality.text.trim(), 'barangay_code':_barangayCode.text.trim(),
        'barangay_name':_barangay.text.trim(), 'street_address':_street.text.trim(),
        'postal_code':_postalCode.text.trim(), 'business_name':_businessName.text.trim(),
        'tin':_tin.text.trim(), 'sec_registration_no':_secRegistrationNo.text.trim(),
        'position':_position.text.trim(), 'password':_password.text,
        'password_confirmation':_passwordConfirmation.text,'terms':'1',
        if (_sex != null) 'sex':_sex!,
        if (_birthday.text.trim().isNotEmpty) 'birthday':_birthday.text.trim(),
      };
      final areas = _serviceAreas.toList()..sort();
      for (var i=0;i<areas.length;i++) { fields['service_areas[$i]'] = areas[i]; }
      final selectedFiles = <PlatformFile?>[
        _profileImage, _idDocument, _businessPermit, _birDocument, _secDocument,
      ];
      if (selectedFiles.any((file) => file == null || file.path == null || file.path!.isEmpty)) {
        throw const FormatException('One or more selected files are unavailable. Re-select the documents and try again.');
      }
      final documents=<String,File>{
        'profile_image':File(_profileImage!.path!),
        'id_document':File(_idDocument!.path!),
        'business_permit':File(_businessPermit!.path!),
        'bir_document':File(_birDocument!.path!),
        'sec_document':File(_secDocument!.path!),
      };
      await SariLiveData.instance.logisticsRegister(fields, documents);
      if (!mounted) return;
      await _verifyOtpDialog();
    } catch (error) {
      if (mounted) _message(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyOtpDialog() async {
    final controller=TextEditingController();
    try {
      final verified=await showDialog<bool>(context:context,barrierDismissible:false,
        builder:(dialogContext)=>AlertDialog(
          title:const Text('Verify Logistics Email'),
          content:Column(mainAxisSize:MainAxisSize.min,children:[
            Text('Enter the 6-digit code sent to ${_email.text.trim()}.'),
            const SizedBox(height:12),
            TextField(controller:controller,keyboardType:TextInputType.number,maxLength:6,
              decoration:const InputDecoration(labelText:'Verification code')),
          ]),
          actions:[
            TextButton(onPressed:()=>Navigator.pop(dialogContext,false),child:const Text('Later')),
            TextButton(onPressed:() async {
              try {
                await SariLiveData.instance.logisticsResendOtp(_email.text.trim());
                if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content:Text('OTP requested. Check your email.')));
              } catch (e) {
                if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content:Text(e.toString())));
              }
            },child:const Text('Resend')),
            FilledButton(onPressed:() async {
              try {
                await SariLiveData.instance.logisticsVerifyOtp(_email.text.trim(),controller.text.trim());
                if (dialogContext.mounted) Navigator.pop(dialogContext,true);
              } catch(e) {
                if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content:Text(e.toString())));
              }
            },child:const Text('Verify')),
          ],
        ));
      if (verified == true && mounted) {
        await showDialog<void>(context:context,builder:(ctx)=>AlertDialog(
          title:const Text('Application submitted'),
          content:const Text('Email verified. Your Logistics application is pending SARI administrator approval.'),
          actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('OK'))],
        ));
        if (mounted) Navigator.pop(context);
      }
    } finally { controller.dispose(); }
  }

  String? _required(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Required.';
    }

    return null;
  }

  String? _nameValidator(String? value) {
    final String text = (value ?? '').trim();

    if (text.length < 2 || text.length > 50) {
      return 'Use 2 to 50 characters.';
    }

    if (!RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿÑñ\s.'-]+$").hasMatch(text)) {
      return 'Enter a valid name.';
    }

    return null;
  }

  String? _middleInitialValidator(String? value) {
    final String text = (value ?? '').trim();

    if (text.isEmpty) {
      return null;
    }

    if (!RegExp(r'^[A-Za-zÀ-ÖØ-öø-ÿÑñ]$').hasMatch(text)) {
      return 'Use one letter only.';
    }

    return null;
  }

  String? _emailValidator(String? value) {
    final String text = (value ?? '').trim();

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    final String text = (value ?? '').trim();

    if (!RegExp(r'^(09\d{9}|\+639\d{9})$').hasMatch(text)) {
      return 'Use 09XXXXXXXXX or +639XXXXXXXXX.';
    }

    return null;
  }

  String? _birthdayValidator(String? value) {
    final String text = (value ?? '').trim();

    if (text.isEmpty) {
      return null;
    }

    final DateTime? birthday = DateTime.tryParse(text);

    if (birthday == null || birthday.isBefore(DateTime(1900))) {
      return 'Enter a valid birthday.';
    }

    return null;
  }

  String? _postalValidator(String? value) {
    final String text = (value ?? '').trim();

    if (!RegExp(r'^\d{4}$').hasMatch(text)) {
      return 'Postal code must be 4 digits.';
    }

    return null;
  }

  String? _businessNameValidator(String? value) {
    final String text = (value ?? '').trim();

    if (text.isEmpty) {
      return 'Required.';
    }

    if (text.length > 180) {
      return 'Maximum of 180 characters.';
    }

    if (!RegExp(r"^[A-Za-z0-9À-ÖØ-öø-ÿÑñ\s.&'()\-]+$").hasMatch(text)) {
      return 'Enter a valid business name.';
    }

    return null;
  }

  String? _tinValidator(String? value) {
    final String text = (value ?? '').trim();

    if (!RegExp(r'^\d{3}-\d{3}-\d{3}-\d{3}$').hasMatch(text)) {
      return 'Use 000-000-000-000.';
    }

    return null;
  }

  String? _secValidator(String? value) {
    final String text = (value ?? '').trim();

    if (!RegExp(r'^[A-Za-z]{2}\d{9}$').hasMatch(text)) {
      return 'Use format CS202012345.';
    }

    return null;
  }

  String? _positionValidator(String? value) {
    final String text = (value ?? '').trim();

    if (text.isEmpty) {
      return 'Required.';
    }

    if (text.length > 120) {
      return 'Maximum of 120 characters.';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    final String password = value ?? '';

    if (password.length < 8) {
      return 'Use at least 8 characters.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[a-z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password) ||
        !RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Use uppercase, lowercase, number, and symbol.';
    }

    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if ((value ?? '') != _password.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  void _message(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  InputDecoration _decoration(
    String label, {
    IconData? icon,
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon, size: 19),
      suffixIcon: suffix,
      labelStyle: const TextStyle(color: _muted, fontSize: 12),
      hintStyle: const TextStyle(color: Color(0xFF71717A), fontSize: 11),
      filled: true,
      fillColor: _field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _gold, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFC95C5C)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFC95C5C), width: 1.3),
      ),
    );
  }

  Widget _section({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: _muted,
              fontSize: 10,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _gap([double height = 12]) => SizedBox(height: height);

  Widget _profilePicker() {
    return InkWell(
      onTap: _pickProfileImage,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _field,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _profileImage == null ? _border : _success,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF2B2619),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                _profileImage == null
                    ? Icons.add_a_photo_outlined
                    : Icons.check_rounded,
                color: _profileImage == null ? _gold : _success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Profile Photo *',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _profileImage?.name ?? 'JPG, JPEG, PNG or WEBP • up to 5 MB',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 9),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _muted),
          ],
        ),
      ),
    );
  }

  Widget _documentTile({
    required String title,
    required String subtitle,
    required PlatformFile? file,
    required VoidCallback onTap,
  }) {
    final bool selected = file != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: _field,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _success : _border),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF1D3024)
                    : const Color(0xFF2B2619),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                selected
                    ? Icons.check_circle_outline_rounded
                    : Icons.upload_file_outlined,
                color: selected ? _success : _gold,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    selected ? file.name : subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 8.5),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _muted, size: 19),
          ],
        ),
      ),
    );
  }

  Widget _stepIndicator() {
    return Row(
      children: List<Widget>.generate(
        _stepTitles.length,
        (int index) {
          final bool active = index == _step;
          final bool complete = index < _step;

          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(
                right: index == _stepTitles.length - 1 ? 0 : 6,
              ),
              decoration: BoxDecoration(
                color: active || complete ? _gold : _border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _personalStep() {
    return Column(
      children: <Widget>[
        _section(
          title: 'Personal Information',
          subtitle:
              'Use the same contact-person information that will appear in your Logistics application.',
          children: <Widget>[
            _profilePicker(),
            _gap(),
            TextFormField(
              controller: _firstName,
              validator: _nameValidator,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(
                'First Name *',
                icon: Icons.person_outline_rounded,
              ),
            ),
            _gap(),
            TextFormField(
              controller: _lastName,
              validator: _nameValidator,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(
                'Last Name *',
                icon: Icons.person_outline_rounded,
              ),
            ),
            _gap(),
            TextFormField(
              controller: _middleInitial,
              validator: _middleInitialValidator,
              maxLength: 1,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(
                'Middle Initial',
                icon: Icons.badge_outlined,
              ).copyWith(counterText: ''),
            ),
            _gap(),
            DropdownButtonFormField<String>(
              initialValue: _sex,
              dropdownColor: _surface,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(
                'Sex',
                icon: Icons.wc_outlined,
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'Male', child: Text('Male')),
                DropdownMenuItem<String>(value: 'Female', child: Text('Female')),
              ],
              onChanged: (String? value) {
                setState(() {
                  _sex = value;
                });
              },
            ),
            _gap(),
            TextFormField(
              controller: _birthday,
              validator: _birthdayValidator,
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              onTap: _pickBirthday,
              decoration: _decoration(
                'Birthday',
                hint: 'Optional',
                icon: Icons.cake_outlined,
                suffix: IconButton(
                  onPressed: _pickBirthday,
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
              ),
            ),
            _gap(),
            TextFormField(
              controller: _email,
              validator: _emailValidator,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(
                'Email Address *',
                icon: Icons.mail_outline_rounded,
              ),
            ),
            _gap(),
            TextFormField(
              controller: _contact,
              validator: _phoneValidator,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(
                'Contact Number *',
                hint: '09XXXXXXXXX',
                icon: Icons.phone_outlined,
              ),
            ),
          ],
        ),
        _gap(14),
        _section(
          title: 'Registered Address',
          subtitle:
              'The address hierarchy is loaded from the same SARI address API used by the other mobile registrations.',
          children: <Widget>[
            SariAddressPicker(
              region: _region,
              regionCode: _regionCode,
              province: _province,
              provinceCode: _provinceCode,
              municipality: _municipality,
              municipalityCode: _municipalityCode,
              barangay: _barangay,
              barangayCode: _barangayCode,
              accent: _gold,
            ),
            _gap(),
            TextFormField(
              controller: _street,
              validator: _required,
              maxLength: 500,
              maxLines: 2,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(
                'Street / House / Building *',
                icon: Icons.home_work_outlined,
              ).copyWith(counterText: ''),
            ),
            _gap(),
            TextFormField(
              controller: _postalCode,
              validator: _postalValidator,
              keyboardType: TextInputType.number,
              maxLength: 4,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(
                'Postal Code *',
                hint: '0000',
                icon: Icons.markunread_mailbox_outlined,
              ).copyWith(counterText: ''),
            ),
          ],
        ),
      ],
    );
  }

  Widget _businessStep() {
    return _section(
      title: 'Logistics / Sorting Center',
      subtitle:
          'These fields match the current SARI web Logistics registration requirements.',
      children: <Widget>[
        TextFormField(
          controller: _businessName,
          validator: _businessNameValidator,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white),
          decoration: _decoration(
            'Business Name *',
            icon: Icons.warehouse_outlined,
          ),
        ),
        _gap(),
        TextFormField(
          controller: _tin,
          validator: _tinValidator,
          maxLength: 15,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
            LengthLimitingTextInputFormatter(15),
          ],
          style: const TextStyle(color: Colors.white),
          decoration: _decoration(
            'TIN *',
            hint: '000-000-000-000',
            icon: Icons.receipt_long_outlined,
          ).copyWith(counterText: ''),
        ),
        _gap(),
        TextFormField(
          controller: _secRegistrationNo,
          validator: _secValidator,
          maxLength: 11,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            LengthLimitingTextInputFormatter(11),
          ],
          style: const TextStyle(color: Colors.white),
          decoration: _decoration(
            'SEC Registration No. *',
            hint: 'CS202012345',
            icon: Icons.verified_user_outlined,
          ).copyWith(counterText: ''),
        ),
        _gap(),
        TextFormField(
          controller: _position,
          validator: _positionValidator,
          maxLength: 120,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white),
          decoration: _decoration(
            'Contact Person Position *',
            hint: 'Operations Manager',
            icon: Icons.work_outline_rounded,
          ).copyWith(counterText: ''),
        ),
        _gap(18),
        const Text(
          'Service Areas *',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select every region your Logistics provider currently serves.',
          style: TextStyle(color: _muted, fontSize: 9, height: 1.4),
        ),
        const SizedBox(height: 11),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: _serviceAreaOptions.map((String area) {
            final bool selected = _serviceAreas.contains(area);

            return FilterChip(
              label: Text(area),
              selected: selected,
              onSelected: (bool value) {
                setState(() {
                  if (value) {
                    _serviceAreas.add(area);
                  } else {
                    _serviceAreas.remove(area);
                  }
                });
              },
              showCheckmark: true,
              selectedColor: const Color(0xFF3B321D),
              backgroundColor: _field,
              side: BorderSide(color: selected ? _gold : _border),
              checkmarkColor: _gold,
              labelStyle: TextStyle(
                color: selected ? const Color(0xFFFFD36B) : _muted,
                fontSize: 9,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _documentsStep() {
    return _section(
      title: 'Verification Documents',
      subtitle:
          'Accepted: JPG, JPEG, PNG or PDF. Each document must be 5 MB or smaller.',
      children: <Widget>[
        _documentTile(
          title: 'Valid ID *',
          subtitle: 'Government-issued ID • JPG, PNG or PDF',
          file: _idDocument,
          onTap: () => _pickDocument('id'),
        ),
        _gap(10),
        _documentTile(
          title: 'Business Permit *',
          subtitle: 'Current business permit • JPG, PNG or PDF',
          file: _businessPermit,
          onTap: () => _pickDocument('permit'),
        ),
        _gap(10),
        _documentTile(
          title: 'BIR Form 2303 *',
          subtitle: 'Certificate of Registration • JPG, PNG or PDF',
          file: _birDocument,
          onTap: () => _pickDocument('bir'),
        ),
        _gap(10),
        _documentTile(
          title: 'SEC Certificate *',
          subtitle:
              'Required by the current Laravel validation contract • JPG, PNG or PDF',
          file: _secDocument,
          onTap: () => _pickDocument('sec'),
        ),
      ],
    );
  }

  Widget _securityStep() {
    final String password = _password.text;

    return Column(
      children: <Widget>[
        _section(
          title: 'Login Credentials',
          subtitle:
              'Create the password that will be used for your SARI Logistics account after approval.',
          children: <Widget>[
            TextFormField(
              controller: _password,
              validator: _passwordValidator,
              obscureText: _hidePassword,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(
                'Password *',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            _gap(10),
            _passwordRule('At least 8 characters', password.length >= 8),
            _passwordRule('Uppercase and lowercase letters',
                RegExp(r'[A-Z]').hasMatch(password) &&
                    RegExp(r'[a-z]').hasMatch(password)),
            _passwordRule('At least one number', RegExp(r'\d').hasMatch(password)),
            _passwordRule(
              'At least one symbol',
              RegExp(r'[^A-Za-z0-9]').hasMatch(password),
            ),
            _gap(),
            TextFormField(
              controller: _passwordConfirmation,
              validator: _confirmPasswordValidator,
              obscureText: _hideConfirmation,
              autocorrect: false,
              enableSuggestions: false,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(
                'Confirm Password *',
                icon: Icons.lock_reset_rounded,
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _hideConfirmation = !_hideConfirmation;
                    });
                  },
                  icon: Icon(
                    _hideConfirmation
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
          ],
        ),
        _gap(14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
          ),
          child: CheckboxListTile(
            value: _terms,
            onChanged: (bool? value) {
              setState(() {
                _terms = value ?? false;
              });
            },
            activeColor: _gold,
            checkColor: Colors.black,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'I agree to the SARI Terms and Privacy Policy.',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
            subtitle: const Text(
              'Your application remains subject to SARI administrator review and approval.',
              style: TextStyle(color: _muted, fontSize: 8.5, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordRule(String label, bool passed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: <Widget>[
          Icon(
            passed ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 14,
            color: passed ? _success : _muted,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: passed ? _success : _muted,
                fontSize: 8.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentStep() {
    switch (_step) {
      case 0:
        return _personalStep();
      case 1:
        return _businessStep();
      case 2:
        return _documentsStep();
      default:
        return _securityStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -.85),
                radius: 1.2,
                colors: <Color>[
                  Color(0xFF353128),
                  Color(0xFF171719),
                  Color(0xFF09090B),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: _back,
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Logistics Registration',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 13, 16, 28),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 620),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(17),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B1A17),
                                  borderRadius: BorderRadius.circular(21),
                                  border: Border.all(
                                    color: _gold.withValues(alpha: .28),
                                  ),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 48,
                                      height: 48,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF302919),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.hub_outlined,
                                        color: _gold,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'SARI LOGISTICS',
                                            style: TextStyle(
                                              color: _gold,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Provider Application',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          SizedBox(height: 3),
                                          Text(
                                            'Same required registration fields as the current SARI web application.',
                                            style: TextStyle(
                                              color: _muted,
                                              fontSize: 9,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _stepIndicator(),
                              const SizedBox(height: 9),
                              Text(
                                'Step ${_step + 1} of ${_stepTitles.length}  •  ${_stepTitles[_step]}',
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 14),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: KeyedSubtree(
                                  key: ValueKey<int>(_step),
                                  child: _currentStep(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: <Widget>[
                                  if (_step > 0) ...[
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _busy ? null : _back,
                                        icon: const Icon(Icons.arrow_back_rounded),
                                        label: const Text('Back'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(color: _border),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(13),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 9),
                                  ],
                                  Expanded(
                                    flex: _step > 0 ? 1 : 2,
                                    child: FilledButton.icon(
                                      onPressed: _busy ? null : _next,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: _gold,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(13),
                                        ),
                                      ),
                                      icon: _busy
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.black,
                                              ),
                                            )
                                          : Icon(
                                              _step == _stepTitles.length - 1
                                                  ? Icons.fact_check_outlined
                                                  : Icons.arrow_forward_rounded,
                                              size: 18,
                                            ),
                                      label: Text(
                                        _step == _stepTitles.length - 1
                                            ? 'Submit Application'
                                            : 'Continue',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Your application will be submitted to SARI for email verification and Admin approval.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF777780),
                                  fontSize: 7.5,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}