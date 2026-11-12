import 'package:flutter/material.dart';
import '../services/sari_live_data.dart';

class MobilePasswordResetScreen extends StatefulWidget {
  const MobilePasswordResetScreen({super.key});

  @override
  State<MobilePasswordResetScreen> createState() =>
      _MobilePasswordResetScreenState();
}

class _MobilePasswordResetScreenState extends State<MobilePasswordResetScreen> {
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  int _step = 0;
  String? _token;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_busy) return;

    setState(() => _busy = true);

    try {
      if (_step == 0) {
        await SariLiveData.instance.passwordResetSendCode(_email.text.trim());

        setState(() => _step = 1);
      } else if (_step == 1) {
        final result = await SariLiveData.instance.passwordResetVerify(
          _email.text.trim(),
          _otp.text.trim(),
        );

        final token =
            result['reset_token'] ??
            (result['data'] is Map
                ? (result['data'] as Map)['reset_token']
                : null);

        if (token == null) {
          throw StateError('Reset token missing from server response.');
        }

        setState(() {
          _token = token.toString();
          _step = 2;
        });
      } else {
        if (_password.text != _confirm.text) {
          throw StateError('Passwords do not match.');
        }

        await SariLiveData.instance.passwordResetConfirm(
          _email.text.trim(),
          _token!,
          _password.text,
        );

        if (!mounted) return;

        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Password updated'),
            content: const Text('Sign in using your new password.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        if (mounted) {
          Navigator.pop(context);
        }
      }

      if (mounted) {
        setState(() => _error = null);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reset Password')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            [
              'Enter your account email',
              'Verify email OTP',
              'Create a new password',
            ][_step],
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 15),

          if (_step == 0)
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

          if (_step == 1)
            TextField(
              controller: _otp,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '6-digit OTP',
                border: OutlineInputBorder(),
              ),
            ),

          if (_step == 2) ...[
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New password',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Minimum 8 characters, upper/lower case, number and symbol.',
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],

          const SizedBox(height: 18),

          FilledButton(
            onPressed: _busy ? null : _next,
            child: Text(
              _busy
                  ? 'Processing...'
                  : _step == 2
                  ? 'Update password'
                  : 'Continue',
            ),
          ),
        ],
      ),
    ),
  );
}
