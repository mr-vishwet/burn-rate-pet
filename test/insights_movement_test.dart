import 'package:flutter_test/flutter_test.dart';
import 'package:momo/engine/insights.dart';

/// Baseline inputs for [buildInsights] with nothing else to report: no
/// spending change, no climb, no streak, no routines, few check-ins.
List<Insight> _insights({
  List<int>? movementDayScores,
  List<int>? otherDayScores,
}) => buildInsights(
  spentCents: 10000,
  lastMonthSpentCents: 10000,
  indexNow: 70,
  indexSixMonthsAgo: 70,
  bestStreakDays: 0,
  bestStreakRoutine: '',
  routinesDoneToday: 0,
  routinesTotal: 0,
  checkinsThisMonth: 5,
  movementDayScores: movementDayScores,
  otherDayScores: otherDayScores,
);

bool _hasMovementInsight(List<Insight> insights) => insights.any(
  (i) => i.title == 'Movement days lift the index',
);

void main() {
  group('movement insight is computed from real data', () {
    test('absent when no check-in history is passed', () {
      expect(_hasMovementInsight(_insights()), isFalse);
    });

    test('absent when either side is empty', () {
      expect(
        _hasMovementInsight(
          _insights(movementDayScores: [80], otherDayScores: []),
        ),
        isFalse,
      );
      expect(
        _hasMovementInsight(
          _insights(movementDayScores: [], otherDayScores: [60]),
        ),
        isFalse,
      );
    });

    test('appears when movement days score higher, with the real means',
        () {
      final insights = _insights(
        movementDayScores: [80, 84],
        otherDayScores: [60, 64],
      );
      expect(_hasMovementInsight(insights), isTrue);
      final insight = insights.firstWhere(
        (i) => i.title == 'Movement days lift the index',
      );
      expect(insight.body, contains('82 vs 62'));
    });

    test('absent when movement days score lower or equal', () {
      expect(
        _hasMovementInsight(
          _insights(
            movementDayScores: [60, 64],
            otherDayScores: [80, 84],
          ),
        ),
        isFalse,
      );
      expect(
        _hasMovementInsight(
          _insights(
            movementDayScores: [70, 70],
            otherDayScores: [70, 70],
          ),
        ),
        isFalse,
      );
    });
  });
}
