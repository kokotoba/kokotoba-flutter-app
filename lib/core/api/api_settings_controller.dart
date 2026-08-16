import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kokotoba_flutter_app/core/controller/settings_controller.dart';
import 'package:kokotoba_flutter_app/core/model/kokotoba_settings.dart';

typedef HttpGet =
    Future<http.Response> Function(Uri url, {Map<String, String>? headers});

typedef HttpPatch =
    Future<http.Response> Function(
      Uri url, {
      Map<String, String>? headers,
      Object? body,
      Encoding? encoding,
    });

class ApiSettingsController implements SettingsController {
  ApiSettingsController({
    required this.baseUrl,
    this.userId = 1,
    HttpGet? get,
    HttpPatch? patch,
  }) : get = get ?? http.get,
       patch = patch ?? http.patch;

  final String baseUrl;
  final int userId;
  final HttpGet get;
  final HttpPatch patch;

  Uri get _settingsUri => Uri.parse('$baseUrl/api/v1/users/$userId/settings');

  @override
  Future<KokotobaSettings> fetchSettings() async {
    final response = await get(
      _settingsUri,
      headers: const {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw SettingsApiException(response.statusCode, response.body);
    }
    return _decodeSettings(response);
  }

  @override
  Future<KokotobaSettings> updateSettings(KokotobaSettingsUpdate update) async {
    final response = await patch(
      _settingsUri,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(update.toJson()),
    );
    if (response.statusCode != 200) {
      throw SettingsApiException(response.statusCode, response.body);
    }
    return _decodeSettings(response);
  }

  KokotobaSettings _decodeSettings(http.Response response) {
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    return KokotobaSettings.fromJson(json as Map<String, dynamic>);
  }
}

class SettingsApiException implements Exception {
  const SettingsApiException(this.statusCode, this.responseBody);

  final int statusCode;
  final String responseBody;

  @override
  String toString() => 'Settings API returned $statusCode: $responseBody';
}
