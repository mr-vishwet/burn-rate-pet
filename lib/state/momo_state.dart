import '../core/constants.dart';
import '../core/format.dart';
import '../engine/budget.dart';
import '../engine/checkin.dart';
import '../engine/routines.dart';

/// One completed mood check-in: the answers given, the score they produced,
/// and whether it is seeded demo content.
class CheckinEntry {
  /// Creates a check-in entry.
  CheckinEntry({
    required this.dayKey,
    required this.questionIds,
    required this.answers,
    required this.score,
    this.isDemo = false,
  });

  /// Day key (yyyy-MM-dd) of the check-in.
  final String dayKey;

  /// Question ids in the order they were asked.
  final List<String> questionIds;

  /// Answer indices (0-4), one per question.
  final List<int> answers;

  /// Score 0-100, computed at submission via [scoreCheckin].
  final int score;

  /// Whether this entry is seeded demo content.
  final bool isDemo;

  /// Serializes the entry to JSON.
  Map<String, dynamic> toJson() => {
    'dayKey': dayKey,
    'questionIds': questionIds,
    'answers': answers,
    'score': score,
    'isDemo': isDemo,
  };

  /// Deserializes an entry from JSON.
  factory CheckinEntry.fromJson(Map<String, dynamic> json) => CheckinEntry(
    dayKey: json['dayKey'] as String,
    questionIds: ((json['questionIds'] as List<dynamic>? ?? [])
            .map((e) => e as String))
        .toList(),
    answers: ((json['answers'] as List<dynamic>? ?? [])
            .map((e) => e as int))
        .toList(),
    score: json['score'] as int? ?? 0,
    isDemo: json['isDemo'] as bool? ?? false,
  );
}

/// One month's index point for the history chart.
class MonthlyIndexPoint {
  /// Creates a history point.
  const MonthlyIndexPoint({required this.monthLabel, required this.index});

  /// Month label, e.g. "Jun".
  final String monthLabel;

  /// Index value that month.
  final int index;

  /// Serializes the point to JSON.
  Map<String, dynamic> toJson() => {
    'monthLabel': monthLabel,
    'index': index,
  };

  /// Deserializes a point from JSON.
  factory MonthlyIndexPoint.fromJson(Map<String, dynamic> json) =>
      MonthlyIndexPoint(
        monthLabel: json['monthLabel'] as String? ?? '',
        index: json['index'] as int? ?? 0,
      );
}

/// A milestone Momo celebrates — unlocked by showing up, never by spending.
class Milestone {
  /// Creates a milestone.
  const Milestone({
    required this.id,
    required this.title,
    required this.body,
    this.unlocked = false,
  });

  /// Stable id.
  final String id;

  /// Title, e.g. "30 days of check-ins".
  final String title;

  /// What it celebrates.
  final String body;

  /// Whether it is unlocked.
  final bool unlocked;

  /// Returns a copy with [unlocked] changed.
  Milestone copyWith({bool? unlocked}) => Milestone(
    id: id,
    title: title,
    body: body,
    unlocked: unlocked ?? this.unlocked,
  );

  /// Serializes the milestone to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'unlocked': unlocked,
  };

  /// Deserializes a milestone from JSON.
  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    unlocked: json['unlocked'] as bool? ?? false,
  );
}

/// Whether the user is a guest or has a (local) account. Guest-first:
/// the whole pet works without an account; an account unlocks sync and
/// read-only friend sharing.
enum AuthMode {
  /// No account — everything on-device.
  guest,

  /// Local account (v0.1: no server; sign-in is local-only).
  account,
}

