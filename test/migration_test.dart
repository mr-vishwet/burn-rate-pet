import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:momo/engine/budget.dart';
import 'package:momo/services/storage_service.dart';
import 'package:momo/state/momo_controller.dart';
import 'package:momo/state/momo_state.dart';

/// A realistic v1 stored document: written by the build before month
/// tracking, seed removal, and the dead-toggle removal. It still carries
/// the removed keys (`demoSeeded`, `nudgesEnabled`, `kindnessMode`,
/// `widgetEnabled`, `lockCheckinsEnabled`) and has no `monthKey` — and
/// one check-in is still flagged `isDemo` from the old seeded content.
Map<String, dynamic> _v1Document() {
  final now = DateTime.now();
  final today = _dayKey(now);
  final yesterday = _dayKey(now.subtract(const Duration(days: 1)));
  return {
    'version': 1,
    'onboarded': true,
    'detailsAdded': true,
    'demoSeeded': true,
    'petName': 'Pip',
    'currency': 'EUR',
    'nudgesEnabled': false,
    'kindnessMode': false,
    'bubbleEnabled': false,
    'widgetEnabled': false,
    'lockCheckinsEnabled': false,
    'authMode': 'account',
    'email': 'you@example.com',
    'displayName': "Momo's human",
    'syncOn': true,
    'shareCode': '7f3k9q',
    'checkins': [
      {
        'dayKey': yesterday,
        'questionIds': ['q0', 'q1'],
        'answers': [3, 4],
        'score': 88,
        'isDemo': true,
      },
      {
        'dayKey': today,
        'questionIds': ['q0', 'q1'],
        'answers': [2, 3],
        'score': 62,
        'isDemo': false,
      },
    ],
    'routines': [
      {
        'id': 'routine-0',
        'name': 'Morning workout',
        'timeLabel': '7:30 AM',
        'completions': [yesterday, today],
        'streakDays': 12,
        'lastCompletedKey': today,
      },
      {
        'id': 'routine-1',
        'name': 'Read',
        'timeLabel': '1:00 PM',
        'completions': [yesterday],
        'streakDays': 4,
        'lastCompletedKey': yesterday,
      },
    ],
    'categories': [
      {
        'id': 'cat-0',
        'name': 'Food',
        'plannedCents': 52000,
        'spentCents': 38600,
      },
      {
        'id': 'cat-1',
        'name': 'Transport',
        'plannedCents': 18000,
        'spentCents': 14200,
      },
    ],
    'expenses': [
      {
        'id': 'exp-1',
        'categoryId': 'cat-0',
        'amountCents': 4200,
        'note': 'Groceries',
        'dayKey': today,
      },
    ],
    'lastMonthSpentCents': 150000,
    'indexHistory': [
      {'monthLabel': 'Sep', 'index': 68},
      {'monthLabel': 'Oct', 'index': 71},
      {'monthLabel': 'Nov', 'index': 75},
    ],
    'milestones': [
      {
        'id': 'first-checkin',
        'title': 'First check-in',
        'body': 'You told Momo how you feel. That is the whole start.',
        'unlocked': true,
      },
      {
        'id': 'checkins-30',
        'title': '30 days of check-ins',
        'body': 'A full month of showing up for yourself.',
        'unlocked': false,
      },
    ],
    'happinessGoal': 85,
    'monthlyBudgetGoalCents': 200000,
  };
}

String _dayKey(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${date.year}-$m-$d';
}

String _lastMonthKey() {
  final now = DateTime.now();
  return monthKeyFor(DateTime(now.year, now.month - 1, 1));
}

