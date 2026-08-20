import 'package:kokotoba_flutter_app/core/model/conversation_result.dart';

abstract interface class ConversationController {
  Future<ConversationResult> fetchConversationResult(String question);
}