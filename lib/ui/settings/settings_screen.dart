import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/controller/settings_controller.dart';
import 'package:kokotoba_flutter_app/core/model/kokotoba_settings.dart';
import 'package:kokotoba_flutter_app/ui/common/components/delayed_loading_indicator.dart';
import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/settings/components/settings_components.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});

  final SettingsController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<KokotobaSettings> settingsFuture;
  final toggles = <String, bool>{};

  @override
  void initState() {
    super.initState();
    settingsFuture = widget.controller.fetchSettings();
  }

  void _setInitialToggles(KokotobaSettings settings) {
    if (toggles.isNotEmpty) return;
    for (final toggle in [
      ...settings.supportToggles,
      ...settings.privacyToggles,
    ]) {
      toggles[toggle.label] = toggle.enabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '設定',
      subtitle: '使いやすさを調整',
      child: FutureBuilder<KokotobaSettings>(
        future: settingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const DelayedLoadingIndicator();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('設定を読み込めませんでした'));
          }

          final settings = snapshot.data!;
          _setInitialToggles(settings);
          return ListView(
            children: [
              SettingsGroup(title: '表示', rows: settings.displayRows),
              const SizedBox(height: 20),
              SettingsGroup(title: '音声', rows: settings.voiceRows),
              const SizedBox(height: 20),
              ToggleGroup(
                title: '会話支援',
                labels: settings.supportToggles
                    .map((toggle) => toggle.label)
                    .toList(),
                values: toggles,
                onChanged: (key, value) => setState(() => toggles[key] = value),
              ),
              const SizedBox(height: 20),
              ToggleGroup(
                title: 'プライバシー',
                labels: settings.privacyToggles
                    .map((toggle) => toggle.label)
                    .toList(),
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
          );
        },
      ),
    );
  }
}
