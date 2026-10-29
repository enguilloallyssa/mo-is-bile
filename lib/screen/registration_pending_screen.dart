import 'package:flutter/material.dart';

class RegistrationPendingScreen extends StatelessWidget {
  final String role;
  final String email;
  final String reviewerName;

  // Pinanatili para compatible sa existing constructor calls.
  // Hindi na ito nagpapakita ng preview-only message.
  final bool previewMode;

  const RegistrationPendingScreen({
    super.key,
    required this.role,
    required this.email,
    required this.reviewerName,
    this.previewMode = false,
  });

  static const Color _background = Color(0xFF0A0A0C);
  static const Color _surface = Color(0xFF18181C);
  static const Color _innerSurface = Color(0xFF222226);
  static const Color _border = Color(0xFF37373D);
  static const Color _gold = Color(0xFFD4A62A);
  static const Color _muted = Color(0xFFAAAAB2);
  static const Color _green = Color(0xFF79C58E);

  bool get _isRider => role.toLowerCase() == 'rider';

  String get _roleLabel {
    switch (role.toLowerCase()) {
      case 'rider':
        return 'Rider';

      case 'logistics':
        return 'Logistics';

      case 'buyer':
      default:
        return 'Buyer';
    }
  }

  String get _reviewer {
    final String name = reviewerName.trim();

    if (name.isNotEmpty) {
      return name;
    }

    return _isRider
        ? 'your Logistics provider'
        : 'the SARI administrator';
  }

  List<_RegistrationFlowStep> get _flow {
    if (_isRider) {
      return const <_RegistrationFlowStep>[
        _RegistrationFlowStep(
          icon: Icons.hub_outlined,
          label: 'Provider selected',
          status: _StepStatus.completed,
        ),
        _RegistrationFlowStep(
          icon: Icons.description_outlined,
          label: 'Application submitted',
          status: _StepStatus.completed,
        ),
        _RegistrationFlowStep(
          icon: Icons.mark_email_read_outlined,
          label: 'Email verified',
          status: _StepStatus.completed,
        ),
        _RegistrationFlowStep(
          icon: Icons.fact_check_outlined,
          label: 'Under review',
          status: _StepStatus.current,
        ),
        _RegistrationFlowStep(
          icon: Icons.check_circle_outline_rounded,
          label: 'Account approved',
          status: _StepStatus.pending,
        ),
      ];
    }

    return const <_RegistrationFlowStep>[
      _RegistrationFlowStep(
        icon: Icons.description_outlined,
        label: 'Registration submitted',
        status: _StepStatus.completed,
      ),
      _RegistrationFlowStep(
        icon: Icons.mark_email_read_outlined,
        label: 'Email verified',
        status: _StepStatus.completed,
      ),
      _RegistrationFlowStep(
        icon: Icons.fact_check_outlined,
        label: 'Under review',
        status: _StepStatus.current,
      ),
      _RegistrationFlowStep(
        icon: Icons.check_circle_outline_rounded,
        label: 'Account approved',
        status: _StepStatus.pending,
      ),
    ];
  }

