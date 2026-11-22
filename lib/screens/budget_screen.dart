import 'package:material_ui/material_ui.dart';
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
    final currency = controller.state.currency;
    final rows = <Widget>[];

    // One row per top category (biggest plan first): what if this
    // category's plan were 10% tighter? Built from the user's own
    // categories — no hardcoded names or amounts.
    final byPlan = List<BudgetCategory>.of(categories)
      ..sort((a, b) => b.plannedCents.compareTo(a.plannedCents));
    for (final category in byPlan.take(3)) {
      final tighter = (category.plannedCents * 0.9).round();
      if (tighter <= 0 || tighter == category.plannedCents) continue;
      rows.add(
        SimulatorRow(
          label:
              '${category.name} ${formatMoney(tighter, currency)}/mo',
          score: simulateCategoryPlan(
            categories: categories,
            categoryId: category.id,
            newPlannedCents: tighter,
          ),
          onTap: () => MomoScope.read(context).updateCategoryPlan(
            category.id,
            tighter,
          ),
        ),
      );
    }
    rows.add(
      SimulatorRow(
        label:
            '${formatMoney(controller.spentCents, currency)} spent',
        score: controller.budgetScoreValue,
        isCurrent: true,
      ),
    );
    // The "under X total" row uses the user's own monthly goal (or the
    // plan total when no goal is set).
    final goal = controller.state.monthlyBudgetGoalCents > 0
        ? controller.state.monthlyBudgetGoalCents
        : controller.plannedCents;
    if (goal > 0) {
      rows.add(
        SimulatorRow(
          label: 'Under ${formatMoney(goal, currency)}/mo total',
          score: simulateTotalSpent(
            categories: categories,
            newSpentCents: goal,
          ),
        ),
      );
    }
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
    final currency = controller.state.currency;
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
              initialValue: categoryId,
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}'),
                ),
              ],
              decoration: InputDecoration(
                prefixText: '${currencySymbol(currency)} ',
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
    final amountCents = parseMoneyToCents(amountController.text);
    if (result == true && amountCents > 0) {
      await controller.addExpense(
        categoryId: categoryId,
        amountCents: amountCents,
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
    final currency = controller.state.currency;
    final planController = TextEditingController(
      text: moneyInputText(category.plannedCents),
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${category.name} — monthly plan'),
        content: TextField(
          controller: planController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d*\.?\d{0,2}'),
            ),
          ],
          decoration: InputDecoration(
            prefixText: '${currencySymbol(currency)} ',
          ),
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
      final plannedCents = parseMoneyToCents(planController.text);
      await controller.updateCategoryPlan(category.id, plannedCents);
    } else if (result == 'delete') {
      await controller.deleteCategory(category.id);
    }
    planController.dispose();
  }

  Future<void> _showAddCategory(BuildContext context) async {
    final controller = MomoScope.read(context);
    final currency = controller.state.currency;
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}'),
                ),
              ],
              decoration: InputDecoration(
                prefixText: '${currencySymbol(currency)} ',
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
    final plannedCents = parseMoneyToCents(planController.text);
    if (result == true && nameController.text.trim().isNotEmpty) {
      await controller.addCategory(
        name: nameController.text.trim(),
        plannedCents: plannedCents,
      );
    }
    nameController.dispose();
    planController.dispose();
  }
}
