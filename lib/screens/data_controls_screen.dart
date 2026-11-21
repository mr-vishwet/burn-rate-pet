import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../services/export_service.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 30 Data Controls: export everything, sign out, or delete — no guilt,
/// no dark patterns.
class DataControlsScreen extends StatelessWidget {
  /// Creates the data controls screen.
  const DataControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final isGuest = controller.state.authMode.name == 'guest';
    return AppScaffold(
      title: 'Data Controls',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: MomoAvatar(size: 96, mood: MomoMood.content),
            ),
            const SizedBox(height: 12),
            Text(
              'Your data, your call',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Export everything, sign out, or delete — no guilt, no dark '
              'patterns.',
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
                  const Kicker('Export'),
                  const SizedBox(height: 8),
                  Text(
                    'Download your whole Momo — check-ins, routines, '
                    'budget, history, milestones — as one JSON file.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          label: 'Export JSON',
                          icon: Icons.download_outlined,
                          onPressed: () async {
                            try {
                              final path = await saveTextFile(
                                controller.exportJson(),
                                'momo-export.json',
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Export saved: $path'),
                                ),
                              );
                            } on UnsupportedError {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Saving is not supported on this '
                                    'platform — use Copy instead.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: controller.exportJson()),
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Export copied to clipboard.'),
                              ),
                            );
                          },
                          child: const Text('Copy JSON'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('Sign out'),
                  const SizedBox(height: 8),
                  Text(
                    isGuest
                        ? "You're already a guest — nothing to sign out of."
                        : 'Back to guest mode. Your data stays on this '
                            'device — signing out never deletes anything.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: isGuest
                        ? null
                        : () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Sign out?'),
                                content: const Text(
                                  'You will go back to guest mode. Your '
                                  'data stays on this device.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Stay signed in'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Sign out'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && context.mounted) {
                              await MomoScope.read(context).signOut();
                              if (!context.mounted) return;
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.welcome,
                                (route) => false,
                              );
                            }
                          },
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('Delete everything'),
                  const SizedBox(height: 8),
                  Text(
                    'Wipes Momo from this device — check-ins, routines, '
                    'budget, history, account. There is no undo, and no '
                    'server copy to restore from.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () async {
                      final first = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete everything?'),
                          content: const Text(
                            'This wipes all of Momo from this device. '
                            'Export first if you want a copy.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                              child: const Text('Keep Momo'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.rose,
                              ),
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                              child: const Text('Delete everything'),
                            ),
                          ],
                        ),
                      );
                      if (first != true || !context.mounted) return;
                      final second = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Are you sure?'),
                          content: const Text(
                            'Really everything — Momo forgets you '
                            'completely. This cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                              child: const Text('Keep Momo'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.rose,
                              ),
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                              child: const Text('Yes, delete it all'),
                            ),
                          ],
                        ),
                      );
                      if (second == true && context.mounted) {
                        await MomoScope.read(context).deleteAllData();
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.splash,
                          (route) => false,
                        );
                      }
                    },
                    child: const Text(
                      'Delete everything',
                      style: TextStyle(color: AppTheme.rose),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
