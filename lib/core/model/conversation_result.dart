class ConversationResult {
  const ConversationResult({
    required this.recognizedText,
    required this.suggestions,
    required this.quickPhrases,
    this.suggestionId,
    this.questionType,
  });

  final String recognizedText;
  final List<ConversationSuggestion> suggestions;
  final List<String> quickPhrases;
  final String? suggestionId;
  final String? questionType;
}

class ConversationSuggestion {
  const ConversationSuggestion({
    required this.text,
    required this.reason,
    this.recommended = false,
    this.id,
  });

  final String text;
  final String reason;
  final bool recommended;
  final String? id;
}
