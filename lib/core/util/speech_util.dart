import 'package:flutter/services.dart';

class SpeechUtil {
  SpeechUtil._();

  static const _channel = MethodChannel('com.kokotoba.app/text_to_speech');

  static Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _channel.invokeMethod<void>('speak', {'text': text});
  }
}
