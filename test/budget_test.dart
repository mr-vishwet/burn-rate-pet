import 'package:flutter_test/flutter_test.dart';
import 'package:momo/engine/budget.dart';

void main() {
  group('budgetScore', () {
    test('a month 80.7% spent, no category over plan, scores 78', () {
      expect(
        budgetScore(
          spentCents: 193600,
          plannedCents: 240000,
          overCategoryCount: 0,
        ),
        78,
      );
    });

    test('spending under 35% of plan scores 100', () {
      expect(
        budgetScore(
          spentCents: 35000,
          plannedCents: 100000,
          overCategoryCount: 0,
        ),
        100,
      );
      expect(
        budgetScore(
          spentCents: 0,
          plannedCents: 100000,
          overCategoryCount: 0,
        ),
        100,
      );
    });

    test('each over-plan category costs 15 points', () {
      final clean = budgetScore(
        spentCents: 80000,
        plannedCents: 100000,
        overCategoryCount: 0,
      );
      final oneOver = budgetScore(
        spentCents: 80000,
        plannedCents: 100000,
        overCategoryCount: 1,
      );
      expect(clean - oneOver, 15);
    });

    test('score clamps to 0-100', () {
      expect(
        budgetScore(
          spentCents: 1000000,
          plannedCents: 100000,
          overCategoryCount: 5,
        ),
        0,
      );
    });

    test('no plan at all scores 100 (nothing to miss)', () {
      expect(
        budgetScore(
          spentCents: 0,
          plannedCents: 0,
          overCategoryCount: 0,
        ),
        100,
      );
    });
  });

  group('simulator', () {
    List<BudgetCategory> categories() => [
      BudgetCategory(
        id: 'food',
        name: 'Food',
        plannedCents: 52000,
        spentCents: 38600,
      ),
      BudgetCategory(
        id: 'fun',
        name: 'Fun',
        plannedCents: 26000,
        spentCents: 21400,
      ),
      BudgetCategory(
        id: 'home',
        name: 'Home',
        plannedCents: 115000,
        spentCents: 109800,
      ),
    ];

    test('lowering a plan with the same spend lowers the score', () {
      final before = simulateCategoryPlan(
        categories: categories(),
        categoryId: 'food',
        newPlannedCents: 52000,
      );
      final after = simulateCategoryPlan(
        categories: categories(),
        categoryId: 'food',
        newPlannedCents: 45000,
      );
      expect(after, lessThan(before));
    });

    test('spending less raises the score', () {
      final high = simulateTotalSpent(
        categories: categories(),
        newSpentCents: 220000,
      );
      final low = simulateTotalSpent(
        categories: categories(),
        newSpentCents: 150000,
      );
      expect(low, greaterThan(high));
    });
  });

  group('BudgetCategory', () {
    test('utilization and over-plan detection', () {
      final category = BudgetCategory(
        id: 'x',
        name: 'X',
        plannedCents: 10000,
        spentCents: 9500,
      );
      expect(category.utilization, closeTo(0.95, 0.001));
      expect(category.isOver, isFalse);
      expect(category.leftCents, 500);
      category.spentCents = 10100;
      expect(category.isOver, isTrue);
      expect(category.leftCents, -100);
    });

    test('JSON round-trip', () {
      final category = BudgetCategory(
        id: 'x',
        name: 'X',
        plannedCents: 10000,
        spentCents: 5000,
      );
      final restored = BudgetCategory.fromJson(category.toJson());
      expect(restored.id, 'x');
      expect(restored.plannedCents, 10000);
      expect(restored.spentCents, 5000);
    });
  });
}
