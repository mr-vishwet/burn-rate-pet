import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../engine/happiness.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/formula_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/index_ring.dart';
import '../widgets/momo_avatar.dart';

/// 05 Home: Happiness Index, band, budget at a glance, check-in due,
/// routines today — and the way into every corner of the app.
class HomeScreen extends StatelessWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final currency = controller.state.currency;
    final index = controller.index;
    final band = controller.band;
    final mood = controller.moodScore;
    final routines = controller.routineScoreValue;
    final budget = controller.budgetScoreValue;
    return AppScaffold(
      title: 'Home',
      bottomNavIndex: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.settings),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (controller.state.demoSeeded)
              const Align(
                alignment: Alignment.centerLeft,
                child: DemoChip(),
              ),
            if (index == null || band == null) ...[
              const _FirstIndexCard(),
            ] else ...[
              TwoColumn(
                main: GlassCard(
                  child: Row(
                    children: [
                      IndexRing(value: index, label: band.label, size: 132),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MomoAvatar(
                              size: 56,
                              mood: _moodForBand(band),
                              bob: false,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              band.momoNote,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                side: FormulaCard(
                  mood: mood ?? 0,
                  routines: routines ?? 0,
                  budget: budget,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    value: formatMoney(controller.spentCents, currency),
                    label:
                        'of ${formatMoney(controller.plannedCents, currency)} planned',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    value: formatMoney(controller.leftCents, currency),
                    label: 'left this month',
                    accent: controller.leftCents >= 0
                        ? AppTheme.green
                        : AppTheme.rose,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    value: '${controller.routinesDoneTodayCount} of '
                        '${controller.state.routines.length}',
                    label: 'routines done today',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.checkinDueToday)
              GlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.favorite_outline, color: AppTheme.peach),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check-in due',
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            '10 questions, two minutes. Momo is listening.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    GradientButton(
                      label: 'Check in',
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRoutes.checkin,
                      ),
                    ),
                  ],
                ),
              )
            else
              GlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Today's check-in is done. Momo is proud of you.",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRoutes.checkinResult,
                      ),
                      child: const Text('See result'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const Kicker('Explore'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ExploreChip(
                  label: 'Happiness Bands',
                  icon: Icons.mood_outlined,
                  route: AppRoutes.bands,
                ),
                _ExploreChip(
                  label: 'Insights',
                  icon: Icons.lightbulb_outline,
                  route: AppRoutes.insights,
                ),
                _ExploreChip(
                  label: 'History',
                  icon: Icons.show_chart_outlined,
                  route: AppRoutes.history,
                ),
                _ExploreChip(
                  label: 'Goal Setter',
                  icon: Icons.flag_outlined,
                  route: AppRoutes.goals,
                ),
                _ExploreChip(
                  label: 'Milestones',
                  icon: Icons.emoji_events_outlined,
                  route: AppRoutes.milestone,
                ),
                _ExploreChip(
                  label: 'Overlay Bubble',
                  icon: Icons.bubble_chart_outlined,
                  route: AppRoutes.overlay,
                ),
                _ExploreChip(
                  label: 'Widget',
                  icon: Icons.widgets_outlined,
                  route: AppRoutes.widget,
                ),
                _ExploreChip(
                  label: 'Lock Screen',
                  icon: Icons.lock_outline,
                  route: AppRoutes.lockScreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  MomoMood _moodForBand(HappinessBand band) {
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
}

class _FirstIndexCard extends StatelessWidget {
  const _FirstIndexCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        children: [
          const MomoAvatar(size: 96, mood: MomoMood.sleeping),
          const SizedBox(height: 12),
          Text(
            'Your first index is waiting',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Check in once, add a routine, and set a budget — Momo will '
            'combine them into your Happiness Index. No number is invented '
            'before then.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.peachSoft,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GradientButton(
            label: 'Start with a check-in',
            icon: Icons.favorite_outline,
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.checkin),
          ),
        ],
      ),
    );
  }
}

class _ExploreChip extends StatelessWidget {
  const _ExploreChip({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppTheme.peach),
      label: Text(label),
      backgroundColor: AppTheme.glass,
      side: const BorderSide(color: AppTheme.hairline),
      onPressed: () => Navigator.of(context).pushNamed(route),
    );
  }
}
