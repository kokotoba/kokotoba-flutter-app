import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kokotoba_flutter_app/core/controller/registered_card_controller.dart';
import 'package:kokotoba_flutter_app/core/model/registered_card.dart';
import 'package:kokotoba_flutter_app/ui/cards/cards_screen.dart';

class _MemoryRegisteredCardController implements RegisteredCardController {
  final cards = <RegisteredCard>[];
  var nextID = 1;
  List<int>? reorderedIDs;

  @override
  Future<List<RegisteredCard>> fetchRegisteredCards() async => List.of(cards);

  @override
  Future<RegisteredCard> createRegisteredCard(String text) async {
    final card = RegisteredCard(id: nextID++, text: text);
    cards.insert(0, card);
    return card;
  }

  @override
  Future<void> deleteRegisteredCard(int id) async {
    cards.removeWhere((card) => card.id == id);
  }

  @override
  Future<void> reorderRegisteredCards(List<int> ids) async {
    reorderedIDs = List.of(ids);
    final cardsByID = {for (final card in cards) card.id: card};
    cards
      ..clear()
      ..addAll(ids.map((id) => cardsByID[id]!));
  }
}

void main() {
  testWidgets('カード操作を見やすいサイズで均等に表示する', (tester) async {
    final controller = _MemoryRegisteredCardController()
      ..cards.add(const RegisteredCard(id: 1, text: 'お願いします'));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CardsScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    final readButton = find.widgetWithText(TextButton, '読む');
    final editButton = find.widgetWithText(TextButton, '編集');
    final deleteButton = find.widgetWithText(TextButton, '削除');
    expect(readButton, findsOneWidget);
    expect(editButton, findsOneWidget);
    expect(deleteButton, findsOneWidget);

    final readRect = tester.getRect(readButton);
    final editRect = tester.getRect(editButton);
    final deleteRect = tester.getRect(deleteButton);
    expect(readRect.height, 44);
    expect(editRect.height, 44);
    expect(deleteRect.height, 44);
    expect(readRect.width, closeTo(editRect.width, 0.1));
    expect(editRect.width, closeTo(deleteRect.width, 0.1));
  });

  testWidgets('未登録なら「ありません」と表示し自由入力で追加できる', (tester) async {
    final controller = _MemoryRegisteredCardController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CardsScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ありません'), findsOneWidget);
    await tester.tap(find.text('＋  新しい文章を追加'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  自由に追加した文章  ');
    await tester.pump();
    expect(find.text('登録後のプレビュー'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '登録する'));
    await tester.pumpAndSettle();

    expect(find.text('ありません'), findsNothing);
    expect(find.text('自由に追加した文章'), findsOneWidget);
    expect(controller.cards.single.text, '自由に追加した文章');
  });

  testWidgets('左端のハンドルを長押しして並べ替えを保存できる', (tester) async {
    final controller = _MemoryRegisteredCardController()
      ..cards.addAll(const [
        RegisteredCard(id: 1, text: '1番目'),
        RegisteredCard(id: 2, text: '2番目'),
        RegisteredCard(id: 3, text: '3番目'),
      ]);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CardsScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.drag_indicator), findsNWidgets(3));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.drag_indicator).first),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await gesture.moveBy(const Offset(0, 30));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, 190));
    await tester.pump(const Duration(milliseconds: 800));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(controller.reorderedIDs, isNotNull);
    expect(controller.reorderedIDs, isNot([1, 2, 3]));
  });
}
