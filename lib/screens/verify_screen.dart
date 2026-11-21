import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 25 Verify: magic link and a 6-digit code — works on any device.
///
/// v0.1 is local-only: no email is sent, so any 6-digit code is accepted
/// and the account is created on-device. The screen says so plainly.
class VerifyScreen extends StatefulWidget {
  /// Creates the verify screen.
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _codeController = TextEditingController();
  String? _error;
  var _verifying = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_codeController.text.trim().length != 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      return;
    }
    setState(() {
      _verifying = true;
      _error = null;
    });
    final result = await MomoScope.read(
      context,
    ).verifyCode(_codeController.text.trim());
    if (!mounted) return;
    setState(() => _verifying = false);
    if (result == null) {
      setState(
        () => _error = 'No sign-in in progress — start from Sign in.',
      );
      return;
    }
    if (result) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.migrate,
        (route) => false,
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.account,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final email = controller.pendingEmail ?? 'your email';
    return AppScaffold(
      title: 'Verify',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: MomoAvatar(size: 110, mood: MomoMood.content),
            ),
            const SizedBox(height: 16),
            Text(
              'Check your inbox',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'A magic link and a 6-digit code are on their way to $email. '
              'Works on any device.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.peachSoft,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('6-digit code'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                      hintText: '••••••',
                      errorText: _error,
                    ),
                    style: AppTheme.monoNumbers(
                      size: 24,
                      weight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                    onSubmitted: (_) => _verify(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'v0.1: no email is sent (local-only sign-in). Any '
                    '6-digit code completes verification on this device.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: _verifying ? 'Verifying…' : 'Verify & continue',
              icon: Icons.verified_outlined,
              onPressed: _verifying ? null : _verify,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'v0.1: no email is sent. Enter any 6-digit code.',
                    ),
                  ),
                );
              },
              child: const Text('Resend code'),
            ),
          ],
        ),
      ),
    );
  }
}
