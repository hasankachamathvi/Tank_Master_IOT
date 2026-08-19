import 'dart:async';

import 'package:flutter/material.dart';

import '../models/tank_model.dart';
import '../services/firebase_service.dart';

class TanksPage extends StatefulWidget {
  const TanksPage({super.key});

  @override
  State<TanksPage> createState() => _TanksPageState();
}

class _TanksPageState extends State<TanksPage> {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<TankModel>? _subscription;
  TankModel _tank = const TankModel(
    level: 0,
    pump: false,
    flow: 0,
    dailyUsage: 0,
    monthlyUsage: 0,
    overflowAlert: false,
    lowLevelAlert: false,
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _subscription = _firebaseService.getTankData().listen((tank) {
      if (!mounted) return;
      setState(() {
        _tank = tank;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)));
    }

    final mainTank = _tank;
    final backupLevel = (_tank.level * 0.5).clamp(0, 100).toDouble();
    final gardenLevel = (_tank.level * 1.1).clamp(0, 100).toDouble();

    final tanks = <Map<String, Object>>[
      {
        'name': 'Main Tank',
        'location': 'Rooftop Block A',
        'level': mainTank.level,
        'capacity': 1000,
        'status': mainTank.status,
        'pump': mainTank.pump,
      },
      {
        'name': 'Backup Tank',
        'location': 'Ground Floor',
        'level': backupLevel,
        'capacity': 600,
        'status': backupLevel >= 40 ? 'Healthy' : 'Needs Refill Soon',
        'pump': false,
      },
      {
        'name': 'Garden Tank',
        'location': 'Outdoor Utility',
        'level': gardenLevel,
        'capacity': 450,
        'status': gardenLevel >= 80 ? 'High Level' : 'Normal',
        'pump': false,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Tanks', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          'Real-time tank monitoring',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        ...tanks.map((tank) {
          final level = tank['level']! as double;
          final color = level >= 80
              ? const Color(0xFF1565C0)
              : level >= 40
                  ? const Color(0xFF1E88E5)
                  : const Color(0xFFFB8C00);
          final pump = tank['pump']! as bool;

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.water, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tank['name']! as String,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '${level.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        tank['location']! as String,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.water_drop_outlined, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${tank['capacity']! as int} L',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: (level / 100).clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedLevel, _) {
                      return LinearProgressIndicator(
                        value: animatedLevel,
                        color: color,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(10),
                        backgroundColor: const Color(0xFFE3F2FD),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (pump)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.power, size: 12, color: Color(0xFF1565C0)),
                              SizedBox(width: 4),
                              Text('Pump ON', style: TextStyle(fontSize: 11, color: Color(0xFF1565C0))),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tank['status']! as String,
                          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TankDetailsPage(
                                name: tank['name']! as String,
                                location: tank['location']! as String,
                                level: level,
                                capacity: tank['capacity']! as int,
                                status: tank['status']! as String,
                                pump: pump,
                              ),
                            ),
                          );
                        },
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class TankDetailsPage extends StatelessWidget {
  const TankDetailsPage({
    super.key,
    required this.name,
    required this.location,
    required this.level,
    required this.capacity,
    required this.status,
    required this.pump,
  });

  final String name;
  final String location;
  final double level;
  final int capacity;
  final String status;
  final bool pump;

  @override
  Widget build(BuildContext context) {
    final availableWater = (capacity * (level / 100)).round();
    final color = level >= 80
        ? const Color(0xFF1565C0)
        : level >= 40
            ? const Color(0xFF1E88E5)
            : const Color(0xFFFB8C00);

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFF1565C0)),
                      const SizedBox(width: 4),
                      Text('Location: $location'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.speed, size: 16, color: color),
                      const SizedBox(width: 4),
                      Text('Status: $status'),
                    ],
                  ),
                  if (pump) ...[
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.power, size: 16, color: Color(0xFF1565C0)),
                        SizedBox(width: 4),
                        Text('Pump: Running'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Water Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  _DetailRow(label: 'Level', value: '${level.toStringAsFixed(1)}%', color: color),
                  const SizedBox(height: 6),
                  _DetailRow(label: 'Capacity', value: '$capacity L', color: const Color(0xFF1565C0)),
                  const SizedBox(height: 6),
                  _DetailRow(label: 'Available Water', value: '$availableWater L', color: const Color(0xFF42A5F5)),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: (level / 100).clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedLevel, _) {
                      return LinearProgressIndicator(
                        value: animatedLevel,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(10),
                        color: color,
                        backgroundColor: const Color(0xFFE3F2FD),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.build_circle, color: Color(0xFF1565C0)),
              ),
              title: const Text('Maintenance'),
              subtitle: const Text('Last checked 6 days ago. Next service due in 24 days.'),
              trailing: TextButton(onPressed: () {}, child: const Text('Schedule')),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}