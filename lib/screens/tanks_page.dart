import 'package:flutter/material.dart';

class TanksPage extends StatelessWidget 
{
  const TanksPage({super.key});

  @override
  Widget build(BuildContext context) 
  {
    const tanks = <Map<String, Object>>[
      {
        'name': 'Main Tank',
        'location': 'Rooftop Block A',
        'level': 74.0,
        'capacity': 1000,
        'status': 'Healthy',
      },
      {
        'name': 'Backup Tank',
        'location': 'Ground Floor',
        'level': 38.0,
        'capacity': 600,
        'status': 'Needs Refill Soon',
      },
      {
        'name': 'Garden Tank',
        'location': 'Outdoor Utility',
        'level': 86.0,
        'capacity': 450,
        'status': 'High Level',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Tanks', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...tanks.map((tank) {
          final level = tank['level']! as double;
          final color = level >= 80
              ? const Color(0xFF1565C0)
              : level >= 40
                  ? const Color(0xFF1E88E5)
                  : const Color(0xFFFB8C00);

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.water, color: Color(0xFF1565C0)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tank['name']! as String,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text('${level.toStringAsFixed(0)}%'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Location: ${tank['location']! as String}'),
                  const SizedBox(height: 2),
                  Text('Capacity: ${tank['capacity']! as int} L'),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (level / 100).clamp(0.0, 1.0),
                    color: color,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tank['status']! as String,
                          style: TextStyle(color: color, fontWeight: FontWeight.w600),
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
  });

  final String name;
  final String location;
  final double level;
  final int capacity;
  final String status;

  @override
  Widget build(BuildContext context) {
    final availableWater = (capacity * (level / 100)).round();

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Location: $location'),
                  const SizedBox(height: 4),
                  Text('Current Status: $status'),
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
                  const Text('Water Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text('Level: ${level.toStringAsFixed(1)}%'),
                  const SizedBox(height: 6),
                  Text('Capacity: $capacity L'),
                  const SizedBox(height: 6),
                  Text('Available Water: $availableWater L'),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (level / 100).clamp(0.0, 1.0),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF1565C0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.build_circle, color: Color(0xFF1565C0)),
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
