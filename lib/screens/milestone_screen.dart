import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 18 Milestone: the latest milestone actually earned, with confetti and
/// the numbers that prove it — plus every milestone, unlocked or still
/// ahead. With nothing unlocked yet, the card says so honestly and shows
/// the real check-in count so far.
class MilestoneScreen extends StatelessWidget {
  /// Creates the milestone screen.
  const MilestoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final milestones = controller.state.milestones;
    final unlocked = milestones.where((m) => m.unlocked).toList();
    final locked = milestones.where((m) => !m.unlocked).toList();
    // Headline milestone: the latest one actually earned (last in
    // definition order). Nothing unlocked yet → no celebration claim.
    final headline = unlocked.isEmpty ? null : unlocked.last;
    final checkinDays = controller.checkinDays;
    return AppScaffold(
      title: 'Milestones',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Celebration card for the headline milestone.
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.ctaGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final color in [
                        AppTheme.green,
                        AppTheme.orange,
                        Colors.white,
                        AppTheme.rose,
                        AppTheme.peach,
                      ])
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const MomoAvatar(size: 110, mood: MomoMood.cheer),
                  const SizedBox(height: 12),
                  Text(
                    headline == null
                        ? 'No milestones yet'
                        : '${headline.title}!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    headline == null
                        ? 'Your first check-in unlocks the first one — '
                            '$checkinDays check-in '
                            '${checkinDays == 1 ? 'day' : 'days'} so far.'
                        : headline.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _CelebrationStat(
                          value: '${controller.checkinDays}',
                          label: 'check-in days',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CelebrationStat(
                          value: '${controller.bestStreak.days}-day',
                          label: 'best streak',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CelebrationStat(
                          value: '${unlocked.length}/${milestones.length}',
                          label: 'milestones',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Kicker('Unlocked'),
            const SizedBox(height: 12),
            if (unlocked.isEmpty)
              GlassCard(
                child: Text(
                  'No milestones yet — your first check-in unlocks the '
                  'first one.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              for (final m in unlocked) ...[
                _MilestoneTile(
                  title: m.title,
                  body: m.body,
                  unlocked: true,
                ),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 16),
            const Kicker('Still ahead'),
            const SizedBox(height: 12),
            for (final m in locked) ...[
              _MilestoneTile(
                title: m.title,
                body: m.body,
                unlocked: false,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _CelebrationStat extends StatelessWidget {
  const _CelebrationStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.monoNumbers(
              size: 18,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.title,
    required this.body,
    required this.unlocked,
  });

  final String title;
  final String body;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Row(
        children: [
          Icon(
            unlocked
                ? Icons.emoji_events_outlined
                : Icons.emoji_events_outlined,
            color: unlocked ? AppTheme.orange : AppTheme.taupe,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: unlocked ? AppTheme.ink : AppTheme.taupe,
                  ),
                ),
                Text(
                  body,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (unlocked)
            const Icon(Icons.check_circle, color: AppTheme.green),
        ],
      ),
    );
  }
}
