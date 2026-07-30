class KokotobaSettings {
  const KokotobaSettings({
    required this.displayRows,
    required this.voiceRows,
    required this.supportToggles,
    required this.privacyToggles,
  });

  final List<SettingRow> displayRows;
  final List<SettingRow> voiceRows;
  final List<SettingToggle> supportToggles;
  final List<SettingToggle> privacyToggles;
}

class SettingRow {
  const SettingRow({required this.label, required this.value});

  final String label;
  final String value;
}

class SettingToggle {
  const SettingToggle({required this.label, required this.enabled});

  final String label;
  final bool enabled;
}
