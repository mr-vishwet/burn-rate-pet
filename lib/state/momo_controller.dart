import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../core/format.dart';
import '../engine/budget.dart';
import '../engine/checkin.dart';
import '../engine/happiness.dart';
import '../engine/insights.dart';
import '../engine/routines.dart';
import '../services/storage_service.dart';
import 'momo_state.dart';

/// The app's single controller: owns the [MomoState], derives the Happiness
/// Index and every screen's numbers from it, and persists every change.
///
/// All state lives on-device (shared_preferences JSON). There is no
/// backend in v0.1 — sign-in is local-only (see [verifyCode]).
class MomoController extends ChangeNotifier {
  /// Creates a controller around [state] backed by [store].
  MomoController({required this.state, required StorageService store})
    : _store = store;

  /// Loads persisted state, or seeds the demo on first launch.
  ///
  /// A corrupt stored document (unparseable JSON, or valid JSON with the
  /// wrong shape — e.g. a partial write or an older schema) must never
  /// strand the app: it re-seeds the demo and overwrites the corrupt
  /// document, so the next launch loads cleanly.
  static Future<MomoController> load({
    required StorageService store,
  }) async {
    final raw = await store.read();
    if (raw != null) {
      try {
        final state = MomoState.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
        return MomoController(state: state, store: store);
      } on FormatException {
        // Unparseable JSON — fall through and re-seed below.
      } on TypeError {
        // Valid JSON, wrong shape — same recovery.
      }
    }
    final state = MomoState.seededDemo(now: DateTime.now());
    final controller = MomoController(state: state, store: store);
    await controller._persist();
    return controller;
  }

  /// The current state. Screens read through the controller's getters;
  /// direct mutation is for the controller's own methods.
  final MomoState state;

  final StorageService _store;

  /// Email entered on the sign-in / create-account screen, awaiting
  /// verification.
  String? pendingEmail;

  /// Display name entered on the create-account screen.
  String? pendingDisplayName;

  Future<void> _persist() =>
      _store.write(jsonEncode(state.toJson()));

