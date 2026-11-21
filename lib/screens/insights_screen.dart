import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../engine/insights.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 15 Insights: the good news first — spending down, the climb, the
/// streaks — plus Momo's notes on movement and sleep.
class InsightsScreen extends StatelessWidget {
  /// Creates the insights screen.
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final insights = controller.insights;
    return AppScaffold(
      title: 'Insights',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const MomoAvatar(size: 64, mood: MomoMood.happy, bob: false),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What Momo noticed',
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        'Computed from your own numbers — nothing '
                        'invented, nothing shared.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            for (final insight in insights) ...[
              _InsightCard(insight: insight),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final Insight insight;

  IconData get _icon {
    switch (insight.kind) {
      case InsightKind.good:
        return Icons.trending_up;
      case InsightKind.note:
        return Icons.visibility_outlined;
      case InsightKind.tip:
        return Icons.lightbulb_outline;
    }
  }

  Color get _color {
    switch (insight.kind) {
      case InsightKind.good:
        return AppTheme.green;
      case InsightKind.note:
        return AppTheme.peach;
      case InsightKind.tip:
        return AppTheme.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(insight.body, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
