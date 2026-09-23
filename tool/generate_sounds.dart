// Genera los sonidos de interacción de EcoCapital en assets/sounds/.
//
// Uso: dart run tool/generate_sounds.dart
//
// Son tonos sintetizados, cortos y de volumen moderado para que acompañen
// las acciones sin resultar molestos.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int sampleRate = 44100;

void main() {
  final sounds = <String, List<double>>{
    'tap': _tone(1500, 0.035, gain: 0.22, decay: 90),
    'select': _tone(2200, 0.022, gain: 0.14, decay: 140),
    'simulate': _concat([
      _sweep(520, 1250, 0.13, gain: 0.16),
      _tone(1568, 0.09, gain: 0.18, decay: 35),
    ]),
    'confirm': _chime(988, 0.16, gain: 0.24),
    'success': _concat([
      _chime(784, 0.09, gain: 0.22),
      _chime(1175, 0.22, gain: 0.26),
    ]),
    'partial': _concat([
      _chime(784, 0.1, gain: 0.2),
      _chime(784, 0.16, gain: 0.18),
    ]),
    'error': _concat([
      _chime(440, 0.1, gain: 0.22, bright: false),
      _chime(349, 0.2, gain: 0.22, bright: false),
    ]),
  };
  final dir = Directory('assets/sounds')..createSync(recursive: true);
  for (final entry in sounds.entries) {
    final file = File('${dir.path}/${entry.key}.wav');
    file.writeAsBytesSync(_wav(entry.value));
    stdout.writeln('${file.path} (${file.lengthSync()} bytes)');
  }
}

/// Tono con ataque corto y caída exponencial.
List<double> _tone(
  double freq,
  double seconds, {
  required double gain,
  double decay = 40,
}) {
  final n = (seconds * sampleRate).round();
  return List<double>.generate(n, (i) {
    final t = i / sampleRate;
    final attack = math.min(1.0, t / 0.003);
    final env = attack * math.exp(-decay * t);
    return gain * env * math.sin(2 * math.pi * freq * t);
  });
}

/// Nota tipo campana (fundamental + armónico suave).
List<double> _chime(
  double freq,
  double seconds, {
  required double gain,
  bool bright = true,
}) {
  final n = (seconds * sampleRate).round();
  return List<double>.generate(n, (i) {
    final t = i / sampleRate;
    final attack = math.min(1.0, t / 0.004);
    final release = math.min(1.0, (seconds - t) / 0.02);
    final env = attack * release * math.exp(-9 * t);
    final harmonic = bright ? 0.28 : 0.12;
    final wave = math.sin(2 * math.pi * freq * t) +
        harmonic * math.sin(2 * math.pi * freq * 2 * t);
    return gain * env * wave / (1 + harmonic);
  });
}

/// Barrido ascendente de frecuencia.
List<double> _sweep(
  double from,
  double to,
  double seconds, {
  required double gain,
}) {
  final n = (seconds * sampleRate).round();
  var phase = 0.0;
  return List<double>.generate(n, (i) {
    final p = i / n;
    final freq = from + (to - from) * p * p;
    phase += 2 * math.pi * freq / sampleRate;
    final env = math.sin(math.pi * p);
    return gain * env * math.sin(phase);
  });
}

List<double> _concat(List<List<double>> parts) => [for (final p in parts) ...p];

Uint8List _wav(List<double> samples) {
  final dataSize = samples.length * 2;
  final bytes = ByteData(44 + dataSize);
  void ascii(int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      bytes.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  bytes.setUint32(4, 36 + dataSize, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little);
  bytes.setUint16(22, 1, Endian.little);
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(28, sampleRate * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  bytes.setUint32(40, dataSize, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    final value = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    bytes.setInt16(44 + i * 2, value, Endian.little);
  }
  return bytes.buffer.asUint8List();
}
