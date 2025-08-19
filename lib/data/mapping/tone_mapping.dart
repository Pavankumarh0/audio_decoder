/// Frequency (Hz) -> Character mapping.
/// Values are based on the assignment screenshots + space=418 Hz.
/// You can extend/tweak as needed.
class ToneMapping {
// Primary map (rounded integer Hz)
static const Map<int, String> freqToChar = {
418: ' ', // space
440: 'A',
350: 'B',
260: 'C',
474: 'D',
492: 'E',
461: 'F',
584: 'G',
553: 'H',
582: 'I',
525: 'J',
501: 'K',
532: 'L',
594: 'M',
599: 'N',
528: 'O',
539: 'P',
675: 'Q',
683: 'R',
698: 'S',
631: 'T',
628: 'U',
611: 'V',
622: 'W',
677: 'X',
688: 'Y',
693: 'Z',
};


/// How many Hz we allow when snapping detected frequencies.
static const int snapToleranceHz = 6;


/// Candidate list used by Goertzel scoring
static List<int> candidateFrequencies() => freqToChar.keys.toList()..sort();
}