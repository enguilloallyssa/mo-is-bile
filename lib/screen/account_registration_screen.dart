import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/registration_api.dart';
import '../widgets/sari_address_picker.dart';
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
  static const Color _background = Color(0xFF0A0A0C);
  static const Color _surface = Color(0xFF18181C);
  static const Color _fieldColor = Color(0xFF222226);
  static const Color _border = Color(0xFF37373D);
  static const Color _gold = Color(0xFFD4A62A);
  static const Color _muted = Color(0xFFAAAAB2);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _lastNameController =
      TextEditingController();
  final TextEditingController _firstNameController =
      TextEditingController();
  final TextEditingController _middleInitialController =
      TextEditingController();
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _contactController =
      TextEditingController();
  final TextEditingController _birthdayController =
      TextEditingController();
  final TextEditingController _provinceController =
      TextEditingController();
  final TextEditingController _municipalityController =
      TextEditingController();
  final TextEditingController _barangayController =
      TextEditingController();
  final TextEditingController _streetController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final List<TextEditingController> _otpControllers =
      List<TextEditingController>.generate(
    6,
    (int index) => TextEditingController(),
  );

  int _step = 0;
  String? _sex;
  PlatformFile? _profileImage;

  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _isSendingOtp = false;
  bool _isVerifying = false;
  bool _otpSent = false;

  @override
  void dispose() {
    final List<TextEditingController> controllers =
        <TextEditingController>[
      _lastNameController,
      _firstNameController,
      _middleInitialController,
      _emailController,
      _contactController,
      _birthdayController,
      _provinceController,
      _municipalityController,
      _barangayController,
      _streetController,
      _passwordController,
      _confirmPasswordController,
      ..._otpControllers,
    ];

    for (final TextEditingController controller in controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final DateTime today = DateTime.now();
    final DateTime latestBirthday = DateTime(
      today.year - 18,
      today.month,
      today.day,
    );

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime(
        latestBirthday.year - 5,
        latestBirthday.month,
        latestBirthday.day,
      ),
      firstDate: DateTime(1900),
      lastDate: latestBirthday,
    );

    if (selected == null) {
      return;
    }

    _birthdayController.text =
        '${selected.year.toString().padLeft(4, '0')}-'
        '${selected.month.toString().padLeft(2, '0')}-'
        '${selected.day.toString().padLeft(2, '0')}';

    setState(() {});
  }

  Future<void> _pickProfileImage() async {
    final FilePickerResult? result =
    await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>[
        'jpg',
        'jpeg',
        'png',
      ],
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final PlatformFile file = result.files.single;

    if (file.path == null) {
      _showMessage(
        'The selected photo cannot be read. Please choose another file.',
      );
      return;
    }

    setState(() {
      _profileImage = file;
    });
  }

  int? _calculateAge() {
    final DateTime? birthDate = DateTime.tryParse(
      _birthdayController.text,
    );

    if (birthDate == null) {
      return null;
    }

    final DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    final bool birthdayNotReached =
        today.month < birthDate.month ||
            (today.month == birthDate.month &&
                today.day < birthDate.day);

    if (birthdayNotReached) {
      age--;
    }

    return age;
  }

  bool _validateDetails() {
    final bool valid =
        _formKey.currentState?.validate() ?? false;

    if (_sex == null) {
      _showMessage('Please select your sex.');
      return false;
    }

    if ((_calculateAge() ?? 0) < 18) {
      _showMessage(
        'You must be at least 18 years old.',
      );
      return false;
    }

    return valid;
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();

    if (_step == 0) {
      if (!_validateDetails()) {
        return;
      }

      setState(() {
        _step = 1;
      });

      return;
    }

    if (_step == 1) {
      if (_profileImage == null) {
        _showMessage(
          'Please select a profile picture.',
        );
        return;
      }

      setState(() {
        _step = 2;
      });

      return;
    }

    if (_step == 2) {
      if (!_validateCredentials()) {
        return;
      }

      await _sendOtp(moveToOtpStep: true);
    }
  }

  bool _validateCredentials() {
    final String password = _passwordController.text;

    if (password.length < 8) {
      _showMessage(
        'Password must contain at least 8 characters.',
      );
      return false;
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      _showMessage(
        'Password must contain an uppercase letter.',
      );
      return false;
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      _showMessage(
        'Password must contain a lowercase letter.',
      );
      return false;
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      _showMessage(
        'Password must contain a number.',
      );
      return false;
    }

    if (_passwordController.text !=
        _confirmPasswordController.text) {
      _showMessage('Passwords do not match.');
      return false;
    }

    if (!_acceptTerms) {
      _showMessage(
        'Please accept the Terms of Service and Privacy Policy.',
      );
      return false;
    }

    return true;
  }

  Future<void> _sendOtp({
    required bool moveToOtpStep,
  }) async {
    if (_isSendingOtp || _isVerifying) return;
    FocusScope.of(context).unfocus();

    if (moveToOtpStep && _profileImage == null) {
      _showMessage('Please select a profile picture first.');
      return;
    }

    setState(() => _isSendingOtp = true);

    try {
      if (moveToOtpStep) {
        // Laravel needs the unverified application in its database
        // before the OTP send/verify actions can work.
        await RegistrationApi.instance.registerBuyer(
          fields: _registrationFields(),
          profileImage: _profileImage!,
        );
      } else {
        // Resend requires the application created above.
        await RegistrationApi.instance.sendOtp(
          email: _emailController.text.trim().toLowerCase(),
          role: 'buyer',
        );
      }

      if (!mounted) return;
      setState(() {
        _otpSent = true;
        if (moveToOtpStep) _step = 3;
      });
      _showMessage(moveToOtpStep
          ? 'Registration saved. Check your email for the 6-digit code.'
          : 'Verification request processed. Check your email.');
    } on RegistrationApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (_) {
      if (mounted) {
        _showMessage('Could not contact SARI. Please check your connection.');
      }
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _verifyAndSubmit() async {
    FocusScope.of(context).unfocus();

    if (_isVerifying) {
      return;
    }

    final String otp = _otpControllers
        .map(
          (TextEditingController controller) =>
              controller.text,
        )
        .join();

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      _showMessage(
        'Enter the complete 6-digit verification code.',
      );
      return;
    }

    if (_profileImage == null) {
      _showMessage(
        'Please return and select a profile picture.',
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      await RegistrationApi.instance.verifyOtp(
        email: _emailController.text.trim().toLowerCase(),
        role: 'buyer',
        otp: otp,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              RegistrationPendingScreen(
            role: 'buyer',
            email:
                _emailController.text.trim().toLowerCase(),
            reviewerName: 'administrator',
            previewMode: false,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } on RegistrationApiException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Registration could not be completed. Check your Laravel server connection.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Map<String, String> _registrationFields() {
    return <String, String>{
      'last_name': _lastNameController.text.trim(),
      'first_name': _firstNameController.text.trim(),
      'middle_initial':
          _middleInitialController.text.trim(),
      'sex': _sex ?? '',
      'email':
          _emailController.text.trim().toLowerCase(),
      'contact_no': _contactController.text.trim(),
      'birthday': _birthdayController.text.trim(),
      'province': _provinceController.text.trim(),
      'municipality':
          _municipalityController.text.trim(),
      'barangay': _barangayController.text.trim(),
      'street_address': _streetController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation':
          _confirmPasswordController.text,
      'terms': _acceptTerms ? '1' : '0',
      'profile_image_selected': '1',
    };
  }

  void _back() {
    if (_isSendingOtp || _isVerifying) {
      return;
    }

    if (_step == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _step--;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF29292D),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    const List<String> titles = <String>[
      'Personal Information',
      'Profile Picture',
      'Login Credentials',
      'Email Verification',
    ];

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed:
              _isSendingOtp || _isVerifying ? null : _back,
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: const Text(
          'Buyer Registration',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            _ProgressHeader(
              currentStep: _step,
              totalSteps: 4,
              title: titles[_step],
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    18,
                    16,
                    30,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 620,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(
                          milliseconds: 180,
                        ),
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
    switch (_step) {
      case 0:
        return _detailsStep();

      case 1:
        return _profileStep();

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
      key: ValueKey<int>(_step),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 12),
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
        children: <Widget>[
          _heading(
            title: 'Personal details',
            description:
                'Use the same information shown on your official documents.',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 20),
          _field(
            controller: _lastNameController,
            label: 'Last name *',
            hint: 'Dela Cruz',
          ),
          _field(
            controller: _firstNameController,
            label: 'First name *',
            hint: 'Juan',
          ),
          _field(
            controller: _middleInitialController,
            label: 'Middle initial',
            hint: 'M',
            required: false,
            maxLength: 1,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                RegExp(r'[A-Za-z]'),
              ),
              LengthLimitingTextInputFormatter(1),
            ],
          ),
          _label('Sex *'),
          DropdownButtonFormField<String>(
            value: _sex,
            dropdownColor: _fieldColor,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: _decoration('Select sex'),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: 'Male',
                child: Text('Male'),
              ),
              DropdownMenuItem<String>(
                value: 'Female',
                child: Text('Female'),
              ),
            ],
            onChanged: (String? value) {
              setState(() {
                _sex = value;
              });
            },
          ),
          const SizedBox(height: 15),
          _field(
            controller: _emailController,
            label: 'Email address *',
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: (String? value) {
              final String email = value?.trim() ?? '';

              if (email.isEmpty) {
                return 'Email address is required.';
              }

              if (!RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              ).hasMatch(email)) {
                return 'Enter a valid email address.';
              }

              return null;
            },
          ),
          _field(
            controller: _contactController,
            label: 'Contact number *',
            hint: '09XXXXXXXXX',
            keyboardType: TextInputType.phone,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: (String? value) {
              final String contact = value?.trim() ?? '';

              if (!RegExp(r'^09\d{9}$').hasMatch(contact)) {
                return 'Use an 11-digit number starting with 09.';
              }

              return null;
            },
          ),
          _label('Birthday *'),
          TextFormField(
            controller: _birthdayController,
            readOnly: true,
            style: const TextStyle(
              color: Colors.white,
            ),
            onTap: _pickBirthday,
            decoration:
                _decoration('Select birthday').copyWith(
              suffixIcon: const Icon(
                Icons.calendar_month_outlined,
                color: _muted,
                size: 20,
              ),
            ),
            validator: (String? value) {
              if ((value ?? '').isEmpty) {
                return 'Birthday is required.';
              }

              return null;
            },
          ),
          const SizedBox(height: 8),
          Text(
            _calculateAge() == null
                ? 'You must be at least 18 years old.'
                : 'Age: ${_calculateAge()}',
            style: const TextStyle(
              color: _muted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 25),
          _heading(
            title: 'Address',
            description:
                'Enter your complete current Philippine address.',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 20),
          SariAddressPicker(
            province: _provinceController,
            municipality: _municipalityController,
            barangay: _barangayController,
          ),
          _field(
            controller: _streetController,
            label: 'Street and house number *',
            hint:
                'House number, street, subdivision, landmark',
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          _actions(
            nextLabel: 'Continue',
          ),
        ],
      ),
    );
  }

  Widget _profileStep() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _heading(
            title: 'Profile picture',
            description:
                'Choose a clear photo that will represent your Buyer account.',
            icon: Icons.photo_camera_outlined,
          ),
          const SizedBox(height: 25),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _pickProfileImage,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 210,
              ),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: _fieldColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _profileImage == null
                      ? _border
                      : const Color(0xFF69A97B),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _profileImage == null
                          ? const Color(0xFF2C2C31)
                          : const Color(0xFF213329),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _profileImage == null
                          ? Icons.add_a_photo_outlined
                          : Icons.check_rounded,
                      color: _profileImage == null
                          ? _gold
                          : const Color(0xFF79C58E),
                      size: 31,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _profileImage?.name ??
                        'Select profile picture',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'JPG, JPEG, or PNG',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          _actions(
            nextLabel: 'Continue',
          ),
        ],
      ),
    );
  }

  Widget _credentialsStep() {
    final String password = _passwordController.text;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _heading(
            title: 'Secure your account',
            description:
                'Create a strong password for your SARI account.',
            icon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 22),
          _label('Password *'),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(
              color: Colors.white,
            ),
            onChanged: (String value) {
              setState(() {});
            },
            decoration:
                _decoration('Enter your password').copyWith(
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword =
                        !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _muted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          _passwordRule(
            'At least 8 characters',
            password.length >= 8,
          ),
          _passwordRule(
            'One uppercase letter',
            RegExp(r'[A-Z]').hasMatch(password),
          ),
          _passwordRule(
            'One lowercase letter',
            RegExp(r'[a-z]').hasMatch(password),
          ),
          _passwordRule(
            'One number',
            RegExp(r'\d').hasMatch(password),
          ),
          const SizedBox(height: 17),
          _label('Confirm password *'),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmation,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration:
                _decoration('Repeat your password').copyWith(
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmation =
                        !_obscureConfirmation;
                  });
                },
                icon: Icon(
                  _obscureConfirmation
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _muted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _fieldColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _border,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Checkbox(
                    value: _acceptTerms,
                    activeColor: _gold,
                    checkColor: const Color(0xFF151515),
                    onChanged: (bool? value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy.',
                        style: TextStyle(
                          color: _muted,
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
          const SizedBox(height: 22),
          _actions(
            nextLabel: _isSendingOtp
                ? 'Sending code...'
                : 'Send verification code',
          ),
        ],
      ),
    );
  }

  Widget _otpStep() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF28271F),
                borderRadius: BorderRadius.circular(21),
                border: Border.all(
                  color: _gold.withOpacity(0.35),
                ),
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: _gold,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 19),
          const Text(
            'Verify your email',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _otpSent
                ? 'Enter the 6-digit code sent to ${_emailController.text.trim()}.'
                : 'Request a verification code for ${_emailController.text.trim()}.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 27),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              6,
              (int index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3),
                  child: SizedBox(
                    width: 42,
                    height: 55,
                    child: TextField(
                      controller: _otpControllers[index],
                      enabled: !_isVerifying,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      inputFormatters:
                          <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      onChanged: (String value) {
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(context).nextFocus();
                        }

                        if (value.isEmpty && index > 0) {
                          FocusScope.of(context)
                              .previousFocus();
                        }
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: _fieldColor,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(11),
                          borderSide: const BorderSide(
                            color: _border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(11),
                          borderSide: const BorderSide(
                            color: _gold,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 51,
            child: ElevatedButton(
              onPressed:
                  _isVerifying ? null : _verifyAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: const Color(0xFF151515),
                disabledBackgroundColor:
                    const Color(0xFF5C5232),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isVerifying
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Verify and submit',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _isSendingOtp || _isVerifying
                ? null
                : () {
                    _sendOtp(moveToOtpStep: false);
                  },
            child: Text(
              _isSendingOtp
                  ? 'Sending new code...'
                  : 'Resend verification code',
              style: const TextStyle(
                color: _gold,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _isVerifying ? null : _back,
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 17,
            ),
            label: const Text(
              'Change account details',
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: const Color(0xFF28271F),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: _gold,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: _muted,
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = true,
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          _label(label),
          TextFormField(
            controller: controller,
            maxLength: maxLength,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration:
                _decoration(hint).copyWith(counterText: ''),
            validator: validator ??
                (String? value) {
                  if (required &&
                      (value?.trim().isEmpty ?? true)) {
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
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
        color: Color(0xFF77777F),
        fontSize: 12,
      ),
      filled: true,
      fillColor: _fieldColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: _gold,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.4,
        ),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFFF8A8A),
      ),
    );
  }

  Widget _passwordRule(
    String text,
    bool passed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: <Widget>[
          Icon(
            passed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: passed
                ? const Color(0xFF72C88B)
                : const Color(0xFF67676F),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: passed
                  ? const Color(0xFF91D7A4)
                  : _muted,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions({
    required String nextLabel,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                _isSendingOtp || _isVerifying ? null : _back,
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 17,
            ),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              foregroundColor: Colors.white,
              side: const BorderSide(
                color: _border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: ElevatedButton(
            onPressed:
                _isSendingOtp || _isVerifying ? null : _next,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: _gold,
              foregroundColor: const Color(0xFF151515),
              disabledBackgroundColor:
                  const Color(0xFF5C5232),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: _isSendingOtp
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    nextLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
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
    const Color gold = Color(0xFFD4A62A);

    return Container(
      color: const Color(0xFF131316),
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        14,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: const TextStyle(
                  color: Color(0xFF929299),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List<Widget>.generate(
              totalSteps,
              (int index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(
                      right:
                          index == totalSteps - 1 ? 0 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: index <= currentStep
                          ? gold
                          : const Color(0xFF35353A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}