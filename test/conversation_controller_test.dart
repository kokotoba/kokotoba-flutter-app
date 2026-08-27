import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kokotoba_flutter_app/core/controller/conversation_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/conversation_history_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/speech_recognition_controller.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_speech_recognition_controller.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_history.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_result.dart';
import 'package:kokotoba_flutter_app/ui/conversation/conversation_screen.dart';

class _TestConversationController implements ConversationController {
  final requestedModes = <SuggestionMode>[];
  final selectedCards = <(String, String)>[];

  @override
  Future<ConversationResult> fetchConversationResult({
    String question = '',
    SuggestionMode mode = SuggestionMode.fast,
  }) async {
    requestedModes.add(mode);
    return const ConversationResult(
      recognizedText: 'テスト用の認識結果',
      suggestionId: 'suggestion-1',
      suggestions: [
        ConversationSuggestion(
          id: 'card-1',
          text: 'テスト用の文章候補',
          reason: 'テストControllerから取得',
        ),
        ConversationSuggestion(
          id: 'card-2',
          text: '2つ目の文章候補',
          reason: 'テストControllerから取得',
        ),
      ],
      quickPhrases: ['テスト用の短文'],
    );
  }

  @override
  Future<void> selectCard({
    required String suggestionId,
    required String cardId,
  }) async {
    selectedCards.add((suggestionId, cardId));
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

class _TestHistoryController implements ConversationHistoryController {
  _TestHistoryController({this.hasExistingSession = false});

  final bool hasExistingSession;
  final utterances = <(ConversationSpeaker, String)>[];
  final endedSessionIds = <int>[];
  var startCount = 0;

  @override
  Future<List<ConversationHistory>> fetchConversationHistories() async => [];

  @override
  Future<ConversationHistory> startOrResumeSession() async {
    startCount++;
    final isExisting = hasExistingSession && startCount == 1;
    return ConversationHistory(
      id: isExisting ? 7 : 7 + startCount - 1,
      startedAt: DateTime.utc(2026, 8, 28),
      active: true,
      utterances: isExisting
          ? [
              ConversationUtterance(
                id: 1,
                speaker: ConversationSpeaker.partner,
                text: '前回の質問です',
                spokenAt: DateTime.utc(2026, 8, 28),
              ),
            ]
          : const [],
    );
  }

  @override
  Future<ConversationUtterance> addUtterance({
    required int sessionId,
    required ConversationSpeaker speaker,
    required String text,
  }) async {
    utterances.add((speaker, text));
    return ConversationUtterance(
      id: utterances.length,
      speaker: speaker,
      text: text,
      spokenAt: DateTime.utc(2026, 8, 28),
    );
  }

  @override
  Future<void> endSession(int sessionId) async {
    endedSessionIds.add(sessionId);
  }
}

void main() {
  const speechChannel = MethodChannel('com.kokotoba.app/text_to_speech');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(speechChannel, (_) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(speechChannel, null);
  });

  Future<void> scrollTo(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(
      find.text(text),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
  }

  testWidgets('会話画面は注入されたControllerの推論結果を表示する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConversationScreen(
            controller: _TestConversationController(),
            historyController: _TestHistoryController(),
            speechRecognitionController:
                const MockSpeechRecognitionController(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('「テスト用の認識結果」'), findsOneWidget);
    expect(find.text('聞き取りました'), findsNothing);
    expect(find.text('内容が違うときは修正できます'), findsNothing);
    expect(find.text('テスト用の文章候補'), findsOneWidget);
    expect(find.text('2つ目の文章候補').hitTestable(), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('テスト用の短文'), findsOneWidget);
  });

  testWidgets('ボタンで音声認識を開始・停止して結果を表示する', (tester) async {
    final conversation = _TestConversationController();
    final speech = _TestSpeechRecognitionController();
    final history = _TestHistoryController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConversationScreen(
            controller: conversation,
            historyController: history,
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

    await scrollTo(tester, '聞き取りを停止');
    await tester.tap(find.text('聞き取りを停止'));
    await tester.pumpAndSettle();
    expect(speech.stopped, isTrue);
    expect(find.text('「実際に認識した文章」'), findsOneWidget);

    await tester.tap(find.text('テスト用の文章候補'));
    await tester.pumpAndSettle();
    expect(history.startCount, 1);
    expect(history.utterances, [
      (ConversationSpeaker.partner, '実際に認識した文章'),
      (ConversationSpeaker.user, 'テスト用の文章候補'),
    ]);
    expect(conversation.selectedCards, [('suggestion-1', 'card-1')]);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(history.endedSessionIds, isEmpty);
  });

  testWidgets('候補一覧の読むボタンで選択として保存して読み上げる', (tester) async {
    final conversation = _TestConversationController();
    final history = _TestHistoryController();
    final spokenTexts = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(speechChannel, (call) async {
          spokenTexts.add((call.arguments as Map)['text'] as String);
          return null;
        });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConversationScreen(
            controller: conversation,
            historyController: history,
            speechRecognitionController:
                const MockSpeechRecognitionController(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('読む').first);
    await tester.pumpAndSettle();

    expect(conversation.selectedCards, [('suggestion-1', 'card-1')]);
    expect(history.utterances, [(ConversationSpeaker.user, 'テスト用の文章候補')]);
    expect(spokenTexts, ['テスト用の文章候補']);
    expect(find.text('発話内容を確認'), findsNothing);
  });

  testWidgets('前のセッションを再開できる', (tester) async {
    final history = _TestHistoryController(hasExistingSession: true);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConversationScreen(
            controller: _TestConversationController(),
            historyController: history,
            speechRecognitionController:
                const MockSpeechRecognitionController(),
            initialEntry: ConversationEntry.listening,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('前の会話が残っています'), findsOneWidget);
    await tester.tap(find.text('続きから再開'));
    await tester.pumpAndSettle();

    expect(history.startCount, 1);
    expect(history.endedSessionIds, isEmpty);
  });

  testWidgets('前のセッションを終了して新しく始められる', (tester) async {
    final history = _TestHistoryController(hasExistingSession: true);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConversationScreen(
            controller: _TestConversationController(),
            historyController: history,
            speechRecognitionController:
                const MockSpeechRecognitionController(),
            initialEntry: ConversationEntry.listening,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('終了して新しく始める'));
    await tester.pumpAndSettle();

    expect(history.endedSessionIds, [7]);
    expect(history.startCount, 2);
  });

  testWidgets('音声認識画面からすぐ文字入力へ切り替えられる', (tester) async {
    final speech = _TestSpeechRecognitionController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConversationScreen(
            controller: _TestConversationController(),
            historyController: _TestHistoryController(),
            speechRecognitionController: speech,
            initialEntry: ConversationEntry.listening,
          ),
        ),
      ),
    );

    await scrollTo(tester, '文字で入力する');
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

  testWidgets('高品質モードを選ぶとqualityで音声認識結果を送信する', (tester) async {
    final conversation = _TestConversationController();
    final speech = _TestSpeechRecognitionController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConversationScreen(
            controller: conversation,
            historyController: _TestHistoryController(),
            speechRecognitionController: speech,
            initialEntry: ConversationEntry.listening,
          ),
        ),
      ),
    );

    await tester.tap(find.text('高品質'));
    await tester.pump();
    expect(find.text('履歴や関連情報を詳しく参照します'), findsOneWidget);

    await tester.tap(find.text('聞き取りを始める'));
    await tester.pump();
    speech.recognize('高品質で送る文章');
    await tester.pump();
    await scrollTo(tester, '聞き取りを停止');
    await tester.tap(find.text('聞き取りを停止'));
    await tester.pumpAndSettle();

    expect(conversation.requestedModes.last, SuggestionMode.quality);
  });
}
