import 'package:kokotoba_flutter_app/core/controller/settings_controller.dart';
import 'package:kokotoba_flutter_app/core/model/kokotoba_settings.dart';

class MockSettingsController implements SettingsController {
  const MockSettingsController();

  @override
  Future<KokotobaSettings> fetchSettings() async {
    return const KokotobaSettings(
      displayRows: [
        SettingRow(label: '文字サイズ', value: '大きい'),
        SettingRow(label: 'ボタンサイズ', value: '大きい'),
        SettingRow(label: 'コントラスト', value: '標準'),
        SettingRow(label: '候補表示数', value: '3件'),
      ],
      voiceRows: [
        SettingRow(label: '読み上げ速度', value: '標準'),
        SettingRow(label: '読み上げ音量', value: '80%'),
        SettingRow(label: '読み上げ音声', value: '日本語 1'),
      ],
      supportToggles: [
        SettingToggle(label: '履歴を候補に利用', enabled: true),
        SettingToggle(label: '位置情報を候補に利用', enabled: false),
        SettingToggle(label: '登録情報を候補に利用', enabled: true),
        SettingToggle(label: '選択後に確認画面を表示', enabled: true),
      ],
      privacyToggles: [
        SettingToggle(label: '会話履歴を保存', enabled: true),
        SettingToggle(label: '外部通信を利用', enabled: false),
      ],
    );
  }

  @override
  Future<KokotobaSettings> updateSettings(KokotobaSettingsUpdate update) async {
    final current = await fetchSettings();
    String displayValue(String label, String value) => switch (label) {
      '文字サイズ' => update.textSize ?? value,
      'ボタンサイズ' => update.buttonSize ?? value,
      'コントラスト' => update.contrast ?? value,
      '候補表示数' =>
        update.suggestionCount == null ? value : '${update.suggestionCount}件',
      _ => value,
    };
    String voiceValue(String label, String value) => switch (label) {
      '読み上げ速度' => update.speechRate ?? value,
      '読み上げ音量' =>
        update.speechVolume == null ? value : '${update.speechVolume}%',
      '読み上げ音声' => update.speechVoice ?? value,
      _ => value,
    };
    bool toggleValue(String label, bool value) => switch (label) {
      '履歴を候補に利用' => update.useHistoryForSuggestions ?? value,
      '位置情報を候補に利用' => update.useLocationForSuggestions ?? value,
      '登録情報を候補に利用' => update.useProfileForSuggestions ?? value,
      '選択後に確認画面を表示' => update.showConfirmationAfterSelection ?? value,
      '会話履歴を保存' => update.saveConversationHistory ?? value,
      '外部通信を利用' => update.allowExternalCommunication ?? value,
      _ => value,
    };

    return KokotobaSettings(
      userId: current.userId,
      displayRows: [
        for (final row in current.displayRows)
          SettingRow(
            label: row.label,
            value: displayValue(row.label, row.value),
          ),
      ],
      voiceRows: [
        for (final row in current.voiceRows)
          SettingRow(label: row.label, value: voiceValue(row.label, row.value)),
      ],
      supportToggles: [
        for (final toggle in current.supportToggles)
          SettingToggle(
            label: toggle.label,
            enabled: toggleValue(toggle.label, toggle.enabled),
          ),
      ],
      privacyToggles: [
        for (final toggle in current.privacyToggles)
          SettingToggle(
            label: toggle.label,
            enabled: toggleValue(toggle.label, toggle.enabled),
          ),
      ],
    );
  }
}
