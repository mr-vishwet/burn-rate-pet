import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:momo/engine/happiness.dart';
import 'package:momo/services/storage_service.dart';
import 'package:momo/state/momo_controller.dart';
import 'package:momo/state/momo_state.dart';

void main() {
  group('MomoController seeded demo', () {
    late MomoController controller;

    setUp(() async {
      controller = await MomoController.load(
        store: StorageService(MemoryStore()),
      );
    });

    test('first launch seeds the demo: index 75, Content band', () {
      expect(controller.state.demoSeeded, isTrue);
      expect(controller.moodScore, 76);
      expect(controller.routineScoreValue, 72);
      expect(controller.budgetScoreValue, 78);
      expect(controller.indexRaw, closeTo(75.1, 0.001));
      expect(controller.index, 75);
      expect(controller.band, HappinessBand.content);
    });

    test('seeded budget is \$2,400 planned, \$1,936 spent', () {
      expect(controller.plannedCents, 240000);
      expect(controller.spentCents, 193600);
      expect(controller.leftCents, 46400);
      expect(controller.state.categories.length, 5);
    });

    test('seeded routines: 6 routines, 5 of 6 done today', () {
      expect(controller.state.routines.length, 6);
      expect(controller.routinesDoneTodayCount, 5);
      expect(controller.bestStreak.days, 12);
      expect(controller.bestStreak.routine, 'Morning workout');
    });

    test('seeded history climbs 68 -> 75', () {
      expect(controller.state.indexHistory.length, 6);
      expect(controller.state.indexHistory.first.index, 68);
      expect(controller.state.indexHistory.last.index, 75);
    });

    test('state persists and reloads identically', () async {
      final store = StorageService(MemoryStore());
      final first = await MomoController.load(store: store);
      await first.renamePet('Pip');
      final second = await MomoController.load(store: store);
      expect(second.state.petName, 'Pip');
      expect(second.index, 75);
    });
  });

  group('MomoController actions', () {
    late MomoController controller;

    setUp(() async {
      controller = await MomoController.load(
        store: StorageService(MemoryStore()),
      );
    });

    test('submitting a check-in updates the mood component', () async {
      final before = controller.moodScore;
      await controller.submitCheckin(
        questionIds: List.generate(10, (i) => 'q$i'),
        answers: List.filled(10, 4),
      );
      expect(controller.lastCheckin?.score, 100);
      expect(controller.moodScore, isNot(before));
      expect(controller.checkinDueToday, isFalse);
    });

    test('toggling a routine grows its streak by one', () async {
      final routine = controller.state.routines.firstWhere(
        (r) => r.name == 'Evening walk',
      );
      final before = routine.streakDays;
      await controller.toggleRoutineDone(routine.id);
      expect(routine.streakDays, before + 1);
      expect(controller.routinesDoneTodayCount, 6);
    });

    test('logging an expense moves spent and the budget score', () async {
      final before = controller.spentCents;
      await controller.addExpense(
        categoryId: 'cat-0',
        amountCents: 10000,
        note: 'Test shop',
      );
      expect(controller.spentCents, before + 10000);
      expect(controller.state.expenses.first.note, 'Test shop');
    });

    test('clearing demo data leaves no invented index', () async {
      await controller.clearDemoData();
      expect(controller.state.demoSeeded, isFalse);
      expect(controller.moodScore, isNull);
      expect(controller.routineScoreValue, isNull);
      expect(controller.index, isNull);
      expect(controller.state.petName, 'Momo');
    });

    test('sign-in flow creates a local account', () async {
      await controller.beginCreateAccount(
        email: 'you@example.com',
        name: "Momo's human",
      );
      final isNew = await controller.verifyCode('123456');
      expect(isNew, isTrue);
      expect(controller.state.authMode, AuthMode.account);
      expect(controller.state.email, 'you@example.com');
      expect(controller.state.syncOn, isTrue);
      expect(controller.shareUrl, startsWith('momo.app/s/'));
      await controller.signOut();
      expect(controller.state.authMode, AuthMode.guest);
      expect(controller.state.email, isNull);
    });

    test('verify without a pending sign-in returns null', () async {
      expect(await controller.verifyCode('123456'), isNull);
    });

    test('export is valid JSON with the full state', () {
      final decoded = jsonDecode(controller.exportJson());
      expect(decoded, isA<Map<String, dynamic>>());
      expect(decoded['petName'], 'Momo');
      expect(decoded['categories'], isA<List>());
      expect(decoded['checkins'], isA<List>());
    });
  });
}
