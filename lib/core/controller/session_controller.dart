import 'package:kokotoba_flutter_app/core/model/conversation_session.dart';

abstract interface class SessionController {
  Future<ConversationSession> startOrResumeSession();

  Future<void> endSession(String sessionId);

  Future<void> recordUtterance(String sessionId, Utterance utterance);

  Future<List<ConversationSession>> fetchSessions();
}