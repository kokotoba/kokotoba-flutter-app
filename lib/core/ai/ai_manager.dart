// ignore_for_file: non_constant_identifier_names

import 'package:kokotoba_flutter_app/core/ai/core/chat_manager.dart';
import 'package:kokotoba_flutter_app/core/ai/database/init.dart';
import 'package:kokotoba_flutter_app/core/ai/llm/litert_lm_client.dart';
import 'package:kokotoba_flutter_app/core/ai/llm/llm_client.dart';

/// AI機能を利用するために必要なクラスの生成と破棄をまとめる。
class AIManager {
  const AIManager._({
    required this.db_manager,
    required this.llm_manager,
    required this.chat_manager,
  });

  final DatabaseManager db_manager;
  final LLMClient llm_manager;
  final ChatManager chat_manager;

  /// DatabaseManager、LLMClient、ChatManagerを利用可能な状態にする。
  static Future<AIManager> initialize({
    String model_path = 'models/gemma-4-E2B-it.litertlm',
  }) async {
    final db_manager = DatabaseManager();
    final LLMClient llm_manager = LiteRTLMClient(model_path);

    try {
      await db_manager.initialize();
      await llm_manager.start();
      final chat_manager = ChatManager(db_manager, llm_manager);

      return AIManager._(
        db_manager: db_manager,
        llm_manager: llm_manager,
        chat_manager: chat_manager,
      );
    } on Object {
      await llm_manager.close();
      rethrow;
    }
  }

  /// LLMとデータベースが保持するリソースを解放する。
  Future<void> close() async {
    try {
      await llm_manager.close();
    } finally {
      await db_manager.close();
    }
  }
}
