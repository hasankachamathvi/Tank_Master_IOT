import 'dart:async';

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
  String? _error;

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
    await _firebaseService.updatePump(!_tank.pump);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return ListView(
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
                      Text('Current Status: ${_tank.status}'),
                      const SizedBox(height: 4),
                      Text('Water Level: ${_tank.level.toStringAsFixed(1)}%'),
                      const SizedBox(height: 4),
                      Text('Pump: ${_tank.pump ? 'Running' : 'Stopped'}'),
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
                LinearProgressIndicator(
                  value: (_tank.level.clamp(0, 100)) / 100,
                  minHeight: 16,
                  borderRadius: BorderRadius.circular(12),
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
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Pump',
                value: _tank.pump ? 'ON' : 'OFF',
                icon: _tank.pump ? Icons.power : Icons.power_off,
                color: _tank.pump ? Colors.green : Colors.grey,
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
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Monthly Usage',
                value: '${_tank.monthlyUsage.toStringAsFixed(1)} L',
                icon: Icons.calendar_month,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _togglePump,
          icon: Icon(_tank.pump ? Icons.toggle_off : Icons.toggle_on),
          label: Text(_tank.pump ? 'Turn Off Pump' : 'Turn On Pump'),
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
                Text(_tank.level <= 25 ? 'Fill the tank soon to avoid low-level alerts.' : 'Water level is healthy.'),
                const SizedBox(height: 4),
                Text(_tank.flow <= 0 ? 'No active flow detected right now.' : 'Flow is active and stable.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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
