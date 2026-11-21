import 'package:material_ui/material_ui.dart';

import '../app_routes.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 02 Onboarding 1: meet Momo — a pet for your happiness.
class OnboardingAScreen extends StatelessWidget {
  /// Creates onboarding screen 1.
  const OnboardingAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final currency = controller.state.currency;
    return AppScaffold(
      title: 'Meet Momo',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: MomoAvatar(size: 140)),
            const SizedBox(height: 20),
            Text(
              'A pet for your happiness',
              style: theme.textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Momo is a small corgi who lives on your phone and keeps '
              'one number for you: how you are doing, really. Not your '
              'productivity. Not your money. You.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.peachSoft,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('The budget, in the open'),
                  const SizedBox(height: 8),
                  Text(
                    '${formatMoney(controller.spentCents, currency)} spent '
                    'of ${formatMoney(controller.plannedCents, currency)} '
                    'planned',
                    style: AppTheme.monoNumbers(size: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your spending is one of three inputs — shown, not '
                    'hidden, and never a scolding.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Meet the index',
              icon: Icons.arrow_forward,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.onboardingB),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.addDetails),
              child: const Text('Skip the tour'),
            ),
          ],
        ),
      ),
    );
  }
}
