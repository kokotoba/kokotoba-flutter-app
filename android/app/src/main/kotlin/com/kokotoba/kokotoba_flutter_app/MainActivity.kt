package com.kokotoba.kokotoba_flutter_app

import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity(), TextToSpeech.OnInitListener {
    private var textToSpeech: TextToSpeech? = null
    private var isSpeechReady = false
    private var pendingText: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        textToSpeech = TextToSpeech(applicationContext, this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.kokotoba.app/text_to_speech",
        ).setMethodCallHandler { call, result ->
            if (call.method != "speak") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val text = call.argument<String>("text").orEmpty()
            if (text.isBlank()) {
                result.success(null)
                return@setMethodCallHandler
            }
            if (isSpeechReady) {
                speakNow(text)
            } else {
                pendingText = text
            }
            result.success(null)
        }
    }

    override fun onInit(status: Int) {
        if (status != TextToSpeech.SUCCESS) return
        val result = textToSpeech?.setLanguage(Locale.JAPANESE)
        isSpeechReady =
            result != TextToSpeech.LANG_MISSING_DATA &&
            result != TextToSpeech.LANG_NOT_SUPPORTED
        if (isSpeechReady) {
            pendingText?.let(::speakNow)
            pendingText = null
        }
    }

    private fun speakNow(text: String) {
        textToSpeech?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "kokotoba_text_to_speech")
    }

    override fun onDestroy() {
        textToSpeech?.stop()
        textToSpeech?.shutdown()
        textToSpeech = null
        super.onDestroy()
    }
}
