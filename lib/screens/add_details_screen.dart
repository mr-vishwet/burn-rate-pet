import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../app_routes.dart';
import '../engine/budget.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 04 Add Your Details: one budget, five categories, thirty seconds —
/// stored on-device only. Pre-filled with the demo plan; edit freely.
class AddDetailsScreen extends StatefulWidget {
  /// Creates the details screen.
  const AddDetailsScreen({super.key});

  @override
  State<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> {
  final _totalController = TextEditingController();
  final List<TextEditingController> _categoryControllers = [];
  List<BudgetCategory> _categories = [];
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    final controller = MomoScope.read(context);
    _categories = List<BudgetCategory>.of(controller.state.categories);
    if (_categories.isEmpty) {
      _categories = [
        BudgetCategory(id: 'cat-new-0', name: 'Food', plannedCents: 52000),
        BudgetCategory(
          id: 'cat-new-1',
          name: 'Transport',
          plannedCents: 18000,
        ),
        BudgetCategory(id: 'cat-new-2', name: 'Fun', plannedCents: 26000),
        BudgetCategory(id: 'cat-new-3', name: 'Home', plannedCents: 115000),
        BudgetCategory(id: 'cat-new-4', name: 'Health', plannedCents: 29000),
      ];
    }
    final total = _categories.fold<int>(
      0,
      (sum, c) => sum + c.plannedCents,
    );
    _totalController.text = (total ~/ 100).toString();
    for (final category in _categories) {
      _categoryControllers.add(
        TextEditingController(
          text: (category.plannedCents ~/ 100).toString(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _totalController.dispose();
    for (final c in _categoryControllers) {
      c.dispose();
    }
    super.dispose();
  }

  int _parse(TextEditingController controller) {
    final value = int.tryParse(controller.text.trim()) ?? 0;
    return value < 0 ? 0 : value;
  }

  Future<void> _save() async {
    final controller = MomoScope.read(context);
    final updated = <BudgetCategory>[];
    for (var i = 0; i < _categories.length; i++) {
      final category = _categories[i];
      updated.add(
        BudgetCategory(
          id: category.id,
          name: category.name,
          plannedCents: _parse(_categoryControllers[i]) * 100,
          spentCents: category.spentCents,
        ),
      );
    }
    final goal = _parse(_totalController) * 100;
    await controller.saveDetails(
      categories: updated,
      monthlyBudgetGoalCents: goal,
    );
    await controller.completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Add Your Details',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: MomoAvatar(size: 96)),
            const SizedBox(height: 16),
            Text(
              'One budget, five categories, thirty seconds',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Stored on-device only. Momo never uploads your numbers.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('Monthly budget goal'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _totalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      prefixText: '\$ ',
                      hintText: '2400',
                      labelText: 'A month that feels right',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Kicker('Categories — planned per month'),
                  const SizedBox(height: 8),
                  for (var i = 0; i < _categories.length; i++) ...[
                    TextField(
                      controller: _categoryControllers[i],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        labelText: _categories[i].name,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Wake Momo up',
              icon: Icons.pets_outlined,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
