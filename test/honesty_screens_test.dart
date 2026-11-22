import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:momo/core/format.dart';
import 'package:momo/engine/budget.dart';
import 'package:momo/engine/checkin.dart';
import 'package:momo/engine/routines.dart';
import 'package:momo/screens/account_screen.dart';
import 'package:momo/screens/add_details_screen.dart';
import 'package:momo/screens/budget_screen.dart';
import 'package:momo/screens/checkin_result_screen.dart';
import 'package:momo/screens/connected_screen.dart';
import 'package:momo/screens/goal_setter_screen.dart';
import 'package:momo/screens/lock_screen_screen.dart';
import 'package:momo/screens/milestone_screen.dart';
import 'package:momo/screens/onboarding_b_screen.dart';
import 'package:momo/screens/overlay_bubble_screen.dart';
import 'package:momo/screens/widget_screen.dart';
import 'package:momo/services/storage_service.dart';
import 'package:momo/state/momo_controller.dart';
import 'package:momo/state/momo_scope.dart';
import 'package:momo/state/momo_state.dart';

MomoController _controller(MomoState state) => MomoController(
  state: state,
  store: StorageService(MemoryStore()),
);

Widget _testApp(MomoController controller, Widget screen) {
  return MomoScope(
    notifier: controller,
    child: MaterialApp(
      home: screen,
      // Screens navigate on save; route anywhere harmlessly.
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const Scaffold(body: Text('routed')),
      ),
    ),
  );
}

/// A check-in entry for today with explicit answers. [sleep] and
/// [movement] are the 0-4 answers to those questions; [others] fills the
/// remaining eight questions; the score is computed from the answers.
CheckinEntry _checkin({
  required int sleep,
  required int movement,
  required int others,
}) {
  final ids = kCheckinBank.map((q) => q.id).toList();
  final answers = ids.map((id) {
    if (id == 'sleep') return sleep;
    if (id == 'movement') return movement;
    return others;
  }).toList();
  return CheckinEntry(
    dayKey: dayKey(DateTime.now()),
    questionIds: ids,
    answers: answers,
    score: scoreCheckin(answers),
  );
}

MomoState _accountState() {
  final state = MomoState.fresh();
  state.authMode = AuthMode.account;
  state.email = 'you@example.com';
  state.displayName = "Momo's human";
  state.shareCode = 'abc123';
  return state;
}

