import 'package:material_ui/material_ui.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../state/momo_scope.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 01 Splash: Momo asleep on a cloud — "Your Happiness. Our Pet." — and
/// a Get Started button. Returning users go straight home.
class SplashScreen extends StatelessWidget {
  /// Creates the splash screen.
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MomoAvatar(size: 150, mood: MomoMood.sleeping),
                  const SizedBox(height: 24),
                  const Kicker('Your Happiness. Our Pet.'),
                  const SizedBox(height: 12),
                  Text(
                    'Momo',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 44,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A pet for your happiness — one index, three inputs, '
                    'and a corgi who notices.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.peachSoft,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      label: controller.state.onboarded
                          ? 'Continue'
                          : 'Get Started',
                      icon: Icons.pets_outlined,
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          controller.state.onboarded
                              ? AppRoutes.home
                              : AppRoutes.onboardingA,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No account needed · Your numbers stay on this device',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