void main() {
  group('v1 migration', () {
    test('a v1 stored document loads unchanged', () async {
      final doc = _v1Document();
      final store = StorageService(
        MemoryStore({StorageService.stateKey: jsonEncode(doc)}),
      );
      final controller = await MomoController.load(store: store);
      final state = controller.state;

      // Every section loads byte-equal with the stored document.
      expect(
        jsonEncode(state.checkins.map((c) => c.toJson()).toList()),
        jsonEncode(doc['checkins']),
      );
      expect(
        jsonEncode(state.routines.map((r) => r.toJson()).toList()),
        jsonEncode(doc['routines']),
      );
      expect(
        jsonEncode(state.categories.map((c) => c.toJson()).toList()),
        jsonEncode(doc['categories']),
      );
      expect(
        jsonEncode(state.expenses.map((e) => e.toJson()).toList()),
        jsonEncode(doc['expenses']),
      );
      expect(
        jsonEncode(state.indexHistory.map((p) => p.toJson()).toList()),
        jsonEncode(doc['indexHistory']),
      );
      expect(
        jsonEncode(state.milestones.map((m) => m.toJson()).toList()),
        jsonEncode(doc['milestones']),
      );

      // Every setting loads as stored.
      expect(state.onboarded, isTrue);
      expect(state.detailsAdded, isTrue);
      expect(state.petName, 'Pip');
      expect(state.currency, 'EUR');
      expect(state.bubbleEnabled, isFalse);
      expect(state.authMode, AuthMode.account);
      expect(state.email, 'you@example.com');
      expect(state.displayName, "Momo's human");
      expect(state.syncOn, isTrue);
      expect(state.shareCode, '7f3k9q');
      expect(state.lastMonthSpentCents, 150000);
      expect(state.happinessGoal, 85);
      expect(state.monthlyBudgetGoalCents, 200000);

      // The removed keys are ignored, not errors — and the legacy
      // isDemo flag on the old check-in survives the load.
      expect(state.checkins.first.isDemo, isTrue);
      expect(state.checkins.last.isDemo, isFalse);

      // No monthKey in the document: treated as the current month, so
      // nothing is reset on first load — the user's totals survive.
      expect(state.monthKey, monthKeyFor(DateTime.now()));
      expect(controller.spentCents, 38600 + 14200);
      expect(state.lastMonthCategories, isEmpty);
    });

    test('a malformed monthKey is treated as the current month', () async {
      final doc = _v1Document()..['monthKey'] = 'garbage';
      final store = StorageService(
        MemoryStore({StorageService.stateKey: jsonEncode(doc)}),
      );
      final controller = await MomoController.load(store: store);
      expect(controller.state.monthKey, monthKeyFor(DateTime.now()));
      expect(controller.spentCents, 38600 + 14200);
    });
  });

  group('monthly rollover', () {
    test('stored last-month key: totals archived, spent reset', () async {
      final doc = _v1Document()..['monthKey'] = _lastMonthKey();
      final store = StorageService(
        MemoryStore({StorageService.stateKey: jsonEncode(doc)}),
      );
      final controller = await MomoController.load(store: store);
      final state = controller.state;

      expect(state.monthKey, monthKeyFor(DateTime.now()));
      expect(state.lastMonthSpentCents, 38600 + 14200);
      expect(state.lastMonthCategories.length, 2);
      expect(state.lastMonthCategories[0].id, 'cat-0');
      expect(state.lastMonthCategories[0].name, 'Food');
      expect(state.lastMonthCategories[0].spentCents, 38600);
      expect(state.lastMonthCategories[1].spentCents, 14200);
      expect(state.categories.every((c) => c.spentCents == 0), isTrue);
      expect(controller.spentCents, 0);
      // Plans survive the rollover; only spent resets.
      expect(controller.plannedCents, 52000 + 18000);
      // Check-ins, routines, and history are untouched by the rollover.
      expect(state.checkins.length, 2);
      expect(state.routines.length, 2);

      // The rollover persists: a reload shows the same archived month.
      final reloaded = await MomoController.load(store: store);
      expect(reloaded.state.lastMonthSpentCents, 38600 + 14200);
      expect(reloaded.state.lastMonthCategories.length, 2);
      expect(reloaded.spentCents, 0);
    });

    test('stored current-month key: totals untouched', () async {
      final doc = _v1Document()
        ..['monthKey'] = monthKeyFor(DateTime.now());
      final store = StorageService(
        MemoryStore({StorageService.stateKey: jsonEncode(doc)}),
      );
      final controller = await MomoController.load(store: store);
      expect(controller.spentCents, 38600 + 14200);
      expect(controller.state.lastMonthSpentCents, 150000);
      expect(controller.state.lastMonthCategories, isEmpty);
    });

    test('an expense in a new month rolls over first', () async {
      final store = StorageService(MemoryStore());
      final state = MomoState(
        monthKey: _lastMonthKey(),
        categories: [
          BudgetCategory(
            id: 'cat-0',
            name: 'Food',
            plannedCents: 50000,
            spentCents: 12000,
          ),
        ],
      );
      final controller = MomoController(state: state, store: store);
      await controller.addExpense(
        categoryId: 'cat-0',
        amountCents: 500,
        note: 'New month shop',
      );
      // The old month's 12000 was archived; the new expense lands in a
      // fresh month on its own.
      expect(controller.state.lastMonthSpentCents, 12000);
      expect(controller.state.lastMonthCategories.length, 1);
      expect(controller.state.lastMonthCategories.first.spentCents, 12000);
      expect(controller.spentCents, 500);
      expect(controller.state.monthKey, monthKeyFor(DateTime.now()));
    });

    test('an expense in the current month does not roll over', () async {
      final store = StorageService(MemoryStore());
      final state = MomoState(
        categories: [
          BudgetCategory(
            id: 'cat-0',
            name: 'Food',
            plannedCents: 50000,
            spentCents: 12000,
          ),
        ],
      );
      final controller = MomoController(state: state, store: store);
      await controller.addExpense(
        categoryId: 'cat-0',
        amountCents: 500,
        note: 'Same month shop',
      );
      expect(controller.state.lastMonthSpentCents, 0);
      expect(controller.state.lastMonthCategories, isEmpty);
      expect(controller.spentCents, 12500);
    });
  });
}
