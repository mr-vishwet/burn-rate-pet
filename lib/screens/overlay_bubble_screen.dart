import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 10 Overlay Bubble: Momo floats over other apps — a 10-second check-in
/// without opening the app.
///
/// v0.1: the bubble floats over Momo's own screens (in-app). A true
/// system-level bubble over other apps needs native overlay code and is
/// phase-2 work; this screen says so plainly.
class OverlayBubbleScreen extends StatelessWidget {
  /// Creates the overlay bubble screen.
  const OverlayBubbleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MomoScope.of(context);
    final theme = Theme.of(context);
    final bubbleOn = controller.state.bubbleEnabled;
    return AppScaffold(
      title: 'Overlay Bubble',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('Momo, everywhere'),
                  const SizedBox(height: 8),
                  Text(
                    'The bubble parks over whatever you are doing. One tap '
                    'and Momo asks a single question — ten seconds, then '
                    'you are done.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Floating bubble',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Switch(
                        value: bubbleOn,
                        onChanged: (value) => controller.setCompanion(
                          bubbleEnabled: value,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // A mock "other app" (Notes) with the bubble parked over it.
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.note_outlined, color: AppTheme.taupe),
                      const SizedBox(width: 8),
                      Text('Notes', style: theme.textTheme.titleSmall),
                      const Spacer(),
                      Text(
                        'another app',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Weekend plans\n· Book train\n· Call home\n· Water the '
                    'plants\n· Read',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.peachSoft,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const MomoAvatar(size: 56, bob: false),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick check-in: how\'s your focus?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Tap to answer in 10 seconds — Momo is '
                              'listening.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    label: 'Try the quick check-in',
                    icon: Icons.favorite_outline,
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.checkin,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.peach),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'v0.1: the bubble floats over Momo itself. Floating '
                      'over other apps needs a system overlay permission '
                      'and native code — phase 2.',
                      style: theme.textTheme.bodySmall,
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
}
