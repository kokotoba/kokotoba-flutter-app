// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:kokotoba_flutter_app/core/ai/database/init.dart';

/// ユーザーが実際に選択した発話カードの保存と検索。
class CardSelectionHistory {
  /// 質問と場所に対して選ばれたカードを永続化して再利用する。
  CardSelectionHistory(this._db_manager)
    : _initialization = _initialize(_db_manager);

  final DatabaseManager _db_manager;
  final Future<void> _initialization;

  /// ユーザーが選択したカードと、そのときの文脈を保存する。
  Future<void> record({
    required String question,
    required String location,
    required List<String> shown_cards,
    required String selected_card,
    required List<double> question_embedding,
  }) async {
    if (question.trim().isEmpty) {
      throw ArgumentError('question must not be empty or whitespace only');
    }
    if (location.trim().isEmpty) {
      throw ArgumentError('location must not be empty or whitespace only');
    }
    if (!shown_cards.contains(selected_card)) {
      throw ArgumentError('selected_card must be included in shown_cards');
    }

    final embedding = _validate_embedding(question_embedding);
    await _initialization;
    final conn = await _db_manager.connect();
    await conn.insert('card_selection_history', {
      'question': question,
      'location': location,
      'shown_cards': jsonEncode(shown_cards),
      'selected_card': selected_card,
      'question_embedding': _to_float32_bytes(embedding),
      'selected_at': DateTime.now().toIso8601String(),
    });
  }

  /// 現在の質問に近い履歴から、過去に選ばれたカードを返す。
  Future<List<String>> find_relevant(
    List<double> question_embedding,
    String location, {
    int limit = 3,
    double minimum_similarity = 0.85,
  }) async {
    if (limit <= 0) {
      throw ArgumentError('limit must be greater than zero');
    }
    if (minimum_similarity < -1.0 || minimum_similarity > 1.0) {
      throw ArgumentError('minimum_similarity must be between -1.0 and 1.0');
    }

    final query_vector = _validate_embedding(question_embedding);
    final query_norm = _norm(query_vector);
    if (query_norm == 0.0) {
      throw ArgumentError('question_embedding must not be a zero vector');
    }

    await _initialization;
    final conn = await _db_manager.connect();
    final rows = await conn.query(
      'card_selection_history',
      columns: [
        'location',
        'selected_card',
        'question_embedding',
        'selected_at',
      ],
      where: 'question_embedding IS NOT NULL',
      orderBy: 'selected_at DESC',
    );

    final scored_rows =
        <({bool same_location, double similarity, Map<String, Object?> row})>[];
    for (final row in rows) {
      final history_vector = _from_float32_bytes(
        row['question_embedding']! as Uint8List,
      );
      if (history_vector.length != query_vector.length) {
        continue;
      }

      final history_norm = _norm(history_vector);
      if (history_norm == 0.0) {
        continue;
      }

      final similarity =
          _dot(query_vector, history_vector) / (query_norm * history_norm);
      if (similarity < minimum_similarity) {
        continue;
      }

      final same_location =
          (row['location']! as String).trim() == location.trim();
      scored_rows.add((
        same_location: same_location,
        similarity: similarity,
        row: row,
      ));
    }

    scored_rows.sort((first, second) {
      final location_order =
          (second.same_location ? 1 : 0) - (first.same_location ? 1 : 0);
      if (location_order != 0) {
        return location_order;
      }
      return second.similarity.compareTo(first.similarity);
    });

    final selected_cards = <String>[];
    for (final item in scored_rows) {
      final card = item.row['selected_card']! as String;
      if (!selected_cards.contains(card)) {
        selected_cards.add(card);
      }
      if (selected_cards.length == limit) {
        break;
      }
    }
    return selected_cards;
  }

  /// カード選択履歴テーブルを作成する。
  static Future<void> _initialize(DatabaseManager db_manager) async {
    final conn = await db_manager.connect();
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS card_selection_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        location TEXT NOT NULL,
        shown_cards TEXT NOT NULL,
        selected_card TEXT NOT NULL,
        question_embedding BLOB NOT NULL,
        selected_at DATETIME NOT NULL
      )
    ''');
  }

  static List<double> _validate_embedding(List<double> embedding) {
    if (embedding.isEmpty) {
      throw ArgumentError('embedding must be a non-empty 1D vector');
    }
    return embedding;
  }

  static Uint8List _to_float32_bytes(List<double> values) {
    final result = Float32List.fromList(values);
    return result.buffer.asUint8List();
  }

  static List<double> _from_float32_bytes(Uint8List bytes) {
    return Float32List.view(
      bytes.buffer,
      bytes.offsetInBytes,
      bytes.lengthInBytes ~/ Float32List.bytesPerElement,
    ).toList();
  }

  static double _dot(List<double> first, List<double> second) {
    var result = 0.0;
    for (var index = 0; index < first.length; index++) {
      result += first[index] * second[index];
    }
    return result;
  }

  static double _norm(List<double> vector) {
    return math.sqrt(_dot(vector, vector));
  }
}
