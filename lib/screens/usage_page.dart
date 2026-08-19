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
        const SizedBox(height: 4),
        Text(
          'Track your water consumption',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: _HighlightCard(
                title: 'Today',
                value: '4.2 L',
                icon: Icons.today,
                color: Color(0xFF1976D2),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _HighlightCard(
                title: 'This Month',
                value: '466 L',
                icon: Icons.calendar_month,
                color: Color(0xFF1565C0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        const Text('Weekly Breakdown', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...monthlyData.map((item) {
          final label = item['label']! as String;
          final value = item['value']! as double;
          const maxValue = 160.0;
          final percent = (value / maxValue).clamp(0.0, 1.0).toDouble();

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.bar_chart, color: Color(0xFF1565C0), size: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(label)),
                      Text(
                        '${value.toStringAsFixed(1)} L',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: percent),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedPercent, _) {
                      return LinearProgressIndicator(
                        value: animatedPercent,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF1E88E5),
                        backgroundColor: const Color(0xFFE3F2FD),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Color(0xFFFB8C00), size: 20),
                    SizedBox(width: 8),
                    Text('Tip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Run the pump during low-demand hours to reduce overflow risk and energy usage.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}