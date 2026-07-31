/// LLM 実装に共通するインターフェース。
abstract class LLMClient {
  /// モデルを読み込み、推論可能な状態にする。
  Future<void> start();

  /// プロンプトからテキストを生成して返す。
  Future<String> generate(String prompt);

  /// モデルおよび会話に関連するリソースを解放する。
  Future<void> close();
}
