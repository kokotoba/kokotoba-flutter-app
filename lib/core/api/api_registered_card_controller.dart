import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kokotoba_flutter_app/core/controller/registered_card_controller.dart';
import 'package:kokotoba_flutter_app/core/model/registered_card.dart';

class ApiRegisteredCardController implements RegisteredCardController {
  ApiRegisteredCardController({
    required this.baseUrl,
    this.userId = 1,
    http.Client? client,
  }) : client = client ?? http.Client();

  final String baseUrl;
  final int userId;
  final http.Client client;

  Uri get _collectionUri => Uri.parse('$baseUrl/api/v1/users/$userId/phrases');

  @override
  Future<List<RegisteredCard>> fetchRegisteredCards() async {
    final response = await client.get(
      _collectionUri,
      headers: const {'Accept': 'application/json'},
    );
    _requireStatus(response, 200);
    final json = _decode(response);
    return (json['phrases'] as List<dynamic>)
        .map((value) => RegisteredCard.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<RegisteredCard> createRegisteredCard(String text) async {
    final response = await client.post(
      _collectionUri,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'text': text}),
    );
    _requireStatus(response, 201);
    return RegisteredCard.fromJson(_decode(response));
  }

  @override
  Future<void> reorderRegisteredCards(List<int> ids) async {
    final response = await client.put(
      Uri.parse('$_collectionUri/order'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'phrase_ids': ids}),
    );
    _requireStatus(response, 204);
  }

  @override
  Future<void> deleteRegisteredCard(int id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/v1/users/$userId/phrases/$id'),
    );
    _requireStatus(response, 204);
  }

  Map<String, dynamic> _decode(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  void _requireStatus(http.Response response, int expected) {
    if (response.statusCode != expected) {
      throw RegisteredCardApiException(response.statusCode, response.body);
    }
  }
}

class RegisteredCardApiException implements Exception {
  const RegisteredCardApiException(this.statusCode, this.responseBody);

  final int statusCode;
  final String responseBody;

  @override
  String toString() =>
      'Frequent phrase API returned $statusCode: $responseBody';
}