/// The whole app state in one JSON document. Persisted via
/// [StorageService]; the controller owns mutation + derived values.
class MomoState {
  /// Creates app state.
  MomoState({
    this.onboarded = false,
    this.detailsAdded = false,
    this.demoSeeded = false,
    this.petName = 'Momo',
    this.currency = 'USD',
    this.nudgesEnabled = true,
    this.kindnessMode = true,
    this.bubbleEnabled = true,
    this.widgetEnabled = true,
    this.lockCheckinsEnabled = true,
    this.authMode = AuthMode.guest,
    this.email,
    this.displayName,
    this.syncOn = false,
    this.shareCode,
    List<CheckinEntry>? checkins,
    List<Routine>? routines,
    List<BudgetCategory>? categories,
    List<Expense>? expenses,
    this.lastMonthSpentCents = 0,
    List<MonthlyIndexPoint>? indexHistory,
    List<Milestone>? milestones,
    this.happinessGoal = 80,
    this.monthlyBudgetGoalCents = 240000,
  }) : checkins = checkins ?? <CheckinEntry>[],
       routines = routines ?? <Routine>[],
       categories = categories ?? <BudgetCategory>[],
       expenses = expenses ?? <Expense>[],
       indexHistory = indexHistory ?? <MonthlyIndexPoint>[],
       milestones = milestones ?? <Milestone>[];

  /// Whether onboarding (meet Momo + the formula) is done.
  bool onboarded;

  /// Whether the budget details step is done.
  bool detailsAdded;

  /// Whether the seeded demo content is present.
  bool demoSeeded;

  /// The pet's name (renameable in Settings).
  String petName;

  /// Display currency code, e.g. "USD".
  String currency;

  /// Gentle nudges on (one Sunday nudge, check-in reminders).
  bool nudgesEnabled;

  /// Kindness mode: misses are met kindly, never guilt-trippy.
  bool kindnessMode;

  /// The floating companion bubble (in-app in v0.1).
  bool bubbleEnabled;

  /// The home-screen widget (widget-ready state in v0.1).
  bool widgetEnabled;

  /// Lock-screen check-in prompts (in-app preview in v0.1).
  bool lockCheckinsEnabled;

  /// Guest or account.
  AuthMode authMode;

  /// Account email (account mode only).
  String? email;

  /// Account display name.
  String? displayName;

  /// Sync on (account mode; v0.1: local-only record).
  bool syncOn;

  /// Read-only share code, e.g. "7f3k9q" (account mode only).
  String? shareCode;

  /// Check-in history, oldest first.
  List<CheckinEntry> checkins;

  /// Daily routines.
  List<Routine> routines;

  /// Budget categories for this month.
  List<BudgetCategory> categories;

  /// Recent logged expenses.
  List<Expense> expenses;

  /// Last month's total spend (cents) — for the insights comparison.
  int lastMonthSpentCents;

  /// Six months of index history, oldest first.
  List<MonthlyIndexPoint> indexHistory;

  /// Milestones.
  List<Milestone> milestones;

  /// Happiness goal: the index the user is aiming for.
  int happinessGoal;

  /// Monthly budget goal (cents) from the Goal Setter.
  int monthlyBudgetGoalCents;

  /// Empty state: no demo, no data — what a user gets after clearing demo
  /// data or deleting everything.
  factory MomoState.fresh() => MomoState(
    milestones: const [
      Milestone(
        id: 'first-checkin',
        title: 'First check-in',
        body: 'You told Momo how you feel. That is the whole start.',
      ),
      Milestone(
        id: 'checkins-30',
        title: '30 days of check-ins',
        body: 'A full month of showing up for yourself.',
      ),
      Milestone(
        id: 'streak-12',
        title: '12-day streak',
        body: 'Twelve days of one routine, kindly kept.',
      ),
      Milestone(
        id: 'thriving',
        title: 'Thriving band',
        body: 'Your index reached 80 — Momo wears the sunglasses.',
      ),
      Milestone(
        id: 'budget-month',
        title: 'A month on plan',
        body: 'Every category finished inside its plan.',
      ),
    ],
  );

