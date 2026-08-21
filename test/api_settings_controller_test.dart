import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kokotoba_flutter_app/core/api/api_settings_controller.dart';
import 'package:kokotoba_flutter_app/core/model/kokotoba_settings.dart';

void main() {
  test('バックエンドからユーザー設定を取得する', () async {
    Uri? requestedUri;
    final controller = ApiSettingsController(
      baseUrl: 'http://localhost:8080',
      get: (uri, {headers}) async {
        requestedUri = uri;
        return http.Response.bytes(
          utf8.encode('''
          {
            "user_id": 7,
            "display_rows": [{"label": "文字サイズ", "value": "大きい"}],
            "voice_rows": [{"label": "読み上げ速度", "value": "標準"}],
            "support_toggles": [{"label": "履歴を候補に利用", "enabled": true}],
            "privacy_toggles": [{"label": "外部通信を利用", "enabled": false}]
          }
          '''),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      },
    );

    final settings = await controller.fetchSettings();

    expect(requestedUri.toString(), 'http://localhost:8080/api/v1/me/settings');
    expect(settings.userId, 7);
    expect(settings.displayRows.single.value, '大きい');
    expect(settings.supportToggles.single.enabled, isTrue);
    expect(settings.privacyToggles.single.enabled, isFalse);
  });

  test('バックエンドがエラーを返した場合は例外にする', () async {
    final controller = ApiSettingsController(
      baseUrl: 'http://localhost:8080',
      get: (uri, {headers}) async => http.Response('not found', 404),
    );

    expect(
      controller.fetchSettings,
      throwsA(
        isA<SettingsApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          404,
        ),
      ),
    );
  });

  test('変更した設定をPATCHして最新設定を受け取る', () async {
    Uri? requestedUri;
    Map<String, dynamic>? requestBody;
    final controller = ApiSettingsController(
      baseUrl: 'http://localhost:8080',
      patch: (uri, {headers, body, encoding}) async {
        requestedUri = uri;
        requestBody = jsonDecode(body! as String) as Map<String, dynamic>;
        return http.Response.bytes(
          utf8.encode('''
          {
            "user_id": 1,
            "display_rows": [{"label": "文字サイズ", "value": "標準"}],
            "voice_rows": [{"label": "読み上げ音量", "value": "70%"}],
            "support_toggles": [{"label": "履歴を候補に利用", "enabled": false}],
            "privacy_toggles": [{"label": "外部通信を利用", "enabled": true}]
          }
          '''),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      },
    );

    final settings = await controller.updateSettings(
      const KokotobaSettingsUpdate(
        speechVolume: 70,
        useHistoryForSuggestions: false,
      ),
    );

    expect(requestedUri.toString(), 'http://localhost:8080/api/v1/me/settings');
    expect(requestBody, {
      'speech_volume': 70,
      'use_history_for_suggestions': false,
    });
    expect(settings.voiceRows.single.value, '70%');
    expect(settings.supportToggles.single.enabled, isFalse);
  });
}
