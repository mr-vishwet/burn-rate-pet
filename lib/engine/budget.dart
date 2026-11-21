import '../core/constants.dart';

/// The budget planner/tracker: one monthly plan, five (or more) spending
/// categories, spent vs planned per category. Budget health feeds the
/// Happiness Index as its third input (25%).
///
/// Budget score formula (0-100), shown on the Budget screen:
///
///   score = 100 − 48 × max(0, utilization − 0.35) − 15 × overCategories
///
/// where utilization = spent / planned for the month. Spending up to 35%
/// of the plan costs nothing; past that, each 10% of utilization costs
/// ~5 points; each category over its plan costs 15 points. Clamped 0-100.
///
/// The formula is deliberately gentle: Momo notices, it never scolds.
class BudgetCategory {
  /// Creates a budget category. Amounts in cents.
  BudgetCategory({
    required this.id,
    required this.name,
    required this.plannedCents,
    this.spentCents = 0,
  });

  /// Stable id.
  final String id;

  /// Display name, e.g. "Food".
  final String name;

  /// Planned spend for the month, in cents.
  int plannedCents;

  /// Spent so far this month, in cents.
  int spentCents;

  /// Utilization 0.0+ (1.0 = exactly on plan). 0 when unplanned.
  double get utilization =>
      plannedCents <= 0 ? 0 : spentCents / plannedCents;

  /// Whether this category has gone over its plan.
  bool get isOver => spentCents > plannedCents;

  /// Cents left in this category (negative when over).
  int get leftCents => plannedCents - spentCents;

  /// Serializes the category to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'plannedCents': plannedCents,
    'spentCents': spentCents,
  };

  /// Deserializes a category from JSON.
  factory BudgetCategory.fromJson(Map<String, dynamic> json) =>
      BudgetCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        plannedCents: json['plannedCents'] as int? ?? 0,
        spentCents: json['spentCents'] as int? ?? 0,
      );
}

/// One logged expense. v0.1 logs manually; bank sync is a phase-2 idea
/// (and would stay opt-in, on-device).
class Expense {
  /// Creates an expense. Amounts in cents.
  Expense({
    required this.id,
    required this.categoryId,
    required this.amountCents,
    required this.note,
    required this.dayKey,
  });

  /// Stable id.
  final String id;

  /// Category id this expense belongs to.
  final String categoryId;

  /// Amount in cents.
  final int amountCents;

  /// Short note, e.g. "Groceries".
  final String note;

  /// Day key (yyyy-MM-dd) the expense happened.
  final String dayKey;

  /// Serializes the expense to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'amountCents': amountCents,
    'note': note,
    'dayKey': dayKey,
  };

  /// Deserializes an expense from JSON.
  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as String,
    categoryId: json['categoryId'] as String,
    amountCents: json['amountCents'] as int? ?? 0,
    note: json['note'] as String? ?? '',
    dayKey: json['dayKey'] as String? ?? '',
  );
}

/// Budget score (0-100) for a month. Pure function — the simulator on the
/// Budget screen calls it with hypothetical numbers.
int budgetScore({
  required int spentCents,
  required int plannedCents,
  required int overCategoryCount,
}) {
  if (plannedCents <= 0) return 100;
  final utilization = spentCents / plannedCents;
  final over = utilization - kBudgetFreeUtilization;
  final penalty = (over > 0 ? over * kBudgetSlope : 0) +
      overCategoryCount * kBudgetOverCategoryPenalty;
  return (100 - penalty).round().clamp(0, 100);
}

/// Simulates a budget score if one category's planned amount changed to
/// [newPlannedCents] (spending unchanged). Returns the simulated score.
int simulateCategoryPlan({
  required List<BudgetCategory> categories,
  required String categoryId,
  required int newPlannedCents,
}) {
  var spent = 0;
  var planned = 0;
  var over = 0;
  for (final category in categories) {
    final plan = category.id == categoryId
        ? newPlannedCents
        : category.plannedCents;
    spent += category.spentCents;
    planned += plan;
    if (category.spentCents > plan) over++;
  }
  return budgetScore(
    spentCents: spent,
    plannedCents: planned,
    overCategoryCount: over,
  );
}

/// Simulates a budget score if total monthly spending became
/// [newSpentCents] (plans unchanged).
int simulateTotalSpent({
  required List<BudgetCategory> categories,
  required int newSpentCents,
}) {
  final planned = categories.fold<int>(
    0,
    (sum, c) => sum + c.plannedCents,
  );
  final over = categories.where((c) => c.isOver).length;
  return budgetScore(
    spentCents: newSpentCents,
    plannedCents: planned,
    overCategoryCount: over,
  );
}
