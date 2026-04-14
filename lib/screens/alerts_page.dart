import 'package:flutter/material.dart';

// AlertsPage displays a list of alerts and notifications related to the tank's status, including critical issues, warnings, and resolved alerts. It also provides a summary of alert counts and allows users to view details or manage notification rules.
class AlertsPage extends StatelessWidget 
{
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) 
  {
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
        Row(
          children: const [
            Expanded(
              child: _AlertSummaryCard(
                label: 'Critical',
                count: '1',
                color: Color(0xFFE53935),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _AlertSummaryCard(
                label: 'Warnings',
                count: '2',
                color: Color(0xFFFB8C00),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _AlertSummaryCard(
                label: 'Resolved',
                count: '6',
                color: Color(0xFF43A047),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...alerts.map((item) {
          final color = item['color']! as Color;
          return Card(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: color, width: 5)),
              ),
              child: ListTile(
                leading: Icon(Icons.notifications_active, color: color),
                title: Text(item['title']! as String),
                subtitle: Text(item['message']! as String),
                trailing: TextButton(onPressed: () {}, child: const Text('View')),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.settings_input_component, color: Color(0xFF1565C0)),
            title: Text('Notification Rule'),
            subtitle: Text('Send push notification when level is below 20% for 5 minutes.'),
          ),
        ),
      ],
    );
  }
}

class _AlertSummaryCard extends StatelessWidget {
  const _AlertSummaryCard({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final String count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
