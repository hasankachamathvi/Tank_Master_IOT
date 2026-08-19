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
        'time': '2 min ago',
      },
      {
        'title': 'High Consumption Spike',
        'message': 'Usage increased by 18% compared to last week.',
        'color': Colors.red,
        'time': '1 hr ago',
      },
      {
        'title': 'Pump Health',
        'message': 'Pump runtime remains within normal range.',
        'color': Colors.green,
        'time': '3 hrs ago',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Alerts and Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          'Stay informed about your tank status',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: _AlertSummaryCard(label: 'Critical', count: '1', color: Color(0xFFE53935))),
            SizedBox(width: 12),
            Expanded(child: _AlertSummaryCard(label: 'Warnings', count: '2', color: Color(0xFFFB8C00))),
            SizedBox(width: 12),
            Expanded(child: _AlertSummaryCard(label: 'Resolved', count: '6', color: Color(0xFF43A047))),
          ],
        ),
        const SizedBox(height: 12),
        ...alerts.map((item) {
          final color = item['color']! as Color;
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border(left: BorderSide(color: color, width: 5)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.notifications_active, color: color),
                ),
                title: Text(item['title']! as String),
                subtitle: Text(item['message']! as String),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item['time']! as String,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                    TextButton(onPressed: () {}, child: const Text('View')),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings_input_component, color: Color(0xFF1565C0)),
            ),
            title: const Text('Notification Rule'),
            subtitle: const Text('Send push notification when level is below 20% for 5 minutes.'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }
}

class _AlertSummaryCard extends StatelessWidget {
  const _AlertSummaryCard({required this.label, required this.count, required this.color});

  final String label;
  final String count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}