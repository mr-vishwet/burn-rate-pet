import 'package:material_ui/material_ui.dart';

import 'app_routes.dart';
import 'core/theme.dart';
import 'screens/account_screen.dart';
import 'screens/add_details_screen.dart';
import 'screens/bands_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/checkin_result_screen.dart';
import 'screens/checkin_screen.dart';
import 'screens/connected_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/data_controls_screen.dart';
import 'screens/goal_setter_screen.dart';
import 'screens/guest_mode_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/lock_screen_screen.dart';
import 'screens/migrate_screen.dart';
import 'screens/milestone_screen.dart';
import 'screens/onboarding_a_screen.dart';
import 'screens/onboarding_b_screen.dart';
import 'screens/overlay_bubble_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/routine_detail_screen.dart';
import 'screens/routines_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/upgrade_prompt_screen.dart';
import 'screens/verify_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/widget_screen.dart';
import 'state/momo_controller.dart';
import 'state/momo_scope.dart';
import 'widgets/momo_bubble.dart';

/// Momo app shell: one theme (the V7 palette — dual dark/light themes are
/// phase 2), all 30 routes, and the floating companion bubble over the
/// app's screens when enabled.
class MomoApp extends StatelessWidget {
  /// Creates the app around [controller].
  const MomoApp({required this.controller, super.key});

  /// The app's controller.
  final MomoController controller;

  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MomoScope(
      notifier: controller,
      child: MaterialApp(
        title: 'Momo',
        theme: AppTheme.theme,
        navigatorKey: _navigatorKey,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: _onGenerateRoute,
        builder: (context, child) {
          final bubbleOn = MomoScope.of(context).state.bubbleEnabled;
          if (!bubbleOn || child == null) return child ?? const SizedBox();
          return Stack(
            children: [
              child,
              MomoBubble(
                onTap: () => _navigatorKey.currentState?.pushNamed(
                  AppRoutes.checkin,
                ),
                onDismiss: () =>
                    MomoScope.read(context).setCompanion(bubbleEnabled: false),
              ),
            ],
          );
        },
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    Widget screen;
    switch (settings.name) {
      case AppRoutes.splash:
        screen = const SplashScreen();
      case AppRoutes.onboardingA:
        screen = const OnboardingAScreen();
      case AppRoutes.onboardingB:
        screen = const OnboardingBScreen();
      case AppRoutes.addDetails:
        screen = const AddDetailsScreen();
      case AppRoutes.home:
        screen = const HomeScreen();
      case AppRoutes.checkin:
        screen = const CheckinScreen();
      case AppRoutes.checkinResult:
        screen = const CheckinResultScreen();
      case AppRoutes.routines:
        screen = const RoutinesScreen();
      case AppRoutes.routineDetail:
        screen = RoutineDetailScreen(
          routineId: settings.arguments as String? ?? '',
        );
      case AppRoutes.overlay:
        screen = const OverlayBubbleScreen();
      case AppRoutes.widget:
        screen = const WidgetScreen();
      case AppRoutes.lockScreen:
        screen = const LockScreenScreen();
      case AppRoutes.bands:
        screen = const BandsScreen();
      case AppRoutes.budget:
        screen = const BudgetScreen();
      case AppRoutes.insights:
        screen = const InsightsScreen();
      case AppRoutes.history:
        screen = const HistoryScreen();
      case AppRoutes.goals:
        screen = const GoalSetterScreen();
      case AppRoutes.milestone:
        screen = const MilestoneScreen();
      case AppRoutes.settings:
        screen = const SettingsScreen();
      case AppRoutes.privacy:
        screen = const PrivacyScreen();
      case AppRoutes.welcome:
        screen = const WelcomeScreen();
      case AppRoutes.guest:
        screen = const GuestModeScreen();
      case AppRoutes.signIn:
        screen = const SignInScreen();
      case AppRoutes.createAccount:
        screen = const CreateAccountScreen();
      case AppRoutes.verify:
        screen = const VerifyScreen();
      case AppRoutes.upgrade:
        screen = const UpgradePromptScreen();
      case AppRoutes.migrate:
        screen = const MigrateScreen();
      case AppRoutes.account:
        screen = const AccountScreen();
      case AppRoutes.connected:
        screen = const ConnectedScreen();
      case AppRoutes.dataControls:
        screen = const DataControlsScreen();
      default:
        screen = const SplashScreen();
    }
    return MaterialPageRoute<void>(
      builder: (_) => screen,
      settings: settings,
    );
  }
}
