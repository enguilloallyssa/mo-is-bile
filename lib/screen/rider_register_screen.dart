import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/registration_api.dart';
import '../widgets/sari_address_picker.dart';
import 'registration_pending_screen.dart';
import 'rider_logistics_screen.dart';

class RiderRegisterScreen extends StatefulWidget {
  final LogisticsProvider provider;

  const RiderRegisterScreen({
    super.key,
    required this.provider,
  });

  @override
  State<RiderRegisterScreen> createState() =>
      _RiderRegisterScreenState();
}

class _RiderRegisterScreenState
    extends State<RiderRegisterScreen> {
  static const Color _background = Color(0xFF0A0A0C);
  static const Color _surface = Color(0xFF18181C);
  static const Color _fieldColor = Color(0xFF222226);
  static const Color _border = Color(0xFF37373D);
  static const Color _gold = Color(0xFFD4A62A);
  static const Color _muted = Color(0xFFAAAAB2);

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

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
  final TextEditingController _plateNumberController =
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

  String? _sex;
  String? _vehicleType;

  PlatformFile? _profileImage;
  PlatformFile? _idDocument;
  PlatformFile? _orcrDocument;

  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _isSendingOtp = false;
  bool _isSubmitting = false;
  bool _showOtpStep = false;

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
      _plateNumberController,
      _passwordController,
      _confirmPasswordController,
      ..._otpControllers,
    ];

    for (final TextEditingController controller
        in controllers) {
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

  int? _calculateAge() {
    final DateTime? birthDate = DateTime.tryParse(
      _birthdayController.text,
    );

    if (birthDate == null) {
      return null;
    }

    final DateTime today = DateTime.now();

    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month &&
            today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  Future<PlatformFile?> _pickFile({
    required List<String> extensions,
  }) async {
    final FilePickerResult? result =
        await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final PlatformFile file = result.files.single;

    if (file.path == null) {
      _showMessage(
        'The selected file cannot be read. '
        'Please choose another file.',
      );

      return null;
    }

    return file;
  }

  Future<void> _pickProfileImage() async {
    final PlatformFile? file = await _pickFile(
      extensions: const <String>[
        'jpg',
        'jpeg',
        'png',
      ],
    );

    if (file != null) {
      setState(() {
        _profileImage = file;
      });
    }
  }

  Future<void> _pickIdDocument() async {
    final PlatformFile? file = await _pickFile(
      extensions: const <String>[
        'jpg',
        'jpeg',
        'png',
        'pdf',
      ],
    );

    if (file != null) {
      setState(() {
        _idDocument = file;
      });
    }
  }

  Future<void> _pickOrcrDocument() async {
    final PlatformFile? file = await _pickFile(
      extensions: const <String>[
        'jpg',
        'jpeg',
        'png',
        'pdf',
      ],
    );

    if (file != null) {
      setState(() {
        _orcrDocument = file;
      });
    }
  }

  bool _validateApplication() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return false;
    }

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

    if (_vehicleType == null) {
      _showMessage(
        'Please select your delivery vehicle.',
      );
      return false;
    }

    if (_profileImage == null) {
      _showMessage(
        'Please select a profile picture.',
      );
      return false;
    }

    if (_idDocument == null) {
      _showMessage(
        'Please select your valid ID or driver\'s license.',
      );
      return false;
    }

    if (_orcrDocument == null) {
      _showMessage(
        'Please select your OR/CR document.',
      );
      return false;
    }

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
        'Please accept the Terms of Service '
        'and Privacy Policy.',
      );
      return false;
    }

    return true;
  }

  Future<void> _sendOtp({
    bool openOtpStep = true,
  }) async {
    if (_isSendingOtp) {
      return;
    }

    if (openOtpStep && !_validateApplication()) {
      return;
    }

    setState(() {
      _isSendingOtp = true;
    });

    try {
      final String message =
          await RegistrationApi.instance.sendRiderOtp(
        logisticsId: widget.provider.id,
        email:
            _emailController.text.trim().toLowerCase(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (openOtpStep) {
          _showOtpStep = true;
        }
      });

      _showMessage(message);
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
        'Cannot connect to the SARI server. '
        'Check the Laravel server and SARI_API_URL.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingOtp = false;
        });
      }
    }
  }

  Future<void> _verifyAndSubmit() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting) {
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

    if (_profileImage == null ||
        _idDocument == null ||
        _orcrDocument == null) {
      _showMessage(
        'One or more required files are missing.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await RegistrationApi.instance.verifyRiderOtp(
        logisticsId: widget.provider.id,
        email:
            _emailController.text.trim().toLowerCase(),
        otp: otp,
      );

      await RegistrationApi.instance.registerRider(
        logisticsId: widget.provider.id,
        fields: _registrationFields(),
        profileImage: _profileImage!,
        idDocument: _idDocument!,
        orcrDocument: _orcrDocument!,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return RegistrationPendingScreen(
              role: 'rider',
              email: _emailController.text
                  .trim()
                  .toLowerCase(),
              reviewerName: widget.provider.name,
              previewMode: false,
            );
          },
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
        'Rider application could not be submitted. '
        'Check the Laravel server connection.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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
      'contact_number': _contactController.text.trim(),
      'birthday': _birthdayController.text.trim(),
      'province': _provinceController.text.trim(),
      'municipality':
          _municipalityController.text.trim(),
      'barangay': _barangayController.text.trim(),
      'street_address': _streetController.text.trim(),
      'vehicle_type': _vehicleType ?? '',
      'plate_number':
          _plateNumberController.text.trim().toUpperCase(),
      'password': _passwordController.text,
      'password_confirmation':
          _confirmPasswordController.text,
    };
  }

  void _backFromOtp() {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _showOtpStep = false;

      for (final TextEditingController controller
          in _otpControllers) {
        controller.clear();
      }
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
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: _isSubmitting
              ? null
              : _showOtpStep
                  ? _backFromOtp
                  : () {
                      Navigator.pop(context);
                    },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: Text(
          _showOtpStep
              ? 'Email Verification'
              : 'Rider Application',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _showOtpStep
            ? _buildOtpPage()
            : _buildApplicationPage(),
      ),
    );
  }

  Widget _buildApplicationPage() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          30,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 680,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildProviderSummary(),
                const SizedBox(height: 15),
                _buildFormCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF292820),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: _gold,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'APPLYING TO',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.provider.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.provider.location,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '● ACTIVE',
            style: TextStyle(
              color: Color(0xFF79C58E),
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    final String password = _passwordController.text;

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 28,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          _sectionTitle(
            eyebrow: '01 · PERSONAL',
            title: 'Personal information',
          ),
          _input(
            controller: _lastNameController,
            label: 'Last name *',
            hint: 'Dela Cruz',
          ),
          _input(
            controller: _firstNameController,
            label: 'First name *',
            hint: 'Juan',
          ),
          _input(
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
          _input(
            controller: _emailController,
            label: 'Email address *',
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: (String? value) {
              final String text = value?.trim() ?? '';

              if (!RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              ).hasMatch(text)) {
                return 'Enter a valid email address.';
              }

              return null;
            },
          ),
          _input(
            controller: _contactController,
            label: 'Contact number *',
            hint: '09XXXXXXXXX',
            keyboardType: TextInputType.phone,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: (String? value) {
              if (!RegExp(r'^09\d{9}$')
                  .hasMatch(value?.trim() ?? '')) {
                return 'Use 11 digits beginning with 09.';
              }

              return null;
            },
          ),
          _label('Birthday *'),
          TextFormField(
            controller: _birthdayController,
            readOnly: true,
            onTap: _pickBirthday,
            style: const TextStyle(
              color: Colors.white,
            ),
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
          const SizedBox(height: 16),
          _uploadTile(
            label: 'Profile picture *',
            file: _profileImage,
            onTap: _pickProfileImage,
          ),
          const SizedBox(height: 27),
          _sectionTitle(
            eyebrow: '02 · ADDRESS',
            title: 'Home address',
          ),
          SariAddressPicker(
            province: _provinceController,
            municipality: _municipalityController,
            barangay: _barangayController,
          ),
          _input(
            controller: _streetController,
            label: 'Street and house number *',
            hint:
                'House number, street, subdivision, landmark',
            maxLines: 3,
          ),
          const SizedBox(height: 13),
          _sectionTitle(
            eyebrow: '03 · VEHICLE',
            title: 'Delivery requirements',
          ),
          _label('Vehicle type *'),
          DropdownButtonFormField<String>(
            value: _vehicleType,
            dropdownColor: _fieldColor,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: _decoration(
              'Select delivery vehicle',
            ),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: 'Motorcycle',
                child: Text('Motorcycle'),
              ),
              DropdownMenuItem<String>(
                value: 'Bicycle',
                child: Text('Bicycle'),
              ),
              DropdownMenuItem<String>(
                value: 'Car',
                child: Text('Car'),
              ),
              DropdownMenuItem<String>(
                value: 'Van',
                child: Text('Van'),
              ),
              DropdownMenuItem<String>(
                value: 'Truck',
                child: Text('Truck'),
              ),
            ],
            onChanged: (String? value) {
              setState(() {
                _vehicleType = value;
              });
            },
          ),
          const SizedBox(height: 15),
          _input(
            controller: _plateNumberController,
            label: 'Plate number *',
            hint: 'ABC 1234',
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                RegExp(r'[A-Za-z0-9 -]'),
              ),
            ],
          ),
          _uploadTile(
            label: 'Valid ID or driver\'s license *',
            file: _idDocument,
            onTap: _pickIdDocument,
          ),
          const SizedBox(height: 13),
          _uploadTile(
            label: 'OR/CR document *',
            file: _orcrDocument,
            onTap: _pickOrcrDocument,
          ),
          const SizedBox(height: 27),
          _sectionTitle(
            eyebrow: '04 · ACCOUNT',
            title: 'Create login credentials',
          ),
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
          const SizedBox(height: 17),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: _fieldColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _border,
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  Checkbox(
                    value: _acceptTerms,
                    activeColor: _gold,
                    checkColor:
                        const Color(0xFF151515),
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
                        'I agree to the Terms of Service '
                        'and Privacy Policy.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 10.5,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 51,
            child: ElevatedButton(
              onPressed: _isSendingOtp
                  ? null
                  : () {
                      _sendOtp();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor:
                    const Color(0xFF151515),
                disabledBackgroundColor:
                    const Color(0xFF5C5232),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              child: _isSendingOtp
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Continue to email verification',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        16,
        25,
        16,
        30,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
          child: Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(23),
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
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF292820),
                      borderRadius:
                          BorderRadius.circular(21),
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      color: _gold,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
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
                  'Enter the 6-digit code sent to '
                  '${_emailController.text.trim()}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 27),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    6,
                    (int index) {
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 3,
                        ),
                        child: SizedBox(
                          width: 42,
                          height: 55,
                          child: TextField(
                            controller:
                                _otpControllers[index],
                            enabled: !_isSubmitting,
                            textAlign: TextAlign.center,
                            keyboardType:
                                TextInputType.number,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                            inputFormatters:
                                <TextInputFormatter>[
                              FilteringTextInputFormatter
                                  .digitsOnly,
                              LengthLimitingTextInputFormatter(
                                1,
                              ),
                            ],
                            onChanged: (String value) {
                              if (value.isNotEmpty &&
                                  index < 5) {
                                FocusScope.of(context)
                                    .nextFocus();
                              }

                              if (value.isEmpty &&
                                  index > 0) {
                                FocusScope.of(context)
                                    .previousFocus();
                              }
                            },
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: _fieldColor,
                              contentPadding:
                                  EdgeInsets.zero,
                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  11,
                                ),
                                borderSide:
                                    const BorderSide(
                                  color: _border,
                                ),
                              ),
                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  11,
                                ),
                                borderSide:
                                    const BorderSide(
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
                    onPressed: _isSubmitting
                        ? null
                        : _verifyAndSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor:
                          const Color(0xFF151515),
                      disabledBackgroundColor:
                          const Color(0xFF5C5232),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verify and submit application',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed:
                      _isSendingOtp || _isSubmitting
                          ? null
                          : () {
                              _sendOtp(
                                openOtpStep: false,
                              );
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
                  onPressed:
                      _isSubmitting ? null : _backFromOtp,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    size: 17,
                  ),
                  label: const Text(
                    'Change application details',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle({
    required String eyebrow,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            eyebrow,
            style: const TextStyle(
              color: _gold,
              fontSize: 8.5,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _input({
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

  Widget _uploadTile({
    required String label,
    required PlatformFile? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _fieldColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: file == null
                ? _border
                : const Color(0xFF5B9870),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              file == null
                  ? Icons.upload_file_outlined
                  : Icons.check_circle_outline_rounded,
              color: file == null
                  ? _gold
                  : const Color(0xFF79C58E),
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file?.name ?? 'Tap to select file',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: file == null
                          ? _muted
                          : const Color(0xFF91D7A4),
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
            color: passed
                ? const Color(0xFF72C88B)
                : const Color(0xFF67676F),
            size: 16,
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
}