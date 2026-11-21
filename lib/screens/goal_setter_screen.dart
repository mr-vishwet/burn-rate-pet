import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../engine/budget.dart';
import '../engine/happiness.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 17 Goal Setter: a monthly budget that feels right, and the happiness
/// goal beside it — with a live projection of what the goal would mean
/// for the index.
class GoalSetterScreen extends StatefulWidget {
  /// Creates the goal setter screen.
  const GoalSetterScreen({super.key});

  @override
  State<GoalSetterScreen> createState() => _GoalSetterScreenState();
}

class _GoalSetterScreenState extends State<GoalSetterScreen> {
  final _budgetController = TextEditingController();
  double _happinessGoal = 80;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    final controller = MomoScope.read(context);
    _budgetController.text =
        (controller.state.monthlyBudgetGoalCents ~/ 100).toString();
    _happinessGoal = controller.state.happinessGoal.toDouble();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final currency = controller.state.currency;
    final budgetGoal =
        (int.tryParse(_budgetController.text.trim()) ?? 0) * 100;
    // Live projection: if spending landed on the goal, what would the
    // budget score (and the index) be?
    final projectedBudget = simulateTotalSpent(
      categories: controller.state.categories,
      newSpentCents: budgetGoal,
    );
    final mood = controller.moodScore;
    final routines = controller.routineScoreValue;
    final projectedIndex = (mood != null && routines != null)
        ? HappinessIndex.rounded(
            mood: mood,
            routines: routines,
            budget: projectedBudget,
          )
        : null;
    final onTrack =
        controller.spentCents <= controller.state.monthlyBudgetGoalCents;
    return AppScaffold(
      title: 'Goal Setter',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: MomoAvatar(size: 96, mood: MomoMood.cheer)),
            const SizedBox(height: 12),
            Text(
              onTrack
                  ? "A ${formatMoney(controller.state.monthlyBudgetGoalCents, currency)} month feels right — you're on track"
                  : 'A goal is a direction, not a scolding',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (onTrack) ...[
              const SizedBox(height: 6),
              Text(
                'With ${formatMoney(controller.leftCents, currency)} to '
                'spare. Momo says so, proudly.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.peachSoft,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('Monthly budget goal'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      prefixText: '\$ ',
                      labelText: 'A month that feels right',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final suggestion in [220000, 240000, 200000])
                        ActionChip(
                          label: Text(
                            formatMoney(suggestion, currency),
                          ),
                          onPressed: () {
                            _budgetController.text =
                                (suggestion ~/ 100).toString();
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Momo offers ${formatMoney(220000, currency)}: staying '
                    'under it would lift your budget score to '
                    '${simulateTotalSpent(categories: controller.state.categories, newSpentCents: 220000)}.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Kicker('Happiness goal'),
                      const Spacer(),
                      Text(
                        _happinessGoal.round().toString(),
                        style: AppTheme.monoNumbers(
                          size: 20,
                          weight: FontWeight.w600,
                          color: AppTheme.peach,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _happinessGoal,
                    min: 40,
                    max: 100,
                    divisions: 12,
                    label: _happinessGoal.round().toString(),
                    onChanged: (value) =>
                        setState(() => _happinessGoal = value),
                  ),
                  Text(
                    'Aim for ${HappinessIndex.bandFor(_happinessGoal.round()).label} '
                    '(${HappinessIndex.bandFor(_happinessGoal.round()).rangeLabel}). '
                    'The index you are working toward.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('What the goal would mean'),
                  const SizedBox(height: 8),
                  Text(
                    projectedIndex == null
                        ? 'Set a budget and complete a check-in to see the '
                            'projection.'
                        : 'Spending ${formatMoney(budgetGoal, currency)} '
                            'this month → budget $projectedBudget, index '
                            '~$projectedIndex '
                            '(${HappinessIndex.bandFor(projectedIndex).label}).',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Save my goals',
              icon: Icons.flag_outlined,
              onPressed: () async {
                await controller.setGoals(
                  happinessGoal: _happinessGoal.round(),
                  monthlyBudgetGoalCents: budgetGoal,
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Goals saved. Momo is rooting for you.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
