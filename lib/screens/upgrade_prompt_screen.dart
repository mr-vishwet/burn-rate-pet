import 'package:material_ui/material_ui.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../engine/happiness.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 26 Upgrade Prompt: sharing with a friend needs an account — read-only,
/// always. Shows what a friend would actually see.
class UpgradePromptScreen extends StatelessWidget {
  /// Creates the upgrade prompt screen.
  const UpgradePromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final index = controller.index;
    final band = controller.band;
    return AppScaffold(
      title: 'Share with a Friend',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: MomoAvatar(size: 110)),
            const SizedBox(height: 16),
            Text(
              'Sharing needs an account',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'A friend would see your index and band — read-only, always. '
              'Never your amounts, never your answers.',
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
                  const Kicker('What a friend would see'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const MomoAvatar(size: 56, bob: false),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${controller.state.petName}\'s human',
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              index == null
                                  ? 'No index yet'
                                  : 'Happiness Index $index · '
                                      '${band?.label ?? ''}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              'Read-only · amounts hidden',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker('With an account you also get'),
                  SizedBox(height: 8),
                  _UpgradeRow(
                    icon: Icons.sync_outlined,
                    text: 'Sync across devices — coming in phase 2',
                  ),
                  SizedBox(height: 8),
                  _UpgradeRow(
                    icon: Icons.link_outlined,
                    text: 'Your read-only share link — amounts always '
                        'hidden',
                  ),
                  SizedBox(height: 8),
                  _UpgradeRow(
                    icon: Icons.backup_outlined,
                    text: 'Backup file — export your data, import it on a '
                        'new phone',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Create an account',
              icon: Icons.person_add_outlined,
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.createAccount,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.signIn),
              child: const Text('I already have an account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpgradeRow extends StatelessWidget {
  const _UpgradeRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.peach, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
