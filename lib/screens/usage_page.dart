import 'package:flutter/material.dart';

class UsagePage extends StatelessWidget {
  const UsagePage({super.key});

  @override
  Widget build(BuildContext context) {
    const monthlyData = <Map<String, Object>>[
      {'label': 'Week 1', 'value': 120.0},
      {'label': 'Week 2', 'value': 96.0},
      {'label': 'Week 3', 'value': 140.0},
      {'label': 'Week 4', 'value': 110.0},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Usage Summary', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Average Daily Usage', style: TextStyle(fontSize: 14, color: Colors.black54)),
                SizedBox(height: 6),
                Text('3.8 L', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...monthlyData.map((item) {
          final label = item['label']! as String;
          final value = item['value']! as double;
          return Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart),
              title: Text(label),
              trailing: Text('${value.toStringAsFixed(1)} L'),
            ),
          );
        }),
      ],
    );
  }
}