  /// Seeded demo state — the V7 design's canonical numbers, labelled demo
  /// wherever they show. Computes to index 75 (Content): mood 76,
  /// routines 72, budget 78.
  factory MomoState.seededDemo({required DateTime now}) {
    final state = MomoState.fresh();
    state.demoSeeded = true;

    // Mood: 7 check-in scores averaging exactly 76.
    for (var i = 0; i < DemoFixture.recentCheckinScores.length; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final score = DemoFixture.recentCheckinScores[i];
      state.checkins.add(
        _seededCheckin(dayKey(day), score),
      );
    }

    // Routines: 6 routines × 30 days, 129 of 180 slots completed (71.7%
    // → 72), with the evening walk as today's miss (5 of 6 done today).
    for (var r = 0; r < DemoFixture.routineNames.length; r++) {
      final completions = <String>{};
      for (var d = 0; d < 30; d++) {
        final slot = d * 6 + r;
        if ({0, 1, 2, 3, 4}.contains(slot % 18)) continue;
        completions.add(dayKey(now.subtract(Duration(days: 29 - d))));
      }
      final name = DemoFixture.routineNames[r];
      if (name == 'Evening walk') {
        completions.remove(dayKey(now));
      }
      state.routines.add(
        Routine(
          id: 'routine-$r',
          name: name,
          timeLabel: _routineTime(name),
          completions: completions,
          streakDays: _seededStreak(name),
          lastCompletedKey: _lastCompleted(completions),
        ),
      );
    }

    // Budget: $2,400/mo across five categories, $1,936 spent.
    for (var i = 0; i < DemoFixture.categories.length; i++) {
      final (name, planned, spent) = DemoFixture.categories[i];
      state.categories.add(
        BudgetCategory(
          id: 'cat-$i',
          name: name,
          plannedCents: planned,
          spentCents: spent,
        ),
      );
    }
    state.lastMonthSpentCents = DemoFixture.lastMonthSpentCents;
    state.expenses = [
      Expense(
        id: 'exp-1',
        categoryId: 'cat-0',
        amountCents: 4200,
        note: 'Groceries',
        dayKey: dayKey(now),
      ),
      Expense(
        id: 'exp-2',
        categoryId: 'cat-2',
        amountCents: 1800,
        note: 'Cinema tickets',
        dayKey: dayKey(now.subtract(const Duration(days: 1))),
      ),
      Expense(
        id: 'exp-3',
        categoryId: 'cat-1',
        amountCents: 950,
        note: 'Metro top-up',
        dayKey: dayKey(now.subtract(const Duration(days: 1))),
      ),
      Expense(
        id: 'exp-4',
        categoryId: 'cat-4',
        amountCents: 2400,
        note: 'Pharmacy',
        dayKey: dayKey(now.subtract(const Duration(days: 2))),
      ),
      Expense(
        id: 'exp-5',
        categoryId: 'cat-0',
        amountCents: 3100,
        note: 'Weekly shop',
        dayKey: dayKey(now.subtract(const Duration(days: 3))),
      ),
    ];

    // Index history: 68 → 75 over six months.
    for (var i = 0; i < DemoFixture.indexHistory.length; i++) {
      final month = DateTime(now.year, now.month - (5 - i), 1);
      state.indexHistory.add(
        MonthlyIndexPoint(
          monthLabel: formatMonth(month),
          index: DemoFixture.indexHistory[i],
        ),
      );
    }

    // Milestones: the demo has already earned three.
    state.milestones = state.milestones.map((m) {
      if (m.id == 'first-checkin' ||
          m.id == 'checkins-30' ||
          m.id == 'streak-12') {
        return m.copyWith(unlocked: true);
      }
      return m;
    }).toList();

    return state;
  }

  /// Serializes the state to JSON.
  Map<String, dynamic> toJson() => {
    'version': 1,
    'onboarded': onboarded,
    'detailsAdded': detailsAdded,
    'demoSeeded': demoSeeded,
    'petName': petName,
    'currency': currency,
    'nudgesEnabled': nudgesEnabled,
    'kindnessMode': kindnessMode,
    'bubbleEnabled': bubbleEnabled,
    'widgetEnabled': widgetEnabled,
    'lockCheckinsEnabled': lockCheckinsEnabled,
    'authMode': authMode.name,
    'email': email,
    'displayName': displayName,
    'syncOn': syncOn,
    'shareCode': shareCode,
    'checkins': checkins.map((c) => c.toJson()).toList(),
    'routines': routines.map((r) => r.toJson()).toList(),
    'categories': categories.map((c) => c.toJson()).toList(),
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'lastMonthSpentCents': lastMonthSpentCents,
    'indexHistory': indexHistory.map((p) => p.toJson()).toList(),
    'milestones': milestones.map((m) => m.toJson()).toList(),
    'happinessGoal': happinessGoal,
    'monthlyBudgetGoalCents': monthlyBudgetGoalCents,
  };

