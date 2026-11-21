import '../core/constants.dart';
import '../core/format.dart';

/// Daily routines: user-created, fixed days, kindly kept.
///
/// The routine component (0-100) is the completion rate over the last
/// [kRoutineWindowDays] days: completed slots / (routines × days) × 100.
///
/// Streaks pause, they don't punish: a missed day freezes the streak at
/// its current value instead of resetting it to zero, and the next
/// completed day resumes counting from the frozen value.
class Routine {
  /// Creates a routine.
  Routine({
    required this.id,
    required this.name,
    required this.timeLabel,
    Set<String>? completions,
    this.streakDays = 0,
    this.lastCompletedKey,
  }) : completions = completions ?? <String>{};

  /// Stable id.
  final String id;

  /// Display name, e.g. "Morning workout".
  final String name;

  /// When it happens, e.g. "7:00 AM". A label, not a scheduler (v0.1 has
  /// no alarms — nudges are in-app only).
  final String timeLabel;

  /// Day keys (yyyy-MM-dd) the routine was completed.
  final Set<String> completions;

  /// Current streak in days. Pauses on a miss — never resets to zero.
  int streakDays;

  /// Day key of the most recent completion, if any.
  String? lastCompletedKey;

  /// Whether the routine was completed on [dayKey].
  bool doneOn(String key) => completions.contains(key);

  /// Whether the streak is currently paused: the routine has a streak but
  /// was not completed yesterday or today.
  bool get isStreakPaused {
    if (streakDays <= 0 || lastCompletedKey == null) return false;
    final today = dayKey(DateTime.now());
    final yesterday = dayKey(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    return lastCompletedKey != today && lastCompletedKey != yesterday;
  }

  /// Serializes the routine to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'timeLabel': timeLabel,
    'completions': completions.toList()..sort(),
    'streakDays': streakDays,
    'lastCompletedKey': lastCompletedKey,
  };

  /// Deserializes a routine from JSON.
  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
    id: json['id'] as String,
    name: json['name'] as String,
    timeLabel: json['timeLabel'] as String? ?? '',
    completions: ((json['completions'] as List<dynamic>? ?? [])
            .map((e) => e as String))
        .toSet(),
    streakDays: json['streakDays'] as int? ?? 0,
    lastCompletedKey: json['lastCompletedKey'] as String?,
  );
}

/// The routine component (0-100) from [routines] over the last
/// [windowDays] ending at [now]: completed slots / total slots × 100,
/// rounded. Returns null when there are no routines — the UI then asks
/// the user to create one instead of inventing a number.
int? routineScore(
  List<Routine> routines, {
  required DateTime now,
  int windowDays = kRoutineWindowDays,
}) {
  if (routines.isEmpty || windowDays <= 0) return null;
  var completed = 0;
  for (var d = 0; d < windowDays; d++) {
    final key = dayKey(now.subtract(Duration(days: d)));
    for (final routine in routines) {
      if (routine.doneOn(key)) completed++;
    }
  }
  final total = routines.length * windowDays;
  return (completed / total * 100).round().clamp(0, 100);
}

/// Next streak value after completing a routine on [todayKey], given the
/// current [streak] and the [lastCompletedKey].
///
/// - First completion ever → 1.
/// - Completed yesterday (or already today) → streak + 1 (or unchanged).
/// - Completed earlier → the streak was paused; completing today resumes
///   from the frozen value, so streak + 1. The miss never zeroes it.
int nextStreak({
  required int streak,
  required String? lastCompletedKey,
  required String todayKey,
}) {
  if (lastCompletedKey == null) return 1;
  if (lastCompletedKey == todayKey) return streak;
  final last = parseDayKey(lastCompletedKey);
  final today = parseDayKey(todayKey);
  final gap = today.difference(last).inDays;
  if (gap <= 0) return streak;
  // Gap of 1 (yesterday) or more (paused): completing today grows the
  // streak by one either way. The pause rule is the whole point.
  return streak + 1;
}

/// How many of [routines] were completed on [todayKey].
int routinesDoneToday(List<Routine> routines, String todayKey) =>
    routines.where((r) => r.doneOn(todayKey)).length;
