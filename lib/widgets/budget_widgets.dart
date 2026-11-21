import 'package:material_ui/material_ui.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../engine/budget.dart';

/// A category's spent-vs-planned bar: name, amounts, and a fill that
/// turns rose when the category goes over plan.
class CategoryBar extends StatelessWidget {
  /// Creates a category bar.
  const CategoryBar({
    required this.category,
    required this.currency,
    this.onTap,
    super.key,
  });

  /// The category to show.
  final BudgetCategory category;

  /// Display currency code.
  final String currency;

  /// Optional tap handler (opens the plan editor).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = category.utilization.clamp(0.0, 1.0);
    final color = category.isOver ? AppTheme.rose : AppTheme.green;
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${formatMoney(category.spentCents, currency)} of '
                '${formatMoney(category.plannedCents, currency)}',
                style: AppTheme.monoNumbers(
                  size: 13,
                  color: AppTheme.peachSoft,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(category.utilization * 100).round()}%',
                style: AppTheme.monoNumbers(
                  size: 13,
                  color: color,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: AppTheme.hairline,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (category.isOver) ...[
            const SizedBox(height: 4),
            Text(
              '${formatMoney(-category.leftCents, currency)} over plan — '
              'Momo notes it, no scolding.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.rose),
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: content,
    );
  }
}

/// One simulator row: "If Food dropped to $450 → budget 81".
class SimulatorRow extends StatelessWidget {
  /// Creates a simulator row.
  const SimulatorRow({
    required this.label,
    required this.score,
    this.isCurrent = false,
    this.onTap,
    super.key,
  });

  /// What changes, e.g. "Food \$450/mo".
  final String label;

  /// Simulated budget score.
  final int score;

  /// Whether this row is the current state.
  final bool isCurrent;

  /// Optional tap handler (applies the change).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.glassStrong,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'NOW',
                style: theme.textTheme.labelSmall,
              ),
            ),
          const SizedBox(width: 12),
          Text(
            '$score',
            style: AppTheme.monoNumbers(
              size: 18,
              weight: FontWeight.w600,
              color: isCurrent ? AppTheme.peach : AppTheme.green,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: row,
    );
  }
}
