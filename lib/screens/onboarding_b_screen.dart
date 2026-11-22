import 'package:material_ui/material_ui.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/formula_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 03 Onboarding 2: one Happiness Index, three inputs — check-ins 40%,
/// routines 35%, budget 25%. The formula, shown in the open.
class OnboardingBScreen extends StatelessWidget {
  /// Creates onboarding screen 2.
  const OnboardingBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    // No fallbacks: with no check-ins or routines yet the formula card
    // shows "—" for the missing inputs instead of invented numbers.
    final mood = controller.moodScore;
    final routines = controller.routineScoreValue;
    final budget = controller.budgetScoreValue;
    return AppScaffold(
      title: 'One Index',
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
              'One index, three inputs',
              style: theme.textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Momo does not guess. Your Happiness Index is three numbers '
              'you can see, combined by a formula you can check.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.peachSoft,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const _InputRow(
              icon: Icons.favorite_outline,
              title: 'Mood check-ins',
              weight: '40%',
              body: 'Ten questions, drawn at random — sleep, energy, '
                  'stress, focus, and six more.',
            ),
            const SizedBox(height: 12),
            const _InputRow(
              icon: Icons.check_circle_outline,
              title: 'Daily routines',
              weight: '35%',
              body: 'Routines you create, followed or missed. Streaks '
                  'pause, they never punish.',
            ),
            const SizedBox(height: 12),
            const _InputRow(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Budget health',
              weight: '25%',
              body: 'One monthly plan, five categories, spent vs planned. '
                  'Staying on plan lifts the index.',
            ),
            const SizedBox(height: 20),
            FormulaCard(mood: mood, routines: routines, budget: budget),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Set up in thirty seconds',
              icon: Icons.arrow_forward,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.addDetails),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.icon,
    required this.title,
    required this.weight,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String weight;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.peach),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      weight,
                      style: AppTheme.monoNumbers(
                        size: 16,
                        weight: FontWeight.w600,
                        color: AppTheme.peach,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(body, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
