import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nabung_in/main.dart';
import 'package:nabung_in/services/storage_service.dart';

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
  });

  testWidgets('creating a goal closes the dialog and refreshes the dashboard', (
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
    await tester.tap(find.text('Simpan target'));
    await tester.pumpAndSettle();

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Belum ada target tabungan.'), findsNothing);
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
