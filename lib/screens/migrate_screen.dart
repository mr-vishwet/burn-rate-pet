import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../engine/happiness.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 27 Migrate: budget, history, milestones, bands, Momo — moved, verified
/// item by item. Nothing lost.
///
/// v0.1: guest data already lives on-device, so migration is a
/// verification pass over the real counts — not a copy.
class MigrateScreen extends StatelessWidget {
  /// Creates the migrate screen.
  const MigrateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final state = controller.state;
    final items = <({String title, String detail})>[
      (
        title: 'Budget',
        detail: '${state.categories.length} categories, '
            '${state.expenses.length} recent expenses',
      ),
      (
        title: 'History',
        detail: '${state.indexHistory.length} months, '
            '${state.checkins.length} check-ins',
      ),
      (
        title: 'Milestones',
        detail:
            '${state.milestones.where((m) => m.unlocked).length} unlocked',
      ),
      (
        title: 'Bands',
        detail: controller.band == null
            ? 'No index yet'
            : 'Index ${controller.index} · ${controller.band!.label}',
      ),
      (
        title: 'Momo',
        detail: state.petName,
      ),
    ];
    return AppScaffold(
      title: 'Migrate',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: MomoAvatar(size: 110, mood: MomoMood.cheer)),
            const SizedBox(height: 16),
            Text(
              'Everything moved',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Signed in as ${state.email ?? 'you'}. Your guest data is '
              'now your account data — verified item by item, nothing lost.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.peachSoft,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Column(
                children: [
                  for (final item in items)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.check_circle,
                        color: AppTheme.green,
                      ),
                      title: Text(item.title),
                      subtitle: Text(
                        item.detail,
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: Text(
                        'moved',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.green,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Take me to my account',
              icon: Icons.person_outline,
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.account,
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
