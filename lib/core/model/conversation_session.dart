enum Speaker { partner, user }

class Utterance {
  const Utterance({
    required this.speaker,
    required this.text,
    required this.spokenAt,
  });

  final Speaker speaker;
  final String text;
  final DateTime spokenAt;
}

class ConversationSession {
  const ConversationSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.utterances = const [],
  });

  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<Utterance> utterances;

  bool get isActive => endedAt == null;

  ConversationSession copyWith({
    DateTime? endedAt,
    List<Utterance>? utterances,
  }) {
    return ConversationSession(
      id: id,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      utterances: utterances ?? this.utterances,
    );
  }
}
