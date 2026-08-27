import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kokotoba_flutter_app/core/controller/conversation_history_controller.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_history.dart';

class ApiConversationHistoryController
    implements ConversationHistoryController {
  ApiConversationHistoryController({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  final String baseUrl;
  final http.Client client;

  Uri get _sessionsUri => Uri.parse('$baseUrl/api/v1/me/sessions');

  @override
  Future<List<ConversationHistory>> fetchConversationHistories() async {
    final response = await client.get(
      _sessionsUri,
      headers: const {'Accept': 'application/json'},
    );
    _requireStatus(response, 200);
    final body = _decode(response);
    return (body['sessions'] as List<dynamic>? ?? const [])
        .map(
          (value) =>
              ConversationHistory.fromJson(value as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  Future<ConversationHistory> startOrResumeSession() async {
    final response = await client.post(
      _sessionsUri,
      headers: const {'Accept': 'application/json'},
    );
    _requireStatus(response, 200);
    return ConversationHistory.fromJson(_decode(response));
  }

  @override
  Future<ConversationUtterance> addUtterance({
    required int sessionId,
    required ConversationSpeaker speaker,
    required String text,
  }) async {
    final response = await client.post(
      Uri.parse('$_sessionsUri/$sessionId/utterances'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'speaker': speaker.apiValue, 'text': text}),
    );
    _requireStatus(response, 201);
    return ConversationUtterance.fromJson(_decode(response));
  }

  @override
  Future<void> endSession(int sessionId) async {
    final response = await client.post(
      Uri.parse('$_sessionsUri/$sessionId/end'),
      headers: const {'Accept': 'application/json'},
    );
    _requireStatus(response, 204);
  }

  Map<String, dynamic> _decode(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  void _requireStatus(http.Response response, int expected) {
    if (response.statusCode != expected) {
      throw ConversationHistoryApiException(response.statusCode, response.body);
    }
  }
}

class ConversationHistoryApiException implements Exception {
  const ConversationHistoryApiException(this.statusCode, this.responseBody);

  final int statusCode;
  final String responseBody;

  @override
  String toString() =>
      'Conversation history API returned $statusCode: $responseBody';
}
