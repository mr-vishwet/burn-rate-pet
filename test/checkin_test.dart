import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:momo/engine/checkin.dart';

void main() {
  group('question bank', () {
    test('bank has 10 dimensions, 5 options each', () {
      expect(kCheckinBank.length, 10);
      for (final question in kCheckinBank) {
        expect(question.options.length, 5);
      }
      final dimensions = kCheckinBank.map((q) => q.dimension).toSet();
      expect(dimensions.length, 10);
      expect(dimensions, containsAll([
        'Sleep', 'Energy', 'Stress', 'Focus', 'Social',
        'Movement', 'Mood', 'Appetite', 'Calm', 'Outlook',
      ]));
    });

    test('draw returns 10 unique questions in random order', () {
      final drawn = drawCheckinQuestions(random: Random(42));
      expect(drawn.length, 10);
      expect(drawn.map((q) => q.id).toSet().length, 10);
      // Seeded shuffle is deterministic.
      final drawnAgain = drawCheckinQuestions(random: Random(42));
      expect(
        drawnAgain.map((q) => q.id).toList(),
        drawn.map((q) => q.id).toList(),
      );
    });
  });

  group('scoreCheckin', () {
    test('all best answers score 100, all worst score 0', () {
      expect(scoreCheckin(List.filled(10, 4)), 100);
      expect(scoreCheckin(List.filled(10, 0)), 0);
    });

    test('all middle answers score 50', () {
      expect(scoreCheckin(List.filled(10, 2)), 50);
    });

    test('mixed answers average', () {
      // 5×4 + 5×2 = 30 → 30/40 × 100 = 75.
      expect(scoreCheckin([4, 4, 4, 4, 4, 2, 2, 2, 2, 2]), 75);
    });

    test('empty answers score 0', () {
      expect(scoreCheckin([]), 0);
    });
  });

  group('moodScoreFromRecent', () {
    test('seeded week averages exactly 76', () {
      expect(
        moodScoreFromRecent([74, 76, 78, 75, 77, 76, 76]),
        76,
      );
    });

    test('no check-ins returns null (never invent a number)', () {
      expect(moodScoreFromRecent([]), isNull);
    });

    test('single check-in is the score', () {
      expect(moodScoreFromRecent([82]), 82);
    });
  });
}
