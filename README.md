# 🎵 Hidden-Tone Audio Decoder

A Flutter application that decodes messages hidden inside WAV files.  
Each character is represented as a pure tone (~300 ms), and spaces are encoded as a 418 Hz tone.  
The app reads audio, segments tones, estimates frequencies, and reconstructs the hidden text with a clean animated UI.

---

## 🌐 Live Demo

👉 [Try it here on Vercel](https://audio-decoder1-zci6.vercel.app/)

---

## 🚀 Approach Taken

The decoding pipeline is:

1. **Pick WAV file** → Using [`file_picker`](https://pub.dev/packages/file_picker).
2. **Parse WAV** → Extract PCM samples via [`wav`](https://pub.dev/packages/wav).
3. **Segmentation** → Short-time energy with:
   - 20 ms frames, 10 ms hop
   - Adaptive threshold (60th percentile)
   - Merge gaps < 60 ms
   - Keep durations 0.12–0.8 s
4. **Frequency Estimation** → Run **Goertzel algorithm** across candidate tones defined in `tone_mapping.dart`.
5. **Snapping** → Match detected frequency to the nearest expected tone (±6 Hz tolerance).
6. **Reconstruction** → Map tones to characters and render as animated text with a glowing background.

---

## 🏗️ Clean Architecture Application

This project applies Clean Architecture principles to keep code modular and testable:

- **Data Layer**
  - `tone_mapping.dart` → Defines frequency-to-character mappings.
- **Domain / Services Layer**
  - `audio_decoder_service.dart` → Core business logic (segmentation, Goertzel, mapping).
- **Presentation Layer**
  - `pages/` → UI pages (e.g., `home_page.dart`).
  - `widgets/` → Reusable components (`animated_result.dart`, `wave_loader.dart`).
  - `painters/` → Custom painters (`glow_background.dart`).

Each layer has a **single responsibility**:
- **Presentation** only handles UI.
- **Service** focuses on decoding logic.
- **Data** provides mappings/configurations.

---

## ⚠️ Limitations

- **Noise Sensitivity** → Works best with clean signals. Very noisy audio may require adjusting thresholds or Hann window length.
- **Fixed Tones** → Decoding depends on the exact `freqToChar` mapping. If tones differ, mapping or `snapToleranceHz` must be updated.
- **Segment Assumptions** → Assumes tones last between 0.12–0.8 s. Faster or slower tones may be discarded.
- **Spaces** → Explicitly mapped to 418 Hz. No dynamic silence-based gap detection yet.
- **Single Hidden Message** → Designed for single-pass decoding of short messages, not long-form audio streams.

---

## ▶️ Run the App

```bash
# Run for Web
flutter run -d chrome

# Run for Android
flutter run -d android

# Run for Desktop
flutter run -d windows
