import 'dart:math' as math;
import 'package:flutter/material.dart';
class WaveLoader extends StatefulWidget {
const WaveLoader({super.key});
@override
State<WaveLoader> createState() => _WaveLoaderState();
}
class _WaveLoaderState extends State<WaveLoader>
with SingleTickerProviderStateMixin {
late final AnimationController _c;
@override
void initState() {
super.initState();
_c = AnimationController(vsync: this, duration: const Duration(seconds: 3))
  ..repeat();
}
@override
void dispose() { _c.dispose(); super.dispose(); }
@override
Widget build(BuildContext context) {
return AnimatedBuilder(
animation: _c,
builder: (_, __) {
return CustomPaint(
size: const Size(double.infinity, 120),
painter: _WavePainter(_c.value),
);
},
);
}
}
class _WavePainter extends CustomPainter {
final double t;
_WavePainter(this.t);
@override
void paint(Canvas canvas, Size size) {
final p = Paint()..color = Colors.white.withOpacity(.25);
final path = Path();
final h = size.height * .5;
const amp = 18.0;
path.moveTo(0, h);
for (double x = 0; x <= size.width; x++) {
final y = h + math.sin((x / size.width * 2 * math.pi) + t * 2 *
math.pi) * amp;
path.lineTo(x, y);
}
path.lineTo(size.width, size.height);
path.lineTo(0, size.height);
path.close();
canvas.drawPath(path, p);
}
@override
bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
