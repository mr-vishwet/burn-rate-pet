import 'package:material_ui/material_ui.dart';

import '../app_routes.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 21 Welcome: no account needed — the whole pet works guest-first.
class WelcomeScreen extends StatelessWidget {
  /// Creates the welcome screen.
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final currency = controller.state.currency;
    return AppScaffold(
      title: 'Welcome to Momo',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Momo', style: theme.textTheme.titleMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.glassStrong,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Guest',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Center(child: MomoAvatar(size: 110)),
            const SizedBox(height: 12),
            const Kicker('Welcome to Momo'),
            const SizedBox(height: 6),
            Text(
              'No account needed',
              style: theme.textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Set your budget in thirty seconds — one glance a day tells '
              'you how you are doing. No account needed to start.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.peachSoft,
              ),
              textAlign: TextAlign.center,
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
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.signIn),
              child: const Text('Sign in'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.createAccount,
              ),
              child: const Text('Create an account ›'),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('As a guest you get'),
                  const SizedBox(height: 12),
                  _WorksRow(
                    icon: Icons.home_outlined,
                    title: 'Budget & Momo',
                    body:
                        '${formatMoney(controller.spentCents, currency)} of '
                        '${formatMoney(controller.plannedCents, currency)} '
                        'at a glance — spent vs planned, shown not hidden.',
                  ),
                  const SizedBox(height: 12),
                  const _WorksRow(
                    icon: Icons.show_chart_outlined,
                    title: 'History & bands',
                    body: '6 months of happiness, your bands, your '
                        'milestones.',
                  ),
                  const SizedBox(height: 12),
                  const _WorksRow(
                    icon: Icons.widgets_outlined,
                    title: 'Widget & check-in',
                    body: 'The home-screen widget hides amounts; one '
                        'gentle Sunday nudge.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your numbers stay on this device. Sign in later — nothing '
              'is lost.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.guest),
              child: const Text('What works as a guest?'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorksRow extends StatelessWidget {
  const _WorksRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.peach),
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
      ],
    );
  }
}
