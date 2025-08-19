import 'dart:math' as math;
import 'package:flutter/material.dart';
class GlowBackground extends StatefulWidget {
const GlowBackground({super.key});
@override
State<GlowBackground> createState() => _GlowBackgroundState();
}
class _GlowBackgroundState extends State<GlowBackground>
with SingleTickerProviderStateMixin {
late final AnimationController _c;
@override
void initState() {
super.initState();
_c = AnimationController(vsync: this, duration: const Duration(seconds: 10))
..repeat();
}
@override
void dispose() { _c.dispose(); super.dispose(); }
@override
Widget build(BuildContext context) {
return AnimatedBuilder(
animation: _c,
builder: (_, __) => CustomPaint(
painter: _GlowPainter(_c.value),
child: const SizedBox.expand(),
),
);
}
}
class _GlowPainter extends CustomPainter {
final double t;
_GlowPainter(this.t);
@override
void paint(Canvas canvas, Size size) {
final paint = Paint()
..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60)
..style = PaintingStyle.fill;
final colors = [
Colors.purpleAccent.withOpacity(.35),
Colors.cyanAccent.withOpacity(.30),
Colors.blueAccent.withOpacity(.30),
Colors.pinkAccent.withOpacity(.30),
];
for (int i = 0; i < 4; i++) {
paint.color = colors[i];
final dx = size.width * (0.3 + 0.4 * math.sin(2 * math.pi * (t + i * 0.2)));
final dy = size.height * (0.3 + 0.4 * math.cos(2 * math.pi * (t + i * 0.2)));
canvas.drawCircle(Offset(dx, dy), 160, paint);
}
}
@override
bool shouldRepaint(covariant _GlowPainter oldDelegate) => true;
}
