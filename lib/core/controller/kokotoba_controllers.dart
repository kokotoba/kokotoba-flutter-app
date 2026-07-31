import 'package:kokotoba_flutter_app/core/controller/conversation_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/conversation_history_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/registered_card_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/settings_controller.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_conversation_controller.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_conversation_history_controller.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_registered_card_controller.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_settings_controller.dart';

class KokotobaControllers {
  const KokotobaControllers({
    required this.conversationController,
    required this.registeredCardController,
    required this.conversationHistoryController,
    required this.settingsController,
  });

  const KokotobaControllers.mock()
    : conversationController = const MockConversationController(),
      registeredCardController = const MockRegisteredCardController(),
      conversationHistoryController = const MockConversationHistoryController(),
      settingsController = const MockSettingsController();

  final ConversationController conversationController;
  final RegisteredCardController registeredCardController;
  final ConversationHistoryController conversationHistoryController;
  final SettingsController settingsController;
}
