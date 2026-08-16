import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kokotoba_flutter_app/core/api/api_registered_card_controller.dart';

void main() {
  test('空のよく使う文章一覧を取得する', () async {
    final controller = ApiRegisteredCardController(
      baseUrl: 'http://localhost:8080',
      userId: 1,
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/users/1/phrases');
        return http.Response('{"phrases":[]}', 200);
      }),
    );

    expect(await controller.fetchRegisteredCards(), isEmpty);
  });

  test('自由入力した文章を追加する', () async {
    final controller = ApiRegisteredCardController(
      baseUrl: 'http://localhost:8080',
      userId: 1,
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(jsonDecode(request.body), {'text': 'ゆっくりお願いします'});
        return http.Response(
          '{"id":12,"text":"ゆっくりお願いします"}',
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final card = await controller.createRegisteredCard('ゆっくりお願いします');

    expect(card.id, 12);
    expect(card.text, 'ゆっくりお願いします');
  });

  test('登録済みの文章を削除する', () async {
    final controller = ApiRegisteredCardController(
      baseUrl: 'http://localhost:8080',
      userId: 1,
      client: MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, '/api/v1/users/1/phrases/12');
        return http.Response('', 204);
      }),
    );

    await controller.deleteRegisteredCard(12);
  });
}
