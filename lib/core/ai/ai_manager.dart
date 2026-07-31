// ignore_for_file: non_constant_identifier_names

import 'package:kokotoba_flutter_app/core/ai/core/chat_manager.dart';
import 'package:kokotoba_flutter_app/core/ai/database/init.dart';
import 'package:kokotoba_flutter_app/core/ai/llm/litert_lm_client.dart';
import 'package:kokotoba_flutter_app/core/ai/llm/llm_client.dart';
import 'package:kokotoba_flutter_app/core/ai/util/embedding.dart';

/// AI機能を利用するために必要なクラスの生成と破棄をまとめる。
class AIManager {
  const AIManager._({
    required this.db_manager,
    required this.llm_manager,
    required this.chat_manager,
    required this.embedding,
  });

  final DatabaseManager db_manager;
  final LLMClient llm_manager;
  final ChatManager chat_manager;
  final Embedding embedding;

  /// DatabaseManager、LLMClient、Embedding、ChatManagerを利用可能な状態にする。
  static Future<AIManager> initialize({
    String model_path = 'models/gemma-4-E2B-it.litertlm',
    String embedding_model_path = Embedding.DEFAULT_MODEL_PATH,
    String? embedding_tokenizer_path,
  }) async {
    final db_manager = DatabaseManager();
    final LLMClient llm_manager = LiteRTLMClient(model_path);
    Embedding? embedding;

    try {
      await db_manager.initialize();
      await llm_manager.start();
      final chat_manager = ChatManager(db_manager, llm_manager);
      embedding = chat_manager.rag.embedding;
      if (embedding_model_path != Embedding.DEFAULT_MODEL_PATH) {
        embedding = Embedding(model_path: embedding_model_path);
      }
      await embedding.start(tokenizer_path: embedding_tokenizer_path);

      return AIManager._(
        db_manager: db_manager,
        llm_manager: llm_manager,
        chat_manager: chat_manager,
        embedding: embedding,
      );
    } on Object {
      try {
        await embedding?.close();
      } finally {
        try {
          await llm_manager.close();
        } finally {
          await db_manager.close();
        }
      }
      rethrow;
    }
  }

  /// LLM、Embedding、データベースが保持するリソースを解放する。
  Future<void> close() async {
    try {
      await embedding.close();
    } finally {
      try {
        await llm_manager.close();
      } finally {
        await db_manager.close();
      }
    }
  }
}
