// ignore_for_file: constant_identifier_names, non_constant_identifier_names
// ignore_for_file: prefer_initializing_formals

import 'package:flutter_gemma/flutter_gemma.dart';

/// アプリケーション内で共通利用するテキストEmbedding処理。
class Embedding {
  /// 入力文字列をmultilingual-e5-smallでEmbeddingする汎用クラス。
  Embedding({
    String model_id = DEFAULT_MODEL_ID,
    String model_path = DEFAULT_MODEL_PATH,
  }) : _model_id = model_id,
       _model_path = model_path;

  static const String DEFAULT_MODEL_ID = 'intfloat/multilingual-e5-small';
  static const String DEFAULT_MODEL_PATH =
      'models/sentence-transformers/multilingual-e5-small';

  final String _model_id;
  final String _model_path;
  EmbeddingModel? _model;

  /// 1件の文字列をfloat32のEmbeddingベクトルへ変換する。
  Future<List<double>> embed(String text) async {
    if (text.trim().isEmpty) {
      throw ArgumentError('text must not be empty or whitespace only');
    }

    final model = await _get_model();
    return model.generateEmbedding(text, taskType: TaskType.retrievalQuery);
  }

  /// モデルをインスタンス内で一度だけ読み込む。
  Future<EmbeddingModel> _get_model() async {
    _model ??= await _load_model();
    return _model!;
  }

  /// モデルを初回だけ取得し、以降はローカルから読み込む。
  Future<EmbeddingModel> _load_model() async {
    if (!FlutterGemma.hasActiveEmbedder()) {
      throw StateError(
        'Embedding model is not installed: $_model_id ($_model_path). '
        'Install a LiteRT-compatible embedding model before calling embed().',
      );
    }
    return FlutterGemma.getActiveEmbedder(
      preferredBackend: PreferredBackend.cpu,
    );
  }
}
