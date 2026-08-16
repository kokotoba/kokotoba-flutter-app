import 'package:kokotoba_flutter_app/core/model/registered_card.dart';

abstract interface class RegisteredCardController {
  Future<List<RegisteredCard>> fetchRegisteredCards();

  Future<RegisteredCard> createRegisteredCard(String text);

  Future<void> deleteRegisteredCard(int id);
}
