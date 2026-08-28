import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kokotoba_flutter_app/core/controller/registered_card_controller.dart';
import 'package:kokotoba_flutter_app/core/model/registered_card.dart';
import 'package:kokotoba_flutter_app/ui/home/home_screen.dart';

class _MemoryRegisteredCardController implements RegisteredCardController {
  _MemoryRegisteredCardController(this.cards);

  final List<RegisteredCard> cards;
  var nextID = 100;

  @override
  Future<List<RegisteredCard>> fetchRegisteredCards() async => List.of(cards);

  @override
  Future<RegisteredCard> createRegisteredCard(String text) async {
    final card = RegisteredCard(id: nextID++, text: text);
    cards.add(card);
    return card;
  }

  @override
  Future<void> deleteRegisteredCard(int id) async {}

  @override
  Future<void> reorderRegisteredCards(List<int> ids) async {}
}

Widget _app(_MemoryRegisteredCardController controller) {
  return MaterialApp(
    home: Scaffold(
      body: HomeScreen(
        startConversation: () {},
        manualInput: () {},
        openCards: () {},
        registeredCardController: controller,
      ),
    ),
  );
}

void main() {
  testWidgets('よく使う文章の先頭2件だけをホームに表示する', (tester) async {
    final controller = _MemoryRegisteredCardController([
      const RegisteredCard(id: 1, text: '一番よく使う文章'),
      const RegisteredCard(id: 2, text: '二番目に使う文章'),
      const RegisteredCard(id: 3, text: 'ホームには出さない文章'),
    ]);

    await tester.pumpWidget(_app(controller));
    await tester.pump();

    expect(find.text('一番よく使う文章'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('二番目に使う文章'), 100);
    expect(find.text('二番目に使う文章'), findsOneWidget);
    expect(find.text('ホームには出さない文章'), findsNothing);
    expect(find.text('文章を登録'), findsNothing);
  });

  testWidgets('空き枠から文章をAPIへ登録してホームに表示する', (tester) async {
    final controller = _MemoryRegisteredCardController([
      const RegisteredCard(id: 1, text: '登録済みの文章'),
    ]);

    await tester.pumpWidget(_app(controller));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('文章を登録'), 100);
    await tester.tap(find.text('文章を登録'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ホームから追加した文章');
    await tester.pump();
    await tester.tap(find.text('登録する'));
    await tester.pumpAndSettle();

    expect(controller.cards.last.text, 'ホームから追加した文章');
    expect(find.text('ホームから追加した文章'), findsOneWidget);
  });
}
