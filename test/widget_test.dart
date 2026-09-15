import 'package:flutter_test/flutter_test.dart';

import 'package:tank_master/main.dart';

void main() {
  testWidgets('Splash screen transitions to login',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Tank Master'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
