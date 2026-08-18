import 'package:kokotoba_flutter_app/core/controller/speech_recognition_controller.dart';
import 'package:speech_to_text/speech_to_text.dart';

class DeviceSpeechRecognitionController implements SpeechRecognitionController {
  DeviceSpeechRecognitionController({SpeechToText? speech})
    : speech = speech ?? SpeechToText();

  final SpeechToText speech;

  SpeechResultCallback? _onResult;
  SpeechErrorCallback? _onError;
  ListeningStateCallback? _onListeningChanged;
  bool _initialized = false;

  @override
  Future<bool> initialize({
    required SpeechResultCallback onResult,
    required SpeechErrorCallback onError,
    required ListeningStateCallback onListeningChanged,
  }) async {
    _onResult = onResult;
    _onError = onError;
    _onListeningChanged = onListeningChanged;
    if (_initialized) return true;

    _initialized = await speech.initialize(
      onError: (error) => _onError?.call(error.errorMsg),
      onStatus: (_) => _onListeningChanged?.call(speech.isListening),
      options: [SpeechToText.androidNoBluetooth, SpeechToText.iosNoBluetooth],
    );
    return _initialized;
  }

  @override
  Future<void> start() async {
    if (!_initialized) {
      throw StateError('音声認識が初期化されていません');
    }
    await speech.listen(
      onResult: (result) =>
          _onResult?.call(result.recognizedWords, result.finalResult),
      listenOptions: SpeechListenOptions(
        localeId: 'ja_JP',
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 10),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        autoPunctuation: true,
      ),
    );
  }

  @override
  Future<void> stop() => speech.stop();

  @override
  Future<void> cancel() => speech.cancel();
}
