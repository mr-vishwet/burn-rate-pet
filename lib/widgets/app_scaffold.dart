import 'package:material_ui/material_ui.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../state/momo_scope.dart';
import 'momo_avatar.dart';

/// Width at which the app switches from the mobile layout to the desktop
/// shell (sidebar + wide content).
const double kDesktopBreakpoint = 900;

/// The adaptive app shell.
///
/// - Narrow (< 900px): a normal [Scaffold] with an [AppBar] and, on the
///   four main tabs, a bottom [NavigationBar].
/// - Wide (>= 900px): the desktop shell from the V7 web screens — a
///   sidebar with the Momo lockup + nav, and the content centred at a
///   max width of 1080px.
///
/// Every screen is built on this shell, so all 30 routes get both a
/// mobile and a web presentation from the one codebase.
class AppScaffold extends StatelessWidget {
  /// Creates the shell.
  const AppScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.bottomNavIndex,
    this.floatingActionButton,
    this.showBack = false,
    super.key,
  });

  /// Screen title.
  final String title;

  /// Screen content (scrollable by the screen itself).
  final Widget body;

  /// AppBar actions (mobile) / header actions (desktop).
  final List<Widget>? actions;

  /// Selected bottom-nav tab (0 Home, 1 Check-in, 2 Routines, 3 Budget),
  /// or null for no bottom nav.
  final int? bottomNavIndex;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// Whether to show a back button (mobile AppBar).
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= kDesktopBreakpoint) {
          return _DesktopShell(
            title: title,
            actions: actions,
            body: body,
            floatingActionButton: floatingActionButton,
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            automaticallyImplyLeading: showBack,
            actions: actions,
          ),
          body: body,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavIndex == null
              ? null
              : _BottomNav(selectedIndex: bottomNavIndex!),
        );
      },
    );
  }
}

/// The four main tabs.
const List<({String route, String label, IconData icon})> kMainTabs = [
  (route: AppRoutes.home, label: 'Home', icon: Icons.home_outlined),
  (
    route: AppRoutes.checkin,
    label: 'Check-in',
    icon: Icons.favorite_outline,
  ),
  (
    route: AppRoutes.routines,
    label: 'Routines',
    icon: Icons.check_circle_outline,
  ),
  (
    route: AppRoutes.budget,
    label: 'Budget',
    icon: Icons.account_balance_wallet_outlined,
  ),
];

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (index == selectedIndex) return;
        Navigator.of(context).pushReplacementNamed(kMainTabs[index].route);
      },
      destinations: [
        for (final tab in kMainTabs)
          NavigationDestination(
            icon: Icon(tab.icon),
            label: tab.label,
          ),
      ],
    );
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final route = ModalRoute.of(context)?.settings.name;
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          Container(
            width: 248,
            decoration: const BoxDecoration(
              color: AppTheme.cocoa800,
              border: Border(
                right: BorderSide(color: AppTheme.hairline),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      children: [
                        const MomoAvatar(size: 40, bob: false),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Momo',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              controller.state.authMode.name == 'guest'
                                  ? 'Guest'
                                  : controller.state.email ?? 'Account',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppTheme.hairline),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      children: [
                        for (final item in _sidebarItems)
                          _SidebarItem(
                            label: item.$2,
                            icon: item.$3,
                            selected: route == item.$1,
                            onTap: () {
                              if (route == item.$1) return;
                              Navigator.of(context).pushReplacementNamed(
                                item.$1,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Your numbers stay on this device.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.hairline),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (actions != null) ...actions!,
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: body,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sidebar entries: (route, label, icon).
const List<(String, String, IconData)> _sidebarItems = [
  (AppRoutes.home, 'Home', Icons.home_outlined),
  (AppRoutes.checkin, 'Mood Check-in', Icons.favorite_outline),
  (AppRoutes.routines, 'Routines', Icons.check_circle_outline),
  (AppRoutes.budget, 'Budget Tracker', Icons.account_balance_wallet_outlined),
  (AppRoutes.bands, 'Happiness Bands', Icons.mood_outlined),
  (AppRoutes.insights, 'Insights', Icons.lightbulb_outline),
  (AppRoutes.history, 'History', Icons.show_chart_outlined),
  (AppRoutes.goals, 'Goal Setter', Icons.flag_outlined),
  (AppRoutes.milestone, 'Milestones', Icons.emoji_events_outlined),
  (AppRoutes.overlay, 'Overlay Bubble', Icons.bubble_chart_outlined),
  (AppRoutes.widget, 'Widget', Icons.widgets_outlined),
  (AppRoutes.lockScreen, 'Lock Screen', Icons.lock_outline),
  (AppRoutes.settings, 'Settings', Icons.settings_outlined),
  (AppRoutes.account, 'Account', Icons.person_outline),
  (AppRoutes.privacy, 'Privacy', Icons.shield_outlined),
];

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? AppTheme.peach : AppTheme.peachSoft,
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: selected ? AppTheme.ink : AppTheme.peachSoft,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: AppTheme.glass,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: onTap,
    );
  }
}

/// Two-column layout for wide screens: [main] on the left (2/3),
/// [side] on the right (1/3). On narrow screens the columns stack.
class TwoColumn extends StatelessWidget {
  /// Creates a two-column layout.
  const TwoColumn({
    required this.main,
    required this.side,
    super.key,
  });

  /// Main column.
  final Widget main;

  /// Side column.
  final Widget side;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [main, const SizedBox(height: 16), side],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: main),
            const SizedBox(width: 16),
            Expanded(child: side),
          ],
        );
      },
    );
  }
}
