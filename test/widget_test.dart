import 'package:flutter_test/flutter_test.dart';

import 'package:tank_master/main.dart';

void main() {
  testWidgets('Login screen renders title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Tank Master Login'), findsOneWidget);
  });
}
