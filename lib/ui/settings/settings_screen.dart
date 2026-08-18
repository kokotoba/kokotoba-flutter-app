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
  KokotobaSettings? settings;
  Object? loadError;
  bool saving = false;
  final toggles = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => loadError = null);
    try {
      final fetched = await widget.controller.fetchSettings();
      if (!mounted) return;
      setState(() => _applySettings(fetched));
    } catch (error) {
      if (!mounted) return;
      setState(() => loadError = error);
    }
  }

  void _applySettings(KokotobaSettings updated) {
    settings = updated;
    toggles
      ..clear()
      ..addEntries(
        [
          ...updated.supportToggles,
          ...updated.privacyToggles,
        ].map((toggle) => MapEntry(toggle.label, toggle.enabled)),
      );
  }

  Future<bool> _save(KokotobaSettingsUpdate update) async {
    setState(() => saving = true);
    try {
      final updated = await widget.controller.updateSettings(update);
      if (!mounted) return false;
      setState(() => _applySettings(updated));
      showMessage(context, '設定を保存しました');
      return true;
    } catch (error, stackTrace) {
      if (!mounted) return false;
      debugPrint('Failed to save settings: $error');
      debugPrintStack(stackTrace: stackTrace);
      showMessage(context, '設定を保存できませんでした');
      return false;
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _changeToggle(String label, bool value) async {
    final previous = toggles[label]!;
    setState(() => toggles[label] = value);
    final saved = await _save(_toggleUpdate(label, value));
    if (!saved && mounted) setState(() => toggles[label] = previous);
  }

  KokotobaSettingsUpdate _toggleUpdate(String label, bool value) {
    return switch (label) {
      '履歴を候補に利用' => KokotobaSettingsUpdate(useHistoryForSuggestions: value),
      '位置情報を候補に利用' => KokotobaSettingsUpdate(useLocationForSuggestions: value),
      '登録情報を候補に利用' => KokotobaSettingsUpdate(useProfileForSuggestions: value),
      '選択後に確認画面を表示' => KokotobaSettingsUpdate(
        showConfirmationAfterSelection: value,
      ),
      '会話履歴を保存' => KokotobaSettingsUpdate(saveConversationHistory: value),
      '外部通信を利用' => KokotobaSettingsUpdate(allowExternalCommunication: value),
      _ => throw ArgumentError.value(label, 'label'),
    };
  }

  Future<void> _editRow(SettingRow row) async {
    final choices = _choicesFor(row);
    final selected = await showDialog<_SettingChoice>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(row.label),
        children: [
          for (final choice in choices)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, choice),
              child: Row(
                children: [
                  Expanded(child: Text(choice.label)),
                  if (choice.label == row.value)
                    const Icon(Icons.check, color: rose700),
                ],
              ),
            ),
        ],
      ),
    );
    if (selected != null) await _save(selected.update);
  }

  List<_SettingChoice> _choicesFor(SettingRow row) {
    return switch (row.label) {
      '文字サイズ' => [
        for (final value in ['小さい', '標準', '大きい'])
          _SettingChoice(value, KokotobaSettingsUpdate(textSize: value)),
      ],
      'ボタンサイズ' => [
        for (final value in ['標準', '大きい'])
          _SettingChoice(value, KokotobaSettingsUpdate(buttonSize: value)),
      ],
      'コントラスト' => [
        for (final value in ['標準', '高い'])
          _SettingChoice(value, KokotobaSettingsUpdate(contrast: value)),
      ],
      '候補表示数' => [
        for (final value in [1, 2, 3, 4, 5])
          _SettingChoice(
            '$value件',
            KokotobaSettingsUpdate(suggestionCount: value),
          ),
      ],
      '読み上げ速度' => [
        for (final value in ['遅い', '標準', '速い'])
          _SettingChoice(value, KokotobaSettingsUpdate(speechRate: value)),
      ],
      '読み上げ音量' => [
        for (final value in [50, 60, 70, 80, 90, 100])
          _SettingChoice(
            '$value%',
            KokotobaSettingsUpdate(speechVolume: value),
          ),
      ],
      '読み上げ音声' => [
        for (final value in ['日本語 1', '日本語 2'])
          _SettingChoice(value, KokotobaSettingsUpdate(speechVoice: value)),
      ],
      _ => const [],
    };
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '設定',
      subtitle: '使いやすさを調整',
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final current = settings;
    if (current == null && loadError == null) {
      return const DelayedLoadingIndicator();
    }
    if (current == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('設定を読み込めませんでした'),
            const SizedBox(height: 12),
            FilledButton(onPressed: _loadSettings, child: const Text('再読み込み')),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (saving) const LinearProgressIndicator(),
        SettingsGroup(
          title: '表示',
          rows: current.displayRows,
          enabled: !saving,
          onRowTap: _editRow,
        ),
        const SizedBox(height: 20),
        SettingsGroup(
          title: '音声',
          rows: current.voiceRows,
          enabled: !saving,
          onRowTap: _editRow,
        ),
        const SizedBox(height: 20),
        ToggleGroup(
          title: '会話支援',
          labels: current.supportToggles.map((toggle) => toggle.label).toList(),
          values: toggles,
          enabled: !saving,
          onChanged: _changeToggle,
        ),
        const SizedBox(height: 20),
        ToggleGroup(
          title: 'プライバシー',
          labels: current.privacyToggles.map((toggle) => toggle.label).toList(),
          values: toggles,
          enabled: !saving,
          onChanged: _changeToggle,
        ),
      ],
    );
  }
}

class _SettingChoice {
  const _SettingChoice(this.label, this.update);

  final String label;
  final KokotobaSettingsUpdate update;
}
