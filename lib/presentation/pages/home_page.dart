import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/audio_decoder_service.dart';
import '../painters/glow_background.dart';
import '../widgets/animated_result.dart';
import '../widgets/wave_loader.dart';
class HomePage extends StatefulWidget {
const HomePage({super.key});
@override
State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
bool _busy = false;
String _message = '';
List<double> _freqs = const [];
Future<void> _pickAndDecode() async {
setState(() { _busy = true; _message = ''; _freqs = const []; });
final result = await FilePicker.platform.pickFiles(
type: FileType.custom,
allowedExtensions: const ['wav'],
withData: true,
);
if (result == null || result.files.single.bytes == null) {
setState(() { _busy = false; });
return;
}
final bytes = result.files.single.bytes as Uint8List;
final service = AudioDecoderService();
try {
final out = await service.decodeHiddenMessage(bytes);
setState(() {
_message = out.message;
_freqs = out.segmentFreqs;
});
} catch (e) {
setState(() { _message = 'Decode error: $e'; });
} finally {
setState(() { _busy = false; });
}
}
@override
Widget build(BuildContext context) {
return Scaffold(
body: Stack(
children: [
const GlowBackground(),
SafeArea(
child: Center(
child: Padding(
padding: const EdgeInsets.all(16.0),
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 700),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
const Text(
'Hidden Tone Decoder',
style: TextStyle(fontSize: 28, fontWeight:
FontWeight.bold),
),
const SizedBox(height: 8),
const Text(
'Pick a WAV file; each ~300ms tone maps to a letter (space = 418 Hz).',
textAlign: TextAlign.center,
),
const SizedBox(height: 24),
ElevatedButton.icon(
style: ElevatedButton.styleFrom(
padding: const EdgeInsets.symmetric(horizontal:
22, vertical: 12),
shape: RoundedRectangleBorder(borderRadius:
BorderRadius.circular(14)),
),
onPressed: _busy ? null : _pickAndDecode,
icon: const Icon(Icons.audiotrack),
label: const Text('Pick WAV & Decode'),
),
const SizedBox(height: 24),
if (_busy) const WaveLoader(),
if (!_busy && _message.isNotEmpty) ...[
const SizedBox(height: 8),
const Divider(height: 24),
const Text('Decoded Message:', style:
TextStyle(fontWeight: FontWeight.w600)),
const SizedBox(height: 8),
AnimatedResult(text: _message),
const SizedBox(height: 20),
if (_freqs.isNotEmpty) Text(
'Detected tones: ${_freqs.map((f) =>
f.toStringAsFixed(0)).join(', ')}',
style: const TextStyle(fontSize: 12, color:
Colors.white70),
textAlign: TextAlign.center,
),
],
],
),
),
),
),
),
],
),
);
}
}