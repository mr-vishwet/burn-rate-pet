import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../engine/budget.dart';
import '../state/momo_controller.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/budget_widgets.dart';
import '../widgets/glass_card.dart';

/// 14 Budget Tracker: five categories, spent vs planned — and the
/// simulator, which answers "what if spending changed?" live, from the
/// real budget formula.
class BudgetScreen extends StatelessWidget {
  /// Creates the budget screen.
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final currency = controller.state.currency;
    final categories = controller.state.categories;
    final change = controller.state.lastMonthSpentCents > 0
        ? (controller.spentCents - controller.state.lastMonthSpentCents) /
            controller.state.lastMonthSpentCents
        : 0.0;
    return AppScaffold(
      title: 'Budget Tracker',
      bottomNavIndex: 3,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: categories.isEmpty
            ? null
            : () => _showAddExpense(context),
        backgroundColor: AppTheme.coral,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Log expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  formatMoney(controller.spentCents, currency),
                  style: AppTheme.monoNumbers(
                    size: 36,
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'of ${formatMoney(controller.plannedCents, currency)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.peachSoft,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${change <= 0 ? '−' : '+'}${(change.abs() * 100).round()}%',
                  style: AppTheme.monoNumbers(
                    size: 15,
                    color: change <= 0 ? AppTheme.green : AppTheme.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Budget score ${controller.budgetScoreValue} · '
              '${formatMoney(controller.leftCents, currency)} left this month',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TwoColumn(
              main: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Kicker('This month'),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _showAddCategory(context),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Category'),
                        ),
                      ],
                    ),
                    if (categories.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No categories yet — add your first one, or set '
                          'up the plan from Add Your Details.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    else
                      for (final category in categories)
                        CategoryBar(
                          category: category,
                          currency: currency,
                          onTap: () => _showEditPlan(context, category),
                        ),
                  ],
                ),
              ),
              side: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Kicker('What moves the needle'),
                    const SizedBox(height: 8),
                    Text(
                      'The simulator runs the real budget formula — '
                      'what each change would mean.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    ..._simulatorRows(context, controller),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (controller.state.expenses.isNotEmpty) ...[
              const Kicker('Recent expenses'),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    for (final expense
                        in controller.state.expenses.take(8))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(expense.note),
                        subtitle: Text(
                          '${_categoryName(controller, expense.categoryId)}'
                          ' · ${formatDayKey(expense.dayKey)}',
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: Text(
                          formatMoney(expense.amountCents, currency),
                          style: AppTheme.monoNumbers(size: 14),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _categoryName(MomoController controller, String categoryId) {
    for (final c in controller.state.categories) {
      if (c.id == categoryId) return c.name;
    }
    return 'Other';
  }

  List<Widget> _simulatorRows(
    BuildContext context,
    MomoController controller,
  ) {
    final categories = controller.state.categories;
    final rows = <Widget>[];
    BudgetCategory? byName(String name) {
      for (final c in categories) {
        if (c.name == name) return c;
      }
      return null;
    }

    final food = byName('Food');
    if (food != null) {
      rows.add(
        SimulatorRow(
          label: 'Food \$450/mo',
          score: simulateCategoryPlan(
            categories: categories,
            categoryId: food.id,
            newPlannedCents: 45000,
          ),
          onTap: () => MomoScope.read(context).updateCategoryPlan(
            food.id,
            45000,
          ),
        ),
      );
    }
    rows.add(
      SimulatorRow(
        label:
            '${formatMoney(controller.spentCents, controller.state.currency)} spent',
        score: controller.budgetScoreValue,
        isCurrent: true,
      ),
    );
    final fun = byName('Fun');
    if (fun != null) {
      rows.add(
        SimulatorRow(
          label: 'Fun \$300/mo',
          score: simulateCategoryPlan(
            categories: categories,
            categoryId: fun.id,
            newPlannedCents: 30000,
          ),
          onTap: () => MomoScope.read(context).updateCategoryPlan(
            fun.id,
            30000,
          ),
        ),
      );
    }
    final home = byName('Home');
    if (home != null) {
      rows.add(
        SimulatorRow(
          label: 'Home \$1,300/mo',
          score: simulateCategoryPlan(
            categories: categories,
            categoryId: home.id,
            newPlannedCents: 130000,
          ),
          onTap: () => MomoScope.read(context).updateCategoryPlan(
            home.id,
            130000,
          ),
        ),
      );
    }
    rows.add(
      SimulatorRow(
        label: 'Under \$2,200/mo total',
        score: simulateTotalSpent(
          categories: categories,
          newSpentCents: 220000,
        ),
      ),
    );
    rows.add(
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Tap a row to apply that plan. Staying under plan lifts your '
          'budget score — and your index.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
    return rows;
  }

  Future<void> _showAddExpense(BuildContext context) async {
    final controller = MomoScope.read(context);
    final categories = controller.state.categories;
    var categoryId = categories.first.id;
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log an expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: categoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final c in categories)
                  DropdownMenuItem(value: c.id, child: Text(c.name)),
              ],
              onChanged: (value) {
                if (value != null) categoryId = value;
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                prefixText: '\$ ',
                labelText: 'Amount',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Groceries',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log it'),
          ),
        ],
      ),
    );
    final amount = int.tryParse(amountController.text.trim()) ?? 0;
    if (result == true && amount > 0) {
      await controller.addExpense(
        categoryId: categoryId,
        amountCents: amount * 100,
        note: noteController.text.trim().isEmpty
            ? 'Expense'
            : noteController.text.trim(),
      );
    }
    amountController.dispose();
    noteController.dispose();
  }

  Future<void> _showEditPlan(
    BuildContext context,
    BudgetCategory category,
  ) async {
    final controller = MomoScope.read(context);
    final planController = TextEditingController(
      text: (category.plannedCents ~/ 100).toString(),
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${category.name} — monthly plan'),
        content: TextField(
          controller: planController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(prefixText: '\$ '),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('delete'),
            child: const Text(
              'Delete category',
              style: TextStyle(color: AppTheme.rose),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop('save'),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == 'save') {
      final planned = int.tryParse(planController.text.trim()) ?? 0;
      await controller.updateCategoryPlan(category.id, planned * 100);
    } else if (result == 'delete') {
      await controller.deleteCategory(category.id);
    }
    planController.dispose();
  }

  Future<void> _showAddCategory(BuildContext context) async {
    final nameController = TextEditingController();
    final planController = TextEditingController(text: '100');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Pets',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: planController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                prefixText: '\$ ',
                labelText: 'Planned per month',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    final planned = int.tryParse(planController.text.trim()) ?? 0;
    if (result == true && nameController.text.trim().isNotEmpty) {
      await MomoScope.read(context).addCategory(
        name: nameController.text.trim(),
        plannedCents: planned * 100,
      );
    }
    nameController.dispose();
    planController.dispose();
  }
}
