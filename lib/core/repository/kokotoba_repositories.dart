import 'package:kokotoba_flutter_app/core/mock/mock_conversation_history_repository.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_registered_card_repository.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_settings_repository.dart';
import 'package:kokotoba_flutter_app/core/repository/conversation_history_repository.dart';
import 'package:kokotoba_flutter_app/core/repository/registered_card_repository.dart';
import 'package:kokotoba_flutter_app/core/repository/settings_repository.dart';

class KokotobaRepositories {
  const KokotobaRepositories({
    required this.registeredCardRepository,
    required this.conversationHistoryRepository,
    required this.settingsRepository,
  });

  const KokotobaRepositories.mock()
    : registeredCardRepository = const MockRegisteredCardRepository(),
      conversationHistoryRepository = const MockConversationHistoryRepository(),
      settingsRepository = const MockSettingsRepository();

  final RegisteredCardRepository registeredCardRepository;
  final ConversationHistoryRepository conversationHistoryRepository;
  final SettingsRepository settingsRepository;
}
