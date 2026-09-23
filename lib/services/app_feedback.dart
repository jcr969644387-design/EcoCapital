import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Tipos de retroalimentación sensorial de la aplicación.
enum FeedbackCue {
  /// Pulsación de un botón o tarjeta.
  tap,

  /// Selección de una opción (chips, segmentos, interruptores, deslizador).
  select,

  /// Simulación o recálculo del proyecto.
  simulate,

  /// Confirmación de una acción (restablecer, cambiar ajustes).
  confirm,

  /// Respuesta correcta.
  success,

  /// Respuesta parcialmente correcta.
  partial,

  /// Respuesta incorrecta o datos inválidos.
  error,
}

/// Sonidos y vibración de las interacciones importantes.
///
/// En Android usa un canal nativo (SoundPool + Vibrator) que respeta el modo
/// silencio y las capacidades del dispositivo. Si el canal no está
/// disponible, recurre a la vibración y el clic del sistema.
class AppFeedback {
  AppFeedback._();

  static final AppFeedback instance = AppFeedback._();

  static const MethodChannel channel =
      MethodChannel('com.ecocapital.edu/feedback');

  /// Sonido activado.
  final ValueNotifier<bool> soundEnabled = ValueNotifier<bool>(true);

  /// Vibración activada.
  final ValueNotifier<bool> hapticsEnabled = ValueNotifier<bool>(true);

  /// Evita repetir la misma señal demasiado rápido (p. ej. al arrastrar).
  static const Duration _minGap = Duration(milliseconds: 70);

  final Map<FeedbackCue, DateTime> _lastPlayed = {};

  /// Olvida las últimas señales reproducidas (para pruebas).
  @visibleForTesting
  void resetThrottle() => _lastPlayed.clear();

  /// Carga los ajustes guardados en el dispositivo.
  Future<void> load() async {
    try {
      final settings = await channel.invokeMapMethod<String, Object?>(
        'getSettings',
      );
      if (settings == null) {
        return;
      }
      soundEnabled.value = settings['sound'] as bool? ?? true;
      hapticsEnabled.value = settings['haptics'] as bool? ?? true;
    } catch (_) {
      // Sin canal nativo (pruebas, otras plataformas): valores por defecto.
    }
  }

  Future<void> setSoundEnabled(bool value) async {
    soundEnabled.value = value;
    await _saveSettings();
    if (value) {
      play(FeedbackCue.confirm);
    }
  }

  Future<void> setHapticsEnabled(bool value) async {
    hapticsEnabled.value = value;
    await _saveSettings();
    if (value) {
      play(FeedbackCue.confirm);
    }
  }

  void tap() => play(FeedbackCue.tap);

  void select() => play(FeedbackCue.select);

  void simulate() => play(FeedbackCue.simulate);

  void confirm() => play(FeedbackCue.confirm);

  void success() => play(FeedbackCue.success);

  void partial() => play(FeedbackCue.partial);

  void error() => play(FeedbackCue.error);

  /// Reproduce la señal indicada según los ajustes actuales.
  void play(FeedbackCue cue) {
    final now = DateTime.now();
    final last = _lastPlayed[cue];
    if (last != null && now.difference(last) < _minGap) {
      return;
    }
    _lastPlayed[cue] = now;
    if (soundEnabled.value) {
      unawaited(_playSound(cue));
    }
    if (hapticsEnabled.value) {
      unawaited(_vibrate(cue));
    }
  }

  Future<void> _saveSettings() async {
    try {
      await channel.invokeMethod<void>('setSettings', {
        'sound': soundEnabled.value,
        'haptics': hapticsEnabled.value,
      });
    } catch (_) {
      // Los ajustes siguen vigentes durante la sesión.
    }
  }

  Future<void> _playSound(FeedbackCue cue) async {
    try {
      await channel.invokeMethod<bool>('playSound', {'name': cue.name});
    } catch (_) {
      if (cue != FeedbackCue.select) {
        await _safe(() => SystemSound.play(SystemSoundType.click));
      }
    }
  }

  Future<void> _vibrate(FeedbackCue cue) async {
    final pattern = patterns[cue]!;
    try {
      final done = await channel.invokeMethod<bool>('vibrate', {
        'timings': pattern.timings,
        'amplitudes': pattern.amplitudes,
      });
      if (done ?? false) {
        return;
      }
    } catch (_) {
      // Sin canal nativo: se usa la vibración del sistema.
    }
    await _safe(() => _systemHaptic(cue));
  }

  Future<void> _systemHaptic(FeedbackCue cue) {
    switch (cue) {
      case FeedbackCue.select:
        return HapticFeedback.selectionClick();
      case FeedbackCue.tap:
        return HapticFeedback.lightImpact();
      case FeedbackCue.simulate:
      case FeedbackCue.confirm:
      case FeedbackCue.partial:
        return HapticFeedback.mediumImpact();
      case FeedbackCue.success:
      case FeedbackCue.error:
        return HapticFeedback.heavyImpact();
    }
  }

  Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // El dispositivo no admite esta señal.
    }
  }

  /// Patrones de vibración: tiempos en ms (pausa, vibración, ...) y su
  /// intensidad (0–255). Son breves para no resultar molestos.
  @visibleForTesting
  static const Map<FeedbackCue, VibrationPattern> patterns = {
    FeedbackCue.tap: VibrationPattern([0, 14], [0, 90]),
    FeedbackCue.select: VibrationPattern([0, 8], [0, 60]),
    FeedbackCue.simulate: VibrationPattern([0, 18, 50, 28], [0, 80, 0, 140]),
    FeedbackCue.confirm: VibrationPattern([0, 30], [0, 150]),
    FeedbackCue.success: VibrationPattern([0, 24, 60, 40], [0, 120, 0, 220]),
    FeedbackCue.partial: VibrationPattern([0, 36], [0, 140]),
    FeedbackCue.error: VibrationPattern([0, 50, 70, 50], [0, 200, 0, 200]),
  };
}

/// Patrón de vibración en forma de onda.
@immutable
class VibrationPattern {
  const VibrationPattern(this.timings, this.amplitudes);

  final List<int> timings;
  final List<int> amplitudes;
}
