import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../engine/routines.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 08 Routines: six fixed days, kindly kept — done today, streaks, and
/// the kind rule. Tap a routine for its detail; add your own.
class RoutinesScreen extends StatelessWidget {
  /// Creates the routines screen.
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final routines = controller.state.routines;
    final today = dayKey(DateTime.now());
    final done = controller.routinesDoneTodayCount;
    final best = controller.bestStreak;
    return AppScaffold(
      title: 'Routines',
      bottomNavIndex: 2,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRoutine(context),
        backgroundColor: AppTheme.coral,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add routine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const MomoAvatar(size: 64, mood: MomoMood.content, bob: false),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$done of ${routines.length} done today',
                        style: theme.textTheme.titleLarge,
                      ),
                      if (best.days > 0)
                        Text(
                          'Longest streak: ${best.days} days '
                          '(${best.routine})',
                          style: theme.textTheme.bodySmall,
                        ),
                      Text(
                        'Streaks pause, they don\'t punish.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.peach,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (routines.isEmpty)
              GlassCard(
                child: Column(
                  children: [
                    Text(
                      'No routines yet',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first routine — a wake time, a workout, '
                      'a walk. Momo keeps the streak kindly.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      label: 'Add your first routine',
                      icon: Icons.add,
                      onPressed: () => _showAddRoutine(context),
                    ),
                  ],
                ),
              )
            else
              for (final routine in routines) ...[
                _RoutineTile(routine: routine, todayKey: today),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 12),
            GlassCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite_outline,
                    color: AppTheme.peach,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The kind rule: a missed day is a grey circle, not a '
                      'red one. Your streak waits for you — it never '
                      'resets to zero.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddRoutine(BuildContext context) async {
    final nameController = TextEditingController();
    final timeController = TextEditingController(text: '8:00 AM');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New routine'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Routine name',
                hintText: 'Morning pages',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'When? (label only)',
                hintText: '8:00 AM',
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
    if (result == true && nameController.text.trim().isNotEmpty) {
      await MomoScope.read(context).addRoutine(
        name: nameController.text.trim(),
        timeLabel: timeController.text.trim(),
      );
    }
    nameController.dispose();
    timeController.dispose();
  }
}

class _RoutineTile extends StatelessWidget {
  const _RoutineTile({required this.routine, required this.todayKey});

  final Routine routine;
  final String todayKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = routine.doneOn(todayKey);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: GestureDetector(
          onTap: () =>
              MomoScope.read(context).toggleRoutineDone(routine.id),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: done ? AppTheme.ctaGradient : null,
              border: Border.all(
                color: done ? AppTheme.peach : AppTheme.hairlineStrong,
                width: 2,
              ),
            ),
            child: done
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          routine.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: done ? TextDecoration.lineThrough : null,
            decorationColor: AppTheme.taupe,
          ),
        ),
        subtitle: Text(
          '${routine.timeLabel} · '
          '${routine.streakDays}-day streak'
          '${routine.isStreakPaused ? ' (paused)' : ''}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.taupe,
        ),
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.routineDetail,
          arguments: routine.id,
        ),
      ),
    );
  }
}
