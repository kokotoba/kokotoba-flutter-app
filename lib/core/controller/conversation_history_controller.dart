import 'package:kokotoba_flutter_app/core/model/conversation_history.dart';

abstract interface class ConversationHistoryController {
  Future<List<ConversationHistory>> fetchConversationHistories();

  Future<ConversationHistory> startOrResumeSession();

  Future<ConversationUtterance> addUtterance({
    required int sessionId,
    required ConversationSpeaker speaker,
    required String text,
  });

  Future<void> endSession(int sessionId);
}
