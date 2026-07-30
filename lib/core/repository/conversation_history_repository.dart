import 'package:kokotoba_flutter_app/core/model/conversation_history.dart';

abstract interface class ConversationHistoryRepository {
  Future<List<ConversationHistory>> fetchConversationHistories();
}
