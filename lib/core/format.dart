/// Human-readable formatting for money and dates used across the Momo UI.
/// Money is stored in minor units (cents) and formatted here.
library;

import 'constants.dart';

/// Formats [cents] as "$1,936" / "€1,936" — whole units, thousands
/// separated, no decimals (amounts in Momo are whole-dollar by design).
String formatMoney(int cents, String currencyCode) {
  final symbol = kCurrencies[currencyCode] ?? '\$';
  final units = (cents / 100).round();
  final digits = units.abs().toString();
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(',');
    grouped.write(digits[i]);
  }
  final sign = units < 0 ? '-' : '';
  return '$sign$symbol${grouped.toString()}';
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
