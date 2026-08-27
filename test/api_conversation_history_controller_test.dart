import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kokotoba_flutter_app/core/api/api_conversation_history_controller.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_history.dart';

void main() {
  test('セッションを開始して相手とユーザーの発言を保存する', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      if (request.url.path == '/api/v1/me/sessions') {
        return _jsonResponse(_sessionJson(), 200);
      }
      return _jsonResponse({
        'id': 3,
        'speaker': 'partner',
        'text': '体調はいかがですか？',
        'spoken_at': '2026-08-28T01:01:00Z',
      }, 201);
    });
    final controller = ApiConversationHistoryController(
      baseUrl: 'http://localhost:8080',
      client: client,
    );

    final session = await controller.startOrResumeSession();
    await controller.addUtterance(
      sessionId: session.id,
      speaker: ConversationSpeaker.partner,
      text: '体調はいかがですか？',
    );

    expect(session.id, 7);
    expect(requests[0].method, 'POST');
    expect(requests[1].url.path, '/api/v1/me/sessions/7/utterances');
    expect(jsonDecode(requests[1].body), {
      'speaker': 'partner',
      'text': '体調はいかがですか？',
    });
  });

  test('会話履歴とセッション内の全発言を取得する', () async {
    final controller = ApiConversationHistoryController(
      baseUrl: 'http://localhost:8080',
      client: MockClient(
        (_) async => _jsonResponse({
          'sessions': [
            _sessionJson(
              utterances: [
                {
                  'id': 1,
                  'speaker': 'partner',
                  'text': 'どちらにしますか？',
                  'spoken_at': '2026-08-28T01:01:00Z',
                },
                {
                  'id': 2,
                  'speaker': 'user',
                  'text': 'こちらでお願いします',
                  'spoken_at': '2026-08-28T01:02:00Z',
                },
              ],
            ),
          ],
        }, 200),
      ),
    );

    final histories = await controller.fetchConversationHistories();

    expect(histories, hasLength(1));
    expect(histories.single.utterances, hasLength(2));
    expect(histories.single.latestPartnerUtterance?.text, 'どちらにしますか？');
    expect(histories.single.latestUserUtterance?.text, 'こちらでお願いします');
  });
}

Map<String, dynamic> _sessionJson({
  List<Map<String, dynamic>> utterances = const [],
}) {
  return {
    'id': 7,
    'started_at': '2026-08-28T01:00:00Z',
    'ended_at': null,
    'active': true,
    'utterances': utterances,
  };
}

http.Response _jsonResponse(Map<String, dynamic> body, int status) {
  return http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
