import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tank_master/models/app_user.dart';
import 'package:tank_master/screens/app_shell.dart';
import 'package:tank_master/screens/dashboard_page.dart';
import 'package:tank_master/screens/tanks_page.dart';
import 'package:tank_master/screens/usage_page.dart';
import 'package:tank_master/screens/alerts_page.dart';
import 'package:tank_master/screens/profile_page.dart';
import 'package:tank_master/screens/login_screen.dart';
import 'package:tank_master/screens/register_screen.dart';
import 'package:tank_master/screens/splash_screen.dart';

const user = AppUser(
    name: 'Alex Morgan', email: 'alex@example.com', location: 'Colombo');
void main() {
  final pages = <String, Widget>{
    'home': const DashboardPage(firebaseReady: false),
    'tanks': const TanksPage(),
    'usage': const UsagePage(),
    'alerts': const AlertsPage(),
    'profile': ProfilePage(user: user, onLogout: () {}),
    'login': const LoginScreen(),
    'register': const RegisterScreen(),
    'splash': const SplashScreen(),
    'details': const TankDetailsPage(
        name: 'Main rooftop tank',
        location: 'Block A',
        level: 72,
        capacity: 1000,
        status: 'Filling',
        pump: true),
  };
  for (final width in [320.0, 390.0]) {
    for (final entry in pages.entries) {
      testWidgets('${entry.key} fits phone $width', (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(
            theme: ThemeData(useMaterial3: true),
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(width == 320 ? 1.2 : 1)),
                child: child!),
            home: Scaffold(body: entry.value)));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        expect(tester.takeException(), isNull);
        final scroll = find.byType(Scrollable);
        if (scroll.evaluate().isNotEmpty) {
          for (var i = 0; i < 5; i++) {
            await tester.drag(scroll.first, const Offset(0, -350));
            await tester.pump(const Duration(milliseconds: 700));
            expect(tester.takeException(), isNull);
          }
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
  testWidgets('Navigation preserves usage selection and alerts can be read',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        const MaterialApp(home: AppShell(user: user, firebaseReady: false)));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Usage'));
    await tester.pump(const Duration(seconds: 1));
    await tester.ensureVisible(find.text('Month'));
    await tester.tap(find.text('Month'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Alerts'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Mark all read'));
    await tester.pump();
    await tester.tap(find.text('Unread'));
    await tester.pump();
    expect(find.text('All caught up!'), findsOneWidget);
    await tester.tap(find.text('Usage'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Sample month / litres per week'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  for (final page in [const LoginScreen(), const RegisterScreen()]) {
    testWidgets('${page.runtimeType} supports an open phone keyboard',
        (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(MaterialApp(home: page));
      await tester.pump(const Duration(seconds: 2));
      final field = find.byType(TextFormField).last;
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.enterText(field, 'sample-password');
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
