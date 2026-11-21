import 'package:flutter/material.dart';

import '../core/constants.dart';

/// The Happiness Index: one number (0-100) from three inputs, with the
/// formula shown in the UI — never hidden.
///
///   index = mood × 40% + routines × 35% + budget × 25%
///
/// Each component is itself 0-100. The raw value keeps one decimal; the
/// displayed index is the raw value rounded to the nearest whole number.
/// Pure functions — no Flutter state, fully unit-tested.
class HappinessIndex {
  HappinessIndex._();

  /// Raw (unrounded) index for the three component scores.
  static double raw({
    required int mood,
    required int routines,
    required int budget,
  }) =>
      mood * kMoodWeight + routines * kRoutineWeight + budget * kBudgetWeight;

  /// Displayed index: [raw] rounded to the nearest whole number, clamped
  /// to 0-100.
  static int rounded({
    required int mood,
    required int routines,
    required int budget,
  }) =>
      raw(mood: mood, routines: routines, budget: budget).round().clamp(0, 100);

  /// The band for an index value.
  static HappinessBand bandFor(int index) {
    if (index >= kThrivingMin) return HappinessBand.thriving;
    if (index >= kContentMin) return HappinessBand.content;
    if (index >= kLowMin) return HappinessBand.low;
    return HappinessBand.struggling;
  }

  /// One-line formula breakdown for display, e.g.
  /// "76 × 40% + 72 × 35% + 78 × 25% = 75.1 → 75".
  static String formulaLine({
    required int mood,
    required int routines,
    required int budget,
  }) {
    final value = raw(mood: mood, routines: routines, budget: budget);
    return '$mood × 40% + $routines × 35% + $budget × 25% = '
        '${value.toStringAsFixed(1)} → ${value.round()}';
  }

  /// Per-component contributions (e.g. 30.4, 25.2, 19.5) for the formula
  /// card.
  static ({double mood, double routines, double budget}) contributions({
    required int mood,
    required int routines,
    required int budget,
  }) => (
    mood: mood * kMoodWeight,
    routines: routines * kRoutineWeight,
    budget: budget * kBudgetWeight,
  );
}

/// The four happiness bands. The band — not the number — is the point:
/// Momo reacts to the band, and the UI always names it next to the index.
enum HappinessBand {
  /// 80-100: Momo wears the sunglasses. Everything is clicking.
  thriving,

  /// 60-79: steady and well-fed.
  content,

  /// 40-59: Momo droops a little — and asks, gently, what would help.
  low,

  /// Below 40: Momo curls up beside you. No alarms, no guilt — just rest.
  struggling,
}

/// Display data for a [HappinessBand].
extension HappinessBandDisplay on HappinessBand {
  /// Band name, e.g. "Content".
  String get label {
    switch (this) {
      case HappinessBand.thriving:
        return 'Thriving';
      case HappinessBand.content:
        return 'Content';
      case HappinessBand.low:
        return 'Low';
      case HappinessBand.struggling:
        return 'Struggling';
    }
  }

  /// Range label, e.g. "60–79".
  String get rangeLabel {
    switch (this) {
      case HappinessBand.thriving:
        return '80–100';
      case HappinessBand.content:
        return '60–79';
      case HappinessBand.low:
        return '40–59';
      case HappinessBand.struggling:
        return 'Below 40';
    }
  }

  /// What Momo does in this band.
  String get momoNote {
    switch (this) {
      case HappinessBand.thriving:
        return 'Momo wears the sunglasses. Everything is clicking.';
      case HappinessBand.content:
        return 'Steady and well-fed. A good place to be.';
      case HappinessBand.low:
        return 'Momo droops a little — and asks, gently, what would help.';
      case HappinessBand.struggling:
        return 'Momo curls up beside you. No alarms, no guilt — just rest.';
    }
  }

  /// Accent colour for the band.
  Color get color {
    switch (this) {
      case HappinessBand.thriving:
        return const Color(0xFF34D399);
      case HappinessBand.content:
        return const Color(0xFFF59E0B);
      case HappinessBand.low:
        return const Color(0xFFFB923C);
      case HappinessBand.struggling:
        return const Color(0xFFFB7185);
    }
  }
}
