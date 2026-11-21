/// Canonical constants for Momo: the Happiness Index formula, the bands,
/// and the seeded demo fixture from the V7 design.
///
/// The seeded numbers are DEMO content — labelled as demo wherever they
/// show — and exist so a first launch has a living pet to meet. Real
/// numbers replace them as the user checks in, keeps routines, and tracks
/// their budget.
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

/// ---------------------------------------------------------------------------
/// Seeded demo fixture (SEEDED DEMO CONTENT — labelled as demo everywhere)
/// ---------------------------------------------------------------------------
///
/// The V7 design's canonical numbers: index 75 (Content), from mood 76,
/// routines 72, budget 78 — 76×40% + 72×35% + 78×25% = 75.1 → 75.
/// Budget $2,400/mo across five categories, $1,936 spent, $464 left.
/// Six routines, 5 of 6 done today, a 12-day streak on Morning workout.
/// Index history 68 → 75 over six months (+7).
///
/// These are the product's demo story, not measured data. Clearing demo
/// data (Data Controls) removes them; the formulas then run on real
/// activity only.
class DemoFixture {
  /// Seeded component scores (0-100).
  static const int moodScore = 76;

  /// Seeded routine component score (0-100).
  static const int routineScore = 72;

  /// Seeded budget component score (0-100).
  static const int budgetScore = 78;

  /// Seeded Happiness Index (0-100).
  static const int index = 75;

  /// Seeded check-in scores for the last 7 days — they average exactly 76.
  static const List<int> recentCheckinScores = [74, 76, 78, 75, 77, 76, 76];

  /// Monthly budget in cents, and the five categories (name, planned, spent).
  static const int monthlyPlannedCents = 240000;

  /// Seeded total spent this month, in cents.
  static const int monthlySpentCents = 193600;

  /// Seeded total spent last month, in cents.
  static const int lastMonthSpentCents = 210400; // this month is 8% lower

  /// Seeded budget categories: (name, planned cents, spent cents).
  static const List<(String, int, int)> categories = [
    ('Food', 52000, 38600),
    ('Transport', 18000, 14200),
    ('Fun', 26000, 21400),
    ('Home', 115000, 109800),
    ('Health', 29000, 9600),
  ];

  /// The six seeded routines. The evening walk is today's miss.
  static const List<String> routineNames = [
    'Wake up',
    'Morning workout',
    'Deep work',
    'Read',
    'Evening walk',
    'Lights out',
  ];

  /// Seeded streak (days) for Morning workout.
  static const int workoutStreakDays = 12;

  /// Six months of index history, oldest first: 68 → 75 (+7).
  static const List<int> indexHistory = [68, 69, 70, 71, 73, 75];

  /// Milestone: 30 days of check-ins.
  static const int checkinMilestoneDays = 30;
}

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
