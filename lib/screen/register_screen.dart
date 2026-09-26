import 'package:flutter/material.dart';

import 'account_registration_screen.dart';
import 'rider_logistics_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color sariYellow = Color(0xFFD48F08);
  static const Color sariYellowDark = Color(0xFFBD7D05);
  static const Color sariBackground = Color(0xFFF7F4EE);
  static const Color sariText = Color(0xFF1F1B16);
  static const Color sariMuted = Color(0xFF81786C);
  static const Color sariBorder = Color(0xFFE4DDD3);

  String? selectedRole;

  final List<_RegistrationRole> roles = const [
    _RegistrationRole(
      keyName: 'buyer',
      title: 'Buyer',
      description: 'Shop, track orders, and manage purchases.',
      icon: Icons.person_outline,
    ),
    _RegistrationRole(
      keyName: 'logistics',
      title: 'Logistics',
      description: 'Operate a Logistics team and manage Riders.',
      icon: Icons.warehouse_outlined,
    ),
    _RegistrationRole(
      keyName: 'rider',
      title: 'Rider',
      description:
          'Choose a Logistics provider first, then apply directly to their team.',
      icon: Icons.delivery_dining_outlined,
    ),
  ];

  void _continueRegistration() {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account type first.')),
      );
      return;
    }

    if (selectedRole == 'rider') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const RiderLogisticsScreen(),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountRegistrationScreen(
          role: selectedRole!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sariBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/login-bg.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: sariBackground),
              ),
            ),
            Positioned.fill(
              child: ColoredBox(
                color: Colors.white.withOpacity(.87),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 26),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Back',
                          ),
                          const Expanded(
                            child: Text(
                              'Create your SARI account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: sariText,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.fromLTRB(18, 21, 18, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: sariBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.055),
                              blurRadius: 22,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'GET STARTED',
                              style: TextStyle(
                                color: sariYellow,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.35,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Choose your account type',
                              style: TextStyle(
                                color: sariText,
                                fontSize: 24,
                                height: 1.15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.45,
                              ),
                            ),
                            const SizedBox(height: 7),
                            const Text(
                              'Mobile registration is available for Buyers, Logistics teams, and Riders.',
                              style: TextStyle(
                                color: sariMuted,
                                fontSize: 11.5,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ...roles.map(_buildRoleOption),
                            if (selectedRole != null) ...[
                              const SizedBox(height: 5),
                              _buildSelectedRolePreview(),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 49,
                              child: ElevatedButton(
                                onPressed: _continueRegistration,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: sariYellow,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 7),
                                    Icon(Icons.arrow_forward, size: 17),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(
                              color: sariMuted,
                              fontSize: 11.5,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                color: Color(0xFFA96F06),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(_RegistrationRole role) {
    final selected = selectedRole == role.keyName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: () => setState(() => selectedRole = role.keyName),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFFCF6) : Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: selected ? sariYellow : sariBorder,
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 23,
                  height: 23,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? sariYellow : Colors.white,
                    border: Border.all(
                      color: selected
                          ? sariYellow
                          : const Color(0xFFC9C2B8),
                      width: 1.4,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: role.keyName == 'rider'
                        ? const Color(0xFFF5F7F6)
                        : const Color(0xFFFBF8F3),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    role.icon,
                    size: 21,
                    color: role.keyName == 'rider'
                        ? const Color(0xFF387B5B)
                        : const Color(0xFFB47A0D),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.title,
                        style: const TextStyle(
                          color: sariText,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role.description,
                        style: const TextStyle(
                          color: sariMuted,
                          fontSize: 10.2,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                Icon(
                  Icons.chevron_right,
                  color: selected
                      ? sariYellowDark
                      : const Color(0xFF9A9186),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedRolePreview() {
    final role = roles.firstWhere((item) => item.keyName == selectedRole);

    return Container(
      padding: const EdgeInsets.only(top: 14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFECE7DF)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 33,
            height: 33,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFAF0),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFEADFC9)),
            ),
            child: Icon(
              role.icon,
              color: const Color(0xFFB97805),
              size: 16,
            ),
          ),
          const SizedBox(width: 9),
          const Text(
            'SELECTED ROLE',
            style: TextStyle(
              color: Color(0xFFA49B90),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: .9,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              role.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF38332D),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: sariYellow,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _RegistrationRole {
  final String keyName;
  final String title;
  final String description;
  final IconData icon;

  const _RegistrationRole({
    required this.keyName,
    required this.title,
    required this.description,
    required this.icon,
  });
}
