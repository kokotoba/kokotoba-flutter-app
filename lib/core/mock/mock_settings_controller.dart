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
}
