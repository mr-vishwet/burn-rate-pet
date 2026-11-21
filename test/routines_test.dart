import 'package:flutter_test/flutter_test.dart';
import 'package:momo/core/format.dart';
import 'package:momo/engine/routines.dart';

void main() {
  group('nextStreak', () {
    test('first completion starts a streak of 1', () {
      expect(
        nextStreak(streak: 0, lastCompletedKey: null, todayKey: '2026-11-21'),
        1,
      );
    });

    test('completing the day after grows the streak', () {
      expect(
        nextStreak(
          streak: 11,
          lastCompletedKey: '2026-11-20',
          todayKey: '2026-11-21',
        ),
        12,
      );
    });

    test('a missed day pauses — completing today resumes, never resets', () {
      // Last completed 4 days ago; the streak was frozen at 12.
      expect(
        nextStreak(
          streak: 12,
          lastCompletedKey: '2026-11-17',
          todayKey: '2026-11-21',
        ),
        13,
      );
    });

    test('completing twice the same day does not double-count', () {
      expect(
        nextStreak(
          streak: 12,
          lastCompletedKey: '2026-11-21',
          todayKey: '2026-11-21',
        ),
        12,
      );
    });
  });

  group('routineScore', () {
    Routine routineWithCompletions(int daysBack, Set<int> offsets) {
      final now = DateTime.now();
      return Routine(
        id: 'r',
        name: 'R',
        timeLabel: '',
        completions: {
          for (final offset in offsets)
            dayKey(now.subtract(Duration(days: offset))),
        },
      );
    }

    test('no routines returns null (never invent a number)', () {
      expect(routineScore([], now: DateTime.now()), isNull);
    });

    test('perfect 30 days scores 100', () {
      final routine = routineWithCompletions(
        30,
        {for (var i = 0; i < 30; i++) i},
      );
      expect(routineScore([routine], now: DateTime.now()), 100);
    });

    test('half the days scores 50', () {
      final routine = routineWithCompletions(
        30,
        {for (var i = 0; i < 30; i += 2) i},
      );
      expect(routineScore([routine], now: DateTime.now()), 50);
    });

    test('completions outside the window do not count', () {
      final routine = routineWithCompletions(40, {35, 36, 37});
      expect(routineScore([routine], now: DateTime.now()), 0);
    });
  });

  group('Routine', () {
    test('streak pauses when yesterday and today are both missed', () {
      final now = DateTime.now();
      final routine = Routine(
        id: 'r',
        name: 'R',
        timeLabel: '',
        streakDays: 12,
        lastCompletedKey: dayKey(now.subtract(const Duration(days: 3))),
      );
      expect(routine.isStreakPaused, isTrue);
    });

    test('streak is not paused when yesterday was completed', () {
      final now = DateTime.now();
      final routine = Routine(
        id: 'r',
        name: 'R',
        timeLabel: '',
        streakDays: 12,
        lastCompletedKey: dayKey(now.subtract(const Duration(days: 1))),
      );
      expect(routine.isStreakPaused, isFalse);
    });

    test('JSON round-trip', () {
      final routine = Routine(
        id: 'r',
        name: 'Read',
        timeLabel: '1:00 PM',
        completions: {'2026-11-20', '2026-11-21'},
        streakDays: 4,
        lastCompletedKey: '2026-11-21',
      );
      final restored = Routine.fromJson(routine.toJson());
      expect(restored.name, 'Read');
      expect(restored.streakDays, 4);
      expect(restored.completions.length, 2);
    });
  });
}
