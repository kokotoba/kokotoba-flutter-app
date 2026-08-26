import 'package:kokotoba_flutter_app/core/api/api_registered_card_controller.dart';
import 'package:kokotoba_flutter_app/core/api/api_settings_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/conversation_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/conversation_history_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/registered_card_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/settings_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/speech_recognition_controller.dart';
import 'package:kokotoba_flutter_app/core/device/device_speech_recognition_controller.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_conversation_controller.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_conversation_history_controller.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_registered_card_controller.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_settings_controller.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_speech_recognition_controller.dart';

class KokotobaControllers {
  const KokotobaControllers({
    required this.conversationController,
    required this.speechRecognitionController,
    required this.registeredCardController,
    required this.conversationHistoryController,
    required this.settingsController,
  });

  const KokotobaControllers.mock()
    : conversationController = const MockConversationController(),
      speechRecognitionController = const MockSpeechRecognitionController(),
      registeredCardController = const MockRegisteredCardController(),
      conversationHistoryController = const MockConversationHistoryController(),
      settingsController = const MockSettingsController();

  factory KokotobaControllers.live({
    String apiBaseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    ),
  }) {
    return KokotobaControllers(
      conversationController: const MockConversationController(),
      speechRecognitionController: DeviceSpeechRecognitionController(),
      registeredCardController: ApiRegisteredCardController(
        baseUrl: apiBaseUrl,
      ),
      conversationHistoryController: const MockConversationHistoryController(),
      settingsController: ApiSettingsController(baseUrl: apiBaseUrl),
    );
  }

  final ConversationController conversationController;
  final SpeechRecognitionController speechRecognitionController;
  final RegisteredCardController registeredCardController;
  final ConversationHistoryController conversationHistoryController;
  final SettingsController settingsController;
}
