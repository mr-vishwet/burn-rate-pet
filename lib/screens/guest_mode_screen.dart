import 'package:material_ui/material_ui.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 22 Guest Mode: what works as a guest, and the two things that need an
/// account (sync + friend sharing).
class GuestModeScreen extends StatelessWidget {
  /// Creates the guest mode screen.
  const GuestModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Guest Mode',
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
              'The full pet, no account',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Guest-first is the design, not a trial. Everything below '
              'works without signing in — forever.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.peachSoft,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker('Works as a guest'),
                  SizedBox(height: 12),
                  _GuestRow(
                    icon: Icons.check_circle,
                    iconColor: AppTheme.green,
                    title: 'Mood check-ins',
                    body: '10 questions, any time.',
                  ),
                  _GuestRow(
                    icon: Icons.check_circle,
                    iconColor: AppTheme.green,
                    title: 'Routines & streaks',
                    body: 'Create, keep, pause kindly.',
                  ),
                  _GuestRow(
                    icon: Icons.check_circle,
                    iconColor: AppTheme.green,
                    title: 'Budget tracker & simulator',
                    body: 'Plans, expenses, what-ifs.',
                  ),
                  _GuestRow(
                    icon: Icons.check_circle,
                    iconColor: AppTheme.green,
                    title: 'History, bands, insights, milestones',
                    body: 'Your whole story, on-device.',
                  ),
                  _GuestRow(
                    icon: Icons.check_circle,
                    iconColor: AppTheme.green,
                    title: 'Bubble, widget, lock-screen check-ins',
                    body: 'Momo lives on the phone.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('Needs an account'),
                  const SizedBox(height: 12),
                  _GuestRow(
                    icon: Icons.lock_outline,
                    iconColor: AppTheme.orange,
                    title: 'Sync across devices',
                    body: 'Your pet, on every device you own.',
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.createAccount,
                    ),
                  ),
                  _GuestRow(
                    icon: Icons.lock_outline,
                    iconColor: AppTheme.orange,
                    title: 'Read-only friend share',
                    body: 'A friend sees your index and band — never '
                        'amounts.',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.upgrade),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Continue as guest',
              icon: Icons.pets_outlined,
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
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
    );
  }
}

class _GuestRow extends StatelessWidget {
  const _GuestRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                Text(body, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right, color: AppTheme.taupe),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: row,
    );
  }
}
