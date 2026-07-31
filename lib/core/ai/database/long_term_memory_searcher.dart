// ignore_for_file: non_constant_identifier_names

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:kokotoba_flutter_app/core/ai/database/init.dart';

/// 長期記憶のベクトル検索処理。
class LongTermMemorySearcher {
  /// DatabaseManagerを利用して長期記憶を類似度検索する。
  LongTermMemorySearcher(this._db_manager);

  final DatabaseManager _db_manager;

  /// 長期記憶をコサイン類似度で検索し、上位結果を文字列で返す。
  Future<String> search(
    List<double> query_embedding, {
    int limit = 3,
    double minimum_similarity = 0.80,
  }) async {
    if (limit <= 0) {
      throw ArgumentError('limit must be greater than zero');
    }
    if (minimum_similarity < -1.0 || minimum_similarity > 1.0) {
      throw ArgumentError('minimum_similarity must be between -1.0 and 1.0');
    }
    if (query_embedding.isEmpty) {
      throw ArgumentError('query_embedding must be a non-empty 1D vector');
    }

    final query_vector = query_embedding;
    final query_norm = _norm(query_vector);
    if (query_norm == 0.0) {
      throw ArgumentError('query_embedding must not be a zero vector');
    }

    final conn = await _db_manager.connect();
    final rows = await conn.query(
      'long_term_memory',
      columns: [
        'id',
        'summary',
        'source_text',
        'embedding',
        'place_name',
        'speaker',
        'event_time',
      ],
      where: 'embedding IS NOT NULL',
    );

    final scored_rows = <({double similarity, Map<String, Object?> row})>[];
    for (final row in rows) {
      final memory_vector = _from_float32_bytes(row['embedding']! as Uint8List);
      if (memory_vector.length != query_vector.length) {
        continue;
      }

      final memory_norm = _norm(memory_vector);
      if (memory_norm == 0.0) {
        continue;
      }

      final similarity =
          _dot(query_vector, memory_vector) / (query_norm * memory_norm);
      if (similarity < minimum_similarity) {
        continue;
      }
      scored_rows.add((similarity: similarity, row: row));
    }

    scored_rows.sort(
      (first, second) => second.similarity.compareTo(first.similarity),
    );
    final top_rows = <({double similarity, Map<String, Object?> row})>[];
    final seen_source_texts = <String>{};
    for (final item in scored_rows) {
      final source_text = item.row['source_text']! as String;
      if (seen_source_texts.contains(source_text)) {
        continue;
      }
      seen_source_texts.add(source_text);
      top_rows.add(item);
      if (top_rows.length == limit) {
        break;
      }
    }

    if (top_rows.isEmpty) {
      return '';
    }

    final results = <String>[];
    for (var index = 0; index < top_rows.length; index++) {
      final item = top_rows[index];
      final row = item.row;
      final details = <String>[
        '検索結果${index + 1}（類似度: ${item.similarity.toStringAsFixed(4)}）',
        '要約: ${row['summary']}',
        '内容: ${row['source_text']}',
      ];
      if (row['place_name'] != null && row['place_name'] != '') {
        details.add('場所: ${row['place_name']}');
      }
      if (row['speaker'] != null && row['speaker'] != '') {
        details.add('話者: ${row['speaker']}');
      }
      if (row['event_time'] != null && row['event_time'] != '') {
        details.add('日時: ${row['event_time']}');
      }
      results.add(details.join('\n'));
    }

    return results.join('\n\n');
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
