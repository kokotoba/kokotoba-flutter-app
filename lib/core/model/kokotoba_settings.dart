class KokotobaSettings {
  const KokotobaSettings({
    this.userId = 0,
    required this.displayRows,
    required this.voiceRows,
    required this.supportToggles,
    required this.privacyToggles,
  });

  factory KokotobaSettings.fromJson(Map<String, dynamic> json) {
    return KokotobaSettings(
      userId: json['user_id'] as int,
      displayRows: _rows(json['display_rows']),
      voiceRows: _rows(json['voice_rows']),
      supportToggles: _toggles(json['support_toggles']),
      privacyToggles: _toggles(json['privacy_toggles']),
    );
  }

  final int userId;
  final List<SettingRow> displayRows;
  final List<SettingRow> voiceRows;
  final List<SettingToggle> supportToggles;
  final List<SettingToggle> privacyToggles;

  static List<SettingRow> _rows(Object? value) {
    return (value as List<dynamic>)
        .map((row) => SettingRow.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  static List<SettingToggle> _toggles(Object? value) {
    return (value as List<dynamic>)
        .map((toggle) => SettingToggle.fromJson(toggle as Map<String, dynamic>))
        .toList(growable: false);
  }
}

class SettingRow {
  const SettingRow({required this.label, required this.value});

  factory SettingRow.fromJson(Map<String, dynamic> json) {
    return SettingRow(
      label: json['label'] as String,
      value: json['value'] as String,
    );
  }

  final String label;
  final String value;
}

class SettingToggle {
  const SettingToggle({required this.label, required this.enabled});

  factory SettingToggle.fromJson(Map<String, dynamic> json) {
    return SettingToggle(
      label: json['label'] as String,
      enabled: json['enabled'] as bool,
    );
  }

  final String label;
  final bool enabled;
}

class KokotobaSettingsUpdate {
  const KokotobaSettingsUpdate({
    this.textSize,
    this.buttonSize,
    this.contrast,
    this.suggestionCount,
    this.speechRate,
    this.speechVolume,
    this.speechVoice,
    this.useHistoryForSuggestions,
    this.useLocationForSuggestions,
    this.useProfileForSuggestions,
    this.showConfirmationAfterSelection,
    this.saveConversationHistory,
    this.allowExternalCommunication,
  });

  final String? textSize;
  final String? buttonSize;
  final String? contrast;
  final int? suggestionCount;
  final String? speechRate;
  final int? speechVolume;
  final String? speechVoice;
  final bool? useHistoryForSuggestions;
  final bool? useLocationForSuggestions;
  final bool? useProfileForSuggestions;
  final bool? showConfirmationAfterSelection;
  final bool? saveConversationHistory;
  final bool? allowExternalCommunication;

  Map<String, Object> toJson() {
    return {
      'text_size': ?textSize,
      'button_size': ?buttonSize,
      'contrast': ?contrast,
      'suggestion_count': ?suggestionCount,
      'speech_rate': ?speechRate,
      'speech_volume': ?speechVolume,
      'speech_voice': ?speechVoice,
      'use_history_for_suggestions': ?useHistoryForSuggestions,
      'use_location_for_suggestions': ?useLocationForSuggestions,
      'use_profile_for_suggestions': ?useProfileForSuggestions,
      'show_confirmation_after_selection': ?showConfirmationAfterSelection,
      'save_conversation_history': ?saveConversationHistory,
      'allow_external_communication': ?allowExternalCommunication,
    };
  }
}
