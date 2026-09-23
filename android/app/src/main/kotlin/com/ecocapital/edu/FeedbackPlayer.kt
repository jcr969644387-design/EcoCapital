package com.ecocapital.edu

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.SoundPool
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.FlutterInjector
import java.io.File

/**
 * Sonidos cortos (SoundPool) y vibración (Vibrator) para las interacciones.
 *
 * Respeta el modo silencio/vibración del teléfono y comprueba si el
 * dispositivo tiene motor de vibración y control de intensidad.
 */
class FeedbackPlayer(private val context: Context) {
    private val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private val audioManager =
        context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager

    private val vibrator: Vibrator? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val manager =
                context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
            manager?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }

    private val soundPool: SoundPool =
        SoundPool.Builder()
            .setMaxStreams(4)
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build(),
            )
            .build()

    private val soundIds = mutableMapOf<String, Int>()
    private val loaded = mutableSetOf<Int>()

    init {
        soundPool.setOnLoadCompleteListener { _, sampleId, status ->
            if (status == 0) {
                loaded.add(sampleId)
            }
        }
        for (name in SOUNDS) {
            load(name)
        }
    }

    private fun load(name: String) {
        val asset = FlutterInjector.instance()
            .flutterLoader()
            .getLookupKeyForAsset("assets/sounds/$name.wav")
        val id = try {
            context.assets.openFd(asset).use { soundPool.load(it, 1) }
        } catch (e: Exception) {
            // Si el recurso está comprimido, se copia a la caché.
            try {
                val file = File(context.cacheDir, "feedback_$name.wav")
                if (!file.exists()) {
                    context.assets.open(asset).use { input ->
                        file.outputStream().use { input.copyTo(it) }
                    }
                }
                soundPool.load(file.absolutePath, 1)
            } catch (e: Exception) {
                return
            }
        }
        soundIds[name] = id
    }

    fun play(name: String): Boolean {
        val id = soundIds[name] ?: return false
        if (id !in loaded) return false
        val ringerMode = audioManager?.ringerMode ?: AudioManager.RINGER_MODE_NORMAL
        if (ringerMode != AudioManager.RINGER_MODE_NORMAL) return false
        soundPool.play(id, VOLUME, VOLUME, 1, 0, 1f)
        return true
    }

    fun vibrate(timings: LongArray, amplitudes: IntArray): Boolean {
        val v = vibrator ?: return false
        if (!v.hasVibrator() || timings.isEmpty()) return false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val effect =
                if (v.hasAmplitudeControl() && amplitudes.size == timings.size) {
                    VibrationEffect.createWaveform(timings, amplitudes, -1)
                } else {
                    VibrationEffect.createWaveform(timings, -1)
                }
            v.vibrate(effect)
        } else {
            @Suppress("DEPRECATION")
            v.vibrate(timings, -1)
        }
        return true
    }

    fun settings(): Map<String, Boolean> =
        mapOf(
            "sound" to prefs.getBoolean(KEY_SOUND, true),
            "haptics" to prefs.getBoolean(KEY_HAPTICS, true),
        )

    fun saveSettings(sound: Boolean, haptics: Boolean) {
        prefs.edit()
            .putBoolean(KEY_SOUND, sound)
            .putBoolean(KEY_HAPTICS, haptics)
            .apply()
    }

    fun release() {
        soundPool.release()
    }

    companion object {
        private const val PREFS = "ecocapital_feedback"
        private const val KEY_SOUND = "sound"
        private const val KEY_HAPTICS = "haptics"
        private const val VOLUME = 0.6f
        private val SOUNDS =
            listOf("tap", "select", "simulate", "confirm", "success", "partial", "error")
    }
}
