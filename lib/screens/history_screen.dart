import 'package:material_ui/material_ui.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';

/// 16 History: check-ins, streaks, and the index climb — six months of
/// entries, the +7 story beside them.
class HistoryScreen extends StatelessWidget {
  /// Creates the history screen.
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final history = controller.state.indexHistory;
    final checkins = controller.state.checkins.reversed.toList();
    final climb = history.length >= 2
        ? history.last.index - history.first.index
        : 0;
    return AppScaffold(
      title: 'History',
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
                  Row(
                    children: [
                      const Kicker('Six months'),
                      const Spacer(),
                      if (climb != 0)
                        Text(
                          '${climb > 0 ? '+' : ''}$climb',
                          style: AppTheme.monoNumbers(
                            size: 18,
                            weight: FontWeight.w600,
                            color: climb > 0
                                ? AppTheme.green
                                : AppTheme.rose,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    history.isEmpty
                        ? 'No history yet — your index will build a '
                            'story month by month.'
                        : 'The climb is the story — '
                            '${history.first.index} to ${history.last.index}'
                            ' in six months.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  if (history.isNotEmpty)
                    SizedBox(
                      height: 140,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final point in history)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${point.index}',
                                      style: AppTheme.monoNumbers(size: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          width: double.infinity,
                                          height: 100 *
                                              (point.index / 100) *
                                              0.9,
                                          decoration: BoxDecoration(
                                            gradient: AppTheme.ctaGradient,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      point.monthLabel,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Kicker('Recent check-ins'),
            const SizedBox(height: 12),
            if (checkins.isEmpty)
              GlassCard(
                child: Text(
                  'No check-ins yet. Your first one starts the story.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    for (final entry in checkins.take(14))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.glassStrong,
                          child: Text(
                            '${entry.score}',
                            style: AppTheme.monoNumbers(size: 13),
                          ),
                        ),
                        title: Text(formatDayKey(entry.dayKey)),
                        subtitle: Text(
                          entry.isDemo ? 'Seeded demo' : 'Your check-in',
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: Text(
                          '${entry.answers.length} questions',
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
