import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../widgets/mobile_ui.dart';
import 'alerts_page.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';
import 'tanks_page.dart';
import 'usage_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.user, required this.firebaseReady});
  final AppUser user;
  final bool firebaseReady;
  @override
  State<AppShell> createState() => _AppShellState();
}
class _AppShellState extends State<AppShell> {
  int _index = 0;
  final Set<int> _visited = {0};
  static const _labels = ['Home', 'Tanks', 'Usage', 'Alerts', 'Profile'];
  static const _colors = [AppColors.aqua, AppColors.aqua, AppColors.violet, AppColors.coral, AppColors.mint];
  static const _icons = [Icons.home_rounded, Icons.water_rounded, Icons.bar_chart_rounded, Icons.notifications_rounded, Icons.person_rounded];
  void _select(int index) {
    if (index == _index) return;
    HapticFeedback.selectionClick();
    setState(() { _index = index; _visited.add(index); });
  }
  @override
  Widget build(BuildContext context) {
    final pages = [DashboardPage(firebaseReady: widget.firebaseReady), const TanksPage(),
      const UsagePage(), const AlertsPage(), ProfilePage(user: widget.user, onLogout: () { AuthService.instance.logout(); })];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        leading: Padding(padding: const EdgeInsets.only(left: 16), child: Icon(Icons.water_drop_rounded, color: _colors[_index], size: 30)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tank Master', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          Text(_labels[_index] == 'Home' ? 'MY SMART HOME' : _labels[_index].toUpperCase(), style: TextStyle(fontSize: 9, letterSpacing: 1.8, color: _colors[_index], fontWeight: FontWeight.w700)),
        ]),
        actions: [IconButton(tooltip: 'Open alerts', onPressed: () => _select(3), icon: const Icon(Icons.notifications_none_rounded)), const SizedBox(width: 8)],
        backgroundColor: const Color(0xFFF5F8FC), foregroundColor: AppColors.ink,
        centerTitle: false, elevation: 0, scrolledUnderElevation: 0,
      ),
      body: SafeArea(top: false, child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: IndexedStack(index: _index, children: [
          for (var i = 0; i < pages.length; i++)
            TickerMode(enabled: i == _index, child: _visited.contains(i)
              ? PageEntrance(child: pages[i]) : const SizedBox.shrink()),
        ])))),
      bottomNavigationBar: SafeArea(top: false, child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26),
          boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 4))]),
        child: Row(children: [for (var i = 0; i < _labels.length; i++)
          Expanded(child: Semantics(selected: i == _index, button: true, label: _labels[i],
            child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => _select(i),
              child: AnimatedContainer(duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: i == _index ? _colors[i].withValues(alpha: 0.12) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  AnimatedScale(scale: i == _index ? 1.1 : 1, duration: const Duration(milliseconds: 250),
                    child: Icon(_icons[i], color: i == _index ? _colors[i] : const Color(0xFF899BA8), size: 23)),
                  const SizedBox(height: 5),
                  Text(_labels[i], style: TextStyle(fontSize: 10, fontWeight: i == _index ? FontWeight.w800 : FontWeight.w500, color: i == _index ? _colors[i] : const Color(0xFF647A89))),
                ]))))),
        ]))),
    );
  }
}
