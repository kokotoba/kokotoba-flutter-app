import 'package:kokotoba_flutter_app/core/controller/speech_recognition_controller.dart';

class MockSpeechRecognitionController implements SpeechRecognitionController {
  const MockSpeechRecognitionController();

  @override
  Future<bool> initialize({
    required SpeechResultCallback onResult,
    required SpeechErrorCallback onError,
    required ListeningStateCallback onListeningChanged,
  }) async => true;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> cancel() async {}
}
