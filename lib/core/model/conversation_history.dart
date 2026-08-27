class ConversationHistory {
  const ConversationHistory({
    required this.id,
    required this.startedAt,
    required this.active,
    required this.utterances,
    this.endedAt,
  });

  factory ConversationHistory.fromJson(Map<String, dynamic> json) {
    return ConversationHistory(
      id: json['id'] as int,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: switch (json['ended_at']) {
        final String value => DateTime.parse(value),
        _ => null,
      },
      active: json['active'] as bool? ?? false,
      utterances: (json['utterances'] as List<dynamic>? ?? const [])
          .map(
            (value) =>
                ConversationUtterance.fromJson(value as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }

  final int id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool active;
  final List<ConversationUtterance> utterances;

  ConversationUtterance? get latestPartnerUtterance =>
      _latestUtterance(ConversationSpeaker.partner);

  ConversationUtterance? get latestUserUtterance =>
      _latestUtterance(ConversationSpeaker.user);

  ConversationUtterance? _latestUtterance(ConversationSpeaker speaker) {
    for (final utterance in utterances.reversed) {
      if (utterance.speaker == speaker) return utterance;
    }
    return null;
  }
}

enum ConversationSpeaker {
  partner('partner'),
  user('user');

  const ConversationSpeaker(this.apiValue);

  factory ConversationSpeaker.fromJson(String value) {
    return values.firstWhere(
      (speaker) => speaker.apiValue == value,
      orElse: () =>
          throw FormatException('Unknown conversation speaker: $value'),
    );
  }

  final String apiValue;
}

class ConversationUtterance {
  const ConversationUtterance({
    required this.id,
    required this.speaker,
    required this.text,
    required this.spokenAt,
  });

  factory ConversationUtterance.fromJson(Map<String, dynamic> json) {
    return ConversationUtterance(
      id: json['id'] as int,
      speaker: ConversationSpeaker.fromJson(json['speaker'] as String),
      text: json['text'] as String,
      spokenAt: DateTime.parse(json['spoken_at'] as String),
    );
  }

  final int id;
  final ConversationSpeaker speaker;
  final String text;
  final DateTime spokenAt;
}
