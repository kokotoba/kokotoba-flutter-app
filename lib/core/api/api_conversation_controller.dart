import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kokotoba_flutter_app/core/controller/conversation_controller.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_result.dart';

class ApiConversationController implements ConversationController {
  ApiConversationController({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  final String baseUrl;
  final http.Client client;

  Uri get _cardSuggestionsUri => Uri.parse('$baseUrl/v1/card-suggestions');

  @override
  Future<ConversationResult> fetchConversationResult(String question) async {
    final response = await client.post(
      _cardSuggestionsUri,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'question': question,
        'context': {'place_name': '場所情報なし'},
        'mode': 'fast',
      }),
    );
    _requireStatus(response, 201);

    final json = _decode(response);
    final cards = (json['cards'] as List<dynamic>? ?? const []);

    return ConversationResult(
      recognizedText: question,
      suggestions: cards
          .map(
            (value) => _suggestionFromJson(value as Map<String, dynamic>),
      )
          .toList(growable: false),
      quickPhrases: const ['うまく話せません', '少し待ってください', '文字で伝えます'],
    );
  }

  ConversationSuggestion _suggestionFromJson(Map<String, dynamic> json) {
    return ConversationSuggestion(
      text: json['text'] as String? ?? '',
      reason: json['reason'] as String? ?? 'AIが生成',
      recommended: json['recommended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _decode(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  void _requireStatus(http.Response response, int expected) {
    if (response.statusCode != expected) {
      throw ConversationApiException(response.statusCode, response.body);
    }
  }
}

class ConversationApiException implements Exception {
  const ConversationApiException(this.statusCode, this.responseBody);

  final int statusCode;
  final String responseBody;

  @override
  String toString() =>
      'Card suggestions API returned $statusCode: $responseBody';
}