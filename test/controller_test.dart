import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:momo/core/format.dart';
import 'package:momo/engine/routines.dart';
import 'package:momo/services/storage_service.dart';
import 'package:momo/state/momo_controller.dart';
import 'package:momo/state/momo_state.dart';

void main() {
  group('MomoController first launch', () {
    test('first launch is fresh and empty: no index, no data', () async {
      final controller = await MomoController.load(
        store: StorageService(MemoryStore()),
      );
      expect(controller.state.checkins, isEmpty);
      expect(controller.state.routines, isEmpty);
      expect(controller.state.categories, isEmpty);
      expect(controller.state.expenses, isEmpty);
      expect(controller.state.indexHistory, isEmpty);
      expect(controller.state.onboarded, isFalse);
      expect(controller.moodScore, isNull);
      expect(controller.routineScoreValue, isNull);
      expect(controller.index, isNull);
      expect(controller.band, isNull);
      expect(controller.spentCents, 0);
      expect(controller.plannedCents, 0);
      // The fresh state belongs to the current month.
      expect(
        controller.state.monthKey,
        monthKeyFor(DateTime.now()),
      );
      // The milestones exist, locked, waiting to be earned.
      expect(controller.state.milestones.length, 5);
      expect(
        controller.state.milestones.every((m) => !m.unlocked),
        isTrue,
      );
    });

    test('first launch persists the fresh state', () async {
      final store = StorageService(MemoryStore());
      await MomoController.load(store: store);
      final reloaded = await MomoController.load(store: store);
      expect(reloaded.state.checkins, isEmpty);
      expect(reloaded.state.onboarded, isFalse);
      expect(reloaded.index, isNull);
    });

    test('state persists and reloads identically', () async {
      final store = StorageService(MemoryStore());
      final first = await MomoController.load(store: store);
      await first.renamePet('Pip');
      final second = await MomoController.load(store: store);
      expect(second.state.petName, 'Pip');
      expect(second.index, isNull);
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
      expect(controller.moodScore, isNull);
      await controller.submitCheckin(
        questionIds: List.generate(10, (i) => 'q$i'),
        answers: List.filled(10, 4),
      );
      expect(controller.lastCheckin?.score, 100);
      expect(controller.moodScore, 100);
      expect(controller.checkinDueToday, isFalse);
      // Still no index: routines are missing (never invent a number).
      expect(controller.index, isNull);
    });

    test('toggling a routine grows its streak by one', () async {
      controller.state.routines.add(
        Routine(
          id: 'r-walk',
          name: 'Evening walk',
          timeLabel: '6:30 PM',
          completions: {
            dayKey(DateTime.now().subtract(const Duration(days: 1))),
          },
          streakDays: 3,
          lastCompletedKey: dayKey(
            DateTime.now().subtract(const Duration(days: 1)),
          ),
        ),
      );
      final routine = controller.state.routines.first;
      await controller.toggleRoutineDone(routine.id);
      expect(routine.streakDays, 4);
      expect(controller.routinesDoneTodayCount, 1);
    });

    test('undoing a routine reverts the streak increment', () async {
      final yesterday = dayKey(
        DateTime.now().subtract(const Duration(days: 1)),
      );
      controller.state.routines.add(
        Routine(
          id: 'r-walk',
          name: 'Evening walk',
          timeLabel: '6:30 PM',
          completions: {yesterday},
          streakDays: 3,
          lastCompletedKey: yesterday,
        ),
      );
      final routine = controller.state.routines.first;
      await controller.toggleRoutineDone(routine.id);
      expect(routine.streakDays, 4);
      expect(controller.routinesDoneTodayCount, 1);
      await controller.toggleRoutineDone(routine.id);
      expect(routine.streakDays, 3);
      expect(controller.routinesDoneTodayCount, 0);
      expect(routine.lastCompletedKey, yesterday);
    });

    test('undoing a routine done today drops its streak by one', () async {
      final yesterday = dayKey(
        DateTime.now().subtract(const Duration(days: 1)),
      );
      controller.state.routines.add(
        Routine(
          id: 'r-wake',
          name: 'Wake up',
          timeLabel: '7:00 AM',
          completions: {yesterday, dayKey(DateTime.now())},
          streakDays: 8,
          lastCompletedKey: dayKey(DateTime.now()),
        ),
      );
      final routine = controller.state.routines.first;
      await controller.toggleRoutineDone(routine.id);
      expect(routine.streakDays, 7);
      expect(controller.routinesDoneTodayCount, 0);
      expect(routine.lastCompletedKey, yesterday);
    });

    test(
      'legacy stale last-completed day: ON then OFF returns the streak '
      'to exactly 4',
      () async {
        // State as persisted by the pre-fix build: the old undo removed
        // today's completion but left the incremented streak and a
        // last-completed day of today. Reproduced through the real
        // storage round-trip, as the live site loads it — an explicit
        // fixture routine, not seeded data.
        final yesterday = dayKey(
          DateTime.now().subtract(const Duration(days: 1)),
        );
        final twoDaysAgo = dayKey(
          DateTime.now().subtract(const Duration(days: 2)),
        );
        final store = StorageService(MemoryStore());
        final doc = MomoState(
          routines: [
            Routine(
              id: 'r-walk',
              name: 'Evening walk',
              timeLabel: '6:30 PM',
              completions: {twoDaysAgo, yesterday},
              streakDays: 4,
              lastCompletedKey: dayKey(DateTime.now()),
            ),
          ],
        ).toJson();
        await store.write(jsonEncode(doc));

        final legacy = await MomoController.load(store: store);
        final routine = legacy.state.routines.first;
        expect(routine.streakDays, 4);
        expect(legacy.routinesDoneTodayCount, 0);

        await legacy.toggleRoutineDone(routine.id);
        expect(routine.streakDays, 5);
        expect(legacy.routinesDoneTodayCount, 1);
        await legacy.toggleRoutineDone(routine.id);
        expect(routine.streakDays, 4);
        expect(legacy.routinesDoneTodayCount, 0);
        expect(routine.lastCompletedKey, yesterday);

        // And it persists: a reload still shows 4, not 3.
        final reloaded = await MomoController.load(store: store);
        expect(reloaded.state.routines.first.streakDays, 4);
      },
    );

    test(
      'paused streak: ON resumes from the frozen value, OFF returns '
      'to it',
      () async {
        // Last completed 5 days ago: the streak is paused at 7, never
        // zeroed by the miss. Completing today grows it by one; undoing
        // returns it to exactly 7.
        final fiveDaysAgo = dayKey(
          DateTime.now().subtract(const Duration(days: 5)),
        );
        controller.state.routines.add(
          Routine(
            id: 'routine-paused',
            name: 'Paused test',
            timeLabel: '6:00 PM',
            completions: {fiveDaysAgo},
            streakDays: 7,
            lastCompletedKey: fiveDaysAgo,
          ),
        );
        final routine = controller.state.routines.last;
        await controller.toggleRoutineDone(routine.id);
        expect(routine.streakDays, 8);
        expect(routine.lastCompletedKey, dayKey(DateTime.now()));
        await controller.toggleRoutineDone(routine.id);
        expect(routine.streakDays, 7);
        expect(routine.lastCompletedKey, fiveDaysAgo);
      },
    );

    test('logging an expense moves spent and the budget score', () async {
      await controller.addCategory(
        name: 'Food',
        plannedCents: 50000,
      );
      final categoryId = controller.state.categories.first.id;
      final before = controller.spentCents;
      await controller.addExpense(
        categoryId: categoryId,
        amountCents: 10000,
        note: 'Test shop',
      );
      expect(controller.spentCents, before + 10000);
      expect(controller.state.expenses.first.note, 'Test shop');
    });

    test('delete-all-data returns the app to a fresh install', () async {
      final store = StorageService(MemoryStore());
      final owned = await MomoController.load(store: store);
      await owned.submitCheckin(
        questionIds: List.generate(10, (i) => 'q$i'),
        answers: List.filled(10, 3),
      );
      await owned.addRoutine(name: 'Read', timeLabel: '1:00 PM');
      await owned.addCategory(name: 'Food', plannedCents: 50000);
      await owned.renamePet('Pip');
      expect(owned.state.checkins, isNotEmpty);
      expect(owned.state.petName, 'Pip');

      await owned.deleteAllData();
      expect(owned.state.checkins, isEmpty);
      expect(owned.state.routines, isEmpty);
      expect(owned.state.categories, isEmpty);
      expect(owned.state.expenses, isEmpty);
      expect(owned.state.indexHistory, isEmpty);
      expect(owned.state.petName, 'Momo');
      expect(owned.state.onboarded, isFalse);
      expect(owned.moodScore, isNull);
      expect(owned.index, isNull);

      // The stored document is removed, not overwritten: the next load
      // is a fresh install.
      expect(await store.read(), isNull);
      final reloaded = await MomoController.load(store: store);
      expect(reloaded.state.onboarded, isFalse);
      expect(reloaded.index, isNull);
    });

    test('setCompanion toggles the in-app bubble', () async {
      expect(controller.state.bubbleEnabled, isTrue);
      await controller.setCompanion(bubbleEnabled: false);
      expect(controller.state.bubbleEnabled, isFalse);
      await controller.setCompanion(bubbleEnabled: true);
      expect(controller.state.bubbleEnabled, isTrue);
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
      final decoded =
          jsonDecode(controller.exportJson()) as Map<String, dynamic>;
      expect(decoded, isA<Map<String, dynamic>>());
      expect(decoded['petName'], 'Momo');
      expect(decoded['categories'], isA<List<dynamic>>());
      expect(decoded['checkins'], isA<List<dynamic>>());
      expect(decoded['version'], 1);
    });
  });

  group('MomoController corrupt stored state', () {
    test('garbage JSON throws CorruptStateException', () async {
      final store = StorageService(
        MemoryStore({StorageService.stateKey: 'not json {{{'}),
      );
      await expectLater(
        MomoController.load(store: store),
        throwsA(isA<CorruptStateException>()),
      );
    });

    test('valid JSON with the wrong shape throws CorruptStateException',
        () async {
      final store = StorageService(
        MemoryStore({
          StorageService.stateKey: '{"checkins": "nope", "routines": 42}',
        }),
      );
      await expectLater(
        MomoController.load(store: store),
        throwsA(isA<CorruptStateException>()),
      );
    });

    test('a JSON array (not an object) throws CorruptStateException',
        () async {
      final store = StorageService(
        MemoryStore({StorageService.stateKey: '[1, 2, 3]'}),
      );
      await expectLater(
        MomoController.load(store: store),
        throwsA(isA<CorruptStateException>()),
      );
    });

    test('a corrupt document is left untouched after a failed load',
        () async {
      const garbage = 'garbage {{{';
      final store = StorageService(
        MemoryStore({StorageService.stateKey: garbage}),
      );
      await expectLater(
        MomoController.load(store: store),
        throwsA(isA<CorruptStateException>()),
      );
      // Never silently re-seeded, never silently discarded: the document
      // is still exactly what it was, for the user to decide about.
      expect(await store.read(), garbage);
    });
  });

  group('MomoController storage failure', () {
    test('a failed verify keeps the pending sign-in for a retry', () async {
      final controller = MomoController(
        state: MomoState.fresh(),
        store: StorageService(_ThrowingStore()),
      );
      await controller.beginCreateAccount(
        email: 'you@example.com',
        name: "Momo's human",
      );
      await expectLater(controller.verifyCode('123456'), throwsStateError);
      expect(controller.pendingEmail, 'you@example.com');
      expect(controller.pendingDisplayName, "Momo's human");
    });
  });
}

/// A store whose writes always fail — the storage-full / storage-blocked
/// failure mode on web.
class _ThrowingStore implements KeyValueStore {
  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> write(String key, String value) async {
    throw StateError('storage unavailable');
  }

  @override
  Future<void> remove(String key) async {}
}
