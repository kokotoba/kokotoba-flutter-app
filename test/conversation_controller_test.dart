import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kokotoba_flutter_app/core/controller/conversation_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/speech_recognition_controller.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_speech_recognition_controller.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_result.dart';
import 'package:kokotoba_flutter_app/ui/conversation/conversation_screen.dart';

class _TestConversationController implements ConversationController {
  @override
  Future<ConversationResult> fetchConversationResult() async {
    return const ConversationResult(
      recognizedText: 'テスト用の認識結果',
      suggestions: [
        ConversationSuggestion(text: 'テスト用の文章候補', reason: 'テストControllerから取得'),
      ],
      quickPhrases: ['テスト用の短文'],
    );
  }
}

class _TestSpeechRecognitionController implements SpeechRecognitionController {
  SpeechResultCallback? onResult;
  ListeningStateCallback? onListeningChanged;
  bool started = false;
  bool stopped = false;
  bool canceled = false;

  @override
  Future<bool> initialize({
    required SpeechResultCallback onResult,
    required SpeechErrorCallback onError,
    required ListeningStateCallback onListeningChanged,
  }) async {
    this.onResult = onResult;
    this.onListeningChanged = onListeningChanged;
    return true;
  }

  @override
  Future<void> start() async {
    started = true;
    onListeningChanged?.call(true);
  }

  @override
  Future<void> stop() async {
    stopped = true;
    onListeningChanged?.call(false);
  }

  @override
  Future<void> cancel() async {
    canceled = true;
    onListeningChanged?.call(false);
  }

  void recognize(String text) => onResult?.call(text, false);
}

void main() {
  testWidgets('会話画面は注入されたControllerの推論結果を表示する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConversationScreen(
            controller: _TestConversationController(),
            speechRecognitionController:
                const MockSpeechRecognitionController(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('「テスト用の認識結果」'), findsOneWidget);
    expect(find.text('テスト用の文章候補'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('テスト用の短文'), findsOneWidget);
  });

  testWidgets('ボタンで音声認識を開始・停止して結果を表示する', (tester) async {
    final speech = _TestSpeechRecognitionController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConversationScreen(
            controller: _TestConversationController(),
            speechRecognitionController: speech,
            initialEntry: ConversationEntry.listening,
          ),
        ),
      ),
    );

    expect(find.text('聞き取りを始める'), findsOneWidget);
    await tester.tap(find.text('聞き取りを始める'));
    await tester.pump();
    expect(speech.started, isTrue);
    expect(find.text('聞き取りを停止'), findsOneWidget);

    speech.recognize('実際に認識した文章');
    await tester.pump();
    expect(find.text('実際に認識した文章'), findsOneWidget);

    await tester.tap(find.text('聞き取りを停止'));
    await tester.pumpAndSettle();
    expect(speech.stopped, isTrue);
    expect(find.text('「実際に認識した文章」'), findsOneWidget);
  });

  testWidgets('音声認識画面からすぐ文字入力へ切り替えられる', (tester) async {
    final speech = _TestSpeechRecognitionController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConversationScreen(
            controller: _TestConversationController(),
            speechRecognitionController: speech,
            initialEntry: ConversationEntry.listening,
          ),
        ),
      ),
    );

    await tester.tap(find.text('文字で入力する'));
    await tester.pumpAndSettle();

    expect(speech.canceled, isTrue);
    expect(find.text('文字から伝える'), findsOneWidget);

    await tester.tap(find.byTooltip('戻る'));
    await tester.pumpAndSettle();

    expect(find.text('聞き取りを開始'), findsOneWidget);
    expect(find.text('聞き取りを始める'), findsOneWidget);
    expect(find.text('「テスト用の認識結果」'), findsNothing);
  });
}