  Future<void> _mutate(Future<void> Function() change) async {
    await change();
    await _persist();
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Derived values: the index and its three inputs
  // ------------------------------------------------------------------

  /// Mood component (0-100) from check-ins in the last 7 days, or null
  /// when there are none yet.
  int? get moodScore {
    final cutoff = DateTime.now().subtract(
      const Duration(days: kMoodWindowDays),
    );
    final recent = state.checkins
        .where((c) => !parseDayKey(c.dayKey).isBefore(cutoff))
        .map((c) => c.score)
        .toList();
    return moodScoreFromRecent(recent);
  }

  /// Routine component (0-100) from the last 30 days, or null when there
  /// are no routines yet.
  int? get routineScoreValue => routineScore(
    state.routines,
    now: DateTime.now(),
  );

  /// Budget component (0-100) from this month's spending.
  int get budgetScoreValue => budgetScore(
    spentCents: spentCents,
    plannedCents: plannedCents,
    overCategoryCount: state.categories.where((c) => c.isOver).length,
  );

  /// Raw index (one decimal), or null when any input is missing.
  double? get indexRaw {
    final mood = moodScore;
    final routines = routineScoreValue;
    if (mood == null || routines == null) return null;
    return HappinessIndex.raw(
      mood: mood,
      routines: routines,
      budget: budgetScoreValue,
    );
  }

  /// Displayed index (rounded), or null when any input is missing.
  int? get index => indexRaw?.round();

  /// Current happiness band, or null when the index is unavailable.
  HappinessBand? get band {
    final value = index;
    return value == null ? null : HappinessIndex.bandFor(value);
  }

  /// The most recent check-in, if any.
  CheckinEntry? get lastCheckin =>
      state.checkins.isEmpty ? null : state.checkins.last;

  /// Whether today's check-in is still due.
  bool get checkinDueToday {
    final today = dayKey(DateTime.now());
    return !state.checkins.any((c) => c.dayKey == today && !c.isDemo);
  }

  /// Routines completed today.
  int get routinesDoneTodayCount =>
      routinesDoneToday(state.routines, dayKey(DateTime.now()));

  /// Longest current streak and which routine holds it.
  ({int days, String routine}) get bestStreak {
    var best = 0;
    var name = '';
    for (final routine in state.routines) {
      if (routine.streakDays > best) {
        best = routine.streakDays;
        name = routine.name;
      }
    }
    return (days: best, routine: name);
  }

  /// Total planned spend this month (cents).
  int get plannedCents =>
      state.categories.fold(0, (sum, c) => sum + c.plannedCents);

  /// Total spent this month (cents).
  int get spentCents =>
      state.categories.fold(0, (sum, c) => sum + c.spentCents);

  /// Cents left this month (negative when over plan).
  int get leftCents => plannedCents - spentCents;

  /// Distinct days with a check-in (demo + real).
  int get checkinDays =>
      state.checkins.map((c) => c.dayKey).toSet().length;

  /// Insights computed from the current numbers.
  List<Insight> get insights => buildInsights(
    spentCents: spentCents,
    lastMonthSpentCents: state.lastMonthSpentCents,
    indexNow: index ?? 0,
    indexSixMonthsAgo: state.indexHistory.isEmpty
        ? (index ?? 0)
        : state.indexHistory.first.index,
    bestStreakDays: bestStreak.days,
    bestStreakRoutine: bestStreak.routine,
    routinesDoneToday: routinesDoneTodayCount,
    routinesTotal: state.routines.length,
    checkinsThisMonth: checkinDays,
  );

  /// The widget-safe snapshot: index + band only, never amounts.
  ({int? index, String? bandLabel}) get widgetSnapshot =>
      (index: index, bandLabel: band?.label);

  // ------------------------------------------------------------------
  // Onboarding + details
  // ------------------------------------------------------------------

  /// Marks onboarding complete.
  Future<void> completeOnboarding() => _mutate(() async {
    state.onboarded = true;
  });

  /// Saves the Add Details step: monthly plan + categories. Replaces the
  /// seeded categories with the user's own.
  Future<void> saveDetails({
    required List<BudgetCategory> categories,
    required int monthlyBudgetGoalCents,
  }) => _mutate(() async {
    state.categories = categories;
    state.monthlyBudgetGoalCents = monthlyBudgetGoalCents;
    state.detailsAdded = true;
  });

  // ------------------------------------------------------------------
  // Check-ins
  // ------------------------------------------------------------------

  /// Records a completed check-in and refreshes the current month's
  /// history point + milestones.
  Future<CheckinEntry> submitCheckin({
    required List<String> questionIds,
    required List<int> answers,
  }) async {
    final entry = CheckinEntry(
      dayKey: dayKey(DateTime.now()),
      questionIds: questionIds,
      answers: answers,
      score: scoreCheckin(answers),
    );
    await _mutate(() async {
      // One check-in per day: a new one replaces today's earlier one.
      state.checkins.removeWhere((c) => c.dayKey == entry.dayKey);
      state.checkins.add(entry);
      _refreshCurrentMonthPoint();
      _unlockMilestones();
    });
    return entry;
  }

  void _refreshCurrentMonthPoint() {
    final value = index;
    if (value == null || state.indexHistory.isEmpty) return;
    final label = formatMonth(DateTime.now());
    final last = state.indexHistory.last;
    if (last.monthLabel == label) {
      state.indexHistory[state.indexHistory.length - 1] =
          MonthlyIndexPoint(monthLabel: label, index: value);
    } else {
      state.indexHistory.add(
        MonthlyIndexPoint(monthLabel: label, index: value),
      );
      if (state.indexHistory.length > 6) {
        state.indexHistory.removeAt(0);
      }
    }
  }

  void _unlockMilestones() {
    final days = checkinDays;
    final value = index;
    state.milestones = state.milestones.map((m) {
      switch (m.id) {
        case 'first-checkin':
          return m.copyWith(unlocked: true);
        case 'checkins-30':
          return m.copyWith(unlocked: m.unlocked || days >= 30);
        case 'streak-12':
          return m.copyWith(
            unlocked: m.unlocked || bestStreak.days >= 12,
          );
        case 'thriving':
          return m.copyWith(
            unlocked: m.unlocked || (value != null && value >= 80),
          );
        case 'budget-month':
          return m.copyWith(
            unlocked:
                m.unlocked ||
                (state.categories.isNotEmpty &&
                    state.categories.every((c) => !c.isOver)),
          );
        default:
          return m;
      }
    }).toList();
  }

  // ------------------------------------------------------------------
  // Routines
  // ------------------------------------------------------------------

  /// Marks a routine done (or undoes it) for today. Completing grows the
  /// streak by one — from its frozen value if it was paused. Undoing
  /// reverts that increment: the streak returns to what it was before
  /// today's completion, and the last-completed day goes back to the
  /// most recent remaining completion. Undoing never punishes beyond
  /// the revert — the streak is never zeroed by a miss.
  ///
  /// The last-completed day is re-derived from the completions set
  /// before toggling: persisted state written before the streak-undo
  /// fix can hold a stale "today" there (the old undo removed today's
  /// completion without resetting it), and in that state completing
  /// today grows nothing — [nextStreak] reads "already done today" —
  /// while undoing still decrements, so each toggle cycle loses a
  /// day. The completions set is the source of truth.
  Future<void> toggleRoutineDone(String routineId) => _mutate(() async {
    final routine = state.routines.firstWhere((r) => r.id == routineId);
    final today = dayKey(DateTime.now());
    final sorted = routine.completions.toList()..sort();
    routine.lastCompletedKey = sorted.isEmpty ? null : sorted.last;
    if (routine.doneOn(today)) {
      routine.completions.remove(today);
      if (routine.lastCompletedKey == today) {
        if (routine.streakDays > 0) routine.streakDays--;
        final remaining = routine.completions.toList()..sort();
        routine.lastCompletedKey =
            remaining.isEmpty ? null : remaining.last;
      }
    } else {
      routine.completions.add(today);
      routine.streakDays = nextStreak(
        streak: routine.streakDays,
        lastCompletedKey: routine.lastCompletedKey,
        todayKey: today,
      );
      routine.lastCompletedKey = today;
      _unlockMilestones();
    }
  });

  /// Adds a user-created routine.
  Future<void> addRoutine({
    required String name,
    required String timeLabel,
  }) => _mutate(() async {
    state.routines.add(
      Routine(
        id: 'routine-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        timeLabel: timeLabel,
      ),
    );
  });

  /// Renames a routine.
  Future<void> renameRoutine(String routineId, String name) =>
      _mutate(() async {
        final routine =
            state.routines.firstWhere((r) => r.id == routineId);
        state.routines[state.routines.indexOf(routine)] = Routine(
          id: routine.id,
          name: name,
          timeLabel: routine.timeLabel,
          completions: routine.completions,
          streakDays: routine.streakDays,
          lastCompletedKey: routine.lastCompletedKey,
        );
      });

  /// Deletes a routine.
  Future<void> deleteRoutine(String routineId) => _mutate(() async {
    state.routines.removeWhere((r) => r.id == routineId);
  });

  // ------------------------------------------------------------------
  // Budget
  // ------------------------------------------------------------------

  /// Logs an expense: adds it to the list and to the category's spent.
  Future<void> addExpense({
    required String categoryId,
    required int amountCents,
    required String note,
  }) => _mutate(() async {
    final category =
        state.categories.firstWhere((c) => c.id == categoryId);
    category.spentCents += amountCents;
    state.expenses.insert(
      0,
      Expense(
        id: 'exp-${DateTime.now().millisecondsSinceEpoch}',
        categoryId: categoryId,
        amountCents: amountCents,
        note: note,
        dayKey: dayKey(DateTime.now()),
      ),
    );
  });

  /// Changes a category's monthly plan.
  Future<void> updateCategoryPlan(String categoryId, int plannedCents) =>
      _mutate(() async {
        final category =
            state.categories.firstWhere((c) => c.id == categoryId);
        category.plannedCents = plannedCents;
      });

  /// Adds a spending category.
  Future<void> addCategory({
    required String name,
    required int plannedCents,
  }) => _mutate(() async {
    state.categories.add(
      BudgetCategory(
        id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        plannedCents: plannedCents,
      ),
    );
  });

  /// Deletes a category (and its expenses).
  Future<void> deleteCategory(String categoryId) => _mutate(() async {
    state.categories.removeWhere((c) => c.id == categoryId);
    state.expenses.removeWhere((e) => e.categoryId == categoryId);
  });

  /// Sets the happiness goal (target index) and monthly budget goal.
  Future<void> setGoals({
    required int happinessGoal,
    required int monthlyBudgetGoalCents,
  }) => _mutate(() async {
    state.happinessGoal = happinessGoal;
    state.monthlyBudgetGoalCents = monthlyBudgetGoalCents;
  });

  // ------------------------------------------------------------------
  // Settings + companion
  // ------------------------------------------------------------------

  /// Updates settings.
  Future<void> updateSettings({
    String? currency,
    bool? nudgesEnabled,
    bool? kindnessMode,
  }) => _mutate(() async {
    if (currency != null) state.currency = currency;
    if (nudgesEnabled != null) state.nudgesEnabled = nudgesEnabled;
    if (kindnessMode != null) state.kindnessMode = kindnessMode;
  });

  /// Renames the pet.
  Future<void> renamePet(String name) => _mutate(() async {
    state.petName = name.trim().isEmpty ? 'Momo' : name.trim();
  });

  /// Toggles the floating bubble / widget / lock-screen check-ins.
  Future<void> setCompanion({
    bool? bubbleEnabled,
    bool? widgetEnabled,
    bool? lockCheckinsEnabled,
  }) => _mutate(() async {
    if (bubbleEnabled != null) state.bubbleEnabled = bubbleEnabled;
    if (widgetEnabled != null) state.widgetEnabled = widgetEnabled;
    if (lockCheckinsEnabled != null) {
      state.lockCheckinsEnabled = lockCheckinsEnabled;
    }
  });

  // ------------------------------------------------------------------
  // Account (local-only in v0.1 — no backend, no email is sent)
  // ------------------------------------------------------------------

  /// Starts sign-in: records the email, awaiting verification.
  Future<void> beginSignIn(String email) async {
    pendingEmail = email.trim();
    pendingDisplayName = null;
    notifyListeners();
  }

  /// Starts account creation: records the email + name, awaiting
  /// verification.
  Future<void> beginCreateAccount({
    required String email,
    required String name,
  }) async {
    pendingEmail = email.trim();
    pendingDisplayName = name.trim().isEmpty ? "Momo's human" : name.trim();
    notifyListeners();
  }

  /// Toggles sync (account mode; v0.1 records the preference locally —
  /// real multi-device sync needs a backend, phase 2).
  Future<void> setSync(bool value) => _mutate(() async {
    state.syncOn = value;
  });

  /// Verifies the 6-digit code and completes sign-in / account creation.
  ///
  /// Returns true for a newly created account, false for a returning
  /// sign-in, and null when there is no pending sign-in or the code is
  /// not 6 digits.
  ///
  /// v0.1 is local-only: there is no server and no email is sent, so any
  /// 6-digit code is accepted and the account is created on-device. The
  /// Verify screen says so plainly. Real magic-link verification is a
  /// phase-2 item (needs a backend).
  Future<bool?> verifyCode(String code) async {
    if (pendingEmail == null || code.length != 6) return null;
    final isNewAccount = pendingDisplayName != null;
    final email = pendingEmail;
    final displayName = pendingDisplayName;
    await _mutate(() async {
      state.authMode = AuthMode.account;
      state.email = email;
      state.displayName =
          displayName ?? state.displayName ?? "Momo's human";
      state.syncOn = true;
      state.shareCode ??= _generateShareCode();
    });
    // Cleared only after the persist succeeds: if the write fails, the
    // pending sign-in survives and the user can retry instead of being
    // told there is no sign-in in progress.
    pendingEmail = null;
    pendingDisplayName = null;
    return isNewAccount;
  }

  /// Signs out: back to guest. Data stays on the device — signing out
  /// never deletes anything.
  Future<void> signOut() => _mutate(() async {
    state.authMode = AuthMode.guest;
    state.email = null;
    state.displayName = null;
    state.syncOn = false;
  });

  /// Regenerates the read-only share link.
  Future<void> regenerateShareCode() => _mutate(() async {
    state.shareCode = _generateShareCode();
  });

  /// Full share URL, e.g. "momo.app/s/7f3k9q".
  String? get shareUrl {
    final code = state.shareCode;
    return code == null ? null : '$kShareHost/s/$code';
  }

  String _generateShareCode() {
    const chars = 'abcdefghjkmnpqrstuvwxyz23456789';
    final random = Random.secure();
    return List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // ------------------------------------------------------------------
  // Data controls
  // ------------------------------------------------------------------

  /// Removes the seeded demo content, keeping settings, account and pet
  /// name. The formulas then run on real activity only.
  Future<void> clearDemoData() async {
    final freshMilestones = MomoState.fresh().milestones;
    await _mutate(() async {
      state.checkins = [];
      state.routines = [];
      state.categories = [];
      state.expenses = [];
      state.lastMonthSpentCents = 0;
      state.indexHistory = [];
      state.milestones = freshMilestones;
      state.demoSeeded = false;
      state.onboarded = true;
      state.detailsAdded = true;
    });
  }

  /// Deletes everything: back to a fresh install (onboarding runs again,
  /// and the demo re-seeds on next launch, as on any fresh install).
  Future<void> deleteAllData() async {
    state.onboarded = false;
    state.detailsAdded = false;
    state.demoSeeded = false;
    state.petName = 'Momo';
    state.currency = 'USD';
    state.nudgesEnabled = true;
    state.kindnessMode = true;
    state.bubbleEnabled = true;
    state.widgetEnabled = true;
    state.lockCheckinsEnabled = true;
    state.authMode = AuthMode.guest;
    state.email = null;
    state.displayName = null;
    state.syncOn = false;
    state.shareCode = null;
    state.checkins = [];
    state.routines = [];
    state.categories = [];
    state.expenses = [];
    state.lastMonthSpentCents = 0;
    state.indexHistory = [];
    state.milestones = MomoState.fresh().milestones;
    state.happinessGoal = 80;
    state.monthlyBudgetGoalCents = 240000;
    pendingEmail = null;
    pendingDisplayName = null;
    await _store.clear();
    notifyListeners();
  }

  /// Full state export as pretty JSON (for Data Controls → Export).
  String exportJson() =>
      const JsonEncoder.withIndent('  ').convert(state.toJson());
}
