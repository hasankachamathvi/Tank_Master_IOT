import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/tank_model.dart';
import '../services/firebase_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
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

  late final AnimationController _waveController;
  late final AnimationController _pumpController;
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

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

        if (tank.pump) {
          _pumpController.repeat(reverse: true);
        } else {
          _pumpController.stop();
          _pumpController.value = 0;
        }
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
    _waveController.dispose();
    _pumpController.dispose();
    _fadeController.dispose();
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
          const SizedBox(height: 16),
          // Animated Tank Visualization
          _AnimatedTankCard(
            level: _tank.level,
            pump: _tank.pump,
            waveController: _waveController,
            pumpController: _pumpController,
            fadeController: _fadeController,
          ),
          const SizedBox(height: 12),
          // Tank Level Progress
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Tank Level',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
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
                    tween: Tween<double>(begin: 0, end: (_tank.level.clamp(0, 100)) / 100),
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
          // Animated Pump Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (_tank.pump ? const Color(0xFF1565C0) : const Color(0xFF607D8B))
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
                backgroundColor: _tank.pump ? const Color(0xFFE53935) : const Color(0xFF1565C0),
              ),
              icon: _isTogglingPump
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _tank.pump ? Icons.power_settings_new : Icons.play_arrow,
                        key: ValueKey(_tank.pump),
                        color: Colors.white,
                      ),
                    ),
              label: Text(
                _isTogglingPump
                    ? 'Updating Pump...'
                    : (_tank.pump ? 'Turn Off Pump' : 'Turn On Pump'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Manual Tank Level Simulator
          _SimulatorCard(
            tank: _tank,
            onLevelChanged: (level) async {
              if (!widget.firebaseReady) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Firebase is not configured. Cannot update level.')),
                );
                return;
              }
              try {
                await _firebaseService.updateTankLevel(level);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tank level updated to ${level.toStringAsFixed(0)}%'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update tank level.')),
                );
              }
            },
            onFlowChanged: (flow) async {
              if (!widget.firebaseReady) return;
              try {
                await _firebaseService.writeData('tank', {
                  'level': _tank.level,
                  'pump': _tank.pump,
                  'flow': flow,
                  'dailyUsage': _tank.dailyUsage,
                  'monthlyUsage': _tank.monthlyUsage,
                  'overflowAlert': _tank.overflowAlert,
                  'lowLevelAlert': _tank.lowLevelAlert,
                });
              } catch (_) {}
            },
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

/// Animated tank visualization with water waves
class _AnimatedTankCard extends StatelessWidget {
  const _AnimatedTankCard({
    required this.level,
    required this.pump,
    required this.waveController,
    required this.pumpController,
    required this.fadeController,
  });

  final double level;
  final bool pump;
  final AnimationController waveController;
  final AnimationController pumpController;
  final AnimationController fadeController;

  @override
  Widget build(BuildContext context) {
    final normalized = (level.clamp(0, 100)) / 100;
    final fillColor = normalized >= 0.8
        ? const Color(0xFF1565C0)
        : normalized >= 0.35
            ? const Color(0xFF1E88E5)
            : const Color(0xFF64B5F6);

    return FadeTransition(
      opacity: fadeController,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Tank visualization
              SizedBox(
                width: 110,
                height: 170,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Tank body
                    Container(
                      width: 100,
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1565C0), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1565C0).withValues(alpha: 0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    // Water fill with wave animation
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(13),
                        top: Radius.circular(6),
                      ),
                      child: AnimatedBuilder(
                        animation: waveController,
                        builder: (context, child) {
                          return Container(
                            width: 100,
                            height: 160 * normalized,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  fillColor.withValues(alpha: 0.8),
                                  fillColor,
                                ],
                              ),
                            ),
                            child: CustomPaint(
                              painter: _WavePainter(
                                color: Colors.white.withValues(alpha: 0.3),
                                waveOffset: waveController.value * 2 * math.pi,
                                amplitude: pump ? 4.0 : 2.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Level text
                    Positioned(
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${level.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      ),
                    ),
                    // Pump indicator
                    if (pump)
                      Positioned(
                        bottom: 8,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                            CurvedAnimation(
                              parent: pumpController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.power,
                              size: 16,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Tank info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Main Tank',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rooftop • Block A',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.water_drop,
                      label: 'Water Level',
                      value: '${level.toStringAsFixed(1)}%',
                      color: fillColor,
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.speed,
                      label: 'Status',
                      value: level >= 80
                          ? 'Full'
                          : level <= 30
                              ? 'Low'
                              : 'Normal',
                      color: fillColor,
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.power_settings_new,
                      label: 'Pump',
                      value: pump ? 'Running' : 'Stopped',
                      color: pump ? const Color(0xFF1565C0) : const Color(0xFF607D8B),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.color,
    required this.waveOffset,
    required this.amplitude,
  });

  final Color color;
  final double waveOffset;
  final double amplitude;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 2) {
      final y = size.height * 0.3 + math.sin((x / size.width) * 2 * math.pi + waveOffset) * amplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.waveOffset != waveOffset ||
        oldDelegate.color != color ||
        oldDelegate.amplitude != amplitude;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    final color = _level >= 80
        ? const Color(0xFF1565C0)
        : _level >= 40
            ? const Color(0xFF1E88E5)
            : const Color(0xFFFB8C00);

    return Card(
      elevation: 2,
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
                  child: const Icon(Icons.tune, color: Color(0xFF1565C0), size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Manual Tank Simulator',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.smartphone, size: 12, color: Color(0xFF2E7D32)),
                      SizedBox(width: 4),
                      Text(
                        'No device needed',
                        style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Tank Level', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  '${_level.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: _level,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: color,
              inactiveColor: const Color(0xFFE3F2FD),
              label: '${_level.toStringAsFixed(0)}%',
              onChanged: (value) {
                setState(() {
                  _level = value;
                });
              },
              onChangeEnd: (value) {
                widget.onLevelChanged(value);
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Flow Rate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  '${_flow.toStringAsFixed(1)} L/min',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: _flow,
              min: 0,
              max: 50,
              divisions: 50,
              activeColor: const Color(0xFF42A5F5),
              inactiveColor: const Color(0xFFE3F2FD),
              label: '${_flow.toStringAsFixed(1)} L/min',
              onChanged: (value) {
                setState(() {
                  _flow = value;
                });
              },
              onChangeEnd: (value) {
                widget.onFlowChanged(value);
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Drag the sliders to simulate tank data. Changes are saved to Firebase.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
