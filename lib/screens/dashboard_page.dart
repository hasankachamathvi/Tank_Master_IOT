import 'dart:async';

import 'package:flutter/material.dart';

import '../models/tank_model.dart';
import '../services/firebase_service.dart';

/// DashboardPage displays real-time tank data and allows pump control.
class DashboardPage extends StatefulWidget 
{
  const DashboardPage({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

/// _DashboardPageState manages the state of DashboardPage, including real-time data updates and pump control.
class _DashboardPageState extends State<DashboardPage> 
{
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
        if (!mounted) {
          return;
        }

        setState(() {
          _tank = tank;
          _isLoading = false;
          _error = null;
          _lastUpdatedAt = DateTime.now();
        });
      },
      onError: (Object _) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _error = 'Unable to load tank data';
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

    setState(() {
      _isTogglingPump = true;
    });

    try {
      await _firebaseService.updatePump(!_tank.pump);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update pump status. Please try again.')),
      );
    } finally {
      if (!mounted) {
        return;
      }

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

      if (!mounted) {
        return;
      }

      setState(() {
        _tank = latestTank;
        _error = null;
        _lastUpdatedAt = DateTime.now();
      });
    } on TimeoutException {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'Refresh timed out. Please try again.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'Could not refresh tank data.';
      });
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Color _levelColor(double level) {
    if (level >= 80) {
      return const Color(0xFF0D47A1);
    }
    if (level <= 30) {
      return const Color(0xFF1E88E5);
    }
    return const Color(0xFF42A5F5);
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
      return const Color(0xFF1565C0);
    }
    if (freshness == 'Recent') {
      return const Color(0xFF1E88E5);
    }
    return const Color(0xFF90CAF9);
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

// The build method renders the UI based on the current state of the tank data, showing loading indicators, error messages, and the main dashboard when data is available.
  @override
  Widget build(BuildContext context) 
  {
    if (_isLoading) 
    {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) 
    {
      return Center(
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
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!widget.firebaseReady)
            const Card(
              color: Color(0xFFFFF3E0),
              child: ListTile(
                leading: Icon(Icons.wifi_off),
                title: Text('Firebase not configured'),
                subtitle: Text('Running in local preview mode with default values.'),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _lastUpdatedLabel(),
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
              IconButton(
                onPressed: _isRefreshing ? null : _refreshDashboard,
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Refresh now',
              ),
            ],
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
                color: _tank.pump ? const Color(0xFF1565C0) : const Color(0xFF607D8B),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _TankView(level: _tank.level),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tank Overview',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: Color(0xFF1565C0)),
                            const SizedBox(width: 6),
                            Expanded(child: Text('Current Status: ${_tank.status}')),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.opacity, size: 16, color: Color(0xFF1565C0)),
                            const SizedBox(width: 6),
                            Expanded(child: Text('Water Level: ${_tank.level.toStringAsFixed(1)}%')),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.power_settings_new, size: 16, color: Color(0xFF1565C0)),
                            const SizedBox(width: 6),
                            Expanded(child: Text('Pump: ${_tank.pump ? 'Running' : 'Stopped'}')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tank Level', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: (_tank.level.clamp(0, 100)) / 100),
                    duration: const Duration(milliseconds: 700),
                    builder: (context, animatedLevel, _) {
                      return LinearProgressIndicator(
                        value: animatedLevel,
                        minHeight: 16,
                        borderRadius: BorderRadius.circular(12),
                        color: _levelColor(_tank.level),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('${_tank.level.toStringAsFixed(1)}%  •  ${_tank.status}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Flow',
                  value: '${_tank.flow.toStringAsFixed(1)} L/min',
                  icon: Icons.water_drop,
                  color: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Pump',
                  value: _tank.pump ? 'ON' : 'OFF',
                  icon: _tank.pump ? Icons.power : Icons.power_off,
                  color: _tank.pump ? const Color(0xFF1976D2) : const Color(0xFF607D8B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Daily Usage',
                  value: '${_tank.dailyUsage.toStringAsFixed(1)} L',
                  icon: Icons.today,
                  color: const Color(0xFF42A5F5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Monthly Usage',
                  value: '${_tank.monthlyUsage.toStringAsFixed(1)} L',
                  icon: Icons.calendar_month,
                  color: const Color(0xFF0D47A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.insights, color: Color(0xFF1565C0)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _usageTrendLabel(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_tank.overflowAlert || _tank.lowLevelAlert) ...[
            const SizedBox(height: 12),
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
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isTogglingPump ? null : _togglePump,
            icon: _isTogglingPump
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_tank.pump ? Icons.toggle_off : Icons.toggle_on),
            label: Text(
              _isTogglingPump
                  ? 'Updating Pump...'
                  : (_tank.pump ? 'Turn Off Pump' : 'Turn On Pump'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Recommendations',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  _RecommendationRow(
                    icon: Icons.water,
                    text: _tank.level <= 25 ? 'Fill the tank soon to avoid low-level alerts.' : 'Water level is healthy.',
                  ),
                  const SizedBox(height: 4),
                  _RecommendationRow(
                    icon: Icons.timeline,
                    text: _tank.flow <= 0 ? 'No active flow detected right now.' : 'Flow is active and stable.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// _TankView is a custom widget that visually represents the tank's water level with a fill animation and color coding.
class _TankView extends StatelessWidget {
  const _TankView({required this.level});

  final double level;

  @override
  Widget build(BuildContext context) {
    final normalized = (level.clamp(0, 100)) / 100;
    final fillColor = normalized >= 0.8
        ? const Color(0xFF1565C0)
        : normalized >= 0.35
            ? const Color(0xFF1E88E5)
            : const Color(0xFF64B5F6);

    return SizedBox(
      width: 86,
      height: 140,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 78,
            height: 132,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1565C0), width: 2),
            ),
          ),
          Container(
            width: 78,
            height: 132 * normalized,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.vertical(
                bottom: const Radius.circular(12),
                top: Radius.circular(normalized > 0.95 ? 12 : 6),
              ),
            ),
          ),
          Positioned(
            top: 6,
            child: Text(
              '${level.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

// _MetricCard is a reusable widget that displays a metric with an icon, title, and value in a styled card format.
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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

class _RecommendationRow extends StatelessWidget {
  const _RecommendationRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1565C0)),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
