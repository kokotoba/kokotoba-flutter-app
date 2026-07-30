import 'package:kokotoba_flutter_app/core/model/conversation_history.dart';
import 'package:kokotoba_flutter_app/core/repository/conversation_history_repository.dart';

class MockConversationHistoryRepository
    implements ConversationHistoryRepository {
  const MockConversationHistoryRepository();

  @override
  Future<List<ConversationHistory>> fetchConversationHistories() async {
    return const [
      ConversationHistory(
        time: '今日  10:42',
        place: '近くのクリニック',
        summary: '体調と症状について話しました',
        phrase: '「昨日から頭が痛いです」',
      ),
      ConversationHistory(
        time: '7月21日  16:18',
        place: '場所は保存されていません',
        summary: '予定の時間について確認しました',
        phrase: '「14時でお願いします」',
      ),
      ConversationHistory(
        time: '7月18日  12:05',
        place: '場所は保存されていません',
        summary: '昼食について話しました',
        phrase: '「同じものをお願いします」',
      ),
    ];
  }
}
