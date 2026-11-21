import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// The Happiness Index ring — the V7 ring, mid-fill, animated from 0 to
/// the value on first paint. [value] is 0-100; [label] is the band name
/// shown under the number.
class IndexRing extends StatelessWidget {
  /// Creates the ring.
  const IndexRing({
    required this.value,
    required this.label,
    this.size = 148,
    this.stroke = 12,
    super.key,
  });

  /// Index value 0-100.
  final int value;

  /// Band label under the number, e.g. "Content".
  final String label;

  /// Ring diameter.
  final double size;

  /// Ring stroke width.
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final fraction = (value / 100).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: fraction),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  fraction: animated,
                  stroke: stroke,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(animated * 100).round()}',
                    style: AppTheme.monoNumbers(
                      size: size * 0.30,
                      weight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.peachSoft,
                    ),
                  ),
                  Text(
                    'Happiness Index',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction, required this.stroke});

  final double fraction;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = AppTheme.hairline
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    final valuePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.coral, AppTheme.peach],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.stroke != stroke;
}
