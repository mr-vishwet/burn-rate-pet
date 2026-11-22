import '../engine/budget.dart';
import '../engine/routines.dart';

/// Month key for a [DateTime]: "2026-11". The key for the month a
/// budget's spent totals belong to (see [MomoState.monthKey]).
String monthKeyFor(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  return '${date.year}-$m';
}

/// One category's spend in the previous month, archived at rollover so
/// the History screen can show last month's breakdown per category.
class LastMonthCategorySpend {
  /// Creates an archived per-category spend entry.
  const LastMonthCategorySpend({
    required this.id,
    required this.name,
    required this.spentCents,
  });

  /// The category id (stable across months).
  final String id;

  /// The category name as it was when the month closed.
  final String name;

  /// What was spent in that category that month, in cents.
  final int spentCents;

  /// Serializes the entry to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'spentCents': spentCents,
  };

  /// Deserializes an entry from JSON.
  factory LastMonthCategorySpend.fromJson(Map<String, dynamic> json) =>
      LastMonthCategorySpend(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        spentCents: json['spentCents'] as int? ?? 0,
      );
}

/// One completed mood check-in: the answers given and the score they
/// produced.
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

  /// Whether this entry came from the old seeded demo (pre-v0.2 stored
  /// documents only — the app never creates demo entries anymore). Kept
  /// so old documents still load; a demo entry never counts as a real
  /// check-in for "due today".
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
  ///
  /// [monthKey] defaults to the current month when omitted — which is
  /// also how a stored document from before month tracking existed is
  /// treated on load: its totals belong to the current month, so no
  /// rollover fires on first load and nothing is reset.
  MomoState({
    this.onboarded = false,
    this.detailsAdded = false,
    this.petName = 'Momo',
    this.currency = 'USD',
    this.bubbleEnabled = true,
    this.authMode = AuthMode.guest,
    this.email,
    this.displayName,
    this.syncOn = false,
    this.shareCode,
    List<CheckinEntry>? checkins,
    List<Routine>? routines,
    List<BudgetCategory>? categories,
    List<Expense>? expenses,
    String? monthKey,
    this.lastMonthSpentCents = 0,
    List<LastMonthCategorySpend>? lastMonthCategories,
    List<MonthlyIndexPoint>? indexHistory,
    List<Milestone>? milestones,
    this.happinessGoal = 80,
    this.monthlyBudgetGoalCents = 240000,
  }) : checkins = checkins ?? <CheckinEntry>[],
       routines = routines ?? <Routine>[],
       categories = categories ?? <BudgetCategory>[],
       expenses = expenses ?? <Expense>[],
       monthKey = monthKey ?? monthKeyFor(DateTime.now()),
       lastMonthCategories = lastMonthCategories ?? <LastMonthCategorySpend>[],
       indexHistory = indexHistory ?? <MonthlyIndexPoint>[],
       milestones = milestones ?? <Milestone>[];

  /// Whether onboarding (meet Momo + the formula) is done.
  bool onboarded;

  /// Whether the budget details step is done.
  bool detailsAdded;

  /// The pet's name (renameable in Settings).
  String petName;

  /// Display currency code, e.g. "USD".
  String currency;

  /// The floating companion bubble (in-app in v0.1).
  bool bubbleEnabled;

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

  /// The month (yyyy-MM) the categories' [BudgetCategory.spentCents]
  /// totals belong to. When the current month differs, the controller
  /// archives the totals and resets them (monthly rollover).
  String monthKey;

  /// Last month's total spend (cents) — for the insights comparison.
  int lastMonthSpentCents;

  /// Last month's spend per category, archived at rollover — for the
  /// History screen's last-month breakdown.
  List<LastMonthCategorySpend> lastMonthCategories;

  /// Six months of index history, oldest first.
  List<MonthlyIndexPoint> indexHistory;

  /// Milestones.
  List<Milestone> milestones;

  /// Happiness goal: the index the user is aiming for.
  int happinessGoal;

  /// Monthly budget goal (cents) from the Goal Setter.
  int monthlyBudgetGoalCents;

  /// Empty state: no data at all — what a user gets on first launch or
  /// after deleting everything. The milestones exist (locked) so the
  /// Milestones screen has something to show; every number starts empty
  /// and is earned from real activity.
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

  /// Serializes the state to JSON.
  Map<String, dynamic> toJson() => {
    'version': 1,
    'onboarded': onboarded,
    'detailsAdded': detailsAdded,
    'petName': petName,
    'currency': currency,
    'bubbleEnabled': bubbleEnabled,
    'authMode': authMode.name,
    'email': email,
    'displayName': displayName,
    'syncOn': syncOn,
    'shareCode': shareCode,
    'checkins': checkins.map((c) => c.toJson()).toList(),
    'routines': routines.map((r) => r.toJson()).toList(),
    'categories': categories.map((c) => c.toJson()).toList(),
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'monthKey': monthKey,
    'lastMonthSpentCents': lastMonthSpentCents,
    'lastMonthCategories': lastMonthCategories
        .map((c) => c.toJson())
        .toList(),
    'indexHistory': indexHistory.map((p) => p.toJson()).toList(),
    'milestones': milestones.map((m) => m.toJson()).toList(),
    'happinessGoal': happinessGoal,
    'monthlyBudgetGoalCents': monthlyBudgetGoalCents,
  };

  /// Deserializes state from JSON. Unknown or missing fields fall back to
  /// defaults so older saves keep loading — including v1 documents that
  /// still carry the removed keys (`demoSeeded`, `nudgesEnabled`,
  /// `kindnessMode`, `widgetEnabled`, `lockCheckinsEnabled`), which are
  /// simply ignored, and documents with no `monthKey`, whose totals are
  /// treated as the current month's (see [MomoState]).
  factory MomoState.fromJson(Map<String, dynamic> json) => MomoState(
    onboarded: json['onboarded'] as bool? ?? false,
    detailsAdded: json['detailsAdded'] as bool? ?? false,
    petName: json['petName'] as String? ?? 'Momo',
    currency: json['currency'] as String? ?? 'USD',
    bubbleEnabled: json['bubbleEnabled'] as bool? ?? true,
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
    monthKey: _validMonthKey(json['monthKey'] as String?),
    lastMonthSpentCents: json['lastMonthSpentCents'] as int? ?? 0,
    lastMonthCategories:
        ((json['lastMonthCategories'] as List<dynamic>? ?? [])
                .map(
                  (e) => LastMonthCategorySpend.fromJson(
                    e as Map<String, dynamic>,
                  ),
                ))
            .toList(),
    indexHistory: ((json['indexHistory'] as List<dynamic>? ?? [])
            .map((e) => MonthlyIndexPoint.fromJson(e as Map<String, dynamic>)))
        .toList(),
    milestones: ((json['milestones'] as List<dynamic>? ?? [])
            .map((e) => Milestone.fromJson(e as Map<String, dynamic>)))
        .toList(),
    happinessGoal: json['happinessGoal'] as int? ?? 80,
    monthlyBudgetGoalCents: json['monthlyBudgetGoalCents'] as int? ?? 240000,
  );

  /// Returns [key] when it looks like a yyyy-MM month key, else null —
  /// which the constructor then treats as the current month. A malformed
  /// stored key must never trigger a rollover reset of real totals.
  static String? _validMonthKey(String? key) {
    if (key == null) return null;
    final match = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').firstMatch(key);
    return match == null ? null : key;
  }

  /// Replaces every field of this state with [other]'s, in place. Used
  /// by backup import: the controller's [MomoState] object identity
  /// stays stable (screens hold it through the controller), while its
  /// contents become the imported backup.
  void replaceWith(MomoState other) {
    onboarded = other.onboarded;
    detailsAdded = other.detailsAdded;
    petName = other.petName;
    currency = other.currency;
    bubbleEnabled = other.bubbleEnabled;
    authMode = other.authMode;
    email = other.email;
    displayName = other.displayName;
    syncOn = other.syncOn;
    shareCode = other.shareCode;
    checkins = other.checkins;
    routines = other.routines;
    categories = other.categories;
    expenses = other.expenses;
    monthKey = other.monthKey;
    lastMonthSpentCents = other.lastMonthSpentCents;
    lastMonthCategories = other.lastMonthCategories;
    indexHistory = other.indexHistory;
    milestones = other.milestones;
    happinessGoal = other.happinessGoal;
    monthlyBudgetGoalCents = other.monthlyBudgetGoalCents;
  }
}
