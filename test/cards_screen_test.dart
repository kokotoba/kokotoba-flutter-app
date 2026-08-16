import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kokotoba_flutter_app/core/controller/registered_card_controller.dart';
import 'package:kokotoba_flutter_app/core/model/registered_card.dart';
import 'package:kokotoba_flutter_app/ui/cards/cards_screen.dart';

class _MemoryRegisteredCardController implements RegisteredCardController {
  final cards = <RegisteredCard>[];
  var nextID = 1;

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
}

void main() {
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
    await tester.tap(find.widgetWithText(FilledButton, '追加'));
    await tester.pumpAndSettle();

    expect(find.text('ありません'), findsNothing);
    expect(find.text('自由に追加した文章'), findsOneWidget);
    expect(controller.cards.single.text, '自由に追加した文章');
  });
}
