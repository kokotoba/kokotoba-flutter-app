import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_conversation_history_controller.dart';
import 'package:kokotoba_flutter_app/ui/history/history_screen.dart';

void main() {
  testWidgets('履歴一覧から相手と自分の全発言を参照できる', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HistoryScreen(controller: MockConversationHistoryController()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('今日は体調はいかがですか？'), findsOneWidget);
    expect(find.text('昨日から頭が痛いです'), findsOneWidget);

    await tester.tap(find.text('詳細を見る  ›'));
    await tester.pumpAndSettle();

    expect(find.text('会話の詳細'), findsOneWidget);
    expect(find.text('相手'), findsWidgets);
    expect(find.text('自分'), findsWidgets);
    expect(find.text('今日は体調はいかがですか？'), findsWidgets);
    expect(find.text('昨日から頭が痛いです'), findsWidgets);
  });
}
