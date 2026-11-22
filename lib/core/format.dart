/// Human-readable formatting for money and dates used across the Momo UI.
/// Money is stored in minor units (cents) and formatted here.
library;

import 'constants.dart';

/// Formats [cents] as "$1,936" / "€12.50" — whole units stay clean,
/// amounts with cents show two decimals. Thousands separated.
String formatMoney(int cents, String currencyCode) {
  final symbol = currencySymbol(currencyCode);
  final negative = cents < 0;
  final abs = cents.abs();
  final units = abs ~/ 100;
  final remainder = abs % 100;
  final digits = units.toString();
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(',');
    grouped.write(digits[i]);
  }
  final sign = negative ? '-' : '';
  final fraction = remainder == 0
      ? ''
      : '.${remainder.toString().padLeft(2, '0')}';
  return '$sign$symbol${grouped.toString()}$fraction';
}

/// Display symbol for [currencyCode], e.g. "$" for USD, "€" for EUR.
/// Unknown codes fall back to "$".
String currencySymbol(String currencyCode) =>
    kCurrencies[currencyCode] ?? '\$';

/// Parses user-typed money ("12.50", "12", "12.5", "0.99") into cents.
/// String-based, so no floating-point rounding: "12.50" → 1250.
/// Anything unparseable, negative, or empty → 0. Extra decimals beyond
/// two places are truncated ("12.345" → 1234).
int parseMoneyToCents(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 0;
  final match = RegExp(r'^(\d*)(?:\.(\d*))?$').firstMatch(trimmed);
  if (match == null) return 0;
  final wholeText = match.group(1)!;
  final whole = wholeText.isEmpty ? 0 : int.tryParse(wholeText) ?? 0;
  final fracText = match.group(2) ?? '';
  final frac = fracText.isEmpty
      ? 0
      : int.tryParse(fracText.padRight(2, '0').substring(0, 2)) ?? 0;
  return whole * 100 + frac;
}

/// Text-field initial value for [cents]: "2400" for whole amounts,
/// "2400.50" when cents are present. Round-trips through
/// [parseMoneyToCents].
String moneyInputText(int cents) {
  final negative = cents < 0;
  final abs = cents.abs();
  final units = abs ~/ 100;
  final remainder = abs % 100;
  final sign = negative ? '-' : '';
  if (remainder == 0) return '$sign$units';
  return '$sign$units.${remainder.toString().padLeft(2, '0')}';
}

/// Formats a day key (yyyy-MM-dd) as "Mon 12" — short weekday + day.
/// Uses a fixed English weekday table (no intl dependency).
String formatDayKey(String dayKey) {
  final parts = dayKey.split('-');
  if (parts.length != 3) return dayKey;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return dayKey;
  final date = DateTime(y, m, d);
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${weekdays[date.weekday - 1]} $d';
}

/// Short month label for a [DateTime], e.g. "Nov".
String formatMonth(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return months[date.month - 1];
}

/// Day key for a [DateTime]: "2026-11-21". The canonical key for routine
/// completions and check-in history.
String dayKey(DateTime date) {
  final y = date.year.toString();
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Parses a day key back into a [DateTime] (midnight, local).
DateTime parseDayKey(String key) {
  final parts = key.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}
