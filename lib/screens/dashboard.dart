import 'dart:async';

import 'package:flutter/material.dart';

import '../models/tank_model.dart';
import '../services/firebase_service.dart';

// Main dashboard screen that displays real-time tank data and controls
class Dashboard extends StatefulWidget 
{
  const Dashboard({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseService _firebaseService = FirebaseService();

  TankModel _tank = const TankModel(
    level: 0,
    pump: false,
    flow: 0,
    dailyUsage: 0,
    monthlyUsage: 0,
    overflowAlert: false,
    lowLevelAlert: false,
  );

  StreamSubscription<TankModel>? _subscription;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isTogglingPump = false;
  String? _error;
  DateTime? _lastUpdatedAt;

  @override
  void initState() {
    super.initState();
    _subscription = _firebaseService.getTankData().listen(
      (tank) {
        if (!mounted) return;
        setState(() {
          _tank = tank;
          _isLoading = false;
          _error = null;
          _lastUpdatedAt = DateTime.now();
        });
      },
      onError: (Object err) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = 'Unable to read tank data';
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _togglePump() async {
    if (!widget.firebaseReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase is not configured. Pump control is disabled.')),
      );
      return;
    }

    if (_isTogglingPump) {
      return;
    }

    final nextState = !_tank.pump;

    setState(() {
      _isTogglingPump = true;
    });

    try {
      await _firebaseService.updatePump(nextState);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update pump status. Please try again.')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isTogglingPump = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    if (_isRefreshing) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      final latestTank = await _firebaseService.getTankData().first.timeout(const Duration(seconds: 5));

      if (!mounted) return;

      setState(() {
        _tank = latestTank;
        _error = null;
        _lastUpdatedAt = DateTime.now();
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _error = 'Refresh timed out. Please pull to refresh again.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not refresh tank data.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Color _levelColor(double level) {
    if (level >= 80) {
      return Colors.blue;
    }
    if (level <= 30) {
      return Colors.orange;
    }
    return Colors.green;
  }

  String _lastUpdatedLabel() {
    if (_lastUpdatedAt == null) {
      return 'Waiting for live data...';
    }

    final time = TimeOfDay.fromDateTime(_lastUpdatedAt!);
    return 'Last updated ${time.format(context)}';
  }

  String _dataFreshnessLabel() {
    if (_lastUpdatedAt == null) {
      return 'Awaiting data';
    }

    final seconds = DateTime.now().difference(_lastUpdatedAt!).inSeconds;

    if (seconds < 30) {
      return 'Live';
    }
    if (seconds < 120) {
      return 'Recent';
    }
    return 'Stale';
  }

  Color _dataFreshnessColor() {
    final freshness = _dataFreshnessLabel();

    if (freshness == 'Live') {
      return Colors.green;
    }
    if (freshness == 'Recent') {
      return Colors.orange;
    }
    return Colors.red;
  }

  String _usageTrendLabel() {
    if (_tank.dailyUsage <= 0 && _tank.monthlyUsage <= 0) {
      return 'No usage detected';
    }

    final avgDaily = _tank.monthlyUsage / 30;

    if (_tank.dailyUsage > avgDaily * 1.2) {
      return 'Above monthly trend';
    }
    if (_tank.dailyUsage < avgDaily * 0.8) {
      return 'Below monthly trend';
    }
    return 'On monthly trend';
  }

  String _levelHint() {
    if (_tank.level >= 95) {
      return 'Near full capacity';
    }
    if (_tank.level <= 15) {
      return 'Refill recommended';
    }
    return 'Level is in a safe range';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Tank Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isRefreshing ? null : _refreshDashboard,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh now',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _refreshDashboard,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshDashboard,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (!widget.firebaseReady) ...[
                        const _AlertTile(
                          title: 'Firebase Not Configured',
                          subtitle: 'Running in local preview mode. Data writes and live sync are disabled.',
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        _lastUpdatedLabel(),
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusChip(
                            icon: Icons.sync,
                            text: _dataFreshnessLabel(),
                            color: _dataFreshnessColor(),
                          ),
                          _StatusChip(
                            icon: Icons.water_drop,
                            text: _tank.status,
                            color: _levelColor(_tank.level),
                          ),
                          _StatusChip(
                            icon: _tank.pump ? Icons.power : Icons.power_off,
                            text: _tank.pump ? 'Pump ON' : 'Pump OFF',
                            color: _tank.pump ? Colors.green : Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _OverviewCard(
                              icon: Icons.speed,
                              title: 'Flow Rate',
                              value: '${_tank.flow.toStringAsFixed(1)} L/min',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _OverviewCard(
                              icon: _tank.pump ? Icons.power : Icons.power_off,
                              title: 'Pump',
                              value: _tank.pump ? 'Running' : 'Stopped',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Water Level', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: (_tank.level.clamp(0, 100)) / 100),
                        duration: const Duration(milliseconds: 700),
                        builder: (context, animatedLevel, _) {
                          return LinearProgressIndicator(
                            value: animatedLevel,
                            color: _levelColor(_tank.level),
                            minHeight: 18,
                            borderRadius: BorderRadius.circular(12),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Text('${_tank.level.toStringAsFixed(1)} %', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(_levelHint(), style: const TextStyle(fontSize: 13, color: Colors.black54)),
                      const SizedBox(height: 16),
                      Text('Status: ${_tank.status}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: _UsageCard(title: 'Daily Usage', value: '${_tank.dailyUsage.toStringAsFixed(1)} L')),
                          const SizedBox(width: 12),
                          Expanded(child: _UsageCard(title: 'Monthly Usage', value: '${_tank.monthlyUsage.toStringAsFixed(1)} L')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _OverviewCard(
                        icon: Icons.insights,
                        title: 'Usage Insight',
                        value: _usageTrendLabel(),
                      ),
                      const SizedBox(height: 24),
                      if (_tank.overflowAlert || _tank.lowLevelAlert) ...[
                        const Text('Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        if (_tank.overflowAlert)
                          const _AlertTile(
                            title: 'Overflow Alert',
                            subtitle: 'Water level is very high. Check inlet valve and pump.',
                            color: Colors.red,
                          ),
                        if (_tank.lowLevelAlert)
                          const _AlertTile(
                            title: 'Low Level Alert',
                            subtitle: 'Tank is low. Consider turning on pump.',
                            color: Colors.orange,
                          ),
                        const SizedBox(height: 16),
                      ],
                      ElevatedButton(
                        onPressed: _isTogglingPump ? null : _togglePump,
                        child: _isTogglingPump
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_tank.pump ? 'Turn OFF Pump' : 'Turn ON Pump'),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.title, required this.subtitle, required this.color});

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

