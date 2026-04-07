import 'dart:async';

import 'package:flutter/material.dart';

import '../models/tank_model.dart';
import '../services/firebase_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

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
  String? _error;

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
    final nextState = !_tank.pump;
    await _firebaseService.updatePump(nextState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Tank Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: () async {},
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text('Water Level', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: (_tank.level.clamp(0, 100)) / 100,
                        minHeight: 18,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 10),
                      Text('${_tank.level.toStringAsFixed(1)} %', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      Text('Status: ${_tank.status}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Flow: ${_tank.flow.toStringAsFixed(1)} L/min', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: _UsageCard(title: 'Daily Usage', value: '${_tank.dailyUsage.toStringAsFixed(1)} L')),
                          const SizedBox(width: 12),
                          Expanded(child: _UsageCard(title: 'Monthly Usage', value: '${_tank.monthlyUsage.toStringAsFixed(1)} L')),
                        ],
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
                        onPressed: _togglePump,
                        child: Text(_tank.pump ? 'Turn OFF Pump' : 'Turn ON Pump'),
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

