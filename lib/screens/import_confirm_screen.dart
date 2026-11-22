import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../state/momo_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// Import confirm: shows what a backup contains and what it will
/// replace, and only replaces the current data when the user confirms.
/// Import never silently overwrites anything.
///
/// Used from Data Controls (replacing the current Momo) and from the
/// corrupt-state screen (replacing unreadable saved data). It does not
/// use the app shell — the corrupt-state flow has no controller and no
/// scope, and the desktop shell needs both.
class ImportConfirmScreen extends StatelessWidget {
  /// Creates the import confirm screen.
  const ImportConfirmScreen({
    required this.imported,
    required this.currentDescription,
    required this.onConfirm,
    super.key,
  });

  /// The parsed backup state, ready to replace the current data.
  final MomoState imported;

  /// Plain-language description of what the import replaces — the
  /// caller's current data, or the unreadable saved data on the
  /// corrupt-state screen.
  final String currentDescription;

  /// Runs the replacement (persist + notify). Called only after the
  /// user confirms. The screen pops itself afterwards.
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = imported.milestones.where((m) => m.unlocked).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Restore backup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: MomoAvatar(size: 96, mood: MomoMood.content),
                ),
                const SizedBox(height: 12),
                Text(
                  'Restore this backup?',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  currentDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.peachSoft,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Kicker('In this backup'),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        label: 'Pet',
                        value: imported.petName,
                      ),
                      _SummaryRow(
                        label: 'Check-ins',
                        value: '${imported.checkins.length}',
                      ),
                      _SummaryRow(
                        label: 'Routines',
                        value: '${imported.routines.length}',
                      ),
                      _SummaryRow(
                        label: 'Budget categories',
                        value: '${imported.categories.length}',
                      ),
                      _SummaryRow(
                        label: 'Expenses',
                        value: '${imported.expenses.length}',
                      ),
                      _SummaryRow(
                        label: 'History points',
                        value: '${imported.indexHistory.length}',
                      ),
                      _SummaryRow(
                        label: 'Milestones unlocked',
                        value: '$unlocked of ${imported.milestones.length}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Restoring replaces your current Momo completely — '
                  'this cannot be undone.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.peachSoft,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Keep my data'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        label: 'Restore backup',
                        icon: Icons.restore_outlined,
                        onPressed: () async {
                          await onConfirm();
                          if (!context.mounted) return;
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Text(
            value,
            style: AppTheme.monoNumbers(size: 14, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
