import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import 'alerts_page.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';
import 'tanks_page.dart';
import 'usage_page.dart';

// The main app shell that contains the bottom navigation and manages switching between the different pages. It also passes the authenticated user and Firebase readiness state down to the relevant pages.
class AppShell extends StatefulWidget 
{
  const AppShell({
    super.key,
    required this.user,
    required this.firebaseReady,
  });

  final AppUser user;
  final bool firebaseReady;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardPage(firebaseReady: widget.firebaseReady),
      const TanksPage(),
      const UsagePage(),
      const AlertsPage(),
      ProfilePage(
        user: widget.user,
        onLogout: () {
          AuthService.instance.logout();
        },
      ),
    ];

    final titles = <String>[
      'Dashboard',
      'Tanks',
      'Usage',
      'Alerts',
      'Profile',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Tank Master - ${titles[_index]}'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFFDCEEFD),
        indicatorColor: const Color(0xFF90CAF9),
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.water), label: 'Tanks'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Usage'),
          NavigationDestination(icon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
