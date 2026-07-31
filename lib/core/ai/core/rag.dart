// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:convert';

import 'package:kokotoba_flutter_app/core/ai/database/card_selection_history.dart';
import 'package:kokotoba_flutter_app/core/ai/database/init.dart';
import 'package:kokotoba_flutter_app/core/ai/database/long_term_memory_searcher.dart';
import 'package:kokotoba_flutter_app/core/ai/llm/llm_client.dart';
import 'package:kokotoba_flutter_app/core/ai/util/embedding.dart';

/// 質問形式を表す文字列。"yes_no"、"choice"、"open" のいずれか。
typedef QuestionType = String;

/// 長期記憶と選択履歴を利用して発話カードを生成するRAG処理。
class RAG {
  /// 質問に対して、ユーザーが選択できる短い発話カードを生成する。
  RAG(this.llm_client, this.db_manager)
    : embedding = Embedding(),
      long_term_memory_searcher = LongTermMemorySearcher(db_manager),
      card_selection_history = CardSelectionHistory(db_manager);

  static const int MAX_CARDS = 5;
  static const int MAX_CARD_LENGTH = 24;

  final LLMClient llm_client;
  final DatabaseManager db_manager;
  final Embedding embedding;
  final LongTermMemorySearcher long_term_memory_searcher;
  final CardSelectionHistory card_selection_history;

  /// 質問と文脈から、検証済みの発話カード候補を返す。
  Future<List<String>> generate_rag_response(
    String user_input,
    String user_location,
  ) async {
    final question_type = _classify_question(user_input);
    final base_cards = _base_cards(question_type, user_input);

    final expanded_query = await _query_expansion(user_input, user_location);
    final query_embedding = await embedding.embed(expanded_query);
    final long_term_memory_result = await long_term_memory_searcher.search(
      query_embedding,
      minimum_similarity: 0.84,
    );

    final interaction_embedding = await _embed_interaction(
      user_input,
      user_location,
    );
    final previously_selected_cards = await card_selection_history
        .find_relevant(interaction_embedding, user_location);

    final generated_cards = await _generate_cards_with_llm(
      user_input: user_input,
      user_location: user_location,
      question_type: question_type,
      base_cards: base_cards,
      previously_selected_cards: previously_selected_cards,
      long_term_memory_result: long_term_memory_result,
    );
    return _merge_cards(
      question_type: question_type,
      base_cards: base_cards,
      generated_cards: generated_cards,
      previously_selected_cards: previously_selected_cards,
    );
  }

  /// 実際に選択されたカードを次回の候補順位へ反映できるよう保存する。
  Future<void> record_selected_card({
    required String user_input,
    required String user_location,
    required List<String> shown_cards,
    required String selected_card,
  }) async {
    final interaction_embedding = await _embed_interaction(
      user_input,
      user_location,
    );
    await card_selection_history.record(
      question: user_input,
      location: user_location,
      shown_cards: shown_cards,
      selected_card: selected_card,
      question_embedding: interaction_embedding,
    );
  }

  /// 元の質問と場所を維持しつつ、長期記憶検索用の関連語を補う。
  Future<String> _query_expansion(
    String user_input,
    String user_location,
  ) async {
    if (user_input.trim().isEmpty) {
      throw ArgumentError('user_input must not be empty or whitespace only');
    }
    if (user_location.trim().isEmpty) {
      throw ArgumentError('user_location must not be empty or whitespace only');
    }

    final prompt =
        '''
あなたは、ユーザーの長期記憶をベクトル検索するためのクエリ拡張器です。
次の質問と現在地から、関連する過去の記録にヒットしそうな日本語の関連語を
最大5個生成してください。

<question>
$user_input
</question>

<location>
$user_location
</location>

ルール:
- 質問への回答はしない
- 現在地を特定の施設種別に決めつけない
- 行動、出来事、話題、言い換えを中心に補う
- 具体的な体験、症状、商品、人物、日時を捏造しない
- 関連語だけを半角スペース区切りで出力する
- 見出し、番号、説明、引用符、句読点、改行は出力しない
'''
            .trim();

    final expanded_terms = (await llm_client.generate(
      prompt,
    )).trim().split(RegExp(r'\s+')).join(' ');
    final query_parts = [user_input.trim(), user_location.trim()];
    if (expanded_terms.isNotEmpty) {
      query_parts.add(expanded_terms);
    }
    return query_parts.join(' ');
  }

  /// LLMにJSON形式の追加候補を生成させ、検証して返す。
  Future<List<String>> _generate_cards_with_llm({
    required String user_input,
    required String user_location,
    required QuestionType question_type,
    required List<String> base_cards,
    required List<String> previously_selected_cards,
    required String long_term_memory_result,
  }) async {
    final prompt =
        '''
あなたは、発語障害のあるユーザー向けの発話カードを作る支援者です。
ユーザーがボタンを押すだけで相手の質問へ答えられるように、短く直接的な
一人称の回答候補を作ってください。

<question>
$user_input
</question>

<location>
$user_location
</location>

<question_type>
$question_type
</question_type>

<excluded_base_cards>
${jsonEncode(base_cards)}
</excluded_base_cards>

<previously_selected_cards>
${jsonEncode(previously_selected_cards)}
</previously_selected_cards>

<long_term_memory>
${long_term_memory_result.isEmpty ? "関連度が十分な長期記憶なし" : long_term_memory_result}
</long_term_memory>

ルール:
- excluded_base_cardsは別処理で追加するため、絶対に出力しない
- excluded_base_cardsより具体的で、状況に合った追加候補だけを1〜3個作る
- 過去に同様の状況で選ばれたカードは有力候補として扱う
- 長期記憶は参考情報であり、現在も同じ状態だと断定しない
- 関連度が十分な長期記憶に症状、希望、行動が含まれる場合は、その内容を
  ユーザーが選べる候補として1〜2個追加してよい
- 長期記憶と無関係な症状、希望、体験、商品などを捏造しない
- 医療診断や確定していない事実を作らない
- 関連する長期記憶も具体的な追加候補もない場合はcardsを空配列にする
- 各候補は24文字以内にする
- 説明、Markdown、コードフェンスは出力しない
- 必ず次のJSON形式だけを出力する

{"cards":["候補1","候補2","候補3"]}
'''
            .trim();

    final response = await llm_client.generate(prompt);
    final cards = _parse_cards_json(response);
    return _filter_generated_cards(
      cards,
      question_type: question_type,
      user_input: user_input,
    );
  }

