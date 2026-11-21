import 'package:flutter/material.dart';

import '../core/theme.dart';

/// A glassmorphic card — translucent white on cocoa, hairline border,
/// 20px radius. The V7 card.
class GlassCard extends StatelessWidget {
  /// Creates a glass card.
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  /// Card content.
  final Widget child;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: child,
    );
  }
}

/// A small-caps kicker label above a section, e.g. "THE FORMULA, SHOWN".
class Kicker extends StatelessWidget {
  /// Creates a kicker.
  const Kicker(this.text, {super.key});

  /// Label text.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 1.2,
        color: AppTheme.peach,
      ),
    );
  }
}

/// A gradient CTA button — coral → peach, the V7 primary button.
class GradientButton extends StatelessWidget {
  /// Creates a gradient button.
  const GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  /// Button label.
  final String label;

  /// Tap handler.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.ctaGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.coral.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// A labelled stat: big mono value + small label below.
class StatTile extends StatelessWidget {
  /// Creates a stat tile.
  const StatTile({
    required this.value,
    required this.label,
    this.accent,
    super.key,
  });

  /// Big value, e.g. "75".
  final String value;

  /// Small label, e.g. "Index".
  final String label;

  /// Optional accent colour for the value.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.monoNumbers(
              size: 22,
              weight: FontWeight.w600,
              color: accent ?? AppTheme.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// A "DEMO" chip marking seeded demo content wherever it shows.
class DemoChip extends StatelessWidget {
  /// Creates a demo chip.
  const DemoChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.orange.withValues(alpha: 0.5)),
      ),
      child: Text(
        'DEMO',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppTheme.orange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
