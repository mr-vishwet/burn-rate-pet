import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 23 Sign In: magic link, no password — your guest numbers and Momo
/// move over.
///
/// v0.1 is local-only: no email is sent. The Verify screen accepts any
/// 6-digit code and signs you in on-device. Real magic-link email is a
/// phase-2 item (needs a backend).
class SignInScreen extends StatefulWidget {
  /// Creates the sign-in screen.
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _emailValid {
    final email = _emailController.text.trim();
    return email.contains('@') && email.contains('.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Sign In',
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
              'Magic link, no password',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your guest numbers and Momo move over — nothing is lost '
              'when you sign in.',
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
                  const Kicker('Email'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'you@example.com',
                      errorText: _error,
                    ),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'v0.1: sign-in is local-only — no email is sent. The '
                    'next screen accepts any 6-digit code.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Send magic link',
              icon: Icons.mail_outline,
              onPressed: () async {
                if (!_emailValid) {
                  setState(
                    () => _error = 'Enter a valid email address.',
                  );
                  return;
                }
                await MomoScope.read(
                  context,
                ).beginSignIn(_emailController.text);
                if (!mounted) return;
                Navigator.of(context).pushNamed(AppRoutes.verify);
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.createAccount,
              ),
              child: const Text('No account yet? Create one ›'),
            ),
          ],
        ),
      ),
    );
  }
}
