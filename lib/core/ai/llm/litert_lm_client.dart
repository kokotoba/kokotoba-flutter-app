// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_embeddings/flutter_gemma_embeddings.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:kokotoba_flutter_app/core/ai/llm/llm_client.dart';

/// LiteRT-LM を利用する LLMClient の具象実装。
class LiteRTLMClient implements LLMClient {
  /// モデルファイルのパスを保持する。読み込みは start() で行う。
  LiteRTLMClient(String model_path) : _model_path = model_path;

  final String _model_path;
  InferenceModel? _engine;
  InferenceModelSession? _conversation;

  /// CPU のデフォルト設定でモデルと Conversation を初期化する。
  @override
  Future<void> start() async {
    if (_engine != null && _conversation != null) {
      return;
    }

    FlutterGemma.logLevel = GemmaLogLevel.none;

    if (_engine != null || _conversation != null) {
      await close();
    }

    if (!await File(_model_path).exists()) {
      throw ArgumentError('LiteRT-LM model file was not found: $_model_path');
    }

    try {
      await FlutterGemma.initialize(
        inferenceEngines: const [LiteRtLmEngine()],
        embeddingBackends: const [LiteRtEmbeddingBackend()],
      );
      await FlutterGemma.installModel(
        modelType: ModelType.gemma4,
        fileType: ModelFileType.task,
      ).fromFile(_model_path).install();
      _engine = await FlutterGemma.getActiveModel(
        preferredBackend: PreferredBackend.cpu,
        maxTokens: 4096,
      );
      _conversation = await _engine!.createSession();
    } on Object {
      await close();
      rethrow;
    }
  }

  /// 独立したConversationで同期生成し、テキストだけを返す。
  @override
  Future<String> generate(String prompt) async {
    if (prompt.trim().isEmpty) {
      throw ArgumentError('prompt must not be empty or whitespace only');
    }

    _ensure_started();
    final conversation = _conversation!;
    try {
      await conversation.addQueryChunk(
        Message.text(text: prompt, isUser: true),
      );
      final response = await conversation.getResponse();
      return _extract_text(response);
    } finally {
      await _close_resource(conversation);
      _conversation = null;
      if (_engine != null) {
        _conversation = await _engine!.createSession();
      }
    }
  }

  /// Conversation、Engine の順にリソースを安全に解放する。
  @override
  Future<void> close() async {
    final conversation = _conversation;
    final engine = _engine;
    _conversation = null;
    _engine = null;

    try {
      await _close_resource(conversation);
    } finally {
      await _close_resource(engine);
    }
  }

  /// start() が正常に完了していることを確認する。
  void _ensure_started() {
    if (_engine == null || _conversation == null) {
      throw StateError(
        'LiteRTLMClient is not started. Call start() before generate().',
      );
    }
  }

  /// close() を持つリソースだけを解放する。
  static Future<void> _close_resource(Object? resource) async {
    if (resource is InferenceModelSession) {
      await resource.close();
    } else if (resource is InferenceModel) {
      await resource.close();
    }
  }

  /// LiteRT-LM のレスポンスからテキスト要素だけを抽出する。
  static String _extract_text(Object? response) {
    if (response is String) {
      return response;
    }

    if (response is Map<Object?, Object?>) {
      final direct_text = response['text'];
      if (direct_text is String) {
        return direct_text;
      }

      final content = response['content'];
      if (content is String) {
        return content;
      }
      if (content is Iterable<Object?>) {
        final text_parts = <String>[];
        for (final item in content) {
          if (item is String) {
            text_parts.add(item);
          } else if (item is Map<Object?, Object?>) {
            final text = item['text'];
            final item_type = item['type'];
            if (text is String && (item_type == null || item_type == 'text')) {
              text_parts.add(text);
            }
          }
        }
        if (text_parts.isNotEmpty) {
          return text_parts.join();
        }
      }
    }

    throw ArgumentError(
      'Could not extract text from the LiteRT-LM response. '
      'Unsupported response type: ${response.runtimeType}',
    );
  }
}
