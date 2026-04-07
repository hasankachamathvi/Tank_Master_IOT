import 'package:flutter_test/flutter_test.dart';

import 'package:tank_master/main.dart';

void main() {
  testWidgets('Dashboard renders title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(firebaseReady: false));
    await tester.pump();

    expect(find.text('Water Tank Dashboard'), findsOneWidget);
  });
}