void main() {
  group('sync honesty', () {
    testWidgets('account screen says saved locally, never synced',
        (tester) async {
      await tester.pumpWidget(
        _testApp(_controller(_accountState()), const AccountScreen()),
      );
      await tester.pump();
      expect(find.text('Saved on this device'), findsOneWidget);
      expect(find.text('Synced · just now'), findsNothing);
    });

    testWidgets('connected screen says saved locally, never synced',
        (tester) async {
      await tester.pumpWidget(
        _testApp(_controller(_accountState()), const ConnectedScreen()),
      );
      await tester.pump();
      expect(find.text('Saved on this device'), findsOneWidget);
      expect(find.text('Synced · just now'), findsNothing);
    });

    testWidgets('new link snackbar makes no false invalidation claim',
        (tester) async {
      await tester.pumpWidget(
        _testApp(_controller(_accountState()), const ConnectedScreen()),
      );
      await tester.pump();
      await tester.ensureVisible(find.text('New link'));
      await tester.tap(find.text('New link'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.text('New link generated. Share this one instead.'),
        findsOneWidget,
      );
      expect(find.textContaining('stops working'), findsNothing);
    });
  });

  group('milestone header is real', () {
    testWidgets('fresh state shows no milestone claim and the real count',
        (tester) async {
      await tester.pumpWidget(
        _testApp(_controller(MomoState.fresh()), const MilestoneScreen()),
      );
      await tester.pump();
      expect(find.text('No milestones yet'), findsOneWidget);
      expect(find.text('30 days of check-ins!'), findsNothing);
      expect(find.textContaining('0 check-in days so far'), findsOneWidget);
    });

    testWidgets('headline is the latest milestone actually earned',
        (tester) async {
      final state = MomoState.fresh();
      state.checkins = [
        _checkin(sleep: 3, movement: 3, others: 3),
      ];
      state.milestones = state.milestones.map((m) {
        if (m.id == 'first-checkin' || m.id == 'checkins-30') {
          return m.copyWith(unlocked: true);
        }
        return m;
      }).toList();
      await tester.pumpWidget(
        _testApp(_controller(state), const MilestoneScreen()),
      );
      await tester.pump();
      expect(find.text('30 days of check-ins!'), findsOneWidget);
      expect(find.text('No milestones yet'), findsNothing);
    });
  });

  group('check-in result observations come from the answers', () {
    testWidgets('good sleep + movement says so', (tester) async {
      final state = MomoState.fresh();
      state.checkins = [
        _checkin(sleep: 4, movement: 4, others: 3), // score 80
      ];
      state.routines = [
        Routine(id: 'r1', name: 'Read', timeLabel: '1:00 PM'),
      ];
      await tester.pumpWidget(
        _testApp(_controller(state), const CheckinResultScreen()),
      );
      await tester.pump();
      expect(
        find.textContaining('you slept well and moved today.'),
        findsOneWidget,
      );
    });

    testWidgets('high score without sleep or movement says neither',
        (tester) async {
      final state = MomoState.fresh();
      state.checkins = [
        _checkin(sleep: 0, movement: 0, others: 4), // score 80
      ];
      state.routines = [
        Routine(id: 'r1', name: 'Read', timeLabel: '1:00 PM'),
      ];
      await tester.pumpWidget(
        _testApp(_controller(state), const CheckinResultScreen()),
      );
      await tester.pump();
      expect(find.textContaining('slept well'), findsNothing);
      expect(find.textContaining('you moved today'), findsNothing);
      expect(
        find.textContaining('without great sleep or movement'),
        findsOneWidget,
      );
    });
  });

  group('onboarding shows no invented numbers', () {
    testWidgets('fresh state shows dashes, not 76 and 72',
        (tester) async {
      await tester.pumpWidget(
        _testApp(
          _controller(MomoState.fresh()),
          const OnboardingBScreen(),
        ),
      );
      await tester.pump();
      expect(find.text('76'), findsNothing);
      expect(find.text('72'), findsNothing);
      expect(find.textContaining('No index yet'), findsOneWidget);
    });
  });

  group('dead toggles are honestly labelled', () {
    testWidgets('widget screen has no toggle and no add button',
        (tester) async {
      await tester.pumpWidget(
        _testApp(_controller(MomoState.fresh()), const WidgetScreen()),
      );
      await tester.pump();
      expect(
        find.textContaining('Coming with the mobile app'),
        findsOneWidget,
      );
      expect(find.byType(Switch), findsNothing);
      expect(find.text('Add widget'), findsNothing);
    });

    testWidgets('lock-screen screen has no toggle and no fake snooze',
        (tester) async {
      await tester.pumpWidget(
        _testApp(_controller(MomoState.fresh()), const LockScreenScreen()),
      );
      await tester.pump();
      expect(
        find.textContaining('Coming with the mobile app'),
        findsOneWidget,
      );
      expect(find.byType(Switch), findsNothing);
      expect(find.text('Snooze 1h'), findsNothing);
      expect(find.text('Check in'), findsOneWidget);
    });

    testWidgets('overlay bubble keeps its real in-app toggle',
        (tester) async {
      await tester.pumpWidget(
        _testApp(
          _controller(MomoState.fresh()),
          const OverlayBubbleScreen(),
        ),
      );
      await tester.pump();
      expect(find.byType(Switch), findsOneWidget);
      expect(
        find.textContaining("parks over Momo's screens"),
        findsOneWidget,
      );
      expect(
        find.textContaining('coming with the mobile app'),
        findsWidgets,
      );
    });
  });

  group('budget simulator derives from the user plan', () {
    testWidgets('simulator rows use the user categories and currency',
        (tester) async {
      final state = MomoState.fresh();
      state.currency = 'EUR';
      state.categories = [
        BudgetCategory(
          id: 'c1',
          name: 'Groceries',
          plannedCents: 60000,
          spentCents: 10000,
        ),
        BudgetCategory(
          id: 'c2',
          name: 'Transport',
          plannedCents: 20000,
          spentCents: 5000,
        ),
      ];
      state.monthlyBudgetGoalCents = 100000;
      await tester.pumpWidget(
        _testApp(_controller(state), const BudgetScreen()),
      );
      await tester.pump();
      // 10% tighter than the user's own plans, in the user's currency.
      expect(find.text('Groceries €540/mo'), findsOneWidget);
      expect(find.text('Transport €180/mo'), findsOneWidget);
      expect(find.text('Under €1,000/mo total'), findsOneWidget);
      expect(find.textContaining('\$450'), findsNothing);
      expect(find.textContaining('\$1,300'), findsNothing);
      expect(find.textContaining('\$2,200'), findsNothing);
    });
  });

  group('goal presets derive from the user plan', () {
    testWidgets('chips are the plan and 10% either side',
        (tester) async {
      final state = MomoState.fresh();
      state.monthlyBudgetGoalCents = 300000;
      state.categories = [
        BudgetCategory(
          id: 'c1',
          name: 'Everything',
          plannedCents: 300000,
        ),
      ];
      await tester.pumpWidget(
        _testApp(_controller(state), const GoalSetterScreen()),
      );
      await tester.pump();
      expect(find.text('\$2,700'), findsOneWidget);
      expect(find.text('\$3,000'), findsOneWidget);
      expect(find.text('\$3,300'), findsOneWidget);
      expect(find.textContaining('Momo offers \$2,700'), findsOneWidget);
      expect(find.text('\$2,200'), findsNothing);
    });
  });

  group('expenses allow cents', () {
    testWidgets('add-details saves a decimal category plan as cents',
        (tester) async {
      final controller = _controller(MomoState.fresh());
      await tester.pumpWidget(
        _testApp(controller, const AddDetailsScreen()),
      );
      await tester.pump();
      // First category field (Food): type a decimal amount.
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(1), '12.50');
      await tester.pump();
      await tester.ensureVisible(find.text('Wake Momo up'));
      await tester.tap(find.text('Wake Momo up'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.state.categories.first.plannedCents, 1250);
    });
  });
}
