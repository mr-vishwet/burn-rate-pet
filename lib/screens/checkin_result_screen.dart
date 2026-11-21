import 'package:material_ui/material_ui.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../engine/happiness.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/formula_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/index_ring.dart';
import '../widgets/momo_avatar.dart';

/// 07 Check-in Result: "Momo feels you" — the ring, the formula shown,
/// and what Momo noticed. No guilt, just noticed.
class CheckinResultScreen extends StatelessWidget {
  /// Creates the check-in result screen.
  const CheckinResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final last = controller.lastCheckin;
    final index = controller.index;
    final band = controller.band;
    final mood = controller.moodScore;
    final routines = controller.routineScoreValue;
    final budget = controller.budgetScoreValue;

    if (last == null || index == null || band == null) {
      return AppScaffold(
        title: 'Check-in Result',
        showBack: true,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MomoAvatar(size: 110, mood: MomoMood.sleeping),
                const SizedBox(height: 16),
                Text(
                  'No check-in yet',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete a check-in first — Momo will show you the '
                  'result here.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GradientButton(
                  label: 'Start a check-in',
                  icon: Icons.favorite_outline,
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.checkin),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      title: 'Check-in Result',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: MomoAvatar(size: 120, mood: MomoMood.happy)),
            const SizedBox(height: 12),
            Text(
              'Check-in complete · 10 of 10',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Momo feels you.',
              style: theme.textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              last.score >= 70
                  ? 'Sleep and movement lifted today. Nothing to fix — '
                      'just noticed.'
                  : last.score >= 45
                      ? 'A middling day, honestly answered. Momo notes it '
                          'and stays close.'
                      : 'A hard day, and you still showed up to say so. '
                          'Momo curls up beside you.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.peachSoft,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GlassCard(
              child: Row(
                children: [
                  IndexRing(value: index, label: band.label, size: 118),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This check-in scored ${last.score} / 100',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your mood input is now ${mood ?? '—'} — the '
                          'average of your recent check-ins.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FormulaCard(
              mood: mood ?? 0,
              routines: routines ?? 0,
              budget: budget,
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    color: AppTheme.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Momo noticed: ${last.score >= 70 ? 'you slept well and moved. That is most of the lift this week.' : 'today was heavy. Rest counts as a routine too.'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Back to Home',
              icon: Icons.home_outlined,
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
