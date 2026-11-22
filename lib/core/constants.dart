/// Canonical constants for Momo: the Happiness Index formula, the bands,
/// and the budget score constants. First launch is fresh and empty — no
/// demo content is seeded anywhere; every number the app shows comes from
/// real activity.
library;

/// ---------------------------------------------------------------------------
/// Happiness Index formula
/// ---------------------------------------------------------------------------

/// Weights of the three inputs. They sum to 1.0 and are shown in the UI
/// next to the formula — the formula is never hidden.
const double kMoodWeight = 0.40;

/// Weight of the routine component (35%).
const double kRoutineWeight = 0.35;

/// Weight of the budget component (25%).
const double kBudgetWeight = 0.25;

/// Check-in questions per session: 10, drawn at random (shuffled) from the
/// bank of 10 dimensions.
const int kCheckinQuestions = 10;

/// Answer scale: 5 options per question, scored 0..4.
const int kAnswerOptions = 5;

/// How many recent check-ins feed the mood component.
const int kMoodWindowDays = 7;

/// How many days of routine history feed the routine component.
const int kRoutineWindowDays = 30;

/// ---------------------------------------------------------------------------
/// Happiness bands
/// ---------------------------------------------------------------------------

/// Band boundaries (inclusive lower bounds): Thriving 80-100, Content
/// 60-79, Low 40-59, Struggling below 40.
const int kThrivingMin = 80;

/// Content band starts at 60 (60-79).
const int kContentMin = 60;

/// Low band starts at 40 (40-59).
const int kLowMin = 40;

/// ---------------------------------------------------------------------------
/// Budget score formula
/// ---------------------------------------------------------------------------

/// The budget component starts at 100 and loses points as spending rises
/// past 35% of the monthly plan, plus a flat penalty per category that has
/// gone over its plan. See [BudgetScore] in `engine/budget.dart`.
const double kBudgetFreeUtilization = 0.35;

/// Points lost per unit of utilization past the free threshold.
const double kBudgetSlope = 48.0;

/// Flat penalty per category that has gone over its plan.
const int kBudgetOverCategoryPenalty = 15;

/// Supported display currencies (code → symbol). Amounts are stored in
/// minor units (cents); the currency only changes the label.
const Map<String, String> kCurrencies = {
  'USD': '\$',
  'EUR': '€',
  'GBP': '£',
  'INR': '₹',
  'JPY': '¥',
};

/// The share-link host shown on the Connected screen. The link itself is
/// generated per account (v0.1: local-only, no server behind it yet).
const String kShareHost = 'momo.app';
