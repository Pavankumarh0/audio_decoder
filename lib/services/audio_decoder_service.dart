import 'dart:math' as math;
import 'dart:typed_data';
import 'package:wav/wav.dart';
import '../data/mapping/tone_mapping.dart';

class DecodeResult {
  final String message;
  final List<double> segmentFreqs; // detected fundamental per segment
  final List<({double start, double end})> times;

  DecodeResult({
    required this.message,
    required this.segmentFreqs,
    required this.times,
  });
}

class AudioDecoderService {
  /// Main entry: bytes -> message
  Future<DecodeResult> decodeHiddenMessage(Uint8List wavBytes) async {
    final wav = Wav.read(wavBytes);

    // wav.channels is List<Float32List>, one entry per channel
    final channels = wav.channels;

    if (channels.isEmpty) {
      throw Exception('No audio channels found in WAV file.');
    }

    // Mix to mono if stereo
    late List<double> samples;
    if (channels.length == 1) {
      samples = channels[0].toList();
    } else {
      final left = channels[0];
      final right = channels[1];
      final n = math.min(left.length, right.length);
      samples = List<double>.generate(n, (i) => (left[i] + right[i]) / 2);
    }

    final sr = wav.samplesPerSecond;

    // 1) Segment the audio into tone chunks using short-time energy.
    final segments = _segment(samples, sr);

    // 2) Estimate dominant frequency for each segment with Goertzel over known tones.
    final candidateHz = ToneMapping.candidateFrequencies();
    final detected = <double>[];
    for (final seg in segments) {
      final f = _dominantByGoertzel(samples, sr, seg.$1, seg.$2, candidateHz);
      detected.add(f);
    }

    // 3) Snap each frequency to nearest mapped tone within tolerance and build text.
    final chars = <String>[];
    for (final f in detected) {
      final nearest = _nearestKey(ToneMapping.freqToChar.keys, f.round());
      if ((nearest - f).abs() <= ToneMapping.snapToleranceHz) {
        chars.add(ToneMapping.freqToChar[nearest]!);
      } else {
        chars.add('¿'); // unknown token
      }
    }

    // 4) Return message
    final message = chars.join();

    // Build time info (seconds)
    final times = segments
        .map((s) => (start: s.$1 / sr, end: s.$2 / sr))
        .toList(growable: false);

    return DecodeResult(message: message, segmentFreqs: detected, times: times);
  }

  // ------------------------- SEGMENTATION -------------------------
  /// Short-time energy segmentation with 20 ms frames, 10 ms hop,
  /// adaptive threshold (60th percentile), merge gaps < 60 ms,
  /// keep durations between 0.12 and 0.8 seconds.
  List<(int, int)> _segment(List<double> x, int sr) {
    final frameLen = (0.02 * sr).round();
    final hop = (0.01 * sr).round();
    if (x.length < frameLen) return [];

    final nFrames = 1 + ((x.length - frameLen) ~/ hop);
    final energy = List<double>.generate(nFrames, (i) {
      final start = i * hop;
      final end = start + frameLen;
      double e = 0;
      for (int k = start; k < end; k++) {
        final s = x[k];
        e += s * s;
      }
      return e / frameLen;
    });

    final sorted = [...energy]..sort();
    final p60 = sorted[(0.60 * (sorted.length - 1)).round()];
    final active = energy.map((e) => e > p60).toList();

    // Frame segments
    final raw = <(int, int)>[];
    var inSeg = false;
    var start = 0;
    for (int i = 0; i < active.length; i++) {
      if (active[i] && !inSeg) {
        inSeg = true;
        start = i;
      } else if (!active[i] && inSeg) {
        inSeg = false;
        raw.add((start, i));
      }
    }
    if (inSeg) raw.add((start, active.length));

    // Merge gaps < 60 ms
    final gapFrames = (0.06 / 0.01).round();
    final merged = <(int, int)>[];
    for (final seg in raw) {
      if (merged.isEmpty) {
        merged.add(seg);
        continue;
      }
      final prev = merged.last;
      if (seg.$1 - prev.$2 <= gapFrames) {
        merged[merged.length - 1] = (prev.$1, seg.$2);
      } else {
        merged.add(seg);
      }
    }

    // Convert to sample indices; keep durations
    final out = <(int, int)>[];
    for (final seg in merged) {
      final s = seg.$1 * hop;
      final e = math.min(x.length, seg.$2 * hop + frameLen);
      final dur = (e - s) / sr;
      if (dur >= 0.12 && dur <= 0.8) out.add((s, e));
    }
    return out;
  }

  // ------------------------- FREQUENCY ESTIMATION -------------------------
  /// Goertzel scoring at each candidate tone; returns the best frequency (Hz)
  double _dominantByGoertzel(
      List<double> x, int sr, int s, int e, List<int> freqs) {
    final slice = x.sublist(s, e);
    // Hann window to reduce spectral leakage
    for (int i = 0; i < slice.length; i++) {
      slice[i] *= 0.5 * (1 - math.cos(2 * math.pi * i / (slice.length - 1)));
    }
    double bestPow = -1;
    int bestF = freqs.first;
    for (final f in freqs) {
      final p = _goertzelPower(slice, sr, f);
      if (p > bestPow) {
        bestPow = p;
        bestF = f;
      }
    }
    return bestF.toDouble();
  }

  /// Classic Goertzel algorithm power at a target frequency f0.
  double _goertzelPower(List<double> x, int sr, int f0) {
    final n = x.length;
    final k = ((n * f0) / sr).round();
    final w = 2 * math.pi * k / n;
    final cosw = math.cos(w);
    final coeff = 2 * cosw;
    double s0 = 0, s1 = 0, s2 = 0;
    for (int i = 0; i < n; i++) {
      s0 = x[i] + coeff * s1 - s2;
      s2 = s1;
      s1 = s0;
    }
    final power = s1 * s1 + s2 * s2 - coeff * s1 * s2;
    return power;
  }

  // ------------------------- UTILS -------------------------
  int _nearestKey(Iterable<int> keys, int value) {
    int best = keys.first;
    int bestDiff = (best - value).abs();
    for (final k in keys) {
      final d = (k - value).abs();
      if (d < bestDiff) {
        best = k;
        bestDiff = d;
      }
    }
    return best;
  }
}
