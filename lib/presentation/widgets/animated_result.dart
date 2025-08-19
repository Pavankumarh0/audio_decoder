import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
class AnimatedResult extends StatelessWidget {
final String text;
const AnimatedResult({super.key, required this.text});
@override
Widget build(BuildContext context) {
if (text.isEmpty) return const SizedBox.shrink();
return AnimatedTextKit(
animatedTexts: [
TyperAnimatedText(
text,
textStyle: const TextStyle(
fontSize: 26,
fontWeight: FontWeight.bold,
color: Colors.white,
),
speed: const Duration(milliseconds: 80),
),
],
totalRepeatCount: 1,
isRepeatingAnimation: false,
);
}
}
