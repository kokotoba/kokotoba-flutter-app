// ignore_for_file: non_constant_identifier_names

import 'package:kokotoba_flutter_app/core/ai/database/init.dart';

class Location {
  const Location({
    required this.latitude,
    required this.longitude,
    required this.place_name,
  });

  final double latitude;
  final double longitude;
  final String place_name;
}

class ShortTermMemoryRecord {
  const ShortTermMemoryRecord({
    required this.conversation_text,
    required this.timestamp,
    required this.location,
    required this.speaker,
  });

  final String conversation_text;
  final DateTime timestamp;
  final Location? location;
  final String speaker;
}

class MemoryConsolidator {
  MemoryConsolidator(this.db_manager);

  final DatabaseManager db_manager;

  // セッションごとに終了するので短期記憶はテスト段階では、メモリに保存する
  final List<ShortTermMemoryRecord> short_term_memory = [];

  void record_short_term_memory(ShortTermMemoryRecord record) {
    short_term_memory.add(record);
  }
}
