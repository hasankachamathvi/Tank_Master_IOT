import 'package:flutter/material.dart';

class AppColors {
  static const ink = Color(0xFF16364B);
  static const aqua = Color(0xFF079BA5);
  static const violet = Color(0xFF7961CC);
  static const coral = Color(0xFFE77965);
  static const mint = Color(0xFF329B7F);
}

class PageIntro extends StatelessWidget {
  const PageIntro({super.key, required this.title, required this.subtitle,
    required this.icon, this.color = AppColors.aqua, this.eyebrow = 'TANK MASTER'});
  final String title, subtitle, eyebrow;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [color, Color.lerp(color, AppColors.ink, 0.38)!]),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [BoxShadow(color: color.withValues(alpha: 0.16), blurRadius: 20, offset: const Offset(0, 8))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(eyebrow, style: const TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.w700))),
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: Colors.white, size: 24)),
      ]),
      const SizedBox(height: 14),
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.7)),
      const SizedBox(height: 8),
      Text(subtitle, style: const TextStyle(color: Color(0xFFF2F9FF), fontSize: 13, height: 1.5)),
    ]));
}

class ColorStat extends StatelessWidget {
  const ColorStat({super.key, required this.label, required this.value, required this.icon, required this.color});
  final String label, value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Color.lerp(color, Colors.white, 0.9), borderRadius: BorderRadius.circular(22)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 24), const SizedBox(height: 16),
      Text(value, style: const TextStyle(color: AppColors.ink, fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Color(0xFF516777), fontSize: 12)),
    ]));
}

class PageEntrance extends StatelessWidget {
  const PageEntrance({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 450),
    curve: Curves.easeOutCubic,
    child: child,
    builder: (context, value, child) => Opacity(opacity: value,
      child: Transform.translate(offset: Offset(0, 18 * (1 - value)), child: child)));
}
