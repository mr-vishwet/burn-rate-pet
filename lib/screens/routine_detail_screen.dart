import 'package:material_ui/material_ui.dart';

import '../app_routes.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../engine/routines.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 09 Routine Detail: the streak, the week, and the kind rule. Rename or
/// delete the routine here.
class RoutineDetailScreen extends StatelessWidget {
  /// Creates the routine detail screen.
  const RoutineDetailScreen({required this.routineId, super.key});

  /// Id of the routine to show.
  final String routineId;

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    Routine? routine;
    for (final r in controller.state.routines) {
      if (r.id == routineId) routine = r;
    }
    if (routine == null) {
      return AppScaffold(
        title: 'Routine',
        showBack: true,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MomoAvatar(size: 96, mood: MomoMood.sleeping),
                const SizedBox(height: 16),
                Text(
                  'That routine is gone',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                GradientButton(
                  label: 'Back to routines',
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.routines,
                    (route) => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final today = dayKey(DateTime.now());
    final doneToday = routine.doneOn(today);
    final week = List<DateTime>.generate(
      7,
      (i) => DateTime.now().subtract(Duration(days: 6 - i)),
    );
    final weekDone = week.where((d) => routine!.doneOn(dayKey(d))).length;
    return AppScaffold(
      title: routine.name,
      showBack: true,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'rename') {
              await _rename(context, routine!);
            } else if (value == 'delete') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete "${routine!.name}"?'),
                  content: const Text(
                    'Its history goes with it. No guilt — routines '
                    'come and go.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Keep it'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await MomoScope.read(context).deleteRoutine(routine!.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'rename', child: Text('Rename')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Row(
                children: [
                  MomoAvatar(
                    size: 72,
                    mood: routine.isStreakPaused
                        ? MomoMood.low
                        : MomoMood.happy,
                    bob: false,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${routine.streakDays}-day streak',
                          style: AppTheme.monoNumbers(
                            size: 24,
                            weight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          routine.isStreakPaused
                              ? 'Paused — waiting for you, not reset.'
                              : routine.timeLabel.isEmpty
                                  ? 'Kept kindly, one day at a time.'
                                  : 'Every day · ${routine.timeLabel}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
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
                      const Kicker('This week'),
                      const Spacer(),
                      Text(
                        '$weekDone / 7',
                        style: AppTheme.monoNumbers(size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final day in week)
                        _WeekDot(
                          day: day,
                          done: routine.doneOn(dayKey(day)),
                          isToday: dayKey(day) == today,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The kind rule, stated twice: streaks pause, they '
                    "don't punish. A missed day is a grey circle, not a "
                    'red one.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: doneToday
                  ? 'Done today — tap to undo'
                  : 'Mark done today',
              icon: doneToday ? Icons.undo : Icons.check,
              onPressed: () =>
                  MomoScope.read(context).toggleRoutineDone(routine!.id),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context, Routine routine) async {
    final controller = MomoScope.read(context);
    final nameController = TextEditingController(text: routine.name);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename routine'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Routine name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == true && nameController.text.trim().isNotEmpty) {
      await controller.renameRoutine(
        routine.id,
        nameController.text.trim(),
      );
    }
    nameController.dispose();
  }
}

class _WeekDot extends StatelessWidget {
  const _WeekDot({
    required this.day,
    required this.done,
    required this.isToday,
  });

  final DateTime day;
  final bool done;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: done ? AppTheme.ctaGradient : null,
            color: done ? null : AppTheme.glass,
            border: Border.all(
              color: isToday ? AppTheme.peach : AppTheme.hairline,
              width: isToday ? 2 : 1,
            ),
          ),
          child: done
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          weekdays[day.weekday - 1],
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
