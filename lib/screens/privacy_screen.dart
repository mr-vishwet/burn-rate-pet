import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 20 Privacy First: your data stays on your device — no tracking, no
/// sharing. The promise is absolute.
class PrivacyScreen extends StatelessWidget {
  /// Creates the privacy screen.
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Privacy First',
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
              'Your data stays on your device',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Momo is local-first. There is no server in v0.1 — nothing '
              'to leak, nothing to sell, nothing to breach.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.peachSoft,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const _Guarantee(
              icon: Icons.phone_android_outlined,
              title: 'On-device only',
              body: 'Check-ins, routines, budget, history — stored in '
                  'this app, on this device, and nowhere else.',
            ),
            const SizedBox(height: 12),
            const _Guarantee(
              icon: Icons.visibility_off_outlined,
              title: 'No tracking',
              body: 'No analytics, no advertising identifiers, no '
                  'behavioural profiling. Momo watches only what you '
                  'show it.',
            ),
            const SizedBox(height: 12),
            const _Guarantee(
              icon: Icons.share_outlined,
              title: 'No sharing',
              body: 'Your numbers are never sent to anyone. The friend '
                  'share link (account only) is read-only and shows the '
                  'index and band — never amounts.',
            ),
            const SizedBox(height: 12),
            const _Guarantee(
              icon: Icons.lock_outline,
              title: 'Amounts stay hidden',
              body: 'The widget and lock screen show the index and band '
                  'only. A screenshot of your home screen reveals no '
                  'money.',
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Data controls',
              icon: Icons.settings_outlined,
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.dataControls,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Export everything, sign out, or delete — no guilt, no '
              'dark patterns. Your data, your call.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Guarantee extends StatelessWidget {
  const _Guarantee({
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
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.green, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(body, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
