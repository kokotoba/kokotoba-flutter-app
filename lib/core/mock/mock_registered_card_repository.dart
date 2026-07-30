import 'package:kokotoba_flutter_app/core/model/registered_card.dart';
import 'package:kokotoba_flutter_app/core/repository/registered_card_repository.dart';

class MockRegisteredCardRepository implements RegisteredCardRepository {
  const MockRegisteredCardRepository();

  @override
  Future<List<RegisteredCard>> fetchRegisteredCards() async {
    return const [
      RegisteredCard(text: 'うまく話せないため、アプリを使っています'),
      RegisteredCard(text: 'もう一度ゆっくり話してください'),
      RegisteredCard(text: '少し考える時間をください'),
      RegisteredCard(text: 'ありがとうございます'),
      RegisteredCard(text: '助けてください'),
    ];
  }
}
