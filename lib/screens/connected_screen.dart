import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 29 Connected: the read-only share link, devices, and the
/// amounts-hidden widget.
class ConnectedScreen extends StatelessWidget {
  /// Creates the connected screen.
  const ConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final state = controller.state;
    final isGuest = state.authMode.name == 'guest';
    if (isGuest) {
      return AppScaffold(
        title: 'Connected',
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
                  'Sharing needs an account',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                GradientButton(
                  label: 'See what sharing means',
                  icon: Icons.share_outlined,
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.upgrade,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final shareUrl = controller.shareUrl ?? 'No link yet';
    return AppScaffold(
      title: 'Connected',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('Read-only share link'),
                  const SizedBox(height: 8),
                  Text(
                    shareUrl,
                    style: AppTheme.monoNumbers(
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Read-only, always. A friend sees your index and band '
                    '— never amounts, never answers.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          label: 'Copy link',
                          icon: Icons.copy_outlined,
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: 'https://$shareUrl'),
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Share link copied.'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await controller.regenerateShareCode();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'New link generated. Share this one '
                                  'instead.',
                                ),
                              ),
                            );
                          },
                          child: const Text('New link'),
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
                  const Kicker('Devices'),
                  const SizedBox(height: 8),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.phone_android_outlined,
                      color: AppTheme.peach,
                    ),
                    title: Text('This device'),
                    subtitle: Text('Saved on this device'),
                    trailing: Icon(
                      Icons.check_circle,
                      color: AppTheme.green,
                    ),
                  ),
                  Text(
                    'v0.1 is local-only: this is the only device until '
                    'real sync lands in phase 2.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppTheme.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The widget shows the band and the index, never the '
                      'amounts — on your home screen and on a friend\'s '
                      'view alike.',
                      style: theme.textTheme.bodyMedium,
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