  /// Deserializes state from JSON. Unknown or missing fields fall back to
  /// defaults so older saves keep loading.
  factory MomoState.fromJson(Map<String, dynamic> json) => MomoState(
    onboarded: json['onboarded'] as bool? ?? false,
    detailsAdded: json['detailsAdded'] as bool? ?? false,
    demoSeeded: json['demoSeeded'] as bool? ?? false,
    petName: json['petName'] as String? ?? 'Momo',
    currency: json['currency'] as String? ?? 'USD',
    nudgesEnabled: json['nudgesEnabled'] as bool? ?? true,
    kindnessMode: json['kindnessMode'] as bool? ?? true,
    bubbleEnabled: json['bubbleEnabled'] as bool? ?? true,
    widgetEnabled: json['widgetEnabled'] as bool? ?? true,
    lockCheckinsEnabled: json['lockCheckinsEnabled'] as bool? ?? true,
    authMode: AuthMode.values.firstWhere(
      (m) => m.name == (json['authMode'] as String? ?? 'guest'),
      orElse: () => AuthMode.guest,
    ),
    email: json['email'] as String?,
    displayName: json['displayName'] as String?,
    syncOn: json['syncOn'] as bool? ?? false,
    shareCode: json['shareCode'] as String?,
    checkins: ((json['checkins'] as List<dynamic>? ?? [])
            .map((e) => CheckinEntry.fromJson(e as Map<String, dynamic>)))
        .toList(),
    routines: ((json['routines'] as List<dynamic>? ?? [])
            .map((e) => Routine.fromJson(e as Map<String, dynamic>)))
        .toList(),
    categories: ((json['categories'] as List<dynamic>? ?? [])
            .map((e) => BudgetCategory.fromJson(e as Map<String, dynamic>)))
        .toList(),
    expenses: ((json['expenses'] as List<dynamic>? ?? [])
            .map((e) => Expense.fromJson(e as Map<String, dynamic>)))
        .toList(),
    lastMonthSpentCents: json['lastMonthSpentCents'] as int? ?? 0,
    indexHistory: ((json['indexHistory'] as List<dynamic>? ?? [])
            .map((e) => MonthlyIndexPoint.fromJson(e as Map<String, dynamic>)))
        .toList(),
    milestones: ((json['milestones'] as List<dynamic>? ?? [])
            .map((e) => Milestone.fromJson(e as Map<String, dynamic>)))
        .toList(),
    happinessGoal: json['happinessGoal'] as int? ?? 80,
    monthlyBudgetGoalCents: json['monthlyBudgetGoalCents'] as int? ?? 240000,
  );
}

/// Builds a seeded check-in entry for [key] with [score]. The answers are
/// illustrative (they sum near the score); the stored score is exact.
CheckinEntry _seededCheckin(String key, int score) {
  final target = (score / 2.5).round(); // sum of 10 answers, 0-4 each
  final answers = <int>[];
  var remaining = target;
  for (var i = 0; i < 10; i++) {
    final value = remaining >= 4 ? 4 : remaining;
    answers.add(value);
    remaining -= value;
  }
  return CheckinEntry(
    dayKey: key,
    questionIds: kCheckinBank.map((q) => q.id).toList(),
    answers: answers,
    score: score,
    isDemo: true,
  );
}

/// Display time for a seeded routine name.
String _routineTime(String name) {
  switch (name) {
    case 'Wake up':
      return '7:00 AM';
    case 'Morning workout':
      return '7:30 AM';
    case 'Deep work':
      return '9:00 AM';
    case 'Read':
      return '1:00 PM';
    case 'Evening walk':
      return '6:30 PM';
    case 'Lights out':
      return '10:30 PM';
    default:
      return '';
  }
}

/// Seeded streak for a routine name.
int _seededStreak(String name) {
  switch (name) {
    case 'Morning workout':
      return DemoFixture.workoutStreakDays;
    case 'Wake up':
      return 8;
    case 'Deep work':
      return 5;
    case 'Read':
      return 4;
    case 'Evening walk':
      return 3;
    case 'Lights out':
      return 6;
    default:
      return 0;
  }
}

/// Most recent completion key in [completions], or null.
String? _lastCompleted(Set<String> completions) {
  if (completions.isEmpty) return null;
  final sorted = completions.toList()..sort();
  return sorted.last;
}
