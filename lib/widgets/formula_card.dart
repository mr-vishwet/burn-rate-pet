import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../engine/happiness.dart';
import 'glass_card.dart';

/// The formula card — the Happiness Index formula, shown in the open,
/// with each input's contribution. Never hidden behind a tap.
///
///   Check-ins 76 × 40% = 30.4
///   Routines  72 × 35% = 25.2
///   Budget    78 × 25% = 19.5
///   = 75.1 → 75 · Content
class FormulaCard extends StatelessWidget {
  /// Creates the formula card.
  const FormulaCard({
    required this.mood,
    required this.routines,
    required this.budget,
    super.key,
  });

  /// Mood component (0-100).
  final int mood;

  /// Routine component (0-100).
  final int routines;

  /// Budget component (0-100).
  final int budget;

  @override
  Widget build(BuildContext context) {
    final parts = HappinessIndex.contributions(
      mood: mood,
      routines: routines,
      budget: budget,
    );
    final raw = HappinessIndex.raw(
      mood: mood,
      routines: routines,
      budget: budget,
    );
    final index = raw.round();
    final band = HappinessIndex.bandFor(index);
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Kicker('The formula, shown'),
          const SizedBox(height: 12),
          _FormulaLine(
            label: 'Check-ins',
            value: mood,
            weight: '40%',
            contribution: parts.mood,
          ),
          const SizedBox(height: 6),
          _FormulaLine(
            label: 'Routines',
            value: routines,
            weight: '35%',
            contribution: parts.routines,
          ),
          const SizedBox(height: 6),
          _FormulaLine(
            label: 'Budget',
            value: budget,
            weight: '25%',
            contribution: parts.budget,
          ),
          const Divider(color: AppTheme.hairline, height: 24),
          Row(
            children: [
              Text(
                '= ${raw.toStringAsFixed(1)} → $index',
                style: AppTheme.monoNumbers(
                  size: 16,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '· ${band.label}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: band.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Mood 40% + routines 35% + budget 25%. The band — not the '
            'number — is the point.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _FormulaLine extends StatelessWidget {
  const _FormulaLine({
    required this.label,
    required this.value,
    required this.weight,
    required this.contribution,
  });

  final String label;
  final int value;
  final String weight;
  final double contribution;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Text(
            '$value × $weight',
            style: AppTheme.monoNumbers(size: 13, color: AppTheme.peachSoft),
          ),
        ),
        Text(
          '= ${contribution.toStringAsFixed(1)}',
          style: AppTheme.monoNumbers(size: 13),
        ),
      ],
    );
  }
}
