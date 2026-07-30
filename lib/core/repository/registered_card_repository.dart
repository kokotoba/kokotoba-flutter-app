import 'package:kokotoba_flutter_app/core/model/registered_card.dart';

abstract interface class RegisteredCardRepository {
  Future<List<RegisteredCard>> fetchRegisteredCards();
}
