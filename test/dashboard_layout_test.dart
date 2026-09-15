import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tank_master/screens/dashboard_page.dart';

void main() {
  for (final width in [320.0, 900.0]) {
    testWidgets('Dashboard fits width $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(
          home: Scaffold(body: DashboardPage(firebaseReady: false))));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Main rooftop tank'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
