import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kokotoba_flutter_app/core/api/api_conversation_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/conversation_controller.dart';

void main() {
  test('選択した候補生成モードをAPIへ送信する', () async {
    Map<String, dynamic>? requestBody;
    final client = MockClient((request) async {
      requestBody = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'id': 'suggestion-1',
          'question_type': 'open',
          'cards': <Map<String, String>>[],
          'created_at': '2026-08-27T00:00:00Z',
        }),
        201,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final controller = ApiConversationController(
      baseUrl: 'http://127.0.0.1:8000',
      client: client,
    );

    await controller.fetchConversationResult(
      question: '認識した文章',
      mode: SuggestionMode.quality,
    );

    expect(requestBody?['mode'], 'quality');
  });
}
