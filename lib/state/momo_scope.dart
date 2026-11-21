import 'package:flutter/widgets.dart';

import 'momo_controller.dart';

/// Provides the [MomoController] to the whole widget tree. Screens read it
/// with [MomoScope.of] (rebuilds on change) or [MomoScope.read] (one-off
/// actions, no rebuild subscription).
class MomoScope extends InheritedNotifier<MomoController> {
  /// Creates the scope around [child].
  const MomoScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  /// Returns the controller, subscribing the caller to changes.
  static MomoController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MomoScope>();
    assert(scope != null, 'MomoScope not found in widget tree.');
    return scope!.notifier!;
  }

  /// Returns the controller without subscribing (for event handlers).
  static MomoController read(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<MomoScope>()
        ?.widget as MomoScope?;
    assert(scope != null, 'MomoScope not found in widget tree.');
    return scope!.notifier!;
  }
}
