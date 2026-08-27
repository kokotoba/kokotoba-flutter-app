import 'package:flutter/services.dart';

class SpeechUtil {
  SpeechUtil._();

  static const _channel = MethodChannel('com.kokotoba.app/text_to_speech');
  static const _duplicateTapWindow = Duration(milliseconds: 700);
  static String? _lastText;
  static DateTime? _lastRequestedAt;

  static Future<void> speak(String text) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return;

    final now = DateTime.now();
    final previousRequest = _lastRequestedAt;
    if (_lastText == normalizedText &&
        previousRequest != null &&
        now.difference(previousRequest) < _duplicateTapWindow) {
      return;
    }
    _lastText = normalizedText;
    _lastRequestedAt = now;

    try {
      await _channel.invokeMethod<void>('speak', {'text': normalizedText});
    } on PlatformException {
      // The native speech engine can still be finishing initialization on the
      // first request. Retry once after a short delay without requiring a
      // second user tap.
      await Future<void>.delayed(const Duration(milliseconds: 150));
      await _channel.invokeMethod<void>('speak', {'text': normalizedText});
    }
  }
}
