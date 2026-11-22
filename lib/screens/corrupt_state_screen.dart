import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../services/import_service.dart';
import '../services/storage_service.dart';
import '../state/momo_controller.dart';
import '../state/momo_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';
import 'import_confirm_screen.dart';

/// Minimal app shell for the corrupt-state screen: a plain [MaterialApp]
/// with the Momo theme and no controller, no scope, no routes — the
/// state could not be loaded, so the normal app shell cannot run.
class CorruptStateApp extends StatelessWidget {
  /// Creates the shell around [screen].
  const CorruptStateApp({required this.screen, super.key});

  /// The error screen to show.
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momo',
      theme: AppTheme.theme,
      home: screen,
    );
  }
}

/// The corrupt-state error screen: shown instead of the app when the
/// stored state document cannot be read ([CorruptStateException]), or
/// when storage itself is unavailable (the storage-unavailable
/// constructor).
///
/// Nothing is ever silently discarded here: the corrupt document stays
/// on the device until the user chooses Restore from backup (which
/// replaces it with a backup they picked and confirmed) or Start fresh
/// (which removes it after an explicit confirmation).
class CorruptStateScreen extends StatelessWidget {
  /// Corrupt document: restore from backup or start fresh.
  const CorruptStateScreen({
    required this.store,
    required this.onRecovered,
    super.key,
  }) : storageUnavailable = false;

  /// Storage unavailable: nothing can be read or written, so the only
  /// path is to try again.
  const CorruptStateScreen.storageUnavailable({
    required this.onRecovered,
    super.key,
  }) : store = null,
       storageUnavailable = true;

  /// The storage service (null when storage itself is unavailable).
  final StorageService? store;

  /// Called after a successful recovery (backup restored, fresh start,
  /// or retry) — the caller re-runs the boot flow.
  final Future<void> Function() onRecovered;

  /// Whether storage itself is unavailable (as opposed to the stored
  /// document being corrupt).
  final bool storageUnavailable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Momo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: MomoAvatar(size: 96, mood: MomoMood.sleepy),
                ),
                const SizedBox(height: 12),
                Text(
                  storageUnavailable
                      ? "Momo couldn't reach your data"
                      : "Momo couldn't open your data",
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  storageUnavailable
                      ? 'Your browser storage is not available right now '
                          '— it may be blocked or full. Nothing has been '
                          'deleted. Try again, and if it keeps happening, '
                          'check your browser storage settings.'
                      : 'The data saved on this device could not be read '
                          '— it may have been damaged by an interrupted '
                          'save. Nothing has been deleted: restore a '
                          'backup, or start fresh.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.peachSoft,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (storageUnavailable)
                  GradientButton(
                    label: 'Try again',
                    icon: Icons.refresh_outlined,
                    onPressed: () => onRecovered(),
                  )
                else ...[
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Kicker('Restore from backup'),
                        const SizedBox(height: 8),
                        Text(
                          'Pick the JSON file you exported from Data '
                          'Controls. You will see what is in it before '
                          'anything is replaced.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        GradientButton(
                          label: 'Restore from backup',
                          icon: Icons.restore_outlined,
                          onPressed: () => _restoreFromBackup(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Kicker('Start fresh'),
                        const SizedBox(height: 8),
                        Text(
                          'Removes the unreadable saved data and starts '
                          'Momo empty, as on a first install. Your '
                          'backup files elsewhere are not touched.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => _startFresh(context),
                          child: const Text(
                            'Start fresh',
                            style: TextStyle(color: AppTheme.rose),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _restoreFromBackup(BuildContext context) async {
    final store = this.store;
    if (store == null) return;
    final String? text;
    try {
      text = await ImportService.pickBackupText();
    } on ImportFormatException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    if (text == null) return; // User cancelled the picker.
    final MomoState imported;
    try {
      imported = ImportService.parseBackup(text);
    } on ImportFormatException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => ImportConfirmScreen(
          imported: imported,
          currentDescription:
              "Your saved data on this device couldn't be read, so this "
              'backup becomes your Momo.',
          onConfirm: () async {
            await store.write(jsonEncode(imported.toJson()));
            await onRecovered();
          },
        ),
      ),
    );
  }

  Future<void> _startFresh(BuildContext context) async {
    final store = this.store;
    if (store == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start fresh?'),
        content: const Text(
          'The unreadable saved data will be removed and Momo will start '
          'empty, as on a first install. This cannot be undone — but if '
          'you have a backup file, restore it instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Go back'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.rose,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Start fresh'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await store.clear();
      await onRecovered();
    }
  }
}
