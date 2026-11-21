import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 11 Widget: the home-screen widget — Momo, the index, the band.
/// Amounts never shown. Safe for a screenshot, by design.
///
/// v0.1: the widget state is ready (index + band only) and this screen
/// previews all three sizes. The native home-screen widget itself needs
/// platform code and is phase-2 work.
class WidgetScreen extends StatelessWidget {
  /// Creates the widget screen.
  const WidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final snapshot = controller.widgetSnapshot;
    final index = snapshot.index;
    final bandLabel = snapshot.bandLabel ?? '—';
    return AppScaffold(
      title: 'Widget',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Home-screen widget',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Switch(
                  value: controller.state.widgetEnabled,
                  onChanged: (value) =>
                      controller.setCompanion(widgetEnabled: value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Medium widget preview.
            GlassCard(
              child: Row(
                children: [
                  const MomoAvatar(size: 84, bob: false),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              index == null ? '—' : '$index',
                              style: AppTheme.monoNumbers(
                                size: 32,
                                weight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              bandLabel,
                              style: theme.textTheme.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.checkinDueToday
                              ? 'Check-in due · 10 questions'
                              : "Today's check-in is done",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SizePreview(
                    label: 'Small',
                    child: Column(
                      children: [
                        const MomoAvatar(size: 48, bob: false),
                        const SizedBox(height: 4),
                        Text(
                          index == null ? '—' : '$index',
                          style: AppTheme.monoNumbers(
                            size: 18,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SizePreview(
                    label: 'Large',
                    child: Column(
                      children: [
                        const MomoAvatar(size: 48, bob: false),
                        const SizedBox(height: 4),
                        Text(
                          '${index ?? '—'} · $bandLabel',
                          style: AppTheme.monoNumbers(size: 14),
                        ),
                        Text(
                          '${controller.routinesDoneTodayCount} of '
                          '${controller.state.routines.length} routines',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppTheme.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The widget shows the band and the index, never the '
                      'amounts. Safe for a screenshot.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: 'Add widget',
              icon: Icons.add,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'v0.1: the widget preview lives here. The native '
                      'home-screen widget needs platform code — phase 2.',
                    ),
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

class _SizePreview extends StatelessWidget {
  const _SizePreview({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
