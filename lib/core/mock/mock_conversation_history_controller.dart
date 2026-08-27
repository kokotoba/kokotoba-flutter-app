import 'package:kokotoba_flutter_app/core/controller/conversation_history_controller.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_history.dart';

class MockConversationHistoryController
    implements ConversationHistoryController {
  const MockConversationHistoryController();

  @override
  Future<List<ConversationHistory>> fetchConversationHistories() async {
    return [
      ConversationHistory(
        id: 1,
        startedAt: _startedAt,
        active: false,
        utterances: [
          ConversationUtterance(
            id: 1,
            speaker: ConversationSpeaker.partner,
            text: '今日は体調はいかがですか？',
            spokenAt: _startedAt,
          ),
          ConversationUtterance(
            id: 2,
            speaker: ConversationSpeaker.user,
            text: '昨日から頭が痛いです',
            spokenAt: _answeredAt,
          ),
        ],
      ),
    ];
  }

  @override
  Future<ConversationHistory> startOrResumeSession() async {
    return ConversationHistory(
      id: 1,
      startedAt: _startedAt,
      active: true,
      utterances: [],
    );
  }

  @override
  Future<ConversationUtterance> addUtterance({
    required int sessionId,
    required ConversationSpeaker speaker,
    required String text,
  }) async {
    return ConversationUtterance(
      id: 1,
      speaker: speaker,
      text: text,
      spokenAt: _answeredAt,
    );
  }

  @override
  Future<void> endSession(int sessionId) async {}
}

final _startedAt = DateTime.utc(2026, 8, 28, 10, 42);
final _answeredAt = DateTime.utc(2026, 8, 28, 10, 43);
