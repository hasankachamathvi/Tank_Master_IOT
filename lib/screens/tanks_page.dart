import 'package:flutter/material.dart';
import '../models/tank_model.dart';
import '../services/firebase_service.dart';
import '../widgets/mobile_ui.dart';
import '../widgets/water_gauge.dart';

class TanksPage extends StatefulWidget {
  const TanksPage({super.key});
  @override
  State<TanksPage> createState() => _TanksPageState();
}

class _TanksPageState extends State<TanksPage> {
  late final _stream = FirebaseService().getTankData();
  @override
  Widget build(BuildContext context) => StreamBuilder<TankModel>(
      stream: _stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final main = snapshot.data!;
        final levels = [
          main.level,
          main.level * 0.5,
          (main.level * 1.1).clamp(0, 100).toDouble()
        ];
        const names = ['Main rooftop tank', 'Backup tank', 'Garden tank'];
        const locations = ['Block A', 'Ground floor', 'Outdoor utility'];
        const capacities = [1000, 600, 450];
        const colors = [AppColors.aqua, AppColors.coral, AppColors.mint];
        return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              PageIntro(
                  title: 'Every tank.\nOne happy home.',
                  subtitle: FirebaseService.demoMode
                      ? '3 sample tanks / Your water at a glance'
                      : 'Main tank connected / 2 illustrative tanks',
                  icon: Icons.water_rounded,
                  eyebrow: 'MY TANKS'),
              const SizedBox(height: 22),
              const Text('Your water storage',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              for (var i = 0; i < names.length; i++)
                Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Card(
                        child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                    builder: (_) => TankDetailsPage(
                                        name: names[i],
                                        location: locations[i],
                                        level: levels[i],
                                        capacity: capacities[i],
                                        status: levels[i] <= 30
                                            ? 'Needs refill'
                                            : 'Healthy',
                                        pump: i == 0 && main.pump))),
                            child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: colors[i]
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(14)),
                                            child: Icon(Icons.water,
                                                color: colors[i])),
                                        const SizedBox(width: 12),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              Text(names[i],
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800)),
                                              const SizedBox(height: 4),
                                              Text(locations[i],
                                                  style: const TextStyle(
                                                      color: Color(0xFF6D8190),
                                                      fontSize: 12)),
                                            ])),
                                        const Icon(Icons.arrow_forward_rounded,
                                            size: 20, color: Color(0xFF6D8190)),
                                      ]),
                                      const SizedBox(height: 18),
                                      Row(children: [
                                        WaterGauge(level: levels[i], size: 112),
                                        const SizedBox(width: 14),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              Text(
                                                  '${(levels[i] * capacities[i] / 100).round()} L',
                                                  style: const TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: AppColors.ink)),
                                              Text(
                                                  'of ${capacities[i]} L capacity',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Color(0xFF6D8190))),
                                              const SizedBox(height: 10),
                                              Text(
                                                  levels[i] <= 30
                                                      ? 'Needs a refill'
                                                      : i == 0 && main.pump
                                                          ? 'Filling now'
                                                          : 'Water ready',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: colors[i],
                                                      fontWeight:
                                                          FontWeight.w700)),
                                            ])),
                                      ]),
                                    ]))))),
            ]);
      });
}

class TankDetailsPage extends StatelessWidget {
  const TankDetailsPage(
      {super.key,
      required this.name,
      required this.location,
      required this.level,
      required this.capacity,
      required this.status,
      required this.pump});
  final String name, location, status;
  final double level;
  final int capacity;
  final bool pump;
  @override
  Widget build(BuildContext context) => MobileBackground(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              scrolledUnderElevation: 0,
              title: const Text('Tank details')),
          body: SafeArea(
              child: ListView(padding: const EdgeInsets.all(16), children: [
            PageIntro(
                title: name,
                subtitle: '$location / $capacity L capacity',
                icon: Icons.water),
            const SizedBox(height: 20),
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(children: [
                      WaterGauge(level: level),
                      const SizedBox(height: 16),
                      Text(status,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.aqua)),
                      const SizedBox(height: 8),
                      const Text('Water level at the time you opened this tank',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF6D8190))),
                    ]))),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: ColorStat(
                      label: 'Available water',
                      value: '${(capacity * level / 100).round()} L',
                      icon: Icons.water_drop_outlined,
                      color: AppColors.aqua)),
              const SizedBox(width: 12),
              Expanded(
                  child: ColorStat(
                      label: 'Pump status',
                      value: pump ? 'Running' : 'Standby',
                      icon: Icons.power_settings_new,
                      color: AppColors.violet)),
            ]),
            const SizedBox(height: 20),
            const Card(
                child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                        'Keep your tank covered and check its inlet regularly to help keep your water supply clean.',
                        style: TextStyle(height: 1.5)))),
          ]))));
}