  /// 質問文をルールベースで回答形式に分類する。
  QuestionType _classify_question(String user_input) {
    final normalized = user_input.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('user_input must not be empty or whitespace only');
    }

    const choice_markers = ['どちら', 'どっち', 'どれ', 'それとも', 'または'];
    if (choice_markers.any(normalized.contains)) {
      return 'choice';
    }

    const open_markers = [
      'どう',
      'いかが',
      '何',
      'なに',
      'いつ',
      'どこ',
      '誰',
      'だれ',
      'なぜ',
      'どの',
    ];
    if (open_markers.any(normalized.contains)) {
      return 'open';
    }

    if (['?', '？', 'か', 'か。'].any(normalized.endsWith)) {
      return 'yes_no';
    }
    return 'open';
  }

  /// 質問形式ごとに、必ず利用できる安全な基本候補を返す。
  List<String> _base_cards(QuestionType question_type, String user_input) {
    if (question_type == 'yes_no') {
      if (user_input.contains('温め') || user_input.contains('あたため')) {
        return ['はいお願いします', 'いいえそのままで', '少しだけお願いします', 'もう一度お願いします'];
      }
      if (user_input.contains('袋')) {
        return ['はいお願いします', 'いいえ大丈夫です', '袋を分けてください', 'もう一度お願いします'];
      }
      return ['はいお願いします', 'いいえ大丈夫です', 'わかりません', 'もう一度お願いします'];
    }

    if (question_type == 'choice') {
      return ['最初のもの', '次のもの', 'どちらでもいいです', 'もう一度お願いします'];
    }

    if (user_input.contains('体調') || user_input.contains('具合')) {
      return ['元気です', '少し具合が悪いです', 'わかりません', 'うまく説明できません'];
    }
    return ['わかりません', 'うまく説明できません', 'もう一度お願いします'];
  }

  /// LLMレスポンスからJSONを抽出し、安全なカード文字列だけを返す。
  List<String> _parse_cards_json(String response) {
    final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(response);
    if (match == null) {
      return [];
    }

    Object? payload;
    try {
      payload = jsonDecode(match.group(0)!);
    } on FormatException {
      return [];
    }

    final raw_cards = payload is Map<String, Object?> ? payload['cards'] : null;
    if (raw_cards is! List<Object?>) {
      return [];
    }

    final cards = <String>[];
    final unsafe_characters = RegExp(r'''[\s、。,．・:："\'`「」『』【】\[\]]+''');
    for (final value in raw_cards) {
      if (value is! String) {
        continue;
      }
      final card = value.replaceAll(unsafe_characters, '');
      if (card.isEmpty || card.length > MAX_CARD_LENGTH) {
        continue;
      }
      if (!cards.contains(card)) {
        cards.add(card);
      }
    }
    return cards.take(MAX_CARDS).toList();
  }

  /// 履歴・固定候補・LLM候補を優先順位付きで統合する。
  List<String> _merge_cards({
    required QuestionType question_type,
    required List<String> base_cards,
    required List<String> generated_cards,
    required List<String> previously_selected_cards,
  }) {
    final List<String> ordered_cards;
    if (question_type == 'yes_no') {
      ordered_cards = [
        ...previously_selected_cards,
        ...base_cards.take(3),
        ...generated_cards,
        ...base_cards.skip(3),
      ];
    } else {
      ordered_cards = [
        ...previously_selected_cards,
        ...generated_cards,
        ...base_cards,
      ];
    }

    final cards = <String>[];
    for (final card in ordered_cards) {
      final normalized = card.replaceAll(RegExp(r'\s+'), '');
      if (normalized.isEmpty || normalized.length > MAX_CARD_LENGTH) {
        continue;
      }
      if (!cards.contains(normalized)) {
        cards.add(normalized);
      }
      if (cards.length == MAX_CARDS) {
        break;
      }
    }
    return cards;
  }

  /// 質問へ直接答えていない過去形の候補などを除外する。
  static List<String> _filter_generated_cards(
    List<String> cards, {
    required QuestionType question_type,
    required String user_input,
  }) {
    if (question_type == 'yes_no') {
      const generic_yes_no_cards = {
        'はい',
        'いいえ',
        'はいお願いします',
        'いいえ大丈夫です',
        '大丈夫です',
        '結構です',
      };
      cards = cards
          .where((card) => !generic_yes_no_cards.contains(card))
          .toList();
    }

    if (question_type == 'open' &&
        (user_input.contains('体調') || user_input.contains('具合'))) {
      const past_action_markers = ['ました', 'だった', '行った', 'もらった', '言われた'];
      return cards
          .where((card) => !past_action_markers.any(card.contains))
          .toList();
    }
    return cards;
  }

  /// 質問と場所をカード選択履歴検索用のベクトルへ変換する。
  Future<List<double>> _embed_interaction(
    String user_input,
    String user_location,
  ) {
    return embedding.embed(
      '質問: ${user_input.trim()} 場所: ${user_location.trim()}',
    );
  }
}
