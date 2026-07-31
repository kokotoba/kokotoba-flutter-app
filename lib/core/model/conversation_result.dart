class ConversationResult {
  const ConversationResult({
    required this.recognizedText,
    required this.suggestions,
    required this.quickPhrases,
  });

  final String recognizedText;
  final List<ConversationSuggestion> suggestions;
  final List<String> quickPhrases;
}

class ConversationSuggestion {
  const ConversationSuggestion({
    required this.text,
    required this.reason,
    this.recommended = false,
  });

  final String text;
  final String reason;
  final bool recommended;
}
