class RegisteredCard {
  const RegisteredCard({required this.id, required this.text});

  factory RegisteredCard.fromJson(Map<String, dynamic> json) {
    return RegisteredCard(id: json['id'] as int, text: json['text'] as String);
  }

  final int id;
  final String text;
}
