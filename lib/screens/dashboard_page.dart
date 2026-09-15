import 'dart:async';
import '../widgets/water_gauge.dart';
import '../widgets/mobile_ui.dart';

import 'package:flutter/material.dart';

import '../models/tank_model.dart';
import '../services/firebase_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
    if (!widget.firebaseReady && !FirebaseService.demoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Firebase is not configured. Pump control is disabled.')),
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
        const SnackBar(
            content: Text('Failed to update pump status. Please try again.')),
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
      final latestTank = await _firebaseService
          .getTankData()
          .first
          .timeout(const Duration(seconds: 5));

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
    if (FirebaseService.demoMode) return 'Sample readings • Main rooftop tank';
    if (_lastUpdatedAt == null) {
      return 'Waiting for live data...';
    }

    final time = TimeOfDay.fromDateTime(_lastUpdatedAt!);
    return 'Last updated ${time.format(context)}';
  }

  String _dataFreshnessLabel() {
    if (FirebaseService.demoMode) return 'Demo';
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1565C0)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
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
      color: const Color(0xFF1565C0),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Your water, in balance.',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.6)),
          const SizedBox(height: 6),
          Text(
              FirebaseService.demoMode
                  ? 'A little care. Every drop counts. / Demo'
                  : 'A little care. Every drop counts.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6D8190))),
          const SizedBox(height: 20),
          // Animated Tank Visualization
          _AnimatedTankCard(
            level: _tank.level,
            pump: _tank.pump,
          ),
          const SizedBox(height: 12),
          if (FirebaseService.demoMode) ...[
            const SizedBox(height: 16),
            const Text('DEMO SCENARIOS',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: Color(0xFF547084))),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final scenario
                  in const {'Low': 18.0, 'Normal': 72.0, 'Full': 98.0}.entries)
                ChoiceChip(
                  label: Text('${scenario.key} ${scenario.value.toInt()}%'),
                  selected: _tank.level == scenario.value,
                  onSelected: (_) =>
                      FirebaseService.previewLevel(scenario.value),
                ),
            ]),
          ],
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
                color: _tank.pump
                    ? const Color(0xFF1565C0)
                    : const Color(0xFF607D8B),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tank Level Progress
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                          child: Text(
                        'Tank Level',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                      const SizedBox(width: 12),
                      Text(
                        '${_tank.level.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _levelColor(_tank.level),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                        begin: 0, end: (_tank.level.clamp(0, 100)) / 100),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedLevel, _) {
                      return LinearProgressIndicator(
                        value: animatedLevel,
                        minHeight: 16,
                        borderRadius: BorderRadius.circular(12),
                        color: _levelColor(_tank.level),
                        backgroundColor: const Color(0xFFE3F2FD),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_tank.status}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _levelColor(_tank.level),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Flow Rate',
                  value: '${_tank.flow.toStringAsFixed(1)} L/min',
                  icon: Icons.water_drop,
                  color: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Pump Status',
                  value: _tank.pump ? 'ON' : 'OFF',
                  icon: _tank.pump ? Icons.power : Icons.power_off,
                  color: _tank.pump
                      ? const Color(0xFF1976D2)
                      : const Color(0xFF607D8B),
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
                  color: AppColors.violet,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Monthly Usage',
                  value: '${_tank.monthlyUsage.toStringAsFixed(1)} L',
                  icon: Icons.calendar_month,
                  color: AppColors.mint,
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
                subtitle:
                    'Water level is very high. Check inlet valve and pump.',
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
          // Animated Pump Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (_tank.pump
                          ? const Color(0xFF1565C0)
                          : const Color(0xFF607D8B))
                      .withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: _isTogglingPump ? null : _togglePump,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: _tank.pump
                    ? const Color(0xFFE53935)
                    : const Color(0xFF1565C0),
              ),
              icon: _isTogglingPump
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _tank.pump
                            ? Icons.power_settings_new
                            : Icons.play_arrow,
                        key: ValueKey(_tank.pump),
                        color: Colors.white,
                      ),
                    ),
              label: Text(
                _isTogglingPump
                    ? 'Updating Pump...'
                    : (_tank.pump ? 'Turn Off Pump' : 'Turn On Pump'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
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
                    text: _tank.level <= 25
                        ? 'Fill the tank soon to avoid low-level alerts.'
                        : 'Water level is healthy.',
                  ),
                  const SizedBox(height: 4),
                  _RecommendationRow(
                    icon: Icons.timeline,
                    text: _tank.flow <= 0
                        ? 'No active flow detected right now.'
                        : 'Flow is active and stable.',
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

/// A spacious water gauge with an accessible numeric reading.
class _AnimatedTankCard extends StatelessWidget {
  const _AnimatedTankCard({required this.level, required this.pump});
  final double level;
  final bool pump;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFFE5F5F4),
                    borderRadius: BorderRadius.circular(14)),
                child:
                    const Icon(Icons.water_outlined, color: Color(0xFF078B94))),
            const SizedBox(width: 12),
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Main rooftop tank',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('Block A / 1,000 L capacity',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6D8190))),
                ])),
          ]),
          const SizedBox(height: 24),
          WaterGauge(level: level),
          const SizedBox(height: 24),
          Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 12,
              children: [
                _GaugeStat(
                    label: 'Available water',
                    value: '${(level * 10).toStringAsFixed(0)} L'),
                _GaugeStat(
                    label: 'Tank status',
                    value: level <= 30
                        ? 'Low level'
                        : level >= 80
                            ? 'Full'
                            : pump
                                ? 'Filling'
                                : 'Normal'),
                _GaugeStat(label: 'Pump', value: pump ? 'Running' : 'Standby'),
              ]),
        ]),
      ),
    );
  }
}

