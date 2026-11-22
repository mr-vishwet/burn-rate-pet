import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:momo/screens/checkin_screen.dart';
import 'package:momo/screens/verify_screen.dart';
import 'package:momo/services/storage_service.dart';
import 'package:momo/state/momo_controller.dart';
import 'package:momo/state/momo_scope.dart';
import 'package:momo/state/momo_state.dart';

/// A store whose writes always fail — the storage-full / storage-blocked
/// failure mode on web (localStorage quota or unavailable storage).
class ThrowingStore implements KeyValueStore {
  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> write(String key, String value) async {
    throw StateError('storage unavailable');
  }

  @override
  Future<void> remove(String key) async {}
}

Widget _testApp(MomoController controller, Widget screen) {
  return MomoScope(
    notifier: controller,
    child: MaterialApp(home: screen),
  );
}

MomoController _failingController() => MomoController(
  state: MomoState.seededDemo(now: DateTime.now()),
  store: StorageService(ThrowingStore()),
);

void main() {
  group('Check-in save failure', () {
    testWidgets('a failed save re-enables the button and shows an error',
        (tester) async {
      await tester.pumpWidget(
        _testApp(_failingController(), const CheckinScreen()),
      );
      await tester.pump();

      // Answer all 10 questions with the middle option. Nine questions
      // call it 'Okay'; Movement calls it 'Some'. The scroll position
      // persists between questions, so scroll each target into view
      // before tapping (as a real user would scroll).
      for (var i = 0; i < 10; i++) {
        final option = find.text('Okay').evaluate().isNotEmpty
            ? find.text('Okay')
            : find.text('Some');
        await tester.ensureVisible(option);
        await tester.pump();
        await tester.tap(option);
        await tester.pump();
        final next = find.text(i < 9 ? 'Next question' : 'See my result');
        await tester.ensureVisible(next);
        await tester.pump();
        await tester.tap(next);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      // The error is shown and the button is usable again (not stuck
      // disabled with no message).
      expect(
        find.text("Couldn't save your check-in — please try again."),
        findsOneWidget,
      );
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'See my result'),
      );
      expect(button.onPressed, isNotNull);
    });
  });

  group('Verify save failure', () {
    testWidgets('a failed save re-enables the button and shows an error',
        (tester) async {
      final controller = _failingController();
      await controller.beginCreateAccount(
        email: 'you@example.com',
        name: "Momo's human",
      );
      await tester.pumpWidget(
        _testApp(controller, const VerifyScreen()),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();
      await tester.tap(find.text('Verify & continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The error is shown and the button is usable again (not stuck on
      // "Verifying…" forever).
      expect(
        find.text("Couldn't save your sign-in — please try again."),
        findsOneWidget,
      );
      expect(find.text('Verify & continue'), findsOneWidget);
      expect(find.text('Verifying…'), findsNothing);
    });
  });
}
