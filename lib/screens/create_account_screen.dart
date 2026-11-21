import 'package:material_ui/material_ui.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 24 Create Account: one account, Momo everywhere — 6 months of history
/// comes with you.
///
/// v0.1 is local-only: no email is sent. The Verify screen accepts any
/// 6-digit code and creates the account on-device.
class CreateAccountScreen extends StatefulWidget {
  /// Creates the create-account screen.
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool get _emailValid {
    final email = _emailController.text.trim();
    return email.contains('@') && email.contains('.');
  }

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Create Account',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: MomoAvatar(size: 110)),
            const SizedBox(height: 16),
            Text(
              'One account, Momo everywhere',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.state.indexHistory.length} months of history '
              'comes with you — budget, milestones, bands, Momo.',
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
                  const Kicker('Your name'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "Momo's human",
                    ),
                  ),
                  const SizedBox(height: 16),
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
                    'No password — a magic link + 6-digit code. v0.1 is '
                    'local-only: no email is sent.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Create my account',
              icon: Icons.person_add_outlined,
              onPressed: () async {
                if (!_emailValid) {
                  setState(
                    () => _error = 'Enter a valid email address.',
                  );
                  return;
                }
                await MomoScope.read(context).beginCreateAccount(
                  email: _emailController.text,
                  name: _nameController.text,
                );
                if (!context.mounted) return;
                Navigator.of(context).pushNamed(AppRoutes.verify);
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.signIn),
              child: const Text('Already have an account? Sign in ›'),
            ),
          ],
        ),
      ),
    );
  }
}
