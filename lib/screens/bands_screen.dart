import 'package:material_ui/material_ui.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../engine/happiness.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 13 Happiness Bands: Thriving, Content, Low, Struggling — plus budget
/// health below. "You are here" sits on the current band.
class BandsScreen extends StatelessWidget {
  /// Creates the bands screen.
  const BandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final band = controller.band;
    final index = controller.index;
    final currency = controller.state.currency;
    return AppScaffold(
      title: 'Happiness Bands',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Four moods, one number',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'The band — not the number — is the point. Momo feels the '
              'index, and reacts to where you are.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.peachSoft,
              ),
            ),
            const SizedBox(height: 16),
            for (final b in HappinessBand.values) ...[
              _BandCard(
                band: b,
                isHere: b == band,
                index: index,
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            const Kicker('Budget health · the third input'),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Budget score ${controller.budgetScoreValue}',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        controller.budgetScoreValue >= 70
                            ? 'On track'
                            : controller.budgetScoreValue >= 45
                                ? 'Watch it'
                                : 'Needs care',
                        style: AppTheme.monoNumbers(
                          size: 13,
                          color: controller.budgetScoreValue >= 70
                              ? AppTheme.green
                              : AppTheme.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${formatMoney(controller.spentCents, currency)} of '
                    '${formatMoney(controller.plannedCents, currency)} '
                    'this month',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Budget ${controller.budgetScoreValue} · contributes '
                    '${controller.budgetScoreValue} × 25% to the index',
                    style: theme.textTheme.bodySmall,
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

class _BandCard extends StatelessWidget {
  const _BandCard({
    required this.band,
    required this.isHere,
    required this.index,
  });

  final HappinessBand band;
  final bool isHere;
  final int? index;

  MomoMood get _mood {
    switch (band) {
      case HappinessBand.thriving:
        return MomoMood.cheer;
      case HappinessBand.content:
        return MomoMood.happy;
      case HappinessBand.low:
        return MomoMood.low;
      case HappinessBand.struggling:
        return MomoMood.sleepy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHere ? band.color : AppTheme.hairline,
          width: isHere ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          MomoAvatar(size: 56, mood: _mood, bob: false),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      band.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: band.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      band.rangeLabel,
                      style: AppTheme.monoNumbers(
                        size: 13,
                        color: AppTheme.peachSoft,
                      ),
                    ),
                    if (isHere) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: band.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'YOU ARE HERE · ${index ?? '—'}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: band.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(band.momoNote, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
