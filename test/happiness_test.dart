import 'package:flutter_test/flutter_test.dart';
import 'package:momo/engine/happiness.dart';

void main() {
  group('HappinessIndex formula', () {
    test('example inputs compute to 75.1 -> 75', () {
      final raw = HappinessIndex.raw(mood: 76, routines: 72, budget: 78);
      expect(raw, closeTo(75.1, 0.001));
      expect(
        HappinessIndex.rounded(mood: 76, routines: 72, budget: 78),
        75,
      );
    });

    test('contributions split by the formula weights', () {
      final parts = HappinessIndex.contributions(
        mood: 76,
        routines: 72,
        budget: 78,
      );
      expect(parts.mood, closeTo(30.4, 0.001));
      expect(parts.routines, closeTo(25.2, 0.001));
      expect(parts.budget, closeTo(19.5, 0.001));
    });

    test('formula line reads as in the design', () {
      expect(
        HappinessIndex.formulaLine(mood: 76, routines: 72, budget: 78),
        '76 × 40% + 72 × 35% + 78 × 25% = 75.1 → 75',
      );
    });

    test('weights sum to 1.0', () {
      expect(
        HappinessIndex.raw(mood: 100, routines: 100, budget: 100),
        100,
      );
      expect(HappinessIndex.raw(mood: 0, routines: 0, budget: 0), 0);
    });

    test('rounding follows .5 up', () {
      // 50×40% + 50×35% + 51×25% = 20 + 17.5 + 12.75 = 50.25 -> 50.
      expect(
        HappinessIndex.rounded(mood: 50, routines: 50, budget: 51),
        50,
      );
      // 50×40% + 50×35% + 53×25% = 20 + 17.5 + 13.25 = 50.75 -> 51.
      expect(
        HappinessIndex.rounded(mood: 50, routines: 50, budget: 53),
        51,
      );
    });
  });

  group('HappinessBand', () {
    test('boundaries', () {
      expect(HappinessIndex.bandFor(100), HappinessBand.thriving);
      expect(HappinessIndex.bandFor(80), HappinessBand.thriving);
      expect(HappinessIndex.bandFor(79), HappinessBand.content);
      expect(HappinessIndex.bandFor(75), HappinessBand.content);
      expect(HappinessIndex.bandFor(60), HappinessBand.content);
      expect(HappinessIndex.bandFor(59), HappinessBand.low);
      expect(HappinessIndex.bandFor(40), HappinessBand.low);
      expect(HappinessIndex.bandFor(39), HappinessBand.struggling);
      expect(HappinessIndex.bandFor(0), HappinessBand.struggling);
    });

    test('labels and ranges', () {
      expect(HappinessBand.thriving.label, 'Thriving');
      expect(HappinessBand.thriving.rangeLabel, '80–100');
      expect(HappinessBand.content.rangeLabel, '60–79');
      expect(HappinessBand.low.rangeLabel, '40–59');
      expect(HappinessBand.struggling.rangeLabel, 'Below 40');
    });
  });
}
