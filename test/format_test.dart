import 'package:flutter_test/flutter_test.dart';
import 'package:momo/core/format.dart';

void main() {
  group('formatMoney', () {
    test('whole amounts stay clean', () {
      expect(formatMoney(1200, 'USD'), '\$12');
      expect(formatMoney(193600, 'USD'), '\$1,936');
      expect(formatMoney(0, 'USD'), '\$0');
    });

    test('amounts with cents show two decimals', () {
      expect(formatMoney(1250, 'USD'), '\$12.50');
      expect(formatMoney(99, 'USD'), '\$0.99');
      expect(formatMoney(1005, 'USD'), '\$10.05');
      expect(formatMoney(193650, 'USD'), '\$1,936.50');
    });

    test('negatives keep the sign outside the symbol', () {
      expect(formatMoney(-1250, 'USD'), '-\$12.50');
      expect(formatMoney(-1200, 'USD'), '-\$12');
    });

    test('respects the selected currency', () {
      expect(formatMoney(1250, 'EUR'), '€12.50');
      expect(formatMoney(1250, 'INR'), '₹12.50');
      expect(formatMoney(1250, 'JPY'), '¥12.50');
    });
  });

  group('parseMoneyToCents', () {
    test('parses whole and decimal amounts', () {
      expect(parseMoneyToCents('12'), 1200);
      expect(parseMoneyToCents('12.50'), 1250);
      expect(parseMoneyToCents('12.5'), 1250);
      expect(parseMoneyToCents('0.99'), 99);
      expect(parseMoneyToCents('2400'), 240000);
    });

    test('trims and tolerates a trailing dot', () {
      expect(parseMoneyToCents('  12.50  '), 1250);
      expect(parseMoneyToCents('12.'), 1200);
    });

    test('invalid or negative input is 0, never a crash', () {
      expect(parseMoneyToCents(''), 0);
      expect(parseMoneyToCents('abc'), 0);
      expect(parseMoneyToCents('-5'), 0);
      expect(parseMoneyToCents('12.34.56'), 0);
    });

    test('extra decimals truncate, never round up', () {
      expect(parseMoneyToCents('12.345'), 1234);
    });
  });

  group('moneyInputText', () {
    test('whole amounts have no decimals', () {
      expect(moneyInputText(240000), '2400');
      expect(moneyInputText(0), '0');
    });

    test('amounts with cents show two decimals', () {
      expect(moneyInputText(240050), '2400.50');
      expect(moneyInputText(99), '0.99');
    });

    test('round-trips through parseMoneyToCents', () {
      for (final cents in [0, 99, 1250, 240000, 193650]) {
        expect(parseMoneyToCents(moneyInputText(cents)), cents);
      }
    });
  });
}
