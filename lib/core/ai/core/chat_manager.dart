// ignore_for_file: non_constant_identifier_names, unused_element

import 'package:kokotoba_flutter_app/core/ai/core/rag.dart';
import 'package:kokotoba_flutter_app/core/ai/database/init.dart';
import 'package:kokotoba_flutter_app/core/ai/llm/llm_client.dart';
import 'package:kokotoba_flutter_app/core/ai/memory/memory_consolidator.dart';

class ChatManager {
  ChatManager(this.db_manager, LLMClient llm_client)
    : memory_consolidator = MemoryConsolidator(db_manager),
      rag = RAG(llm_client, db_manager);

  final DatabaseManager db_manager;
  final MemoryConsolidator memory_consolidator;
  final RAG rag;

  Future<List<String>> handle_user_input(
    String user_input,
    String user_location_input,
  ) async {
    // 短期記憶に会話内容を保存
    memory_consolidator.record_short_term_memory(
      ShortTermMemoryRecord(
        conversation_text: user_input,
        timestamp: DateTime.now(),
        location: Location(
          latitude: 0.0,
          longitude: 0.0,
          place_name: user_location_input,
        ),
        speaker: 'user',
      ),
    );

    return rag.generate_rag_response(user_input, user_location_input);
  }

  /// ユーザーが実際に選んだカードを記録する。
  Future<void> record_selected_card({
    required String user_input,
    required String user_location_input,
    required List<String> shown_cards,
    required String selected_card,
  }) {
    return rag.record_selected_card(
      user_input: user_input,
      user_location: user_location_input,
      shown_cards: shown_cards,
      selected_card: selected_card,
    );
  }

  void finish_session() {}

  String _build_card(String user_input, String user_location_input) {
    return '$user_input / $user_location_input';
  }
}
