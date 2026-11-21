import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/theme.dart';

/// Momo's moods — the face is one SVG; the mood shows in the ring colour
/// and the caption. Momo reacts to the band, never to a single number.
enum MomoMood {
  /// Asleep on a cloud — the app rests until you need it.
  sleeping,

  /// Steady and well-fed.
  content,

  /// Perks up — a good answer, a done routine.
  happy,

  /// Sunglasses Momo — Thriving band, milestones.
  cheer,

  /// Droops a little — Low band.
  low,

  /// Curls up beside you — Struggling band.
  sleepy,
}

/// Ring colour for a mood.
extension MomoMoodColor on MomoMood {
  /// Accent colour for the mood ring.
  Color get color {
    switch (this) {
      case MomoMood.sleeping:
        return AppTheme.taupe;
      case MomoMood.content:
        return AppTheme.orange;
      case MomoMood.happy:
        return AppTheme.peach;
      case MomoMood.cheer:
        return AppTheme.green;
      case MomoMood.low:
        return AppTheme.amber;
      case MomoMood.sleepy:
        return AppTheme.rose;
    }
  }
}

/// Momo the corgi — the app's logo mark, gently bobbing, ringed in the
/// mood colour. [size] is the diameter of the face.
class MomoAvatar extends StatelessWidget {
  /// Creates the avatar.
  const MomoAvatar({
    this.size = 96,
    this.mood = MomoMood.happy,
    this.bob = true,
    super.key,
  });

  /// Diameter of the face.
  final double size;

  /// Current mood (drives the ring colour).
  final MomoMood mood;

  /// Whether the avatar gently bobs (the V7 floaty animation).
  final bool bob;

  @override
  Widget build(BuildContext context) {
    final face = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.glass,
        border: Border.all(color: mood.color.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: mood.color.withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.12),
      child: SvgPicture.asset(
        'assets/logos/icon.svg',
        width: size * 0.76,
        height: size * 0.76,
        semanticsLabel: 'Momo',
      ),
    );
    if (!bob) return face;
    return Bobbing(child: face);
  }
}

/// Gentle vertical bob — the V7 `floaty` keyframe in Flutter.
class Bobbing extends StatefulWidget {
  /// Creates a bobbing wrapper.
  const Bobbing({required this.child, this.amplitude = 6, super.key});

  /// The child to bob.
  final Widget child;

  /// Bob distance in logical pixels.
  final double amplitude;

  @override
  State<Bobbing> createState() => _BobbingState();
}

class _BobbingState extends State<Bobbing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dy =
            math.sin(_controller.value * 2 * math.pi) * widget.amplitude;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.child,
    );
  }
}

/// The horizontal lockup (icon + MOMO wordmark). The wordmark is dark, so
/// this belongs on a light background — the widget renders it on a cream
/// chip.
class MomoLockup extends StatelessWidget {
  /// Creates the lockup.
  const MomoLockup({this.width = 180, super.key});

  /// Width of the lockup.
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0DC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SvgPicture.asset(
        'assets/logos/horizontal.svg',
        width: width,
        semanticsLabel: 'Momo',
      ),
    );
  }
}
