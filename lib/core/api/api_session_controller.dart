import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kokotoba_flutter_app/core/controller/session_controller.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_session.dart';

class ApiSessionController implements SessionController {
  ApiSessionController({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  final String baseUrl;
  final http.Client client;

  Uri get _sessionsUri => Uri.parse('$baseUrl/api/v1/me/sessions');

  @override
  Future<ConversationSession> startOrResumeSession() async {
    final response = await client.post(
      _sessionsUri,
      headers: const {'Accept': 'application/json'},
    );
    _requireStatus(response, 200);
    return _sessionFromJson(_decode(response));
  }

  @override
  Future<void> endSession(String sessionId) async {
    final response = await client.post(
      Uri.parse('$_sessionsUri/$sessionId/end'),
      headers: const {'Accept': 'application/json'},
    );
    _requireStatus(response, 204);
  }

  @override
  Future<void> recordUtterance(String sessionId, Utterance utterance) async {
    final response = await client.post(
      Uri.parse('$_sessionsUri/$sessionId/utterances'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'speaker': utterance.speaker == Speaker.partner ? 'partner' : 'user',
        'text': utterance.text,
        'spoken_at': utterance.spokenAt.toUtc().toIso8601String(),
      }),
    );
    _requireStatus(response, 201);
  }

  @override
  Future<List<ConversationSession>> fetchSessions() async {
    final response = await client.get(
      _sessionsUri,
      headers: const {'Accept': 'application/json'},
    );
    _requireStatus(response, 200);

    final json = _decode(response);
    final sessions = json['sessions'] as List<dynamic>? ?? const [];
    return sessions
        .map((value) => _sessionFromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  ConversationSession _sessionFromJson(Map<String, dynamic> json) {
    final utterances = json['utterances'] as List<dynamic>? ?? const [];
    final endedAt = json['ended_at'] as String?;
    return ConversationSession(
      id: '${json['id']}',
      startedAt: DateTime.parse(json['started_at'] as String).toLocal(),
      endedAt: endedAt == null ? null : DateTime.parse(endedAt).toLocal(),
      utterances: utterances
          .map((value) => _utteranceFromJson(value as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Utterance _utteranceFromJson(Map<String, dynamic> json) {
    return Utterance(
      speaker: json['speaker'] == 'partner' ? Speaker.partner : Speaker.user,
      text: json['text'] as String? ?? '',
      spokenAt: DateTime.parse(json['spoken_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> _decode(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  void _requireStatus(http.Response response, int expected) {
    if (response.statusCode != expected) {
      throw SessionApiException(response.statusCode, response.body);
    }
  }
}

class SessionApiException implements Exception {
  const SessionApiException(this.statusCode, this.responseBody);

  final int statusCode;
  final String responseBody;

  @override
  String toString() => 'Session API returned $statusCode: $responseBody';
}