class _GaugeStat extends StatelessWidget {
  const _GaugeStat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF102D50))),
        const SizedBox(height: 5),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6D8190))),
      ]);
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

  @override
  Widget build(BuildContext context) {
    return ColorStat(label: title, value: value, icon: icon, color: color);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(
      {required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile(
      {required this.title, required this.subtitle, required this.color});

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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

/// Manual tank level simulator - allows changing tank level without a physical device
class _SimulatorCard extends StatefulWidget {
  const _SimulatorCard({
    required this.tank,
    required this.onLevelChanged,
    required this.onFlowChanged,
  });

  final TankModel tank;
  final Future<void> Function(double level) onLevelChanged;
  final Future<void> Function(double flow) onFlowChanged;

  @override
  State<_SimulatorCard> createState() => _SimulatorCardState();
}

class _SimulatorCardState extends State<_SimulatorCard> {
  late double _level;
  late double _flow;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _level = widget.tank.level;
    _flow = widget.tank.flow;
  }

  @override
  void didUpdateWidget(covariant _SimulatorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tank.level != widget.tank.level) {
      _level = widget.tank.level;
    }
    if (oldWidget.tank.flow != widget.tank.flow) {
      _flow = widget.tank.flow;
    }
  }

  Future<void> _saveLevel() async {
    setState(() => _isSaving = true);
    await widget.onLevelChanged(_level);
    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _saveFlow() async {
    setState(() => _isSaving = true);
    await widget.onFlowChanged(_flow);
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final color = _level >= 80
        ? const Color(0xFF0D47A1)
        : _level <= 30
            ? const Color(0xFF1E88E5)
            : const Color(0xFF42A5F5);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune,
                      color: Color(0xFF1565C0), size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Simulator (No Device)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'TEST MODE',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Manually set tank level and flow rate to simulate sensor data',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            // Level slider
            Row(
              children: [
                const Icon(Icons.water_drop,
                    size: 18, color: Color(0xFF1565C0)),
                const SizedBox(width: 8),
                const Text('Tank Level',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  '${_level.toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: color),
                ),
              ],
            ),
            Slider(
              value: _level,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: color,
              label: '${_level.toStringAsFixed(0)}%',
              onChanged: (value) => setState(() => _level = value),
            ),
            // Flow slider
            Row(
              children: [
                const Icon(Icons.speed, size: 18, color: Color(0xFF1565C0)),
                const SizedBox(width: 8),
                const Text('Flow Rate',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  '${_flow.toStringAsFixed(1)} L/min',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1565C0)),
                ),
              ],
            ),
            Slider(
              value: _flow,
              min: 0,
              max: 50,
              divisions: 100,
              activeColor: const Color(0xFF1565C0),
              label: '${_flow.toStringAsFixed(1)} L/min',
              onChanged: (value) => setState(() => _flow = value),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _saveFlow,
                    icon: const Icon(Icons.speed, size: 18),
                    label: const Text('Set Flow'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _saveLevel,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save, size: 18),
                    label: const Text('Set Level'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
