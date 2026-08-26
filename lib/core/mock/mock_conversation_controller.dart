import 'package:kokotoba_flutter_app/core/controller/conversation_controller.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_result.dart';

class MockConversationController implements ConversationController {
  const MockConversationController();

  @override
  Future<ConversationResult> fetchConversationResult(String question) async {
    return ConversationResult(
      recognizedText: question.isEmpty ? '今日は体調はいかがですか？' : question,
      suggestionId: 'mock-suggestion-1',
      questionType: 'open',
      suggestions: const [
        ConversationSuggestion(
          id: 'mock-card-1',
          text: '昨日から頭が痛いです',
          reason: '直前の会話を参考',
          recommended: true,
        ),
        ConversationSuggestion(
          id: 'mock-card-2',
          text: '前回より少し良くなりました',
          reason: '以前の会話を参考',
        ),
        ConversationSuggestion(
          id: 'mock-card-3',
          text: '少し考える時間をください',
          reason: '過去によく使用',
        ),
      ],
      quickPhrases: const ['うまく話せません', '少し待ってください', '文字で伝えます'],
    );
  }

  @override
  Future<void> selectCard({
    required String suggestionId,
    required String cardId,
  }) async {}
}
