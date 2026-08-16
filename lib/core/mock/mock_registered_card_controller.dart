import 'package:kokotoba_flutter_app/core/controller/registered_card_controller.dart';
import 'package:kokotoba_flutter_app/core/model/registered_card.dart';

class MockRegisteredCardController implements RegisteredCardController {
  const MockRegisteredCardController();

  @override
  Future<List<RegisteredCard>> fetchRegisteredCards() async {
    return const [
      RegisteredCard(id: 1, text: 'うまく話せないため、アプリを使っています'),
      RegisteredCard(id: 2, text: 'もう一度ゆっくり話してください'),
      RegisteredCard(id: 3, text: '少し考える時間をください'),
      RegisteredCard(id: 4, text: 'ありがとうございます'),
      RegisteredCard(id: 5, text: '助けてください'),
    ];
  }

  @override
  Future<RegisteredCard> createRegisteredCard(String text) async {
    return RegisteredCard(
      id: DateTime.now().microsecondsSinceEpoch,
      text: text,
    );
  }

  @override
  Future<void> reorderRegisteredCards(List<int> ids) async {}

  @override
  Future<void> deleteRegisteredCard(int id) async {}
}
