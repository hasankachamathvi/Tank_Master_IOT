import 'package:flutter/material.dart';
import '../widgets/mobile_ui.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});
  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String _filter = 'All';
  final Set<int> _read = {};
  static const _titles = [
    'Low water level',
    'A busy water day',
    'Pump looking good'
  ];
  static const _messages = [
    'The sample backup tank fell below 20%. Check its supply before starting a refill.',
    'Sample consumption increased by 18% compared with the previous week.',
    'The sample pump runtime is within its normal range.'
  ];
  static const _colors = [AppColors.sky, AppColors.indigo, AppColors.ocean];
  static const _icons = [
    Icons.water_drop_outlined,
    Icons.trending_up,
    Icons.check_circle_outline
  ];
  @override
  Widget build(BuildContext context) {
    final visible = [
      for (var i = 0; i < 3; i++)
        if (_filter != 'Unread' || !_read.contains(i)) i
    ];
    return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const PageIntro(
              title: 'A heads-up.\nPeace of mind.',
              subtitle: 'Your sample notification history, in one place.',
              icon: Icons.notifications_active_outlined,
              color: AppColors.sky,
              eyebrow: 'NOTIFICATIONS'),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: Text('${3 - _read.length} unread',
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w800))),
            TextButton(
                onPressed: _read.length == 3
                    ? null
                    : () => setState(() => _read.addAll([0, 1, 2])),
                child: const Text('Mark all read')),
          ]),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFDCEBFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBAD3F5)),
            ),
            child: Row(children: [
              for (final filter in ['All', 'Unread'])
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Semantics(
                    selected: filter == _filter,
                    child: AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: filter == _filter
                            ? AppColors.blue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: filter == _filter
                            ? [
                                BoxShadow(
                                    color:
                                        AppColors.blue.withValues(alpha: 0.24),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3)),
                              ]
                            : [],
                      ),
                      child: TextButton(
                        onPressed: () => setState(() => _filter = filter),
                        style: TextButton.styleFrom(
                          foregroundColor: filter == _filter
                              ? Colors.white
                              : const Color(0xFF345783),
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                  child: Text(filter,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700))),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                    color: filter == _filter
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : const Color(0xFFC4DAF7),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                    '${filter == 'All' ? 3 : 3 - _read.length}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ]),
                      ),
                    ),
                  ),
                )),
            ]),
          ),
          const SizedBox(height: 16),
          if (visible.isEmpty)
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(children: [
                  Icon(Icons.done_all, color: AppColors.ocean, size: 48),
                  SizedBox(height: 12),
                  Text('All caught up!',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w800))
                ])),
          for (final i in visible)
            Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Card(
                    child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          setState(() => _read.add(i));
                          showModalBottomSheet<void>(
                              context: context,
                              showDragHandle: true,
                              isScrollControlled: true,
                              builder: (context) => SafeArea(
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 8, 24, 32),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(_icons[i],
                                                color: _colors[i], size: 38),
                                            const SizedBox(height: 16),
                                            Text(_titles[i],
                                                style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                            const SizedBox(height: 12),
                                            Text(_messages[i],
                                                style: const TextStyle(
                                                    height: 1.6)),
                                            const SizedBox(height: 20),
                                            FilledButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Got it')),
                                          ]))));
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: _colors[i]
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        child:
                                            Icon(_icons[i], color: _colors[i])),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Text(
                                            i == 0
                                                ? '2 min ago'
                                                : i == 1
                                                    ? '1 hour ago'
                                                    : '3 hours ago',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6D8190)))),
                                    if (!_read.contains(i))
                                      Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                              color: _colors[i],
                                              shape: BoxShape.circle)),
                                  ]),
                                  const SizedBox(height: 14),
                                  Text(_titles[i],
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 6),
                                  Text(_messages[i],
                                      style: const TextStyle(
                                          color: Color(0xFF6D8190),
                                          height: 1.5)),
                                  const SizedBox(height: 12),
                                  Text('View notification',
                                      style: TextStyle(
                                          color: _colors[i],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700)),
                                ])))))
        ]);
  }
}
