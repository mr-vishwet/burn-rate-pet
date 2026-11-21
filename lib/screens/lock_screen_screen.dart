import 'package:material_ui/material_ui.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 12 Lock-screen Check-in: Momo asks about your focus before you unlock
/// — amounts stay hidden on the lock screen.
///
/// v0.1: an in-app preview + the real check-in flow. A true lock-screen
/// extension needs native code and is phase-2 work.
class LockScreenScreen extends StatelessWidget {
  /// Creates the lock-screen screen.
  const LockScreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Lock-screen check-ins',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Switch(
                  value: controller.state.lockCheckinsEnabled,
                  onChanged: (value) =>
                      controller.setCompanion(lockCheckinsEnabled: value),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Snoozed for an hour. Momo will wait.',
                              ),
                            ),
                          );
                        },
                        child: const Text('Snooze 1h'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Swipe up to check in · amounts stay hidden on the '
                    'lock screen',
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
                      'v0.1: this preview runs the real check-in flow. A '
                      'true lock-screen extension needs native code — '
                      'phase 2.',
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
