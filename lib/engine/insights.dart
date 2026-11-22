/// Insights: short, kind observations Momo draws from the user's own data.
///
/// Every insight is computed from stored state — nothing is invented, and
/// nothing references data the user hasn't entered. Insights never
/// guilt-trip: good news first, and every nudge is a suggestion, not a
/// scolding.
class Insight {
  /// Creates an insight.
  const Insight({
    required this.title,
    required this.body,
    required this.kind,
  });

  /// Headline, e.g. "Spending 8% lower than last month".
  final String title;

  /// One or two sentences of detail.
  final String body;

  /// What kind of insight this is (drives the icon + accent).
  final InsightKind kind;
}

/// Insight kinds.
enum InsightKind {
  /// Good news — spending down, streaks up, index climbing.
  good,

  /// A gentle observation — movement days, sleep, patterns.
  note,

  /// A suggestion — what would move the index.
  tip,
}

/// Builds the insight list from a snapshot of the user's numbers.
///
/// All inputs are plain values so this stays pure and testable; the
/// controller passes its current state in.
///
/// The movement insight needs check-in history: [movementDayScores] are
/// the scores of check-ins on days the user moved (movement answer 2+,
/// "Some" or more), [otherDayScores] the rest. It only appears when both
/// lists are non-empty and movement days actually score higher — never
/// as an unconditional claim.
List<Insight> buildInsights({
  required int spentCents,
  required int lastMonthSpentCents,
  required int indexNow,
  required int indexSixMonthsAgo,
  required int bestStreakDays,
  required String bestStreakRoutine,
  required int routinesDoneToday,
  required int routinesTotal,
  required int checkinsThisMonth,
  List<int>? movementDayScores,
  List<int>? otherDayScores,
}) {
  final insights = <Insight>[];

  if (lastMonthSpentCents > 0) {
    final change =
        (spentCents - lastMonthSpentCents) / lastMonthSpentCents;
    if (change < 0) {
      final pct = (-change * 100).round();
      insights.add(
        Insight(
          title: 'Spending $pct% lower than last month',
          body: 'You spent less than last month — and Momo noticed. '
              'Steady spending is the quietest way the index climbs.',
          kind: InsightKind.good,
        ),
      );
    } else if (change > 0) {
      final pct = (change * 100).round();
      insights.add(
        Insight(
          title: 'Spending $pct% higher than last month',
          body: 'A heavier month — it happens. Momo just notes it; '
              'nothing here is a scolding.',
          kind: InsightKind.note,
        ),
      );
    }
  }

  final climb = indexNow - indexSixMonthsAgo;
  if (climb > 0) {
    insights.add(
      Insight(
        title: 'Your index climbed +$climb in six months',
        body: 'From $indexSixMonthsAgo to $indexNow. Small days, added up — '
            'that is the whole method.',
        kind: InsightKind.good,
      ),
    );
  }

  if (bestStreakDays > 0) {
    insights.add(
      Insight(
        title: '$bestStreakRoutine: a $bestStreakDays-day streak',
        body: 'Your longest-running routine. Streaks pause, they never '
            'punish — a missed day just waits for you.',
        kind: InsightKind.good,
      ),
    );
  }

  if (routinesTotal > 0) {
    insights.add(
      Insight(
        title: '$routinesDoneToday of $routinesTotal routines done today',
        body: routinesDoneToday == routinesTotal
            ? 'A full house. Momo is doing a small happy wiggle.'
            : 'The rest of the day is still yours. No rush, no guilt.',
        kind: InsightKind.note,
      ),
    );
  }

  if (checkinsThisMonth >= 30) {
    insights.add(
      const Insight(
        title: '30 days of check-ins',
        body: 'A full month of showing up for yourself. That is the '
            'milestone Momo is proudest of.',
        kind: InsightKind.good,
      ),
    );
  }

  // Movement days: only claimed when the user's own check-ins back it
  // up — movement days must average higher than other days, with real
  // check-ins on both sides. No data, no claim.
  if (movementDayScores != null &&
      otherDayScores != null &&
      movementDayScores.isNotEmpty &&
      otherDayScores.isNotEmpty) {
    final moveMean =
        movementDayScores.reduce((a, b) => a + b) / movementDayScores.length;
    final otherMean =
        otherDayScores.reduce((a, b) => a + b) / otherDayScores.length;
    final lift = (moveMean - otherMean).round();
    if (lift > 0) {
      insights.add(
        Insight(
          title: 'Movement days lift the index',
          body:
              'On days you move, your check-ins average '
              '${moveMean.round()} vs ${otherMean.round()} on other days. '
              'A short walk counts — Momo will take any movement you offer.',
          kind: InsightKind.tip,
        ),
      );
    }
  }

  return insights;
}
