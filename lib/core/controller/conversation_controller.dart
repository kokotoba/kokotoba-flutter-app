import 'package:kokotoba_flutter_app/core/model/conversation_result.dart';

enum SuggestionMode {
  fast('fast'),
  quality('quality');

  const SuggestionMode(this.apiValue);

  final String apiValue;
}

abstract interface class ConversationController {
  Future<ConversationResult> fetchConversationResult({
    String question = '',
    SuggestionMode mode = SuggestionMode.fast,
  });

  Future<void> selectCard({
    required String suggestionId,
    required String cardId,
  });
}
