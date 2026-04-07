import 'package:flutter/material.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const alerts = <Map<String, Object>>[
      {
        'title': 'Low Water Level',
        'message': 'Tank dropped below 20%. Consider starting the pump.',
        'color': Colors.orange,
      },
      {
        'title': 'High Consumption Spike',
        'message': 'Usage increased by 18% compared to last week.',
        'color': Colors.red,
      },
      {
        'title': 'Pump Health',
        'message': 'Pump runtime remains within normal range.',
        'color': Colors.green,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Alerts and Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...alerts.map((item) {
          final color = item['color']! as Color;
          return Card(
            child: ListTile(
              leading: Icon(Icons.notifications_active, color: color),
              title: Text(item['title']! as String),
              subtitle: Text(item['message']! as String),
            ),
          );
        }),
      ],
    );
  }
}
