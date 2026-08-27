import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kokotoba_flutter_app/core/util/speech_util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.kokotoba.app/text_to_speech');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('短時間の二重タップでは同じ文章を一度だけ読み上げる', () async {
    var callCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async {
          callCount++;
          return null;
        });

    await SpeechUtil.speak('二重タップのテスト文章');
    await SpeechUtil.speak('二重タップのテスト文章');

    expect(callCount, 1);
  });

  test('初回のネイティブ呼び出し失敗時は自動で一度再試行する', () async {
    var callCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async {
          callCount++;
          if (callCount == 1) {
            throw PlatformException(code: 'not-ready');
          }
          return null;
        });

    await SpeechUtil.speak('初期化再試行のテスト文章');

    expect(callCount, 2);
  });
}
