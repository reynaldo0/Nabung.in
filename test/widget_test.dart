import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nabung_in/main.dart';
import 'package:nabung_in/models/goal_model.dart';
import 'package:nabung_in/screens/add_goal/add_edit_goal_screen.dart';
import 'package:nabung_in/services/storage_service.dart';
import 'package:nabung_in/utils/currency_formatter.dart';

Future<void> _scrollToBottom(WidgetTester tester) async {
  final verticalScrollable = find.byWidgetPredicate(
    (widget) => widget is Scrollable && widget.axis == Axis.vertical,
  );
  final state = tester.state<ScrollableState>(verticalScrollable);
  for (var i = 0; i < 3; i++) {
    state.position.jumpTo(state.position.maxScrollExtent);
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('Nabung.in displays the dashboard empty state', (tester) async {
    SharedPreferences.setMockInitialValues({
      StorageService.onboardingCompletedKey: true,
    });
    final storage = await StorageService.initialize();
    await tester.pumpWidget(NabungInApp(storage: storage));
    await tester.pumpAndSettle();

    expect(find.text('Nabung.in'), findsOneWidget);
    expect(find.text('Belum ada target tabungan.'), findsOneWidget);
    expect(find.text('Total Tabungan Aktif'), findsOneWidget);
    expect(
      find.text('0 target siap dibeli • 0 target sedang berjalan'),
      findsOneWidget,
    );
  });

  testWidgets('creating a goal with installment calculator refreshes dashboard', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      StorageService.onboardingCompletedKey: true,
    });
    final storage = await StorageService.initialize();
    await tester.pumpWidget(NabungInApp(storage: storage));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Target baru'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Laptop');
    await tester.enterText(find.byType(TextFormField).at(1), '15000000');
    await tester.enterText(find.byType(TextFormField).at(2), '1500000');
    await tester.pumpAndSettle();

    expect(find.textContaining('10 bulan lagi'), findsOneWidget);

    await _scrollToBottom(tester);
    await tester.tap(find.text('Simpan target'));
    await tester.pumpAndSettle();

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Rencana Rp 1.500.000 / bulan'), findsOneWidget);
    expect(
      find.text('0 target siap dibeli • 1 target sedang berjalan'),
      findsOneWidget,
    );
  });

  testWidgets('switching calculator to deadline mode computes periodic amount', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      StorageService.onboardingCompletedKey: true,
    });
    final storage = await StorageService.initialize();

    await tester.pumpWidget(
      MaterialApp(home: AddEditGoalScreen(storage: storage)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Kamera');
    await tester.enterText(find.byType(TextFormField).at(1), '3000000');
    await tester.tap(find.text('Tanggal Target'));
    await tester.pumpAndSettle();

    expect(find.text('REKOMENDASI TABUNGAN RUTIN'), findsOneWidget);
    expect(find.text('Rp 3.000.000 / bulan'), findsOneWidget);

    await _scrollToBottom(tester);
    await tester.tap(find.text('Simpan target'));
    await tester.pumpAndSettle();

    final goals = await storage.getGoals();
    expect(goals.length, 1);
    expect(goals.first.calculationMode, 'deadline');
    expect(goals.first.savingAmount, 3000000);
  });

  testWidgets('editing existing goal preserves currentAmount', (tester) async {
    SharedPreferences.setMockInitialValues({
      StorageService.onboardingCompletedKey: true,
    });
    final storage = await StorageService.initialize();
    final now = DateTime.now().toIso8601String();
    final initialGoal = GoalModel(
      id: 'g-1',
      name: 'Sepeda',
      targetAmount: 2000000,
      currentAmount: 500000,
      savingLocation: 'cash',
      status: 'active',
      createdAt: now,
      updatedAt: now,
    );
    await storage.addGoal(initialGoal);

    await tester.pumpWidget(
      MaterialApp(
        home: AddEditGoalScreen(
          storage: storage,
          existingGoal: initialGoal,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit target'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Sepeda Lipat');

    await _scrollToBottom(tester);
    await tester.tap(find.text('Simpan perubahan'));
    await tester.pumpAndSettle();

    final updatedGoals = await storage.getGoals();
    expect(updatedGoals.first.name, 'Sepeda Lipat');
    expect(updatedGoals.first.currentAmount, 500000);
  });

  test('formatRupiah abbreviates trillion values cleanly', () {
    expect(formatRupiah(950000000000), 'Rp 950.000.000.000');
    expect(formatRupiah(1500000000000), 'Rp 1,500 Triliun');
  });

  testWidgets('first launch displays four-step onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.initialize();
    await (await SharedPreferences.getInstance()).setBool(
      StorageService.onboardingCompletedKey,
      false,
    );
    await tester.pumpWidget(NabungInApp(storage: storage));
    await tester.pumpAndSettle();

    expect(
      find.text('Wujudkan rencana,\nsatu target setiap saat.'),
      findsOneWidget,
    );
    expect(find.text('Lewati'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);

    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    expect(find.text('Total Tabungan Aktif'), findsOneWidget);
    expect(storage.hasCompletedOnboarding, isTrue);
  });
}