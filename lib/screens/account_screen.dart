import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 28 Account: sync on, devices, friend share — signed in.
class AccountScreen extends StatelessWidget {
  /// Creates the account screen.
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final state = controller.state;
    final isGuest = state.authMode.name == 'guest';
    if (isGuest) {
      return AppScaffold(
        title: 'Account',
        showBack: true,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MomoAvatar(size: 110, mood: MomoMood.content),
                const SizedBox(height: 16),
                Text(
                  "You're a guest",
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in or create an account to unlock sync and '
                  'friend sharing. Your guest data moves over.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GradientButton(
                  label: 'Sign in',
                  icon: Icons.login_outlined,
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.signIn,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.createAccount,
                  ),
                  child: const Text('Create an account'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return AppScaffold(
      title: 'Account',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Row(
                children: [
                  const MomoAvatar(size: 64, bob: false),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.displayName ?? "Momo's human",
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          state.email ?? '',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sync'),
                    subtitle: const Text(
                      'v0.1: recorded locally. Real multi-device sync '
                      'needs a backend — phase 2.',
                    ),
                    value: state.syncOn,
                    onChanged: (value) => controller.setSync(value),
                  ),
                  const Divider(color: AppTheme.hairline),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.phone_android_outlined,
                      color: AppTheme.peach,
                    ),
                    title: const Text('This device'),
                    subtitle: const Text('Synced · just now'),
                    trailing: const Icon(
                      Icons.check_circle,
                      color: AppTheme.green,
                    ),
                  ),
                  const Divider(color: AppTheme.hairline),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.link_outlined,
                      color: AppTheme.peach,
                    ),
                    title: const Text('Friend share'),
                    subtitle: Text(
                      controller.shareUrl ?? 'No link yet',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.connected,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.dataControls,
              ),
              child: const Text('Data controls'),
            ),
          ],
        ),
      ),
    );
  }
}
