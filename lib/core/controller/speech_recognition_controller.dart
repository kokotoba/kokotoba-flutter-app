typedef SpeechResultCallback = void Function(String text, bool isFinal);
typedef SpeechErrorCallback = void Function(String message);
typedef ListeningStateCallback = void Function(bool isListening);

abstract interface class SpeechRecognitionController {
  Future<bool> initialize({
    required SpeechResultCallback onResult,
    required SpeechErrorCallback onError,
    required ListeningStateCallback onListeningChanged,
  });

  Future<void> start();

  Future<void> stop();

  Future<void> cancel();
}
