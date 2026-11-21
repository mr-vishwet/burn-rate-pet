/// The companion that lives on the phone: floating bubble, home-screen
/// widget, lock-screen check-ins.
///
/// v0.1 implements the companion *in-app* — a draggable bubble over the
/// app's own screens, widget-ready state, and a lock-screen preview — and
/// documents the platform gap honestly: a true system-level bubble,
/// home-screen widget, and lock-screen extension need native platform
/// code (Android overlay permission + AppWidget, iOS WidgetKit +
/// Live Activities) and are phase-2 work. Nothing here pretends the
/// native pieces exist.
///
/// What IS real in v0.1: the widget snapshot ([CompanionSnapshot]) is the
/// exact data a native widget would render — index + band only, amounts
/// never shown — and the bubble + lock-screen flows inside the app run
/// the real check-in.
library;

/// The data a home-screen widget or lock-screen prompt may show.
///
/// Deliberate: index + band only. Amounts never appear on the widget or
/// lock screen — safe for a screenshot, by design.
class CompanionSnapshot {
  /// Creates a widget-safe snapshot.
  const CompanionSnapshot({
    required this.petName,
    required this.index,
    required this.bandLabel,
    required this.checkinDue,
  });

  /// The pet's name.
  final String petName;

  /// Current Happiness Index, if available.
  final int? index;

  /// Current band label, e.g. "Content".
  final String? bandLabel;

  /// Whether today's check-in is still due.
  final bool checkinDue;
}
