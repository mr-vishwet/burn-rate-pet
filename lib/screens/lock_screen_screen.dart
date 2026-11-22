import 'package:material_ui/material_ui.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 12 Lock-screen Check-in: Momo asks about your focus before you unlock
/// — amounts stay hidden on the lock screen.
///
/// Coming with the mobile app: a true lock-screen extension needs native
/// code this web-only build cannot ship. This screen previews how it will
/// look; the Check in button runs the real in-app check-in flow.
class LockScreenScreen extends StatelessWidget {
  /// Creates the lock-screen screen.
  const LockScreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return AppScaffold(
      title: 'Lock-screen Check-in',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.smartphone_outlined,
                      color: AppTheme.peach),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Coming with the mobile app — lock-screen check-ins '
                      'need native code. Below is a preview of how they '
                      'will look.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Kicker('Preview'),
            const SizedBox(height: 12),
            // Lock-screen preview.
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.backgroundGradient,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.hairline),
              ),
              child: Column(
                children: [
                  Text(
                    time,
                    style: AppTheme.monoNumbers(
                      size: 56,
                      weight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    weekdays[now.weekday - 1],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.peachSoft,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _LockNotification(
                    mood: MomoMood.content,
                    title: 'Quick check-in: how\'s your focus?',
                    body: 'Tap to answer in 10 seconds — Momo is listening.',
                    when: 'now',
                  ),
                  const SizedBox(height: 12),
                  const _LockNotification(
                    mood: MomoMood.happy,
                    title: 'Your budget is looking better!',
                    body: 'Keep it up — Momo noticed.',
                    when: '1h ago',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: () => Navigator.of(context).pushNamed(
                          AppRoutes.checkin,
                        ),
                        child: const Text('Check in'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Preview: swipe up to check in · amounts stay hidden '
                    'on the lock screen',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.peach),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The preview above runs the real check-in flow when '
                      'you tap Check in. The lock-screen extension itself '
                      'comes with the mobile app.',
                      style: theme.textTheme.bodySmall,
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

class _LockNotification extends StatelessWidget {
  const _LockNotification({
    required this.mood,
    required this.title,
    required this.body,
    required this.when,
  });

  final MomoMood mood;
  final String title;
  final String body;
  final String when;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MomoAvatar(size: 44, mood: mood, bob: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Momo',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(when, style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 2),
                Text(title, style: theme.textTheme.bodyMedium),
                Text(body, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
