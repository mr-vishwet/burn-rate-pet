import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'momo_avatar.dart';

/// The floating companion bubble — Momo, living on the phone.
///
/// v0.1: an in-app draggable bubble over the app's own screens. Tapping it
/// opens the quick check-in; long-pressing it offers to hide it. A true
/// system-level bubble over other apps needs native overlay code and is
/// phase-2 work (see README).
class MomoBubble extends StatefulWidget {
  /// Creates the bubble.
  const MomoBubble({required this.onTap, required this.onDismiss, super.key});

  /// Tap handler — opens the quick check-in.
  final VoidCallback onTap;

  /// Dismiss handler — hides the bubble (re-enable in Settings / Overlay).
  final VoidCallback onDismiss;

  @override
  State<MomoBubble> createState() => _MomoBubbleState();
}

class _MomoBubbleState extends State<MomoBubble> {
  Offset? _position;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _position ??= Offset(size.width - 88, size.height - 180);
        final position = Offset(
          _position!.dx.clamp(8, size.width - 72),
          _position!.dy.clamp(8, size.height - 72),
        );
        return Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _position = Offset(
                      (_position!.dx + details.delta.dx).clamp(
                        8,
                        size.width - 72,
                      ),
                      (_position!.dy + details.delta.dy).clamp(
                        8,
                        size.height - 72,
                      ),
                    );
                  });
                },
                onTap: widget.onTap,
                onLongPress: () async {
                  final hide = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hide the bubble?'),
                      content: const Text(
                        'Momo will stop floating over the app. You can '
                        'bring the bubble back from Settings or the '
                        'Overlay screen.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop(false),
                          child: const Text('Keep it'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(context).pop(true),
                          child: const Text('Hide'),
                        ),
                      ],
                    ),
                  );
                  if (hide == true) widget.onDismiss();
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.ctaGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.coral.withValues(alpha: 0.5),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const MomoAvatar(size: 52, bob: false),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
