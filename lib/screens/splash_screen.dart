import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ripple =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ripple.stop();
    } else {
      _ripple.repeat();
    }
  }

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0C235B), Color(0xFF1854CC), Color(0xFF4398FF)],
          )),
          child: Stack(fit: StackFit.expand, children: [
            AnimatedBuilder(
                animation: _ripple,
                builder: (context, _) =>
                    CustomPaint(painter: _SplashWaves(_ripple.value))),
            SafeArea(
                child: Column(children: [
              const SizedBox(height: 28),
              const Text('SMART WATER. SIMPLE LIVING.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFFC9DEFF),
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600)),
              Expanded(
                  child: Center(
                      child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 1100),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                            offset: Offset(0, 22 * (1 - value)), child: child)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(
                          width: 220,
                          height: 220,
                          child: AnimatedBuilder(
                              animation: _ripple,
                              builder: (context, _) =>
                                  Stack(alignment: Alignment.center, children: [
                                    for (var i = 0; i < 3; i++)
                                      Container(
                                          width: 144 +
                                              ((_ripple.value + i / 3) % 1) *
                                                  76,
                                          height: 144 +
                                              ((_ripple.value + i / 3) % 1) *
                                                  76,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white.withValues(
                                                      alpha: (1 -
                                                              ((_ripple.value +
                                                                      i / 3) %
                                                                  1)) *
                                                          0.22)))),
                                    Container(
                                        width: 132,
                                        height: 132,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: const Color(0xFF081B50)
                                                      .withValues(alpha: 0.25),
                                                  blurRadius: 36,
                                                  offset: const Offset(0, 14))
                                            ]),
                                        child: const Icon(
                                            Icons.water_drop_rounded,
                                            size: 72,
                                            color: Color(0xFF246BFD))),
                                  ]))),
                      const SizedBox(height: 18),
                      const Text('Tank Master',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1)),
                      const SizedBox(height: 12),
                      const Text('A little care.\nEvery drop counts.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Color(0xFFD8E7FF))),
                    ])),
              ))),
              const SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                      minHeight: 3,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      color: Colors.white,
                      backgroundColor: Color(0xFF629EF0))),
              const SizedBox(height: 14),
              const Text('Getting things ready',
                  style: TextStyle(fontSize: 12, color: Color(0xFFD8E7FF))),
              const SizedBox(height: 32),
            ])),
          ]),
        ),
      );
}

class _SplashWaves extends CustomPainter {
  const _SplashWaves(this.phase);
  final double phase;
  @override
  void paint(Canvas canvas, Size size) {
    for (var layer = 0; layer < 3; layer++) {
      final path = Path()..moveTo(0, size.height);
      for (double x = 0; x <= size.width; x += 3) {
        path.lineTo(
            x,
            size.height * (0.80 + layer * 0.06) +
                math.sin(x / size.width * math.pi * 2 +
                        phase * math.pi * 2 +
                        layer) *
                    24);
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.04 + layer * 0.025));
    }
  }

  @override
  bool shouldRepaint(covariant _SplashWaves oldDelegate) =>
      oldDelegate.phase != phase;
}
