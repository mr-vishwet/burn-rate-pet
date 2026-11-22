import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:momo/services/import_service.dart';
import 'package:momo/services/storage_service.dart';
import 'package:momo/state/momo_controller.dart';
import 'package:momo/state/momo_state.dart';

/// A populated state, built through the controller's own actions (the
/// way real data gets in) — the round-trip fixture.
Future<MomoController> _populatedController(StorageService store) async {
  final controller = await MomoController.load(store: store);
  await controller.submitCheckin(
    questionIds: List.generate(10, (i) => 'q$i'),
    answers: [4, 3, 4, 2, 3, 4, 4, 3, 2, 3],
  );
  await controller.addRoutine(name: 'Read', timeLabel: '1:00 PM');
  await controller.toggleRoutineDone(
    controller.state.routines.first.id,
  );
  await controller.addCategory(name: 'Food', plannedCents: 50000);
  await controller.addExpense(
    categoryId: controller.state.categories.first.id,
    amountCents: 4200,
    note: 'Groceries',
  );
  await controller.renamePet('Pip');
  await controller.setGoals(
    happinessGoal: 85,
    monthlyBudgetGoalCents: 200000,
  );
  return controller;
}

void main() {
  group('ImportService.parseBackup', () {
    test('parses a real export', () async {
      final controller = await _populatedController(
        StorageService(MemoryStore()),
      );
      final parsed = ImportService.parseBackup(controller.exportJson());
      expect(parsed.petName, 'Pip');
      expect(parsed.checkins.length, 1);
      expect(parsed.checkins.first.score, 80);
      expect(parsed.routines.length, 1);
      expect(parsed.routines.first.streakDays, 1);
      expect(parsed.categories.length, 1);
      expect(parsed.categories.first.spentCents, 4200);
      expect(parsed.expenses.length, 1);
      expect(parsed.happinessGoal, 85);
      expect(parsed.monthlyBudgetGoalCents, 200000);
    });

    test('rejects garbage JSON with a clear error', () {
      expect(
        () => ImportService.parseBackup('not json {{{'),
        throwsA(
          isA<ImportFormatException>().having(
            (e) => e.message,
            'message',
            contains('not valid JSON'),
          ),
        ),
      );
    });

    test('rejects an empty file', () {
      expect(
        () => ImportService.parseBackup(''),
        throwsA(isA<ImportFormatException>()),
      );
    });

    test('rejects a JSON array (not an object)', () {
      expect(
        () => ImportService.parseBackup('[1, 2, 3]'),
        throwsA(
          isA<ImportFormatException>().having(
            (e) => e.message,
            'message',
            contains('not a Momo backup'),
          ),
        ),
      );
    });

    test('rejects a missing version', () {
      expect(
        () => ImportService.parseBackup('{"petName": "Momo"}'),
        throwsA(
          isA<ImportFormatException>().having(
            (e) => e.message,
            'message',
            contains('version'),
          ),
        ),
      );
    });

    test('rejects an unknown version', () {
      expect(
        () => ImportService.parseBackup(
          '{"version": 99, "petName": "Momo"}',
        ),
        throwsA(
          isA<ImportFormatException>().having(
            (e) => e.message,
            'message',
            contains('version'),
          ),
        ),
      );
    });

    test('rejects a damaged backup (wrong shape)', () {
      expect(
        () => ImportService.parseBackup(
          '{"version": 1, "checkins": "nope"}',
        ),
        throwsA(
          isA<ImportFormatException>().having(
            (e) => e.message,
            'message',
            contains('damaged'),
          ),
        ),
      );
    });
  });

  group('import round-trip', () {
    test('export -> delete-all -> import restores byte-identically',
        () async {
      final store = StorageService(MemoryStore());
      final controller = await _populatedController(store);
      final before = jsonEncode(controller.state.toJson());
      final exported = controller.exportJson();

      await controller.deleteAllData();
      expect(controller.state.checkins, isEmpty);
      expect(controller.state.petName, 'Momo');

      final imported = ImportService.parseBackup(exported);
      await controller.importState(imported);
      expect(jsonEncode(controller.state.toJson()), before);
    });

    test('parsing a backup alone changes nothing', () async {
      final store = StorageService(MemoryStore());
      final controller = await _populatedController(store);
      final before = jsonEncode(controller.state.toJson());
      final other = MomoState.fresh()..petName = 'Someone else';
      ImportService.parseBackup(jsonEncode(other.toJson()));
      expect(jsonEncode(controller.state.toJson()), before);
      expect(controller.state.petName, 'Pip');
    });

    test('imported state persists across reload', () async {
      final store = StorageService(MemoryStore());
      final controller = await _populatedController(store);
      final exported = controller.exportJson();
      await controller.deleteAllData();

      final imported = ImportService.parseBackup(exported);
      await controller.importState(imported);
      final reloaded = await MomoController.load(store: store);
      expect(reloaded.state.petName, 'Pip');
      expect(reloaded.state.checkins.length, 1);
      expect(reloaded.state.routines.length, 1);
      expect(reloaded.spentCents, 4200);
    });
  });
}
