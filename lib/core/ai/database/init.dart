// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:typed_data';

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path/path.dart' as path_util;
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  static const String EMBEDDING_MODEL_ID = 'intfloat/multilingual-e5-small';
  static const String EMBEDDING_MODEL_PATH =
      'models/sentence-transformers/multilingual-e5-small';

  DatabaseManager();

  String path = 'data/app.sqlite3';
  Database? _database;

  Future<Database> connect() async {
    if (_database != null) {
      return _database!;
    }

    final database_path = await getDatabasesPath();
    path = path_util.join(database_path, 'data', 'app.sqlite3');
    _database = await openDatabase(
      path,
      version: 1,
      onConfigure: (conn) async {
        await conn.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: _initialize_database,
      onCreate: (conn, version) => _initialize_database(conn),
    );
    return _database!;
  }

  Future<void> initialize() async {
    final conn = await connect();
    await _initialize_database(conn);
  }

  Future<void> close() async {
    final database = _database;
    _database = null;
    await database?.close();
  }

  Future<void> _initialize_database(Database conn) async {
    // 長期記憶 (embedding BLOB を追加)
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS long_term_memory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        summary TEXT NOT NULL,
        source_text TEXT NOT NULL,
        embedding BLOB,

        place_name TEXT,
        latitude REAL,
        longitude REAL,

        speaker TEXT,
        event_time DATETIME,

        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        modified_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // タグ辞書
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        name TEXT NOT NULL UNIQUE,
        description TEXT
      )
    ''');

    // 長期記憶とタグの対応
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS memory_tag_map (
        memory_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,

        PRIMARY KEY (memory_id, tag_id),

        FOREIGN KEY (memory_id)
          REFERENCES long_term_memory(id)
          ON DELETE CASCADE,

        FOREIGN KEY (tag_id)
          REFERENCES tags(id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<void> insert_demo_data() async {
    // 完全に独立したユニークなエピソードデータのリスト
    var demo_records = <Map<String, Object?>>[
      {
        'summary': '風邪の診察と薬の処方',
        'source_text':
            '昨晩から熱が38度出たため、九州病院を受診した。医師の診察の結果、ただの風邪とのことで解熱剤と抗生物質を3日分処方された。しっかり休むように言われた。',
        'place_name': '九州病院',
        'latitude': 33.8631,
        'longitude': 130.7606,
        'speaker': '自分',
        'days_ago': 2,
        'tags': ['hospital', 'health', 'medicine', 'sick'],
      },
      {
        'summary': '新規プロジェクトのキックオフ会議',
        'source_text':
            '東京ビッグサイトの会議室で、来期に向けたAI開発プロジェクトのキックオフミーティングを行った。各部署から合計20名が集まり、今後のロードマップについて熱心な議論が交わされた。',
        'place_name': '東京ビッグサイト',
        'latitude': 35.6298,
        'longitude': 139.7938,
        'speaker': '山田マネージャー',
        'days_ago': 10,
        'tags': ['work', 'meeting', 'ai', 'project'],
      },
      {
        'summary': '自己ベスト更新のランニング',
        'source_text':
            '早朝に大濠公園へ行き、5kmのジョギングをした。気温が涼しく走りやすかったため、ペースが上がり、自己ベストのタイムを2分更新することができた。とても気分が良い。',
        'place_name': '大濠公園',
        'latitude': 33.5858,
        'longitude': 130.3763,
        'speaker': '自分',
        'days_ago': 5,
        'tags': ['sports', 'running', 'hobby', 'achievement'],
      },
      {
        'summary': '新幹線の大幅遅延トラブル',
        'source_text':
            '出張帰りに京都駅から新幹線に乗ろうとしたところ、静岡県での大雨の影響で運転が見合わせられていた。駅構内で3時間待機することになり、非常に疲労した。',
        'place_name': '京都駅',
        'latitude': 34.9858,
        'longitude': 135.7587,
        'speaker': '駅アナウンス',
        'days_ago': 20,
        'tags': ['travel', 'trouble', 'train'],
      },
      {
        'summary': '最新のノートパソコンを購入',
        'source_text':
            'これまで使っていたPCのバッテリーが寿命を迎えたため、秋葉原のヨドバシカメラで最新のM3チップ搭載のノートパソコンを購入した。想定より安く買えたので、浮いたお金でマウスも新調した。',
        'place_name': 'ヨドバシカメラ マルチメディアAkiba',
        'latitude': 35.6987,
        'longitude': 139.7747,
        'speaker': '店員さん',
        'days_ago': 1,
        'tags': ['shopping', 'gadget', 'pc'],
      },
      {
        'summary': '友人との海沿いドライブとランチ',
        'source_text':
            '大学時代の友人3人と車で糸島半島へドライブに行った。海沿いのカフェで食べたガーリックシュリンプが絶品で、夕日も見ることができ素晴らしい休日になった。',
        'place_name': '糸島のカフェ',
        'latitude': 33.6269,
        'longitude': 130.1583,
        'speaker': '友人A',
        'days_ago': 45,
        'tags': ['drive', 'food', 'friends', 'holiday'],
      },
      {
        'summary': '引っ越しに伴う転入届の提出',
        'source_text':
            '先週末に新居への引っ越しが完了したため、午前休を取って区役所の窓口に行き、転入届とマイナンバーカードの住所変更手続きを行った。非常に混雑していた。',
        'place_name': '福岡市中央区役所',
        'latitude': 33.5881,
        'longitude': 130.3956,
        'speaker': '窓口担当者',
        'days_ago': 60,
        'tags': ['procedure', 'moving', 'government'],
      },
      {
        'summary': '深夜の地震による一時避難',
        'source_text':
            '深夜2時頃に震度4の地震が発生。スマホの緊急地震速報で飛び起きた。念のため防災リュックを持ってマンションのロビーまで一時避難したが、特に被害はなく30分後に部屋に戻った。',
        'place_name': '自宅マンション',
        'latitude': null,
        'longitude': null,
        'speaker': '自分',
        'days_ago': 120,
        'tags': ['emergency', 'earthquake', 'disaster'],
      },
      {
        'summary': '図書館での資格試験の勉強',
        'source_text':
            '来月受験予定の基本情報技術者試験に向けて、市立図書館の学習室で過去問題集を解いた。アルゴリズムの問題がまだ苦手なので、重点的に復習する必要がある。',
        'place_name': '市立図書館',
        'latitude': 33.5899,
        'longitude': 130.3541,
        'speaker': '自分',
        'days_ago': 15,
        'tags': ['study', 'qualification', 'library'],
      },
    ];

    // アプリ起動のたびに同じデモデータが増えないようにする。
    final conn = await connect();
    final rows = await conn.query('long_term_memory', columns: ['source_text']);
    final existing_source_texts = rows
        .map((row) => row['source_text'] as String)
        .toSet();
    demo_records = demo_records
        .where(
          (record) =>
              !existing_source_texts.contains(record['source_text'] as String),
        )
        .toList();
    if (demo_records.isEmpty) {
      return;
    }

    final model = await _load_embedding_model();

    // E5モデルの要件：保存するドキュメントには "passage: " を付ける
    final texts_to_embed = demo_records
        .map((record) => record['source_text'] as String)
        .toList();

    final embeddings = await model.generateEmbeddings(
      texts_to_embed,
      taskType: TaskType.retrievalDocument,
    );

    await conn.transaction((transaction) async {
      for (var index = 0; index < demo_records.length; index++) {
        final record = demo_records[index];
        final emb = embeddings[index];
        final event_time = DateTime.now()
            .subtract(Duration(days: record['days_ago'] as int))
            .toIso8601String();
        final emb_bytes = _to_float32_bytes(emb);

        final memory_id = await transaction.insert('long_term_memory', {
          'summary': record['summary'],
          'source_text': record['source_text'],
          'embedding': emb_bytes,
          'place_name': record['place_name'],
          'latitude': record['latitude'],
          'longitude': record['longitude'],
          'speaker': record['speaker'],
          'event_time': event_time,
        });

        for (final tag_name in record['tags']! as List<String>) {
          await transaction.insert('tags', {
            'name': tag_name,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
          final tag_rows = await transaction.query(
            'tags',
            columns: ['id'],
            where: 'name = ?',
            whereArgs: [tag_name],
            limit: 1,
          );
          final tag_id = tag_rows.single['id'] as int;

          await transaction.insert('memory_tag_map', {
            'memory_id': memory_id,
            'tag_id': tag_id,
          });
        }
      }
    });
  }

  /// Embeddingモデルを初回だけ取得し、以降はローカルから読み込む。
  static Future<EmbeddingModel> _load_embedding_model() async {
    if (!FlutterGemma.hasActiveEmbedder()) {
      throw StateError(
        'Embedding model is not installed: '
        '$EMBEDDING_MODEL_ID ($EMBEDDING_MODEL_PATH).',
      );
    }
    return FlutterGemma.getActiveEmbedder(
      preferredBackend: PreferredBackend.cpu,
    );
  }

  static Uint8List _to_float32_bytes(List<double> values) {
    final result = Float32List.fromList(values);
    return result.buffer.asUint8List();
  }
}
