import 'package:flutter/material.dart';
import '../widgets/mobile_ui.dart';

class UsagePage extends StatefulWidget {
  const UsagePage({super.key});
  @override
  State<UsagePage> createState() => _UsagePageState();
}

class _UsagePageState extends State<UsagePage> {
  bool _monthly = false;
  @override
  Widget build(BuildContext context) {
    final values = _monthly
        ? [1400, 1200, 1500, 1300]
        : [160, 190, 145, 210, 175, 200, 180];
    final labels = _monthly
        ? ['W1', 'W2', 'W3', 'W4']
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final max = _monthly ? 1600 : 240;
    return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const PageIntro(
              title: 'Small changes.\nMore water saved.',
              subtitle: 'Discover your daily habits with sample usage data.',
              icon: Icons.insights_rounded,
              color: AppColors.indigo,
              eyebrow: 'WATER INSIGHTS'),
          const SizedBox(height: 20),
          const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: ColorStat(
                    label: 'Used today',
                    value: '180 L',
                    icon: Icons.wb_sunny_outlined,
                    color: AppColors.sky)),
            SizedBox(width: 12),
            Expanded(
                child: ColorStat(
                    label: 'This month',
                    value: '5,400 L',
                    icon: Icons.calendar_month_outlined,
                    color: AppColors.indigo)),
          ]),
          const SizedBox(height: 20),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your consumption',
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),
                        SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(value: false, label: Text('Week')),
                              ButtonSegment(value: true, label: Text('Month'))
                            ],
                            selected: {
                              _monthly
                            },
                            onSelectionChanged: (value) =>
                                setState(() => _monthly = value.first)),
                        const SizedBox(height: 22),
                        AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(_monthly ? '5,400 L' : '1,260 L',
                                key: ValueKey(_monthly),
                                style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.indigo))),
                        Text(
                            _monthly
                                ? 'Sample month / litres per week'
                                : 'Sample week / litres per day',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6D8190))),
                        const SizedBox(height: 20),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (var i = 0; i < values.length; i++)
                                Expanded(
                                    child: Semantics(
                                        label:
                                            '${_monthly ? 'Week' : 'Day'} ${i + 1}: ${values[i]} litres',
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 3),
                                            child: Column(children: [
                                              FittedBox(
                                                  child: Text('${values[i]}',
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Color(
                                                              0xFF6D8190)))),
                                              const SizedBox(height: 8),
                                              TweenAnimationBuilder<double>(
                                                  tween: Tween(
                                                      begin: 0,
                                                      end: values[i] / max),
                                                  duration: const Duration(
                                                      milliseconds: 650),
                                                  curve: Curves.easeOutCubic,
                                                  builder: (context, value, _) => Container(
                                                      height: 140 * value + 4,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(9),
                                                          gradient:
                                                              LinearGradient(
                                                                  begin:
                                                                      Alignment
                                                                          .topCenter,
                                                                  end: Alignment
                                                                      .bottomCenter,
                                                                  colors:
                                                                      i == values.length - 1
                                                                          ? const [
                                                                              AppColors.indigo,
                                                                              Color(0xFF8DB9F3)
                                                                            ]
                                                                          : const [
                                                                              Color(0xFFA9C9F5),
                                                                              Color(0xFFDDEBFF)
                                                                            ])))),
                                              const SizedBox(height: 10),
                                              Text(labels[i],
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          Color(0xFF6D8190))),
                                            ])))),
                            ]),
                      ]))),
          const SizedBox(height: 18),
          const ColorStat(
              label: 'Average daily use / sample week',
              value: '180 L',
              icon: Icons.show_chart,
              color: AppColors.ocean),
          const SizedBox(height: 18),
          const Card(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded,
                            color: AppColors.sky),
                        SizedBox(height: 10),
                        Text('Make every drop count',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w800)),
                        SizedBox(height: 6),
                        Text(
                            'Check dripping taps and use collected rainwater for your garden. Little habits add up.',
                            style: TextStyle(
                                height: 1.5, color: Color(0xFF6D8190))),
                      ]))),
        ]);
  }
}
