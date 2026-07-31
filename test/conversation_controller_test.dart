import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kokotoba_flutter_app/core/controller/conversation_controller.dart';
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

void main() {
  testWidgets('会話画面は注入されたControllerの推論結果を表示する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConversationScreen(controller: _TestConversationController()),
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
}
