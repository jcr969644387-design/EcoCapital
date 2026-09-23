package com.ecocapital.edu

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var feedback: FeedbackPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val player = FeedbackPlayer(applicationContext)
        feedback = player
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "playSound" ->
                        result.success(player.play(call.argument<String>("name") ?: ""))
                    "vibrate" -> {
                        val timings = call.argument<List<Number>>("timings")
                            ?.map { it.toLong() }?.toLongArray() ?: LongArray(0)
                        val amplitudes = call.argument<List<Number>>("amplitudes")
                            ?.map { it.toInt() }?.toIntArray() ?: IntArray(0)
                        result.success(player.vibrate(timings, amplitudes))
                    }
                    "getSettings" -> result.success(player.settings())
                    "setSettings" -> {
                        player.saveSettings(
                            call.argument<Boolean>("sound") ?: true,
                            call.argument<Boolean>("haptics") ?: true,
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        feedback?.release()
        feedback = null
        super.onDestroy()
    }

    companion object {
        private const val CHANNEL = "com.ecocapital.edu/feedback"
    }
}
