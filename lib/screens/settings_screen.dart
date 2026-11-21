import 'package:material_ui/material_ui.dart';

import '../app_routes.dart';
import '../core/constants.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 19 Settings: currency, nudges, Momo's name, bands, kindness — About
/// folded in below, plus the screen atlas and demo-data controls.
class SettingsScreen extends StatelessWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final state = controller.state;
    return AppScaffold(
      title: 'Settings',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Kicker('You'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Currency'),
                    trailing: DropdownButton<String>(
                      value: state.currency,
                      items: [
                        for (final code in kCurrencies.keys)
                          DropdownMenuItem(
                            value: code,
                            child: Text(
                              '$code (${kCurrencies[code]})',
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.updateSettings(currency: value);
                        }
                      },
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Gentle nudges'),
                    subtitle: const Text(
                      'One Sunday nudge, check-in reminders. Never more.',
                    ),
                    value: state.nudgesEnabled,
                    onChanged: (value) => controller.updateSettings(
                      nudgesEnabled: value,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Kindness mode'),
                    subtitle: const Text(
                      'Misses are met kindly, never guilt-trippy.',
                    ),
                    value: state.kindnessMode,
                    onChanged: (value) =>
                        controller.updateSettings(kindnessMode: value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Kicker('Momo'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Momo's name"),
                    subtitle: Text(state.petName),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _renamePet(context),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Floating bubble'),
                    value: state.bubbleEnabled,
                    onChanged: (value) =>
                        controller.setCompanion(bubbleEnabled: value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Home-screen widget'),
                    value: state.widgetEnabled,
                    onChanged: (value) =>
                        controller.setCompanion(widgetEnabled: value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Lock-screen check-ins'),
                    value: state.lockCheckinsEnabled,
                    onChanged: (value) => controller.setCompanion(
                      lockCheckinsEnabled: value,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Happiness bands'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.bands,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Kicker('Account'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      state.authMode.name == 'guest'
                          ? 'Guest mode'
                          : 'Account',
                    ),
                    subtitle: Text(
                      state.authMode.name == 'guest'
                          ? 'The whole pet works without an account.'
                          : state.email ?? '',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pushNamed(
                      state.authMode.name == 'guest'
                          ? AppRoutes.welcome
                          : AppRoutes.account,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Privacy first'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.privacy,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Data controls'),
                    subtitle: const Text('Export, sign out, delete'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.dataControls,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Kicker('About'),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Momo v0.1.0 — a happiness companion.',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'One Happiness Index from mood check-ins, daily '
                    'routines, and budget health. Local-first: your '
                    'numbers stay on this device. v0.1 is a first build — '
                    'sign-in is local-only and the native widget, '
                    'lock-screen extension, and system bubble are phase-2 '
                    'work.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  const MomoLockup(width: 150),
                ],
              ),
            ),
            if (state.demoSeeded) ...[
              const SizedBox(height: 20),
              const Kicker('Demo data'),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This install shows seeded demo content — the V7 '
                      'design numbers — so you can meet a living pet '
                      'first.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear demo data?'),
                            content: const Text(
                              'Removes the seeded check-ins, routines, '
                              'budget, and history. Your settings and '
                              'account stay. The formulas then run on '
                              'real activity only.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Keep demo'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Clear demo data'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true && context.mounted) {
                          await MomoScope.read(
                            context,
                          ).clearDemoData();
                        }
                      },
                      child: const Text('Clear demo data'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            ExpansionTile(
              title: const Text('All screens'),
              subtitle: const Text('Every Momo screen, in one place'),
              children: [
                for (final route in AppRoutes.all)
                  if (route != AppRoutes.splash &&
                      route != AppRoutes.routineDetail &&
                      route != AppRoutes.verify)
                    ListTile(
                      title: Text(AppRoutes.labels[route] ?? route),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () =>
                          Navigator.of(context).pushNamed(route),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renamePet(BuildContext context) async {
    final controller = MomoScope.read(context);
    final nameController = TextEditingController(
      text: controller.state.petName,
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Momo's name"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Pet name',
            hintText: 'Momo',
          ),
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
    if (result == true) {
      await controller.renamePet(nameController.text);
    }
    nameController.dispose();
  }
}
