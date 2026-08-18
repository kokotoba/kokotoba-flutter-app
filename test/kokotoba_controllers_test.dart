import 'package:flutter_test/flutter_test.dart';
import 'package:kokotoba_flutter_app/core/api/api_registered_card_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/kokotoba_controllers.dart';
import 'package:kokotoba_flutter_app/core/device/device_speech_recognition_controller.dart';

void main() {
  test('live構成はよく使う文章に実API Controllerを使う', () {
    final controllers = KokotobaControllers.live();

    expect(
      controllers.registeredCardController,
      isA<ApiRegisteredCardController>(),
    );
    expect(
      controllers.speechRecognitionController,
      isA<DeviceSpeechRecognitionController>(),
    );
  });
}
