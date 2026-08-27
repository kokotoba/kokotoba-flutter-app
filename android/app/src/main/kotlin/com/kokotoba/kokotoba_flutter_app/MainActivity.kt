package com.kokotoba.kokotoba_flutter_app

import android.media.AudioAttributes
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity(), TextToSpeech.OnInitListener {
    private var textToSpeech: TextToSpeech? = null
    private var isSpeechReady = false
    private var initializationFailed = false
    private var pendingText: String? = null
    private var utteranceSequence = 0L

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        initializeTextToSpeech()
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
                if (initializationFailed) {
                    initializeTextToSpeech()
                }
            }
            result.success(null)
        }
    }

    override fun onInit(status: Int) {
        if (status != TextToSpeech.SUCCESS) {
            initializationFailed = true
            return
        }
        val result = textToSpeech?.setLanguage(Locale.JAPANESE)
        isSpeechReady =
            result != TextToSpeech.LANG_MISSING_DATA &&
            result != TextToSpeech.LANG_NOT_SUPPORTED
        initializationFailed = !isSpeechReady
        if (isSpeechReady) {
            textToSpeech?.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ASSISTANCE_ACCESSIBILITY)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build(),
            )
            pendingText?.let(::speakNow)
            pendingText = null
        }
    }

    private fun initializeTextToSpeech() {
        textToSpeech?.stop()
        textToSpeech?.shutdown()
        isSpeechReady = false
        initializationFailed = false
        textToSpeech = TextToSpeech(applicationContext, this)
    }

    private fun speakNow(text: String) {
        utteranceSequence += 1
        val status = textToSpeech?.speak(
            text,
            TextToSpeech.QUEUE_FLUSH,
            null,
            "kokotoba_text_to_speech_$utteranceSequence",
        )
        if (status == TextToSpeech.ERROR) {
            pendingText = text
            initializationFailed = true
            initializeTextToSpeech()
        }
    }

    override fun onDestroy() {
        textToSpeech?.stop()
        textToSpeech?.shutdown()
        textToSpeech = null
        super.onDestroy()
    }
}