  void _goToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  void _goToWelcome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/welcome',
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _background,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.75),
                  radius: 1.15,
                  colors: <Color>[
                    Color(0xFF303034),
                    Color(0xFF151518),
                    Color(0xFF08080A),
                  ],
                  stops: <double>[
                    0,
                    0.52,
                    1,
                  ],
                ),
              ),
            ),
            Positioned(
              top: -120,
              right: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  17,
                  24,
                  17,
                  30,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 620,
                    ),
                    child: _buildCard(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        22,
      ),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.98),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.38),
            blurRadius: 38,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _buildLogo(),
          const SizedBox(height: 20),
          _buildPendingIcon(),
          const SizedBox(height: 17),
          const Text(
            'APPLICATION SUBMITTED',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _gold,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Waiting for $_reviewer',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _isRider
                ? 'Your SARI Rider application has been saved. '
                    '$_reviewer will review your information, '
                    'vehicle details, and uploaded documents.'
                : 'Your SARI $_roleLabel registration has been '
                    'saved. The administrator will review your '
                    'information before activating your account.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
              height: 1.6,
            ),
          ),
          if (email.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 20),
            _buildEmailCard(),
          ],
          const SizedBox(height: 23),
          Container(
            height: 1,
            color: _border,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$_roleLabel registration progress',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildFlow(),
          const SizedBox(height: 23),
          _buildNotice(),
          const SizedBox(height: 21),
          SizedBox(
            width: double.infinity,
            height: 51,
            child: ElevatedButton.icon(
              onPressed: () {
                _goToLogin(context);
              },
              icon: const Icon(
                Icons.login_rounded,
                size: 19,
              ),
              label: const Text(
                'Go to Sign In',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: const Color(0xFF151515),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          TextButton(
            onPressed: () {
              _goToWelcome(context);
            },
            child: const Text(
              'Return to welcome page',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 54,
          height: 54,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF111113),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.07),
            ),
          ),
          child: Image.asset(
            'assets/images/sari_s.png',
            fit: BoxFit.contain,
            errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
            ) {
              return const Center(
                child: Text(
                  'S',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 11),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'SARI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            Text(
              'ELEVATED EVERYDAY',
              style: TextStyle(
                color: Color(0xFF929299),
                fontSize: 6.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPendingIcon() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFF292820),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _gold.withOpacity(0.28),
        ),
      ),
      child: const Icon(
        Icons.hourglass_top_rounded,
        color: _gold,
        size: 34,
      ),
    );
  }

  Widget _buildEmailCard() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _innerSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: const Color(0xFF292820),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              color: _gold,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'The decision will be sent to',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildFlow() {
    return Column(
      children: List<Widget>.generate(
        _flow.length,
        (int index) {
          final _RegistrationFlowStep step = _flow[index];
          final bool isLast = index == _flow.length - 1;

          return _FlowStepTile(
            step: step,
            isLast: isLast,
          );
        },
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2922),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF355542),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            color: _green,
            size: 19,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You cannot sign in until your account is approved. '
              'Please wait for the confirmation email before trying again.',
              style: TextStyle(
                color: Color(0xFFB8D8C1),
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepStatus {
  completed,
  current,
  pending,
}

class _RegistrationFlowStep {
  final IconData icon;
  final String label;
  final _StepStatus status;

  const _RegistrationFlowStep({
    required this.icon,
    required this.label,
    required this.status,
  });
}

class _FlowStepTile extends StatelessWidget {
  final _RegistrationFlowStep step;
  final bool isLast;

  const _FlowStepTile({
    required this.step,
    required this.isLast,
  });

  static const Color _gold = Color(0xFFD4A62A);
  static const Color _muted = Color(0xFFAAAAB2);
  static const Color _border = Color(0xFF37373D);
  static const Color _green = Color(0xFF79C58E);

  @override
  Widget build(BuildContext context) {
    final bool completed =
        step.status == _StepStatus.completed;

    final bool current =
        step.status == _StepStatus.current;

    final Color iconColor = completed
        ? _green
        : current
            ? _gold
            : const Color(0xFF686870);

    final Color circleColor = completed
        ? const Color(0xFF1E3024)
        : current
            ? const Color(0xFF292820)
            : const Color(0xFF222226);

    final Color lineColor = completed
        ? const Color(0xFF42694E)
        : _border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 42,
            child: Column(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: iconColor.withOpacity(0.6),
                    ),
                  ),
                  child: Icon(
                    completed
                        ? Icons.check_rounded
                        : step.icon,
                    color: iconColor,
                    size: 17,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      constraints: const BoxConstraints(
                        minHeight: 19,
                      ),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 8,
                bottom: isLast ? 0 : 21,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      step.label,
                      style: TextStyle(
                        color: completed || current
                            ? Colors.white
                            : _muted,
                        fontSize: 11,
                        fontWeight: current
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    completed
                        ? 'DONE'
                        : current
                            ? 'CURRENT'
                            : 'PENDING',
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
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