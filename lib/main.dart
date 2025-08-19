import 'package:flutter/material.dart';
import 'presentation/pages/home_page.dart';

      
void main() {
WidgetsFlutterBinding.ensureInitialized();
runApp(const HiddenToneApp());
}


class HiddenToneApp extends StatelessWidget {
const HiddenToneApp({super.key});


@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'Hidden Tone Decoder',
theme: ThemeData.dark(useMaterial3: true).copyWith(
scaffoldBackgroundColor: const Color(0xFF0A0A10),
colorScheme: ColorScheme.fromSeed(
seedColor: const Color(0xFF7C4DFF),
brightness: Brightness.dark,
),
),
home: const HomePage(),
);
}
}