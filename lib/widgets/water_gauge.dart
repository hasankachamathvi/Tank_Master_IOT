import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaterGauge extends StatefulWidget {
  const WaterGauge({super.key, required this.level, this.size = 240});
  final double level, size;
  @override
  State<WaterGauge> createState() => _WaterGaugeState();
}

class _WaterGaugeState extends State<WaterGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _wave.stop();
    } else {
      _wave.repeat();
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
      label: 'Water level ${widget.level.toStringAsFixed(0)} percent',
      child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: widget.level),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, level, _) => AnimatedBuilder(
                  animation: _wave,
                  builder: (context, _) => CustomPaint(
                      painter: _WaterGaugePainter(
                          level,
                          _wave.value,
                          level <= 30
                              ? const Color(0xFFE6A044)
                              : const Color(0xFF246BDB)),
                      child: Center(
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                  padding: const EdgeInsets.all(22),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('${level.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                                fontSize: widget.size * 0.225,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF102D50),
                                                letterSpacing: -2)),
                                        if (widget.size >= 180)
                                          const Text('WATER LEVEL',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  letterSpacing: 2,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF234D63))),
                                      ])))))))));
}

class _WaterGaugePainter extends CustomPainter {
  const _WaterGaugePainter(this.level, this.phase, this.color);
  final double level;
  final double phase;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 10;
    final ring = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFFDCE8F8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8);
    canvas.drawArc(
        ring,
        -math.pi / 2,
        2 * math.pi * level.clamp(0, 100) / 100,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round);
    canvas.save();
    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius - 12)));
    canvas.drawColor(const Color(0xFFF0F6FF), BlendMode.srcOver);
    for (var layer = 0; layer < 2; layer++) {
      final path = Path()..moveTo(0, size.height);
      for (double x = 0; x <= size.width; x += 2) {
        final y = size.height * (1 - level.clamp(0, 100) / 100) +
            math.sin(x / size.width * math.pi * 2 +
                    phase * math.pi * 2 +
                    layer * 2) *
                6;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path,
          Paint()..color = color.withValues(alpha: layer == 0 ? 0.12 : 0.18));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WaterGaugePainter old) =>
      old.level != level || old.phase != phase || old.color != color;
}
