import 'package:kokotoba_flutter_app/core/controller/conversation_controller.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_result.dart';

class MockConversationController implements ConversationController {
  const MockConversationController();

  @override
  Future<ConversationResult> fetchConversationResult() async {
    return const ConversationResult(
      recognizedText: '今日は体調はいかがですか？',
      suggestions: [
        ConversationSuggestion(
          text: '昨日から頭が痛いです',
          reason: '直前の会話を参考',
          recommended: true,
        ),
        ConversationSuggestion(text: '前回より少し良くなりました', reason: '以前の会話を参考'),
        ConversationSuggestion(text: '少し考える時間をください', reason: '過去によく使用'),
      ],
      quickPhrases: ['うまく話せません', '少し待ってください', '文字で伝えます'],
    );
  }
}
