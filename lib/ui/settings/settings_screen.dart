import 'package:flutter/material.dart';

import '../common/components/kokotoba_components.dart';
import '../theme/color.dart';
import 'components/settings_components.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final toggles = <String, bool>{
    '履歴を候補に利用': true,
    '位置情報を候補に利用': false,
    '登録情報を候補に利用': true,
    '選択後に確認画面を表示': true,
    '会話履歴を保存': true,
    '外部通信を利用': false,
  };

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '設定',
      subtitle: '使いやすさを調整',
      child: ListView(
        children: [
          const SettingsGroup(
            title: '表示',
            rows: [
              ('文字サイズ', '大きい'),
              ('ボタンサイズ', '大きい'),
              ('コントラスト', '標準'),
              ('候補表示数', '3件'),
            ],
          ),
          const SizedBox(height: 20),
          const SettingsGroup(
            title: '音声',
            rows: [('読み上げ速度', '標準'), ('読み上げ音量', '80%'), ('読み上げ音声', '日本語 1')],
          ),
          const SizedBox(height: 20),
          ToggleGroup(
            title: '会話支援',
            labels: toggles.keys.take(4).toList(),
            values: toggles,
            onChanged: (key, value) => setState(() => toggles[key] = value),
          ),
          const SizedBox(height: 20),
          ToggleGroup(
            title: 'プライバシー',
            labels: toggles.keys.skip(4).toList(),
            values: toggles,
            onChanged: (key, value) => setState(() => toggles[key] = value),
          ),
          const SizedBox(height: 20),
          Card(
            color: rose050,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: rose700, size: 25),
                  SizedBox(width: 12),
                  Expanded(child: Text('音声認識と文章候補は、基本的に端末内で処理されます。')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
