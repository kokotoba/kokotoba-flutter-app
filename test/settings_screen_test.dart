import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kokotoba_flutter_app/core/controller/settings_controller.dart';
import 'package:kokotoba_flutter_app/core/mock/mock_settings_controller.dart';
import 'package:kokotoba_flutter_app/core/model/kokotoba_settings.dart';
import 'package:kokotoba_flutter_app/ui/settings/settings_screen.dart';

class _RecordingSettingsController implements SettingsController {
  final mock = const MockSettingsController();
  final updates = <KokotobaSettingsUpdate>[];

  @override
  Future<KokotobaSettings> fetchSettings() => mock.fetchSettings();

  @override
  Future<KokotobaSettings> updateSettings(KokotobaSettingsUpdate update) async {
    updates.add(update);
    return mock.updateSettings(update);
  }
}

void main() {
  testWidgets('スイッチ変更をControllerへ保存する', (tester) async {
    final controller = _RecordingSettingsController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SettingsScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('履歴を候補に利用'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    final historySwitch = find.byType(Switch).first;
    await tester.tap(historySwitch);
    await tester.pumpAndSettle();

    expect(controller.updates, hasLength(1));
    expect(controller.updates.single.useHistoryForSuggestions, isFalse);
    expect(find.text('設定を保存しました'), findsOneWidget);
  });

  testWidgets('表示設定を選択してControllerへ保存する', (tester) async {
    final controller = _RecordingSettingsController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SettingsScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('文字サイズ'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SimpleDialogOption, '標準'));
    await tester.pumpAndSettle();

    expect(controller.updates, hasLength(1));
    expect(controller.updates.single.textSize, '標準');
  });
}
