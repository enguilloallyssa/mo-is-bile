import 'package:flutter/material.dart';

class RegistrationPendingScreen extends StatelessWidget {
  final String role;
  final String email;
  final String reviewerName;
  final bool previewMode;

  const RegistrationPendingScreen({
    super.key,
    required this.role,
    required this.email,
    required this.reviewerName,
    this.previewMode = false,
  });

  String get roleLabel {
    switch (role) {
      case 'logistics':
        return 'Logistics';
      case 'rider':
        return 'Rider';
      default:
        return 'Buyer';
    }
  }

  List<_FlowStep> get flow {
    if (role == 'rider') {
      return const [
        _FlowStep(Icons.hub_outlined, 'Choose provider'),
        _FlowStep(Icons.description_outlined, 'Register'),
        _FlowStep(Icons.mail_outline, 'Verify email'),
        _FlowStep(Icons.fact_check_outlined, 'Document review'),
        _FlowStep(Icons.groups_outlined, 'Provider review'),
        _FlowStep(Icons.check_circle_outline, 'Approved'),
        _FlowStep(Icons.login, 'Can log in'),
      ];
    }

    if (role == 'logistics') {
      return const [
        _FlowStep(Icons.description_outlined, 'Register'),
        _FlowStep(Icons.mail_outline, 'Verify email'),
        _FlowStep(Icons.warehouse_outlined, 'Business requirements'),
        _FlowStep(Icons.shield_outlined, 'Admin review'),
        _FlowStep(Icons.check_circle_outline, 'Approved'),
        _FlowStep(Icons.login, 'Can log in'),
      ];
    }

    return const [
      _FlowStep(Icons.description_outlined, 'Register'),
      _FlowStep(Icons.mail_outline, 'Verify email'),
      _FlowStep(Icons.shield_outlined, 'Admin review'),
      _FlowStep(Icons.check_circle_outline, 'Approved'),
      _FlowStep(Icons.login, 'Can log in'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F4EE);
    const gold = Color(0xFFC9870B);
    const ink = Color(0xFF1F2328);
    const muted = Color(0xFF666D76);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(13, 16, 13, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE6DED1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.055),
                      blurRadius: 35,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (previewMode)
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7E8),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Text(
                          'UI PREVIEW — not submitted to Laravel',
                          style: TextStyle(
                            color: Color(0xFFA96F06),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .6,
                          ),
                        ),
                      ),
                    Image.asset(
                      'assets/images/sari-logo.png',
                      width: 112,
                      height: 58,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text(
                        'SARI',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 11),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E9),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.hourglass_top_rounded,
                        color: gold,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'APPLICATION SUBMITTED',
                      style: TextStyle(
                        color: gold,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Waiting for $reviewerName review',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      role == 'rider'
                          ? 'Your SARI Rider registration has been saved. '
                              'Your selected Logistics team must review your information '
                              'and documents before your account can log in.'
                          : 'Your SARI $roleLabel registration has been saved. '
                              'The administrator must review your information and uploaded '
                              'documents before your account can log in.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10.5,
                        height: 1.6,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF9),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: const Color(0xFFE7E2DA),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBF5E9),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(
                                Icons.mail_outline,
                                color: Color(0xFFA96F08),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Decision email will be sent to',
                                    style: TextStyle(
                                      color: Color(0xFF8B9198),
                                      fontSize: 8.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      color: Color(0xFF363B42),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    const Divider(color: Color(0xFFEEE9E2)),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$roleLabel registration flow',
                        style: const TextStyle(
                          color: ink,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 94,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: flow.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (_, index) {
                          final item = flow[index];
                          final active = index < 2;

                          return SizedBox(
                            width: 79,
                            child: Column(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: active
                                        ? const Color(0xFFFFF9ED)
                                        : Colors.white,
                                    border: Border.all(
                                      color: active
                                          ? const Color(0xFFD6AC60)
                                          : const Color(0xFFDED8CE),
                                    ),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    size: 15,
                                    color: active
                                        ? const Color(0xFFA76C08)
                                        : const Color(0xFF806F55),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item.label,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    color: Color(0xFF5F656C),
                                    fontSize: 8,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Go to Login',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlowStep {
  final IconData icon;
  final String label;

  const _FlowStep(this.icon, this.label);
}
